SELECT table_name, column_name, data_type
FROM information_schema.columns
WHERE table_catalog LIKE 'data_jobs';

PRAGMA show_tables_expanded;
DESCRIBE job_postings_fact;