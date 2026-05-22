SELECT UNNEST([1, 1, 1, 2])
EXCEPT ALL
SELECT UNNEST([1, 1, 3]);

-- Temporary tables with 2023 and 2024 job postings
CREATE OR REPLACE TEMP TABLE job_postings_2023 AS
SELECT * EXCLUDE (job_id, job_posted_date) -- These are not unique columns, that's why they are being excluded.
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2023;

CREATE OR REPLACE TEMP TABLE job_postings_2024 AS
SELECT * EXCLUDE (job_id, job_posted_date)
FROM
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date) = 2024;


-- Which unique job postings appeared in either 2023 or 2024?
SELECT *
FROM job_postings_2023
UNION
SELECT *
FROM job_postings_2024;

SELECT 
    'jobs 2023' AS table_name,
    COUNT(*) AS job_count
FROM job_postings_2023
UNION
SELECT 
    'jobs 2024' AS table_name,
    COUNT(*) AS job_count
FROM job_postings_2024;


-- Which job postings appeared across both years, counting duplicates?
SELECT *
FROM job_postings_2023
UNION ALL
SELECT *
FROM job_postings_2024;

-- Which job postings appeared in 2023 but not in 2024?
SELECT *
FROM job_postings_2023
EXCEPT
SELECT *
FROM job_postings_2024;

-- Which job postings from 2023 remain after subtracting matching 2024 postings, one-for-one?
SELECT *
FROM job_postings_2023
EXCEPT ALL
SELECT *
FROM job_postings_2024;

-- Which job postings appeared in both 2023 and 2024?
SELECT *
FROM job_postings_2023
INTERSECT
SELECT *
FROM job_postings_2024; 

-- Which job postings appeared in both years, preserving duplicate counts?
SELECT *
FROM job_postings_2023
INTERSECT ALL
SELECT *
FROM job_postings_2024;