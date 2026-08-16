-- B5-1 Reference: 핵심 SQL Query 15개
PRAGMA foreign_keys = ON;
.headers on
.mode column

-- Q01. 전체 도서 기본 조회
SELECT id, title, author, publication_year, category_id
FROM books;

-- Q02. 2023년 이후 출판 도서 조건 조회
SELECT id, title, publication_year
FROM books
WHERE publication_year >= 2023;

-- Q03. 제목에 SQL이 포함된 도서 검색
SELECT id, title, author
FROM books
WHERE title LIKE '%SQL%';

-- Q04. 최신 출판년도 순으로 상위 5권 정렬
SELECT id, title, publication_year
FROM books
ORDER BY publication_year DESC, id ASC
LIMIT 5;

-- Q05. 대여기록 + 회원 + 도서 3테이블 INNER JOIN
SELECT
    r.id AS rental_id,
    m.name AS member_name,
    b.title AS book_title,
    r.rented_at,
    r.returned_at
FROM rentals AS r
JOIN members AS m ON m.id = r.member_id
JOIN books AS b ON b.id = r.book_id
ORDER BY r.id;

-- Q06. 도서와 카테고리 JOIN
SELECT
    b.id,
    b.title,
    c.name AS category_name
FROM books AS b
JOIN categories AS c ON c.id = b.category_id
ORDER BY b.id;

-- Q07. 대여가 없는 회원까지 포함하는 LEFT JOIN + 건수
SELECT
    m.id,
    m.name,
    COUNT(r.id) AS rental_count
FROM members AS m
LEFT JOIN rentals AS r ON r.member_id = m.id
GROUP BY m.id, m.name
ORDER BY m.id;

-- Q08. 카테고리별 도서 수 집계
SELECT
    c.id,
    c.name,
    COUNT(b.id) AS book_count
FROM categories AS c
LEFT JOIN books AS b ON b.category_id = c.id
GROUP BY c.id, c.name
ORDER BY book_count DESC, c.id;

-- Q09. 대여 2회 이상 회원만 HAVING으로 조회
SELECT
    m.id,
    m.name,
    COUNT(r.id) AS rental_count
FROM members AS m
JOIN rentals AS r ON r.member_id = m.id
GROUP BY m.id, m.name
HAVING COUNT(r.id) >= 2
ORDER BY rental_count DESC, m.id;

-- Q10. 도서 출판연도 MIN/MAX/AVG 집계
SELECT
    MIN(publication_year) AS oldest_year,
    MAX(publication_year) AS newest_year,
    ROUND(AVG(publication_year), 1) AS avg_year
FROM books;

-- Q11. 서브쿼리: Database 카테고리에 속한 도서
SELECT id, title, author
FROM books
WHERE category_id = (
    SELECT id
    FROM categories
    WHERE name = 'Database'
)
ORDER BY id;

-- Q12. 서브쿼리: AI 도서를 한 번이라도 대여한 회원
SELECT id, name, email
FROM members
WHERE id IN (
    SELECT DISTINCT r.member_id
    FROM rentals AS r
    JOIN books AS b ON b.id = r.book_id
    JOIN categories AS c ON c.id = b.category_id
    WHERE c.name = 'AI'
)
ORDER BY id;

-- Q13. 상관 서브쿼리: 도서별 누적 대여 횟수
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

-- Q14. UPDATE 실습: 변경 결과를 확인한 뒤 seed 상태로 복구
SAVEPOINT q14_update;
UPDATE books
SET publication_year = 2026
WHERE id = 1;
SELECT id, title, publication_year
FROM books
WHERE id = 1;
ROLLBACK TO q14_update;
RELEASE q14_update;

-- Q15. DELETE 실습: 삭제 결과를 확인한 뒤 seed 상태로 복구
SAVEPOINT q15_delete;
DELETE FROM rentals
WHERE id = 1;
SELECT COUNT(*) AS rental_rows_after_delete
FROM rentals;
ROLLBACK TO q15_delete;
RELEASE q15_delete;
