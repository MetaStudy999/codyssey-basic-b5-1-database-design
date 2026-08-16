#!/usr/bin/env bash
# B5-1 R01 verification-only helper.

set -u

PASS=0
FAIL=0
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROUND_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
SQL_DIR="$ROUND_DIR/reference/sql"
DB=$(mktemp /tmp/codyssey-b5-1-XXXXXX.sqlite3)
trap 'rm -f "$DB" /tmp/b5-1-queries.out /tmp/b5-1-indexes.out' EXIT

pass() { echo "[PASS] $1"; PASS=$((PASS + 1)); }
fail() { echo "[FAIL] $1"; FAIL=$((FAIL + 1)); }

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "[FAIL] sqlite3 command not found"
  echo "Result: 0 PASS / 1 FAIL"
  exit 1
fi
pass "sqlite3 command"

for file in schema.sql seed.sql queries.sql indexes.sql; do
  [ -f "$SQL_DIR/$file" ] && pass "file exists: $file" || fail "file missing: $file"
done

if sqlite3 "$DB" < "$SQL_DIR/schema.sql" && sqlite3 "$DB" < "$SQL_DIR/seed.sql"; then
  pass "schema + seed execute"
else
  fail "schema + seed execute"
fi

for table in members categories books rentals; do
  count=$(sqlite3 "$DB" "PRAGMA foreign_keys=ON; SELECT COUNT(*) FROM $table;" 2>/dev/null || echo 0)
  if [ "$count" -ge 10 ] 2>/dev/null; then
    pass "$table has >= 10 rows ($count)"
  else
    fail "$table has >= 10 rows ($count)"
  fi
done

fk_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM pragma_foreign_key_list('books'); SELECT COUNT(*) FROM pragma_foreign_key_list('rentals');" | awk '{s+=$1} END{print s+0}')
if [ "$fk_count" -ge 3 ]; then pass "foreign keys >= 3"; else fail "foreign keys >= 3"; fi

unique_email=$(sqlite3 "$DB" "SELECT COUNT(*) FROM pragma_index_list('members') WHERE \"unique\"=1;" 2>/dev/null || echo 0)
if [ "$unique_email" -ge 1 ]; then pass "UNIQUE constraint/index present"; else fail "UNIQUE constraint/index present"; fi

# FK must reject an invalid parent reference when foreign_keys is ON.
if sqlite3 "$DB" "PRAGMA foreign_keys=ON; INSERT INTO books(id,title,author,publication_year,category_id) VALUES(999,'bad','bad',2026,999);" >/dev/null 2>&1; then
  fail "FK rejects invalid reference"
else
  pass "FK rejects invalid reference"
fi

if sqlite3 "$DB" < "$SQL_DIR/indexes.sql" >/tmp/b5-1-indexes.out 2>&1; then
  pass "indexes.sql execute"
else
  fail "indexes.sql execute"
fi

index_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND name IN ('idx_books_category_id','idx_rentals_member_id','idx_rentals_book_id');")
if [ "$index_count" -eq 3 ]; then pass "three reference indexes created"; else fail "reference indexes created ($index_count/3)"; fi

if sqlite3 "$DB" < "$SQL_DIR/queries.sql" >/tmp/b5-1-queries.out 2>&1; then
  pass "queries.sql executes"
else
  fail "queries.sql executes"
fi

# Q14/Q15 use rollback, therefore seed row counts should remain unchanged.
book1_year=$(sqlite3 "$DB" "SELECT publication_year FROM books WHERE id=1;")
rental_count=$(sqlite3 "$DB" "SELECT COUNT(*) FROM rentals;")
[ "$book1_year" = "2022" ] && pass "UPDATE practice rolls back to seed state" || fail "UPDATE rollback state"
[ "$rental_count" = "12" ] && pass "DELETE practice rolls back to seed state" || fail "DELETE rollback state"

query_markers=$(grep -Ec '^-- Q[0-9][0-9]\.' "$SQL_DIR/queries.sql" || true)
[ "$query_markers" -eq 15 ] && pass "15 numbered queries" || fail "15 numbered queries ($query_markers)"

for keyword in JOIN 'GROUP BY' HAVING 'SELECT DISTINCT' UPDATE DELETE; do
  if grep -qi "$keyword" "$SQL_DIR/queries.sql"; then pass "query coverage: $keyword"; else fail "query coverage missing: $keyword"; fi
done

echo
printf 'Result: %d PASS / %d FAIL\n' "$PASS" "$FAIL"
[ "$FAIL" -eq 0 ]
