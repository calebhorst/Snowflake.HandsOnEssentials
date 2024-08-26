/*
🎯 Turn Things Off
If you have any tasks running, turn them off. 
If your pipe is running, you should pause it. Using something like: 
alter pipe mypipe set pipe_execution_paused = true;
We will not use the tasks or pipes any more in this course. Instead, we'll talk a little more about data, and then you'll be done. 

📓 Create a CURATED Layer
Sometimes a Data Engineer's job is done once the data has been enhanced.

In some organizations, anything that involves moving beyond the row level, and into some kind of aggregation or analysis is not the job of a Data Engineer. 

But in some other organizations, a Data Engineer will move data beyond the Enhanced level, into a Curated state. When that happens, the Data Engineer is adding additional processing that may help analysts and data scientists do their work faster, and/or more effectively. 

In this last lesson, we'll be creating some dashboard charts so we can do some light analysis to check data quality. We'll also look at a windowing function that could be used to to roll-up rows into a smaller, more meaningful data set. 

🎯 Create a CURATED Layer
Create a SCHEMA named CURATED in the AGS_GAME_AUDIENCE database.
Make sure the schema is owned by SYSADMIN.
*/
USE ROLE sysadmin;
USE ags_game_audience.raw;


ALTER PIPE ags_game_audience.raw.pipe_get_new_files SET PIPE_EXECUTION_PAUSED = TRUE;

SHOW TASKS;
ALTER TASK raw.cdc_load_logs_enhanced SUSPEND;

-- 🎯 Create a CURATED Layer
CREATE SCHEMA IF NOT EXISTS ags_game_audience.curated;

/*
📓 Snowflake Dashboards
Snowflake has dashboards that can be used to display charts and tables together. These dashboards are not as sophisticated as the ones that can be created with tools like Tableau or Looker, but they can be used for some light analysis on the data. Dashboards are still a new part of Snowflake and many improvements are planned for future releases, but right now they are limited. 

Since Kishore's goal was to load the data and let Agnie analyze her audience, he wasn't asked to take the data any further, but he wants to do some simple data visualizations before he hands to project back to her and allow her to do a fuller analysis. 

🥋 Create a New Dashboard and Add a Tile

🥋 Create a Chart
Remember that clone we made of our original logs_enhanced table? We named it LOGS_ENHANCED_UF and it only had a about a 150 rows in it. We'll use that for our chart. 
*/
SELECT DISTINCT
  gamer_name,
  city
FROM ags_game_audience.enhanced.logs_enhanced_uf;

/*
You can drag the tiles into different positions. You can also do some adjustments on the heights and widths. 

If two Gamer Cities tiles appear on the page -- one with a table and one with the chart -- don't delete the table tile. Instead, right-click on it and choose UNPLACE TILE. 

📓 So, Where is Agnie's Audience Playing From? 
Most Agnie's gaming audience is in Denver, Colorado, USA. This makes a lot of sense, since Kishore, Agnie and Tsai all live, work and socialize there and have been telling friends and family about their fun project.

Warsaw, Poland is less obvious until Agnie reveals that her aunt, uncle and cousins live in Warsaw. One of her cousins has been promoting the game on a Warsaw Gamers message board. 

Gdansk, Poland is where Agnie's grandparents live.

Kenosha and Sheboygan, Wisconsin, are cities where Agnie grew up and went to college. She posted about her game on her social media accounts, her school friends must have given the game a try!

Tsai's sister is doing a semester abroad in Kenya. 

🎯 Add a Time of Day Chart
Duplicate a tile.
Edit it so that the name is "Time of Day".
Use this code for the query:
*/
SELECT
  tod_name AS time_of_day,
  COUNT(*) AS tally
FROM ags_game_audience.enhanced.logs_enhanced_uf 
GROUP BY  tod_name
ORDER BY tally DESC;     

/*
📓 Data and Dashboard Limitations
The data being written to the stage files only covers a three-day period, so the fact that our heatmap only has 3 days is not surprising. 

As mentioned earlier, Snowflake Dashboards have room for improvement. For now, we only use them for light analysis, not for production dashboards. 

📓 What Matters Most?
Kishore has been looking at the ENHANCED_LOGS charts he created and he thinks Agnie will be interested in seeing the charts he created. 

He notices that he's getting two events for every gamer and he doesn't think the actual login and logout data will be very valuable to Agnie, but the total amount of time each gamer played -- a "game_session_length" might be something really interesting and valuable. He wants to see if the time of day a person played the game showed a strong or weak correlation to the length of time they played. 

Even though Agnie hasn't asked for it, Kishore decides to spend a half hour seeing how easy it might be to calculate the session length and analyze it with the time of day labels they assigned. 
*/

--  🥋 Rolling Up Login and Logout Events with ListAgg
--the ListAgg function can put both login and logout into a single column in a single row
-- if we don't have a logout, just one timestamp will appear
SELECT
  gamer_name,
  LISTAGG(game_event_ltz,' / ') AS login_and_logout
FROM ags_game_audience.enhanced.logs_enhanced 
GROUP BY gamer_name;

/*
This is a quick and easy way to aggregate rows, but our goal with rolling up the rows is to compare the times the users logs in and out of the system so we can get a metric on how long they played the game. We will need a more sophisticated method to get this done. 
*/
-- 🥋 Windowed Data for Calculating Time in Game Per Player
SELECT
  gamer_name,
  game_event_ltz AS login,
  LEAD(game_event_ltz) 
    OVER (
      PARTITION BY gamer_name 
      ORDER BY game_event_ltz
    ) AS logout,
  COALESCE(DATEDIFF('mi', login, logout),0) AS game_session_length
FROM ags_game_audience.enhanced.logs_enhanced
ORDER BY game_session_length DESC;

--  🥋 Code for the Heatgrid
--We added a case statement to bucket the session lengths
SELECT
  CASE WHEN game_session_length < 10 THEN '< 10 mins'
    WHEN game_session_length < 20 THEN '10 to 19 mins'
    WHEN game_session_length < 30 THEN '20 to 29 mins'
    WHEN game_session_length < 40 THEN '30 to 39 mins'
    ELSE '> 40 mins' 
  END AS session_length,
  tod_name
FROM (
  SELECT
    gamer_name,
    tod_name,
    game_event_ltz AS login,
    LEAD(game_event_ltz) 
      OVER (
        PARTITION BY gamer_name 
        ORDER BY game_event_ltz
      ) AS logout,
    COALESCE(DATEDIFF('mi', login, logout),0) AS game_session_length
  FROM ags_game_audience.enhanced.logs_enhanced_uf
)
WHERE logout IS NOT NULL;

/*
🎯 Add a Heatgrid for Session Length x Time of Day
Can you add a Heatgrid to your dashboard that uses the Windowed data aggregation to show the correlation between time of day and the length of a session? (Too bad we can't sort the time of day properly, so just let the dashboard do whatever it does!) 
*/

USE util_db.public;
USE ROLE accountadmin;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DNGW07' AS step,
      (
        SELECT COUNT(*)/COUNT(*) FROM snowflake.account_usage.query_history
        WHERE query_text LIKE '%case when game_session_length < 10%'
      ) AS actual,
      1 AS expected,
      'Curated Data Lesson completed' AS description
  ); 

-- the view takes time to populate
SELECT *
FROM snowflake.account_usage.query_history
--order by execution_time desc;
WHERE query_text LIKE '%case when game_session_length < 10%'
;