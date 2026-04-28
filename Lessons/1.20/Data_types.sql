
SELECT  *
FROM 
    information_schema.columns;


SELECT  
    table_name,
    column_name,
    data_type
FROM 
    information_schema.columns
WHERE
    table_name = 'job_postings_fact';

DESCRIBE job_postings_fact;

DESCRIBE
SELECT 
    jpf.job_id,
    jpf.job_title_short,
    jpf.job_location
FROM 
    job_postings_fact AS jpf;


SELECT CAST('123' AS INTEGER);

SELECT 
    CAST(jpf.job_id AS VARCHAR) || '-' || CAST(jpf.company_id AS VARCHAR),
    CAST(jpf.job_work_from_home AS INT) AS job_work_from_home,
    CAST(jpf.job_posted_date AS DATE)  AS job_posted_date,
    CAST(jpf.salary_year_avg AS DECIMAL(10,0)) AS salary_year_avg
FROM 
    job_postings_fact AS jpf
WHERE   
    jpf.salary_year_avg IS NOT NULL
LIMIT 10;



SELECT 
    jpf.job_id::VARCHAR || '-' || jpf.company_id::VARCHAR AS job_company_id,
    jpf.job_work_from_home::INT AS job_work_from_home,
    jpf.job_posted_date::DATE AS job_posted_date,
    jpf.salary_year_avg::DECIMAL(10,0) AS salary_year_avg
FROM 
    job_postings_fact AS jpf
WHERE   
    jpf.salary_year_avg IS NOT NULL
LIMIT 10;