# Домашнее задание к занятию "Индексы" Nikiforov Viktor

### Задание 1

## Напишите запрос к учебной базе данных, который вернёт процентное отношение общего размера всех индексов к общему размеру всех таблиц.

	SELECT
	    table_schema,
	    ROUND(SUM(index_length) * 100 / NULLIF(SUM(data_length), 0), 2) AS index_to_data_percent
	FROM information_schema.tables
	WHERE table_schema = 'sakila'
	  AND table_type = 'BASE TABLE'
	GROUP BY table_schema;

---

### Задание 2

## Выполните explain analyze запроса. Перечислите узкие места, оптимизируйте запрос: внесите корректировки по использованию операторов, при необходимости добавьте индексы.

Узкие места исходного запроса:
	1. Использован старый синтаксис соединений через запятую, из-за чего легко допустить ошибку в условиях соединения.
	2. Таблица film не связана с другими таблицами, поэтому возникает декартово произведение.
	3. Таблицы payment и rental соединяются по payment_date = rental_date, что некорректно; корректная связь - по rental_id.
	4. Условие DATE(p.payment_date) = '2005-07-30' мешает эффективному использованию индекса по payment_date; лучше использовать диапазон дат.
	5. Использование DISTINCT вместе с оконной функцией приводит к лишней обработке промежуточного результата.
	6. Для агрегации по клиенту и фильму логичнее использовать GROUP BY, а не оконную функцию.

## Оптимизированный запрос

	SELECT
	    CONCAT(c.last_name, ' ', c.first_name) AS customer_name,
	    f.title,
	    SUM(p.amount) AS total_amount
	FROM payment p
	JOIN rental r
	    ON r.rental_id = p.rental_id
	JOIN customer c
	    ON c.customer_id = p.customer_id
	JOIN inventory i
	    ON i.inventory_id = r.inventory_id
	JOIN film f
	    ON f.film_id = i.film_id
	WHERE p.payment_date >= '2005-07-30 00:00:00'
	  AND p.payment_date <  '2005-07-31 00:00:00'
	GROUP BY c.customer_id, c.last_name, c.first_name, f.film_id, f.title
	ORDER BY customer_name, f.title;

---

### Задание 3

## Перечислите те индексы, которые используются в PostgreSQL, а в MySQL — нет.

	В PostgreSQL, помимо обычных B-tree и Hash, есть типы индексов GiST, SP-GiST, GIN и BRIN.
	В MySQL таких встроенных индексных методов в общем случае нет.
	GiST и SP-GiST предназначены для более сложных структур поиска, GIN удобен для inverted index-сценариев (например, массивы, jsonb, полнотекстовый поиск), а BRIN применяется для очень больших таблиц как компактный индекс по диапазонам блоков. 
	PostgreSQL в целом предоставляет более широкий набор специализированных индексных методов, чем MySQL.

---
