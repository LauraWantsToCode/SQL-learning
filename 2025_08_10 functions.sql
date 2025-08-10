-- Find the numbers of employees - counts how many entries in the database (not a sum)
select count(emp_id)
from employee;

-- Find the number of female employees born after 1970
select count(emp_id)
from employee
  where sex = 'F' and birth_day > '1970-01-01';


-- Find the average of all employee's salaries
select avg(salary)
from employee;

-- Find the average of all men employee's salaries 
select avg(salary)
from employee
  where sex = 'M';

-- Find the sum of all employee's salaries
select sum(salary)
from employee;


-- Find out how many males and females there are [the below formula 'count' would show how many entries have sex added]
select count(sex)
from employee;

-- Find out how many males and females there are [display how many males and females]
select count(sex), sex
from employee
  group by sex;


-- Find the total sales for each salesperson
select sum(total_sales), emp_id
from works_with
  group by emp_id;


-- Find the total money each client spent
select sum(total_sales), client_id
from works_with
  group by client_id;