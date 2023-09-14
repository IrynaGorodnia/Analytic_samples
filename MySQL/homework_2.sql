USE employees;

/* 1. For the current maximum annual wage in the company SHOW the full name of the
employee, department, current position, for how long the current position is held, and
total years of service in the company.

Для полученой текущей максимальной годовой заработной платы в компании УКАЖИТЕ полное имя и фамилию
сотрудника, отдел, текущая должность, как долго занимает текущую должность, и
общий стаж работы в компании.
*/


/* вариант 1*/

WITH salary_all_staff AS
(   SELECT   s.*
        FROM `employees`.`salaries` AS s
       WHERE s.salary
 )
SELECT    s_s.emp_no,
          e.first_name,
          e.last_name,
          t_s.title,
          d_n.dept_name,
          TIMESTAMPDIFF(YEAR, t_s.from_date , curdate()) AS `work_in_dept`,
          TIMESTAMPDIFF(YEAR, e.hire_date , curdate())   AS `work_exp`
	  FROM salary_all_staff              AS s_s
INNER JOIN employees.employees           AS e     ON e.emp_no=s_s.emp_no
INNER JOIN employees.titles              AS t_s   ON s_s.emp_no=t_s.emp_no    AND t_s.to_date>curdate()
INNER JOIN employees.dept_emp            AS d     ON d.emp_no=t_s.emp_no      AND d.to_date>curdate()
 LEFT JOIN employees.departments         AS d_n   ON d.dept_no = d_n.dept_no
    WHERE (salary = (SELECT MAX( salary) 
					FROM salary_all_staff
					WHERE salary_all_staff.to_date > curdate()
					)) 
;
 
 
 /* вариант 2*/
WITH salary_all_staff AS
(   SELECT   s.*
        FROM `employees`.`salaries` AS s
       WHERE s.salary
 ),		
 title_of_staff AS
 (SELECT t.*, 
         CASE
		  WHEN t.to_date > curdate() OR t.to_date IS NULL THEN  TIMESTAMPDIFF(YEAR, t.from_date, curdate() ) 
		  ELSE  TIMESTAMPDIFF(YEAR, t.from_date , t.to_date)
	     END AS `work_in_dep`
    FROM titles AS t
)
SELECT    s_s.emp_no,
          e.first_name,
          e.last_name,
          t_s.title,
          d_n.dept_name,
          t_s.work_in_dep,
          we.`work_exp`
FROM salary_all_staff                    AS s_s
INNER JOIN employees.employees           AS e     ON e.emp_no=s_s.emp_no
INNER JOIN title_of_staff                AS t_s   ON s_s.emp_no=t_s.emp_no    AND t_s.to_date>curdate()
INNER JOIN employees.dept_emp            AS d     ON d.emp_no=t_s.emp_no      AND d.to_date>curdate()
 LEFT JOIN  employees.departments        AS d_n   ON d.dept_no = d_n.dept_no
INNER JOIN (SELECT     t_o_s.emp_no, 
                       SUM(t_o_s.`work_in_dep`) AS `work_exp`
				 FROM title_of_staff AS t_o_s
		     GROUP BY t_o_s.emp_no)        AS we  ON we.emp_no=s_s.emp_no
    WHERE salary = (SELECT MAX( salary) 
					FROM salary_all_staff
					WHERE salary_all_staff.to_date > curdate()
					)
  ;
  


/*2. For each department, show its name and current manager’s name, last name, and
current salary

Для каждого отдела укажите его название и имя, фамилию и текущую зарплату руководителя.
*/

   SELECT 
	    department.dept_name,
	    staff_head.first_name, 
	    staff_head.last_name, 
	    salary.salary  
	  FROM employees.departments    AS department
INNER JOIN employees.dept_manager   AS manager     ON department.dept_no = manager.dept_no AND manager.to_date > curdate()
INNER JOIN employees.employees      AS staff_head  ON staff_head.emp_no = manager.emp_no
LEFT JOIN employees.salaries        AS salary      ON salary.emp_no = manager.emp_no       AND salary.to_date > curdate()   
;
/*3. Show for each employee, their current salary and their current manager’s current salary.
Покажите для каждого сотрудника его текущую зарплату и текущую зарплату его текущего руководителя.
*/
WITH salary_all_staff AS
(   SELECT e.*,
           s.salary
       FROM `employees`.`employees` AS e
 INNER JOIN `employees`.`salaries`  AS s ON s.emp_no  = e.emp_no     AND s.to_date > curdate()
 )
SELECT 		salary_staff.emp_no,
			salary_staff.first_name, 
			salary_staff.salary     AS 'salary_staff',
			salary_head.salary      AS 'salary_head'
	   FROM salary_all_staff        AS salary_staff
INNER JOIN employees.dept_emp       AS dept_staff  	ON salary_staff.emp_no = dept_staff.emp_no  AND dept_staff.to_date > curdate()      
INNER JOIN employees.dept_manager   AS head_dept	ON dept_staff.dept_no = head_dept.dept_no   AND head_dept.to_date > curdate() 
INNER JOIN salary_all_staff         AS salary_head  ON head_dept.emp_no = salary_head.emp_no 
;
 
   
 
/* 4. Show all employees that currently earn more than their managers.
Покажите всех сотрудников, которые в настоящее время зарабатывают больше, чем их руководители.
*/
WITH salary_all_staff AS
(   SELECT e.*,
           s.salary
       FROM `employees`.`employees` AS e
 INNER JOIN `employees`.`salaries`  AS s ON s.emp_no  = e.emp_no AND s.to_date > curdate()
 )
SELECT 		salary_staff.emp_no,
			salary_staff.first_name, 
			salary_staff.salary      AS 'salary_staff',
			salary_head.salary       AS 'salary_head'
	   FROM salary_all_staff         AS salary_staff  
       INNER JOIN employees.dept_emp AS dept_staff    ON salary_staff.emp_no = dept_staff.emp_no  AND dept_staff.to_date > curdate()      
INNER JOIN employees.dept_manager    AS head_dept     ON dept_staff.dept_no = head_dept.dept_no   AND head_dept.to_date > curdate() 
INNER JOIN salary_all_staff          AS salary_head   ON head_dept.emp_no = salary_head.emp_no    AND salary_head.salary < salary_staff.salary    
;
 
/*5. Show how many employees currently hold each title, sorted in descending order by the
number of employees.

Показать, сколько сотрудников в настоящее время занимают каждую должность, отсортированные в порядке убывания по
количеству сотрудников.
*/

SELECT
        title        AS 'TITLE OF DEPARTMENT',
        count(title) AS 'COUNT OF EMPLOE'
	FROM employees.titles
   WHERE titles.to_date > curdate()  -- OR titles.to_date IS NULL если считаем что есть там стоит NULL то он еще работает, то нужно добавить условие
GROUP BY titles.title
ORDER BY count(title) DESC
;


/*6. Show full name of the all employees who were employed in more than one department.
Укажите ФИО всех сотрудников, которые работали более чем в одном отделе
*/

SELECT	 dep.emp_no, 
		 CONCAT (staff.first_name,' ', staff.last_name) AS PERSON
	  FROM employees.dept_emp   AS dep 
INNER JOIN employees.employees  AS staff  ON dep.emp_no = staff.emp_no 
  GROUP BY dep.emp_no
    HAVING count(dep.emp_no)>1
;


/*7. Show the average salary and maximum salary in thousands of dollars for every year.
Покажите среднюю зарплату и максимальную зарплату в тысячах долларов за каждый год.
*/
SELECT 
        YEAR(from_date), 
        round(AVG(salary)/1000,2) AS avg_salary,
        round(max(salary)/1000,2) AS max_salary 
	FROM salaries 
GROUP BY YEAR(from_date)
;




/*8. Show how many employees were hired on weekends (Saturday + Sunday), split by
gender
Покажите, сколько сотрудников было принято на работу в выходные дни (суббота + воскресенье), с разбивкой по
пол
*/
SELECT  gender, 
	    count(gender) AS 'Quantity of Staff'
     FROM employees.employees
    WHERE DAYOFWEEK(employees.hire_date) = 1 OR DAYOFWEEK(employees.hire_date) = 7
 GROUP BY employees.gender 
;


/* 9. Fulfill the script below to achieve the following data:
Group all employees according to their age at January 1st, 1995 into four groups:
30 or younger, 31-40, 41-50 and older. Show average salary for each group and gender
(8 categories in total) Also add subtotals and grand total.

Выполните приведенный ниже сценарий, чтобы получить следующие данные:
Сгруппируйте всех сотрудников в соответствии с их возрастом на 1 января 1995 года в четыре группы:
30 и моложе, 31-40, 41-50 и старше. Показать среднюю зарплату для каждой группы и пол
(всего 8 категорий) Также добавьте промежуточные итоги и общий итог.
*/


/*
SELECT CASE -- let’s create age categories first
WHEN (datediff('1995-01-01', employees.birth_date)THEN '30 and below'
...
END AS category,
...,
...
FROM employees e
INNER JOIN ...
WHERE ... -- filter out those employees, who were not employed at that date yet.
AND (SELECT MAX(to_date) FROM dept_emp de WHERE de.emp_no = e.emp_no
GROUP BY de.emp_no) > '1995-01-01' -- this subquery filters out employees,
-- who already left the company by that date (think
– about how it works)
GROUP BY ... ... ...; -- don’t forget to add totals
*/

SELECT 
       CASE 
         GROUPING (
				CASE WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') <= 30               THEN 'YoungerThen30'
					 WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01')   BETWEEN 31 AND 40 THEN 'Between31and40' 
					 WHEN TIMESTAMPDIFF(YEAR, e.birth_date, '1995-01-01') BETWEEN 41 AND 50 THEN 'Between41and50'
					 WHEN TIMESTAMPDIFF(YEAR, e.birth_date, '1995-01-01') >51               THEN 'OlderThen51' 
				 END )
          WHEN 1 THEN 'TOTAL' 
          ELSE 
            (CASE WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') <= 30                  THEN 'YoungerThen30'
	              WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01')      BETWEEN 31 AND 40 THEN 'Between31and40' 
				  WHEN TIMESTAMPDIFF(YEAR, e.birth_date, '1995-01-01')    BETWEEN 41 AND 50 THEN 'Between41and50'
				  WHEN TIMESTAMPDIFF(YEAR, e.birth_date, '1995-01-01') >51                  THEN 'OlderThen51' 
			  END )
		  END                  AS `group`,
        
        CASE 
          GROUPING (e.gender)
          WHEN 1 THEN 'TOTAL'
          ELSE e.gender 
		END AS gender,
        
        AVG(s.salary)         AS `salary_avg`
        
  FROM employees.employees   AS e
  INNER JOIN salaries        AS s ON s.emp_no=e.emp_no
		WHERE e.hire_date >'1995-01-01'
		 AND (SELECT MAX(de.to_date) 
			    FROM dept_emp de 
			   WHERE de.emp_no = e.emp_no
			  GROUP BY de.emp_no) > '1995-01-01'
   GROUP BY CASE WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01') <= 30                   THEN 'YoungerThen30'
				 WHEN TIMESTAMPDIFF(YEAR, birth_date, '1995-01-01')       BETWEEN 31 AND 40 THEN 'Between31and40' 
				 WHEN TIMESTAMPDIFF(YEAR, e.birth_date, '1995-01-01')     BETWEEN 41 AND 50 THEN 'Between41and50'
				 WHEN TIMESTAMPDIFF(YEAR, e.birth_date, '1995-01-01') >51                   THEN 'OlderThen51' 
			END ,
            e.gender WITH ROLLUP
  -- ORDER BY `group`
;



