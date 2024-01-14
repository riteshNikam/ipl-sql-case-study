CREATE DATABASE ipl;

USE ipl;

-- WHAT ARE THE TOP 5 PLAYERS WITH THE MOST PLAYER OF THE MATCH AWARDS?

SELECT 
    player_of_match,
    COUNT(id) AS number_of_awards
FROM matches
GROUP BY player_of_match
ORDER BY COUNT(id) DESC LIMIT 5;

-- HOW MANY MATCHES WERE WON BY EACH TEAM IN EACH SEASON?

SELECT 
	season,
    winner,
    COUNT(id) number_of_wins
FROM matches
GROUP BY season, winner;

-- WHAT IS THE AVERAGE STRIKE RATE OF BATSMEN IN THE IPL DATASET?

SELECT ROUND(AVG(strike_rate), 2) AS avg_strike_rate FROM (
	SELECT 
		batsman,
		ROUND(SUM(batsman_runs) / COUNT(ball) * 100, 2) AS strike_rate
	FROM deliveries
	GROUP BY batsman
) AS temp;

-- WHAT IS THE NUMBER OF MATCHES WON BY EACH TEAM BATTING FIRST VERSUS BATTING
-- SECOND?

SELECT batting_first, COUNT(*) AS number_of_wins FROM
(
	SELECT
		CASE
			WHEN win_by_runs > 0 THEN team1
			ELSE team2
		END AS batting_first
	FROM matches
	WHERE winner != 'TIE'
) AS temp
GROUP BY batting_first;

SELECT batting_second, COUNT(*) AS number_of_wins FROM 
(
SELECT 
	CASE
		WHEN win_by_runs > 0 THEN team2
		ELSE team1
	END AS batting_second
FROM matches
WHERE winner != 'TIE'
) AS temp GROUP BY batting_second;

-- WHICH BATSMAN HAS THE HIGHEST STRIKE RATE (MINIMUM 200 RUNS SCORED)?

SELECT batsman, ROUND((runs / balls_faced * 100), 2) AS strike_rate FROM 
(
	SELECT 
		batsman, 
		SUM(batsman_runs) as runs,
		COUNT(ball) AS balls_faced
	FROM deliveries
	GROUP BY batsman
) AS temp
WHERE runs > 200
ORDER BY strike_rate DESC LIMIT 1;

-- HOW MANY TIMES HAS EACH BATSMAN BEEN DISMISSED BY THE BOWLER 'MALINGA'?

SELECT 
	player_dismissed, 
    COUNT(*) AS number_of_dismissals FROM deliveries 
WHERE bowler = 'SL Malinga' AND player_dismissed != 'NULL'
GROUP BY player_dismissed;

-- WHAT IS THE AVERAGE PERCENTAGE OF BOUNDARIES (FOURS AND SIXES
-- COMBINED) HIT BY EACH BATSMAN?

SELECT
	batsman,
    ROUND(AVG(
		CASE
			WHEN batsman_runs=4 OR batsman_runs=6 THEN 1 
			ELSE 0 
		END
    ) * 100, 2) AS average_boundaries
FROM deliveries GROUP BY batsman;

-- WHAT IS THE AVERAGE NUMBER OF BOUNDARIES HIT BY EACH TEAM IN EACH SEASON?

SELECT 
	batting_team,
	ROUND(AVG(
		CASE
			WHEN batsman_runs = 4 OR batsman_runs = 6 THEN 1
			ELSE 0
		END
	) * 100, 2) AS average_boundraries
FROM deliveries GROUP BY batting_team;

-- HOW MANY EXTRAS (WIDES & NO-BALLS) WERE BOWLED BY EACH TEAM IN EACH MATCH?

SELECT 
	match_id,
	batting_team,
    SUM(extra_runs) AS extras
FROM deliveries
GROUP BY match_id, batting_team;

-- WHICH BOWLER HAS THE BEST BOWLING FIGURES (MOST WICKETS TAKEN) IN A SINGLE
-- MATCH?

SELECT 
	match_id,
	bowler,
    SUM(dismissed) AS dismissals
FROM (
	SELECT
		match_id,
		bowler,
		CASE 
			WHEN player_dismissed = NULL THEN 0
			ELSE 1
		END AS dismissed
	FROM deliveries
	WHERE dismissal_kind != 'run out'
) AS temp
GROUP BY match_id, bowler
ORDER BY dismissals DESC LIMIT 1;

-- HOW MANY MATCHES RESULTED IN A WIN FOR EACH TEAM IN EACH CITY?

SELECT
	city,
    winner AS team,
    COUNT(id) AS number_of_wins
FROM matches
GROUP BY city, winner
ORDER BY city;

-- HOW MANY TIMES DID EACH TEAM WIN THE TOSS IN EACH SEASON?

SELECT
	season,
    toss_winner,
    COUNT(id) AS number_of_matches
FROM matches
GROUP BY season, toss_winner;

-- HOW MANY MATCHES DID EACH PLAYER WIN THE "PLAYER OF THE MATCH" AWARD?

select player_of_match,count(*) as total_wins
from matches 
where player_of_match is not null
group by player_of_match
order by total_wins desc;

-- WHAT IS THE AVERAGE NUMBER OF RUNS SCORED IN EACH OVER OF THE INNINGS IN
-- EACH MATCH?

SELECT
	match_id,
    inning,
    over_no,
    ROUND(AVG(total_runs), 1) AS average_runs
FROM deliveries
GROUP BY match_id, inning, over_no;

-- WHICH TEAM HAS THE HIGHEST TOTAL SCORE IN A SINGLE MATCH?

SELECT 
	batting_team AS team,
    total_runs AS runs
FROM (
SELECT 
	match_id,
    batting_team,
    SUM(total_runs) AS total_runs,
    RANK() OVER (PARTITION BY match_id ORDER BY SUM(total_runs) DESC) as ranked
FROM deliveries
GROUP BY match_id, batting_team
) AS temp
WHERE ranked = 1
ORDER BY total_runs DESC LIMIT 1;

-- WHICH BATSMAN HAS SCORED THE MOST RUNS IN A SINGLE MATCH?

SELECT 
	batsman,
    runs
FROM (
	SELECT 
		match_id,
		batsman,
		SUM(batsman_runs) AS runs,
		RANK() OVER (PARTITION BY match_id ORDER BY SUM(batsman_runs) DESC) AS ranked
	FROM deliveries
	GROUP BY match_id, batsman
) AS temp 
WHERE ranked = 1
ORDER BY runs DESC LIMIT 1;

