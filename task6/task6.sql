#  Практическое задание по теме “Операторы, фильтрация, сортировка и ограничение. Агрегация данных”. Работаем с БД vk и данными, которые вы сгенерировали ранее:
# 1. Пусть задан некоторый пользователь. Из всех пользователей соц. сети найдите человека, который больше всех общался с выбранным пользователем (написал ему сообщений).
SELECT * FROM vk.users
WHERE id in (
    SELECT ids FROM
    (SELECT GROUP_CONCAT(from_user_id) ids
    FROM
    (SELECT from_user_id, count(*) count_message FROM vk.messages
    WHERE to_user_id=1
    GROUP BY from_user_id
    ) as count_mess_to_user
    GROUP BY count_message
    ORDER BY count_message DESC
    LIMIT 1) max_mess
);
# 2. Подсчитать общее количество лайков, которые получили пользователи младше 10 лет..
SELECT count(*) FROM vk.likes
WHERE user_id in (
SELECT user_id FROM
(SELECT *, ROUND(DATEDIFF(NOW(), birthday) / 365.25) age
FROM vk.profiles) profs_with_age
WHERE age < 10);

# 3. Определить кто больше поставил лайков (всего): мужчины или женщины.
SELECT gender, count(*) as count_likes
FROM vk.likes l INNER JOIN vk.profiles p on l.user_id=p.user_id
GROUP BY gender
ORDER BY count_likes DESC
LIMIT 1


