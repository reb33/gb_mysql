# i. Заполнить все таблицы БД vk данными (по 10-100 записей в каждой таблице)
# ii. Написать скрипт, возвращающий список имен (только firstname) пользователей без повторений в алфавитном порядке
SELECT DISTINCT firstname FROM vk.users ORDER BY firstname;
# iii. Написать скрипт, отмечающий несовершеннолетних пользователей как неактивных (поле is_active = false). Предварительно добавить такое поле в таблицу profiles со значением по умолчанию = true (или 1)
ALTER TABLE vk.users ADD COLUMN is_active BOOL DEFAULT true;
UPDATE vk.users SET vk.users.is_active = false
WHERE id IN (SELECT user_id FROM vk.profiles
    WHERE ROUND(DATEDIFF(NOW(), birthday) / 365.25) < 18 );
# iv. Написать скрипт, удаляющий сообщения «из будущего» (дата больше сегодняшней)
DELETE FROM vk.messages
WHERE created_at > NOW()
# v. Написать название темы курсового проекта (в комментарии)
# Платежные операции
