/*1.В схеме tempdb создать таблицу dept_emp с делением по партициямпо полю from_date. 
Для этого:
•Из базы данных employees таблицы dept_emp → из Info-Tableinspector-DDL взять и
 скопировать код по созданиютой таблицы.
 •Убрать из DDL кода упоминаниепро KEYи CONSTRAINT.
 •И добавить код для секционирования по полю from_dateс 1985 года до 2002.
 Партиции по каждому году.
 HINT: 
 CREATE TABLE... PARTITION BY RANGE (YEAR(from_date)) (PARTITION...)
 */
 CREATE TABLE IF NOT EXISTS `tempdb`.`dept_emp` (
  `emp_no` int NOT NULL,
  `dept_no` char(4) NOT NULL,
  `from_date` date NOT NULL,
  `to_date` date NOT NULL
  ) 
  ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci
  PARTITION BY RANGE (YEAR(from_date)) (
    PARTITION p0  VALUES LESS THAN (1985),
    PARTITION p1  VALUES LESS THAN (1986),
    PARTITION p2  VALUES LESS THAN (1987),
    PARTITION p3  VALUES LESS THAN (1988),
    PARTITION p4  VALUES LESS THAN (1989),
   	PARTITION p5  VALUES LESS THAN (1990),
    PARTITION p6  VALUES LESS THAN (1991),
    PARTITION p7  VALUES LESS THAN (1992),
    PARTITION p8  VALUES LESS THAN (1993),
   	PARTITION p9  VALUES LESS THAN (1994),
    PARTITION p10 VALUES LESS THAN (1995),
   	PARTITION p11 VALUES LESS THAN (1996),
    PARTITION p12 VALUES LESS THAN (1997),
   	PARTITION p13 VALUES LESS THAN (1998),
   	PARTITION p14 VALUES LESS THAN (1999),
    PARTITION p15 VALUES LESS THAN (2000),
    PARTITION p16 VALUES LESS THAN (2001),
    PARTITION p17 VALUES LESS THAN (2002),
   	PARTITION p18 VALUES LESS THAN (MAXVALUE))
;
ALTER TABLE  `tempdb`.`dept_emp`
PARTITION BY RANGE (YEAR(from_date)) (
    PARTITION p0  VALUES LESS THAN (1985),
    PARTITION p1  VALUES LESS THAN (1986),
    PARTITION p2  VALUES LESS THAN (1987),
    PARTITION p3  VALUES LESS THAN (1988),
    PARTITION p4  VALUES LESS THAN (1989),
   	PARTITION p5  VALUES LESS THAN (1990),
    PARTITION p6  VALUES LESS THAN (1991),
    PARTITION p7  VALUES LESS THAN (1992),
    PARTITION p8  VALUES LESS THAN (1993),
   	PARTITION p9  VALUES LESS THAN (1994),
    PARTITION p10 VALUES LESS THAN (1995),
   	PARTITION p11 VALUES LESS THAN (1996),
    PARTITION p12 VALUES LESS THAN (1997),
   	PARTITION p13 VALUES LESS THAN (1998),
   	PARTITION p14 VALUES LESS THAN (1999),
    PARTITION p15 VALUES LESS THAN (2000),
    PARTITION p16 VALUES LESS THAN (2001),
    PARTITION p17 VALUES LESS THAN (2002),
   	PARTITION p18 VALUES LESS THAN (MAXVALUE)
);

START TRANSACTION;

INSERT INTO `tempdb`.`dept_emp`
SELECT *
FROM `employees`.`dept_emp`;

COMMIT;

 /*2.Создать индекс на таблицу tempdb.dept_emp по полю dept_no.*/
 CREATE INDEX index_dept_emp ON tempdb.dept_emp(dept_no); 
 
 /*3.Из таблицы tempdb.dept_emp выбрать данные толькоза 1990 год.*/
SELECT * 
  FROM tempdb.dept_emp AS d
 WHERE d.from_date BETWEEN '19900101' AND '19901231'
; 
 /*4.На основе предыдущего задания, через explain убедиться что сканирование данных идет
 только по одной секции. зафиксировать в видекомментария через/* вывод из explain*/
 /*HINT: EXPLAIN SELECT ... FROM ... WHERE ...*/
 
  EXPLAIN
SELECT * 
  FROM tempdb.dept_emp AS d
 WHERE d.from_date BETWEEN '19900101' AND '19901231'
 ;
 
 /*вывод из explain
 1	SIMPLE	d	p6	ALL					20045	11.11	Using where*/
 
 /*5.Загрузить свой любой CSV файл в схему tempdb.HINT: LOAD DATA INFILE ... INTO TABLE ...*/
SHOW VARIABLES LIKE "secure_file_priv";
 
CREATE TABLE IF NOT EXISTS tempdb.department like employees.departments;
 
LOAD DATA INFILE "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/homework_add_2.csv"  -- File path
     INTO TABLE tempdb.department -- Table which will be used as a container for the new data
     FIELDS TERMINATED BY ',' -- Columns separator
     ENCLOSED BY '"' -- Probable enclosing for the new data that may be used
     LINES TERMINATED BY '\n' -- Rows separator
     IGNORE 1 LINES -- Skip a number of rows
     (dept_no, dept_name)
;