USE employees;

-- 1. List all female employees who joined at 01/01/1990 or at 01/01/2000.
SELECT 
	*
FROM employees.employees
WHERE gender = 'F'
  AND (hire_date = '19900101' OR hire_date = '20000101')
ORDER BY hire_date asc	
;

-- 2. Show the name of all employees who have an equal first and last name
SELECT 
	first_name AS 'name of staff'
FROM employees.employees
WHERE first_name = last_name
;

-- 3. Show employees numbers 10001,10002,10003 and 10004, select columns first_name, last_name, gender, hire_date.
SELECT 
	emp_no, first_name, last_name, gender, hire_date
FROM employees.employees
WHERE emp_no = 10001 OR emp_no = 10002 OR emp_no = 10003 OR emp_no = 10004
;

-- 4. Select the names of all departments whose names have ‘a’ character on any position or ‘e’ on the second place.
SELECT 
	*
FROM employees.departments
WHERE dept_name LIKE '_e%' OR dept_name LIKE '%a%'  
  ;

-- 5. Show employees who satisfy the following description: He(!) was 45 when hired, born in October and was hired on Sunday. 
SELECT 
	 *
FROM employees.employees
WHERE TIMESTAMPDIFF(YEAR, birth_date, hire_date ) >= 45 AND MONTH(employees.birth_date) = 10 AND DAYOFWEEK(employees.birth_date) = 1
;

-- 6. Show the maximum annual salary in the company after 01/06/1995.
SELECT 
	MAX(salary)
FROM employees.salaries
WHERE  from_date > '19950601'
;

/* 7. In the dept_emp table, show the quantity of employees by department (dept_no). 
To_date must be greater than current_date. Show departments with more than 13,000 employees. Sort by quantity of employees.
*/

SELECT 
	 dept_no, count(DISTINCT emp_no)
FROM employees.dept_emp
WHERE to_date > curdate() 
GROUP BY dept_no 
HAVING count(emp_no) > 13000
ORDER BY count(emp_no) asc
;

-- 8. Show the minimum and maximum salaries by employee

SELECT 
	 emp_no,  MAX( DISTINCT salary),  MIN(DISTINCT salary)
FROM employees.salaries
GROUP BY emp_no
;


