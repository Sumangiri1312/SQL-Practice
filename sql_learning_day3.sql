-- SORTING DATA

-- find top five samsung phone with biggest screen size
SELECT brand_name, screen_size FROM employees.smartphones
WHERE brand_name= 'samsung'
ORDER BY screen_size DESC LIMIT 5;

-- sort all the phone in descending order of number of total cameras
SELECT brand_name, num_front_cameras+num_rear_cameras AS 'total_cameras' FROM  employees.smartphones
ORDER BY total_cameras DESC;

-- sort data on the basis of ppt on descending order
SELECT brand_name,
ROUND(SQRT(resolution_width*resolution_width + resolution_height*resolution_height)/screen_size) AS 'ppi' 
FROM employees.smartphones
ORDER BY ppi DESC;

-- find the phone with second largest battery
SELECT model, battery_capacity FROM employees.smartphones
ORDER BY battery_capacity DESC LIMIT 1,1; -- (limit 10,2 means skip 0-9 and select 10 and 11)

-- find the phone with third llowest battery
SELECT model, battery_capacity FROM employees.smartphones
ORDER BY battery_capacity ASC LIMIT 2,1;

-- find the name and ratinf of worst ratted APPLE phone
SELECT model, rating FROM employees.smartphones
WHERE brand_name= 'apple'
ORDER BY rating ASC LIMIT 1;