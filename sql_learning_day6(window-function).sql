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

