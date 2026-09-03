-- SQL JOINS

-- CROSS JOIN (CARTESIAN PDODUCT)
SELECT * FROM suman_db.users1 t1 
CROSS JOIN suman_db.groups t2;

-- INNER JOIN
SELECT * FROM suman_db.membership t1
INNER JOIN suman_db.users1 t2
ON t1.user_id = t2.user_id;

--  LEFT JOIN 
SELECT * FROM suman_db.membership t1
LEFT JOIN suman_db.users1 t2
ON t1.user_id = t2.user_id;

-- RIGHT JOIN
SELECT * FROM suman_db.membership t1
RIGHT JOIN suman_db.users1 t2
ON t1.user_id = t2.user_id;

-- UNION
SELECT * FROM suman_db.person1 
UNION
SELECT * FROM suman_db.person2;

-- UNION ALL
SELECT * FROM suman_db.person1 
UNION ALL
SELECT * FROM suman_db.person2;

-- INTERSECT
SELECT * FROM suman_db.person1 
INTERSECT
SELECT * FROM suman_db.person2;

-- EXCEPT(MINUS)
SELECT * FROM suman_db.person1 
EXCEPT
SELECT * FROM suman_db.person2;

-- FOR FULL OUTER JOIN
SELECT * FROM suman_db.membership t1
LEFT JOIN suman_db.users1 t2
ON t1.user_id = t2.user_id
UNION
SELECT * FROM suman_db.membership t1
RIGHT JOIN suman_db.users1 t2
ON t1.user_id = t2.user_id;

-- SELF JOIN 
SELECT * FROM suman_db.users1 t1 JOIN suman_db.users1 t2
ON t1.emergency_contact = t2.user_id;

-- JOINING MORE THAN ONE COLUMNS
SELECT * FROM suman_db.students t1 
JOIN suman_db.class t2
ON t1.class_id=t2.class_id AND t1.enrollment_year = t2.class_year;

-- JOINING MORE THAN TWO TABLES
SELECT  * FROM flipkart.users t1
JOIN flipkart.orders t2 
ON t1.user_id = t2.user_id
JOIN flipkart.order_details t3
ON t2.order_id = t3.order_id;

-- COLUMNS FILTERING
SELECT t1.user_id,t1.name, t2.order_id  FROM flipkart.users t1
JOIN flipkart.orders t2
ON t1.user_id = t2.user_id;

-- ROWS FILTERING
SELECT * FROM flipkart.users t1
JOIN flipkart.orders t2
ON t1.user_id = t2.user_id
WHERE city = 'pune' AND name='Parth';

-- find all profitale orders
SELECT t1.order_id, SUM(t2.profit) AS 'profit' FROM flipkart.orders t1
JOIN flipkart.order_details t2
ON t1.order_id = t2.order_id
GROUP BY t1.order_id 
HAVING profit > 0;

-- customer who has placed maximum number of orders
SELECT  t1.name, COUNT(*) AS 'num_of_orders' FROM flipkart.users t1
JOIN flipkart.orders t2 
ON t1.user_id =t2.user_id
GROUP BY t1.name
ORDER BY COUNT(*) DESC LIMIT 1;

-- most profitable category
SELECT t1.vertical, SUM(t2.profit) AS 'profit' FROM flipkart.category t1
JOIN flipkart.order_details t2
ON t1.category_id = t2.category_id
GROUP BY t1.vertical
ORDER BY profit DESC LIMIT 1;

-- most profitable state
SELECT t1.state, SUM(t3.profit) AS 'profit' FROM flipkart.users t1
JOIN flipkart.orders t2
ON t1.user_id = t2.user_id
JOIN flipkart.order_details t3
ON t2.order_id = t3.order_id
GROUP BY t1.state
ORDER BY profit DESC LIMIT 1;

-- all categories having profit higher than 1000
SELECT t1.vertical, SUM(t2.profit) AS 'profit' FROM flipkart.category t1
JOIN flipkart.order_details t2
ON t1.category_id = t2.category_id
GROUP BY t1.vertical
HAVING profit > 1000

