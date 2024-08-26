/*
📓 Extracting, Transforming and Loading
extract and load

The main work of a data Engineer is to build ETL pipelines. ETL stands for Extract, Transform and Load. 

Did you notice in the image above, Kishore is dressed as an artist? That's because making decisions when building ETL is a very creative activity. Experienced Data Engineers can usually come up with several ways to achieve the end goal, so selecting the final method is, often, an art. 

So far, Agnie has extracted the data (twice), and Kishore has loaded it (twice).

When we created our LOGS view, we parsed out the JSON into the separate columns. Parsing the data could be considered a transformation. 

So, in this case, instead of Extract-Transform-Load, we Extract-Load-Transformed things. 

But, it's important not to get too hung up on the order of the letters. When you work as a Data Engineer, you'll be doing lots of extracting, lots of transforming, and lots of loading. 

For the remainder of this workshop, we'll stick to calling it ETL, regardless of the particular order of our steps. 

📓 Defining the Transformed State
extract and load

The work of a Data Engineer is to take RAW data and refine that data until it matches what the customer* is looking for. Since this is just a fun project for Kishore, Agnie and Tsai, they can collaborate to define what the refined version of the data should look like.  They can define Agnie as the "customer" or they can imagine and define a customer they want their project's data to serve.

In many organizations, a Data Engineer is given access to extracted data, and told what the end goals are (the final, transformed state). Then, it is within their power and discretion to decide what steps they will follow to get there. 

These choices are called "design" and the structures and processes that result are called the "architecture." In this workshop we'll give you hands-on experience with the components, but design and architecture decisions are something it takes years to learn and we don't attempt to teach them in this beginner course. 

Data Engineers often perform a series of ETL steps and so they have different "layers" where data is expected to have reached certain levels of refinement or transformation. In this workshop we'll have named our layers: 

RAW
ENHANCED
CURATED
In this next step, Kishore will try to make the RAW data more valuable than it is currently, by adding information that will ENHANCE that data. 

* A "customer" does not have to be someone outside of the company who is buying something. A customer is any person, department or organization that you are trying to help by delivering data in a certain format. 


📓 A Project Status Meeting
refinement meeting 1

The team meets for lunch to discuss the project. Tsai leads the meeting as each person reports on progress made. As BSA, Tsai is trying to "capture requirements". Capturing requirements means writing down a definition that everyone agrees would mean that the work is complete. 

Tsai will try to write down something they can all agree on so that they will know when the data is considered transformed and ready for use. 

📓 Next Steps
refinement meeting 1

The team discusses alternative ways to get time zone information for each gamer.  Kishore notes that IP Addresses can be geo-located and that geolocation can be used to infer a time zone. 

Agnie mentions that the use of VPNs can mess up IP Geolocation. That's a problem, but the team agrees that using the IP address, even with the VPN issue, is better than not having any time zone information at all. 

Tsai asks Kishore how he plans to perform the IP Geolocation process.  Kishore says there are lots of options. He notes that there are lookup API services available.

Lookup services often charge a fee per lookup and might require a contract right away. Kishore also mentions downloadable database files he could upload into his Snowflake account. Those files often only provide the country so he'd still have to map to the time zone from there using a second lookup. Kishore doesn't think using the IP_ADDRESS to infer location will work for the project, after all. 

Then, Tsai asks if anyone has checked the Marketplace to see if any companies are offering IP Address-based time zone look up via a share. Kishore quickly searches the Marketplace and finds a listing from a company called IPInfo. The sample data is free and the team can look up at least some of their gamers' locations. When they're sure it will work, they can talk to IPInfo about premium data. 

Kishore's first data TRANSFORMATION will be to ENHANCE the log data by adding time zone to each row. 

🎯 Use Snowflake's PARSE_IP Function
Find Kishore's sister's log files, and copy the IP Address assigned to Kishore's VR headset. 
Paste the IP into this code snippet, and run it. 
*/

SELECT PARSE_IP('100.41.16.160','inet');

/*
🎯 Pull Out PARSE_IP Results Fields
We can pull out the values from the PARSE_IP results by adding a colon and the name after the close parentheses, like this: 

select parse_ip('107.217.231.17','inet'):host;
Or this:
select parse_ip('107.217.231.17','inet'):family;

The code above shows examples. Those are not the correct IP Address. Use the IP Address that was assigned to Kishore's headset while Prajina was playing Agnie's game. Pull out the ipv4 property. This value is just Kishore's internet connection IP Address formatted a different way. We need his IP Address in the ipv4 format because it is easier to compare to other numbers. 
*/

-- 🎯 Enhancement Infrastructure
-- Create a new schema in the database and call it ENHANCED
USE ROLE sysadmin;
USE DATABASE ags_game_audience;
CREATE SCHEMA IF NOT EXISTS enhanced;

/*
📓 Locate the IPInfo Free Sample Data
IPInfo provides just the kind of IP Information the team is looking for! And they have a free, sample listing they can get access to immediately!
*/
// Previewing the data
/*
The first top 10 rows from the IP geolocation demo database.
*/
SELECT *
FROM demo.location
LIMIT 10;

// Get Specific IP address data
/*
Use this query if you want to get geolocation information of a single IP address. Replace the IP address provided with your desired IP address.
*/
-- '24.183.120.0' ⇒ Input IP Address

SELECT *
FROM demo.location
WHERE ipinfo.public.TO_INT('24.183.120.0') BETWEEN start_ip_int AND end_ip_int;

-----------------
-- Explanation --
-----------------

-- TO_INT is a custom function that converts IP address values to their integer equivalent
-- start_ip_int represents the integer equivalent of the start_ip column
-- end_ip_int represents that integer equivalent of the end_ip column
-- The BETWEEN function checks to see if your input IP address falls between an the IP Range of start_ip_int and end_ip_int;

// Get the number of IP addresses by City (Groupby - Count)
/*
Get the number of IP addresses located in each city.
*/
SELECT
  COUNT(start_ip) AS num_ips,
  city
FROM demo.location
GROUP BY city
ORDER BY num_ips DESC;

// Specific data query from IP address lookup
/*
Extract specific geolocation details such as, city, region, country, geographic coordinates (latitude & longitude) and timezone from a single IP address lookup.
*/
-- '24.183.120.0' ⇒ Input IP Address

SELECT 
  city,
  region,
  country,
  lat AS latitude,
  lng AS longitude,
  postal,
  timezone
FROM demo.location
WHERE ipinfo.public.TO_INT('24.183.120.0') BETWEEN start_ip_int AND end_ip_int;

// Optimized join on IP Addresses
/*
Joining a table that has IP addresses to IPinfo’s geolocation table. This join operation uses the Join Key column to facilitate the join operation, creating a joined table that contains the input IP address and IPinfo’s geolocation insights.
*/
-- Placeholder CTE representing the log database that contains IP addresses
-- contains two IP adddresses on the 'ip' column

WITH log AS (
  SELECT '172.4.12.1' AS ip
  UNION
  SELECT '172.4.12.2'
)

-- JOIN operation code

SELECT
  input_db.ip, // 'ip' column of the log database
  ipinfo_demo.city,
  ipinfo_demo.region,
  ipinfo_demo.country,
  ipinfo_demo.postal,
  ipinfo_demo.lat,
  ipinfo_demo.lng,
  ipinfo_demo.timezone 
FROM log ASinput_db
INNER JOIN demo.location ASipinfo_demo
  ON ipinfo.public.TO_JOIN_KEY(input_db.ip) = ipinfo_demo.join_key
  AND ipinfo.public.TO_INT(input_db.ip) BETWEEN ipinfo_demo.start_ip_int AND ipinfo_demo.end_ip_int;


-----------------
-- Explanation --
-----------------


-- your 'log' database contains the 'ip' column
-- using the ipinfo geolocation database you can create a new table
-- this table will contain the geolocation data of each individual ip addresses;

// Top 10 Nearest IP Address from a location
/*
The Nearest IP address shows the closest IP addresses from a geographic coordinate. We use the “Haversine formula” to find IP addresses from the provided Latitude and Longitude values.
*/
-- 42.556 ⇒ Input Latitude
-- -87.8705 ⇒ Input Longitude

SELECT
  HAVERSINE(42.556, -87.8705, lat, lng) AS distance,
  start_ip,
  end_ip,
  city,
  region,
  country,
  postal,
  timezone
FROM demo.location
ORDER BY 1
LIMIT 10;


-----------------
-- Explanation --
-----------------


-- Uses the Haversine Formula: https://en.wikipedia.org/wiki/Haversine_formula
-- The haversine formula determines the great-circle distance between two points on a sphere given their longitudes and latitudes.;


-- 🥋 Look Up Kishore & Prajina's Time Zone

--Look up Kishore and Prajina's Time Zone in the IPInfo share using his headset's IP Address with the PARSE_IP function.
SELECT
  start_ip,
  end_ip,
  start_ip_int,
  end_ip_int,
  city,
  region,
  country,
  timezone
FROM ipinfo_geoloc.demo.location
WHERE PARSE_IP('100.41.16.160', 'inet'):ipv4 --Kishore's Headset's IP Address
  BETWEEN start_ip_int AND end_ip_int;

-- 🥋 Look Up Everyone's Time Zone
--Join the log and location tables to add time zone to each row using the PARSE_IP function.
SELECT
  logs.*,
  loc.city,
  loc.region,
  loc.country,
  loc.timezone
FROM ags_game_audience.raw.logs ASlogs
INNER JOIN ipinfo_geoloc.demo.location ASloc
WHERE PARSE_IP(logs.ip_address, 'inet'):ipv4 
  BETWEEN start_ip_int AND end_ip_int;

/*
📓 How Expensive is This? 
Looking up time zones using the IPInfo Geolocation share is going to be an important part of Kishore's data pipeline. Even though IPInfo is giving away this data sample for free, anyone querying it will still pay Snowflake for the use of Warehouse time. 

Of course, as a Trial Account User, you're not spending real money. Right now you're simply using up Free Trial Credits, but as a Data Engineer, you have to be able to write queries that don't work super hard, when they could get the same result set by working smart!

After running a query, especially one that he plans to run often, Kishore will need to make sure it will be "performant." He can do that by examining the Query Profile of any command he runs.  Let's run some commands that might not perform all that well and then look at the query profiles for each. 

🥋 View the Query Profile of the Code You Just Ran
If you forget to look at the Query Profile while the results are still on your screen, just use the side menu to find and explore previous queries.

NOTE: If you run the query more than once, the profile the second time around (and 3rd, 4th, 5th, etc) will be very different. This is due to CACHING. Please see our Level Up on Caching if you would like to understand Caching in Snowflake better. 

📓 Functions As Part of the Share
We are especially interested in using two of the functions IPInfo has provided to us.

The TO_JOIN_KEY function reduces the IP down to an integer that is helpful for joining with a range of rows that might match our IP Address.
The TO_INT function converts IP Addresses to integers so we don't have to try to compare them as strings! 
*/

-- 🥋 Use the IPInfo Functions for a More Efficient Lookup
--Use two functions supplied by IPShare to help with an efficient IP Lookup Process!
SELECT
  logs.ip_address,
  logs.user_login,
  logs.user_event,
  logs.datetime_iso8601,
  city,
  region,
  country,
  timezone 
FROM ags_game_audience.raw.logs ASlogs
INNER JOIN ipinfo_geoloc.demo.location ASloc 
  ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
  AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address) 
  BETWEEN start_ip_int AND end_ip_int;

/*
📓 Create a Local Time Column!
We have a timestamp in every row of our logs that tells us the date and time the gaming event (login or logoff) took place. 

Based on his calculations and tracking, Kishore feels confident those timestamps are in UTC+0. 

Now we have the local time zone for many of our gamers. 

These 3 pieces of information are exactly what we need to create a new column that contains the local date and time of the gaming event. 

Kishore will use a function he found on docs.snowflake.com called CONVERT_TIMEZONE. 

🎯 Add a Local Time Zone Column to Your Select
Add a column called GAME_EVENT_LTZ to the last code block you ran.
After you create the new column, use the test rows created by Kishore's sister to make sure the conversion worked. 
*/

SELECT 
  logs.ip_address,
  logs.user_login,
  logs.user_event,
  logs.datetime_iso8601,
  city,
  region,
  country,
  timezone,
  CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) AS game_event_ltz
FROM ags_game_audience.raw.logs ASlogs
INNER JOIN ipinfo_geoloc.demo.location ASloc 
  ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
  AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address) 
  BETWEEN start_ip_int AND end_ip_int;

/*
📓 Planning More Data Enhancements
Agnie and Tsai are impressed and want to know what other enhancements Kishore is planning to make. Kishore explains that he wants to hear their ideas about what would be useful. 

Agnie is wanting to know what time of the day gamers are playing. Is it after school? In the evenings? Late at night? 
Tsai suggests knowing which days of the week, like weekdays versus weekends would also be helpful. 
Kishore thinks he can also figure out how long they are playing the game each time they log in and out, and asks if that seems interesting. 
Everyone agrees that these three data enhancements sound great and Kishore says he'll let them know when he's got them added. 

🎯 Add A Column Called DOW_NAME
Continue adding columns to the SELECT statement (we're not codifying them in a view, yet). 

Use the DAYNAME function to add the DOW ("Day of Week") name as a column to your SELECT.  The new column should be named DOW_NAME. Be sure to use the local time zone datetime value so that you get the day in local time. 

 TIP: If you find any docs page hard to understand, you can scroll to the bottom of the page or click the EXAMPLES hyperlink in the right side headings to see code samples. This is what MANY coders do and you should not feel like an imposter because you like to see concrete EXAMPLES before trying to absorb the abstracted SYNTAX. You can always scroll back to the top when you feel less overwhelmed. 
*/
SELECT 
  logs.ip_address,
  logs.user_login,
  logs.user_event,
  logs.datetime_iso8601,
  city,
  region,
  country,
  timezone,
  CONVERT_TIMEZONE('UTC', timezone, logs.datetime_iso8601) AS game_event_ltz,
  DAYNAME(logs.datetime_iso8601) AS dow_name
FROM ags_game_audience.raw.logs ASlogs
INNER JOIN ipinfo_geoloc.demo.location ASloc 
  ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
  AND IPINFO_GEOLOC.public.TO_INT(logs.ip_address) 
  BETWEEN start_ip_int AND end_ip_int;

/*
📓 Assigning a Time of Day
Agnie wants to know what "time" of day people are playing her game. But when asking Kishore for "the time," she's not requesting a number, she wants something more like "Before Breakfast" or "After School." 

Kishore doesn't think that makes any sense because "Before Breakfast" is not reliable across cultures and age groups. Tsai, in her role as BSA, tries to facilitate the discussion to help Agnie and Kishore find a compromise. 

After some back and forth, Kishore and Agnie agree that using labels like "Early morning" and "Mid-morning," for example, are an acceptable compromise for both of them. 

Kishore asks Agnie to write out what she wants to call each portion of the day and send it to the team via email.
*/

-- 🥋 Create the Table and Fill in the Values
-- Your role should be SYSADMIN
-- Your database menu should be set to AGS_GAME_AUDIENCE
-- The schema should be set to RAW

--a Look Up table to convert from hour number to "time of day name"
USE ROLE sysadmin;
USE ags_game_audience.raw;

CREATE TABLE ags_game_audience.raw.time_of_day_lu
(
  hour NUMBER,
  tod_name VARCHAR(25)
);

--insert statement to add all 24 rows to the table
INSERT INTO time_of_day_lu
VALUES
(6,'Early morning'),
(7,'Early morning'),
(8,'Early morning'),
(9,'Mid-morning'),
(10,'Mid-morning'),
(11,'Late morning'),
(12,'Late morning'),
(13,'Early afternoon'),
(14,'Early afternoon'),
(15,'Mid-afternoon'),
(16,'Mid-afternoon'),
(17,'Late afternoon'),
(18,'Late afternoon'),
(19,'Early evening'),
(20,'Early evening'),
(21,'Late evening'),
(22,'Late evening'),
(23,'Late evening'),
(0,'Late at night'),
(1,'Late at night'),
(2,'Late at night'),
(3,'Toward morning'),
(4,'Toward morning'),
(5,'Toward morning');

-- 🥋 Check the Table
--Check your table to see if you loaded it properly
SELECT
  tod_name,
  LISTAGG(HOUR,',') 
FROM time_of_day_lu
GROUP BY tod_name;

/*
📓 Time to Stretch!
 

Kishore will stretch his SQL skills with this task. He needs to join his current select with the new time of day table and use it to get the TOD_NAME into his results. 


Below is a screenshot of what his results (and yours!) should look like when he (and you!) are done.  If you find the image hard to see, right click on it and choose "Open image in new tab" so that you can zoom in on the image. 

All the blurred areas in the screenshot above are places where you have generated your own code to create enhancements to the data. We are confident you know how to fill in the blurs. 

🎯 A Join with a Function
To create this next data enhancement (which you will call TOD_NAME), you will need to join to our new time of day table to the tables in our existing SELECT.

Use the "hour" column of our new look-up table as the linking point in the ON clause. Once you've linked the two tables you can send back the TOD_NAME in the results. 

HINT: You will need a function from Snowflake's Date & Time Functions group in order to make the join. Can you figure out how to get a numeric hour from the Local timestamp column? If you can isolate the hour, you can then use to join to the hour number in the new table? 
*/

SELECT 
  logs.ip_address,
  logs.user_login,
  logs.user_event,
  logs.datetime_iso8601,
  -- , city
  -- , region
  -- , country
  -- , timezone 
  -- ,convert_timezone('UTC', timezone, logs.datetime_iso8601) as GAME_EVENT_LTZ
  DAYNAME(logs.datetime_iso8601) AS dow_name,
  lu.tod_name
FROM ags_game_audience.raw.logs ASlogs
INNER JOIN ipinfo_geoloc.demo.location ASloc ON IPINFO_GEOLOC.public.TO_JOIN_KEY(logs.ip_address) = loc.join_key
INNER JOIN ags_game_audience.raw.time_of_day_lu AS lu ON lu.hour = HOUR(datetime_iso8601)
WHERE IPINFO_GEOLOC.public.TO_INT(logs.ip_address) BETWEEN start_ip_int AND end_ip_int
;


/*
🪄 Step-By-Step Tips (If You Need Them)
FIrst, make sure you can pull out the hour. Once you have identified the function that gets you the hour, you can move that function into the join.

The basic syntax for the join would be this: 
select * 
from main_table 
join lookup_table
on main_table.hour = lookup_table.hour;

But in our case, we'll have a function IN THE JOIN!! so it will be more like this: 
select * 
from main_table 
join lookup_table
on a_function_that_returns_an_hour = lookup_table.hour;

Once the tables are successfully joined together, you have access to the other columns in that new, joined table. The column we want to add to our select statement has the name of the time of day in it.  */

/*
🎯 Rename Some Columns in Our Select Statement
We're going to rename some of our columns by putting "as" between the column definition and the new name. 

 logs.user_login should be renamed to GAMER_NAME
 logs.user_event should be renamed to GAME_EVENT_NAME
 logs.datetime_iso8601 should be renamed to GAME_EVENT_UTC
timezone should be renamed GAMER_LTZ_NAME
Other columns can keep their current names. 

📓 Query Complexity
Our select statement is starting to get somewhat complex. It might be a good idea to take the results and move them somewhere, especially now that the data is no longer RAW, it's starting to merit being referred to as ENHANCED. 

We could wrap our select in a view, but the select is already based on a view, joined with a share and another table. It might be nice to write the data into a table to sort of lock it down.

To create the table we can use a CTAS -- a Create Table as Select. CTAS statements are a really quick way to create a table. It's not a long-term solution, but a stepping stone as we work out the process logic. 

*/

--Wrap any Select in a CTAS statement
CREATE OR REPLACE TABLE ags_game_audience.enhanced.logs_enhanced 
AS
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

USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DNGW03' AS step,
      (
        SELECT COUNT(*) 
        FROM ags_game_audience.enhanced.logs_enhanced
        WHERE dow_name = 'Sat'
          AND tod_name = 'Early evening'   
          AND gamer_name LIKE '%prajina'
      ) AS actual,
      2 AS expected,
      'Playing the game on a Saturday evening' AS description
  ); 
