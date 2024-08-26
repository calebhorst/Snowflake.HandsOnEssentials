/*
📓  Time Zones Around the World
Data comes into many data-driven organizations from all over the world. Because of this, understanding how time zones work is a critical skill for a Data Engineer.

Just as the Prime Meridian (Zero Longitude) flows through Greenwich, England, United Kingdom, the time in that region has historically been used as THE starting point for other time zones. 

Many times you will see a time or time zone listed using a code like GMT+3 or GMT-4. The first example, GMT+3 could be read as, "Whatever time it is in Greenwich, England, plus 3 hours." The second example, GMT-4 could be read as, "Whatever time it is in Greenwich, England, minus 4 hours."

But people who live in Ghana, the Gambia or Greenland might not like referring to their home time zone by comparing it to Greenwich, England. This is one of several reasons UTC was created. UTC is a less UK-centric way of talking about time even though GMT+0 and UTC+0 result in the same timestamps.  

UTC stands for Universal Time, Coordinated (or Universal Coordinated Time, if you prefer).

The same time zone as GMT+0/UTC+0 is sometimes also called Zulu Time. This is based on military parlance where the letter Z is referred to as "Zulu." The Zulu people of KwaZulu-Natal actually happen to be in UTC+2.

You can read more about the nuances between these three standards but for this course, we will be talking about and using the UTC standard. 

The image above is from timeanddate.com. The Time and Date website has an interactive version of the image above that you can use to explore time zones. 

You'll need to know a few more initialisms for this lesson. NTZ means "No Time Zone." LTZ means "Local Time Zone." 

📓 UTC Timestamp Storage Parts/Format
format

YYYY means the 4-digit Year. 
MM means the 2-digit Month. 
DD means the 2-digit Day. 
HH is for the hour, usually on a 24 hour clock. 
MI is for the 2-digit Minutes past the hour. 
SS.SSS stands for 2-digit Seconds and 3-digit Milliseconds. 
+/- tells you the DIRECTION of OFFSET from UTC+0
HH:MI shows the offset hour and minute amount that the time represents from UTC. 

📓  Kishore & Agnie's LTZ
Kishore and Agnieszka live in Denver, Colorado, USA. So what is their LTZ, expressed in UTC? 

Kishore runs the command SELECT current_timestamp(); in a worksheet (in October) and sees -0600 as part of the results.

-0600 is the same thing as UTC-6.

This means Kishore's Snowflake session is currently using the Denver time zone. 

What time zone is your Snowflake Trial Account using?  Run the current_timestamp() command to find out. Our guess is that you'll see either UTC-7 (-0700) or UTC-8 (-0800) depending on the time of year it is (daylight savings time).

We can guess this because all Snowflake Trial Account use "America/Los_Angeles" as the default. This may be because Snowflake was founded in San Mateo, California, USA. 
*/

--what time zone is your account(and/or session) currently set to? Is it -0700?
SELECT CURRENT_TIMESTAMP();

--worksheets are sometimes called sessions -- we'll be changing the worksheet time zone
ALTER SESSION SET timezone = 'UTC';
SELECT CURRENT_TIMESTAMP();

--how did the time differ after changing the time zone for the worksheet?
ALTER SESSION SET timezone = 'Africa/Nairobi';
SELECT CURRENT_TIMESTAMP();

ALTER SESSION SET timezone = 'Pacific/Funafuti';
SELECT CURRENT_TIMESTAMP();

ALTER SESSION SET timezone = 'Asia/Shanghai';
SELECT CURRENT_TIMESTAMP();

--show the account parameter called timezone
SHOW PARAMETERS LIKE 'timezone';

-- Snowflake uses the IANA list. You can see it here: https://data.iana.org/time-zones/tzdb-2021a/zone1970.tab

/*
📓 Time Zones in Agnie's Data
If we look at the records in our LOGS view we can explore the time zone information in the log dates.  You should be aware that how the data is presented and how the data is stored can be different, so make sure you know how the formatting options work.  log results

When no time zone is captured, it's hard to know when the events actually happened. There are many possibilities. For example, any of the below scenarios could be true:

Datetime info was captured in the players' local time, but the time zone info was lost along the way. 
Datetime info was captured in the players' local time, but the data was converted to UTC before being made available to Agnie.
 The game captured the datetime info in the server's default time, but the server's time zone information was lost along the way. 
 The game captured the datetime info in the server's default time, but the data was converted to UTC before being made available to Agnie.
 Some other capture and convert/loss scenario. 
In short, the lack of a timezone can mean we know the time zone and it is in a standardized, zero-offset form OR it can mean we don't know what the original time zone was. 

It can also sometimes mean that the time zone is stored in a separate column and you are expected to combine the two values when you compare two different timestamps. 

📓 How Can We Find Out More About the Timezone of Agnie's Log Data? 
The team needs to find out how the datetime data is being captured.  There are common methods for learning about source data. 

Ask someone who knows, or might know. 
Look at some documentation, somewhere.
Create your own test records and compare what you know to what flows through. 
Most teams will use a combination of all three of the methods. Sometimes a team will use one method to start, and another to confirm.

🖼�\x8f The Team Members Each Take an "Action Item"
split up the work

Tsai is going to try to contact the game platform developers and see what they can tell her. 

Kishore is going to generate some test data he can use to compare what he knows with what he gets from the feed. 

Agnie's going to see what she can find in the online documentation and online forums. 


🖼�\x8f Agnie Checks the Docs and Message Boards
docs

Agnie searches the online documentation of the game platform but isn't able to learn how the datetime_iso8601 data is captured and stored. Different message board postings seem to contradict each other.

She does find a list of fields she can add to the feed right away which is cool information, even if it wasn't actually what she was looking for. The list has a column that indicates which fields can be added for now and which are planned for future releases. She emails a link to the information to Kishore and Tsai. 

🖼�\x8f Kishore Generates Test Data
docs

Kishore has his sister, Prajina, log in to the game for a few minutes of play time. As Prajina plays, Kishore keeps notes regarding the local times she starts and stops playing so that he can compare those events to what appears in the data they download next time.  

He also looks over the list of available fields sent by Agnie. He decides the AGENT field isn't really needed but the IP_ADDRESS could be very helpful. He messages Tsai and Agnie his thoughts on the updated column list. 

🖼�\x8f Tsai Finds a Contact Who Works On the Game Platform
docs

A few days later, Tsai is able to get in touch with a member of game platform development team. The platform developer promises to research how the datetime_iso8601 field is captured, and see what they can uncover about whether the information is converted to UTC before being stored.

The developer is able to confirm that an LTZ field won't be available in the feed for another 6 to 8 months. If Kishore and Agnie want that information in their data, they'll have to figure out a different way to get it.  
*/

/*
🖼�\x8f Agnie Downloads an Updated Log File!
docs

After confirming with Tsai and Kishore on Discord, Agnie adds IP_ADDRESS to the list of fields in the feed and removes AGENT. Then, she outputs a new file.

Kishore already gave her read/write access to his S3 bucket (uni-kishore), so she creates a folder named "updated_feed" and loads the new file into it. 

Now it's time for Kishore (and YOU!) to check for that new file, view the records pre-load ($1!), load them, and view them again using the LOGS view. 



🎯 CHALLENGE: Update Your Process to Accommodate the New File
Find the new file Agnie downloaded from the game platform by listing files in the stage you already set up. Agnie put it in a different folder. It's not in the "kickoff" folder. 
Assess whether the GAME_LOGS table will need to be modified to accommodate the added IP_ADDRESS field. 
If GAME_LOGS table needs to be changed, change it. 
Load the file into the GAME_LOGS table.  To do this, you can likely make one adjustment to the COPY INTO command you ran earlier. 
TIPS

Do not remove the old rows (or if you do remove them by accident, re-load them). 
Remember that our previous load was done with a COPY INTO pointed at the folder "kickoff." This new file is in a different folder. 
Look at the data in the GAME_LOGS table after you load it. Understand how the second set of rows differs from the first set that was loaded. 
didn't break

Good News! For Kishore, at least, the table did not have any issues accommodating the variation in the files. 
*/

LIST @ags_game_audience.raw.uni_kishore/;

-- updated_feed/DNGW_updated_feed_0_0_0.json

SELECT $1
FROM
  @ags_game_audience.raw.uni_kishore/updated_feed/DNGW_updated_feed_0_0_0.json
  (FILE_FORMAT => ags_game_audience.raw.ff_json_logs)
;


SELECT *
FROM ags_game_audience.raw.game_logs
;


COPY INTO ags_game_audience.raw.game_logs
FROM @ags_game_audience.raw.uni_kishore/updated_feed/DNGW_updated_feed_0_0_0.json
FILE_FORMAT = (FORMAT_NAME = ags_game_audience.raw.ff_json_logs)
;

/*
🎯 CHALLENGE: Filter Out the Old Rows
Can you write a select statement that will filter out the old rows? Remember that one column was added and another was removed. Using one or both of these fields can you write a SELECT that will return only rows from the second file? 

TIPS

What field was removed? That column will be empty in the new rows. 
What column was added? The column will NOT be empty in the new rows. 
*/

SELECT *
FROM ags_game_audience.raw.logs
WHERE agent IS NULL
;

/*
📓 Filter Out the Old Records
Remember that the first set of records included the AGENT field, but in the second set of records would have an empty AGENT value. 

The first set of records did NOT include IP_ADDRESS, but in the second set of records, there should be an IP_ADDRESS. 

We used this knowledge to write two different select statements. 

You may see the term "schema-on-read" noted in some articles and posts as a great benefit Snowflake is able to provide. In a sense, you are seeing schema-on-read in action, here, because we can load anything we want into a VARIANT column, and parse it out (read it) differently over time. The change in the columns included (the schema difference in the two data loads) doesn't break anything because we are reading the structure after the load, not before or during the data load. 
*/

-- 🥋 Two Filtering Options
--looking for empty AGENT column
SELECT * 
FROM ags_game_audience.raw.logs
WHERE agent IS NULL;

--looking for non-empty IP_ADDRESS column
SELECT 
  raw_log:ip_address::TEXT AS ip_address,
  *
FROM ags_game_audience.raw.logs
WHERE raw_log:ip_address::TEXT IS NOT NULL;

/*
🎯 CHALLENGE: Update Your LOGS View
Change the LOGS view definition so that it no longer contains an AGENT column.  ( Instead of create view, you will need create or replace view)
Change the LOGS view definition so that it now contains the IP_ADDRESS column.
Add a WHERE clause that will exclude the first set of records from the view results. Do NOT remove the rows from the table. 
TIPS

If you remove the old rows by accident, re-load them. 
The order of the columns doesn't matter. 
After the changes, your results should look like this: 
Now we see 284 rows and all of them have IP_ADDRESS information!
*/

CREATE OR REPLACE VIEW ags_game_audience.raw.logs
AS
SELECT
  --raw_log:agent::text as agent
  raw_log:ip_address::TEXT AS ip_address,
  raw_log:user_event::TEXT AS user_event,
  raw_log:user_login::TEXT AS user_login,
  raw_log:datetime_iso8601::TIMESTAMP AS datetime_iso8601,
  *
FROM ags_game_audience.raw.game_logs
WHERE ip_address IS NOT NULL
;

/*
📓 Kishore's Test Rows - His Sister's Gaming  
Kishore and Prajina's Auntie snapped a picture just as Prajina was logging in to start playing Agnie's game. Kishore took notes about the date and time, but perhaps you can infer a date and time on your own, using their Auntie's snapshot. 

test records generated

🎯 Estimate the Expected Time Stamp and Find the Test Records
Based on clues in the picture above, what would a timestamp for Prajina's login look like if it were in the ISO 8601 format? (YYYY-MM-DDTHH:MI:SS)

Based on Kishore's family living in Denver, Colorado, USA, what would the same timestamp look like if it was converted to UTC before being stored? 

TIP: Use tools from the web (there are many) to help you if you struggle with converting between datetimes across time zones.

Even though we will learn to use Snowflake functions to do calculations like this, a good Data Engineer will test their results from one calculation (a Snowflake function) against another method of calculation (a website calculator) just to be sure. 
*/

/*
📓 Did You Calculate Timestamps Like We Did?
Based on the photo, did you guess that you should be looking for records for 2022-10-15 at around 7:22 PM? 
Did you know that ISO 8601 uses a 24-Hour clock? And did you know that 7:22PM is 19:22 on a 24-Hour clock?
Did you calculate that if the time captured had been converted to UTC, it would not show as 19:22 on Saturday evening, but as 1:22 -- very early on Sunday morning?
test records generated

🎯 Find Prajina's Log Events in Your Table
Kishore can't remember what his sister's gamer name is, but he is pretty sure it includes her first name. Can you find her login and and logoff records?

When looking for a value like "Kishore" but you aren't sure whether it would appear as "kingKishore" or "kishoreDaKing" use LIKE or ILIKE and use % as wild cards.

So something like:
WHERE USER_LOGIN ilike '%kishore%'
When you think you've found Prajina's test records, can you use the timestamps you calculated, to confirm whether you have found the right records?

Finally, can you draw a conclusion as to whether the datetimes were recorded in LTZ or UTC?
*/
SELECT *
FROM ags_game_audience.raw.logs
WHERE user_login ILIKE '%Prajina%'
; -- princess_prajina

USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DNGW02' AS step,
      (
        SELECT SUM(tally) FROM(
          SELECT (COUNT(*) * -1) AS tally
          FROM ags_game_audience.raw.logs 
          UNION ALL
          SELECT COUNT(*) AS tally
          FROM ags_game_audience.raw.game_logs
        )     
      ) AS actual,
      250 AS expected,
      'View is filtered' AS description
  ); 

