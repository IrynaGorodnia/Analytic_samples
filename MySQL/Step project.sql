/* 1.Покажите среднюю зарплату сотрудников за каждый год 
(средняя заработная плата среди тех, кто работал в отчетный период -статистика с начала до 2005 года).*/

USE employees;

SELECT 
        YEAR(s.from_date)           AS `year`, 
        round(AVG(s.salary)/1000,2) AS avg_salary
   	FROM salaries AS s
   WHERE YEAR(s.to_date)<2005
GROUP BY YEAR(s.from_date)
ORDER BY `year`
;

/* 2.Покажите среднюю зарплату сотрудников по каждому отделу. Примечание: принять в расчет только текущие отделы и текущую заработную плату.*/
SELECT d.dept_no, 
	   AVG(s.salary) AS avg_salary
      FROM employees.dept_emp AS d
INNER JOIN employees.salaries AS s ON (d.emp_no=s.emp_no and s.to_date > curdate())
     WHERE d.to_date> curdate() 
 GROUP BY d.dept_no
;

/*3.Покажите среднюю зарплату сотрудников по каждому отделу за каждый год. 
Примечание: для средней зарплаты отдела X-в году Y нам нужно взять среднее значение всех зарплат в году Y сотрудников,
которые были в отделе X-в году Y.*/

SELECT   d.dept_no 			     AS `Numebr of Department`,
         d_n.dept_name			 AS `Department name`,
         YEAR(s.From_date)       AS `Year`, 
         round(AVG(s.salary),2)  AS `AVG_Salary`
      FROM employees.dept_emp 	 AS d
INNER JOIN employees.salaries    AS s   ON s.emp_no = d.emp_no
INNER JOIN employees.departments AS d_n ON d.dept_no = d_n.dept_no
  GROUP BY d.dept_no , YEAR(s.from_date)
  ORDER BY d.dept_no , YEAR(s.from_date)
;
/*4.Покажите для каждого года самый крупный отдел (по количеству сотрудников) в этом году и его среднюю зарплату.*/
/*вариант 1*/
WITH table_dep_year_sal AS
(    SELECT  d.dept_no 			    AS `Department`,
             YEAR(s.From_date)      AS `Years`, 
             count(d.emp_no)	    AS `Count_of_emp`,
			 round(AVG(s.salary),2) AS `AVG_Salary`
      FROM employees.dept_emp 	    AS d
INNER JOIN employees.salaries       AS s   ON s.emp_no = d.emp_no
  GROUP BY d.dept_no, YEAR(s.from_date)
  ORDER BY d.dept_no, YEAR(s.from_date)
 )
    SELECT 
            d_n.dept_name,
            t.Years,
            s.max_count,
            t.AVG_Salary
      FROM table_dep_year_sal AS t
INNER JOIN (SELECT
                    t1.Years             AS `year_max`, 
                    max(t1.Count_of_emp) AS `max_count`
	           FROM table_dep_year_sal   AS t1
           GROUP BY t1.Years 
           )                        AS s   ON (t.Years = s.year_max  AND  s.max_count = t.Count_of_emp)              
INNER JOIN employees.departments    AS d_n ON t.Department = d_n.dept_no           
;
 
/*вариант 2*/
WITH table_dep_year_sal AS
(    SELECT  d.dept_no 			    AS `Department`,
             YEAR(s.From_date)      AS `Years`, 
             count(d.emp_no)	    AS `Count_of_emp`,
			 round(AVG(s.salary),2) AS `AVG_Salary`
      FROM employees.dept_emp 	    AS d
INNER JOIN employees.salaries       AS s   ON s.emp_no = d.emp_no
  GROUP BY d.dept_no, YEAR(s.from_date)
  ORDER BY d.dept_no, YEAR(s.from_date)
 )
     SELECT  t_end.Department,
             t_end.Years,
             t_end.Count_of_emp,
             t_end.AVG_Salary
       FROM (
              SELECT t.*,
		             max(t.Count_of_emp) OVER (PARTITION BY t.Years)  as max_quantity
                FROM table_dep_year_sal AS t
            ) AS t_end
 INNER JOIN employees.departments AS d_n ON t_end.Department = d_n.dept_no
      WHERE t_end.max_quantity=t_end.Count_of_emp
   ORDER BY t_end.Years 
;

/*5.Покажите подробную информацию о менеджере, который дольше всех исполняет свои обязанности на данный момент.*/

 WITH table_dif AS
(
SELECT t.* , 
	   DATEDIFF(curdate(), t.from_date) AS `dif`
 FROM employees.titles AS t
WHERE t.title='Manager' and t.to_date > curdate() 
)
SELECT 
	        td.emp_no,
			e.last_name,
            e.first_name,
            e.gender,
            e.birth_date,
            s.salary
      FROM table_dif AS td
INNER JOIN  employees.employees AS e ON e.emp_no=td.emp_no 
INNER JOIN  employees.salaries  AS s ON (e.emp_no=s.emp_no   AND s.to_date>curdate())
     WHERE td.dif = (SELECT max(table_dif.dif)
				       FROM table_dif
                     )
;


/* любой сотрудник который дольше всех исполняет свои обязанности */
WITH table_dif AS
(
SELECT t.* , 
	   DATEDIFF(curdate(), t.from_date) AS `dif`
 FROM employees.titles AS t
WHERE t.to_date > curdate() 
)
  SELECT    td.emp_no,
			e.last_name,
            e.first_name,
            e.gender,
            e.birth_date,
            d.dept_no
       FROM table_dif AS td
 INNER JOIN  employees.employees AS e ON e.emp_no=td.emp_no 
 INNER JOIN  dept_emp            AS d ON (e.emp_no=d.emp_no   AND d.to_date > curdate())  /*через INNER JOIN можно получить всю инфо дальше*/
      WHERE td.dif = (SELECT max(table_dif.dif)
						FROM table_dif
                      )
 ;

/*6.Покажите топ-10 нынешних сотрудников компании с наибольшей разницей между их зарплатой и текущей средней зарплатой в их отделе.*/
SELECT  s.*, d.*,
		ABS(s.salary- avg(s.salary) OVER (PARTITION BY d.dept_no  )) AS `dif_sal`
      FROM employees.salaries AS s
INNER JOIN employees.dept_emp AS d ON (s.emp_no=d.emp_no AND d.to_date>curdate())
     WHERE s.to_date>curdate() 
  ORDER BY `dif_sal` DESC
     LIMIT 10
;

/*7.Из-за кризиса на одно подразделение на своевременную выплату зарплаты выделяется всего 500 тысяч долларов. 
Правление решило, что низкооплачиваемые сотрудники будут первыми получать зарплату. 
Показать список всех сотрудников, которые будут вовремя получать зарплату 
(обратите внимание, что мы должны платить зарплату за один месяц, но в базе данных мы храним годовые суммы). */

SELECT TABLE_with_sum.*
  FROM (
        SELECT
        TABLE_RES.*,
        SUM(TABLE_RES.salary_in_month) OVER (PARTITION BY TABLE_RES.dept_no ORDER BY TABLE_RES.salary_in_month) AS sum_salary_dep
         FROM (   SELECT s.*,
                         round(s.salary/12,2)  AS `salary_in_month`,
                         d.dept_no
                   FROM employees.salaries AS s
             INNER JOIN employees.dept_emp AS d ON (d.emp_no=s.emp_no AND d.to_date>curdate())
                  WHERE s.to_date>curdate() 
			  ) AS TABLE_RES
		) AS TABLE_with_sum
WHERE TABLE_with_sum.sum_salary_dep <=500000
;
/* Дизайн базы данных:*/

/*1.Разработайте базу данных для управления курсами. 
База данных содержит следующие сущности:
a.students: student_no, teacher_no, course_no, student_name, email, birth_date.
b.teachers: teacher_no, teacher_name, phone_no
c.courses: course_no, course_name, start_date, end_date.
●Секционировать по годам, таблицу students по полю birth_date с помощью механизма range
●В таблице students сделать первичный ключ в сочетании двух полей student_no и birth_date   
●Создать индекс по полю students.email
●Создать уникальный индекс по полю teachers.phone_no */

SET SESSION SQL_SAFE_UPDATES = 0;
  
-- Create a new database
CREATE DATABASE IF NOT EXISTS courses;

-- check database in list of database
SHOW DATABASES;

-- Choose a database context
USE courses;

-- Create a table to store information about the studens
DROP TABLE IF EXISTS students;
CREATE TABLE IF NOT EXISTS students (
       student_no    INT AUTO_INCREMENT,    
       teacher_no    INT DEFAULT 1,                   
       course_no	 INT DEFAULT 1,
       student_name  VARCHAR(255)  NOT NULL,
       email         VARCHAR(100)  NOT NULL, 
       birth_date    DATE NOT NULL,
       CONSTRAINT composite_pk PRIMARY KEY (student_no ,birth_date)
) ENGINE=INNODB;

ALTER TABLE courses.students
PARTITION BY RANGE (YEAR(birth_date)) (
    PARTITION p0 VALUES LESS THAN (1996),
    PARTITION p1 VALUES LESS THAN (2000),
    PARTITION p2 VALUES LESS THAN (2004),
    PARTITION p3 VALUES LESS THAN (2008),
    PARTITION p4 VALUES LESS THAN (2012),
	PARTITION p5 VALUES LESS THAN (MAXVALUE)
);

 -- ●Создать индекс по полю students.email
CREATE INDEX students_email ON students(email); 

 -- use for testing when need create new one, but when before need delete  
DROP TABLE IF EXISTS teachers;   

-- Create a table to store information about the teachers
CREATE TABLE IF NOT EXISTS teachers (
       teacher_no     INT AUTO_INCREMENT PRIMARY KEY,     /*объявила первичным ключем если там есть бизнес логика*/              
	   teacher_name   VARCHAR(255)  NOT NULL,
	   phone_no       VARCHAR(15)  NOT NULL
) ENGINE=INNODB;


-- ●Создать уникальный индекс по полю teachers.phone_no *
CREATE UNIQUE INDEX teachers_phone ON teachers(phone_no);  

DROP TABLE IF EXISTS courses;
CREATE TABLE IF NOT EXISTS courses (
       course_no      INT AUTO_INCREMENT PRIMARY KEY,         /*объявила первичным ключем если там есть бизнес логика*/                        
	   course_name    VARCHAR(255)  NOT NULL,
	   start_date     DATE, 
       end_date       DATE
) ENGINE=INNODB;

                        
/*2.На свое усмотрение добавить тестовые данные (7-10 строк) в наши три таблицы.*/
START TRANSACTION;

INSERT INTO `courses`.`teachers`(teacher_name, phone_no)
VALUES 
	  ('Keterina', '+380674258596'),
	  ('Lorena',   '+380968962685'),
      ('Olena',    '+380854265779'),
	  ('Anna',     '+34682398008'),
      ('Piedad',   '+34660606478'),
	  ('Nataly',   '+49550968472'),
      ('Diane',    '+33508496124'),
	  ('Silvia',   '+34859702563'),
      ('Daniel',   '+33859631148')
	;

      
INSERT INTO `courses`.`courses` (course_name, start_date, end_date)
VALUES 
	  ('English', '2022-05-08', '2022-08-08'),
	  ('Spanish', '2021-11-25', '2022-03-15'),
      ('German',  '2020-08-30', '2020-12-24'),
      ('English', '2022-04-07', '2022-06-12'),
	  ('Spanish', '2021-10-20', '2022-02-18'),
      ('German',  '2020-08-30', '2020-12-24'),
      ('English', '2022-05-08', '2022-08-08'),
	  ('Spanish', '2021-11-25', '2022-03-15'),
      ('German',  '2020-08-30', '2020-12-24')
;

INSERT INTO courses.students(teacher_no, course_no, student_name, email, birth_date)
VALUES 
	  (1, 4, 'Petrov Ivan',      'petrov_ivan@gmail.com','1979-10-20'),
      (4, 6, 'Ostrovskay Iryna', 'ostrov@yahoo.com',     '1976-12-24'),
      (5, 7, 'Kostya Olga',      'olga_k@yandex.ua',     '2005-11-10'),
      (1, 3, 'Gorod Petro', 	 'PGorod@gmail.com',     '2010-05-14'),
      (1, 4, 'Petrov Alex',      'alex_p@gmail.com',     '1979-10-20'),
      (2, 7, 'Sivanov Ivan',     'siv_ivan@gmail.com',   '1988-04-20'),
	  (2, 7, 'Petrov Ivan',      'petrov_ivan@gmail.com','1979-10-20')
 ;     
 
COMMIT;
/*3.Отобразить данные за любой год из таблицы students и зафиксировать в виду 
комментария план выполнения запроса, где будет видно что запрос будет выполняться по конкретной секции.*/

-- p1
EXPLAIN
SELECT * 
  FROM `courses`.`students` AS s
 WHERE s.birth_date BETWEEN '19970101' AND '19990101'
;
/* result of request 
1	SIMPLE	s	p1	ALL					1	100.00	Using where
*/

-- p0
EXPLAIN
SELECT * 
  FROM `courses`.`students` AS s
 WHERE s.birth_date <= '19860101'
;
/* result of request 
 1	SIMPLE	s	p0	ALL					5	33.33	Using where 
 */

/*4.Отобразить данные учителя, по любому одному номеру телефона и зафиксировать план выполнения запроса, где будет видно, 
что запрос будет выполняться по индексу, а не методом ALL.
Далее индекс из поля teachers.phone_no сделать невидимым и зафиксировать план выполнения запроса, где ожидаемый результат -метод ALL. 
В итоге индекс оставить в статусе -видимый. */
EXPLAIN
SELECT * 
  FROM `courses`.`teachers` AS t
 WHERE t.phone_no='+49550968472'
 ;
  /* result of request - where can see that use index correct
 '1', 'SIMPLE', 't', NULL, 'const', 'teachers_phone', 'teachers_phone', '62', 'const', '1', '100.00', NULL
 */

/* make index invisble */
ALTER TABLE `courses`.`teachers` ALTER INDEX teachers_phone INVISIBLE;
/* result of request - where can see that work without index, because it is invisible
1	SIMPLE	t		ALL					9	11.11	Using where
*/

/*return index status - visible*/
ALTER TABLE `courses`.`teachers` ALTER INDEX teachers_phone VISIBLE;


/*5.Специально сделаем 3 дубляжа в таблице students (добавим еще 3 одинаковые строки).*/
/* добавила дубликаты, но только student_no у них будут разные*/

/* вариант 1* ' когда добавляем строки с такими же данными кроме ключа*/
START TRANSACTION;

INSERT INTO courses.students(teacher_no, course_no, student_name, email, birth_date)
VALUES 
	  (1, 4, 'Petrov Ivan',      'petrov_ivan@gmail.com','1979-10-20'),
      (4, 6, 'Ostrovskay Iryna', 'ostrov@yahoo.com',     '1976-12-24'),
      (5, 7, 'Kostya Olga',      'olga_k@yandex.ua',     '2005-11-10')
 ;    

 /*вариант 2* - делаем дубликат таблицы и в него вносим 3 полных дубликата*/
CREATE TEMPORARY TABLE IF NOT EXISTS students_temp SELECT* FROM students;

INSERT INTO courses.students_temp(student_no, teacher_no, course_no, student_name, email, birth_date)
VALUES 
	  (1, 1, 4, 'Petrov Ivan',      'petrov_ivan@gmail.com','1979-10-20'),
      (2, 4, 6, 'Ostrovskay Iryna', 'ostrov@yahoo.com',     '1976-12-24'),
      (3, 5, 7, 'Kostya Olga',      'olga_k@yandex.ua',     '2005-11-10')
 ;    
 
COMMIT;

/*6.Написать запрос, который выводит строки с дубляжами */
/*увидим где был один и тот же человек внесен дважды*/
/* вариант 1* - из таблицы текущей ловит дубликаты, но там где номер студента разный а остальное совпадает*/
SELECT * 
  FROM (SELECT *, 
			  count(`rwn`)OVER(PARTITION BY teacher_no, course_no, student_name, email, birth_date) AS `cnt`
		 FROM (SELECT *, 
                      ROW_NUMBER()OVER(PARTITION BY teacher_no, course_no, student_name, email, birth_date) AS  `rwn`
			    FROM courses.students) q) s 
  WHERE `cnt` > 1
  ;
  
  
  /*вариант 2 - из временной таблицы ловит дубликаты*/
    SELECT * 
  FROM (SELECT *, 
			  count(`rwn`)OVER(PARTITION BY student_no, teacher_no, course_no, student_name, email, birth_date) AS `cnt`
		 FROM (SELECT *, 
                      ROW_NUMBER()OVER(PARTITION BY student_no, teacher_no, course_no, student_name, email, birth_date) AS  `rwn`
			    FROM courses.students_temp) q) s 
  WHERE `cnt` > 1
  ;
  
  
  SET SESSION SQL_SAFE_UPDATES = 1;