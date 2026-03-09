EXPLAIN ANALYZE 
SELECT 
    cd.name,
    COUNT(jpf.job_id) AS num_job_postings
FROM 
    job_postings_fact jpf
LEFT JOIN 
    company_dim cd ON cd.company_id = jpf.company_id
WHERE
    jpf.job_country = 'United States'
GROUP BY 
    cd.name
HAVING 
    num_job_postings > 3000
ORDER BY num_job_postings DESC
LIMIT 10;
