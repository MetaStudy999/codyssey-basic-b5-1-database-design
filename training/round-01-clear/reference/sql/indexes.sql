-- B5-1 Reference indexes
-- FK/JOIN 조건에서 자주 사용하는 컬럼에 index를 둔다.

CREATE INDEX IF NOT EXISTS idx_books_category_id
ON books(category_id);

CREATE INDEX IF NOT EXISTS idx_rentals_member_id
ON rentals(member_id);

CREATE INDEX IF NOT EXISTS idx_rentals_book_id
ON rentals(book_id);

-- SQLite에서 실제 Query Plan을 확인하는 예시
EXPLAIN QUERY PLAN
SELECT r.id, m.name, b.title
FROM rentals AS r
JOIN members AS m ON m.id = r.member_id
JOIN books AS b ON b.id = r.book_id
WHERE r.member_id = 1;
