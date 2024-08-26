/*
📓 Mel Starts with a Quick Geography Review
Mel is excited to do something with GeoSpatial Data, but first, he needs to recall some middle school geography! 

Remember that latitude is counted from the Equator to the North Pole and then from the Equator to the South Pole. So latitude for any location in the world is always between 0 and 90 degrees.

In some notation systems an N or S is used to indicate which side of the Equator a location falls on.

In other systems, the Southern hemisphere is represented with negative numbers and the Northern hemisphere is represented with positive numbers. 

Longitude is counted from the Greenwich Meridian Line (also called the Prime Meridian).

So longitude is always between 0 and 180 degrees. If you start in Greenwich, England, UK, at zero degrees longitude, and head East, you will count up from zero to 180, until you get to Fiji on the other side of the globe. (Assuming you also drift South as you go.) If you head West from Greenwich, you will also count from zero to 180.

In some notation systems an E or W is used with the number to indicate whether you are East or West of Greenwich. 

In other systems, the Eastern hemisphere is represented with positive numbers and the Western hemisphere is represented with negative numbers. 


📓 Mel's Hometown of Denver, Colorado, USA
In the graphic below, white lines are latitude lines and gray lines are longitude lines. 

Mel's home state of Colorado, USA is shown in the gold box between 100 degrees West and 110 degrees West.

usa with colorado

 Mel lives in Denver. Denver is the capital city of Colorado. Denver is at about 105 degrees West and 40 degrees North. When Mel right-clicked on Denver's official center point in Google Maps, he saw the location listed as:

  39.73962793994306, -104.99016507876348


📓 Your Crash Course in Geography
You are not required to explore the same websites Mel used, but if you enjoy hands-on exploration, you may want to check them out. 

Go to earth.google.com and search for the Cherry Creek Trail in Denver, Colorado, USA.
Go to google.com/maps google.com/maps and search for the Cherry Creek Trail. 
Go to www.openstreetmap.org
Go to WKT Playground located at: clydedacruz.github.io/openstreetmap-wkt-playground/


🎯 Put Your Snowflake Skills to Work!
Mel's new friend Camilla decided to start taking Snowflake Workshops too! She's completed Badges 1 & 2,  so she's going to help Mel set up the data infrastructure for his project. 

Make sure everything you create is owned by the SYSADMIN role. 
Create a database called MELS_SMOOTHIE_CHALLENGE_DB. 
Drop the PUBLIC schema 
Add a schema named TRAILS
Add an internal named stage called TRAILS_GEOJSON
Add an internal named stage called TRAILS_PARQUET
NOTE: For both stages, client-side encryption is fine. Just make sure both are owned by SYSADMIN and are in the TRAILS schema. 


🎯 Load Your New Stages
Download this file: geoJSON_files.zip
Unzip the file(s) and load file(s) into the geoJSON stage you created. 
Download this file: cherry_creek_trail.parquet
Load the parquet file into the Parquet stage you created. 
*/

USE ROLE sysadmin;
CREATE DATABASE IF NOT EXISTS mels_smoothie_challenge_db;
CREATE SCHEMA trails;
DROP SCHEMA public;

CREATE STAGE IF NOT EXISTS mels_smoothie_challenge_db.trails.trails_geojson
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  COMMENT = 'a place to hold files before loading them';

CREATE STAGE IF NOT EXISTS mels_smoothie_challenge_db.trails.trails_parquet
  ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE')
  COMMENT = 'a place to hold files before loading them';

/*
🥋 Create a Very Basic JSON File Format

🎯 Create a Very Basic Parquet File Format
Create a file format, name it FF_PARQUET and set the Type to PARQUET
Make sure it's in the TRAILS schema and are owned by SYSADMIN

🥋 Query Your TRAILS_GEOJSON Stage!
Try querying the TRAILS_GEOJSON stage using the very simple FF_JSON file format.

Did you notice that EVEN THOUGH this data hasn't been loaded, we CAN use the "Select *" -- we don't have to use "Select $1" notation.

🎯 Query Your TRAILS_PARQUET Stage!
Use the query above as an example and write a simple select statement for the data in your trails_parquet stage. 
*/
USE mels_smoothie_challenge_db.trails;

CREATE FILE FORMAT ff_json
TYPE = 'JSON'
;

CREATE FILE FORMAT ff_parquet
TYPE = 'PARQUET'
;

SELECT *
FROM
  @trails_geojson
  (FILE_FORMAT => ff_json);

SELECT *
FROM
  @trails_parquet
  (FILE_FORMAT => ff_parquet);

USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DLKW05' AS step,
      (
        SELECT SUM(tally)
        FROM
          (
            SELECT COUNT(*) AS tally
            FROM mels_smoothie_challenge_db.information_schema.stages 
            UNION ALL
            SELECT COUNT(*) AS tally
            FROM mels_smoothie_challenge_db.information_schema.file_formats
          )
      ) AS actual,
      4 AS expected,
      'Camila\'s Trail Data is Ready to Query' AS description
  ); 

 