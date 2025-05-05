# Amazon E-Commerce Sales Analysis

## Objective
To derive actionable insights from Amazon E-Commerce data using data analysis and visualization techniques. The goal is to understand pricing trends, discount strategies, customer satisfaction, and reviewer behavior.

## Purpose of the Project
This project aims to:
- Uncover patterns between pricing strategies and customer ratings.
- Identify top-performing products and reviewers.
- Understand the effect of detailed product descriptions on ratings.
- Help businesses make data-driven decisions in product positioning and marketing strategies.

## Tools and Technologies Used
- **MySQL**: For storing and querying the dataset.
- **Python**: (Pandas, NumPy, Matplotlib, Seaborn) for data cleaning, transformation, and initial EDA.
- **Tableau**: For building interactive dashboards and storytelling through data visualizations.

## Dataset Info
The dataset contains information about Amazon products, their pricing, ratings, reviews, and customer interaction. It includes the following 16 columns:

- `product_id`: Unique product identifier  
- `product_name`: Name of the product  
- `category`: Product category  
- `discounted_price`: Selling price after discount  
- `actual_price`: Original product price  
- `discount_percentage`: % discount offered  
- `rating`: Customer rating  
- `rating_count`: Number of ratings  
- `about_product`: Description of the product  
- `user_id`: Reviewer’s ID  
- `user_name`: Name of the reviewer  
- `review_id`: Review ID  
- `review_title`: Short review  
- `review_content`: Detailed review  
- `img_link`: Product image URL  
- `product_link`: Product web page  

## Problem Statements Addressed

1. Analyze the relationship between actual price and discounted price.  
2. Analyze discount percentage across different product categories.  
3. Identify categories offering the best savings.  
4. Investigate if higher discount percentages correlate with better customer ratings.  
5. Identify top-performing products by rating count and average rating.  
6. Explore the relationship between product popularity and customer satisfaction across categories.  
7. Compare average pricing metrics across categories to uncover trends and pricing opportunities.  
8. Examine reviewer behavior and whether frequent reviewers influence overall ratings.  
9. Assess if detailed product descriptions affect customer trust and ratings.  
10. Explore how different discount brackets affect average customer satisfaction.

## Conclusion
The analysis helped identify that:
- Detailed product descriptions often correlate with higher customer trust and better ratings.
- Discounts have a mixed effect on ratings — not all highly discounted products are rated well.
- Top reviewers have significant influence on average product ratings.
- Categories like Electronics and Fashion offer higher discounts and greater customer engagement.
- Price comparison and discount analysis across categories revealed ideal pricing strategies.

## Output
The final output includes:
- Two Tableau Dashboards (5 problems each)
- One Tableau Story combining both dashboards

---

