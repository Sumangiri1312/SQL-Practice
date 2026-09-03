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

-- find the name and rating of worst ratted APPLE phone
SELECT model, rating FROM employees.smartphones
WHERE brand_name= 'apple'
ORDER BY rating ASC LIMIT 1;

-- sort two collumns
SELECT * FROM employees.smartphones
ORDER BY brand_name ASC, price ASC;






-- GROUP BY

-- group by on the basis of brand name and performed some agg. function
SELECT brand_name, COUNT(*) AS 'num_phones', ROUND(AVG(price)) AS 'average price', MAX(rating) AS 'max ratind', ROUND(AVG(screen_size), 2) AS 'average screen size'
FROM employees.smartphones
GROUP BY brand_name
ORDER BY num_phones DESC;

-- group on has_nfc and get avg price nad rating
SELECT has_nfc, AVG(price) AS 'average price', AVG(rating) AS 'avg rating' FROM employees.smartphones
GROUP BY has_nfc;

-- group on extended_memory_available and get avg price
SELECT extended_memory_available, AVG(price) AS 'avg price' FROM employees.smartphones
GROUP BY extended_memory_available;


-- group by on brand name and processor brand and get the count on  model  and average on primary rare camera
SELECT brand_name, processor_brand, COUNT(*), ROUND(AVG(primary_camera_rear), 2) FROM employees.smartphones
GROUP BY brand_name, processor_brand
ORDER BY brand_name ASC;

-- top 5 most costly phone brand
SELECT brand_name, AVG(price) AS'price' FROM smartphones
GROUP BY brand_name
ORDER BY price DESC LIMIT 5;

-- highest number model that has both nfc and ir blaster
SELECT brand_name, COUNT(*) AS 'count' 
FROM employees.smartphones
WHERE has_nfc='True' AND has_ir_blaster='True'
GROUP BY brand_name
ORDER BY count DESC LIMIT 1;

-- find all samsund 5g enable smartphones and find out average price for nfc and non nfc phones
SELECT has_nfc,avg(price) AS price FROM smartphones
where brand_name='samsung' and has_5g='True'
group by has_nfc;


 



-- HAVING CLAUSE

select brand_name, count(*) AS 'count', avg(price)  as 'avg_price' from smartphones
group by brand_name
having count>20
order by avg_price desc;

-- top 3 brand with the highest ram capacity that has refrash rare at least 90 hz and fast chargin available and dont cconsider brand which has less than 10 phones
select brand_name, avg(ram_capacity) as 'avg_rame_capacity' from smartphones
where refresh_rate>90 and fast_charging_available = 1
group by brand_name
having count(*)>10
order by avg_rame_capacity desc limit 3;

-- average price of all phone with the average rating >70 and number of phone more than 10 among all 5g enable phones
select brand_name, avg(price) as 'price' from smartphones
where has_5g='True'
group by brand_name
having avg(rating)>70 and count(*)>10;

-- note: having clause only use on agg function
     --  and where clause use on rows

