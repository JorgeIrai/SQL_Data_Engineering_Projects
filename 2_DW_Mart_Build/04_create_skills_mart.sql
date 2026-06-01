-- Step 4: Mart - Create skills demand mart
-- .read 04_create_skills_mart.sql

DROP SCHEMA IF EXISTS skills_mart CASCADE;

CREATE SCHEMA skills_mart;

CREATE TABLE skills_mart.dim_skill (
    skill_id    INTEGER     PRIMARY KEY,
    skills      VARCHAR,
    type        VARCHAR
);

SELECT '=== Loading dim_skills Table ===' AS info;
INSERT INTO skills_mart.dim_skill (skill_id, skills, type)
SELECT 
    skill_id,
    skills,
    type
FROM skills_dim;


CREATE TABLE skills_mart.dim_date_month (
    month_start_date    DATE    PRIMARY KEY,
    year                INTEGER,
    month               INTEGER,
    quarter             INTEGER,
    quarter_name        VARCHAR,
    year_quarter        VARCHAR
);
SELECT '=== Loading dim_date_month Table ===' AS info;
INSERT INTO skills_mart.dim_date_month (
    month_start_date,
    year,
    month,
    quarter,
    quarter_name,
    year_quarter
)
SELECT DISTINCT
    DATE_TRUNC('month', job_posted_date) AS month_start_date,
    EXTRACT(YEAR FROM job_posted_date) AS year,
    EXTRACT(MONTH FROM job_posted_date) AS month,
    EXTRACT(QUARTER FROM job_posted_date) AS quarter,
    'Q-' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS quarter_name,
    EXTRACT(YEAR FROM job_posted_date)::VARCHAR || '-Q' || EXTRACT(QUARTER FROM job_posted_date)::VARCHAR AS year_quarter
FROM job_postings_fact
ORDER BY month_start_date;


CREATE TABLE skills_mart.fact_skill_demand_monthly (
    skill_id                            INTEGER,
    month_start_date                    DATE,
    job_title_short                     VARCHAR,
    postings_count                      INTEGER,
    remote_postings_count               INTEGER,
    health_insurance_postings_count     INTEGER,
    no_degree_mentioned_postings_count  INTEGER,
    PRIMARY KEY (skill_id, month_start_date, job_title_short),
    FOREIGN KEY (skill_id)              REFERENCES skills_mart.dim_skill(skill_id),
    FOREIGN KEY (month_start_date)      REFERENCES skills_mart.dim_date_month(month_start_date)
);

SELECT '=== Loading fact_skill_demand_monthly Table ===' AS info;
INSERT INTO skills_mart.fact_skill_demand_monthly(
    skill_id,
    month_start_date,
    job_title_short,
    postings_count,
    remote_postings_count,
    health_insurance_postings_count,    
    no_degree_mentioned_postings_count  
)
WITH job_postings_prep AS (
    SELECT
        sjd.skill_id,
        DATE_TRUNC('month', jpf.job_posted_date) AS month_start_date,
        jpf.job_title_short,
        jpf.job_work_from_home::INT   AS is_remote,
        jpf.job_health_insurance::INT AS has_health_insurance,
        jpf.job_no_degree_mention::INT AS no_degree_mentioned
    FROM
        job_postings_fact jpf
    INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
)
SELECT
    skill_id,
    month_start_date,
    job_title_short,
    COUNT(*) AS postings_count,
    SUM(is_remote) AS remote_postings_count,
    SUM(has_health_insurance) AS health_insurance_postings_count,
    SUM(no_degree_mentioned) AS no_degree_mentioned_postings_count
FROM job_postings_prep
GROUP BY ALL
ORDER BY skill_id, month_start_date, job_title_short;

SELECT 'Skill Dimension' AS table_name, COUNT(*) AS record_count FROM skills_mart.dim_skill
UNION ALL
SELECT 'Date Month Dimension' AS table_name, COUNT(*) FROM skills_mart.dim_date_month
UNION ALL
SELECT 'Skill Demand Fact' AS table_name, COUNT(*) FROM skills_mart.fact_skill_demand_monthly;


SELECT '=== Skill Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_skill LIMIT 5;

SELECT '=== Date Month Dimension Sample ===' AS info;
SELECT * FROM skills_mart.dim_date_month LIMIT 5;

SELECT '=== Skill Demand Fact Sample ===' AS info;
SELECT * FROM skills_mart.fact_skill_demand_monthly LIMIT 5;