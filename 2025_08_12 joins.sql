-- Find all branches and the names of their managers

select employee.emp_id, employee.first_name, branch.branch_name
from employee 
join branch 
on employee.emp_id = branch.mgr_id;

-- left join - includes all people from the table on the left and adds the matching column data
select employee.emp_id, employee.first_name, branch.branch_name
from employee 
left join branch 
on employee.emp_id = branch.mgr_id;


-- right join - will incl everything from branch table no matter what
select employee.emp_id, employee.first_name, branch.branch_name
from employee 
right join branch 
on employee.emp_id = branch.mgr_id;


-- there is also a full outer join, but not possible in MySQL. COmbines full left and full right. 
-- it would be 'full join'