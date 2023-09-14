/*1. В схеме employees, в таблице employees добавить новый столбец - lang_no (int).*/
USE employees;

ALTER TABLE employees.employees ADD COLUMN lang_no INT; 

/*2. Обновить столбец lang_no значением "1" для всех у кого год прихода на работу 1985 и
1988. Остальным значение сотрудникам обновить значение "2".*/
SET SESSION SQL_SAFE_UPDATES = 0;

START TRANSACTION; 
 
UPDATE employees.employees 
  SET employees.lang_no = 1 
WHERE YEAR(employees.hire_date) = 1985 OR YEAR(employees.hire_date) = 1988
;

UPDATE employees.employees 
  SET employees.lang_no = 2 
WHERE YEAR(employees.hire_date) <> 1985 AND YEAR(employees.hire_date) <> 1988
;
COMMIT;

SET SESSION SQL_SAFE_UPDATES = 1;
 

/*3. В схеме tempdb, создать новую таблицу language с двумя полями lang_no (int) и
lang_name (varchar(3)).*/

CREATE DATABASE IF NOT EXISTS tempdb;

USE tempdb;

DROP TABLE IF EXISTS `tempdb`.`language`;
CREATE TABLE IF NOT EXISTS `tempdb`.`language` (
       lang_no       INT AUTO_INCREMENT PRIMARY KEY,   
       lang_name     VARCHAR(3)
) ENGINE=INNODB;

/*4. Добавить в таблицу tempdb.language две строки: 1 - ukr, 2 - rus.*/

START TRANSACTION;

INSERT INTO `tempdb`.`language`(lang_name )
VALUES 
	('ukr'),
    ('rus')
;

COMMIT;

/*5. Связать таблицы из схемы employees и tempdb чтобы показать всю информацию из
таблицы employees и один столбец lang_name из таблицы language (столбцы lang_no не
отображать).*/
SELECT e.emp_no, 
       e.birth_date,
       e.first_name,
       e.last_name,
       e.gender,
       e.hire_date,
       l.lang_name
FROM `employees`.`employees` AS e, 
     `tempdb`.`language`     AS l
WHERE l.lang_no = e.lang_no
;


/*6. На основе запроса из 5-го задания, создать вью employees_lang.*/
DROP VIEW IF EXISTS tempdb.employees_lang;

CREATE VIEW tempdb.employees_lang (emp_no, birth_date, first_name, last_name, gender, hire_date, lang_name)
AS SELECT e.emp_no, 
       e.birth_date,
       e.first_name,
       e.last_name,
       e.gender,
       e.hire_date,
       l.lang_name
FROM `employees`.`employees` AS e, 
     `tempdb`.`language`     AS l
WHERE l.lang_no = e.lang_no
;

/*7. Через вью employees_lang вывести количество сотрудников в разрезе языка.
*/

  SELECT   e_l.lang_name,
           count(e_l.lang_name) AS 'quantity of staff with lang'
	FROM tempdb.employees_lang as e_l
GROUP BY e_l.lang_name
;
