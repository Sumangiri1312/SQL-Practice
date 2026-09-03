-- SUBQUERIES

-- INDEPENDENT SUBQUERY - SCALER SUBQUORY
USE suman_db; 

-- find the movie with highest profit
SELECT * FROM movies
WHERE (gross - budget) = (SELECT MAX(gross - budget) FROM movies);

select * from movies
order by (gross - budget) desc limit 1;

-- Find how many movies have a rating > the avg of all the movie ratings(Find the count of above average movies)
select count(*) from movies
where score > (select avg(score) from movies);

-- Find the highest rated movie of 2000
select * from movies
where year=2000 and score = (select max(score) from movies
                                 where year= 2000);
						
-- Find the highest rated movie among all movies whose number of votes are > the dataset avg votes
select * from movies
where score =(select max(score) from movies
                   where votes > (select avg(votes) from movies))



-- Independent Subquery - Row Subquery(One Col Multi Rows)

-- Find all users who never ordered
select * from users2
where user_id not in (select distinct(user_id) from orders1);

-- Find all the movies made by top 3 directors(in terms of total gross income)
select * from movies
where director in (select director from movies
                     group by director
                     order by sum(gross) desc limit 3);
				
-- Find all movies of all those actors whose filmography's avg rating > 8.5(take 25000 votes as cutoff)
SELECT name
FROM movies
WHERE votes > 25000
  AND star IN (
        SELECT star
        FROM movies
        WHERE votes > 25000
        GROUP BY star
        HAVING AVG(score) > 8.5
  );




  -- Independent Subquery - Table Subquery(Multi Col Multi Row)

-- Find the most profitable movie of each year
select * from movies
where (year ,gross - budget) in (select year, max(gross - budget) as 'profit' from movies
							group by year);
                            
-- Find the highest rated movie of each genre votes cutoff of 25000
select * from movies
where votes > 2500 and (genre, score) in (select genre , max(score) from movies
							where votes>25000
							group by genre);
                            
-- Find the highest grossing movies of top 5 actor/director combo in terms of total gross income
with top_duos as (select star, director , max(gross) from movies
					group by star, director  
					order by sum(gross) desc limit 5)

select * from movies
where (star, director , gross)  in (select * from top_duos);                




-- CORRELATED SUBQUERY 

-- "same"
-- "each"
-- "its own"
-- "within its group"
-- "compared to its category"

-- Find all the movies that have a rating higher than the average rating of movies in the same genre.
select * from  movies m1
where score > (select avg(score) from movies m2 where m1.genre = m2.genre);

-- Find the favorite food of each customer.
with fev_food as (SELECT t1.user_id, t1.name, t4.f_name, COUNT(*) as 'frequency' FROM users2 t1
					JOIN orders1 t2 ON t1.user_id = t2.user_id
					JOIN order_details1 t3 ON t2.order_id = t3.order_id
					JOIN food t4 ON t3.f_id = t4.f_id
					GROUP BY t2.user_id, t3.f_id, t1.name, t4.f_name)


select * from fev_food f1
where  frequency = (select max(frequency) from fev_food f2 where f2.user_id = f1.user_id );

-- Usage with SELECT
-- Get the percentage of votes for each movie compared to the total number of votes.
select name, (votes/ (select sum(votes) from movies)*100) as 'total' from movies;

-- Display all movie names ,genre, score and avg(score) of genre
select name, genre, score, (select avg(score) from movies m2 where m2.genre = m1.genre) as 'avg_score' from movies m1;


-- Usage with FROM
-- Display average rating of all the restaurants
select r_name, avg_rating from(select r_id, avg(restaurant_rating) as 'avg_rating' from orders1 
									group by r_id) t1 join restaurants t2 on t1.r_id = t2.r_id;
                                    
                                    
-- Usage with Having 
-- Find genres having avg score > avg score of all the movies
select genre, avg(score) from movies
group by genre
having avg(score) > (select avg(score) from movies);

-- Subquery in INSERT
INSERT INTO student_backup (student_id, name)
SELECT student_id, name
FROM students
WHERE student_id = 1;

-- Subquery in UPDATE
UPDATE employees
SET salary = salary * 1.1
WHERE salary < (
    SELECT AVG(salary)
    FROM employees
);

-- Subquery in DELETE
DELETE FROM orders
WHERE user_id IN (
    SELECT user_id
    FROM inactive_users
);




