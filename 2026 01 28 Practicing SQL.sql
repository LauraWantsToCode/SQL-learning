// ---------- SELECT / FROM / WHERE / LIKE / ORDER BY ----------------- 

  

// all records with employee with Murzi in the name 

select * 

FROM PRODUCTION.POSITIONS.WORKDAY_ALL_POSITIONS 

WHERE employee_name LIKE '%Murzi%' 

  

// all records with Murzi in last name 

select * 

FROM Production.workers.acq_workers 

WHERE last_name LIKE '%Murzi%' 

  

// all records with Murzi but also only 1st day of each month, rather than a daily snapshot 

select * 

FROM Production.workers.tfm_workers_history 

WHERE  

( 

    last_name LIKE '%Murzi%' 

    and day(snapshot_date) = 1  

  ) 

  order by snapshot_date asc 

  ; 

// my data is only from June 2025 here.  

  

  

// selecting only specific fields. from the snapshot dataset.  

// only People job fam.  

// only on a specific date 

// only non leavers 

select snapshot_date, is_active, worker_id, worker_type, worker, hire_date, probation_end_date, country, business_title, job_family, division, manager_name, termination_date, termination_reason, termination_regrettable, termination_type 

from production.workers.tfm_workers_history 

where 

( 

job_family like '%People%' 

and snapshot_date = '2026-01-01' 

and ( 

    termination_date is null 

    ) 

) 

order by is_active desc,  worker asc 

; 

// is job family group missing from records??  

// what about exec orgs -1 -2 in the dataset? do we not have this?  

// am I not looking at data from Snowflake reports from Prod??  

 

 

 

 

 

 

// ----------- when we need unique by worker id ------------- 

// so no duplicates on different snapshot dates, but with different joining and leaving dates 

  

  

// all employees we had at any point 

// below formula explained:  

// PARTITION BY worker_id <- group rows by employee 

// ROW_NUMBER() <-  number the rows within each employee 

// ORDER BY ... inside ROW_NUMBER() <- decide which employee row is kept, not which is removed 

  

select * 

from production.workers.tfm_workers_history 

WHERE snapshot_date <= CURRENT_DATE() 

qualify row_number() over( 

partition by worker_id 

order by snapshot_date desc 

) =1 

order by hire_date asc; 

 

 

 

// creating 'countifs' in here, using above table selection  

SELECT 

  SUM(CASE WHEN worker_type = 'Employee' THEN 1 ELSE 0 END) AS total_unique_employees, 

  SUM(CASE WHEN worker_type = 'Employee' AND is_active = TRUE THEN 1 ELSE 0 END) AS total_unique_active_employees, 

  SUM(CASE WHEN employee_type <> 'EOR' and worker_type = 'Employee' THEN 1 ELSE 0 END) AS total_unique_employees_NOT_EOR, 

  SUM(CASE WHEN employee_type <> 'EOR' and worker_type = 'Employee' AND is_active = TRUE THEN 1 ELSE 0 END) AS total_unique_active_employees_NOT_EOR, 

  SUM(CASE WHEN worker_type = 'Contingent Worker' THEN 1 ELSE 0 END) AS total_unique_contingent_workers, 

  SUM(CASE WHEN worker_type = 'Contingent Worker' AND is_active = TRUE THEN 1 ELSE 0 END) AS total_unique_active_contingent_workers 

FROM ( 

  SELECT * 

  FROM production.workers.tfm_workers_history 

  QUALIFY ROW_NUMBER() OVER ( 

    PARTITION BY worker_id 

    ORDER BY snapshot_date DESC 

  ) = 1 

); 

 

 

// can also try creating above but 'from' using snapshot date of yesterday.  

  

SELECT 

  SUM(CASE WHEN worker_type = 'Employee' THEN 1 ELSE 0 END) AS total_unique_employees, 

  SUM(CASE WHEN worker_type = 'Employee' AND is_active = TRUE THEN 1 ELSE 0 END) AS total_unique_active_employees, 

  SUM(CASE WHEN employee_type <> 'EOR' and worker_type = 'Employee' THEN 1 ELSE 0 END) AS total_unique_employees_NOT_EOR, 

  SUM(CASE WHEN employee_type <> 'EOR' and worker_type = 'Employee' AND is_active = TRUE THEN 1 ELSE 0 END) AS total_unique_active_employees_NOT_EOR, 

  SUM(CASE WHEN worker_type = 'Contingent Worker' THEN 1 ELSE 0 END) AS total_unique_contingent_workers, 

  SUM(CASE WHEN worker_type = 'Contingent Worker' AND is_active = TRUE THEN 1 ELSE 0 END) AS total_unique_active_contingent_workers 

FROM production.workers.tfm_workers_history 

where snapshot_date = '2026-01-19' 

; 

  

  

// checking all the columns 

  

select *  

from production.workers.acq_workers 

where is_active = True 

order by hire_date asc 

;  

  

  

// what's our active employee snapshot by groups?  

  

select  

SUM(CASE WHEN worker_type = 'Employee' THEN 1 ELSE 0 END) AS total_unique_employees, 

  SUM(CASE WHEN worker_type = 'Employee' THEN 1 ELSE 0 END) AS total_employees, 

  SUM(CASE WHEN employee_type <> 'EOR' and worker_type = 'Employee' THEN 1 ELSE 0 END) AS total_employees_not_EOR, 

  SUM(Case when employee_type = 'EOR' then 1 else 0 end) as total_eor, 

  SUM(CASE WHEN worker_type = 'Contingent Worker' THEN 1 ELSE 0 END) AS total_contingent_workers, 

  max (rec_updated_at) as last_data_upload_date 

from production.workers.acq_workers 

where is_active = True 

;  

 

 

// JOINS 

// create a join and check gender? maybe - active employees today, full name, role, gender, ethnicity  

  

select  

prodworker.worker_id, prodworker.worker_type, prodworker.employee_type, prodworker.worker,  

prodworker.hire_date, prodworker.level, prodworker.country, prodworker.job_title, scratchdemo.org_level_1, 

scratchdemo.org_level_2, scratchdemo.org_level_3, scratchdemo.org_level_4, scratchdemo.gender, 

scratchdemo.global_majority 

from  

production.workers.acq_workers as prodworker 

join 

scratch.people_analytics.additional_demographics_clean as scratchdemo 

on prodworker.worker_id = scratchdemo.employee_id 

where scratchdemo.snapshot_date = '2025-10-31' 

order by prodworker.worker_type desc, prodworker.hire_date asc 

; 

  

// testing scratch report to see what date it's on, as above initially didn't work.  

select *  

from scratch.people_analytics.additional_demographics_clean 

order by snapshot_date desc 

; 

  

// INNER JOIN → only matching rows   - my above is an inner join, because it was not specified 

// LEFT JOIN → all rows from left table + matches from right 

// RIGHT JOIN → all rows from right table + matches from left 

// FULL JOIN → all rows from both, match when possible 

  

// below is a left join, so some data will be missing due to prod is today, scratch is 31-Oct.  

  

select  

prodworker.worker_id, prodworker.worker_type, prodworker.worker,  

prodworker.hire_date, prodworker.level, prodworker.country, scratchdemo.org_level_1, 

scratchdemo.org_level_2, scratchdemo.gender, 

scratchdemo.global_majority 

from  

production.workers.acq_workers as prodworker 

left join 

scratch.people_analytics.additional_demographics_clean as scratchdemo 

on prodworker.worker_id = scratchdemo.employee_id 

where scratchdemo.snapshot_date = '2025-10-31' 

order by prodworker.worker_type desc, prodworker.hire_date asc 

; 

// XX records above.  

  

select  *  

from production.workers.acq_workers 

; 

//(TOO MANY) records above 

// tables don't match records even on left join because  

// For rows where there’s no match in scratchdemo, all scratchdemo.* values are NULL,  

// so scratchdemo.snapshot_date = ... is false and those rows get dropped. 

  

// to keep all records from the first table, we also need to add in:  

// we replace 'where' with 'and'  

 

select  

prodworker.worker_id, prodworker.worker_type, prodworker.worker,  

prodworker.hire_date, prodworker.level, prodworker.country, scratchdemo.org_level_1, 

scratchdemo.org_level_2, scratchdemo.gender, 

scratchdemo.global_majority 

from  

production.workers.acq_workers as prodworker 

left join 

scratch.people_analytics.additional_demographics_clean as scratchdemo 

on prodworker.worker_id = scratchdemo.employee_id 

and scratchdemo.snapshot_date = '2025-10-31' 

where prodworker.is_active = True 

order by prodworker.worker_type desc, prodworker.hire_date asc 

; 

// above brings XX records 

// and so does below - Yay, it works!  

select  *  

from production.workers.acq_workers 

where is_active = True 

; 

 

// ---------------------------------------------- 

 

 
