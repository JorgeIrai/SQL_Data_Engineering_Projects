/*
Question: What are the highest-paying skills for data engineers?
- Calculate the median salary for each skill required in data engineer positions
- Focus on remote positions with specified salaries
- Include skill frequency to identify both salary and demand
- Why? 
    - Helps identify which skills command the highest compensation while also showing 
    how common those skills are, providing a more complete picture for skill development
    priorities.
    - The median is used instead of the average to reduce the influence of outliers.
*/

SELECT
  sd.skills,
  ROUND(MEDIAN(jpf.salary_year_avg),0) AS median_salary,
  COUNT(jpf.job_id) AS demand_count
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
GROUP BY
  sd.skills
HAVING 
  demand_count > 100
ORDER BY
  median_salary DESC
LIMIT 25;

/*
┌────────────┬───────────────┬──────────────┐
│   skills   │ median_salary │ demand_count │
│  varchar   │    double     │    int64     │
├────────────┼───────────────┼──────────────┤
│ rust       │      210000.0 │          232 │
│ terraform  │      184000.0 │         3250 │
│ golang     │      184000.0 │          912 │
│ spring     │      175500.0 │          365 │
│ gdpr       │      169616.0 │          583 │
│ zoom       │      168438.0 │          127 │
│ graphql    │      167500.0 │          445 │
│ mongo      │      162250.0 │          265 │
│ fastapi    │      157500.0 │          204 │
│ django     │      155000.0 │          266 │
│ bitbucket  │      155000.0 │          478 │
│ crystal    │      154224.0 │          129 │
│ atlassian  │      151500.0 │          250 │
│ c          │      151500.0 │          444 │
│ typescript │      151000.0 │          388 │
│ kubernetes │      150500.0 │         4205 │
│ ruby       │      150000.0 │          736 │
│ css        │      150000.0 │          262 │
│ node       │      150000.0 │          179 │
│ airflow    │      150000.0 │         9999 │
│ neo4j      │      149075.0 │          278 │
│ redis      │      149000.0 │          606 │
│ vmware     │      148798.0 │          136 │
│ ansible    │      148798.0 │          475 │
│ jupyter    │      147500.0 │          400 │
├────────────┴───────────────┴──────────────┤
│ 25 rows                         3 columns │
└───────────────────────────────────────────┘
*/