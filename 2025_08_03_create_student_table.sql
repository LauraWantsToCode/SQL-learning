create table student ( 
  student_id INT AUTO_INCREMENT, 
  name VARCHAR(20), 
  major VARCHAR(20) DEFAULT 'undecided', 
  Primary key(student_id) 
);  

  
INSERT INTO student(name, major) VALUES('Jack', 'Biology'); 
INSERT INTO student(name, major) VALUES('Kate', 'Sociology'); 
INSERT INTO student(name, major) VALUES('Claire', 'Chemistry'); 
INSERT INTO student(name, major) VALUES('Jack', 'Biology'); 
INSERT INTO student(name, major) VALUES('Mike', 'Computer Science'); 


UPDATE student 
SET major = 'Biochemistry' 
WHERE major = 'Biology' OR major = 'Chemistry';


delete from student
WHERE student_ID = 5;


drop table student;


Select * from student;

