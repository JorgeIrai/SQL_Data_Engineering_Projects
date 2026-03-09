/*
What are the most in-demand skills for data engineers?
- Identify the top 10 in-demand skills for data engineers
- Focus on remote job postings
- Why? 
    - Retrieves the top 10 skills with the highest demand in the 
    remote job market, providing insights into the most valuable 
    skills for data engineers seeking remote work
*/

SELECT 
    sd.skills,
    COUNT(jpf.job_id) AS num_jobs_per_skill
FROM 
    job_postings_fact jpf
LEFT JOIN
    skills_job_dim sjd ON jpf.job_id = sjd.job_id
LEFT JOIN
    skills_dim sd ON sjd.skill_id = sd.skill_id
WHERE 
    jpf.job_title_short = 'Data Engineer'
    AND(
      jpf.job_work_from_home = TRUE OR job_location = 'Anywhere'
    )
GROUP BY sd.skills
ORDER BY num_jobs_per_skill DESC
LIMIT 10;

/*
┌────────────┬────────────────────┐
│   skills   │ num_jobs_per_skill │
│  varchar   │       int64        │
├────────────┼────────────────────┤
│ sql        │              29243 │
│ python     │              28803 │
│ aws        │              17842 │
│ azure      │              14160 │
│ spark      │              12811 │
│ airflow    │               9999 │
│ snowflake  │               8647 │
│ databricks │               8192 │
│ java       │               7271 │
│ gcp        │               6452 │
├────────────┴────────────────────┤
│ 10 rows               2 columns │
└─────────────────────────────────┘
*/