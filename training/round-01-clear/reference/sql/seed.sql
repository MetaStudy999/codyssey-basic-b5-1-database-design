-- B5-1 Reference sample data
PRAGMA foreign_keys = ON;

INSERT INTO members (id, name, email, joined_at) VALUES
(1, '김민준', 'minjun@example.com', '2026-01-10 09:00:00'),
(2, '이서연', 'seoyeon@example.com', '2026-01-12 10:00:00'),
(3, '박지훈', 'jihoon@example.com', '2026-01-15 11:00:00'),
(4, '최유진', 'yujin@example.com', '2026-02-01 12:00:00'),
(5, '정현우', 'hyunwoo@example.com', '2026-02-05 13:00:00'),
(6, '한지민', 'jimin@example.com', '2026-02-11 14:00:00'),
(7, '오서준', 'seojun@example.com', '2026-03-01 15:00:00'),
(8, '윤하은', 'haeun@example.com', '2026-03-07 16:00:00'),
(9, '임도윤', 'doyun@example.com', '2026-03-15 17:00:00'),
(10, '송수아', 'sua@example.com', '2026-04-01 18:00:00');

INSERT INTO categories (id, name) VALUES
(1, 'Technology'),
(2, 'AI'),
(3, 'Database'),
(4, 'Linux'),
(5, 'Web'),
(6, 'Network'),
(7, 'Security'),
(8, 'Algorithm'),
(9, 'Cloud'),
(10, 'Career');

INSERT INTO books (id, title, author, publication_year, category_id) VALUES
(1, 'Practical Linux', 'A. Kim', 2022, 4),
(2, 'Python Data Structures', 'B. Lee', 2023, 8),
(3, 'SQL Foundations', 'C. Park', 2021, 3),
(4, 'Modern Web Basics', 'D. Choi', 2024, 5),
(5, 'AI for Beginners', 'E. Jung', 2025, 2),
(6, 'Cloud Fundamentals', 'F. Han', 2023, 9),
(7, 'Network Essentials', 'G. Oh', 2020, 6),
(8, 'Secure Coding Basics', 'H. Yoon', 2024, 7),
(9, 'Developer Career Guide', 'I. Lim', 2019, 10),
(10, 'Computer Systems', 'J. Song', 2022, 1),
(11, 'Advanced SQL Practice', 'K. Seo', 2025, 3),
(12, 'Machine Learning Start', 'L. Moon', 2024, 2);

INSERT INTO rentals (id, member_id, book_id, rented_at, returned_at) VALUES
(1, 1, 1, '2026-05-01', '2026-05-08'),
(2, 1, 5, '2026-05-10', '2026-05-18'),
(3, 2, 3, '2026-05-02', '2026-05-09'),
(4, 2, 11, '2026-05-15', NULL),
(5, 3, 2, '2026-05-03', '2026-05-10'),
(6, 4, 4, '2026-05-04', '2026-05-11'),
(7, 5, 6, '2026-05-05', NULL),
(8, 6, 8, '2026-05-06', '2026-05-14'),
(9, 7, 7, '2026-05-07', '2026-05-15'),
(10, 8, 12, '2026-05-08', NULL),
(11, 3, 5, '2026-05-20', NULL),
(12, 9, 10, '2026-05-21', '2026-05-28');
