/*1. Отобразить информацию из таблицы сотрудников и через подзапрос добавить
его текущую должность.*/
SELECT e.*, 
		(SELECT t.title
		   FROM employees.titles AS t
           WHERE e.emp_no = t.emp_no AND t.to_date>curdate()
        ) AS title_current      
  FROM employees.employees AS e
;


/*2. Отобразить информацию из таблицы сотрудников, которые (exists) в прошлом
были с должностью 'Engineer'.*/
SELECT e.*
FROM employees.employees AS e
WHERE EXISTS (SELECT *
			    FROM employees.titles     AS t
               WHERE t.title ='Engineer' 
                 AND t.to_date<curdate() 
                 AND e.emp_no=t.emp_no
                 )
;

/*3. Отобразить информацию из таблицы сотрудников, у которых (in) актуальная
зарплата от 50 тысяч до 75 тысяч.*/

SELECT e.*
FROM employees.employees AS e
WHERE e.emp_no IN ( SELECT  s.emp_no
			          FROM employees.salaries     AS s
					 WHERE s.salary               BETWEEN  50000 AND 75000
                       AND s.to_date>curdate() 
                  GROUP BY s.emp_no
                  )
;

/*4. Создать копию таблицы employees с помощью этого SQL скрипта:
create table employees_dub as select * from employees;*/

CREATE TABLE IF NOT EXISTS employees_dub AS SELECT * FROM employees;

/*5. Из таблицы employees_dub удалить сотрудников которые были наняты в 1985
году.*/
SET SQL_SAFE_UPDATES = 0;

DELETE
FROM employees.employees_dub AS e
WHERE year(e.hire_date)=1985
;
SET SQL_SAFE_UPDATES = 1;

/*6. В таблице employees_dub сотруднику под номером 10008 изменить дату приема
на работу на ‘1994-09-01’.*/
SET SQL_SAFE_UPDATES = 0;
UPDATE employees_dub AS e
SET hire_date = '1994-09-01'
WHERE emp_no=10008
;
SET SQL_SAFE_UPDATES = 1;



/*7. В таблицу employees_dub добавить двух произвольных сотрудников.*/
INSERT employees.employees_dub
VALUES  (500000,'19791020','Gorod','Ira','F','20100502'),
		(500001,'19751225','Ostrov','Petr','M','20150731')
;
