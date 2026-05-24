-- =====================================================
-- BLACK FRIDAY SALES ANALYSIS PROJECT
-- =====================================================

-- 1. LOADING DATASET
-- CREATE AND USE DATABASE
CREATE DATABASE black_friday_sales_analysis;
USE black_friday_sales_analysis;
-- CREATE TABLE AND INSERT DATA
-- (STEP 1 — CREATE TABLE USING IMPORT WIZARD)
-- Use MySQL Workbench:
-- Navigator → Schemas
-- Right Click Database
-- Table Data Import Wizard
-- Select:
-- retail_black_friday_sales_100k.csv
-- IMPORTANT:
-- Import ONLY a few rows first
-- After table is successfully created,
-- cancel/finish the wizard.
-- (STEP 2 — REMOVE TEMPORARY ROWS)
TRUNCATE TABLE black_friday_sales;
-- (STEP 3 — IMPORT FULL CSV USING LOAD DATA)
SET GLOBAL local_infile = 1;
LOAD DATA LOCAL INFILE 'path/to/retail_black_friday_sales_100k.csv'
INTO TABLE retail_black_friday_sales_100k
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- 2. DATA UNDERSTANDING
-- Preview Dataset
SELECT *
FROM retail_black_friday_sales_100k
LIMIT 5;
-- Total Rows
SELECT COUNT(*) AS total_rows
FROM retail_black_friday_sales_100k;
-- Check Data Types
DESCRIBE retail_black_friday_sales_100k;

-- 3. DATA CLEANING
-- FIX DATA TYPE
ALTER TABLE retail_black_friday_sales_100k
MODIFY purchase_date DATE;
-- CHECK MISSING VALUES
SELECT
    SUM(
        (transaction_id IS NULL)
        + (customer_id IS NULL)
        + (age_group IS NULL)
        + (gender IS NULL)
        + (city IS NULL)
        + (customer_segment IS NULL)
        + (product_id IS NULL)
        + (product_category IS NULL)
        + (original_price IS NULL)
        + (discount_pct IS NULL)
        + (final_price IS NULL)
        + (quantity IS NULL)
        + (purchase_amount IS NULL)
        + (payment_method IS NULL)
        + (purchase_date IS NULL)
        + (purchase_hour IS NULL)
        + (is_weekend IS NULL)
        + (is_black_friday IS NULL)
    ) AS total_missing_values
FROM retail_black_friday_sales_100k;
-- CHECK DUPLICATES
SELECT COUNT(*) AS total_duplicate_rows
FROM (
    SELECT
        COUNT(*) OVER (
            PARTITION BY transaction_id
        ) AS duplicate_count
    FROM retail_black_friday_sales_100k
) AS duplicate_check
WHERE duplicate_count > 1;

-- 4. EXPLORATORY DATA ANALYSIS (EDA)
-- Which product categories and customer segments drive the highest revenue during black friday?
SELECT
  product_category,
  customer_segment,
  SUM(purchase_amount) AS total_revenue
FROM retail_black_friday_sales_100k
WHERE is_black_friday = TRUE
GROUP BY product_category, customer_segment
ORDER BY total_revenue DESC
LIMIT 5;
-- Which product categories contribute most to total revenue druing black friday?
SELECT
  product_category,
  SUM(purchase_amount) AS total_revenue,
  CASE 
    WHEN SUM(purchase_amount) = 0 THEN NULL
    ELSE ROUND(
		SUM(purchase_amount) / SUM(SUM(purchase_amount)) OVER () * 100, 2)
  END AS revenue_share
FROM retail_black_friday_sales_100k
WHERE is_black_friday = TRUE
GROUP BY product_category
ORDER BY total_revenue DESC;
-- What is the relationship between discount levels and customer spending behavior during Black Friday?
SELECT
  discount_pct,
  AVG(purchase_amount) AS avg_spending,
  SUM(purchase_amount) AS total_revenue,
  SUM(quantity) AS total_quantity
FROM retail_black_friday_sales_100k
WHERE is_black_friday = TRUE
GROUP BY discount_pct
ORDER BY discount_pct;
-- Which customer segments are the most valuable during black friday?
SELECT
  customer_segment,
  SUM(purchase_amount) AS total_revenue,
  AVG(purchase_amount) AS avg_spending,
  RANK() OVER (ORDER BY SUM(purchase_amount) DESC) AS segment_rank
FROM retail_black_friday_sales_100k
WHERE is_black_friday = TRUE
GROUP BY customer_segment;
-- When do customers spend the most during Black Friday?
SELECT
  purchase_hour,
  COUNT(transaction_id) AS total_transactions,
  SUM(purchase_amount) AS total_revenue
FROM retail_black_friday_sales_100k
WHERE is_black_friday = TRUE
GROUP BY purchase_hour
ORDER BY total_revenue DESC
LIMIT 5;
SELECT * FROM retail_black_friday_sales_100k;