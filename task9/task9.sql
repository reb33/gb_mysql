# Практическое задание по теме “Транзакции, переменные, представления”
# В базе данных shop и sample присутствуют одни и те же таблицы, учебной базы данных. Переместите запись id = 1 из таблицы shop.users в таблицу sample.users. Используйте транзакции.
START TRANSACTION;
INSERT INTO sample.users
SELECT * FROM shop.users WHERE id=1;
DELETE FROM shop.users WHERE id=1;
COMMIT;
# Создайте представление, которое выводит название name товарной позиции из таблицы products и соответствующее название каталога name из таблицы catalogs.
DROP VIEW IF EXISTS shop.prods;
CREATE VIEW shop.prods AS
    SELECT p.name as prod_name, c.name as cat_name FROM shop.products p
    INNER JOIN shop.catalogs c on p.catalog_id = c.id;
SELECT * FROM shop.prods;
# (по желанию) Пусть имеется таблица с календарным полем created_at. В ней размещены разряженые календарные записи за август 2018 года '2018-08-01', '2016-08-04', '2018-08-16' и 2018-08-17. Составьте запрос, который выводит полный список дат за август, выставляя в соседнем поле значение 1, если дата присутствует в исходном таблице и 0, если она отсутствует.
CREATE TABLE IF NOT EXISTS shop.dates(
    created_at DATE
);
INSERT INTO shop.dates VALUES ('2018-08-01'), ('2016-08-04'), ('2018-08-16'), ('2018-08-17');

SELECT dates.date, IF(dates.date in (select created_at FROM shop.dates), 1, 0) exist
FROM(
SELECT DATE(CONCAT('2018', '-', '08', '-', @r := @r + 1)) as date
FROM (SELECT @r := 0) as n,
     information_schema.COLUMNS
limit 31) as dates;

# (по желанию) Пусть имеется любая таблица с календарным полем created_at. Создайте запрос, который удаляет устаревшие записи из таблицы, оставляя только 5 самых свежих записей.
INSERT INTO shop.dates VALUES ('2015-08-04'), ('2015-08-05'), ('2015-08-06'), ('2015-08-07'), ('2015-08-08'), ('2015-08-09'), ('2015-08-10');

CREATE OR REPLACE VIEW shop.latest_dates AS
SELECT created_at FROM shop.dates ORDER BY created_at LIMIT 5;

DELETE FROM shop.dates
WHERE created_at not in (SELECT created_at FROM shop.latest_dates);

SELECT * FROM shop.dates;
#
# Практическое задание по теме “Администрирование MySQL” (эта тема изучается по вашему желанию)
# Создайте двух пользователей которые имеют доступ к базе данных shop. Первому пользователю shop_read должны быть доступны только запросы на чтение данных, второму пользователю shop — любые операции в пределах базы данных shop.
CREATE USER 'shop_read'@'localhost' IDENTIFIED BY 'pass';
GRANT SELECT ON shop.* TO 'shop'@'localhost';

CREATE USER 'shop'@'localhost' IDENTIFIED BY 'pass';
GRANT ALL ON shop.* TO 'shop'@'localhost';
# (по желанию) Пусть имеется таблица accounts содержащая три столбца id, name, password, содержащие первичный ключ, имя пользователя и его пароль. Создайте представление username таблицы accounts, предоставляющий доступ к столбца id и name. Создайте пользователя user_read, который бы не имел доступа к таблице accounts, однако, мог бы извлекать записи из представления username.
CREATE TABLE sample.accounts(
    id SERIAL PRIMARY KEY,
    name VARCHAR(30),
    password VARCHAR(30)
);

CREATE VIEW sample.username AS SELECT id, name FROM sample.accounts;
CREATE USER 'user_read'@'localhost' IDENTIFIED BY 'pass';
GRANT USAGE, SELECT ON sample.username TO 'user_read'@'localhost';

#
# Практическое задание по теме “Хранимые процедуры и функции, триггеры"
# Создайте хранимую функцию hello(), которая будет возвращать приветствие, в зависимости от текущего времени суток. С 6:00 до 12:00 функция должна возвращать фразу "Доброе утро", с 12:00 до 18:00 функция должна возвращать фразу "Добрый день", с 18:00 до 00:00 — "Добрый вечер", с 00:00 до 6:00 — "Доброй ночи".
DROP FUNCTION IF EXISTS shop.hello;

CREATE FUNCTION shop.hello()
RETURNS TEXT DETERMINISTIC
BEGIN
    IF TIME(NOW()) BETWEEN '00:00' AND '06:00' THEN
        RETURN 'Доброй ночи';
    ELSEIF TIME(NOW()) BETWEEN '06:00' AND '12:00' THEN
        RETURN 'Доброе утро';
    ELSEIF TIME(NOW()) BETWEEN '12:00' AND '18:00' THEN
        RETURN 'Добрый день';
    ELSE
        RETURN 'Добрый вечер';
    end if;
end;

SELECT shop.hello();

# В таблице products есть два текстовых поля: name с названием товара и description с его описанием. Допустимо присутствие обоих полей или одно из них. Ситуация, когда оба поля принимают неопределенное значение NULL неприемлема. Используя триггеры, добейтесь того, чтобы одно из этих полей или оба поля были заполнены. При попытке присвоить полям NULL-значение необходимо отменить операцию.
DROP TRIGGER IF EXISTS shop.check_insert_product;
CREATE TRIGGER shop.check_insert_product BEFORE INSERT ON shop.products
FOR EACH ROW BEGIN
  IF NEW.name IS NULL AND NEW.description IS NULL THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'INSERT canceled';
  END IF;
END;

CREATE TRIGGER shop.check_update_product BEFORE UPDATE ON shop.products
FOR EACH ROW BEGIN
  IF NEW.name IS NULL AND NEW.description IS NULL THEN
	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'UPDATE canceled';
  END IF;
END;

INSERT INTO shop.products(name, description)
VALUES ('aaa', NULL);

INSERT INTO shop.products(name, description)
VALUES (NULL, 'aaa');

INSERT INTO shop.products(name, description)
VALUES (NULL, NULL);

UPDATE shop.products SET name = NULL
WHERE id = 8;
# (по желанию) Напишите хранимую функцию для вычисления произвольного числа Фибоначчи. Числами Фибоначчи называется последовательность в которой число равно сумме двух предыдущих чисел. Вызов функции FIBONACCI(10) должен возвращать число 55.

DROP FUNCTION IF EXISTS shop.fib;
CREATE FUNCTION shop.fib (num INT) RETURNS INTEGER DETERMINISTIC
BEGIN
    DECLARE i, prev, res, tmp int DEFAULT 0;
    SET res = 1;
    WHILE i < num-1 do
        SET tmp = res;
        SET res = res + prev;
        SET prev = tmp;
        SET i = i+1;
    end while;
    RETURN res;
end;

SELECT shop.fib(3);