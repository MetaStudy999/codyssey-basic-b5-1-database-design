-- B5-1 Reference: 핵심 SQL Query 16개
-- SQLite Reference.
-- .headers/.mode/.print는 SQLite CLI 전용 지시어이며, 실행 결과를 Q 번호별로 구분하기 위해 사용한다.
PRAGMA foreign_keys = ON;
.headers on
.mode column

.print '=== Q01 [BASIC] 전체 도서 기본 조회 ==='
-- Q01. [BASIC] 전체 도서 기본 조회
SELECT id, title, author, publication_year, category_id
FROM books;

.print '=== Q02 [BASIC] WHERE 조건 조회 ==='
-- Q02. [BASIC] 2023년 이후 출판 도서 조건 조회
SELECT id, title, publication_year
FROM books
WHERE publication_year >= 2023;

.print '=== Q03 [BASIC] LIKE 검색 ==='
-- Q03. [BASIC] 제목에 SQL이 포함된 도서 검색
SELECT id, title, author
FROM books
WHERE title LIKE '%SQL%';

.print '=== Q04 [BASIC] ORDER BY + LIMIT ==='
-- Q04. [BASIC] 최신 출판년도 순으로 상위 5권 정렬
SELECT id, title, publication_year
FROM books
ORDER BY publication_year DESC, id ASC
LIMIT 5;

.print '=== Q05 [JOIN] 3-table INNER JOIN ==='
-- Q05. [JOIN] 대여기록 + 회원 + 도서 3테이블 INNER JOIN
SELECT
    r.id AS rental_id,
    m.name AS member_name,
    b.title AS book_title,
    r.rented_at,
    r.returned_at
FROM rentals AS r
INNER JOIN members AS m ON m.id = r.member_id
INNER JOIN books AS b ON b.id = r.book_id
ORDER BY r.id;

.print '=== Q06 [JOIN] books/categories INNER JOIN ==='
-- Q06. [JOIN] 도서와 카테고리 INNER JOIN
SELECT
    b.id,
    b.title,
    c.name AS category_name
FROM books AS b
INNER JOIN categories AS c ON c.id = b.category_id
ORDER BY b.id;

.print '=== Q07 [JOIN] members/rentals LEFT JOIN ==='
-- Q07. [JOIN] 대여가 없는 회원까지 포함하는 LEFT JOIN + 건수
SELECT
    m.id,
    m.name,
    COUNT(r.id) AS rental_count
FROM members AS m
LEFT JOIN rentals AS r ON r.member_id = m.id
GROUP BY m.id, m.name
ORDER BY m.id;

.print '=== Q08 [JOIN] categories/books LEFT JOIN ==='
-- Q08. [JOIN] 카테고리별 도서 수를 LEFT JOIN으로 확인
SELECT
    c.id,
    c.name,
    COUNT(b.id) AS book_count
FROM categories AS c
LEFT JOIN books AS b ON b.category_id = c.id
GROUP BY c.id, c.name
ORDER BY book_count DESC, c.id;

.print '=== Q09 [AGGREGATE] GROUP BY + HAVING + COUNT ==='
-- Q09. [AGGREGATE] 대여 2회 이상 회원만 GROUP BY/HAVING으로 조회
SELECT
    m.id,
    m.name,
    COUNT(r.id) AS rental_count
FROM members AS m
INNER JOIN rentals AS r ON r.member_id = m.id
GROUP BY m.id, m.name
HAVING COUNT(r.id) >= 2
ORDER BY rental_count DESC, m.id;

.print '=== Q10 [AGGREGATE] AVG publication year ==='
-- Q10. [AGGREGATE] 카테고리별 평균 출판연도와 도서 수
SELECT
    c.id,
    c.name,
    COUNT(b.id) AS book_count,
    ROUND(AVG(b.publication_year), 1) AS avg_publication_year
FROM categories AS c
INNER JOIN books AS b ON b.category_id = c.id
GROUP BY c.id, c.name
ORDER BY c.id;

.print '=== Q11 [AGGREGATE] member rental counts ==='
-- Q11. [AGGREGATE] 회원별 대여 횟수 집계
SELECT
    m.id,
    m.name,
    COUNT(r.id) AS rental_count
FROM members AS m
LEFT JOIN rentals AS r ON r.member_id = m.id
GROUP BY m.id, m.name
ORDER BY rental_count DESC, m.id;

.print '=== Q12 [SUBQUERY] Database category books ==='
-- Q12. [SUBQUERY] Database 카테고리에 속한 도서
SELECT id, title, author
FROM books
WHERE category_id = (
    SELECT id
    FROM categories
    WHERE name = 'Database'
)
ORDER BY id;

.print '=== Q13 [SUBQUERY] correlated rental count ==='
-- Q13. [SUBQUERY] 상관 서브쿼리로 도서별 누적 대여 횟수
SELECT
    b.id,
    b.title,
    (
        SELECT COUNT(*)
        FROM rentals AS r
        WHERE r.book_id = b.id
    ) AS rental_count
FROM books AS b
ORDER BY b.id;

.print '=== Q14 [MUTATION] UPDATE + rollback ==='
-- Q14. [MUTATION] UPDATE 실습: 변경 결과를 확인한 뒤 seed 상태로 복구
SAVEPOINT q14_update;
UPDATE books
SET publication_year = 2026
WHERE id = 1;
SELECT id, title, publication_year
FROM books
WHERE id = 1;
ROLLBACK TO q14_update;
RELEASE q14_update;

.print '=== Q15 [MUTATION] DELETE + rollback ==='
-- Q15. [MUTATION] DELETE 실습: 삭제 결과를 확인한 뒤 seed 상태로 복구
SAVEPOINT q15_delete;
DELETE FROM rentals
WHERE id = 1;
SELECT COUNT(*) AS rental_rows_after_delete
FROM rentals;
ROLLBACK TO q15_delete;
RELEASE q15_delete;

.print '=== Q16 [INDEX] CREATE INDEX + query plan ==='
-- Q16. [INDEX] books.category_id는 category-book JOIN과 필터에 반복 사용되므로 index 후보로 선택한다.
CREATE INDEX IF NOT EXISTS idx_books_category_id
ON books(category_id);

-- SQLite 전용: 실제 실행 계획에서 scan/search 여부를 확인한다.
EXPLAIN QUERY PLAN
SELECT b.id, b.title, c.name AS category_name
FROM books AS b
INNER JOIN categories AS c ON c.id = b.category_id
WHERE b.category_id = 3;
