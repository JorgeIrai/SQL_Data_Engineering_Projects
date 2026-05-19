-- Bucket Salaries
-- < 25 = 'Low'
-- 25 -50 = 'Medium'
-- > 50 = 'High'
SELECT
    jpf.job_title_short,
    jpf.salary_hour_avg,
    CASE
        WHEN jpf.salary_hour_avg < 25 THEN 'Low'
        WHEN jpf.salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM
    job_postings_fact jpf
WHERE
    jpf.salary_hour_avg IS NOT NULL
LIMIT
    10;

-- Handling Missing Data (NULLS)
-- Filter NULL salary values
SELECT
    jpf.job_title_short,
    jpf.salary_hour_avg,
    CASE
        WHEN jpf.salary_hour_avg IS NULL THEN 'Missing'
        WHEN jpf.salary_hour_avg < 25 THEN 'Low'
        WHEN jpf.salary_hour_avg < 50 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM
    job_postings_fact jpf
LIMIT
    10;

-- Standardizing categorical values
-- Classify the 'job_title' column values as:
-- 'Data Analyst'
-- 'Data Engineer'
-- 'Data Scientist'
SELECT
    job_title,
    CASE
        WHEN job_title LIKE '%Data%'
        AND job_title LIKE '%Analyst%' THEN 'Data Analyst'
        WHEN job_title LIKE '%Data%'
        AND job_title LIKE '%Engineer%' THEN 'Data Engineer'
        WHEN job_title LIKE '%Data%'
        AND job_title LIKE '%Scientist%' THEN 'Data Scientist'
        ELSE 'Other'
    END AS job_title_category,
    job_title_short
FROM
    job_postings_fact
ORDER BY
    RANDOM()
LIMIT
    20;

-- Conditional Aggregation
-- Calculate Median Salaries for Different Buckets
-- < $100K
-- >= $100K
SELECT
    jpf.job_title_short,
    COUNT(*) AS total_postings,
    MEDIAN(
        CASE
            WHEN jpf.salary_year_avg < 100_000 THEN jpf.salary_year_avg
        END
    ) AS medium_low_salary,
    MEDIAN(
        CASE
            WHEN jpf.salary_year_avg >= 100_000 THEN jpf.salary_year_avg
        END
    ) AS medium_high_salary
FROM
    job_postings_fact jpf
WHERE
    jpf.salary_year_avg IS NOT NULL
GROUP BY
    jpf.job_title_short;

-- Final Example: Conditional Calculations
-- Compute a standardized_salary using yearly salary and adjusted hourlys salary (e.g. 2080 hours/year)
-- Categorize salaries into tiers of:
-- < 75K
-- 75K - 150K
-- >=150K
SELECT
    job_title_short,
    salary_year_avg,
    salary_hour_avg,
    CASE
        WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
        WHEN salary_year_avg IS NULL
        AND salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
    END AS standardized_salary,
    CASE
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 150_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM
    job_postings_fact
WHERE
    NOT (
        salary_year_avg IS NULL
        AND salary_hour_avg IS NULL
    )
ORDER BY
    RANDOM();

-- Other Way
WITH salaries AS(
    SELECT
        job_title_short,
        salary_year_avg,
        salary_hour_avg,
        CASE
            WHEN salary_year_avg IS NOT NULL THEN salary_year_avg
            WHEN salary_year_avg IS NULL AND salary_hour_avg IS NOT NULL THEN salary_hour_avg * 2080
        END AS standardized_salary
    FROM
        job_postings_fact
)
SELECT
    *,
    CASE
        WHEN standardized_salary IS NULL THEN 'Missing'
        WHEN standardized_salary < 75_000 THEN 'Low'
        WHEN standardized_salary < 150_000 THEN 'Medium'
        ELSE 'High'
    END AS salary_category
FROM
    salaries
ORDER BY standardized_salary
LIMIT 10;