#!/usr/bin/env python3
"""Rebuild and verify the B5-1 SQLite deliverables using only Python stdlib."""

from __future__ import annotations

import re
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SQL_DIR = ROOT / "sql"
BUILD_DIR = ROOT / "build"
EVIDENCE_DIR = ROOT / "evidence"
DB_PATH = BUILD_DIR / "b5-1.sqlite3"

TABLES = ("categories", "members", "books", "rentals")
EXPECTED_MIN_ROWS = 10
QUERY_MARKER = re.compile(r"(?m)^-- Q(\d{2}) \[([^\]]+)\](.*)$")


def read_sql(name: str) -> str:
    return (SQL_DIR / name).read_text(encoding="utf-8")


def split_statements(sql: str) -> list[str]:
    statements: list[str] = []
    buffer = ""
    for line in sql.splitlines(keepends=True):
        buffer += line
        if sqlite3.complete_statement(buffer):
            statement = buffer.strip()
            if statement:
                statements.append(statement)
            buffer = ""
    if buffer.strip():
        raise ValueError(f"Incomplete SQL statement: {buffer}")
    return statements


def format_rows(cursor: sqlite3.Cursor, rows: list[sqlite3.Row]) -> str:
    headers = [item[0] for item in cursor.description or []]
    widths = [len(header) for header in headers]
    rendered_rows: list[list[str]] = []
    for row in rows:
        values = ["" if value is None else str(value) for value in row]
        rendered_rows.append(values)
        for index, value in enumerate(values):
            widths[index] = max(widths[index], len(value))
    if not headers:
        return "(no result columns)"
    header_line = " | ".join(header.ljust(widths[i]) for i, header in enumerate(headers))
    separator = "-+-".join("-" * width for width in widths)
    body = "\n".join(
        " | ".join(value.ljust(widths[i]) for i, value in enumerate(row))
        for row in rendered_rows
    )
    return f"{header_line}\n{separator}\n{body}" if body else f"{header_line}\n{separator}\n(0 rows)"


def parse_query_groups(sql: str) -> list[tuple[str, str, str, str]]:
    matches = list(QUERY_MARKER.finditer(sql))
    groups: list[tuple[str, str, str, str]] = []
    for idx, match in enumerate(matches):
        start = match.end()
        end = matches[idx + 1].start() if idx + 1 < len(matches) else len(sql)
        qid, category, description = match.group(1), match.group(2), match.group(3).strip()
        groups.append((qid, category, description, sql[start:end].strip()))
    return groups


def expect_integrity_error(conn: sqlite3.Connection, label: str, sql: str) -> str:
    conn.execute("SAVEPOINT constraint_test")
    try:
        conn.execute(sql)
    except sqlite3.IntegrityError as exc:
        conn.execute("ROLLBACK TO constraint_test")
        conn.execute("RELEASE constraint_test")
        return f"PASS | {label} | {exc}"
    else:
        conn.execute("ROLLBACK TO constraint_test")
        conn.execute("RELEASE constraint_test")
        raise AssertionError(f"{label}: constraint violation was not blocked")


def main() -> None:
    BUILD_DIR.mkdir(exist_ok=True)
    EVIDENCE_DIR.mkdir(exist_ok=True)
    if DB_PATH.exists():
        DB_PATH.unlink()

    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")

    conn.executescript(read_sql("01_schema.sql"))
    conn.executescript(read_sql("02_seed.sql"))

    found_tables = {
        row["name"]
        for row in conn.execute(
            "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
        )
    }
    assert found_tables == set(TABLES), found_tables

    row_count_lines = ["B5-1 row counts after clean seed"]
    for table in TABLES:
        count = conn.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
        assert count >= EXPECTED_MIN_ROWS, (table, count)
        row_count_lines.append(f"PASS | {table} | {count} rows (minimum {EXPECTED_MIN_ROWS})")
    (EVIDENCE_DIR / "row-counts.txt").write_text("\n".join(row_count_lines) + "\n", encoding="utf-8")

    fk_rows = []
    for table in ("books", "rentals"):
        fk_rows.extend((table, dict(row)) for row in conn.execute(f"PRAGMA foreign_key_list({table})"))
    assert len(fk_rows) >= 3

    constraint_lines = ["B5-1 constraint verification"]
    constraint_lines.append(
        expect_integrity_error(
            conn,
            "FK blocks missing member",
            "INSERT INTO rentals (id, member_id, book_id, rented_at, due_at, status, fee) "
            "VALUES (999, 999, 1, '2026-08-01', '2026-08-02', 'rented', 0)",
        )
    )
    constraint_lines.append(
        expect_integrity_error(
            conn,
            "UNIQUE blocks duplicate member email",
            "INSERT INTO members (id, name, email, joined_at) "
            "VALUES (999, 'Duplicate', 'minjun@example.com', '2026-08-01')",
        )
    )
    constraint_lines.append(
        expect_integrity_error(
            conn,
            "NOT NULL blocks missing category name",
            "INSERT INTO categories (id, name, description) VALUES (999, NULL, 'invalid')",
        )
    )
    constraint_lines.append(
        expect_integrity_error(
            conn,
            "CHECK blocks invalid published year",
            "INSERT INTO books (id, category_id, title, author, isbn, published_year, daily_fee) "
            "VALUES (999, 1, 'Invalid', 'Test', '9780999999999', 1800, 1000)",
        )
    )
    constraint_lines.append(f"PASS | FK definitions found | {len(fk_rows)}")
    (EVIDENCE_DIR / "constraints.txt").write_text("\n".join(constraint_lines) + "\n", encoding="utf-8")

    query_sql = read_sql("03_queries.sql")
    groups = parse_query_groups(query_sql)
    assert [qid for qid, *_ in groups] == [f"{i:02d}" for i in range(1, 16)]

    output_lines = ["B5-1 actual query results", f"Database: {DB_PATH.name}", ""]
    for qid, category, description, body in groups:
        output_lines.append(f"=== Q{qid} [{category}] {description} ===")
        statements = split_statements(body)
        assert statements, qid
        for statement in statements:
            cur = conn.execute(statement)
            if cur.description:
                rows = cur.fetchall()
                output_lines.append(format_rows(cur, rows))
            elif cur.rowcount >= 0:
                output_lines.append(f"OK | affected_rows={cur.rowcount}")
            else:
                output_lines.append("OK")
        output_lines.append("")

    (EVIDENCE_DIR / "query-results.txt").write_text("\n".join(output_lines), encoding="utf-8")

    final_rentals = conn.execute("SELECT COUNT(*) FROM rentals").fetchone()[0]
    assert final_rentals >= EXPECTED_MIN_ROWS
    updated = conn.execute("SELECT status, returned_at FROM rentals WHERE id=8").fetchone()
    assert tuple(updated) == ("returned", "2026-07-12")
    deleted = conn.execute("SELECT COUNT(*) FROM rentals WHERE id=18").fetchone()[0]
    assert deleted == 0
    idx = conn.execute(
        "SELECT COUNT(*) FROM sqlite_master WHERE type='index' AND name='idx_rentals_status_due_at'"
    ).fetchone()[0]
    assert idx == 1

    summary = [
        "B5-1 verification summary",
        "PASS | schema rebuild",
        f"PASS | tables={len(found_tables)}",
        f"PASS | foreign_keys={len(fk_rows)}",
        "PASS | each seeded table has >=10 rows",
        "PASS | FK/UNIQUE/NOT NULL/CHECK violations blocked",
        f"PASS | query_groups={len(groups)}",
        "PASS | UPDATE result verified",
        "PASS | DELETE result verified",
        "PASS | index created",
        f"PASS | final rentals rows={final_rentals}",
    ]
    (EVIDENCE_DIR / "verification-summary.txt").write_text("\n".join(summary) + "\n", encoding="utf-8")
    conn.commit()
    conn.close()
    print("\n".join(summary))


if __name__ == "__main__":
    main()
