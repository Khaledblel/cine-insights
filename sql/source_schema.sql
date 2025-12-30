-- Create Customers Table
CREATE TABLE IF NOT EXISTS app_customers (
    customer_id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    gender CHAR(1),
    age INTEGER,
    email VARCHAR(150),
    city VARCHAR(50),
    created_at DATE
);

-- Create Theaters Table (Lookup table for the source system)
CREATE TABLE IF NOT EXISTS app_theaters (
    theater_id INTEGER PRIMARY KEY,
    name VARCHAR(100),
    city VARCHAR(50),
    capacity_factor DECIMAL(3,1)
);

-- Create Sales Table (Transactional Fact in Source)
CREATE TABLE IF NOT EXISTS app_sales (
    transaction_id INTEGER PRIMARY KEY,
    date_key DATE,
    customer_id INTEGER,
    movie_id INTEGER,
    theater_id INTEGER,
    city VARCHAR(50),
    ticket_price DECIMAL(6,2),
    quantity INTEGER,
    total_amount DECIMAL(8,2),
    CONSTRAINT fk_customer
        FOREIGN KEY(customer_id)
        REFERENCES app_customers(customer_id)
);
