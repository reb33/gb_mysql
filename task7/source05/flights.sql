use task7;

DROP TABLE IF EXISTS flights;

CREATE TABLE flights(
    id SERIAL PRIMARY KEY,
    `from` VARCHAR(32),
    `to` varchar(32)
);

insert into flights (`from`, `to`) values ('moscow', 'omsk'), ('novgorod', 'kazan'),
                                          ('irkutsk', 'moscow'), ('omsk', 'irkutsk'),
                                          ('moscow', 'kazan');

DROP TABLE IF EXISTS cities;

CREATE TABLE cities(
    label VARCHAR(32),
    name varchar(32)
);

insert into cities values ('moscow', 'Москва'), ('irkutsk', 'Иркутск'),
                          ('novgorod', 'Новгород'), ('kazan', 'Казань'),
                          ('omsk', 'Омск');
