-- Array Intro
SELECT ['python', 'sql', 'r'] AS skills_array;


WITH skills AS (
    SELECT 'python' AS skill
    UNION ALL
    SELECT 'sql'
    UNION ALL
    SELECT 'r'
), skills_array AS (
    SELECT ARRAY_AGG(skill ORDER BY skill) AS skills -- Alphabetical order
    FROM skills
)
SELECT 
    skills[1] AS first_skill,
    skills[2] AS second_skill,
    skills[3] AS third_skill,
FROM skills_array;


-- STRUCT
SELECT {skill:'python', type:'programming'} AS skill_struct;

WITH skill_struct AS(
    SELECT 
    STRUCT_PACK(
        skill := 'python',
        type := 'programming'
    ) AS s
)
SELECT 
    s.skill,
    s.type
FROM skill_struct;


WITH skill_table AS(
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
)
SELECT 
    STRUCT_PACK(
        skill := skills,
        type := types
    )
FROM skill_table;



-- Array of Structs
SELECT [
    {skill: 'python', type:'programming'},
    {skill: 'sql', type: 'query_language'}
] AS skills_array_of_structs;



WITH skill_table AS(
    SELECT 'python' AS skills, 'programming' AS types
    UNION ALL
    SELECT 'sql', 'query_language'
    UNION ALL
    SELECT 'r', 'programming'
), skills_array_structs AS(
    SELECT 
        ARRAY_AGG(
            STRUCT_PACK(
                skill := skills,
                type := types
            )
        ) AS array_struct
    FROM skill_table
)
SELECT
    array_struct[1].type,
    array_struct[2].skill,
    array_struct[3]
FROM skills_array_structs;


-- MAP
WITH skill_map AS(
    SELECT MAP {'skill' :  'python', 'type' : 'programming'} AS skill_type
)
SELECT
    skill_type['skill'],
    skill_type['type']
FROM skill_map;


-- JSON
WITH raw_skill_json AS(
    SELECT
        '{"skill":"python", "type":"programming"}'::JSON AS skill_json
)
SELECT
    STRUCT_PACK(
        skill := JSON_EXTRACT_STRING(skill_json, '$.skill'),
        type := JSON_EXTRACT_STRING(skill_json, '$.type')
    )
FROM raw_skill_json;


-- JSON to Array of Structs
WITH raw_json AS (
    SELECT
        '[
            {"skill":"python", "type":"programming"},
            {"skill":"sql", "type":"query_language"},
            {"skill":"r", "type":"programming"}
        ]'::JSON AS skills_json
)
SELECT
    ARRAY_AGG(
        STRUCT_PACK(
            skill := json_extract_string(e.value, '$.skill'),
            type  := json_extract_string(e.value, '$.type')
        )
        ORDER BY json_extract_string(e.value, '$.skill')
    ) AS skills
FROM 
    raw_json, 
    json_each(skills_json) AS e;



-- Arrays - Final Example
-- Build a flat skill table for co-workers to access job titles, salary info, and skills in one table
-- Put the Skills from skills_dim table into an array
CREATE OR REPLACE TEMP TABLE job_skills_array AS
SELECT
    jpf.job_id,
    jpf.job_title_short,
    jpf.salary_year_avg,
    ARRAY_AGG(sd.skills ORDER BY sd.skills) AS skills_array
FROM job_postings_fact jpf
LEFT JOIN skills_job_dim sjd ON jpf.job_id = sjd.job_id
LEFT JOIN skills_dim sd ON sjd.skill_id = sd.skill_id
GROUP BY ALL;

-- From the perspective of a Data Analyst, analyze the median salary per skill
WITH flat_skill AS(
    SELECT
        job_id,
        job_title_short,
        salary_year_avg,
        UNNEST(skills_array) AS skills
    FROM job_skills_array
    --WHERE salary_year_avg IS NOT NULL
)
SELECT
    skills,
    MEDIAN(salary_year_avg) AS median_salary
FROM flat_skill
GROUP BY skills
ORDER BY median_salary DESC;

    