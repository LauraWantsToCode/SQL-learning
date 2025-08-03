select *
from student; 

select student.name, student.major
from student
order by name desc;


select *
from student
order by student_id asc;

select *
from student
order by major, student_id;

select *
from student
limit 2;


select *
from student
Where major = 'Biology' or major = 'Biochemistry';

-- can also use different symbols instead of = (<,>,<=,>=, <>, AND, OR)

select *
from student
Where major <> 'Biochemistry';

select *
from student
Where name IN ('Claire', 'Kate', 'Mike') and student_id > 2;

