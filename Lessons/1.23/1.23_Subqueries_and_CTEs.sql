-- Subquery (FROM): Filter JPF table to only provide job postings with salary data
SELECT
    *
FROM
    (
        SELECT
            *
        FROM
            job_postings_fact jpf
        WHERE
            jpf.salary_year_avg IS NOT NULL
            OR jpf.salary_hour_avg IS NOT NULL
    ) AS valid_salaries
LIMIT
    10;

--CTE: Filter JPF table to only provide job postings with salary data
WITH valid_salaries AS(
    SELECT
        *
    FROM
        job_postings_fact jpf
    WHERE
        jpf.salary_year_avg IS NOT NULL
        OR jpf.salary_hour_avg IS NOT NULL
)
SELECT
    *
FROM
    valid_salaries;

-- Subquery in SELECT
-- Show each job's salary next to the overall market median.
SELECT
    jpf.job_title_short,
    jpf.salary_year_avg,
    (
        SELECT
            MEDIAN(jpf.salary_year_avg)
        FROM
            job_postings_fact jpf
    ) AS median_market_salary
FROM
    job_postings_fact jpf
WHERE
    jpf.salary_year_avg IS NOT NULL
LIMIT
    10;

-- Subquery in FROM
-- Stage only jobs that are remote before aggregating
SELECT
    remote_job.job_title_short,
    MEDIAN(remote_job.salary_year_avg) AS median_salary,
    (
        SELECT
            MEDIAN(jpf.salary_year_avg)
        FROM
            job_postings_fact jpf
        WHERE
            job_work_from_home IS TRUE
    ) AS median_market_salary
FROM
    (
        SELECT
            *
        FROM
            job_postings_fact jpf
        WHERE
            job_work_from_home IS TRUE
    ) AS remote_job
GROUP BY
    remote_job.job_title_short;

-- Subquery in HAVING
-- Keep Only job titles whose median salary is above the overall median
SELECT
    remote_job.job_title_short,
    MEDIAN(remote_job.salary_year_avg) AS median_salary,
    (
        SELECT
            MEDIAN(jpf.salary_year_avg)
        FROM
            job_postings_fact jpf
        WHERE
            job_work_from_home IS TRUE
    ) AS median_market_salary
FROM
    (
        SELECT
            *
        FROM
            job_postings_fact jpf
        WHERE
            job_work_from_home IS TRUE
    ) AS remote_job
GROUP BY
    remote_job.job_title_short
HAVING
    median_salary > (
        SELECT
            MEDIAN(jpf.salary_year_avg)
        FROM
            job_postings_fact jpf
        WHERE
            job_work_from_home IS TRUE
    );

-- CTE Example
-- Compare how much more (or less) remote roles pay compared to onsite roles for each job title.
-- Use a CTE to calculate the median salary by title and work arrangement, then compare those medians.
WITH valid_salaries AS (
    SELECT
        jpf.job_title_short,
        jpf.job_work_from_home,
        MEDIAN(salary_year_avg) :: INT AS median_salary
    FROM
        job_postings_fact jpf
    GROUP BY
        jpf.job_title_short,
        jpf.job_work_from_home
    ORDER BY
        job_title_short
)
SELECT
    r.job_title_short,
    r.median_salary AS remote_median_salary,
    o.median_salary AS onsite_median_salary,
    (remote_median_salary - onsite_median_salary) AS difference
FROM
    valid_salaries r
    INNER JOIN valid_salaries o ON r.job_title_short = o.job_title_short
WHERE
    r.job_work_from_home = TRUE
    AND o.job_work_from_home = FALSE
ORDER BY
    difference DESC;

SELECT
    *
FROM
    range(3) AS src(key);

SELECT
    *
FROM
    range(3) AS src(key)
WHERE
    EXISTS (
        SELECT
            1 -- You can put whatever (1, *)
        FROM
            range(2) AS tgt(key)
        WHERE
            tgt.key = src.key
    );

-- Final example
-- Identify job postings that have no associated skills before loading them into a data mart
SELECT
    *
FROM
    job_postings_fact src
WHERE
    NOT EXISTS(
        SELECT
            1
        FROM
            skills_job_dim tgt
        WHERE
            src.job_id = tgt.job_id
    )
ORDER BY
    src.job_id;