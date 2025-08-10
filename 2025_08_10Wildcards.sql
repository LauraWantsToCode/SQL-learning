-- Wildcards
-- Grab data that matches description
-- % = any # characters, _ = one character

-- Find any client's who are an LLC - client's name needs to match the pattern next to like in '' 
-- % means any number of characters
-- %LLC means any number of characters and LLC at the end
select *
from client
where client_name like '%LLC';


-- Find any employee born in October
-- Employee birth is in this format '1967-11-17' 
-- % represented any number of characters
-- _ represents one character
-- we will need to add 4 x _ to cover the year of birth, add -, then the month we need, and % at the end
select *
from employee
where birth_day like '____-02%'; 


-- Find any clients who are schools
-- do not leave spaces between the name and % if the name might be 'highschool', as there is no space before the word school
select *
from client
where client_name like '%school%';