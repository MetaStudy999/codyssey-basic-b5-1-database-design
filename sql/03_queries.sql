-- B5-1 / Core query set (15 queries)
-- Execute after 01_schema.sql and 02_seed.sql.
PRAGMA foreign_keys = ON;

-- Q01 [Basic SELECT] Database-category books, newest first, top 5.
SELECT b.id, b.title, b.published_year
FROM books AS b
WHERE b.category_id = 1
ORDER BY b.published_year DESC, b.id
LIMIT 5;

-- Q02 [Basic SELECT] Members who joined on or after 2026-04-01.
SELECT id, name, email, joined_at
FROM members
WHERE joined_at >= '2026-04-01'
ORDER BY joined_at, id;

-- Q03 [Basic SELECT] Active rentals (rented or overdue), most recent first.
SELECT id, member_id, book_id, rented_at, due_at, status
FROM rentals
WHERE status IN ('rented', 'overdue')
ORDER BY rented_at DESC, id DESC
LIMIT 10;

-- Q04 [Basic SELECT] Books with daily fee at least 1500.
SELECT id, title, daily_fee
FROM books
WHERE daily_fee >= 1500
ORDER BY daily_fee DESC, title;

-- Q05 [JOIN / INNER JOIN] Rental history with member and book names.
SELECT r.id AS rental_id, m.name AS member_name, b.title, r.status
FROM rentals AS r
INNER JOIN members AS m ON m.id = r.member_id
INNER JOIN books AS b ON b.id = r.book_id
ORDER BY r.id;

-- Q06 [JOIN / INNER JOIN] Books with their category.
SELECT b.id, b.title, c.name AS category_name
FROM books AS b
INNER JOIN categories AS c ON c.id = b.category_id
ORDER BY c.name, b.title;

-- Q07 [JOIN / LEFT JOIN] Every member and rental count, including members with zero rentals.
SELECT m.id, m.name, COUNT(r.id) AS rental_count
FROM members AS m
LEFT JOIN rentals AS r ON r.member_id = m.id
GROUP BY m.id, m.name
ORDER BY rental_count DESC, m.id;

-- Q08 [JOIN] Active rental details with category.
SELECT r.id, m.name AS member_name, b.title, c.name AS category_name, r.due_at, r.status
FROM rentals AS r
JOIN members AS m ON m.id = r.member_id
JOIN books AS b ON b.id = r.book_id
JOIN categories AS c ON c.id = b.category_id
WHERE r.status IN ('rented', 'overdue')
ORDER BY r.due_at, r.id;

-- Q09 [Aggregate] Rental count per member.
SELECT m.id, m.name, COUNT(r.id) AS rental_count
FROM members AS m
LEFT JOIN rentals AS r ON r.member_id = m.id
GROUP BY m.id, m.name
ORDER BY rental_count DESC, m.id;

-- Q10 [Aggregate] Total collected fee by category.
SELECT c.id, c.name, SUM(r.fee) AS total_fee
FROM categories AS c
JOIN books AS b ON b.category_id = c.id
JOIN rentals AS r ON r.book_id = b.id
GROUP BY c.id, c.name
ORDER BY total_fee DESC, c.id;

-- Q11 [Aggregate] Average fee by rental status.
SELECT status, ROUND(AVG(fee), 2) AS avg_fee
FROM rentals
GROUP BY status
ORDER BY status;

-- Q12 [Subquery] Members who have never rented a book.
SELECT m.id, m.name
FROM members AS m
WHERE NOT EXISTS (
    SELECT 1
    FROM rentals AS r
    WHERE r.member_id = m.id
)
ORDER BY m.id;

-- Q13 [UPDATE] Mark rental 8 as returned and record return date.
UPDATE rentals
SET status = 'returned',
    returned_at = '2026-07-12'
WHERE id = 8;
SELECT id, status, returned_at FROM rentals WHERE id = 8;

-- Q14 [DELETE] Delete rental 18 as a correction, then verify it no longer exists.
DELETE FROM rentals
WHERE id = 18;
SELECT COUNT(*) AS rental_18_count FROM rentals WHERE id = 18;

-- Q15 [INDEX] SQLite-specific CREATE INDEX to speed lookups by rental status and due date.
-- Reason: Q03/Q08 filter or order active rentals by status/due_at, so this composite index targets that access pattern.
CREATE INDEX IF NOT EXISTS idx_rentals_status_due_at
ON rentals(status, due_at);
SELECT name, sql
FROM sqlite_master
WHERE type = 'index' AND name = 'idx_rentals_status_due_at';
EXPLAIN QUERY PLAN
SELECT id, due_at
FROM rentals
WHERE status = 'overdue'
ORDER BY due_at;
