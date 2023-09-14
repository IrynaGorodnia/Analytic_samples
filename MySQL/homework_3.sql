/*
1.For the current maximum annual wage in the company SHOW the full name of an employee, department, current position, 
for how long the current position is held, and total years of service in the company.USE common table expression this time

Для текущей максимальной годовой зарплаты в компании УКАЖИТЕ полное имя сотрудника, отдел, текущую должность, 
как долго занимает текущую должность, и общий стаж работы в компании. На этот раз используйте обычное табличное выражение
*/


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
 
  
/*
2.From MySQL documentation check how ABS() function works. https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html#function_abs
Из документации MySQL проверьте, как работает функция ABS(). https://dev.mysql.com/doc/refman/8.0/en/mathematical-functions.html#function_abs
*/


/*
3.Show all information about the employee, salary year, and the difference between salary and average salary in the company overall. 
For the employee, whose salary was assigned latest from salaries that are closest to mean salary overall (doesn’t matter higher or lower).
Here you need to find the average salary overall and then find the smallest difference of someone’s salary with an average salary

Покажите всю информацию о сотруднике, год выплаты и разницу между зарплатой и средней зарплатой в целом по компании. 
Для сотрудника, чья зарплата была назначена последней из зарплат, наиболее близких к средней зарплате в целом (неважно, выше или ниже).
Здесь нужно найти среднюю зарплату в целом, а затем найти наименьшую разницу чьей-то зарплаты со средней зарплатой
*/

 SELECT @salaries:= min(ABS(s.salary-(SELECT AVG(s1.salary)
										FROM employees.salaries AS s1 
									 )
                            )
                        ) 
  FROM employees.salaries AS s
;

WITH d_s AS
(SELECT s.* 
  FROM employees.salaries AS s
 WHERE @salaries = ABS(s.salary-(SELECT AVG(s1.salary)
								   FROM employees.salaries AS s1 
                                 )
					  )
 )
      SELECT e.emp_no,
	         concat(e.first_name, ' ',e.last_name) AS 'name and last name',
             e.gender,
             e.hire_date,
             YEAR(d_s.from_date),
		     @salaries AS 'betweens AVG and salary of staff'
	   FROM d_s
 INNER JOIN employees.employees AS e ON e.emp_no=d_s.emp_no      
      WHERE d_s.from_date = (SELECT max(d1.from_date) 
							   FROM d_s AS d1
                             )            
;

/*
4.Select the details, title, and salary of the employee with the highest salary who is not employed in the company anymore.
Выберите данные, должность и оклад сотрудника с самой высокой зарплатой, который больше не работает в компании. 
*/
   
    
WITH staff_titles AS
(SELECT  title.*
  FROM employees.titles     AS title
),
salary_staff AS
(SELECT salary.*
FROM employees.salaries AS salary
)
    SELECT salary_all.emp_no,
	--       title_not_all.title,
           salary_all.salary,
           salary_all.*, title_not_all.*
      FROM salary_staff AS salary_all
INNER JOIN staff_titles AS title_not_all ON title_not_all.emp_no=salary_all.emp_no AND title_not_all.to_date = salary_all.to_date
	 WHERE salary_all.salary = (   SELECT max(s.salary)
									  FROM salary_staff   AS s
					            INNER JOIN (  SELECT  t.*  
									            FROM staff_titles              AS t
									        GROUP BY t.emp_no
											  HAVING max(t.to_date)<curdate()) AS e ON e.emp_no=s.emp_no                        
								)  
		AND salary_all.to_date < curdate()
;



/*
5.Show Full Name, salary, and year of the salary for top 	 (in absolute numbers). 
Also, attach the top 5 employees that have the highest one-time raise in salary (in percent).  
One-time rise here means the biggest difference between the two consecutive years

Укажите ФИО, размер оклада и год, за который он был повышен, для 5 лучших сотрудников, 
у которых было наибольшее единовременное повышение оклада (в абсолютных цифрах). 
Также прикрепите 5 лучших сотрудников, которые имеют наибольшее единовременное повышение зарплаты (в процентах).  
Единовременное повышение здесь означает наибольшую разницу между двумя последовательными годами
*/

-- Absolute difference
WITH emp_lead AS 
(
 SELECT s.*, LEAD(s.salary)OVER(PARTITION BY s.emp_no ORDER BY s.from_date) `next_year_salary`
   FROM `employees`.`salaries` s
)
SELECT res1.*
FROM (SELECT emp_lead.*, 
             IF(emp_lead.next_year_salary IS NULL, 0, emp_lead.next_year_salary-emp_lead.salary)  AS `dif_sal`
	    FROM emp_lead
	ORDER BY `dif_sal` DESC
       LIMIT 5 ) AS res1
UNION all 
SELECT res2.*
  FROM (SELECT emp_lead.*, 
               IF(emp_lead.next_year_salary IS NULL, 0, (emp_lead.next_year_salary/emp_lead.salary)*100-100)  AS `dif_sal`
          FROM emp_lead
	  ORDER BY `dif_sal` DESC
		 LIMIT 5) AS res2
;

/*
6.Generate a sequence of square numbers till 9 (1^2, 2^2... 9^2)
Сгенерируйте последовательность квадратных чисел до 9 (1^2, 2^2... 9^2)
*/

/* variant 1*/
WITH num_table AS
(
 SELECT @i := @i + 1            AS `row_number` 
 FROM employees, (select @i:=0) AS z 
 LIMIT 9
 )
SELECT 
  num_table.`row_number`*num_table.`row_number` AS 'square number'
FROM num_table
;

/* variant 2*/
SELECT @i := @i + 1             AS `row_number`,
	   @i*@i	                AS `square number`
 FROM employees, (select @i:=0) AS z 
 LIMIT 9;

/*variant 3*/

WITH RECURSIVE cte AS
(
  -- Постоянная часть
  SELECT 1 AS N
  UNION ALL
  -- Рекурсивная часть
  SELECT n + 1 FROM cte WHERE n < 9
)
SELECT c.n*c.n
  FROM cte AS c;

