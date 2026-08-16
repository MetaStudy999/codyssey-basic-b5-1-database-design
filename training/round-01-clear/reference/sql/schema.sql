-- B5-1 Reference schema: Library Rental
-- SQLite 기준. FK 검증을 반드시 활성화한다.

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS members;

CREATE TABLE members (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    joined_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    publication_year INTEGER NOT NULL CHECK (publication_year BETWEEN 1000 AND 2100),
    category_id INTEGER NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

CREATE TABLE rentals (
    id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    rented_at TEXT NOT NULL,
    returned_at TEXT,
    FOREIGN KEY (member_id) REFERENCES members(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES books(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CHECK (returned_at IS NULL OR returned_at >= rented_at)
);
