/*1. Создать таблицу client с полями:
• clnt_no ( AUTO_INCREMENT первичный ключ)
• cnlt_name (нельзя null значения)
• clnt_tel (нельзя null значения)
• clnt_region_no*/

DROP TABLE IF EXISTS `client`;
CREATE TABLE IF NOT EXISTS `client` (
       clnt_no         INT AUTO_INCREMENT PRIMARY KEY,    
       cnlt_name       VARCHAR(255)  NOT NULL,                   
       clnt_tel        VARCHAR(13)  NOT NULL,
       clnt_region_no  INT
) ENGINE=INNODB;


/*2. Создать таблицу sales с полями:
• clnt_no (внешний ключ на таблицу client поле clnt_no; режим RESTRICT для
update и delete)
• product_no (нельзя null значения)
• date_act (по умолчанию текущая дата)*/

DROP TABLE IF EXISTS `sales`;
CREATE TABLE IF NOT EXISTS `sales` (
       clnt_no         INT ,    
       product_no      VARCHAR(10)  NOT NULL,                   
       date_act        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
       FOREIGN KEY (clnt_no) REFERENCES `client`(clnt_no)
       ON UPDATE RESTRICT ON DELETE RESTRICT
) ENGINE=INNODB;


/*3. Добавить 5 клиентов (тестовые данные на свое усмотрение) в таблицу client.*/
START TRANSACTION;

INSERT INTO `courses`.`client`(cnlt_name , clnt_tel, clnt_region_no)
VALUES 
      ('Keterina', '+380674258596', 10),
	  ('Lorena',   '+380968962685', 7),
      ('Olena',    '+380854265779', 14),
	  ('Anna',     '+34682398008', 10),
      ('Piedad',   '+34660606478', 12),
	  ('Nataly',   '+49550968472', 8)
;

/*4. Добавить по 2 продажи для каждого сотрудника (тестовые данные на свое
усмотрение ) в таблицу sales.*/

INSERT INTO `courses`.`sales`(clnt_no, product_no )
VALUES 
    (1, 'D00012'),
    (3, 'D00011'),
    (4, 'D00111'),
    (1, 'D00112'),
    (3, 'D00011'),
    (4, 'D00011')
;


/*5. Из таблицы client, попробовать удалить клиента с clnt_no=1 и увидеть ожидаемую
ошибку. Ошибку зафиксировать в виде комментария через /* ошибка */
DELETE FROM `courses`.`client` WHERE clnt_no=1;

/*Error Code: 1451. Cannot delete or update a parent row: 
a foreign key constraint fails (`courses`.`sales`, CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`clnt_no`) REFERENCES `client` (`clnt_no`) ON DELETE RESTRICT ON UPDATE RESTRICT)
*/

/*6. Удалить из sales клиента по clnt_no=1, после чего повторить удаление из client по
clnt_no=1 (ошибки в таком порядке не должно быть).*/
DELETE FROM `courses`.`sales` WHERE clnt_no=1;
DELETE FROM `courses`.`client` WHERE clnt_no=1;

COMMIT;

/*7. Из таблицы client удалить столбец clnt_region_no.*/
ALTER TABLE `courses`.`client` DROP COLUMN clnt_region_no; 

/*8. В таблице client переименовать поле clnt_tel в clnt_phone.*/
ALTER TABLE `courses`.`client`  RENAME COLUMN clnt_tel TO clnt_phone;

/*9. Удалить данные в таблице departments_dup с помощью DDL оператора truncate*/

/*создаем дубликат*/
CREATE TABLE IF NOT EXISTS employees.departments_dup SELECT* FROM employees.departments;

/*применяем truncate*/
TRUNCATE TABLE employees.departments_dup;
