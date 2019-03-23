USE sakila;

SET SQL_SAFE_UPDATES = 0;

-- 1a. List columns in actor table --
DESCRIBE actor;

-- 1b. Display first and last name of each actor in one column --
SELECT 
	CONCAT (first_name, " ", last_name) AS Actor
FROM
	actor;

-- 2a. Find data for Joe --
SELECT
	actor_id, first_name, last_name
FROM
	actor
WHERE 
	first_name = "Joe";
    
-- 2b. Find all actors whose last name contains GEN --
SELECT * FROM actor
WHERE last_name LIKE "%Gen%";

-- 2c. Find actors whose last name contains LI --
SELECT last_name, first_name FROM actor
WHERE last_name LIKE "%Li%"
ORDER BY last_name, first_name;

-- 2d. Display country_id and country for specified countries --
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");

-- 3a. Add description column to actor table --
ALTER TABLE actor
ADD COLUMN description BLOB;

-- 3b. Delete description column --
ALTER TABLE actor
DROP COLUMN description;

-- 4a. List last names and counts of each last name --
SELECT last_name, COUNT(last_name) AS "name_count"
FROM actor
GROUP BY last_name;

-- 4b. Do the same, but only for names shared by 2 or more actors --
SELECT last_name, COUNT(last_name) AS "name_count"
FROM actor
GROUP BY last_name
HAVING name_count >= 2;

-- 4c. Change Groucho Williams to Harpo --
UPDATE actor
SET first_name = "HARPO"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";

-- 4d. Change all Harpos to Groucho --
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";

-- 5a. Locate schema of address table --
SHOW CREATE TABLE address;

-- 6a. Use JOIN to display first & last name and address of staff --
SELECT S.first_name, S.last_name, A.address
FROM staff AS S
INNER JOIN address AS A
ON S.address_id=A.address_id;

-- 6b. Join total amount rung up by each staff member in August 2005 --
SELECT S.first_name, S.last_name, SUM(P.amount) AS "August Rentals"
FROM staff AS S
INNER JOIN payment AS P
ON S.staff_id=P.staff_id
WHERE P.payment_date
	BETWEEN '2005-08-01 00:00:00' 
	AND '2005-08-31 12:59:59'
GROUP BY S.staff_id;
   
-- 6c. List films with number of actors for each -- 
SELECT F.title, COUNT(A.actor_id) AS Actors
FROM film AS F
INNER JOIN film_actor AS A
ON F.film_id=A.film_id
GROUP BY F.film_id;

-- 6d. How many copies of Hunchback Impossible exist? --
SELECT F.title, COUNT(I.film_id) AS Copies
FROM film AS F
INNER JOIN inventory AS I
ON F.film_id=I.film_id
WHERE F.title = "Hunchback Impossible";

-- 6e. List total paid by each customer --
SELECT C.first_name, C.last_name, SUM(P.amount) AS "Total Amount Paid"
FROM customer AS C
INNER JOIN payment AS P
ON C.customer_id=P.customer_id
GROUP BY C.customer_id
ORDER BY C.last_name;

-- 7a. Display English movie titles beg. w/ K & Q --
SELECT F.title, 
	(SELECT name 
     FROM language AS L 
     WHERE F.language_id=L.language_id) AS "language"
FROM film AS F
WHERE F.language_id IN 
(
	SELECT L.language_id
    FROM language AS L
    WHERE L.name = "English"
)
AND F.title LIKE "K%" OR F.title LIKE "Q%";

-- 7b. Use subqueries to show all actors who appear in Alone Trip --
SELECT A.first_name, A.last_name
FROM actor AS A
WHERE A.actor_id IN 
(
	SELECT FA.actor_id
    FROM film_actor AS FA
    WHERE film_id IN
    (
		SELECT F.film_id
        FROM film AS F
        WHERE F.title = "Alone Trip"
	)
);

-- 7c. Use JOIN to get names and emails for Canadian customers --
SELECT CU.first_name, CU.last_name, CU.email, CO.country
FROM customer AS CU
INNER JOIN address AS A
ON CU.address_id=A.address_id
INNER JOIN city AS CI
ON A.city_id=CI.city_id
INNER JOIN country AS CO
ON CI.country_id=CO.country_id
WHERE CO.country="Canada";

-- 7d. Identify all movies categorized as family films --
SELECT F.title AS "Family Films"
FROM film AS F
WHERE F.film_id IN 
(
	SELECT FC.film_id
    FROM film_category AS FC
    WHERE FC.category_id IN 
    (
		SELECT C.category_id
        FROM category AS C
        WHERE C.name = "Family"
	)
);

-- 7e. Display most frequently rented movies in descending order --
SELECT F.title, COUNT(I.inventory_id) AS "Number of Rentals"
FROM film AS F
INNER JOIN inventory AS I
ON F.film_id=I.film_id
INNER JOIN rental AS R
ON I.inventory_id=R.inventory_id
INNER JOIN payment AS P
ON P.rental_id=R.rental_id
GROUP BY I.film_id
ORDER BY COUNT(I.inventory_id) DESC;

-- 7f. Show how much business ($) brought in by each store --
SELECT store.store_id, SUM(P.amount) AS "Business ($)"
FROM store
INNER JOIN staff
ON staff.store_id=store.store_id
INNER JOIN rental AS R
ON R.staff_id=staff.staff_id
INNER JOIN payment AS P
ON P.rental_id=R.rental_id
GROUP BY store.store_id;

-- 7g. Display store ID, city and country for each store --
SELECT S.store_id, CI.city, CO.country
FROM store AS S
INNER JOIN address AS A
ON A.address_id=S.address_id
INNER JOIN city AS CI
ON CI.city_id=A.city_id
INNER JOIN country AS CO
ON CO.country_id=CI.country_id;

-- 7h. List the top 5 genres in descending order --
SELECT C.name, SUM(P.amount) AS "Gross Revenue"
FROM category AS C
INNER JOIN film_category AS FC
ON C.category_id=FC.category_id
INNER JOIN inventory AS I 
ON FC.film_id=I.film_id
INNER JOIN rental AS R
ON I.inventory_id=R.inventory_id
INNER JOIN payment AS P
ON R.rental_id=P.rental_id
GROUP BY C.name
ORDER BY SUM(P.amount) DESC;

-- 8a. Create view of gross revenue by genre --
CREATE VIEW top_five_genres
AS
	SELECT C.name, SUM(P.amount) AS "Gross Revenue"
	FROM category AS C
	INNER JOIN film_category AS FC
	ON C.category_id=FC.category_id
	INNER JOIN inventory AS I 
	ON FC.film_id=I.film_id
	INNER JOIN rental AS R
	ON I.inventory_id=R.inventory_id
	INNER JOIN payment AS P
	ON R.rental_id=P.rental_id
	GROUP BY C.name
	ORDER BY SUM(P.amount) DESC
;

-- 8b. Display view created in previous problem --
SELECT * FROM top_five_genres;
-- Views can be interacted with the same way as tables --

-- 8c. Delete view --
DROP VIEW IF EXISTS top_five_genres;

SET SQL_SAFE_UPDATES = 1;