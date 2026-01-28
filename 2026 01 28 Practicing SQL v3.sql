
// • Rehires: 

// • Can you create a list of all current rehires (use field and logic to identify from hire/termination dates) 

  

select worker_id, worker, worker_type, hire_date, termination_date, is_active 

from production.workers.acq_workers 

where is_active = TRUE 

and hire_date > termination_date 

order by hire_date asc 

; 

  

  

// • Can you create a table calculating the number of re-hires per month since january 2024? 

// need to do this from Scratch, not prod.  

// ----as I'll need to create a table or a view - using Scratch, rather than Production 

// below has a daily snapshot frm 2023 AUg.  

select * 

from scratch.people_analytics.org_snapshot_d 

; 

  

//testing if we have rehires 

select * 

from scratch.people_analytics.org_snapshot_d 

where is_rehire = True 

; 

  

// testing to see if it's showing rehires correctly. below does - raw list.  

SELECT * 

FROM ( 

  SELECT *, 

         ROW_NUMBER() OVER ( 

           PARTITION BY employee_id, hire_date 

           ORDER BY snapshot_date DESC 

         ) AS rn 

  FROM scratch.people_analytics.org_snapshot_d 

  WHERE snapshot_date >= '2024-01-01' 

    AND snapshot_date < '2026-01-22' 

    AND termination_date IS NOT NULL 

    AND hire_date > termination_date 

) 

WHERE rn = 1 

ORDER BY hire_date; 

  

  

  

//attempt  

  

create or replace view scratch.people_analytics.Laura_Rehires_per_month_2024 as  

select  

month_label, 

    sum( 

        case  

            WHEN termination_date IS NOT NULL 

            and hire_date > termination_date  

            then 1 else 0 

        end 

) as rehires_per_month 

from ( 

    select  

    to_varchar(date_trunc('month',hire_date),'Mon-YYYY') as month_label, 

    hire_date, 

    termination_date, 

            ROW_NUMBER() OVER ( 

              PARTITION BY employee_id, hire_date 

                ORDER BY snapshot_date DESC 

            ) AS rn 

  FROM scratch.people_analytics.org_snapshot_d 

where hire_date >= '2024-01-01' 

and hire_date < '2026-01-23' 

) 

where rn = 1 

group by month_label 

order by to_date(month_label, 'Mon-YYYY') 

; 

  

  

SELECT * 

FROM scratch.people_analytics.Laura_Rehires_per_month_2024; 

  

  

// ----------------------------------------------------- 

  

// • Can you create a calculation for % of staff rehired per month since 2024? 

// not sure I am clear on the question, so assuming it is % of rehires/all new hires 


/* will reuse the table above */ 

// the bit from to var char(round ... until 'as rehire_percentage' - both calculates %, but also  

// multiplies by 100 to make it into % 

// then trims to just one decimal point 

// and then adds the % icon so we know it's multiplied already 

  

CREATE OR REPLACE VIEW scratch.people_analytics.Laura_Rehires_percentage_per_month_2024 AS 

SELECT 

  month_label, 

  SUM(CASE WHEN termination_date IS NOT NULL AND hire_date > termination_date THEN 1 ELSE 0 END) AS rehires_per_month, 

  COUNT(*) AS new_hires_per_month, 

TO_VARCHAR( 

ROUND( 

100 * SUM(CASE WHEN termination_date IS NOT NULL AND hire_date > termination_date THEN 1 ELSE 0 END) 

/ NULLIF(COUNT(*), 0), 1) 

) || '%' AS rehire_percentage 

FROM ( 

  SELECT 

    TO_VARCHAR(DATE_TRUNC('MONTH', hire_date), 'Mon-YYYY') AS month_label, 

    hire_date, 

    termination_date, 

    ROW_NUMBER() OVER ( 

      PARTITION BY employee_id, hire_date 

      ORDER BY snapshot_date DESC 

    ) AS rn 

  FROM scratch.people_analytics.org_snapshot_d 

  WHERE hire_date >= '2024-01-01' 

    AND hire_date < '2026-01-23' 

) 

WHERE rn = 1 

GROUP BY month_label 

ORDER BY TO_DATE(month_label, 'Mon-YYYY'); 

  

  

  

SELECT * 

FROM scratch.people_analytics.Laura_Rehires_percentage_per_month_2024; 

  

// • Can you calculate which cost centers have the higher re-hire rate in the company? 

  

select *  

FROM scratch.people_analytics.master_dataset; 

  

CREATE OR REPLACE VIEW scratch.people_analytics.Laura_Rehires_percentage_CC AS 

SELECT 

  cost_centre, 

  SUM(CASE WHEN termination_date IS NOT NULL AND hire_date > termination_date THEN 1 ELSE 0 END) AS rehires, 

  COUNT(*) AS new_hires, 

  TO_VARCHAR( 

    ROUND( 

      100 * SUM(CASE WHEN termination_date IS NOT NULL AND hire_date > termination_date THEN 1 ELSE 0 END) 

      / NULLIF(COUNT(*), 0), 

      1 

    ) 

  ) || '%' AS rehire_percentage 

FROM ( 

  SELECT 

    cost_centre, 

    hire_date, 

    termination_date, 

    ROW_NUMBER() OVER ( 

      PARTITION BY employee_id, hire_date 

      ORDER BY snapshot_date DESC 

    ) AS rn 

  FROM scratch.people_analytics.master_dataset 

  WHERE hire_date >= '2024-01-01' 

    AND hire_date < '2026-01-23' 

) 

WHERE rn = 1 

GROUP BY cost_centre 

ORDER BY rehires desc; 

  

  

SELECT * 

FROM scratch.people_analytics.Laura_Rehires_percentage_CC; 


// Unrelated - PARTITION USE 

// generic example, not my data  

// How to think about it: 

// PARTITION BY → what you’re grouping (e.g. one employee) 

// ORDER BY → which row you keep (latest, earliest, highest, etc.) 

// rn = 1 → keep exactly one row per group 

  

SELECT * 

FROM ( 

  SELECT *, 

         ROW_NUMBER() OVER ( 

           PARTITION BY employee_id        -- what defines the entity (who) 

           ORDER BY snapshot_date DESC     -- how to choose the row (latest / earliest) 

         ) AS rn 

  FROM Data_Sheet 

) 

WHERE rn = 1;  

  

  

// • Can you create a field for time between leaving and being rehired? 

//division by 30.44 - to count in months. 365.25 days per year divided by 12 months is 30.44.  

  

  

SELECT snapshot_date, employee_id, employee_name, hire_date, termination_date, ROUND(DATEDIFF('day', termination_date, hire_date) / 30.44, 1) AS months_between_term_and_rehire 

FROM ( 

  SELECT *, 

         ROW_NUMBER() OVER ( 

           PARTITION BY employee_id 

           ORDER BY snapshot_date DESC 

         ) AS rn 

  FROM scratch.people_analytics.master_dataset 

  WHERE snapshot_date >= '2024-01-01' 

    AND snapshot_date < '2026-01-22' 

    and hire_date > termination_date 

    and is_rehire = TRUE 

) 

WHERE rn = 1 

ORDER BY months_between_term_and_rehire desc; 

  

  

  

  

// • Can you create a calculation for the average performance score of a re-hire Vs a hire 

// perf data 

// what do we mean by 'hires' - this is not possible, because new joiners won't have a rating, so including 'all' vs 'rehire'. 

  

select * 

from scratch.people_analytics.performance_data; 

  

select * 

from scratch.people_analytics.master_dataset;  

  

  

SELECT  * 

FROM ( 

  SELECT 

    perf.employee_id,    perf.preferred_name,    perf.active_status, perf.perf_2021_h1, perf.perf_2021_h2, perf.perf_2022,   perf.perf_2023,    perf.perf_2024,    emp.is_rehire, 

    ROW_NUMBER() OVER ( 

      PARTITION BY perf.employee_id 

      ORDER BY emp.snapshot_date DESC 

    ) AS rn 

  FROM scratch.people_analytics.performance_data AS perf 

  LEFT JOIN scratch.people_analytics.master_dataset AS emp 

    ON perf.employee_id = emp.employee_id 

) 

WHERE rn = 1; 


// changing perf reviews to numbers 

  

CREATE OR REPLACE VIEW scratch.people_analytics.Laura_perf_numbers AS 

SELECT 

  employee_id, 

  preferred_name, 

  active_status, 

  is_rehire, 

  

  CASE perf_2021_h1 

    WHEN 'Greatly Exceeds' THEN 5 

    WHEN 'Exceeds' THEN 4 

    WHEN 'Meets All' THEN 3 

    WHEN 'Meets Most' THEN 2 

    WHEN 'Partly Meets' THEN 1 

    ELSE NULL 

  END AS perf_2021_h1_num, 

  

  CASE perf_2021_h2 

    WHEN 'Greatly Exceeds' THEN 5 

    WHEN 'Exceeds' THEN 4 

    WHEN 'Meets All' THEN 3 

    WHEN 'Meets Most' THEN 2 

    WHEN 'Partly Meets' THEN 1 

    ELSE NULL 

  END AS perf_2021_h2_num, 

  

  CASE perf_2022 

    WHEN 'Greatly Exceeds' THEN 5 

    WHEN 'Exceeds' THEN 4 

    WHEN 'Meets All' THEN 3 

    WHEN 'Meets Most' THEN 2 

    WHEN 'Partly Meets' THEN 1 

    ELSE NULL 

  END AS perf_2022_num, 

  

  CASE perf_2023 

    WHEN 'Greatly Exceeds' THEN 5 

    WHEN 'Exceeds' THEN 4 

    WHEN 'Meets All' THEN 3 

    WHEN 'Meets Most' THEN 2 

    WHEN 'Partly Meets' THEN 1 

    ELSE NULL 

  END AS perf_2023_num, 

  

  CASE perf_2024 

    WHEN 'Greatly Exceeds' THEN 5 

    WHEN 'Exceeds' THEN 4 

    WHEN 'Meets All' THEN 3 

    WHEN 'Meets Most' THEN 2 

    WHEN 'Partly Meets' THEN 1 

    ELSE NULL 

  END AS perf_2024_num 

  

FROM ( 

  SELECT 

    perf.employee_id, 

    perf.preferred_name, 

    perf.active_status, 

    perf.perf_2021_h1, 

    perf.perf_2021_h2, 

    perf.perf_2022, 

    perf.perf_2023, 

    perf.perf_2024, 

    emp.is_rehire, 

    ROW_NUMBER() OVER ( 

      PARTITION BY perf.employee_id 

      ORDER BY emp.snapshot_date DESC 

    ) AS rn 

  FROM scratch.people_analytics.performance_data AS perf 

  LEFT JOIN scratch.people_analytics.master_dataset AS emp 

    ON perf.employee_id = emp.employee_id 

) 

WHERE rn = 1; 

  

  

SELECT * 

FROM scratch.people_analytics.Laura_perf_numbers 

LIMIT 50; 

  

// above gives me emp reviews as numbers.  

// now trying to put all in one table:  

  

CREATE OR REPLACE VIEW scratch.people_analytics.Laura_Rehires_perf_avg AS 

SELECT 

  -- 2021 H1 

  AVG(CASE WHEN is_rehire = FALSE THEN perf_2021_h1_num END) AS avg_2021_h1_non_rehire, 

  AVG(CASE WHEN is_rehire = TRUE  THEN perf_2021_h1_num END) AS avg_2021_h1_rehire, 

  

  -- 2021 H2 

  AVG(CASE WHEN is_rehire = FALSE THEN perf_2021_h2_num END) AS avg_2021_h2_non_rehire, 

  AVG(CASE WHEN is_rehire = TRUE  THEN perf_2021_h2_num END) AS avg_2021_h2_rehire, 

  

  -- 2022 

  AVG(CASE WHEN is_rehire = FALSE THEN perf_2022_num END)    AS avg_2022_non_rehire, 

  AVG(CASE WHEN is_rehire = TRUE  THEN perf_2022_num END)    AS avg_2022_rehire, 

  

  -- 2023 

  AVG(CASE WHEN is_rehire = FALSE THEN perf_2023_num END)    AS avg_2023_non_rehire, 

  AVG(CASE WHEN is_rehire = TRUE  THEN perf_2023_num END)    AS avg_2023_rehire, 

  

  -- 2024 

  AVG(CASE WHEN is_rehire = FALSE THEN perf_2024_num END)    AS avg_2024_non_rehire, 

  AVG(CASE WHEN is_rehire = TRUE  THEN perf_2024_num END)    AS avg_2024_rehire 

  

FROM scratch.people_analytics.Laura_perf_numbers 

; 

  

// below gives the answers, but not pretty 

SELECT * 

FROM scratch.people_analytics.Laura_Rehires_perf_avg 

; 

  

 // tidied table 

SELECT '2021 H1' AS perf_cycle, avg_2021_h1_rehire AS rehired_average_perf, avg_2021_h1_non_rehire AS not_rehired_average_perf 

FROM scratch.people_analytics.Laura_Rehires_perf_avg 

UNION ALL 

SELECT '2021 H2', avg_2021_h2_rehire, avg_2021_h2_non_rehire 

FROM scratch.people_analytics.Laura_Rehires_perf_avg 

UNION ALL 

SELECT '2022', avg_2022_rehire, avg_2022_non_rehire 

FROM scratch.people_analytics.Laura_Rehires_perf_avg 

UNION ALL 

SELECT '2023', avg_2023_rehire, avg_2023_non_rehire 

FROM scratch.people_analytics.Laura_Rehires_perf_avg 

UNION ALL 

SELECT '2024', avg_2024_rehire, avg_2024_non_rehire 

FROM scratch.people_analytics.Laura_Rehires_perf_avg; 
