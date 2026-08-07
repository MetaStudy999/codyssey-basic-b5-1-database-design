-- B5-1 / SQLite sample data
PRAGMA foreign_keys = ON;

INSERT INTO categories (id, name, description) VALUES
(1, 'Database', 'Relational databases and SQL'),
(2, 'Python', 'Python programming and tooling'),
(3, 'Web', 'HTML, CSS, JavaScript and web architecture'),
(4, 'Algorithms', 'Data structures and algorithms'),
(5, 'Cloud', 'Cloud infrastructure and deployment'),
(6, 'AI', 'Machine learning and AI engineering'),
(7, 'Linux', 'Linux and operating systems'),
(8, 'Security', 'Application and system security'),
(9, 'DevOps', 'CI/CD, containers and operations'),
(10, 'Design', 'Software design and architecture');

INSERT INTO members (id, name, email, joined_at) VALUES
(1, 'Kim Minjun', 'minjun@example.com', '2026-01-05'),
(2, 'Lee Seoyeon', 'seoyeon@example.com', '2026-01-12'),
(3, 'Park Jihoon', 'jihoon@example.com', '2026-02-02'),
(4, 'Choi Yuna', 'yuna@example.com', '2026-02-14'),
(5, 'Jung Hyunwoo', 'hyunwoo@example.com', '2026-03-01'),
(6, 'Han Jiwon', 'jiwon@example.com', '2026-03-11'),
(7, 'Song Doyun', 'doyun@example.com', '2026-04-07'),
(8, 'Kang Sumin', 'sumin@example.com', '2026-04-23'),
(9, 'Yoon Jisoo', 'jisoo@example.com', '2026-05-04'),
(10, 'Lim Taehyun', 'taehyun@example.com', '2026-05-19'),
(11, 'Oh Nari', 'nari@example.com', '2026-06-02'),
(12, 'Seo Jun', 'jun@example.com', '2026-06-18');

INSERT INTO books (id, category_id, title, author, isbn, published_year, daily_fee) VALUES
(1, 1, 'SQL Fundamentals', 'A. Row', '9780000000001', 2023, 1200),
(2, 1, 'Practical Data Modeling', 'B. Key', '9780000000002', 2024, 1500),
(3, 2, 'Python Essentials', 'C. Py', '9780000000003', 2022, 1000),
(4, 2, 'Clean Python', 'D. Code', '9780000000004', 2025, 1300),
(5, 3, 'Modern Web Basics', 'E. DOM', '9780000000005', 2024, 1100),
(6, 4, 'Algorithms by Hand', 'F. Graph', '9780000000006', 2021, 1400),
(7, 4, 'Data Structures Lab', 'G. Heap', '9780000000007', 2025, 1400),
(8, 5, 'Cloud First Steps', 'H. VPC', '9780000000008', 2024, 1600),
(9, 6, 'AI Engineering Basics', 'I. Model', '9780000000009', 2025, 1700),
(10, 7, 'Linux Operations', 'J. Shell', '9780000000010', 2020, 900),
(11, 8, 'Web Security Primer', 'K. Guard', '9780000000011', 2023, 1500),
(12, 9, 'DevOps Pipeline', 'L. Deploy', '9780000000012', 2024, 1600),
(13, 10, 'Software Architecture Notes', 'M. Layer', '9780000000013', 2025, 1800),
(14, 1, 'Advanced SQL Practice', 'N. Join', '9780000000014', 2026, 1800),
(15, 6, 'Prompt Engineering', 'O. Context', '9780000000015', 2026, 1700);

INSERT INTO rentals (id, member_id, book_id, rented_at, due_at, returned_at, status, fee) VALUES
(1, 1, 1, '2026-06-01', '2026-06-08', '2026-06-07', 'returned', 8400),
(2, 2, 2, '2026-06-03', '2026-06-10', '2026-06-11', 'returned', 12000),
(3, 3, 3, '2026-06-05', '2026-06-12', '2026-06-12', 'returned', 7000),
(4, 1, 4, '2026-06-15', '2026-06-22', '2026-06-21', 'returned', 9100),
(5, 4, 5, '2026-06-18', '2026-06-25', '2026-06-25', 'returned', 7700),
(6, 5, 6, '2026-07-01', '2026-07-08', NULL, 'overdue', 11200),
(7, 6, 7, '2026-07-03', '2026-07-10', '2026-07-09', 'returned', 9800),
(8, 7, 8, '2026-07-05', '2026-07-12', NULL, 'rented', 11200),
(9, 8, 9, '2026-07-08', '2026-07-15', '2026-07-14', 'returned', 11900),
(10, 9, 10, '2026-07-10', '2026-07-17', NULL, 'overdue', 6300),
(11, 10, 11, '2026-07-12', '2026-07-19', '2026-07-18', 'returned', 10500),
(12, 2, 12, '2026-07-15', '2026-07-22', '2026-07-22', 'returned', 11200),
(13, 3, 13, '2026-07-18', '2026-07-25', NULL, 'rented', 12600),
(14, 4, 14, '2026-07-20', '2026-07-27', '2026-07-26', 'returned', 12600),
(15, 5, 15, '2026-07-22', '2026-07-29', NULL, 'rented', 11900),
(16, 6, 1, '2026-07-24', '2026-07-31', '2026-07-30', 'returned', 8400),
(17, 7, 2, '2026-07-26', '2026-08-02', NULL, 'overdue', 10500),
(18, 8, 3, '2026-07-28', '2026-08-04', '2026-08-03', 'returned', 7000);
