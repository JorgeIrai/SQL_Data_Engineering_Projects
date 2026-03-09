/*
Question: What are the most optimal skills for data engineers—balancing both demand and salary?
- Create a ranking column that combines demand count and median salary to identify the most valuable skills.
- Focus only on remote Data Engineer positions with specified annual salaries.
- Why?
    - This approach highlights skills that balance market demand and financial reward. 
    It weights core skills appropriately instead of letting rare, outlier skills distort the results.
    
    - The natural log transformation ensures that both high-salary and widely in-demand skills surface 
    as the most practical and valuable to learn for data engineering careers.
*/

SELECT
  sd.skills,
  ROUND(MEDIAN(jpf.salary_year_avg),0) AS median_salary,
  COUNT(jpf.*) AS demand_count, 
  ROUND(LN(COUNT(jpf.*)),1) AS ln_demand_count,
  ROUND((median_salary * ln_demand_count)/1_000_000,2) AS optimal_demand
FROM
  job_postings_fact jpf
  INNER JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
  INNER JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE
  jpf.job_title_short = 'Data Engineer'
  AND (
    jpf.job_work_from_home = TRUE
    OR job_location = 'Anywhere'
  )
  AND jpf.salary_year_avg NOT NULL
GROUP BY
  sd.skills
ORDER BY
  optimal_demand DESC
LIMIT 25;

/*
┌────────────┬───────────────┬──────────────┬─────────────────┬────────────────┐
│   skills   │ median_salary │ demand_count │ ln_demand_count │ optimal_demand │
│  varchar   │    double     │    int64     │     double      │     double     │
├────────────┼───────────────┼──────────────┼─────────────────┼────────────────┤
│ terraform  │      184000.0 │          193 │             5.3 │           0.98 │
│ python     │      135000.0 │         1135 │             7.0 │           0.95 │
│ aws        │      137305.0 │          784 │             6.7 │           0.92 │
│ sql        │      130000.0 │         1130 │             7.0 │           0.91 │
│ airflow    │      150000.0 │          387 │             6.0 │            0.9 │
│ spark      │      140000.0 │          504 │             6.2 │           0.87 │
│ kafka      │      145000.0 │          292 │             5.7 │           0.83 │
│ snowflake  │      135500.0 │          438 │             6.1 │           0.83 │
│ azure      │      128075.0 │          476 │             6.2 │           0.79 │
│ java       │      134300.0 │          304 │             5.7 │           0.77 │
│ scala      │      136645.0 │          248 │             5.5 │           0.75 │
│ kubernetes │      150500.0 │          147 │             5.0 │           0.75 │
│ databricks │      132750.0 │          266 │             5.6 │           0.74 │
│ git        │      140000.0 │          208 │             5.3 │           0.74 │
│ redshift   │      130000.0 │          274 │             5.6 │           0.73 │
│ gcp        │      136000.0 │          197 │             5.3 │           0.72 │
│ hadoop     │      135000.0 │          199 │             5.3 │           0.72 │
│ nosql      │      133458.0 │          194 │             5.3 │           0.71 │
│ pyspark    │      140000.0 │          152 │             5.0 │            0.7 │
│ golang     │      184000.0 │           39 │             3.7 │           0.68 │
│ docker     │      135000.0 │          144 │             5.0 │           0.68 │
│ mongodb    │      135750.0 │          136 │             4.9 │           0.67 │
│ go         │      140000.0 │          113 │             4.7 │           0.66 │
│ github     │      135000.0 │          127 │             4.8 │           0.65 │
│ r          │      133638.0 │          134 │             4.9 │           0.65 │
├────────────┴───────────────┴──────────────┴─────────────────┴────────────────┤
│ 25 rows                                                            5 columns │
└──────────────────────────────────────────────────────────────────────────────┘
*/