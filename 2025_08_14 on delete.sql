-- On Delete 

--Deleting foreign keys.  
--Imagine we have employee tables and deleted one of the employees -  
--Especially the one who's a manager for a branch.  
--What would happen to the manager id? It links us to employee table.  

--If empl Id is no longer in the employee table.  
 
--We need these when defining foreign key relationships between tables.  


--On delete set null / on delete cascade 
 

--When to use:  

  --  On delete set null 

   --     When data is just a foreign key and not a primary key – mgr id for branch table is not essential.  

 --   on delete cascade 

  --      Foreign key is also part of the primary key. It doesn't make sense to have suppliers for a branch if a branch doesn’t exist. Primary key can't be null.  

 

--On delete set null 

 

-- when we created a branch table, we also set 'on delete set null' 
-- if the empl id in empl table gets deleted - we want to set the 
-- manager id to null.

CREATE TABLE branch ( 
  branch_id INT PRIMARY KEY, 
  branch_name VARCHAR(40), 
  mgr_id INT,
  mgr_start_date DATE, 
  FOREIGN KEY(mgr_id) REFERENCES employee(emp_id) ON DELETE SET NULL 
); 


   -- -when we delete the empl below, the tables are affected as per  -> 

 

delete from employee 
where emp_id = 102; 
  
-- the above has affected the branch, so we view what it looks like now 

select * from branch; 


-- it has also affected employee table where the person was managing others birth_day 
-- it's now null

select * from employee; 

---  

--CASCADE 
 

CREATE TABLE branch_supplier ( 
  branch_id INT, 
  supplier_name VARCHAR(40), 
  supply_type VARCHAR(40), 
  PRIMARY KEY(branch_id, supplier_name), 
  FOREIGN KEY(branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE 
);

-- within branch_supplier table, we used on delete cascade  
-- if the branch_id is deleted, the whole row gets deleted 
-- if we would delete the branch 2, the rows in branch supplier would be deleted too.  
  

delete from branch  
where branch_id = 2; 

select * from branch_supplier; 


-- all branch 2 is now removed.