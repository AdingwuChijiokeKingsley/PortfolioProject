-- 				DATA CLEANING PROJECT 
-- 					FEW STEPS
-- Creating Staging Table
-- Remove Duplicates if Any
-- Standardize Data and Fixing Errors
-- Check for Null or Blank Values
-- Remove any rows and column not necessary


-- Creating Staging Table

SELECT*
FROM world_layoffs;

CREATE TABLE world_layoffs_staging
LIKE world_layoffs;

INSERT INTO world_layoffs_staging
SELECT*
FROM world_layoffs;

SELECT* 
FROM world_layoffs_staging;


-- Remove Duplicates if Any


SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs_staging;

WITH DUPLICATE_CTE AS 
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs_staging
)
SELECT*
FROM DUPLICATE_CTE
WHERE row_Num > 1;

CREATE TABLE `world_layoffs_staging1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT*
FROM world_layoffs_staging1;

INSERT INTO world_layoffs_staging1
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,
percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM world_layoffs_staging;

SELECT*
FROM world_layoffs_staging1;

SELECT*
FROM world_layoffs_staging1
WHERE row_num > 1;

DELETE
FROM world_layoffs_staging1
WHERE row_num > 1;

SELECT*
FROM world_layoffs_staging1;



-- Standardize Data and Fixing Errors


SELECT DISTINCT company
FROM world_layoffs_staging1;

SELECT DISTINCT company, Trim(company)
FROM world_layoffs_staging1;

UPDATE world_layoffs_staging1
SET company = Trim(company);

SELECT DISTINCT industry
FROM world_layoffs_staging1
ORDER BY 1;

SELECT DISTINCT industry
FROM world_layoffs_staging1
WHERE industry LIKE 'Crypto%';

UPDATE world_layoffs_staging1
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT *
FROM world_layoffs_staging1;

SELECT DISTINCT location
FROM world_layoffs_staging1;

SELECT DISTINCT country
FROM world_layoffs_staging1
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.'  FROM country)
FROM world_layoffs_staging1
ORDER BY 1;

UPDATE world_layoffs_staging1
SET country = TRIM(TRAILING '.'  FROM country);

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM world_layoffs_staging1;

UPDATE world_layoffs_staging1
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE world_layoffs_staging1
MODIFY COLUMN `date` DATE;

SELECT date
FROM world_layoffs_staging1;

SELECT*
FROM world_layoffs_staging1;

SELECT *
FROM world_layoffs_staging1
WHERE industry IS NULL
OR industry = '';

UPDATE world_layoffs_staging1
SET industry = NULL
WHERE industry = '';

SELECT *
FROM world_layoffs_staging1 t1
JOIN world_layoffs_staging1 t2
	ON t1.company = t2.company
WHERE t1.industry is NULL
AND t2.industry is NOT NULL;

UPDATE world_layoffs_staging1 t1
JOIN world_layoffs_staging1 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry is NULL
AND t2.industry is NOT NULL;

SELECT*
FROM world_layoffs_staging1;

SELECT *
FROM world_layoffs_staging1
WHERE total_laid_off = ""
OR percentage_laid_off = "";

SELECT *
FROM world_layoffs_staging1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

DELETE
FROM world_layoffs_staging1
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


ALTER TABLE world_layoffs_staging1
DROP COLUMN Row_Num;

SELECT*
FROM world_layoffs_staging1;


-- EXPLORATORY DATA ANALYSIS PROJECT


SELECT *
FROM world_layoffs_staging1;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM world_layoffs_staging1;

SELECT *
FROM world_layoffs_staging1
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;

SELECT country, SUM(total_laid_off)
FROM world_layoffs_staging1
GROUP BY country
ORDER BY 2 DESC;

SELECT company, SUM(total_laid_off)
FROM world_layoffs_staging1
GROUP BY company
ORDER BY 2 DESC;

SELECT industry, SUM(total_laid_off)
FROM world_layoffs_staging1
GROUP BY industry
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM world_layoffs_staging1;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs_staging1
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM world_layoffs_staging1
GROUP BY stage
ORDER BY 2 DESC;


-- LETS DO A ROLLING SUM OF THIS DATA, LET'S LOOK AT THE PROGRESSION --

SELECT SUBSTRING(`date`, 1, 7) `MONTH`, SUM(total_laid_off)
FROM world_layoffs_staging1
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH ROLLING_TOTAL AS
(
SELECT SUBSTRING(`date`, 1, 7) `MONTH`, SUM(total_laid_off) total_off
FROM world_layoffs_staging1
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(total_off) OVER(ORDER BY `MONTH`) Rolling_Total
FROM ROLLING_TOTAL;

-- LETS DO A RANKING OF THIS DATA FOR EACH YEAR, LET'S LOOK AT THE PROGRESSION --

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs_staging1
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;  

WITH HIGHEST_COMPANY_LAIDOFF_FOR_EACH_YEAR (company, Years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM world_layoffs_staging1
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(SELECT *, DENSE_RANK() OVER (PARTITION BY Years ORDER BY total_laid_off DESC) AS Ranking
FROM HIGHEST_COMPANY_LAIDOFF_FOR_EACH_YEAR
WHERE Years IS NOT NULL
ORDER BY Ranking
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5 
ORDER BY Ranking;
