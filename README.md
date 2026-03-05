# Домашнее задание к занятию "SQL. Часть 2" Nikiforov Viktor

### Задание 1

## Одним запросом получите информацию о магазине, в котором обслуживается более 300 покупателей, и выведите в результат следующую информацию:
## -фамилия и имя сотрудника из этого магазина;
## -город нахождения магазина;
## -количество пользователей, закреплённых в этом магазине.

	SELECT
	  s.store_id,
	  CONCAT(st.last_name, ' ', st.first_name) AS staff_name,
	  c.city AS store_city,
	  s_cust.cnt_customers AS customers_count
	FROM store s
	JOIN (
	  SELECT store_id, COUNT(*) AS cnt_customers
	  FROM customer
	  GROUP BY store_id
	  HAVING COUNT(*) > 300
	) s_cust
	  ON s.store_id = s_cust.store_id
	JOIN staff st
	  ON st.store_id = s.store_id
	JOIN address a
	  ON a.address_id = s.address_id
	JOIN city c
	  ON c.city_id = a.city_id
	ORDER BY s.store_id, staff_name;

---

### Задание 2

## Получите количество фильмов, продолжительность которых больше средней продолжительности всех фильмов.

	SELECT COUNT(*) AS films_longer_than_avg
	FROM film
	WHERE length > (SELECT AVG(length) FROM film);

---

### Задание 3

## Получите информацию, за какой месяц была получена наибольшая сумма платежей, и добавьте информацию по количеству аренд за этот месяц.

	SELECT
	  p_month.ym AS year_month,
	  p_month.total_amount,
	  (
	    SELECT COUNT(*)
	    FROM rental r
	    WHERE DATE_FORMAT(r.rental_date, '%Y-%m') = p_month.ym
	  ) AS rentals_count
	FROM (
	  SELECT
	    DATE_FORMAT(payment_date, '%Y-%m') AS ym,
	    SUM(amount) AS total_amount
	  FROM payment
	  GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
	  ORDER BY total_amount DESC
	  LIMIT 1
	) p_month;

---

### Задание 4

## Посчитайте количество продаж, выполненных каждым продавцом. Добавьте вычисляемую колонку «Премия». Если количество продаж превышает 8000, то значение в колонке будет «Да», иначе должно быть значение «Нет».

	SELECT
	  st.staff_id,
	  CONCAT(st.last_name, ' ', st.first_name) AS staff_name,
	  COUNT(p.payment_id) AS sales_count,
	  CASE
	    WHEN COUNT(p.payment_id) > 8000 THEN 'Да'
	    ELSE 'Нет'
	  END AS `Премия`
	FROM staff st
	LEFT JOIN payment p
	  ON p.staff_id = st.staff_id
	GROUP BY st.staff_id, st.last_name, st.first_name
	ORDER BY sales_count DESC;

---

### Задание 5

## Найдите фильмы, которые ни разу не брали в аренду.

	SELECT
	  f.film_id,
	  f.title
	FROM film f
	LEFT JOIN inventory i
	  ON i.film_id = f.film_id
	LEFT JOIN rental r
	  ON r.inventory_id = i.inventory_id
	WHERE r.rental_id IS NULL
	GROUP BY f.film_id, f.title
	ORDER BY f.film_id;

---
