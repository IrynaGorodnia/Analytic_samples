/* 1.Отобразить сотрудников и напротив каждого, показать информацию о разнице
 текущей и первой зарплате.*/
USE  employees;
 
WITH  first_last_salary AS 
(SELECT s.emp_no, 
        s.from_date, 
		s.to_date, 
		FIRST_VALUE(s.salary) OVER (PARTITION BY s.emp_no ORDER BY s.from_date) AS first_salary, 
		s.salary AS last_salary 
  FROM employees.salaries AS s
)
    SELECT fls.emp_no,
           e.first_name,
           fls.last_salary-fls.first_salary 
	  FROM employees.employees AS e 
INNER JOIN first_last_salary AS fls ON (e.emp_no=fls.emp_no AND fls.to_date>curdate());       
       
 /*2.Отобразить департаменты и сотрудников, 
 которые получают наивысшую зарплату в своем департаменте.*/
 
SELECT dd.dept_name,
	   e.last_name,
       e.first_name,
       d_b.salary
FROM (
		  SELECT d.dept_no, 
                 s.emp_no, 
                 s.salary,
			     max(s.salary) OVER (PARTITION BY d.dept_no )  as max_sal
            FROM employees.salaries    AS s 
      INNER JOIN employees.dept_emp    AS d  ON (d.emp_no=s.emp_no AND d.to_date>curdate())
    		   WHERE s.to_date>curdate() ) AS d_b
INNER JOIN employees.employees   AS e  ON e.emp_no=d_b.emp_no
INNER JOIN employees.departments AS dd ON d_b.dept_no = dd.dept_no
WHERE d_b.salary = d_b.max_sal
;


 /*3.Из таблицы должностей, отобразить сотрудника с его текущей должностью и предыдущей.
 HINT OVER(PARTITION BY ... ORDER BY ... ROWS 1 preceding)*/

SELECT new_old_title.emp_no,
       new_old_title.title,
       new_old_title.title_previous
FROM  (
        SELECT  t.*,
		        LAG(t.title,1,t.title) OVER (PARTITION BY t.emp_no ORDER BY t.from_date ROWS 1 PRECEDING )  as title_previous
          FROM employees.titles AS t
		) AS new_old_title
WHERE new_old_title.to_date>curdate()
;
 
 /*4.Из таблицы должностей, посчитать интервал в днях -сколько прошло времени от первой 
 должности до текущей.*/
 SELECT new_title.emp_no,
        new_title.title,
        IF(new_title.max_date>curdate(), DATEDIFF(curdate(), new_title.min_date), DATEDIFF(new_title.max_date,new_title.min_date)) AS dif_in_days
 FROM (
       SELECT t.*, 
              min(t.from_date) OVER (PARTITION BY t.emp_no )  as min_date,
              max(t.to_date) OVER (PARTITION BY t.emp_no )  as max_date
         FROM employees.titles AS t
         ) AS new_title
WHERE new_title.to_date = new_title.max_date
 ;
 
 /*5.Выбрать сотрудников и отобразить их рейтинг по году принятия на работу.
 Попробуйте разные типы рейтингов.
 Как вариант можно SELECTс оконными функциями вставить как подзапрос 
 в FROM.SELECT subq.a-subq.bAS value_diff 
 FROM (SELECT a,FIRST_VALUE(col1) OVER(PARTITION BY ... ORDER BY ...) 
 AS bFROM table1) AS subq
 WHERE subq.date > now();SELECT subq.*, DATEDIFF(subq.c-subq.d) AS date_diff
 FROM (SELECT *,FIRST_VALUE(date_col1) OVER(PARTITION BY ... ORDER BY ...) AS d 
 FROM table1) AS subqWHERE subq.date > now()*/
 
 SELECT e.emp_no,
        e.hire_date, 
        RANK() OVER (ORDER BY YEAR(e.hire_date))         AS rnk ,
        DENSE_RANK() OVER (ORDER BY YEAR(e.hire_date))   AS dns_rnk, 
        PERCENT_RANK() OVER (ORDER BY YEAR(e.hire_date)) AS perc_rnk,  
        NTILE(15) OVER (ORDER BY YEAR(e.hire_date))      AS ntl 
   FROM employees.employees AS e 
;