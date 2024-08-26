/*
📓 What About Next Time?
Kishore has now successfully taken data from a file (extracted it), enhanced it (transformed it) and put it into a database table (loaded it). 

Along the way, he:

normalized the data from a JSON format into a relational presentation,
added the local time zone using IP address information 
calculated a timestamp in each gamer's local time zone.
added columns that can be used to group gaming events by day of week and/or time of day. 
The problem is, he did this just one time, for one file.

What if Agnie wants him to pull in a new log file, every day? That could be a lot of work!

How can Kishore automate the movement of the data all the way from the external file through to loading of the enhanced table? Generically, this can be referred to as "production-izing" the data load. 

There are a number of ways to productionize this load process, but we'll start by learning about tasks!

🥋 Create a Simple Task

The task you just created doesn't actually do anything, and it's not running anyway (did you see where it says "Suspended"?), but at least you've seen how simple it is to create one, assign a warehouse, and give it a schedule. 
*/
CREATE OR REPLACE TASK ags_game_audience.raw.load_logs_enhanced
  warehouse = 'compute_wh'
  SCHEDULE = '5 minute'
AS
  SELECT 'hello'
;


-- 🥋 SYSADMIN Privileges for Executing Tasks
USE ROLE accountadmin;
--You have to run this grant or you won't be able to test your tasks while in SYSADMIN role
--this is true even if SYSADMIN owns the task!!
GRANT EXECUTE TASK ON ACCOUNT TO ROLE sysadmin;

USE ROLE sysadmin; 

--Now you should be able to run the task, even if your role is set to SYSADMIN
EXECUTE TASK ags_game_audience.raw.load_logs_enhanced;

--the SHOW command might come in handy to look at the task 
SHOW TASKS IN ACCOUNT;

--you can also look at any task more in depth using DESCRIBE
DESCRIBE TASK ags_game_audience.raw.load_logs_enhanced;

/*
📓 Running the Task
Once we have a task, we would have to turn it "on" to start the 5 minute clock. We don't want to do that, yet, that's why we executed the task manually. 

We can manually run the task any time want, using: 
EXECUTE TASK AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

📓 Checking Task History
You can view a lot of information about the task and see it's history. 
*/

-- 🥋 Execute the Task a Few More Times
--Run the task a few times to see changes in the RUN HISTORY
EXECUTE TASK ags_game_audience.raw.load_logs_enhanced;


USE ROLE accountadmin;
SELECT *
FROM snowflake.account_usage.task_history
ORDER BY completed_time DESC
LIMIT 100;

/*
📓 Making the Task Better
We should edit the task so that it actually runs the complex logic we constructed.  

The easiest way to edit a task (especially if you are already in the main interface and on the task's page) is to click on the Open in Worksheets link. 

This opens a new worksheet and puts in a copy of the script for you. 

TIP: After the worksheet opens, check the context menus and set them appropriately. 

🎯 Use the CTAS Logic in the Task
Remember the logic we used to create our table and load it? That was called a CTAS.

We can use the logic from that CTAS statement as the logic for our task.

Copy the logic from earlier lab work, the query history, or an earlier page of this course. Replace the select 'hello'; clause of the task as currently written. 

Then, run the CREATE TASK statement to re-create a new version of the task. 
*/

USE ROLE sysadmin;

CREATE OR REPLACE TASK ags_game_audience.raw.load_logs_enhanced
  warehouse = 'compute_wh'
  SCHEDULE = '5 minute'
AS
  INSERT INTO ags_game_audience.enhanced.logs_enhanced
  SELECT 
    logs.ip_address,
    logs.user_login AS gamer_name,
    logs.user_event AS game_event_name,
    logs.datetime_iso8601 AS game_event_utc,
    city,
    region,
    country,
    timezone AS gamer_ltz_name,
    CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) AS game_event_ltz,
    DAYNAME(game_event_ltz) AS dow_name,
    lu.tod_name
  FROM ags_game_audience.raw.logs ASlogs
  INNER JOIN ipinfo_geoloc.demo.location ASloc ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
  INNER JOIN ags_game_audience.raw.time_of_day_lu AS lu ON lu.hour = HOUR(CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601))
  WHERE IPINFO_GEOLOC.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
;

-- Executing the Task to TRY to Load More Rows


--make a note of how many rows you have in the table
SELECT COUNT(*)
FROM ags_game_audience.enhanced.logs_enhanced;

--Run the task to load more rows
EXECUTE TASK ags_game_audience.raw.load_logs_enhanced;

--check to see how many rows were added (if any!)
SELECT COUNT(*)
FROM ags_game_audience.enhanced.logs_enhanced;

/*
🧂 For Seasoned Data Professionals
We get it! You can already see the issues we'll be encountering downstream. But, the issues are not obvious to some learners, yet, and we need to let them learn things through a simulated version of trial and error. Because that's how humans learn best. 

So, again, if you can see the solution and are frustrated that you can't just sprint to the end, please, take a deep breath and let these mistakes be made. It will all be alright in the end. 

📓  What is Missing? 
Why didn't the task load the records? This exact SELECT statement was enough to load the table when we used it in a CTAS.

What gives?

Consider what you think may be the solution. Use the the question below to test your hypothesis. Keep trying the question until you get it correct. When you get the answer correct, you'll know what we plan to do in the next lab. 


🎯 Convert Your Task so It Inserts Rows
1) Add this line of code just above the SELECT line in your task:

INSERT INTO AGS_GAME_AUDIENCE.ENHANCED.LOGS_ENHANCED 
2) Run the CREATE OR REPLACE TASK command. This will replace the old task with this new version. 

3) EXECUTE the task manually. (Run it a few times if you want!)

4) Check the number of rows in the table (has it changed now? - it may take a minute to finish running and how updated results)

5) Check the RUN HISTORY to make sure the task is still running without errors. 

📓 Yikes!
The task is working, but the data is piling up and NOT in a good way! 

This is where we learn a new, fancy term: IDEMPOTENCY. 

In short, it means, Kishore can't just write cool stuff that loads data, he has to design a solution that ONLY loads each record one time.

Snowflake has some built in help for IDEMPOTENCY, especially when the file is first picked up from the stage, and we'll talk more about how Snowflake can help with that, but right now we'll focus on making this particular step IDEMPOTENT.  


📓 Dump And Refresh - A Y2K Party!
In the early 2000's, a lot of data engineers would just empty a table and completely reload every single row, totally fresh, every 5 minutes. 

Let's empty the table using a truncate, and reload it with the INSERT just like we would have back in the Y2Ks! While you do it this old-school way, feel free to think of this lab work as a sort of Millennial Dance Party. 

"Okay Google, Play Toxic by Britney Spears"

🥋 Trunc & Reload Like It's Y2K!
*/

--first we dump all the rows out of the table
TRUNCATE TABLE ags_game_audience.enhanced.logs_enhanced;

--then we put them all back in
INSERT INTO ags_game_audience.enhanced.logs_enhanced (
  SELECT
    logs.ip_address,
    logs.user_login AS gamer_name,
    logs.user_event AS game_event_name,
    logs.datetime_iso8601 AS game_event_utc,
    city,
    region,
    country,
    timezone AS gamer_ltz_name,
    CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) AS game_event_ltz,
    DAYNAME(game_event_ltz) AS dow_name,
    tod_name
  FROM ags_game_audience.raw.logs ASlogs
  INNER JOIN ipinfo_geoloc.demo.location ASloc 
    ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
    BETWEEN start_ip_int AND end_ip_int
  INNER JOIN ags_game_audience.raw.time_of_day_lu AStod
    ON HOUR(game_event_ltz) = tod.hour
);

--Hey! We should do this every 5 minutes from now until the next millennium - Y3K!!!
--Alexa, play Yeah by Usher!

/*
📓 Rebuild and Replace
Another method that was used in the early days of data warehousing was a database replace. A whole new warehouse would be built each night and when it was complete, the old one would be given an archival name, and the new one would be given the standard name.

Snowflake has the ability to CLONE databases, schemas, tables and more which means this sort of switching out can be done very easily but this isn't really a version of the old-school rebuild and replace. It's pretty significantly different. That's okay, because almost no orgs rebuild their warehouses from scratch each night anymore.

On the subject of Snowflake's cloning capabilities, some organizations use cloning to create test and dev copies of entire databases, schemas or just a few of the objects within them.  So, after using modern update methods, you could delete your test and dev instances each night and replace them with fresh clones of your production warehouse. 

Cloning is a very powerful tool, doesn't cost much, and doesn't take long. Cloning is more efficient than copying (you can read more about cloning at docs.snowflake.com).  

We can also use cloning to make back ups of things we feel more comfortable having a safe copy of while we are in heavy development. Let's make a back up copy of our LOGS_ENHANCED table.  We're about to start testing some complex logic and we might want to look back at this table, later. 
*/

--clone the table to save this version as a backup
--since it holds the records from the UPDATED FEED file, we'll name it _UF

-- 🥋 Create a Backup Copy of the Table
CREATE TABLE ags_game_audience.enhanced.logs_enhanced_uf 
CLONE ags_game_audience.enhanced.logs_enhanced;

/*
📓 Sophisticated 2010's - The Merge!
After the 2000s, most Data Engineers were moving away from a full truncate and replace. Merge statements started taking center stage. Of course, Merge statements existed before 2010, but it took a minute for them to catch on. 

There was a new, more sophisticated way to move! (move...your data...from one place to another)

A SQL merge lets you compare new records to already loaded records and do different things based on what you learn by doing the comparison. 

To define a very simple merge, we'll first figure out:

Where our rows are coming from = our SOURCE. (RAW.LOGS)
Where we want to load our rows to = our TARGET.  (ENHANCED.LOGS_ENHANCED)
We want to add any new rows we find in the source. So we need to figure out which rows are new. 

Snowflake Docs gives this sample code for a simple update merge. We can use this as a template to figure out which columns we want to use to match on

Here's some merge code we can start with: 

MERGE INTO ENHANCED.LOGS_ENHANCED e
USING RAW.LOGS r
ON r.user_login = e.GAMER_NAME
WHEN MATCHED THEN
UPDATE SET IP_ADDRESS = 'Hey I updated matching rows!';
But this code will return an error because each gamer_name has more than one row in our table currently (each user has a login and a logout). 

What will we need to add to allow our merge to find unique records?
*/

/*
📓 A Working Update Merge
Adding the datetime field was enough to remove the duplicate errors, but we like to be extra safe, so we also added the event name also (e.g. 'login' and 'logoff'). 

The number of rows updated will depend on how many times you ran the task and reloaded all the rows. Run a select on your table and see if you really changed all the IP_ADDRESS values!

If we had not used the CLONE feature to make a copy of the table, we could use TIME TRAVEL to go back to the table right before we wiped out all the IP_ADDRESS values. Check out the documentation for TIME TRAVEL if you are interested in learning more.  The combination of CLONING and TIME TRAVEL can help you fix a lot of otherwise disastrous mistakes!!


📓 Merges Are Powerful
You've just seen a merge example that could be called an UPDATE MERGE. Now we'll write an INSERT MERGE. These aren't really two different things, just two different ways of using a MERGE. 

Be aware that you can write very complex merge statements that do lots of things at one time. A single MERGE statement can insert new rows, update changed rows, and delete other rows.

For now, we'll continue to keep things simple and separate. Our next merge will simply look for matches, and when it finds that a new row does NOT MATCH anything in our TARGET table, it will add that row to our TARGET table. 
*/

-- 🥋 Build Your Insert Merge
USE ROLE sysadmin;
USE DATABASE ags_game_audience;
MERGE INTO enhanced.logs_enhanced ASe
USING (
  SELECT
    logs.ip_address,
    logs.user_login AS gamer_name,
    logs.user_event AS game_event_name,
    logs.datetime_iso8601 AS game_event_utc,
    city,
    region,
    country,
    timezone AS gamer_ltz_name,
    CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) AS game_event_ltz,
    DAYNAME(game_event_ltz) AS dow_name,
    tod_name
  FROM ags_game_audience.raw.logs ASlogs
  INNER JOIN ipinfo_geoloc.demo.location ASloc 
    ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
    AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
    BETWEEN start_ip_int AND end_ip_int
  INNER JOIN ags_game_audience.raw.time_of_day_lu AStod ON HOUR(game_event_ltz) = tod.hour
) ASr
  ON r.gamer_name = e.gamer_name
  AND r.game_event_utc = e.game_event_utc
  AND r.game_event_name = e.game_event_name
WHEN NOT MATCHED THEN
  INSERT (
    ip_address,
    gamer_name,
    game_event_name,
    game_event_utc,
    city,
    region,
    country,
    gamer_ltz_name,
    game_event_ltz,
    dow_name,
    tod_name
  )
  VALUES (
    ip_address,
    gamer_name,
    game_event_name,
    game_event_utc,
    city,
    region,
    country,
    gamer_ltz_name,
    game_event_ltz,
    dow_name,
    tod_name
  )
;

/*
📓 Testing the Insert Merge
Now that we have an Insert Merge built, we should test it to see if it works. We can start by truncating the table. 

The first time we run the merge, it should load EVERY record. The second time we run the merge, it should NOT load ANY records. 
*/

-- 🥋 Truncate Again for a Fresh Start
--let's truncate so we can start the load over again
TRUNCATE TABLE ags_game_audience.enhanced.logs_enhanced;

/*
🥋 Check Your Logs Enhanced Table
Is it empty? It should be. 

🥋 Run Your Merge Statement
Does it load every row?

Because every row is NOT MATCHED, so every row in LOGS should be loaded into LOGS_ENHANCED. 
*/

/*
📓 One Bite at a Time
Did you notice our SQL command is starting to look pretty complex?

We built it one piece at a time and we know what each piece does.

This is an important lesson for beginning developers. When we encounter complex-looking code, we have to remember that it is nearly always made up of smaller parts that were built and tested one chunk at a time.

As Desmond Tutu famously said, The way to eat an elephant is one bite at a time. 

elephant

Room for one more bite? 

Add the lines of code to the top of your MERGE, to make it into a TASK!! Replace your old task with this new version! 

elephant

After creating the task, execute it to check that it succeeds. Like this: 

EXECUTE TASK AGS_GAME_AUDIENCE.RAW.LOAD_LOGS_ENHANCED;

What happens if you run it more than once? Does it create multiple copies of each record? Or is the process IDEMPOTENT? 

If you'd like to test your MERGE TASK by adding a few fake rows to the source table, you can use the code below. After testing, as long as you keep the user_login field set to something consistent like "fake user", you can easily remove the test rows from your raw data table. 
*/

CREATE OR REPLACE TASK ags_game_audience.raw.load_logs_enhanced
  warehouse='COMPUTE_WH'
  SCHEDULE='5 minute'
AS
  MERGE INTO enhanced.logs_enhanced ASe
  USING (
    SELECT
      logs.ip_address,
      logs.user_login AS gamer_name,
      logs.user_event AS game_event_name,
      logs.datetime_iso8601 AS game_event_utc,
      city,
      region,
      country,
      timezone AS gamer_ltz_name,
      CONVERT_TIMEZONE( 'UTC',timezone,logs.datetime_iso8601) AS game_event_ltz,
      DAYNAME(game_event_ltz) AS dow_name,
      tod_name
    FROM ags_game_audience.raw.logs ASlogs
    INNER JOIN ipinfo_geoloc.demo.location ASloc 
      ON ipinfo_geoloc.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
      AND ipinfo_geoloc.public.TO_INT(logs.ip_address) 
      BETWEEN start_ip_int AND end_ip_int
    INNER JOIN ags_game_audience.raw.time_of_day_lu AStod ON HOUR(game_event_ltz) = tod.hour
  ) ASr
    ON r.gamer_name = e.gamer_name
    AND r.game_event_utc = e.game_event_utc
    AND r.game_event_name = e.game_event_name
  WHEN NOT MATCHED THEN
    INSERT (
      ip_address,
      gamer_name,
      game_event_name,
      game_event_utc,
      city,
      region,
      country,
      gamer_ltz_name,
      game_event_ltz,
      dow_name,
      tod_name
    )
    VALUES (
      ip_address,
      gamer_name,
      game_event_name,
      game_event_utc,
      city,
      region,
      country,
      gamer_ltz_name,
      game_event_ltz,
      dow_name,
      tod_name
    )
;

EXECUTE TASK ags_game_audience.raw.load_logs_enhanced;


-- 🥋 Testing Cycle (Optional)


--Testing cycle for MERGE. Use these commands to make sure the Merge works as expected

--Write down the number of records in your table 
SELECT * FROM ags_game_audience.enhanced.logs_enhanced;

--Run the Merge a few times. No new rows should be added at this time 
EXECUTE TASK ags_game_audience.raw.load_logs_enhanced;

--Check to see if your row count changed 
SELECT * FROM ags_game_audience.enhanced.logs_enhanced;

--Insert a test record into your Raw Table 
--You can change the user_event field each time to create "new" records 
--editing the ip_address or datetime_iso8601 can complicate things more than they need to 
--editing the user_login will make it harder to remove the fake records after you finish testing 
INSERT INTO ags_game_audience.raw.game_logs 
SELECT PARSE_JSON('{"datetime_iso8601":"2025-01-01 00:00:00.000", "ip_address":"196.197.196.255", "user_event":"fake event", "user_login":"fake user"}');

--After inserting a new row, run the Merge again 
EXECUTE TASK ags_game_audience.raw.load_logs_enhanced;

--Check to see if any rows were added 
SELECT * FROM ags_game_audience.enhanced.logs_enhanced;

--When you are confident your merge is working, you can delete the raw records 
DELETE FROM ags_game_audience.raw.game_logs WHERE raw_log LIKE '%fake user%';

--You should also delete the fake rows from the enhanced table
DELETE FROM ags_game_audience.enhanced.logs_enhanced
WHERE gamer_name = 'fake user';

--Row count should be back to what it was in the beginning
SELECT * FROM ags_game_audience.enhanced.logs_enhanced; 


USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DNGW04' AS step,
      (
        SELECT COUNT(*)/IFF(COUNT(*) = 0, 1, COUNT(*))
        FROM TABLE(
          ags_game_audience.information_schema.task_history(task_name=>'LOAD_LOGS_ENHANCED')
        )
      ) AS actual,
      1 AS expected,
      'Task exists and has been run at least once' AS description 
  ); 