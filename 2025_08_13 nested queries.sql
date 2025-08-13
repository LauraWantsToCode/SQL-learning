-- Nested query - a query where we will be using multiple select statements to get specific info

-- Find names of all employees who have
-- sold over 30,000 to a single client

select works_with.emp_id 
from works_with 
where works_with.total_sales > 30000;

-- we will use the above to be nested in another query below, that has other data we need 

select employee.first_name, employee.last_name 
from employee 
where employee.emp_id IN (
  select works_with.emp_id 
  from works_with 
  where works_with.total_sales > 30000
  );


-- Find all clients who are handled by the branch 
-- that Michael Scott manages
-- Assume you know michael's ID

-- this time we add 'limit' in case Michael Scott managers a few branches, we have limited
-- answers to just one of his branches

select client.client_name
from client 
where client.branch_id = (
  select branch.branch_id
  from branch 
  where branch.mgr_id = 102
  limit 1
  );

