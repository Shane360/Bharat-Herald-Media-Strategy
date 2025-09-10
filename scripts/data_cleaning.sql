
-- ========================
-- DATA CLEANING
-- ========================
-- A. Clean dim_city
-- Check for unwanted spaces
SELECT * 
FROM dim_city
WHERE city <> TRIM(city);
-- Result: No Issues: no duplicates, unwanted spaces, weird characters


-- B. Clean dim_ad_category
SELECT * 
FROM dim_ad_category;

SELECT *
FROM dim_ad_category
WHERE category_group <> TRIM(category_group);
-- Result: No duplicates, unwanted spaces, weird characters


-- C. Clean fact_ad_revenue
SELECT *
FROM fact_ad_revenue
WHERE quarter LIKE '%Qtr %';

-- i. unwanted spaces
SELECT * 
FROM fact_ad_revenue
WHERE comments <> TRIM(comments);
-- Result: No Unwanted spaces


-- ii. Check the ad_category column for impossible values
-- Values not in the dim_ad_category
SELECT
	ad_category
FROM fact_ad_revenue
WHERE ad_category NOT IN (SELECT ad_category_id FROM dim_ad_category);
-- Result: No impossible or weird values


-- iii.  Standardize the 'quarter' column
SELECT 
	edition_id,
    ad_category,
    quarter,
    CASE
		WHEN quarter LIKE '%Qtr %' THEN 
			CONCAT('Q', 
				CASE
					WHEN quarter LIKE '1st%' THEN '1'
          WHEN quarter LIKE '2nd%' THEN '2'
          WHEN quarter LIKE '3rd%' THEN '3'
          WHEN quarter LIKE '4th%' THEN '4'
        END,    
				'-', RIGHT(quarter, 4)) 
        WHEN quarter LIKE '____-Q_' THEN CONCAT(RIGHT(quarter, 2), '-', LEFT(quarter, 4))
        ELSE quarter
	END AS quarter_clean,
    ad_revenue,
    currency,
    comments
FROM fact_ad_revenue;


-- iii(b) Update the table
UPDATE fact_ad_revenue
SET quarter =
CASE 
	WHEN quarter LIKE '%Qtr %' THEN
    CONCAT('Q',
		CASE
			WHEN quarter LIKE '1st%' THEN '1'
      WHEN quarter LIKE '2nd%' THEN '2'
      WHEN quarter LIKE '3rd%' THEN '3'
      WHEN quarter LIKE '4th%' THEN '4'
		END,
        '-', RIGHT(quarter, 4))
	WHEN quarter LIKE '____-Q_' THEN CONCAT(RIGHT(quarter, 2), '-', LEFT(quarter, 4))
	ELSE quarter
END
WHERE quarter LIKE '%Qtr %' OR quarter LIKE '____-Q_';
;
-- Check transaction 
SELECT * 
FROM fact_ad_revenue;
-- Result: quarter column has been standardized


-- iv. Check for weird characters in ad_revenue
SELECT 
	edition_id,
  ad_revenue
FROM fact_ad_revenue
WHERE ad_revenue REGEXP '[^0-9.-]';
-- Result: No weird charcters in the column


-- v. Standardize ad_revenue (convert USD, EUR and other currencies to INR)
-- Check currencies
SELECT
	edition_id,
  ad_revenue,
  currency
FROM fact_ad_revenue
WHERE currency <> 'INR';

-- Other Currencies are EUR and USD
-- 1 EUR = 103.37 INR
-- 1 USD = 88.18 INR
-- Add column to accommodate converted figures in Indian Rupees (INR)

ALTER TABLE fact_ad_revenue
ADD ad_revenue_inr DECIMAL(40,2);

-- Re-order the columns
ALTER TABLE fact_ad_revenue
MODIFY ad_revenue_inr DECIMAL(40,2) AFTER currency;

SELECT * FROM fact_ad_revenue;

-- Update ad_revenue column
UPDATE fact_ad_revenue
SET ad_revenue_inr = 
    CASE 
		WHEN currency LIKE '%EUR%' THEN (ad_revenue * 103.37)
    WHEN currency LIKE '%USD%' THEN (ad_revenue * 88.18)
    WHEN currency LIKE '%IN%' THEN ad_revenue
	END
WHERE currency LIKE '%EUR%' 
OR currency LIKE '%USD%' 
OR currency LIKE '%IN%';

-- Check
SELECT * 
FROM fact_ad_revenue;

-- vi. Standardize the currency column
SELECT 
	edition_id,
  ad_category,
  quarter,
  ad_revenue,
  currency,
  CASE 
		WHEN currency LIKE '%EUR%' THEN 'EUR'
    WHEN currency LIKE '%USD%' THEN 'USD'
    WHEN currency LIKE '%IN%' THEN 'INR'
    ELSE TRIM(currency)
	END AS currency_clean,
    ad_revenue_inr,
    comments
FROM fact_ad_revenue;

-- Update the currency column
UPDATE fact_ad_revenue
SET currency = 
    CASE 
		WHEN currency LIKE '%EUR%' THEN 'EUR'
    WHEN currency LIKE '%USD%' THEN 'USD'
    WHEN currency LIKE '%IN%' THEN 'INR'
    ELSE TRIM(currency)
	END
WHERE currency LIKE '%EUR%'
OR currency LIKE '%USD%'
OR currency LIKE '%IN%'
;

-- D. Clean fact_city_readiness
SELECT * FROM fact_city_readiness;

-- i. Check for unwanted spaces
SELECT
	row_id,
  city_id,
  quarter,
  literacy_rate,
  smartphone_penetration,
  internet_penetration
FROM fact_city_readiness
WHERE literacy_rate != TRIM(literacy_rate); 
-- Issues: literacy_rate has unwanted spaces in 227 rows

SELECT
	row_id,
    city_id,
    quarter,
    literacy_rate,
    smartphone_penetration,
    internet_penetration
FROM fact_city_readiness
WHERE smartphone_penetration != TRIM(smartphone_penetration); 
-- Issues: smartphone_penetration has unwanted spaces in 229 rows

SELECT
	row_id,
    city_id,
    quarter,
    literacy_rate,
    smartphone_penetration,
    internet_penetration
FROM fact_city_readiness
WHERE internet_penetration != TRIM(internet_penetration); 
-- Issues: internet_penetration has unwanted spaces in 209 rows

-- i(b) Fix unwanted spaces
SELECT
	row_id,
    city_id,
    quarter,
    TRIM(literacy_rate) AS literacy_rate,
    TRIM(smartphone_penetration) AS smartphone_penetration,
    TRIM(internet_penetration) AS internet_penetration
FROM fact_city_readiness; 

UPDATE fact_city_readiness
SET literacy_rate = TRIM(literacy_rate);

UPDATE fact_city_readiness
SET smartphone_penetration = TRIM(smartphone_penetration);

UPDATE fact_city_readiness
SET internet_penetration = TRIM(internet_penetration);

SELECT * 
FROM fact_city_readiness
WHERE internet_penetration != TRIM(internet_penetration);

-- i(c). Check connection to the PK dim_cty
SELECT
	city_id
FROM fact_city_readiness
WHERE city_id NOT IN (SELECT city_id FROM dim_city);
-- Results: no connection issues


-- ii. Standardize the quarter column (Q#-YYYY)
SELECT 
	city_id,
    CASE
		WHEN quarter LIKE '____-Q_' THEN CONCAT(RIGHT(quarter, 2), '-', LEFT(quarter, 4))
        ELSE quarter
	END AS quarter
FROM fact_city_readiness;

-- Update the quarter column
UPDATE fact_city_readiness
SET quarter =
    CASE
		WHEN quarter LIKE '____-Q_' THEN CONCAT(RIGHT(quarter, 2), '-', LEFT(quarter, 4))
        ELSE quarter
	END
WHERE quarter LIKE '____-Q_';

SELECT * 
FROM fact_city_readiness;


-- E. Clean fact_digital_pilot
SELECT *
FROM fact_digital_pilot;

-- i. Check for unwanted spaces
SELECT
	city_id
FROM fact_digital_pilot
WHERE city_id <> TRIM(city_id);
-- Results: No unwanted spaces in the fields

-- ii. Check for weird characters
SELECT 
	ad_category_id,
    dev_cost,
    marketing_cost,
    users_reached,
    downloads_or_accesses,
    avg_bounce_rate
FROM fact_digital_pilot
WHERE dev_cost REGEXP '[^0-9.-]'
OR marketing_cost REGEXP '[^0-9.-]'
OR users_reached REGEXP '[^0-9.-]'
OR downloads_or_accesses REGEXP '[^0-9.-]'
OR avg_bounce_rate REGEXP '[^0-9.-]';
-- Results: no weird character

-- iii. Check the connection between city_id and dim_city
SELECT city_id
FROM fact_digital_pilot
WHERE city_id NOT IN (SELECT city_id FROM dim_city);

SELECT *
FROM dim_city;
-- Results: the records do not match. Need to investigate further

-- iii(b). Check for extra hidden characters using HEX(colName)
SELECT 
	city_id, HEX(city_id)
FROM fact_digital_pilot
WHERE city_id LIKE '%\r%'
OR  city_id LIKE '%\n%' 
OR city_id LIKE '%\t%';
-- Result: all the rows in the FK, i.e., fact_digital_pilot(city_id)

-- iii(c). Fix relationship issues
UPDATE fact_digital_pilot
SET city_id = TRIM(REPLACE(REPLACE(REPLACE(city_id, '\r', ''), '\n', ''), '\t', ''));

-- Confirm transaction
SELECT city_id
FROM fact_digital_pilot
WHERE city_id NOT IN (SELECT city_id FROM dim_city);


-- F. Clean fact_print_sales
SELECT * 
FROM fact_print_sales;

-- i. Check for unwanted spaces
SELECT net_circulation
FROM fact_print_sales
WHERE net_circulation <> TRIM(net_circulation);
-- Results: No unwanted spaces


-- ii. Check the connection with the dim_city
SELECT city_id
FROM fact_print_sales 
WHERE city_id NOT IN (SELECT city_id FROM dim_city);
-- Results: no connection issues


-- iii. Remove underscores (_) and hyphens (-) from the state column
SELECT DISTINCT
	state,
    CASE
		WHEN state LIKE 'Uttar-Pradesh' THEN 'Uttar Pradesh'
    WHEN state LIKE 'Madhya_Pradesh' THEN 'Madhya Pradesh'
    ELSE TRIM(state)
	END AS state_clean
FROM fact_print_sales;

-- iii(b). Update the column accordingly
UPDATE fact_print_sales
SET state = 
    CASE
		WHEN state LIKE 'Uttar-Pradesh' THEN 'Uttar Pradesh'
    WHEN state LIKE 'Madhya_Pradesh' THEN 'Madhya Pradesh'
    ELSE TRIM(state)
	END
WHERE state LIKE 'Uttar-Pradesh' OR state LIKE 'Madhya_Pradesh';

-- Check
SELECT DISTINCT state
FROM fact_print_sales;
-- Results: No more unnecessary hyphens and underscores in the column

-- iv. Standardize the month column
-- Check the formats
SELECT 
	month,
    CASE 
  		WHEN month REGEXP '[0-9]{2}-[A-Za-z]{3}$' THEN 'YY-MMM'
      WHEN month REGEXP '[0-9]{4}/[0-9]{2}$' THEN 'YYYY/MM'
		  ELSE 'Unkown format'
    END AS pattern_match,
    COUNT(*)
FROM fact_print_sales
GROUP BY  month, pattern_match
ORDER BY COUNT(*) DESC;


-- Proper Fix
SELECT DISTINCT
	month,
    CASE
		WHEN month LIKE '__-___' THEN CONCAT('20', LEFT(month, 2), '-', 
        CASE 
			      WHEN RIGHT(month, 3) LIKE '%Jan%' THEN '01'
            WHEN RIGHT(month, 3) LIKE '%Feb%' THEN '02'
            WHEN RIGHT(month, 3) LIKE '%Mar%' THEN '03'
            WHEN RIGHT(month, 3) LIKE '%Apr%' THEN '04'
            WHEN RIGHT(month, 3) LIKE '%May%' THEN '05'
            WHEN RIGHT(month, 3) LIKE '%Jun%' THEN '06'
            WHEN RIGHT(month, 3) LIKE '%Jul%' THEN '07'
            WHEN RIGHT(month, 3) LIKE '%Aug%' THEN '08'
            WHEN RIGHT(month, 3) LIKE '%Sep%' THEN '09'
            WHEN RIGHT(month, 3) LIKE '%Oct%' THEN '10'
            WHEN RIGHT(month, 3) LIKE '%Nov%' THEN '11'
            WHEN RIGHT(month, 3) LIKE '%Dec%' THEN '12'
            ELSE month
		    END)
    WHEN month LIKE '____/__' THEN REPLACE(month, '/', '-')
    ELSE month
	END AS month_clean
FROM fact_print_sales;

-- Update the month column
UPDATE fact_print_sales
SET month = 
CASE
	WHEN month LIKE '__-___' THEN CONCAT('20', LEFT(month, 2), '-', 
	CASE 
		WHEN RIGHT(TRIM(month), 3) LIKE '%Jan%' THEN '01'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Feb%' THEN '02'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Mar%' THEN '03'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Apr%' THEN '04'
		WHEN RIGHT(TRIM(month), 3) LIKE '%May%' THEN '05'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Jun%' THEN '06'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Jul%' THEN '07'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Aug%' THEN '08'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Sep%' THEN '09'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Oct%' THEN '10'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Nov%' THEN '11'
		WHEN RIGHT(TRIM(month), 3) LIKE '%Dec%' THEN '12'
		ELSE month
	END)
	WHEN month LIKE '____/__' THEN REPLACE(month, '/', '-')
	ELSE month
END 
WHERE month LIKE '__-___' OR month LIKE '____/__';

-- Check 
SELECT * FROM fact_print_sales;
-- Results: month column Standardized properly 


-- v. Remove weird characters from copies_sold column
SELECT
	edition_id, city_id, print_language, state, month, copies_sold, copies_returned, 
    net_circulation, 
	SUBSTRING(copies_sold, 2) as copies_sold_new
FROM fact_print_sales
WHERE copies_sold REGEXP '[^0-9.-]'
OR copies_returned REGEXP '[^0-9.-]'
OR net_circulation REGEXP '[^0-9.-]';
-- 66 rows have the INR official currency symbol

-- Update the copies_sold column
UPDATE fact_print_sales
SET copies_sold = SUBSTRING(copies_sold, 2)
WHERE copies_sold REGEXP '[^0-9.-]'
OR copies_returned REGEXP '[^0-9.-]'
OR net_circulation REGEXP '[^0-9.-]';

-- Check 
SELECT * FROM fact_print_sales;
-- Results: No more weird characters


-- vi. Validate the net_circulation column
SELECT * 
FROM fact_print_sales
WHERE net_circulation <> (copies_sold - copies_returned);
-- Results: the net_circulation was well calculated and recorded
