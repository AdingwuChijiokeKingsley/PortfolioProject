# SQL Data Cleaning & Exploratory Data Analysis on World Layoffs Dataset

# Project Overview
This project focuses on data cleaning and exploratory data analysis (EDA) using SQL on a dataset containing global layoffs across different industries. The objective was to prepare, clean, and analyze the dataset to extract meaningful insights into layoff trends.

# Key Steps & SQL Techniques Used

# 1. Data Cleaning
To ensure data integrity and consistency, the following steps were taken:

🔹 Created a Staging Table

Used CREATE TABLE and INSERT INTO to duplicate the raw dataset into a staging table for modifications without affecting the original data.
🔹 Removed Duplicates

Identified duplicate records using ROW_NUMBER() with PARTITION BY over relevant columns.
Deleted duplicate records from the dataset using DELETE FROM with a Common Table Expression (CTE).
🔹 Standardized Data and Fixed Errors

Trimmed unnecessary spaces using TRIM().
Standardized industry names (e.g., consolidating variations of "Crypto" into a single label).
Converted date values from text format to DATE type using STR_TO_DATE().
Handled missing values by replacing blank fields with NULL and using self-joins to fill missing industries where the company had a known industry in another record.
Removed unnecessary columns using ALTER TABLE DROP COLUMN.
# 2. Exploratory Data Analysis (EDA)
After cleaning the data, several SQL queries were executed to uncover insights on layoff trends:

🔹 Summary Statistics

Used MAX() and MIN() to determine the range of layoffs over time.
🔹 Industry and Country Insights

GROUP BY and SUM() to identify industries and countries with the highest number of layoffs.
🔹 Yearly and Monthly Trends

Extracted yearly (YEAR(date)) and monthly (SUBSTRING(date, 1, 7)) layoffs, then calculated rolling totals using SUM() OVER(ORDER BY date).
🔹 Ranking Companies by Layoffs Per Year

Used DENSE_RANK() OVER(PARTITION BY YEAR(date) ORDER BY total_laid_off DESC) to identify top companies with the highest layoffs each year.

# Key Findings
📌 Industries like Tech & Crypto saw major layoffs.
📌 The highest layoffs occurred in specific years, indicating economic downturns.
📌 Some companies appeared multiple times in the top layoffs ranking.
📌 A progressive increase in layoffs was observed over time.

# Conclusion

This project showcases SQL data cleaning and exploratory analysis techniques, demonstrating proficiency in:
✅ Data preprocessing (duplicates, missing values, standardization)
✅ Advanced SQL window functions (PARTITION BY, ROW_NUMBER(), DENSE_RANK())
✅ Aggregation & trend analysis using SUM(), GROUP BY, and ORDER BY
✅ Optimized SQL queries for real-world data analysis

🔹 Tools Used: MySQL
🔹 Dataset: Global layoffs dataset (world_layoffs.csv)

Check out the full SQL script in the repository!
