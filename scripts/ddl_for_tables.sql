
-- ======================================
-- CREATE TABLES
-- ======================================

-- Create dim_city
DROP TABLE IF EXISTS dim_cty;
CREATE TABLE dim_city (
	city_id VARCHAR(50) PRIMARY KEY NOT NULL,
    city VARCHAR(50),
    state VARCHAR(50),
    tier VARCHAR(100)
);


-- Create dim_ad_category
DROP TABLE IF EXISTS dim_ad_category;
CREATE TABLE dim_ad_category (
	ad_category_id VARCHAR(50),
    standard_ad_category VARCHAR(100),
    category_group VARCHAR(100),
    example_brands VARCHAR(500)
);


-- Create fact_print_sales
DROP TABLE IF EXISTS fact_print_sales;
CREATE TABLE fact_print_sales (
	edition_id VARCHAR(500),
    city_id VARCHAR(50),
    print_language VARCHAR(100),
    state VARCHAR(100),
    month VARCHAR(25),
    copies_sold VARCHAR(100),
    copies_returned INT,
    net_circulation INT
);

-- Create fact_ad_revenue
DROP TABLE IF EXISTS fact_ad_revenue;
CREATE TABLE fact_ad_revenue (
	edition_id VARCHAR(50),
    ad_category VARCHAR(100),
    quarter VARCHAR(50),
    ad_revenue DECIMAL(10,2),
    currency VARCHAR(50),
    comments VARCHAR(500)
);

-- Create fact_digital_pilot
DROP TABLE IF EXISTS fact_digital_pilot;
CREATE TABLE fact_digital_pilot (
	row_id INT AUTO_INCREMENT PRIMARY KEY,
    platform VARCHAR(100),
    launch_month VARCHAR(25),
    ad_category_id VARCHAR(50),
    dev_cost INT,
    marketing_cost INT,
    users_reached INT,
    downloads_or_accesses INT,
    avg_bounce_rate FLOAT,
    cumulative_feedback_from_customers TEXT,
    city_id VARCHAR(50)
);

-- Create fact_digital_readiness
DROP TABLE IF EXISTS fact_city_readiness;
CREATE TABLE fact_city_readiness (
	row_id INT AUTO_INCREMENT PRIMARY KEY,
    city_id VARCHAR(50),
    quarter VARCHAR(50),
    literacy_rate FLOAT,
    smartphone_penetration FLOAT,
    internet_penetration FLOAT
);
