-- 1. INSERT
INSERT INTO employees.employee (emp_id, name, email, password)
VALUES(NULL, 'suman', 'suman@gmail.com', '2344')

INSERT INTO employee(email, name, password) VALUES ('bikash@gmail.com', 'bikash', '123')

INSERT INTO employee VALUES
(NULL, 'ram', 'ram@email.com', '1111'),
(NULL, 'shyam', 'shyam@email.com', '2222'),
(NULL, 'sita', 'sita@email.com', '3333');





-- 2. SELECT
SELECT * FROM smartphones
SELECT brand_name, price, os FROM smartphones
SELECT brand_name, price, os AS 'operaing system' FROM smartphones

-- CREATE EXPRESSION USING COLUMNS
SELECT model, 
SQRT(resolution_height*resolution_height +  resolution_width*resolution_width) /screen_size AS ppt
FROM employees.smartphones;

-- CONSTANTS
SELECT brand_name, 'smartphone' AS 'type' 
FROM employees.smartphones;

-- DISTINCT(unique)
SELECT DISTINCT(brand_name) AS 'all brand'  FROM employees.smartphones;
SELECT DISTINCT(os) AS 'all os name'  FROM employees.smartphones;

-- combination
SELECT DISTINCT brand_name,  processor_brand  FROM employees.smartphones;

-- WHERE CLAUSE
SELECT * FROM employees.smartphones
WHERE brand_name= 'apple'

SELECT * FROM employees.smartphones
WHERE price>50000

-- BETWEEN
SELECT * FROM employees.smartphones
WHERE price>50000 AND price<100000
-- SAME AS 
SELECT * FROM employees.smartphones
WHERE price BETWEEN 50000 AND 100000

SELECT * FROM employees.smartphones
WHERE price <20000 AND rating>80 AND brand_name = 'realme';

SELECT * FROM employees.smartphones
WHERE brand_name = 'samsung' AND processor_brand='snapdragon';

SELECT DISTINCT(brand_name)  FROM employees.smartphones
where price>100000


-- IN AND NOT IN 
SELECT * FROM employees.smartphones
WHERE processor_brand IN ('snapdragon', 'bionic', 'dimensity');

SELECT * FROM employees.smartphones
WHERE processor_brand NOT IN ('snapdragon', 'bionic', 'dimensity');




-- 3. UPDATE
UPDATE smartphones 
SET processor_brand='exynos'
WHERE processor_brand='dimensity';

SELECT * FROM employees.smartphones
WHERE processor_brand='dimensity';

UPDATE employees.employee
SET email='sum@gmail.com' , password='000000'
WHERE name = 'suman';

SELECT * FROM employee;




-- 4. DELETE
DELETE FROM smartphones
WHERE primary_camera_rear>100 AND brand_name='samsung';

SELECT * FROM smartphones
WHERE primary_camera_rear>100 AND brand_name='samsung'






-- TYPE OF FUNCTION

-- 1. AGGREGATE FUNCTION 
-- MIN/ MAX
SELECT MAX(price) FROM employees.smartphones;

SELECT MIN(price) FROM employees.smartphones;

SELECT MAX(price) FROM employees.smartphones
WHERE brand_name='samsung';
 
-- AVG
SELECT AVG(price) FROM employees.smartphones
WHERE brand_name='apple';

-- sum
SELECT SUM(price) FROM employees.smartphones;

-- COUNT
SELECT COUNT(brand_name) FROM employees.smartphones
WHERE brand_name='apple';

-- COUNT(DISTINCT)
SELECT COUNT(DISTINCT(brand_name)) FROM employees.smartphones;

-- STD
-- VAR


-- 2. SCALER FUNCTION
-- ABS
SELECT ABS(price-100000) AS price FROM employees.smartphones;

-- ROUND
SELECT ROUND(screen_size) FROM employees.smartphones;

-- CEIL/FLOOR
-- CEIL -> 2.1=3
-- FLOOR -> 2.7=2

