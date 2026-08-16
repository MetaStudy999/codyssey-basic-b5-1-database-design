#!/usr/bin/env bash
# B5-1 R01 runtime helper.
# Run this only in Phase C. It creates a fresh temporary SQLite DB and writes real execution output to evidence/runtime/.

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROUND_DIR=$(cd "$SCRIPT_DIR/.." && pwd)
SQL_DIR="$ROUND_DIR/reference/sql"
EVIDENCE_DIR="$ROUND_DIR/evidence/runtime"
DB=$(mktemp /tmp/codyssey-b5-1-runtime-XXXXXX.sqlite3)
trap 'rm -f "$DB"' EXIT

if ! command -v sqlite3 >/dev/null 2>&1; then
  echo "[FAIL] sqlite3 command not found"
  exit 1
fi

mkdir -p "$EVIDENCE_DIR"

sqlite3 "$DB" < "$SQL_DIR/schema.sql"
sqlite3 "$DB" < "$SQL_DIR/seed.sql"

{
  echo "# B5-1 Runtime Constraints"
  echo "sqlite3: $(sqlite3 --version)"
  echo
  echo "## schema"
  sqlite3 "$DB" '.schema'
  echo
  echo "## row counts"
  sqlite3 -header -column "$DB" <<'SQL'
SELECT 'members' AS table_name, COUNT(*) AS rows FROM members
UNION ALL SELECT 'categories', COUNT(*) FROM categories
UNION ALL SELECT 'books', COUNT(*) FROM books
UNION ALL SELECT 'rentals', COUNT(*) FROM rentals;
SQL
  echo
  echo "## foreign keys"
  sqlite3 -header -column "$DB" "PRAGMA foreign_key_list('books');"
  sqlite3 -header -column "$DB" "PRAGMA foreign_key_list('rentals');"
  echo
  echo "## invalid FK test"
  if sqlite3 "$DB" "PRAGMA foreign_keys=ON; INSERT INTO books(id,title,author,publication_year,category_id) VALUES(999,'invalid-fk','tester',2026,999);" 2>&1; then
    echo "UNEXPECTED: invalid FK insert succeeded"
    exit 1
  else
    echo "EXPECTED: invalid FK insert rejected"
  fi
} > "$EVIDENCE_DIR/constraints.txt" 2>&1

sqlite3 "$DB" < "$SQL_DIR/queries.sql" > "$EVIDENCE_DIR/query-results.txt" 2>&1
sqlite3 "$DB" < "$SQL_DIR/indexes.sql" > "$EVIDENCE_DIR/index-plan.txt" 2>&1

cat <<EOF
[PASS] fresh SQLite database created and removed safely
[PASS] constraints evidence: $EVIDENCE_DIR/constraints.txt
[PASS] Q01-Q16 results: $EVIDENCE_DIR/query-results.txt
[PASS] index/query-plan evidence: $EVIDENCE_DIR/index-plan.txt

Still required before CLEAR:
- write $EVIDENCE_DIR/evaluation.md in your own words
- run: bash training/round-01-clear/environment/verify.sh --runtime
EOF
