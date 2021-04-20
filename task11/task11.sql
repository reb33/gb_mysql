# Практическое задание по теме “Оптимизация запросов”
# Создайте таблицу logs типа Archive. Пусть при каждом создании записи в таблицах users, catalogs и products в таблицу logs помещается время и дата создания записи, название таблицы, идентификатор первичного ключа и содержимое поля name.
DROP TABLE IF EXISTS shop.logs;
CREATE TABLE shop.logs (
  created_at DATETIME,
  `table` VARCHAR(30),
  id_row INTEGER,
  name VARCHAR(255)
) COMMENT = 'Разделы интернет-магазина' ENGINE=Archive;

CREATE TRIGGER shop.log_users AFTER INSERT ON shop.users
FOR EACH ROW BEGIN
  INSERT INTO shop.logs(created_at, `table`, id_row, name)
  VALUES(NOW(), 'users', NEW.id, NEW.name);
END;

CREATE TRIGGER shop.log_catalog AFTER INSERT ON shop.catalogs
FOR EACH ROW BEGIN
  INSERT INTO shop.logs(created_at, `table`, id_row, name)
  VALUES(NOW(), 'catalogs', NEW.id, NEW.name);
END;

CREATE TRIGGER shop.log_products AFTER INSERT ON shop.products
FOR EACH ROW BEGIN
  INSERT INTO shop.logs(created_at, `table`, id_row, name)
  VALUES(NOW(), 'products', NEW.id, NEW.name);
END;

INSERT INTO shop.users (name, birthday_at) VALUES
  ('Геннадий', '1990-10-05'),
  ('Наталья', '1984-11-12'),
  ('Александр', '1985-05-20');

INSERT INTO shop.catalogs VALUES
  (NULL, 'МФУ');

INSERT INTO shop.products
  (name, description, price, catalog_id)
VALUES
  ('Intel Core i3-8100', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 7890.00, 1),
  ('Intel Core i5-7400', 'Процессор для настольных персональных компьютеров, основанных на платформе Intel.', 12700.00, 1);

# (по желанию) Создайте SQL-запрос, который помещает в таблицу users миллион записей.
#


# Практическое задание по теме “NoSQL”
# В базе данных Redis подберите коллекцию для подсчета посещений с определенных IP-адресов.
HINCRBY ips 127.0.0.1 1
# (integer) 1
HINCRBY ips 127.0.0.1 1
# (integer) 2
HINCRBY ips 127.0.0.3 1
# (integer) 1
HGETALL ips
# 1) "127.0.0.1"
# 2) "2"
# 3) "127.0.0.3"
# 4) "1"

# При помощи базы данных Redis решите задачу поиска имени пользователя по электронному адресу и наоборот, поиск электронного адреса пользователя по его имени.

# вставка новых записей
eval "if not redis.call('LPOS', 'names', KEYS[1]) and not redis.call('LPOS', 'emails', KEYS[2]) then redis.call('RPUSH', 'names', KEYS[1]) redis.call('RPUSH', 'emails', KEYS[2]) return 'inserted' else return 'not inserted' end" 2 boris boris@g.com
# "inserted"
LRANGE names 0 -1
# 1) "boris"
LRANGE emails 0 -1
# 1) "boris@g.com"

# поиск имени по email
eval "local index=redis.call('LPOS', 'emails', KEYS[1]) if index then return redis.call('LINDEX', 'names', index) else return nil end" 1 boris@g.com
# "boris"

# поиск email по имени
eval "local index=redis.call('LPOS', 'names', KEYS[1]) if index then return redis.call('LINDEX', 'emails', index) else return nil end" 1 boris
# "boris@g.com"

# Организуйте хранение категорий и товарных позиций учебной базы данных shop в СУБД MongoDB.
db.shop.insert({"catalogs": [{"id": 1,"name": "Процессоры"},{"id": 2,"name": "Материнские платы"},{"id": 3,"name": "Видеокарты"},{"id": 4,"name": "Жесткие диски"},{"id": 5,"name": "Оперативная память"}]})

db.shop.insert({"products": [{"id": 1,"name": "Intel Core i3-8100","description": "Процессор для настольных персональных компьютеров, основанных на платформе Intel.","price": 7890.00,"catalog_id": 1,"created_at": "2021-04-20 22:27:21","updated_at": "2021-04-20 22:27:21"},{"id": 2,"name": "Intel Core i5-7400","description": "Процессор для настольных персональных компьютеров, основанных на платформе Intel.","price": 12700.00,"catalog_id": 1,"created_at": "2021-04-20 22:27:21","updated_at": "2021-04-20 22:27:21"},{"id": 3,"name": "AMD FX-8320E","description": "Процессор для настольных персональных компьютеров, основанных на платформе AMD.","price": 4780.00,"catalog_id": 1,"created_at": "2021-04-20 22:27:21","updated_at": "2021-04-20 22:27:21"},{"id": 4,"name": "AMD FX-8320","description": "Процессор для настольных персональных компьютеров, основанных на платформе AMD.","price": 7120.00,"catalog_id": 1,"created_at": "2021-04-20 22:27:21","updated_at": "2021-04-20 22:27:21"},{"id": 5,"name": "ASUS ROG MAXIMUS X HERO","description": "Материнская плата ASUS ROG MAXIMUS X HERO, Z370, Socket 1151-V2, DDR4, ATX","price": 19310.00,"catalog_id": 2,"created_at": "2021-04-20 22:27:21","updated_at": "2021-04-20 22:27:21"},{"id": 6,"name": "Gigabyte H310M S2H","description": "Материнская плата Gigabyte H310M S2H, H310, Socket 1151-V2, DDR4, mATX","price": 4790.00,"catalog_id": 2,"created_at": "2021-04-20 22:27:21","updated_at": "2021-04-20 22:27:21"},{"id": 7,"name": "MSI B250M GAMING PRO","description": "Материнская плата MSI B250M GAMING PRO, B250, Socket 1151, DDR4, mATX","price": 5060.00,"catalog_id": 2,"created_at": "2021-04-20 22:27:21","updated_at": "2021-04-20 22:27:21"}]})

