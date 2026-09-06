-- WINDOW FUNCTIONS


CREATE TABLE marks (
 student_id INTEGER PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255),
    branch VARCHAR(255),
    marks INTEGER
);

INSERT INTO marks (name,branch,marks)VALUES 
('Nitish','EEE',82),
('Rishabh','EEE',91),
('Anukant','EEE',69),
('Rupesh','EEE',55),
('Shubham','CSE',78),
('Ved','CSE',43),
('Deepak','CSE',98),
('Arpan','CSE',95),
('Vinay','ECE',95),
('Ankit','ECE',88),
('Anand','ECE',81),
('Rohit','ECE',95),
('Prashant','MECH',75),
('Amit','MECH',69),
('Sunny','MECH',39),
('Gautam','MECH',51);
 

-- Aggregate Function with OVER()
SELECT *, AVG(marks) OVER(PARTITION BY branch) AS 'avg_branch_marks' FROM marks;

-- Find all the students who have marks higher than the avg marks of their respective branch
SELECT * FROM (SELECT *, AVG(marks) OVER(PARTITION BY branch) AS 'avg_branch_marks' 
              FROM marks) t
              WHERE marks > avg_branch_marks;
              
-- RANK/DENSE_RANK/ROW_NUMBER
SELECT *, RANK() OVER(PARTITION BY branch ORDER BY marks DESC) FROM marks;

SELECT *, DENSE_RANK() OVER(PARTITION BY branch ORDER BY marks DESC) FROM marks;

SELECT *, ROW_NUMBER() OVER(PARTITION BY branch ORDER BY marks DESC) FROM marks;

-- Find top 2 most paying customers of each month
SELECT * FROM (SELECT  MONTHNAME(date) AS 'month',user_id ,SUM(amount) AS 'total',
RANK() OVER(PARTITION BY MONTHNAME(date) ORDER BY SUM(amount) DESC) AS 'rank'
FROM orders1
GROUP BY user_id , month
ORDER BY month) t
WHERE t.rank < 3;


-- FRAME

-- A frame in a window function is a subset of rows within the partition that
-- determines the scope of the window function calculation. The frame is defined
-- using a combination of two clauses in the window function: ROWS and BETWEEN.

-- The ROWS clause specifies how many rows should be included in the frame
-- relative to the current row. For example, ROWS 3 PRECEDING means that the
-- frame includes the current row and the three rows that precede it in the partition.

-- The BETWEEN clause specifies the boundaries of the frame.

-- Examples
-- • ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW - means that the
-- frame includes all rows from the beginning of the partition up to and including the
-- current row.
-- • ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING: the frame includes the
-- current row and the row immediately before and after it.
-- • ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING: the
-- frame includes all rows in the partition.
-- • ROWS BETWEEN 3 PRECEDING AND 2 FOLLOWING: the frame includes the
-- current row and the three rows before it and the two rows after it.


-- FIRST_VALUE/LAST VALUE/NTH_VALUE

SELECT *, FIRST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC) FROM marks;

SELECT *, LAST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC 
											ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) FROM marks;
                                            
SELECT *, NTH_VALUE(marks, 3) OVER(PARTITION BY branch ORDER BY marks DESC 
											ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) FROM marks;


-- Find the branch toppers
SELECT name, branch, marks FROM(SELECT *, FIRST_VALUE(name) OVER(PARTITION BY branch ORDER BY marks DESC ) AS 'topper_name' ,
		FIRST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC ) AS 'topper_marks'
		FROM marks) t
WHERE t.name = t.topper_name AND t.marks = t.topper_marks;


-- Find the last guy of each branch
SELECT name, branch, marks FROM(SELECT *, LAST_VALUE(name) OVER(PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'gawad_name', 
LAST_VALUE(marks) OVER(PARTITION BY branch ORDER BY marks DESC ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS 'gawad_marks'
FROM marks) t
WHERE t.name = t.gawad_name AND t.marks = t.gawad_marks;


-- LEAD & LAG
SELECT *, LAG(marks) OVER(),
LEAD(marks) OVER()
FROM marks;


-- Find the MoM revenue growth of Zomato
SELECT MONTHNAME(date), SUM(amount),
((SUM(amount) -LAG(SUM(amount)) OVER(ORDER BY MONTH(date)))/LAG(SUM(amount)) OVER(ORDER BY MONTH(date)))*100
FROM orders1
GROUP BY MONTH(date), MONTHNAME(date);


-- SOME OTHER WINDOW FUNCTIONS
-- RANK()
-- top 5 batsman from each team
SELECT * FROM (SELECT batter, BattingTeam, SUM(batsman_run),RANK() OVER(PARTITION BY BattingTeam ORDER BY SUM(batsman_run) DESC) AS 'rank' FROM ipl
GROUP BY batter, BattingTeam) t
WHERE t.rank<6


-- CUMULATIVE SUM
SELECT * FROM (SELECT CONCAT('Match-', ROW_NUMBER() OVER(ORDER BY ID)) AS 'Match_no', 
SUM(batsman_run) AS 'run_scored',
SUM(SUM(batsman_run)) OVER(ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS 'career_run'
FROM ipl
WHERE batter= 'V Kohli'
GROUP BY ID) t
WHERE t.Match_no = 'Match-50' OR t.Match_no = 'Match-100' OR t.Match_no = 'Match-200';

-- CUMULATIVE AVERAGE
SELECT CONCAT('Match-', ROW_NUMBER() OVER(ORDER BY ID)) AS 'match-no' ,
SUM(batsman_run) AS 'run-scored',
SUM(SUM(batsman_run)) OVER w AS 'career_run',
AVG(SUM(batsman_run)) OVER w 'career_avg_run'
FROM ipl
WHERE batter= 'V Kohli'
GROUP BY ID
WINDOW w AS (ORDER BY ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW);

-- RUNNING AVERAGE
SELECT CONCAT('Match-', ROW_NUMBER() OVER(ORDER BY ID)) AS 'match-no' ,
SUM(batsman_run) AS 'run-scored',
SUM(SUM(batsman_run)) OVER w AS 'career_run',
AVG(SUM(batsman_run)) OVER w 'career_avg_run',
AVG(SUM(batsman_run)) OVER(ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) AS 'rolling_avg'
FROM ipl
WHERE batter= 'V Kohli'
GROUP BY ID
WINDOW w AS (ORDER BY ID ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW);

-- PERCENT OF TOTAL
SELECT f_name,
(total_value/SUM(total_value) OVER())*100 AS 'percent_of_total'
FROM (SELECT f_id,SUM(amount) AS 'total_value' FROM orders1 t1
JOIN order_details1 t2
ON t1.order_id = t2.order_id
WHERE r_id = 1
GROUP BY f_id) t
JOIN food t3
ON t.f_id = t3.f_id
ORDER BY (total_value/SUM(total_value) OVER())*100 DESC;


-- PERCENT CHANGE
-- Percent Change = ((new value - old value)/old value)/100
SELECT YEAR(Date),MONTHNAME(Date),SUM(views) AS 'views',
((SUM(views) - LAG(SUM(views)) OVER(ORDER BY YEAR(Date),MONTH(Date)))/LAG(SUM(views)) OVER(ORDER BY YEAR(Date),MONTH(Date)))*100 AS 'Percent_change'
FROM youtube_views
GROUP BY YEAR(Date),MONTH(Date)
ORDER BY YEAR(Date),MONTH(Date);

SELECT *,
((Views - LAG(Views,7) OVER(ORDER BY Date))/LAG(Views,7) OVER(ORDER BY Date))*100 AS 'weekly_percent_change'
FROM youtube_views;


-- Percentiles & Quantiles
SELECT *,
PERCENTILE_DISC(0.5) WITHIN GROUP(ORDER BY marks) OVER(PARTITION BY branch) AS 'median_marks',
PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY marks) OVER(PARTITION BY branch) AS 'median_marks_cont'
FROM marks; 
-- current MySQL version does not support PERCENTILE_DISC() or PERCENTILE_CONT() but work in other database


SELECT * FROM (SELECT *,
PERCENTILE_CONT(0.25) WITHIN GROUP(ORDER BY marks) OVER() AS 'Q1',
PERCENTILE_CONT(0.75) WITHIN GROUP(ORDER BY marks) OVER() AS 'Q3'
FROM marks) t
WHERE t.marks <= t.Q1 - (1.5*(t.Q3 - t.Q1)) AND t.marks >= t.Q3 + (1.5*(t.Q3 - t.Q1));
-- to filter outliers values


-- SEHMENTATION: 
	-- Segmentation using NTILE is a technique in SQL for dividing a dataset into equal-
	-- sized groups based on some criteria or conditions, and then performing
	-- calculations or analysis on each group separately using window functions.
SELECT *,
NTILE(3) OVER(ORDER BY marks DESC) AS 'buckets'
FROM marks;

SELECT brand_name,model,price, 
CASE 
	WHEN bucket = 1 THEN 'budget'
    WHEN bucket = 2 THEN 'mid-range'
    WHEN bucket = 3 THEN 'premium'
END AS 'phone_type'
FROM (SELECT brand_name,model,price,
NTILE(3) OVER(PARTITION BY brand_name ORDER BY price) AS 'bucket' 
FROM smartphones) t;


-- Cumulative Distribution
-- CUME_DIST(): Its main use is to find what proportion/percentage of rows have a value less than or equal to the current row's value.
SELECT * FROM (SELECT *,
CUME_DIST() OVER(ORDER BY marks) AS 'Percentile_Score'
FROM marks) t
WHERE t.Percentile_Score > 0.90;


-- Partition By multiple columns
SELECT * FROM (SELECT source,destination,airline,AVG(price) AS 'avg_fare',
DENSE_RANK() OVER(PARTITION BY source,destination ORDER BY AVG(price)) AS 'rank'
FROM flights
GROUP BY source,destination,airline) t
WHERE t.rank < 2


