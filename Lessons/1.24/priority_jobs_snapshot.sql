-- .read Lessons/1.24/priority_jobs_snapshot.sql
-- Source table: It will be a TEMP Table that'll contain contain a query to check if there are any modifications.
-- Create Source table: 
CREATE
OR REPLACE TEMP TABLE src_priority_jobs AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_lvl,
    CURRENT_TIMESTAMP AS updated_at
FROM
    data_jobs.job_postings_fact jpf
    LEFT JOIN data_jobs.company_dim cd ON jpf.company_id = cd.company_id
    INNER JOIN staging.priority_roles pr ON jpf.job_title_short = pr.role_name;

/* 
  -- UPDATE Statement: 
  -- To capture the differences in the rows that match in src and tgt.
  -- In this case, we'll update only if the priority_lvl column changes for a specific role

UPDATE
    main.priority_jobs_snapshot AS tgt
SET
    priority_lvl = src.priority_lvl,
    updated_at   = src.updated_at
FROM
    src_priority_jobs AS src
WHERE
    tgt.job_id = src.job_id
    AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl;

---

/* 
  -- INSERT statement:
  -- We'll be looking at UNMATCHED INCOMING ROWS --> Did we add jobs to the priority_roles table. 
  -- If not, we need to insert those rows into our target table.
*/
INSERT INTO main.priority_jobs_snapshot (
    job_id,
    job_title_short,
    company_name,
    job_posted_date,
    salary_year_avg,
    priority_lvl,
    updated_at
)
SELECT
    src.job_id,
    src.job_title_short,
    src.company_name,
    src.job_posted_date,
    src.salary_year_avg,
    src.priority_lvl,
    src.updated_at
FROM
    src_priority_jobs AS src
WHERE
    NOT EXISTS (
        SELECT 1
        FROM main.priority_jobs_snapshot AS tgt
        WHERE src.job_id = tgt.job_id
    );

---

/* 
  -- DELETE: 
  -- Unmatched Existing Rows in the target table
*/
DELETE FROM 
    main.priority_jobs_snapshot AS tgt
WHERE
    NOT EXISTS (
        SELECT 1
        FROM src_priority_jobs AS src
        WHERE tgt.job_id = src.job_id
    );
*/


-- MERGE
MERGE INTO main.priority_jobs_snapshot AS tgt 
USING src_priority_jobs AS src 
ON tgt.job_id = src.job_id

WHEN MATCHED AND tgt.priority_lvl IS DISTINCT FROM src.priority_lvl THEN
    UPDATE SET
        priority_lvl = src.priority_lvl,
        updated_at = src.updated_at
    
WHEN NOT MATCHED THEN
INSERT
    (
        job_id,
        job_title_short,
        company_name,
        job_posted_date,
        salary_year_avg,
        priority_lvl,
        updated_at
    )
VALUES
    (
        src.job_id,
        src.job_title_short,
        src.company_name,
        src.job_posted_date,
        src.salary_year_avg,
        src.priority_lvl,
        src.updated_at
    )
WHEN NOT MATCHED BY SOURCE THEN DELETE;



-- Final Chck query
SELECT
    job_title_short,
    COUNT(*) AS job_count,
    MIN(priority_lvl) AS priority_lvl,
    MIN(updated_at) AS updated_at
FROM
    main.priority_jobs_snapshot
GROUP BY
    job_title_short
ORDER BY
    job_count DESC;

/*
-- CTA for creating table --> This can be done instead of MERGE
CREATE OR REPLACE TABLE main.priority_jobs_snapshot AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    cd.name AS company_name,
    jpf.job_posted_date,
    jpf.salary_year_avg,
    pr.priority_lvl,
    CURRENT_TIMESTAMP
FROM
    data_jobs.job_postings_fact jpf
LEFT JOIN
    data_jobs.company_dim cd ON jpf.company_id = cd.company_id
INNER JOIN 
    staging.priority_roles pr ON jpf.job_title_short = pr.role_name;
*/