/* ============================================================================
   📊 SQL ANALYTICS PROJECT: E-COMMERCE SALES PERFORMANCE
   ============================================================================

   🎯 PURPOSE:
   A comprehensive analytical view of sales, customer, and product performance 
   using advanced SQL techniques such as Window Functions, CTEs, CASE statements, 
   Joins, and data cleansing.

   🧾 DATASETS USED:
   - gold.fact_sales (f): transactional data (sales, quantity, price, dates)
   - gold.dim_customers (c): customer demographic data
   - gold.dim_products (p): product and category data

   ⚙️ PLATFORM:
   Designed for MySQL (functions used: DATE_FORMAT, TIMESTAMPDIFF, DATEDIFF, STR_TO_DATE)

   📚 TABLE OF CONTENTS:
   1️. Monthly Sales & Customer Metrics
   2️. Monthly Sales by Month Start Date
   3️. Monthly Sales Running Total & Moving Average Price
   4️. Yearly Performance per Product
   5️. Category Sales Contribution
   6️. Product Cost Segmentation
   7️. Customer Spending & Segmentation
   8️. Customer Orders & Age Analysis
   9️. Customer Summary Metrics
   10. Null Data Check
   11. Top 10 Products by Sales
   12. Month-Over-Month Sales Analysis
============================================================================ */

/* ============================================================================
   1️. MONTHLY SALES & CUSTOMER METRICS
============================================================================ */
SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

/* ============================================================================
   2️. MONTHLY SALES BY MONTH START DATE
============================================================================ */
SELECT
    DATE_FORMAT(order_date, '%Y-%m-01') AS order_month_start,
    SUM(sales_amount) AS total_sales,
    COUNT(DISTINCT customer_key) AS total_customers,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
ORDER BY order_month_start;

/* ============================================================================
   3️. MONTHLY SALES RUNNING TOTAL & MOVING AVERAGE PRICE
============================================================================ */
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m-01') AS order_date,
        SUM(sales_amount) AS total_sales,
        AVG(price) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
)
SELECT
    order_date,
    total_sales,
    SUM(total_sales) OVER (ORDER BY order_date) AS running_total,
    ROUND(AVG(avg_price) OVER (
        ORDER BY order_date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 0) AS moving_avg_price
FROM monthly_sales
ORDER BY order_date;

/* ============================================================================
   4️. YEARLY PERFORMANCE PER PRODUCT
============================================================================ */
WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
      AND p.product_name IS NOT NULL
    GROUP BY YEAR(f.order_date), p.product_name
),
sales_with_lag AS (
    SELECT
        order_year,
        product_name,
        current_sales,
        LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales
    FROM yearly_product_sales
)
SELECT
    order_year,
    product_name,
    current_sales,
    ROUND(AVG(current_sales) OVER (PARTITION BY product_name), 0) AS avg_sales,
    CASE 
        WHEN current_sales > AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Above Avg'
        WHEN current_sales < AVG(current_sales) OVER (PARTITION BY product_name) THEN 'Below Avg'
        ELSE 'Equal to Avg'
    END AS avg_change,
    prev_year_sales,
    current_sales - prev_year_sales AS yoy_diff,
    CASE 
        WHEN prev_year_sales IS NULL THEN NULL
        WHEN current_sales > prev_year_sales THEN 'Increase'
        WHEN current_sales < prev_year_sales THEN 'Decrease'
        ELSE 'No Change'
    END AS yoy_change
FROM sales_with_lag
ORDER BY product_name, order_year;

/* ============================================================================
   5️. CATEGORY SALES CONTRIBUTION
============================================================================ */
WITH category_sales AS (
    SELECT
        p.category AS category_name,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p ON f.product_key = p.product_key
    WHERE f.sales_amount IS NOT NULL
      AND p.category IS NOT NULL
    GROUP BY p.category
)
SELECT
    category_name,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND(total_sales / SUM(total_sales) OVER () * 100, 2) AS pct_of_total
FROM category_sales
ORDER BY total_sales DESC;

/* ============================================================================
   6️. PRODUCT COST SEGMENTATION
============================================================================ */
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 499.99 THEN '100-499'
            WHEN cost BETWEEN 500 AND 999.99 THEN '500-999'
            ELSE '1000 and above'
        END AS cost_range
    FROM gold.dim_products
    WHERE cost IS NOT NULL
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/* ============================================================================
   7️. CUSTOMER SPENDING & SEGMENTATION
============================================================================ */
WITH customer_spending AS (
    SELECT
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(f.order_date) AS first_order,
        MAX(f.order_date) AS last_order,
        TIMESTAMPDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan_months,
        COUNT(f.order_date) AS total_orders
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON f.customer_key = c.customer_key
    WHERE f.sales_amount IS NOT NULL
      AND c.customer_key IS NOT NULL
    GROUP BY c.customer_key
)
SELECT
    customer_key,
    total_spending,
    lifespan_months AS lifespan,
    total_orders,
    CASE
        WHEN lifespan_months >= 12 AND total_spending > 5000 THEN 'High Regular'
        WHEN lifespan_months >= 12 AND total_spending <= 5000 THEN 'Low Regular'
        ELSE 'New'
    END AS customer_segment
FROM customer_spending
ORDER BY customer_segment, total_spending DESC;

/* ============================================================================
   8️. CUSTOMER ORDERS & AGE ANALYSIS
============================================================================ */
WITH base_query AS (
    SELECT
        f.order_number,
        f.product_key,
        DATE(f.order_date) AS order_date,
        CAST(f.sales_amount AS DECIMAL(10,2)) AS sales_amount,
        CAST(f.quantity AS UNSIGNED) AS quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.birthdate,
        CASE
            WHEN c.birthdate LIKE '%/%' THEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(c.birthdate, '%c/%e/%Y'), CURDATE())
            WHEN c.birthdate REGEXP '^[0-9]+$' AND CAST(c.birthdate AS UNSIGNED) BETWEEN 5 AND 120
                THEN CAST(c.birthdate AS UNSIGNED)
            ELSE NULL
        END AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
      AND c.customer_key IS NOT NULL
)
SELECT *
FROM base_query
LIMIT 500;

/* ============================================================================
   9️⃣ CUSTOMER SUMMARY METRICS
============================================================================ */
WITH base_data AS (
    SELECT
        f.order_number,
        f.product_key,
        DATE(f.order_date) AS order_date,
        CAST(f.sales_amount AS DECIMAL(10,2)) AS sales_amount,
        CAST(f.quantity AS UNSIGNED) AS quantity,
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        c.birthdate,
        CASE
            WHEN c.birthdate LIKE '%/%' THEN TIMESTAMPDIFF(YEAR, STR_TO_DATE(c.birthdate, '%c/%e/%Y'), CURDATE())
            WHEN c.birthdate REGEXP '^[0-9]+$' AND CAST(c.birthdate AS UNSIGNED) BETWEEN 5 AND 120
                THEN CAST(c.birthdate AS UNSIGNED)
            ELSE NULL
        END AS age
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_customers c ON c.customer_key = f.customer_key
    WHERE f.order_date IS NOT NULL
      AND c.customer_key IS NOT NULL
)
SELECT
    customer_key,
    customer_number,
    customer_name,
    age,
    COUNT(DISTINCT order_number) AS total_orders,
    SUM(sales_amount) AS total_sales,
    SUM(quantity) AS total_quantity,
    COUNT(DISTINCT product_key) AS total_products,
    MAX(order_date) AS last_order_date,
    TIMESTAMPDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM base_data
GROUP BY customer_key, customer_number, customer_name, age
LIMIT 500;

/* ============================================================================
   10️⃣ NULL DATA CHECK
============================================================================ */
SELECT COUNT(*) AS null_orders
FROM gold.fact_sales
WHERE order_date IS NULL OR sales_amount IS NULL;

/* ============================================================================
   11️⃣ TOP 10 PRODUCTS BY SALES
============================================================================ */
SELECT
    p.product_name,
    SUM(f.sales_amount) AS total_sales
FROM gold.fact_sales f
JOIN gold.dim_products p USING (product_key)
GROUP BY p.product_name
ORDER BY total_sales DESC
LIMIT 10;

/* ============================================================================
   12️⃣ MONTH-OVER-MONTH SALES ANALYSIS
============================================================================ */
WITH monthly_sales AS (
    SELECT
        DATE_FORMAT(order_date, '%Y-%m-01') AS order_month_start,
        SUM(sales_amount) AS total_sales
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATE_FORMAT(order_date, '%Y-%m-01')
),
monthly_diff AS (
    SELECT
        order_month_start,
        total_sales,
        total_sales - LAG(total_sales) OVER (ORDER BY order_month_start) AS MoM_diff,
        ROUND(
            (total_sales - LAG(total_sales) OVER (ORDER BY order_month_start))
            / LAG(total_sales) OVER (ORDER BY order_month_start) * 100, 2
        ) AS MoM_pct
    FROM monthly_sales
)
SELECT *
FROM monthly_diff
WHERE MoM_diff IS NOT NULL
ORDER BY order_month_start;
