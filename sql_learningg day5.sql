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


