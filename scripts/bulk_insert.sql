
-- ======================================
-- BULK INSERT INTO TABLES
-- ======================================

-- Load into dim_city
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_city.csv'
INTO TABLE dim_city
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(city_id, city, state, tier);
SHOW WARNINGS;


-- Load into dim_ad_category
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/dim_ad_category.csv'
INTO TABLE dim_ad_category
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(ad_category_id, standard_ad_category, category_group, example_brands);
SHOW WARNINGS;



-- Load into fact_ad_revenue
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_ad_revenue.csv'
INTO TABLE fact_ad_revenue
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(edition_id, ad_category, quarter, ad_revenue, currency, comments);
SHOW WARNINGS;

-- Load into fact_digital_pilot
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_digital_pilot.csv'
INTO TABLE fact_digital_pilot
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(row_id, platform, launch_month, ad_category_id, dev_cost, marketing_cost, users_reached, downloads_or_accesses, avg_bounce_rate, cumulative_feedback_from_customers, city_id)
SET row_id = NULL;
SHOW WARNINGS;


-- Load into fact_print_sales
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_print_sales.csv'
INTO TABLE fact_print_sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(edition_id, city_id, print_language, state, month, copies_sold, copies_returned, net_circulation);
SHOW WARNINGS;


-- Load into fact_city_readiness
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/fact_city_readiness.csv'
INTO TABLE fact_city_readiness
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(row_id, city_id, quarter, literacy_rate, smartphone_penetration, internet_penetration)
SET row_id = NULL;
SHOW WARNINGS;
