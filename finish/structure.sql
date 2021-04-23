DROP DATABASE IF EXISTS audio_library;
CREATE DATABASE audio_library;
USE audio_library;

DROP TABLE IF EXISTS authors;
CREATE TABLE authors
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(50),
    lastname    VARCHAR(50),
    patronymic  VARCHAR(50),
    birthday    DATE,
    death       DATE,
    nationality VARCHAR(2),

    INDEX lastname_name (lastname, name)
);

DROP TABLE IF EXISTS books;
CREATE TABLE `books`
(
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100),
    id_author   BIGINT UNSIGNED,
    date_issued DATETIME,

    FOREIGN KEY (id_author) REFERENCES authors (id),
    INDEX author (id_author)
);



DROP TABLE IF EXISTS copyright_holder;
CREATE TABLE copyright_holder
(
    id             SERIAL PRIMARY KEY,
    name           VARCHAR(50),
    inn            VARCHAR(20),
    legal_address  VARCHAR(100),
    actual_address VARCHAR(100),
    phone          VARCHAR(15)
);

DROP TABLE IF EXISTS reader;
CREATE TABLE reader
(
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(50),
    lastname   VARCHAR(50),
    patronymic VARCHAR(50),
    birthday   DATE,

    index lastname_name (lastname, name)
);

DROP TABLE IF EXISTS audiobooks;
CREATE TABLE audiobooks
(
    id                  SERIAL PRIMARY KEY,
    id_book             BIGINT UNSIGNED,
    id_reader           BIGINT UNSIGNED,
    id_copyright_holder BIGINT UNSIGNED,
    date_record         DATE,
    listen_time         TIME COMMENT 'время звучания',

    FOREIGN KEY (id_book) REFERENCES books (id),
    FOREIGN KEY (id_reader) REFERENCES reader (id),
    FOREIGN KEY (id_copyright_holder) REFERENCES copyright_holder (id),

    INDEX books (id_book),
    INDEX readers (id_reader)
);

DROP TABLE IF EXISTS prices;
CREATE TABLE prices
(
    id           SERIAL PRIMARY KEY,
    id_audiobook BIGINT UNSIGNED,
    date_start   DATETIME,
    date_end     DATETIME,
    price        DECIMAL,

    FOREIGN KEY (id_audiobook) REFERENCES audiobooks (id),
    INDEX audiobooks (id_audiobook)
);



DROP TABLE IF EXISTS users;
CREATE TABLE users
(
    id         SERIAL PRIMARY KEY,
    nic        VARCHAR(50),
    name       VARCHAR(50),
    lastname   VARCHAR(50),
    patronymic VARCHAR(50),
    email      VARCHAR(50),
    password   VARCHAR(100),
    birthday   DATE,

    INDEX for_nic (nic)
);

DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts
(
    id           SERIAL PRIMARY KEY,
    id_audiobook BIGINT UNSIGNED,
    discount     DECIMAL,
    date_start   DATETIME,
    date_end     DATETIME,

    FOREIGN KEY (id_audiobook) REFERENCES audiobooks (id),
    INDEX audiobooks (id_audiobook)
);

DROP TABLE IF EXISTS purchase;
CREATE TABLE purchase
(
    id           SERIAL PRIMARY KEY,
    id_audiobook BIGINT UNSIGNED,
    id_user      BIGINT UNSIGNED,
    date_pur     DATETIME,
    price        DECIMAL,
    discount     DECIMAL COMMENT 'скидка при покупке',

    FOREIGN KEY (id_audiobook) REFERENCES audiobooks (id),
    FOREIGN KEY (id_user) REFERENCES users (id),
    INDEX users (id_user)
);

DROP TABLE IF EXISTS rating;
CREATE TABLE rating
(
    id           SERIAL PRIMARY KEY,
    id_audiobook BIGINT UNSIGNED,
    id_user      BIGINT UNSIGNED,
    date_rating  DATETIME,
    score        TINYINT,
    comment      VARCHAR(200),

    FOREIGN KEY (id_audiobook) REFERENCES audiobooks (id),
    FOREIGN KEY (id_user) REFERENCES users (id),
    index audiobook (id_audiobook)
);


# аудио кники с полной информацией
CREATE OR REPLACE VIEW audiobook_info AS
SELECT ab.id, b.name, CONCAT(a.lastname, ' ', a.name) as author, CONCAT(r.lastname, ' ', r.name) as reader
FROM audiobooks ab
         INNER JOIN books b on ab.id_book = b.id
         INNER JOIN reader r on ab.id_reader = r.id
         INNER JOIN authors a on b.id_author = a.id;


# текущие скидки
CREATE OR REPLACE VIEW current_discounts AS
SELECT *
FROM discounts d
WHERE (d.date_end is NULL or d.date_end > now());


# текущие  цены учитывая скидки
CREATE OR REPLACE VIEW current_prices AS
SELECT p.id_audiobook,p.price as 'start_price', d.discount, IF(d.id is null, p.price, ROUND(price * ((100 - d.discount)/100), 2)) as price
FROM prices p
LEFT JOIN current_discounts d on p.id_audiobook = d.id_audiobook
WHERE p.date_end is NULL or p.date_end > NOW();


# скрипты характерных выборок (включающие группировки, JOIN'ы, вложенные таблицы);
# sort audiobooks by rating
SELECT ai.name, ai.author, ai.reader, AVG(r.score) as score
FROM audiobook_info ai
         INNER JOIN rating r on ai.id = r.id_audiobook
GROUP BY ai.id
ORDER BY score DESC;

# sort by sells
SELECT ai.name, ai.author, ai.reader, COUNT(p.id) as sells
FROM audiobook_info ai
         INNER JOIN purchase p on p.id_audiobook = ai.id
GROUP BY ai.id
ORDER BY sells DESC;

DROP PROCEDURE IF EXISTS add_price;
CREATE PROCEDURE add_price(IN in_id_audiobook BIGINT UNSIGNED, IN in_price DECIMAL)
BEGIN
    START TRANSACTION ;
    UPDATE prices
    SET date_end = now()
    WHERE date_end is NULL or date_end>now();

    INSERT INTO prices(id_audiobook, date_start, price)
    VALUES (in_id_audiobook, now(), in_price);

    COMMIT;

end;

CREATE PROCEDURE add_discount(IN in_id_audiobook BIGINT UNSIGNED, IN in_discount DECIMAL)
BEGIN
    START TRANSACTION ;

    UPDATE discounts
    SET date_end = now()
    WHERE date_end is NULL or date_end>now();

    INSERT INTO discounts(id_audiobook, date_start, discount)
    VALUES (in_id_audiobook, now(), in_discount);

    COMMIT;

end;


DROP PROCEDURE IF EXISTS add_purchase;
CREATE PROCEDURE add_purchase(IN in_id_audiobook BIGINT UNSIGNED, IN in_id_user BIGINT UNSIGNED)
BEGIN
    DECLARE curr_price, curr_disc DECIMAL;
    SELECT price, discount into curr_price, curr_disc
    FROM current_prices
    WHERE id_audiobook = in_id_audiobook;

    INSERT INTO purchase(id_audiobook, id_user, date_pur, price, discount)
    VALUES (in_id_audiobook, in_id_user, now(), curr_price, curr_disc);

end;

