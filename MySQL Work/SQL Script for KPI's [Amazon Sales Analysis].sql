USE Amazon_Sales_Analysis;

-- 1. Analyze the relationship between actual price, discounted price.

CREATE TABLE Price_Analysis AS
WITH price_ranges AS (
    SELECT '₹0 - ₹5K' AS price_range, 0 AS min_price, 5000 AS max_price UNION ALL
    SELECT '₹5K - ₹10K', 5001, 10000 UNION ALL
    SELECT '₹10K - ₹20K', 10001, 20000 UNION ALL
    SELECT '₹20K - ₹50K', 20001, 50000 UNION ALL
    SELECT '₹50K+', 50001, 1000000
),
categories AS (
    SELECT DISTINCT Category FROM Amazon_Sales
),
all_combinations AS (
    SELECT 
        c.Category, 
        ap.price_range AS actual_price_range, ap.min_price AS ap_min, ap.max_price AS ap_max,
        dp.price_range AS discount_price_range, dp.min_price AS dp_min, dp.max_price AS dp_max
    FROM categories c
    CROSS JOIN price_ranges ap
    CROSS JOIN price_ranges dp
)
SELECT 
    ac.Category,
    ac.actual_price_range,
    ac.discount_price_range,
    COALESCE(COUNT(a.product_id), 0) AS product_count,
    SUM(COUNT(a.product_id)) OVER (PARTITION BY ac.Category) AS total_product_count
FROM all_combinations ac
LEFT JOIN Amazon_Sales a 
    ON ac.Category = a.Category 
    AND a.actual_price BETWEEN ac.ap_min AND ac.ap_max 
    AND a.discounted_price BETWEEN ac.dp_min AND ac.dp_max
GROUP BY ac.Category, ac.actual_price_range, ac.discount_price_range
ORDER BY ac.Category,ac.actual_price_range, ac.discount_price_range, product_count DESC;

SELECT * FROM Price_Analysis;

-- 2.Analyze discount percentage across different product categories.
CREATE TABLE Category_Discount_Share AS
SELECT 
    Category,
    ROUND(SUM(discount_percentage) * 100 / (SELECT SUM(discount_percentage) FROM Amazon_Sales), 2) AS discount_percentage_share
FROM Amazon_Sales
GROUP BY Category
ORDER BY discount_percentage_share DESC;

SELECT * FROM Category_Discount_Share;

-- 3.Categories offering best Savings.
CREATE TABLE Category_Savings AS
SELECT Category, 
       ROUND(AVG(actual_price - discounted_price), 2) AS avg_savings, 
       ROUND(SUM(actual_price - discounted_price), 2) AS total_savings
FROM Amazon_Sales
GROUP BY Category
ORDER BY avg_savings DESC;

SELECT * FROM Category_Savings;

-- 4.Investigate whether higher discount percentages correlate with better customer ratings.
-- Do products with steep discounts tend to receive higher ratings or more favorable reviews?

-- Here To analyze whether higher discounts correlate with better customer ratings, we’ll compute
-- the Pearson correlation coefficient between discount_percentage and rating for each category as well as for all categories combined.

CREATE TABLE Ratings_Discount_Correlation AS
WITH Stats AS (
    SELECT 
        Category,
        COUNT(*) AS n,
        SUM(discount_percentage) AS sum_x,
        SUM(rating) AS sum_y,
        SUM(discount_percentage * rating) AS sum_xy,
        SUM(discount_percentage * discount_percentage) AS sum_x2,
        SUM(rating * rating) AS sum_y2,
        AVG(discount_percentage) AS avg_discount_percentage,
        AVG(rating) AS avg_rating
    FROM Amazon_Sales
    GROUP BY Category
    
    UNION ALL
    
    SELECT 
        'All Categories Combined' AS Category,
        COUNT(*) AS n,
        SUM(discount_percentage) AS sum_x,
        SUM(rating) AS sum_y,
        SUM(discount_percentage * rating) AS sum_xy,
        SUM(discount_percentage * discount_percentage) AS sum_x2,
        SUM(rating * rating) AS sum_y2,
        AVG(discount_percentage) AS avg_discount_percentage,
        AVG(rating) AS avg_rating
    FROM Amazon_Sales
)
SELECT 
    Category,
    ROUND(avg_discount_percentage, 2) AS avg_discount_percentage,
    ROUND(avg_rating, 2) AS avg_rating,
    CASE 
        WHEN (n * sum_x2 - sum_x * sum_x) = 0 OR (n * sum_y2 - sum_y * sum_y) = 0 
        THEN NULL 
        ELSE ROUND(
            (n * sum_xy - sum_x * sum_y) / 
            (SQRT((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))),
            4
        )
    END AS pearson_correlation,
    CASE 
        WHEN (n * sum_x2 - sum_x * sum_x) = 0 OR (n * sum_y2 - sum_y * sum_y) = 0 
        THEN 'Not Applicable'
        WHEN (n * sum_xy - sum_x * sum_y) / 
             (SQRT((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))) = 1 THEN 'Perfect Positive'
        WHEN (n * sum_xy - sum_x * sum_y) / 
             (SQRT((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))) >= 0.5 THEN 'Moderate Positive'
        WHEN (n * sum_xy - sum_x * sum_y) / 
             (SQRT((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))) > 0 THEN 'Weak Positive'
        WHEN (n * sum_xy - sum_x * sum_y) / 
             (SQRT((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))) = 0 THEN 'No Correlation'
        WHEN (n * sum_xy - sum_x * sum_y) / 
             (SQRT((n * sum_x2 - sum_x * sum_x) * (n * sum_y2 - sum_y * sum_y))) >= -0.5 THEN 'Weak Negative'
        ELSE 'Moderate Negative'
    END AS correlation_strength
FROM Stats;

SELECT * FROM Ratings_Discount_Correlation;

-- 5.Identify the top-performing products by rating count and average rating.
CREATE TABLE Top_Performing_Products AS
SELECT 
    product_name, 
    Category, 
    rating_count, 
    ROUND(AVG(rating), 2) AS avg_rating
FROM Amazon_Sales
GROUP BY product_name, Category, rating_count
ORDER BY rating_count DESC, avg_rating DESC
LIMIT 10;

SELECT * FROM Top_Performing_Products;

-- 6.How do popularity (rating_count) and customer satisfaction (rating) relate across categories?
CREATE TABLE Popularity_vs_Satisfaction AS
SELECT 
    Category, 
    SUM(rating_count) AS total_rating_count, 
    ROUND(AVG(rating), 2) AS avg_rating
FROM Amazon_Sales
GROUP BY Category
ORDER BY total_rating_count DESC;

SELECT * FROM Popularity_vs_Satisfaction;

-- 7.Compare average pricing metrics (actual_price, discounted_price, and discount_percentage) across categories
-- to uncover trends and opportunities for targeted pricing strategies.

CREATE TABLE Pricing_Comparison AS
SELECT 
    Category, 
    COUNT(*) AS total_products, 
    ROUND(AVG(actual_price), 2) AS avg_actual_price, 
    ROUND(AVG(discounted_price), 2) AS avg_discounted_price, 
    ROUND(AVG(discount_percentage), 2) AS avg_discount_percentage
FROM Amazon_Sales
GROUP BY Category
ORDER BY total_products DESC;

SELECT * FROM Pricing_Comparison;

-- 8.Examine reviewer behavior by identifying the most active reviewers (using user_id and review counts) and
-- determine if their feedback influences overall product ratings.
CREATE TABLE Most_Active_Reviewers AS
WITH Reviewer_Stats AS (
    SELECT 
        user_id, 
        COUNT(review_id) AS total_reviews, 
        ROUND(AVG(rating), 2) AS avg_given_rating
    FROM Amazon_Sales
    WHERE user_id IS NOT NULL AND user_id <> ''
    GROUP BY user_id
), 
Overall_Stats AS (
    SELECT 
        ROUND(AVG(rating), 2) AS overall_avg_rating 
    FROM Amazon_Sales
),
Top_Reviewers_Stats AS (
    SELECT 
        ROUND(AVG(avg_given_rating), 2) AS avg_rating_top_100_reviewers
    FROM Reviewer_Stats 
    ORDER BY total_reviews DESC 
    LIMIT 100
)
SELECT 
    r.user_id, 
    r.total_reviews, 
    r.avg_given_rating, 
    t.avg_rating_top_100_reviewers,
    o.overall_avg_rating
FROM Reviewer_Stats r
JOIN Overall_Stats o
JOIN Top_Reviewers_Stats t
ORDER BY r.total_reviews DESC
LIMIT 100;

SELECT * FROM Most_Active_Reviewers;

-- 9.Assess the impact of product descriptions by comparing the detail level in 'about_product' with product ratings and rating counts.
-- Does a more comprehensive description lead to higher customer trust and better ratings?

CREATE TABLE Product_Description_Stats AS
WITH DescriptionStats AS (
    SELECT 
        about_product,
        LENGTH(about_product) AS description_char_count,
        (LENGTH(about_product) - LENGTH(REPLACE(about_product, ' ', '')) + 1) AS description_word_count,
        CASE 
            WHEN (LENGTH(about_product) - LENGTH(REPLACE(about_product, ' ', '')) + 1) < 50 
                 OR LENGTH(about_product) < 400 THEN 'Short'
            WHEN ((LENGTH(about_product) - LENGTH(REPLACE(about_product, ' ', '')) + 1) BETWEEN 50 AND 99) 
                 OR (LENGTH(about_product) BETWEEN 400 AND 799) THEN 'Medium'
            ELSE 'Detailed'
        END AS description_category
    FROM Amazon_Sales
),
CategoryAverages AS (
    SELECT 
        d.description_category,
        AVG(a.rating) AS avg_rating,
        AVG(a.rating_count) AS avg_rating_count,
        COUNT(*) AS total_products
    FROM Amazon_Sales a
    JOIN DescriptionStats d ON a.about_product = d.about_product
    GROUP BY d.description_category
)
SELECT 
    d.about_product,
    d.description_word_count,
    d.description_char_count,
    d.description_category,
    c.avg_rating,
    c.avg_rating_count,
    c.total_products
FROM DescriptionStats d
JOIN CategoryAverages c ON d.description_category = c.description_category;

SELECT * FROM Product_Description_Stats;

-- 10.Explore the interplay between discount strategies and customer satisfaction by segmenting products into discount brackets and 
-- comparing average ratings across these segments.

CREATE TABLE Discount_Bracket_Analysis AS
SELECT 
    CASE 
        WHEN discount_percentage BETWEEN 0.0 AND 0.10 THEN '0-10%'
        WHEN discount_percentage BETWEEN 0.10 AND 0.20 THEN '10-20%'
        WHEN discount_percentage BETWEEN 0.20 AND 0.30 THEN '20-30%'
        WHEN discount_percentage BETWEEN 0.30 AND 0.40 THEN '30-40%'
        WHEN discount_percentage BETWEEN 0.40 AND 0.50 THEN '40-50%'
        ELSE '50%+'
    END AS discount_bracket,
    COUNT(*) AS rating_count,
    AVG(rating) AS average_rating
FROM Amazon_Sales
GROUP BY discount_bracket;

SELECT * FROM Discount_Bracket_Analysis;


