/*1. Показать для каждого сотрудника его текущую зарплату и текущую зарплату
текущего руководителя.*/

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

/*2. Показать всех сотрудников, которые в настоящее время зарабатывают больше,
чем их руководители.*/

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


/*3. Из таблицы dept_manager первым запросом выбрать данные по актуальным
менеджерам департаментов и сделать свой столбец “checks” со значением ‘actual’.
Вторым запросом из этой же таблицы dept_manager выбрать НЕ актуальных
менеджеров департаментов и сделать свой столбец “checks” со значением ‘old’.
Объединить результат двух запросов через union.*/

SELECT d.*, 
	   'actual' AS checks
 FROM employees.dept_manager AS d
WHERE d.to_date>curdate()

UNION 

SELECT d.*, 
      'old'    AS checks
 FROM employees.dept_manager AS d
WHERE d.to_date<curdate()
;

/*4. К результату всех строк таблицы departments, добавить еще две строки со
значениями “d010”, “d011” для dept_no и “Data Base”, “Help Desk” для dept_name.*/
SELECT *
FROM employees.departments AS d
UNION
SELECT 'd010', 'Data Base'
UNION
SELECT 'd011', 'Help Desk'
ORDER BY dept_no
;

/*5. Найти emp_no актуального менеджера из департамента ‘d003’, далее через
подзапрос из таблицы сотрудников вывести по нему информацию.*/
SELECT e.*
  FROM employees.employees AS e
 WHERE e.emp_no = (SELECT  d.emp_no
					 FROM employees.dept_manager AS d
					WHERE d.dept_no ='d003'  AND d.to_date > curdate()
                    )
;

/*6. Найти максимальную дату приема на работу, далее через подзапрос из таблицы
сотрудников вывести по этой дате информацию по сотрудникам.*/

WITH employees_info AS
(SELECT *
 FROM employees.employees AS employee
)
SELECT *
  FROM  employees_info AS e
 WHERE e.hire_date = (SELECT 
					         max(e_i.hire_date)
					   FROM employees_info     AS e_i
                       )
;

