// -------Guidance-------- 

// SELECT *: Will select all fields within a table 

// SELECT DISTINCT: Will return all unique values in a column(s).  

// AND/OR: Allows you to join multiple criteria to your WHERE statement so help filter the data correctly 

// LIKE: Can be used in your WHERE statement to find all values that have an element of the data you are looking for (ie. email LIKE ‘%effers%’ if you don’t know/want to write out the whole value or there are multiple values) 

// ORDER BY: To be used to sort the data. Can be ASC or DESC and can be layered (eg. ORDER BY Employee_ID, SNAPSHOT_DATE DESC to sort the data by employee and then their latest record 

// JOINS: This is how we join data from one table to another.  

  

// Counting 

  

SELECT 

    COUNT(DISTINCT employee_id) AS employee_count 

    FROM PRODUCTION.POSITIONS.WORKDAY_ALL_POSITIONS 

WHERE SNAPSHOT_DATE = '2026-01-06'; 

  

  

//--------select distinct-------- 

// counting 

  

select count(distinct employee_id) as employee_count 

from scratch.people_analytics.dim_exec_org  

; 

  

// if I want to do distinct employee ID's, but use all the data:  

SELECT * 

FROM scratch.people_analytics.dim_exec_org 

QUALIFY ROW_NUMBER() OVER ( 

  PARTITION BY employee_id 

  ORDER BY employee_id 

) = 1; 

  

  

  

 

// --------------------- 

  

//1: identify the correct job families (and what they are called in Snowflake): 

  

select distinct job_family_cleaned 

from PRODUCTION.POSITIONS.WORKDAY_ALL_POSITIONS 

Order by job_family_cleaned 

; 

  

// 2: Build a basic query for sharing with your LLM:  

  

select employee_id,employee_type,job_family_cleaned, 

hire_date,termination_date,snapshot_date 

from production.positions.workday_all_positions 

where snapshot_date = '2026-01-20' 

and employee_id is not null 

and snapshot_date is not null 

and employee_type = 'Permanent' 

; 

 

// ----------------- 

 

 

// creates (or replaces) a view 

// pulls data from WORKDAY_ALL_POSITIONS 

// MAX(snapshot_date) OVER () finds the latest date in the table 

// QUALIFY snapshot_date = ... keeps only rows from that latest snapshot 

// Result:  👉 the view always shows the most recent Workday snapshot only. 

 

create or replace view SCRATCH.PEOPLE_ANALYTICS.V_WORKDAY_EMPLOYEE_SNAPSHOT_LATEST as select  

snapshot_date,  

employee_id 

from PRODUCTION.POSITIONS.WORKDAY_ALL_POSITIONS  

qualify snapshot_date = max(snapshot_date) over (); 

 

 

-- 

 

    LOWER(termination_type) 
    → converts text to lowercase 
    → so 'Settlement', 'SETTLEMENT', 'settlement' all match 

    LIKE '%settlement%' 
    → checks if the word settlement appears anywhere 

 

 

 

/* normalize termination type: treat settlements as involuntary  

BELOW IS COPY FROM CHAT GPT explanation:  

 

  Case 

    when lower(termination_type) like '%settlement%' then 'Involuntary' 
    Finds anything containing “settlement” (any casing) and relabels it as Involuntary. 

    when termination_type in ('Voluntary', 'Involuntary') then termination_type 
    Allows only those two values unchanged. 

    when termination_type is null then null 
    Keeps blanks as blanks. 

    else termination_type 
    Everything else (unexpected values) passes through unchanged instead of being dropped. 

    end as termination_type_norm 
    Closes the logic and names the new column termination_type_norm.  */ 

 

 

/* we are basically slightly adjusting our data - we will still have the old column, but below will just organise it - can be like specific ethnicity -> we organise it into GEM and White 

case 

when lower(column_name) like '%text incl this word%' then 'New Name' 

when column_name in ('First option we use', 'Second Option we use') then column_name 

when column_name is null then null    // this part just keeps any blanks as blanks 

else column_name    // this part will allow any other options to also appear 

end as column_name_updated,  */ 

 

 

------ 

/* 

COALESCE(a, b)  

 

If a is NULL → use b. 

Returns the first non-NULL value. 

*/ 

 

---- 

