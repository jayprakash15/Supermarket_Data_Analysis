-- SQL Queries for Data Analysis for supermarket
-- drop database dbo;

CREATE DATABASE dbo;
use dbo;
-- load data by csv file
-- SHOW SESSION VARIABLES LIKE 'lower_case_table_names'
-- SHOW DATABASES
-- SHOW SESSION VARIABLES LIKE 'lower_case_table_names'
-- SHOW TABLES FROM `dbo` like 'groceries_dataset'
-- CREATE TABLE `dbo`.`groceries_dataset` (`Member_number` int, `Date` text, `itemDescription` text)
-- PREPARE stmt FROM 'INSERT INTO `dbo`.`groceries_dataset` (`Member_number`,`Date`,`itemDescription`) VALUES(?,?,?)';
-- DEALLOCATE PREPARE stmt

-- change name of Date column to purchase_date and change itemDescription into item_description
ALTER TABLE `dbo`.`groceries_dataset` 
CHANGE COLUMN `Date` `purchase_date` TEXT NULL DEFAULT NULL ,
CHANGE COLUMN `itemDescription` `item_description` TEXT NULL DEFAULT NULL ;

-- Preview the table
SELECT * FROM dbo.Groceries_dataset;

-- Check for Null values in Column 1
SELECT member_number FROM dbo.Groceries_dataset WHERE member_number IS NULL;

-- Check for Null values in Column 2
SELECT purchase_date FROM dbo.Groceries_dataset WHERE purchase_date IS NULL;

-- Check for Null values in Column 3
SELECT item_description FROM dbo.Groceries_dataset WHERE item_description IS NULL;

-- Create a new column in the table new_purchase_date
ALTER TABLE dbo.Groceries_dataset ADD new_purchase_date DATE;

-- Create a new column for the purchase date cast as a DATE data type
-- 103 specifies YYYY-MM-DD
-- UPDATE dbo.Groceries_dataset SET new_purchase_date = CONVERT(DATE, purchase_date, 103);

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Create a new column for the purchase date cast as a DATE data type
-- Assuming 'purchase_date' is in a string format like 'DD-MM-YYYY'
UPDATE Groceries_dataset SET new_purchase_date = STR_TO_DATE(purchase_date, '%d-%m-%Y');
-- This query need to be performed in safe mode

-- Re-enable safe update mode (optional, but recommended for safety)
SET SQL_SAFE_UPDATES = 1;

select * from dbo.Groceries_dataset;

-- Count distinct member numbers.
SELECT COUNT( DISTINCT member_number) FROM dbo.Groceries_dataset;

-- Count distinct items
SELECT COUNT( DISTINCT item_description) FROM dbo.Groceries_dataset;

-- Find earliest and latest dates in dataset
SELECT MAX(new_purchase_date) FROM dbo.Groceries_dataset;
SELECT MIN(new_purchase_date) FROM dbo.Groceries_dataset;

-- Find the most popular items sold
SELECT item_description, COUNT(item_description) FROM dbo.Groceries_dataset 
GROUP BY item_description ORDER BY COUNT(item_description) DESC;

-- Create a new column in the table for YEAR, MONTH, DAY, and DAY OF THE WEEK
ALTER TABLE dbo.Groceries_dataset ADD purchase_year INT;
ALTER TABLE dbo.Groceries_dataset ADD purchase_month INT;
ALTER TABLE dbo.Groceries_dataset ADD purchase_day INT;
ALTER TABLE dbo.Groceries_dataset ADD purchase_dow nvarchar(255);

-- Disable safe update mode
SET SQL_SAFE_UPDATES = 0;

-- Update new columns with date related data
UPDATE dbo.Groceries_dataset SET purchase_year = YEAR(new_purchase_date);
UPDATE dbo.Groceries_dataset SET purchase_month = MONTH(new_purchase_date);
UPDATE dbo.Groceries_dataset SET purchase_day = DAY(new_purchase_date);
-- UPDATE dbo.Groceries_dataset SET purchase_dow = DATENAME(weekday, new_purchase_date);
UPDATE dbo.Groceries_dataset SET purchase_dow = DAYNAME(new_purchase_date);

-- Re-enable safe update mode (optional, but recommended for safety)
SET SQL_SAFE_UPDATES = 1;

select * from dbo.Groceries_dataset;

-- Most popular products for 2014
SELECT item_description, count(item_description) FROM dbo.Groceries_dataset 
WHERE purchase_year=2014 GROUP BY item_description ORDER BY count(item_description) DESC;

-- Most popular products for 2015
SELECT item_description, count(item_description) FROM dbo.Groceries_dataset 
WHERE purchase_year=2015 GROUP BY item_description ORDER BY count(item_description) DESC;

-- Sales by Year
SELECT purchase_year, count(item_description) FROM dbo.Groceries_dataset 
GROUP BY purchase_year ORDER BY count(item_description) DESC;

 -- Practice writing GROUP BY and ORDER BY statements in different ways to compare outputs
SELECT item_description, count(item_description), purchase_month FROM dbo.Groceries_dataset 
GROUP BY item_description, purchase_month ORDER BY count(item_description) DESC;

 -- Sales By Month
 SELECT count(item_description), purchase_month FROM dbo.Groceries_dataset 
 GROUP BY purchase_month ORDER BY count(item_description) DESC;

 -- Sales By Month for all years
 SELECT purchase_month, count(item_description) FROM dbo.Groceries_dataset 
 GROUP BY purchase_month ORDER BY purchase_month ASC;

   -- Sales By Month for 2014
 SELECT purchase_month, count(item_description) FROM dbo.Groceries_dataset WHERE purchase_year=2014
 GROUP BY purchase_month ORDER BY count(item_description) DESC;

   -- Sales By Month for 2015
 SELECT purchase_month, count(item_description) FROM dbo.Groceries_dataset WHERE purchase_year=2015
 GROUP BY purchase_month ORDER BY count(item_description) DESC;

 -- Sales By purchase day for 2014
 SELECT purchase_day, count(item_description) FROM dbo.Groceries_dataset WHERE purchase_year=2014
 GROUP BY purchase_day ORDER BY count(item_description) DESC;

  -- Sales By purchase day for 2015
 SELECT purchase_day, count(item_description) FROM dbo.Groceries_dataset WHERE purchase_year=2015
 GROUP BY purchase_day ORDER BY count(item_description) DESC;

 -- Sales By purchase day of the week for 2014
 SELECT purchase_dow, count(item_description) FROM dbo.Groceries_dataset WHERE purchase_year=2014
 GROUP BY purchase_dow ORDER BY count(item_description) DESC;

-- Sales By purchase day of the week for 2015
 SELECT purchase_dow, count(item_description) FROM dbo.Groceries_dataset WHERE purchase_year=2015
 GROUP BY purchase_dow ORDER BY count(item_description) DESC;

-- My most unfavorite thing about this dataset is that there’s no price data included.
-- created a new table with 3 columns, an item_number as a UID, the item description of course, 
-- and used the RND() function to generate some random prices between 0 and $8.

create table ItemPrices(
	select distinct item_description from dbo.Groceries_dataset
    order by item_description
);

alter table dbo.ItemPrices
add item_number int,
add item_price decimal(4,2);

SET @row_number = 0;

SET SQL_SAFE_UPDATES = 0;
UPDATE ItemPrices
SET item_number = (@row_number := @row_number + 1),
item_price = ROUND(RAND() * 10, 2);

SET SQL_SAFE_UPDATES = 1;

select * from ItemPrices;

 -- Preview the second item price table
 SELECT item_number, item_description, cast(item_price as decimal(10,2)) FROM dbo.ItemPrices;

 -- JOIN groceries dataset table with item price table on item description
 create table GrocerySales(
  SELECT member_number, new_purchase_date,priceitem.item_description, item_number, 
  cast(item_price as decimal(10,2)) AS purchase_price,
  purchase_year, purchase_month, purchase_day, purchase_dow
  FROM dbo.ItemPrices priceitem
	LEFT JOIN dbo.Groceries_dataset groceryitem
	ON priceitem.item_description = groceryitem.item_description
	ORDER BY 1,2 -- ;
);

-- Create CTE for joined grocery and item price data
With GrocerySales (member_number, purchase_date, item_description, item_number, purchase_price, 
purchase_year, purchase_month, purchase_day, purchase_dow)
	AS
	  (SELECT member_number, new_purchase_date,priceitem.item_description, item_number, 
  cast(item_price as decimal(10,2)) AS purchase_price,
  purchase_year, purchase_month, purchase_day, purchase_dow
  FROM dbo.ItemPrices priceitem
	LEFT JOIN dbo.Groceries_dataset groceryitem
	ON priceitem.item_description = groceryitem.item_description)


	-- Sales by Year from CTE
SELECT purchase_year, SUM(purchase_price) FROM GrocerySales
 GROUP BY purchase_year;

 -- Sales by Day of the Week from CTE
SELECT purchase_dow, SUM(purchase_price) AS total_sales FROM GrocerySales
WHERE purchase_year = 2015
 GROUP BY purchase_dow
 ORDER BY 2 DESC;

