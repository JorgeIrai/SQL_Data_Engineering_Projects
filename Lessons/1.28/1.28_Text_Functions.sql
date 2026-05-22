SELECT CHAR_LENGTH('SQL');

SELECT LOWER('SQL');

SELECT LEFT('SQL', 1);

SELECT SUBSTRING('SQL', 2, 2);

SELECT CONCAT('SQL', '-', 'functions');

SELECT TRIM(' SQL ');

SELECT REPLACE('SQL', 'Q', '_');

SELECT REGEXP_REPLACE('data.nerd@gmail.com', '^.*(@)', '\1');


-- Cleanup this using Text Function
WITH title_lower AS(
    SELECT 
        job_title,
        LOWER(TRIM(job_title)) AS job_title_clean
    FROM job_postings_fact
)
SELECT
    job_title,
    CASE
        WHEN job_title_clean LIKE '%data%'
            AND job_title_clean LIKE '%analyst%' THEN 'Data Analyst'
        WHEN job_title_clean LIKE '%data%'
            AND job_title_clean LIKE '%scientist%' THEN 'Data Scientist'
        WHEN job_title_clean LIKE '%data%'
            AND job_title_clean LIKE '%engineer%' THEN 'Data Engineer'
        ELSE 'Other'
    END AS job_title_category
FROM
    title_lower
ORDER BY RANDOM()
LIMIT
    30;

SELECT NULLIF(10+10,20);


--If there were any 0 values
SELECT
    MEDIAN(NULLIF(salary_year_avg, 0)),
    MEDIAN(NULLIF(salary_hour_avg, 0))
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
LIMIT 10;


SELECT COALESCE(NULL, 1, 2);

SELECT
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg*2080) AS opt
FROM
    job_postings_fact
WHERE
    salary_year_avg IS NOT NULL OR salary_hour_avg IS NOT NULL
LIMIT 10;


-- Simplify with COALESCE
SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    COALESCE(salary_year_avg, salary_hour_avg*2080) AS standardized_salary,
    CASE
        WHEN standardized_salary IS NULL THEN 'Missing'
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 150_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM
    job_postings_fact
ORDER BY standardized_salary
LIMIT 10;