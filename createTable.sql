-- Create table for Users
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(100) NOT NULL,
    password VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL,
    BOD TIMESTAMP NOT NULL,
    Gender VARCHAR(100) NOT NULL
);

-- Create table for Categories
CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Create table for Libraries
CREATE TABLE Libraries (
    library_id INT PRIMARY KEY,
    library_name VARCHAR(100) NOT NULL,
    address VARCHAR(100) NOT NULL
);


CREATE TABLE Books (
    book_id INT PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    author VARCHAR(100) NOT NULL,
    library_id INT NOT NULL,
    category_id INT NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (library_id) REFERENCES Libraries(library_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);


CREATE TABLE Loan_Systems (
    loan_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    borrow_date TIMESTAMP NOT NULL,
    return_date TIMESTAMP,
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
	CONSTRAINT loan_period CHECK (
        borrow_date <= created_at + INTERVAL '2 WEEK'
    ),
    CONSTRAINT automatic_return CHECK (
        return_date IS NULL OR return_date <= borrow_date+ INTERVAL '2 WEEK'
    )
);
	
	-- Function to check maximum books per user
CREATE OR REPLACE FUNCTION check_max_books_per_user() RETURNS TRIGGER AS $$
DECLARE
    active_loans_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO active_loans_count
    FROM Loan_Systems
    WHERE user_id = NEW.user_id AND return_date IS NULL;

    IF active_loans_count > 2 THEN
        RAISE EXCEPTION 'Maximum active loans per user exceeded';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to enforce maximum books per user constraint
CREATE TRIGGER enforce_max_books_per_user
BEFORE INSERT OR UPDATE ON Loan_Systems
FOR EACH ROW
EXECUTE FUNCTION check_max_books_per_user();


-- Create table for onhold Systems
CREATE TABLE Onhold_Systems (
    onhold_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    book_id INT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    quantity INT NOT NULL CHECK (quantity >= 0),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    FOREIGN KEY (book_id) REFERENCES Books(book_id) ON DELETE RESTRICT ON UPDATE RESTRICT
);

-- Function to check maximum books on hold per user
CREATE OR REPLACE FUNCTION check_max_books_on_hold_per_user() RETURNS TRIGGER AS $$
DECLARE
    onhold_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO onhold_count
    FROM Onhold_Systems
    WHERE user_id = NEW.user_id;

    IF onhold_count > 2 THEN
        RAISE EXCEPTION 'Maximum books on hold per user exceeded';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to enforce maximum books on hold per user constraint
CREATE TRIGGER enforce_max_books_on_hold_per_user
BEFORE INSERT OR UPDATE ON Onhold_Systems
FOR EACH ROW
EXECUTE FUNCTION check_max_books_on_hold_per_user();
