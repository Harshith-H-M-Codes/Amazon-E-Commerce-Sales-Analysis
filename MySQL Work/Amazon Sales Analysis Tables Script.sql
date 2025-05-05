CREATE DATABASE IF NOT EXISTS Amazon_Sales_Analysis;
USE Amazon_Sales_Analysis;

-- Amazon_Sales Table
CREATE TABLE Amazon_Sales (
product_id VARCHAR(255) PRIMARY KEY,
product_name VARCHAR(1000),
Category VARCHAR(1000),
Sub_Category VARCHAR(1000),
`Type` VARCHAR(1000),
Sub_Type VARCHAR(1000),
Specific_Product VARCHAR(1000),
discounted_price DOUBLE,
actual_price DOUBLE,
discount_percentage FLOAT,
rating FLOAT,
rating_count INT,
about_product VARCHAR(1000),
user_id VARCHAR(1000),
user_name VARCHAR(1000),
review_id VARCHAR(1000),
review_title VARCHAR(1000),
review_content VARCHAR(1000),
img_link VARCHAR(1000),
product_link VARCHAR(1000)
);

describe Amazon_Sales;

-- Load Data into Amazon_Sales:
LOAD DATA INFILE 'cleaned_amazon_data.csv'
INTO TABLE Amazon_Sales
FIELDS TERMINATED BY ','  
OPTIONALLY ENCLOSED BY '"'  
IGNORE 1 LINES  
(product_id, @product_name, @Category, @Sub_Category, @`Type`, @Sub_Type, @Specific_Product,  
 @discounted_price, @actual_price, @discount_percentage, @rating, @rating_count, @about_product,  
 @user_id, @user_name, @review_id, @review_title, @review_content, @img_link, @product_link)
SET 
    product_name = NULLIF(@product_name, ''),
    Category = NULLIF(@Category, ''),
    Sub_Category = NULLIF(@Sub_Category, ''),
    `Type` = NULLIF(@`Type`, ''),
    Sub_Type = NULLIF(@Sub_Type, ''),
    Specific_Product = NULLIF(@Specific_Product, ''),
    discounted_price = NULLIF(@discounted_price, ''),
    actual_price = NULLIF(@actual_price, ''),
    discount_percentage = NULLIF(@discount_percentage, ''),
    rating = NULLIF(@rating, ''),
    rating_count = NULLIF(@rating_count, ''),
    about_product = NULLIF(@about_product, ''),
    user_id = NULLIF(@user_id, ''),
    user_name = NULLIF(@user_name, ''),
    review_id = NULLIF(@review_id, ''),
    review_title = NULLIF(@review_title, ''),
    review_content = NULLIF(@review_content, ''),
    img_link = NULLIF(@img_link, ''),
    product_link = NULLIF(@product_link, '');
