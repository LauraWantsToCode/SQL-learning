-- Union is used to combine the results of multiple select statements

-- above two statements need to have the same amount of columns
-- have to have a similar data type

-- Find a list of employee and branch names
-- separately
select first_name
from employee; 

select branch_name
from branch;

-- union. use AS to rename the column, otherwise will show the first one's title. 
select first_name AS company_names
from employee
union
select branch_name
from branch
union 
  select client_name
from client; 


--find a list of all clients & branch supplier's names [suggested to prefix the 'client.' 
-- Before branch_id to make it clear. To make script more readable. 
select client_name, client.branch_id
from client
union 
select supplier_name, branch_supplier.branch_id
from branch_supplier;


-- Find a list of all money spent or earned by the company
select salary
from employee
union
select total_sales
from works_with; 
