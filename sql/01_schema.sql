-- B5-1 / SQLite schema
-- SQLite-specific note: PRAGMA foreign_keys is required per connection to enforce FK constraints.
PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS rentals;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS categories;

CREATE TABLE categories (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT NOT NULL
);

CREATE TABLE members (
    id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    joined_at DATE NOT NULL
);

CREATE TABLE books (
    id INTEGER PRIMARY KEY,
    category_id INTEGER NOT NULL,
    title TEXT NOT NULL,
    author TEXT NOT NULL,
    isbn TEXT NOT NULL UNIQUE,
    published_year INTEGER NOT NULL CHECK (published_year BETWEEN 1900 AND 2100),
    daily_fee INTEGER NOT NULL DEFAULT 1000 CHECK (daily_fee >= 0),
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE RESTRICT
);

CREATE TABLE rentals (
    id INTEGER PRIMARY KEY,
    member_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    rented_at DATE NOT NULL,
    due_at DATE NOT NULL,
    returned_at DATE,
    status TEXT NOT NULL CHECK (status IN ('rented', 'returned', 'overdue')),
    fee INTEGER NOT NULL DEFAULT 0 CHECK (fee >= 0),
    FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES books(id) ON DELETE RESTRICT,
    CHECK (due_at >= rented_at),
    CHECK (returned_at IS NULL OR returned_at >= rented_at)
);
