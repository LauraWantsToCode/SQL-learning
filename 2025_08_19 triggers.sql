-- for example, if a row gets deleted from a table,
-- we get an insert - using a trigger
-- we are creating a table for it (doesn't have to be a table)


-- before all this, we need to change the sql delimiter 
-- this is done inside of the terminal [windows]

-- can use this to connect: mysql -u root -p

create table trigger_test (
  message varchar(100)
);

-- below: before something gets inserted on employee table
-- for each of new items, i want to insert into trigger test table 
-- we are basically changing the delimiter to $$ from the usual ; 
-- this is to make sure SQL actually created the below line with ;
-- we will end delimiter with $$, and change back to ; 
-- this has to be done in MySQL, as pop SQL or Beekeeper wouldnt change delimiter.
-- below would be pasted into mySQL in 3 parts (separated with --)


delimiter $$
  --
create 
trigger my_trigger before insert
on employee
for each row begin
insert into trigger_test values('added new employee'); 
end $$
  --
delimiter; 

-- a trigger would then be set up. 
-- testing by adding another employee

insert into employee
values (109, 'Oscar', 'Martinez', '1968-02-19', 'M', 69000, 106, 3);

select * from trigger_test; 

-- other things we can do with triggers
-- same as above but changed to values(new.first_name)

delimiter $$
create 
trigger my_trigger1 before insert
on employee
for each row begin
insert into trigger_test values(new.first_name); 
end $$
delimiter;

-- this will show the message from the first trigger and then name from the second

-- can also use conditionals 

create
trigger my_trigger2 before insert
on employee
for each row begin
if new.sex = 'M' then
insert into trigger_test values('added male employee'); 
elseif new.sex = 'F' then
insert info trigger_test values('added female'); 
else
insert into trigger_test values('added other employee'); 
end if;

-- we created triggers for INSERT
-- but can also do for update or delete 
-- can isert before or after

-- we could drop a trigger in the terminal by saying drop trigger -name-

