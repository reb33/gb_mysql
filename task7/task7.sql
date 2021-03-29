# Составьте список пользователей users, которые осуществили хотя бы один заказ orders в интернет магазине.
SELECT * from task7.users
WHERE `id` = ANY (select distinct user_id FROM task7.orders);
# Выведите список товаров products и разделов catalogs, который соответствует товару.
SELECT p.name, c.name
FROM task7.products p JOIN task7.catalogs c on p.catalog_id = c.id;

# (по желанию) Пусть имеется таблица рейсов flights (id, from, to) и таблица городов cities (label, name). Поля from, to и label содержат английские названия городов, поле name — русское. Выведите список рейсов flights с русскими названиями городов.

SELECT f.*, c1.name, c2.name
FROM task7.flights f
    JOIN task7.cities c1 ON f.`from` = c1.label
    JOIN task7.cities c2 ON f.`to` = c2.label
