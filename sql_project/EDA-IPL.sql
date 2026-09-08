-- INITIAL EXPLORATION
select * from ipl; -- This is ball-by-ball IPL data (each row = one delivery)

-- Row count and grain check
SELECT COUNT(*) AS total_balls, COUNT(DISTINCT ID) AS total_matches
FROM ipl;

-- Preview
SELECT * FROM ipl LIMIT 20;

-- Column data types
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'ipl';

-- Innings range check (should be 1,2, maybe 3,4 for super overs)
SELECT DISTINCT innings 
FROM ipl 
ORDER BY innings;

-- Overs range check 
SELECT MIN(overs), MAX(overs) FROM ipl;

-- Ball number range (should be 1–6, sometimes up to 7-8 with wides/no-balls)
SELECT MIN(ballnumber), MAX(ballnumber) FROM ipl;




-- DATA CLEANING
-- Check NULLs across all columns
SELECT 
    COUNT(*) - COUNT(batter) AS null_batter,
    COUNT(*) - COUNT(bowler) AS null_bowler,
    COUNT(*) - COUNT(extra_type) AS null_extra_type,      -- expected: most balls have no extra
    COUNT(*) - COUNT(player_out) AS null_player_out,       -- expected: most balls have no wicket
    COUNT(*) - COUNT(kind) AS null_kind,                   -- dismissal kind, expected mostly null
    COUNT(*) - COUNT(fielders_involved) AS null_fielders,  -- expected mostly null
    COUNT(*) - COUNT(BattingTeam) AS null_battingteam
FROM ipl;
-- extra_type, player_out, kind, fielders_involved are legitimately NULL most of the time (no extra, no wicket that ball). NULL here is meaningful, not missing data.

-- Handle legitimate NULLs
SELECT 
    COALESCE(extra_type, 'none') AS extra_type_clean,
    COALESCE(player_out, 'not out') AS player_out_clean,
    COALESCE(kind, 'no dismissal') AS kind_clean,
    COALESCE(fielders_involved, 'none') AS fielders_involved_clean
FROM ipl;

-- Check for duplicate deliveries
SELECT ID, innings, overs, ballnumber, COUNT(*)
FROM ipl
GROUP BY ID, innings, overs, ballnumber
HAVING COUNT(*) > 1;

-- batsman_run should be 0-6
SELECT DISTINCT batsman_run FROM ipl ORDER BY batsman_run;

-- total_run should equal batsman_run + extras_run
SELECT * FROM ipl
WHERE total_run != batsman_run + extras_run;

-- Standardize team names
SELECT DISTINCT BattingTeam FROM ipl ORDER BY BattingTeam;

UPDATE ipl SET BattingTeam = 'Delhi Capitals' WHERE BattingTeam = 'Delhi Daredevils';
UPDATE ipl SET BattingTeam = 'Punjab Kings' WHERE BattingTeam = 'Kings XI Punjab';
UPDATE ipl SET BattingTeam = 'Royal Challengers Bengaluru' WHERE BattingTeam = 'Royal Challengers Bangalore';

-- Standardize/trim player name inconsistencies
SELECT DISTINCT batter FROM ipl ORDER BY batter;
-- look for spacing/case issues, e.g. 'MS Dhoni' vs 'M S Dhoni'
UPDATE ipl SET batter = TRIM(batter);

-- Validate isWicketDelivery flag consistency
-- if isWicketDelivery = 1, player_out and kind should NOT be null
SELECT * FROM ipl
WHERE isWicketDelivery = 1 AND (player_out IS NULL OR kind IS NULL);

-- Validate extras logic
-- if extra_type is null, extras_run should be 0
SELECT * FROM ipl
WHERE extra_type IS NULL AND extras_run <> 0;

-- if extra_type is not null, extras_run should be > 0
SELECT * FROM ipl
WHERE extra_type IS NOT NULL AND extras_run = 0;





-- Exploratory Data Analysis(EDA)

-- Runs per match
select ID, sum(total_run) as 'match_runs'from ipl
group by ID
order by match_runs desc
limit 10;

-- Top run scorers (batters)
SELECT batter, SUM(batsman_run) AS total_runs, COUNT(DISTINCT ID) AS matches_played
FROM ipl
GROUP BY batter
ORDER BY total_runs DESC
LIMIT 10;

-- Strike rate per batter
select batter, sum(batsman_run) as 'total_run', count(*) 'balls_faced',round((sum(batsman_run)/count(*))* 100, 2) as 'stike_rate' from ipl
WHERE extra_type IS NULL OR extra_type NOT IN ('wides')
group by batter
HAVING COUNT(*) > 200
order by stike_rate desc;

-- Top wicket-taking bowlers
SELECT bowler, COUNT(*) AS wickets FROM ipl
WHERE isWicketDelivery = 1 AND kind NOT IN ('run out') 
GROUP BY bowler
ORDER BY wickets DESC
LIMIT 10;

-- Bowler economy rate
SELECT 
    bowler,
    SUM(total_run - COALESCE(CASE WHEN extra_type IN ('byes','legbyes') THEN extras_run ELSE 0 END,0)) AS runs_conceded,
    COUNT(*) AS balls_bowled,
    ROUND(SUM(total_run) * 6.0 / COUNT(*), 2) AS economy_rate
FROM ipl
GROUP BY bowler
HAVING COUNT(*) > 300
ORDER BY economy_rate ASC
LIMIT 10;

-- Dismissal type breakdown
SELECT kind, COUNT(*) AS frequency
FROM ipl
WHERE isWicketDelivery = 1
GROUP BY kind
ORDER BY frequency DESC;

-- Team-wise total runs and matches
select BattingTeam, count(DISTINCT ID) as 'matches', sum(total_run) as 'total_run' from ipl
group by BattingTeam
order by total_run desc;

-- Over-wise scoring pattern (powerplay vs death overs)
SELECT 
    overs,
    AVG(total_run) AS avg_runs_per_ball,
    SUM(total_run) AS total_runs_this_over_across_matches
FROM ipl
GROUP BY overs
ORDER BY overs;

-- Innings comparison (1st vs 2nd innings scoring pattern — win-toss/chase insight)
SELECT innings, AVG(total_run) AS avg_run_per_ball, SUM(isWicketDelivery) AS total_wickets
FROM ipl
GROUP BY innings;

-- Highest individual scores in a single match
SELECT ID, batter, SUM(batsman_run) AS runs_in_match
FROM ipl
GROUP BY ID, batter
ORDER BY runs_in_match DESC
LIMIT 10;

-- Rank batters by total runs within each team
select * from (select BattingTeam, batter, sum(batsman_run) as 'total_runs', dense_rank() over(partition by BattingTeam order by sum(batsman_run) desc) as 'batter_rank' 
            from ipl
			group by BattingTeam, batter) t
where batter_rank <=10;

-- Rank overs by runs scored, per match/innings (find the costliest over)
SELECT 
    ID, innings, overs,
    SUM(total_run) AS runs_in_over,
    RANK() OVER (PARTITION BY ID, innings ORDER BY SUM(total_run) DESC) AS over_rank
FROM ipl
GROUP BY ID, innings, overs
ORDER BY ID, innings, over_rank;

-- Detect scoring pattern shifts (e.g., runs after a wicket falls)
SELECT 
    ID, innings, overs, ballnumber, total_run, isWicketDelivery,
    LAG(isWicketDelivery) OVER (PARTITION BY ID, innings ORDER BY overs, ballnumber) AS prev_ball_wicket,
    LEAD(total_run) OVER (PARTITION BY ID, innings ORDER BY overs, ballnumber) AS next_ball_run
FROM ipl
ORDER BY ID, innings, overs, ballnumber;

--  Batters who scored above the overall average runs per match
SELECT batter, SUM(batsman_run) AS total_runs
FROM ipl
GROUP BY batter
HAVING SUM(batsman_run) >(SELECT AVG(runs)FROM
									   (SELECT SUM(batsman_run) AS runs
											FROM ipl
											GROUP BY batter ) t);
   

-- Top 3 run scorers per team (classic "top N per group" pattern)
SELECT BattingTeam, batter, total_runs
FROM (SELECT BattingTeam, batter, SUM(batsman_run) AS total_runs,
           DENSE_RANK() OVER (PARTITION BY BattingTeam ORDER BY SUM(batsman_run) DESC) AS rnk
           FROM ipl
           GROUP BY BattingTeam, batter) ranked
WHERE rnk <= 3
ORDER BY BattingTeam, rnk;

-- Each team's best bowler by wickets
SELECT BattingTeam, bowler, wickets
FROM (SELECT BattingTeam, bowler, COUNT(*) AS wickets,
        RANK() OVER (PARTITION BY BattingTeam ORDER BY COUNT(*) DESC) AS rnk
		FROM ipl
		WHERE isWicketDelivery = 1
		GROUP BY BattingTeam, bowler) ranked
WHERE rnk = 1
ORDER BY wickets DESC;