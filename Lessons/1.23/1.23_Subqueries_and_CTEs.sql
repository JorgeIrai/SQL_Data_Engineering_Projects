SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL 
        OR salary_hour_avg IS NOT NULL
) AS valid_salaries
LIMIT 10;

--CTE
WITH valid_salaries AS (
    SELECT *
    FROM job_postings_fact
    WHERE salary_year_avg IS NOT NULL 
        OR salary_hour_avg IS NOT NULL
)

SELECT *
FROM
    valid_salaries;

-- Subquery in SELECT
SELECT
    job_title_short,
    salary_year_avg,
    (
        SELECT MEDIAN(salary_year_avg)
        FROM job_postings_fact
    )   AS median_market_salary
FROM job_postings_fact
WHERE salary_year_avg IS NOT NULL
LIMIT 10;

-- Subquery in FROM
SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    (
        SELECT MEDIAN(salary_year_avg),
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS median_remote_market_salary
FROM (
    SELECT
        job_title_short,
        salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS remote_job
GROUP BY job_title_short
LIMIT 10;

-- Subquery in HAVING
SELECT 
    job_title_short,
    MEDIAN(salary_year_avg) AS median_salary,
    (
        SELECT MEDIAN(salary_year_avg),
        FROM job_postings_fact
        WHERE job_work_from_home = TRUE
    ) AS median_remote_market_salary
FROM (
    SELECT
        job_title_short,
        salary_year_avg
    FROM job_postings_fact
    WHERE job_work_from_home = TRUE
) AS remote_job
GROUP BY job_title_short
HAVING median_salary > median_remote_market_salary
LIMIT 10;


-- CTE Example
-- Compare how much more (or less) remote roles pay compared to onsite roles for each job title.
-- Use a CTE to calculate the median salary by title and work arrangement, then compare those medians.

WITH title_median AS (
    SELECT
        job_title_short,
        job_work_from_home,
        MEDIAN(salary_year_avg)::INT AS median_salary
    FROM job_postings_fact
    GROUP BY job_title_short, job_work_from_home
    ORDER BY job_title_short
)

SELECT 
    r.job_title_short,
    r.median_salary AS remote_median_salary,
    o.median_salary AS onsite_median_salary,
    (remote_median_salary - onsite_median_salary) AS remote_premium
FROM title_median r
INNER JOIN title_median o ON r.job_title_short = o.job_title_short
WHERE r.job_work_from_home = TRUE AND o.job_work_from_home = FALSE
ORDER BY remote_premium DESC;


SELECT *
FROM range(3) AS src(key);

SELECT *
FROM range(3) AS src(key)
WHERE NOT EXISTS (
    SELECT 1 -- You can put whatever (1, *)
    FROM range(2) AS tgt(key)
    WHERE tgt.key = src.key
);


-- Final example
-- Identify job postings that have no associated skills before loading them into a data mart
SELECT *
FROM job_postings_fact tgt
WHERE NOT EXISTS (
    SELECT 1
    FROM skills_job_dim src
    WHERE tgt.job_id = src.job_id
)
ORDER BY job_id;


SELECT * 
FROM skills_job_dim
ORDER BY job_id
LIMIT 40;