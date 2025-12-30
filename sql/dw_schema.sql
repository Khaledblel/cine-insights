-- 1. Create a separate Schema for the Data Warehouse to keep it clean
CREATE SCHEMA IF NOT EXISTS dw;

-- ==========================================
-- 2. CREATE DIMENSION TABLES
-- ==========================================

-- Dimension: Date
-- Essential for analyzing the "Friday/Saturday" weighted logic.
CREATE TABLE IF NOT EXISTS dw.Dim_Date (
    date_key            INTEGER PRIMARY KEY,  -- Format: YYYYMMDD
    full_date           DATE,
    day_name            VARCHAR(20),          -- 'Friday', 'Saturday'...
    day_of_week         INTEGER,              -- 1=Monday, 7=Sunday
    is_weekend          BOOLEAN,              -- True for Sat/Sun (or Fri/Sat/Sun based on TN logic)
    month_name          VARCHAR(20),
    quarter             INTEGER,
    year                INTEGER
);

-- Dimension: Theater (Location)
-- Essential for "Tunis vs Sousse" volume analysis.
CREATE TABLE IF NOT EXISTS dw.Dim_Theater (
    theater_key         SERIAL PRIMARY KEY,   -- Surrogate Key
    theater_source_id   INTEGER,              -- ID from the App source
    theater_name        VARCHAR(100),
    city                VARCHAR(50),
    capacity_factor     DECIMAL(3,1)          -- To normalize efficiency (Revenue / Capacity)
);

-- Dimension: Movie
-- Essential for Price Logic (Vote Avg) and Runtime analysis.
CREATE TABLE IF NOT EXISTS dw.Dim_Movie (
    movie_key           SERIAL PRIMARY KEY,
    movie_source_id     INTEGER,              -- ID from TMDB
    title               VARCHAR(255),
    primary_genre       VARCHAR(50),          -- For Gender correlation
    runtime             INTEGER,
    runtime_category    VARCHAR(20),          -- 'Short' (<90), 'Medium', 'Long' (>150)
    vote_average        DECIMAL(3,1),         -- To analyze Price vs Quality
    budget              BIGINT,
    release_year        INTEGER
);

-- Dimension: Customer
-- Essential for Demographics (Age/Gender) analysis.
CREATE TABLE IF NOT EXISTS dw.Dim_Customer (
    customer_key        SERIAL PRIMARY KEY,
    customer_source_id  INTEGER,
    gender              CHAR(1),
    age                 INTEGER,
    age_group           VARCHAR(20),          -- 'Teen', 'Young Adult', 'Adult', 'Senior'
    city                VARCHAR(50)           -- Where they live (Correlation with Theater)
);

-- Dimension: Weather
-- Essential for "Rain vs Sales" analysis.
-- We will store unique daily weather observations here.
CREATE TABLE IF NOT EXISTS dw.Dim_Weather (
    weather_key         SERIAL PRIMARY KEY,
    city                VARCHAR(50),          -- Weather is local
    date_ref            DATE,                 -- Reference date for lookup
    weather_state       VARCHAR(50),          -- 'Rainy', 'Clear'...
    temp_category       VARCHAR(20),          -- 'Cold', 'Hot'...
    min_temp            DECIMAL(5,2),         -- Specific metrics
    max_temp            DECIMAL(5,2),
    precipitation_mm    DECIMAL(6,2),         -- Important for rain logic
    daylight_hours      DECIMAL(4,2)          -- Important for seasonality
);

-- ==========================================
-- 3. CREATE FACT TABLE
-- ==========================================

-- Fact: Ticket Sales
-- This records every transaction with links to all dimensions.
CREATE TABLE IF NOT EXISTS dw.Fact_Ticket_Sales (
    sales_key           SERIAL PRIMARY KEY,
    transaction_id      INTEGER,              -- Lineage to source
    
    -- Foreign Keys
    date_key            INTEGER REFERENCES dw.Dim_Date(date_key),
    theater_key         INTEGER REFERENCES dw.Dim_Theater(theater_key),
    movie_key           INTEGER REFERENCES dw.Dim_Movie(movie_key),
    customer_key        INTEGER REFERENCES dw.Dim_Customer(customer_key),
    weather_key         INTEGER REFERENCES dw.Dim_Weather(weather_key),
    
    -- Measures (Facts)
    ticket_price        DECIMAL(10,2),        -- To analyze Pricing Logic
    quantity            INTEGER,              -- Usually 1
    total_amount        DECIMAL(10,2),        -- Revenue
    
    -- Derived/calculated measures could go here or in Views
    discount_amount     DECIMAL(10,2) DEFAULT 0
);