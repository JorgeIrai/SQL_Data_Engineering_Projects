SELECT
    job_posted_date,
    job_posted_date::DATE AS date,
    job_posted_date::TIME AS time,
    job_posted_date::TIMESTAMP AS timestamp,
    job_posted_date::TIMESTAMPTZ AS timestamptz
FROM
    job_postings_fact
LIMIT
    10;


SELECT
    EXTRACT(YEAR from job_posted_date) AS job_posted_year,
    EXTRACT(MONTH from job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Engineer'
GROUP BY
    job_posted_year, job_posted_month
ORDER BY
    job_posted_year, job_posted_month;


SELECT
    job_posted_date,
    -- Agrupa al primer día del año (Ej: 2026-01-01 00:00:00)
    DATE_TRUNC('year', job_posted_date) AS job_posted_year,
    
    -- Agrupa al primer día del trimestre (Ej: 2026-04-01 00:00:00)
    DATE_TRUNC('quarter', job_posted_date) AS job_posted_quarter,
    
    -- Agrupa al primer día del mes (Ej: 2026-05-01 00:00:00)
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    
    -- Agrupa al primer día de la semana, usualmente lunes (Ej: 2026-05-12 00:00:00)
    DATE_TRUNC('week', job_posted_date) AS job_posted_week,

    DATE_TRUNC('day', job_posted_date) AS job_posted_week,
    
    -- Agrupa al inicio de la hora exacta, llevando los minutos y segundos a cero (Ej: 2026-05-18 14:00:00)
    DATE_TRUNC('hour', job_posted_date) AS job_posted_hour
FROM
    job_postings_fact
ORDER BY 
    RANDOM()
LIMIT
    10;

SELECT
    DATE_TRUNC('month', job_posted_date) AS job_posted_month,
    COUNT(job_id) AS job_count
FROM
    job_postings_fact
WHERE
    job_title_short = 'Data Engineer'
    AND DATE_TRUNC('year', job_posted_date) = '2024-01-01' 
    --AND EXTRACT(YEAR from job_posted_date) = 2024
GROUP BY
    job_posted_month
ORDER BY
    job_posted_month;


SELECT 
    '2026-01-01 00:00:00+00'::TIMESTAMPTZ AT TIME ZONE 'EST';


SELECT
    job_title_short,
    job_location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST'
FROM 
    job_postings_fact
WHERE 
    job_location LIKE 'New York, NY';

SELECT
    EXTRACT(HOUR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST') AS job_posted_hour,
    COUNT(job_id)
FROM 
    job_postings_fact
WHERE 
    job_location LIKE 'New York, NY'
GROUP BY job_posted_hour
ORDER BY job_posted_hour;