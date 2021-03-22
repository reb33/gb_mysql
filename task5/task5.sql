# Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение”
# 1. Пусть в таблице users поля created_at и updated_at оказались незаполненными. Заполните их текущими датой и временем.
ALTER TABLE vk.users
    ADD column created_at DATETIME DEFAULT NOW();
ALTER TABLE vk.users
    ADD column updated_at DATETIME DEFAULT NOW();

UPDATE vk.users
SET created_at = NOW(),
    updated_at = NOW();
# 2. Таблица users была неудачно спроектирована. Записи created_at и updated_at были заданы типом VARCHAR и в них долгое время помещались значения в формате "20.10.2017 8:10". Необходимо преобразовать поля к типу DATETIME, сохранив введеные ранее значения.
ALTER TABLE vk.users
    DROP column created_at;
ALTER TABLE vk.users
    DROP column updated_at;
ALTER TABLE vk.users
    ADD column created_at VARCHAR(30) DEFAULT '20.10.2017 8:10';
ALTER TABLE vk.users
    ADD column updated_at VARCHAR(30) DEFAULT '20.10.2017 8:10';

UPDATE vk.users
SET users.created_at=STR_TO_DATE(users.created_at, '%d.%m.%Y %H:%i'),
    users.updated_at=STR_TO_DATE(users.updated_at, '%d.%m.%Y %H:%i');

ALTER TABLE vk.users
    CHANGE column created_at created_at DATETIME;
ALTER TABLE vk.users
    CHANGE column updated_at updated_at DATETIME;
# 3. В таблице складских запасов storehouses_products в поле value могут встречаться самые разные цифры: 0, если товар закончился и выше нуля, если на складе имеются запасы. Необходимо отсортировать записи таким образом, чтобы они выводились в порядке увеличения значения value. Однако, нулевые запасы должны выводиться в конце, после всех записей.
DELETE
FROM shop.storehouses_products;
INSERT shop.storehouses_products (storehouse_id, product_id, value)
values (1, 1, 1),
       (1, 1, 2),
       (1, 1, 3),
       (1, 1, 0),
       (1, 1, 0),
       (1, 1, 0),
       (1, 1, 20),
       (1, 1, 50),
       (1, 1, 8);

SELECT *
FROM shop.storehouses_products
ORDER BY FIELD(value, 0), value;
# 4. (по желанию) Из таблицы users необходимо извлечь пользователей, родившихся в августе и мае. Месяцы заданы в виде списка английских названий ('may', 'august')
DELETE
FROM shop.users;
INSERT INTO shop.users (name, birthday_at)
VALUES ('Геннадий', '1990-10-05'),
       ('Наталья', '1984-11-12'),
       ('Александр', '1985-05-20'),
       ('Сергей', '1988-02-14'),
       ('Иван', '1998-01-12'),
       ('Мария', '1992-08-29');
ALTER TABLE shop.users
    CHANGE birthday_at birthday_at VARCHAR(30);
UPDATE shop.users
SET users.birthday_at=DATE_FORMAT(users.birthday_at, '%Y %M');
UPDATE shop.users
SET users.birthday_at=LOWER(users.birthday_at);
SELECT *
FROM shop.users
WHERE users.birthday_at LIKE '% may'
   or users.birthday_at LIKE '% august';

# 5. (по желанию) Из таблицы catalogs извлекаются записи при помощи запроса. SELECT * FROM catalogs WHERE id IN (5, 1, 2); Отсортируйте записи в порядке, заданном в списке IN.
SELECT *
FROM shop.catalogs
WHERE id in (5, 1, 2)
ORDER BY FIELD(id, 5, 1, 2);

# Практическое задание теме “Агрегация данных”
# 1. Подсчитайте средний возраст пользователей в таблице users
DELETE
FROM shop.users;
ALTER TABLE shop.users
    CHANGE birthday_at birthday_at DATE;
INSERT INTO shop.users (name, birthday_at)
VALUES ('Геннадий', '1990-10-05'),
       ('Наталья', '1984-11-12'),
       ('Александр', '1985-05-20'),
       ('Сергей', '1988-02-14'),
       ('Иван', '1998-01-12'),
       ('Мария', '1992-08-29');

SELECT AVG(age)
FROM (
         SELECT id, name, birthday_at, ROUND(DATEDIFF(NOW(), users.birthday_at) / 365.25) age
         FROM shop.users) as users_with_age;

# 2. Подсчитайте количество дней рождения, которые приходятся на каждый из дней недели. Следует учесть, что необходимы дни недели текущего года, а не года рождения.
SELECT day_of_week_birth, count(*)
FROM (SELECT id,
             name,
             birthday_at,
             DATE_FORMAT(STR_TO_DATE(CONCAT(YEAR(NOW()), '-', MONTH(users.birthday_at), '-', DAY(users.birthday_at)),
                                     '%Y-%m-%d'), '%W') day_of_week_birth
      FROM shop.users) as users_with_day_of_week_birsth
GROUP BY day_of_week_birth;

# 3. (по желанию) Подсчитайте произведение чисел в столбце таблицы
SELECT round(EXP(SUM(LOG(id)))) FROM shop.products

