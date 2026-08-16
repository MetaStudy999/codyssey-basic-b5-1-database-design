#!/usr/bin/env bash
# B5-1 R01 verification-only helper.
# Reference checks use a temporary SQLite DB. --runtime additionally checks Evidence files.

set -u

PASS=0
FAIL=0
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROUND_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
SQL_DIR="$ROUND_DIR/reference/sql"
EVIDENCE_DIR="$ROUND_DIR/evidence/runtime"
DB=$(mktemp /tmp/codyssey-b5-1-XXXXXX.sqlite3)
TEST_OUT=$(mktemp /tmp/codyssey-b5-1-queries-XXXXXX.txt)
INDEX_OUT=$(mktemp /tmp/codyssey-b5-1-indexes-XXXXXX.txt)
trap 'rm -f "$DB" "$TEST_OUT" "$INDEX_OUT"' EXIT

pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "[FAIL] sqlite3 command not found"
  echo "Result: 0 PASS / 1 FAIL"
  exit 1
fi
pass "sqlite3 command"

sqlite_version=$(sqlite3 --version | awk '{print $1}')
[ -n "$sqlite_version" ] && pass "sqlite3 version: $sqlite_version" || fail "sqlite3 version unavailable"

for file in schema.sql seed.sql queries.sql indexes.sql; do
  [ -f "$SQL_DIR/$file" ] && pass "file exists: $file" || fail "file missing: $file"
done

if sqlite3 "$DB" < "$SQL_DIR/schema.sql" && sqlite3 "$DB" < "$SQL_DIR/seed.sql"; then
  pass "fresh schema + seed execute"
else
  fail "fresh schema + seed execute"
fi

table_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name IN ('members','categories','books','rentals');" 2>/dev/null || echo 0)
[ "$table_count" -eq 4 ] 2>/dev/null && pass "required tables = 4" || fail "required tables = 4 ($table_count/4)"

for table in members categories books rentals; do
  pk_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM pragma_table_info('$table') WHERE pk > 0;" 2>/dev/null || echo 0)
  [ "$pk_count" -ge 1 ] 2>/dev/null && pass "$table has PK" || fail "$table has PK"

done

fk_count=$(sqlite3 "$DB" "SELECT (SELECT COUNT(*) FROM pragma_foreign_key_list('books')) + (SELECT COUNT(*) FROM pragma_foreign_key_list('rentals'));" 2>/dev/null || echo 0)
[ "$fk_count" -ge 3 ] 2>/dev/null && pass "foreign keys >= 3 ($fk_count)" || fail "foreign keys >= 3 ($fk_count)"

not_null_count=$(sqlite3 "$DB" "SELECT (SELECT COALESCE(SUM(\"notnull\"),0) FROM pragma_table_info('members')) + (SELECT COALESCE(SUM(\"notnull\"),0) FROM pragma_table_info('categories')) + (SELECT COALESCE(SUM(\"notnull\"),0) FROM pragma_table_info('books')) + (SELECT COALESCE(SUM(\"notnull\"),0) FROM pragma_table_info('rentals'));" 2>/dev/null || echo 0)
[ "$not_null_count" -ge 1 ] 2>/dev/null && pass "NOT NULL constraint present" || fail "NOT NULL constraint present"

unique_count=$(sqlite3 "$DB" "SELECT (SELECT COUNT(*) FROM pragma_index_list('members') WHERE \"unique\"=1) + (SELECT COUNT(*) FROM pragma_index_list('categories') WHERE \"unique\"=1);" 2>/dev/null || echo 0)
[ "$unique_count" -ge 2 ] 2>/dev/null && pass "UNIQUE constraints present" || fail "UNIQUE constraints present"

for table in members categories books rentals; do
  count=$(sqlite3 "$DB" "PRAGMA foreign_keys=ON; SELECT COUNT(*) FROM $table;" 2>/dev/null || echo 0)
  if [ "$count" -ge 10 ] 2>/dev/null; then
    pass "$table has >= 10 rows ($count)"
  else
    fail "$table has >= 10 rows ($count)"
  fi
done

# Referential integrity must be enforced, not merely declared.
if sqlite3 "$DB" "PRAGMA foreign_keys=ON; INSERT INTO books(id,title,author,publication_year,category_id) VALUES(999,'invalid-fk','tester',2026,999);" >/dev/null 2>&1; then
  fail "FK rejects missing parent"
else
  pass "FK rejects missing parent"
fi

# NOT NULL / UNIQUE should also reject invalid data.
if sqlite3 "$DB" "INSERT INTO members(id,name,email) VALUES(999,NULL,'null-name@example.com');" >/dev/null 2>&1; then
  fail "NOT NULL rejects NULL name"
else
  pass "NOT NULL rejects NULL name"
fi

if sqlite3 "$DB" "INSERT INTO members(id,name,email) VALUES(998,'duplicate','minjun@example.com');" >/dev/null 2>&1; then
  fail "UNIQUE rejects duplicate email"
else
  pass "UNIQUE rejects duplicate email"
fi

if sqlite3 "$DB" < "$SQL_DIR/queries.sql" >"$TEST_OUT" 2>&1; then
  pass "queries.sql executes on fresh seeded DB"
else
  fail "queries.sql executes (inspect runtime output)"
fi

# Q14/Q15 are intentionally rolled back, so the reference dataset must stay reproducible.
book1_year=$(sqlite3 "$DB" "SELECT publication_year FROM books WHERE id=1;" 2>/dev/null || true)
rental_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM rentals;" 2>/dev/null || true)
[ "$book1_year" = "2022" ] && pass "UPDATE practice rolls back to seed state" || fail "UPDATE rollback state"
[ "$rental_count" = "12" ] && pass "DELETE practice rolls back to seed state" || fail "DELETE rollback state"

query_markers=$(grep -Ec '^-- Q[0-9][0-9]\.' "$SQL_DIR/queries.sql" || true)
[ "$query_markers" -ge 15 ] && pass "numbered queries >= 15 ($query_markers)" || fail "numbered queries >= 15 ($query_markers)"

basic_count=$(grep -Ec '^-- Q[0-9][0-9]\. \[BASIC\]' "$SQL_DIR/queries.sql" || true)
join_count=$(grep -Ec '^-- Q[0-9][0-9]\. \[JOIN\]' "$SQL_DIR/queries.sql" || true)
aggregate_count=$(grep -Ec '^-- Q[0-9][0-9]\. \[AGGREGATE\]' "$SQL_DIR/queries.sql" || true)
subquery_count=$(grep -Ec '^-- Q[0-9][0-9]\. \[SUBQUERY\]' "$SQL_DIR/queries.sql" || true)
mutation_count=$(grep -Ec '^-- Q[0-9][0-9]\. \[MUTATION\]' "$SQL_DIR/queries.sql" || true)
index_query_count=$(grep -Ec '^-- Q[0-9][0-9]\. \[INDEX\]' "$SQL_DIR/queries.sql" || true)

[ "$basic_count" -ge 4 ] && pass "basic queries >= 4" || fail "basic queries >= 4 ($basic_count)"
[ "$join_count" -ge 4 ] && pass "join queries >= 4" || fail "join queries >= 4 ($join_count)"
[ "$aggregate_count" -ge 3 ] && pass "aggregate queries >= 3" || fail "aggregate queries >= 3 ($aggregate_count)"
[ "$subquery_count" -ge 1 ] && pass "subquery >= 1" || fail "subquery >= 1 ($subquery_count)"
[ "$mutation_count" -ge 2 ] && pass "UPDATE/DELETE exercises >= 2" || fail "UPDATE/DELETE exercises >= 2 ($mutation_count)"
[ "$index_query_count" -ge 1 ] && pass "index query >= 1" || fail "index query >= 1 ($index_query_count)"

inner_join_count=$(grep -Eic '^[[:space:]]*INNER JOIN ' "$SQL_DIR/queries.sql" || true)
left_join_count=$(grep -Eic '^[[:space:]]*LEFT JOIN ' "$SQL_DIR/queries.sql" || true)
[ "$inner_join_count" -ge 2 ] && pass "INNER JOIN occurrences >= 2" || fail "INNER JOIN occurrences >= 2 ($inner_join_count)"
[ "$left_join_count" -ge 1 ] && pass "LEFT JOIN occurrences >= 1" || fail "LEFT JOIN occurrences >= 1 ($left_join_count)"

aggregate_types=0
for fn in COUNT SUM AVG; do
  if grep -Eqi "${fn}[[:space:]]*\(" "$SQL_DIR/queries.sql"; then
    aggregate_types=$((aggregate_types + 1))
  fi
done
[ "$aggregate_types" -ge 2 ] && pass "at least 2 of COUNT/SUM/AVG" || fail "at least 2 of COUNT/SUM/AVG ($aggregate_types/2)"

for token in 'WHERE ' 'ORDER BY' 'LIMIT ' 'GROUP BY' 'UPDATE ' 'DELETE FROM' 'CREATE INDEX'; do
  grep -qi "$token" "$SQL_DIR/queries.sql" && pass "query coverage: $token" || fail "query coverage missing: $token"
done

index_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND name='idx_books_category_id';" 2>/dev/null || echo 0)
[ "$index_count" -eq 1 ] 2>/dev/null && pass "Q16 index created" || fail "Q16 index created"

# Supplemental index pack must remain executable and idempotent.
if sqlite3 "$DB" < "$SQL_DIR/indexes.sql" >"$INDEX_OUT" 2>&1; then
  pass "supplemental indexes.sql executes"
else
  fail "supplemental indexes.sql executes"
fi

supplemental_index_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND name IN ('idx_books_category_id','idx_rentals_member_id','idx_rentals_book_id');" 2>/dev/null || echo 0)
[ "$supplemental_index_count" -eq 3 ] 2>/dev/null && pass "three reference indexes available" || fail "three reference indexes available ($supplemental_index_count/3)"

if [ "${1:-}" = "--runtime" ]; then
  for file in query-results.txt constraints.txt index-plan.txt evaluation.md; do
    if [ -s "$EVIDENCE_DIR/$file" ]; then
      pass "runtime evidence: $file"
    else
      fail "runtime evidence missing/empty: $file"
    fi
  done
fi

echo
printf 'Result: %d PASS / %d FAIL\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
