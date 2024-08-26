/*
🥋 OpenStreetMap - Super Charged! 
Did you notice that both WKT Playground and the GeoJSON.io site use OpenStreetMap to display the data? OpenStreetMap is an open source alternative to Google Maps that can be very handy for getting geospatial data displayed. Mel considers whether he should somehow try to extract all the data from OpenStreetMap and make it available in his Snowflake Account. 

OpenStreetMap data is free for use. So he is free to download it to his laptop and upload it into a cloud account. Then again, downloading and prepping the data could take awhile. He tells Klaus about his idea.

Klaus tells him that Open Street Map data is probably already available on the Snowflake Data Marketplace and encourages Mel to check out a company called Sonra that enhances Open Street Map data, and makes it available on the Marketplace. Klaus advises that Mel can spend days getting the raw data ready himself, or he can have more than he needs within minutes. 

NOTE: You will need to switch your role to ACCOUNTADMIN to get the share added to your trial. 


📓  Learn More About Sonra's Denver Open Street Map (OSM) Data
How many tables are available in the Sonra Denver share? Are there fewer tables than views? 

Of the views, about how many include "SHOP" in the view name? And about how many include "AMENITY" in the view name? 


*/
USE ROLE accountadmin;

// Give me the length of a Way
SELECT
  id,
  ST_LENGTH(coordinates) AS length
FROM denver.v_osm_den_way;

// List the number of nodes in a Way
SELECT
  id,
  ST_NPOINTS(coordinates) AS num_of_nodes
FROM denver.v_osm_den_way;

// Give me the distance between two Ways
WITH b AS (
  SELECT
    id,
    coordinates
  FROM denver.v_osm_den_way
  WHERE id = 705859570
)
SELECT
  a.id AS id_1,
  b.id AS id_2,
  ST_DISTANCE(a.coordinates, b.coordinates) AS distance
FROM (
  SELECT
    id,
    coordinates
  FROM denver.v_osm_den_way
  WHERE id = 705859567
) AS a
INNER JOIN b;

// Give me all amenities from education category in a radius of 2,000 metres from a point
SELECT *
FROM denver.v_osm_den_amenity_education
WHERE ST_DWITHIN(ST_POINT(
    -1.049212522000000e+02,
    3.969829250000000e+01
  ),coordinates,2000);

// Give me all food and beverage Shops in a radius of 2,000 metres from a point

SELECT *
FROM denver.v_osm_den_shop_food_beverages  
WHERE ST_DWITHIN(ST_POINT(
    -1.049632800000000e+02,
    3.974338330000000e+01
  ),coordinates,2000);

/*
📓 Let's Choose a Location for Melanie's Café
Melanie's Café isn't a real place but we'll choose a location to use for Mel's calculations. Cut and paste from below to see the chosen location in one or more of the mapping tools we've been using. 

GOOGLE MAPS: 39.76471253574085, -104.97300245114094

WKT PLAYGROUND: POINT(-104.9730024511  39.76471253574)

GEOJSON.IO: Paste between the square brackets. 

{
      "type": "Feature",
     "properties": {
        "marker-color": "#ee9bdc",
       "marker-size": "medium",
        "marker-symbol": "cafe",
        "name": "Melanie's Cafe"
     },
     "geometry": {
        "type": "Point",
       "coordinates": [
          -104.97300870716572,
          39.76469906695095
        ]
      }
    }

Denver's Confluence Park


🥋 Using Variables in Snowflake Worksheets 
*/

-- Melanie's Location into a 2 Variables (mc for melanies cafe)
SET mc_lng='-104.97300245114094';
SET mc_lat='39.76471253574085';

--Confluence Park into a Variable (loc for location)
SET loc_lng='-105.00840763333615'; 
SET loc_lat='39.754141917497826';

--Test your variables to see if they work with the Makepoint function
SELECT ST_MAKEPOINT($mc_lng,$mc_lat) AS melanies_cafe_point;
SELECT ST_MAKEPOINT($loc_lng,$loc_lat) AS confluent_park_point;

--use the variables to calculate the distance from 
--Melanie's Cafe to Confluent Park
SELECT ST_DISTANCE(
  ST_MAKEPOINT($mc_lng,$mc_lat),
  ST_MAKEPOINT($loc_lng,$loc_lat)
) AS mc_to_cp;    

/*
📓 Variables are Cool, But Constants Aren't So Bad!
Variables can come in very handy! They can give you the power to write a snippet of code that can be used in a variety of situations. You just change what you put into the Variables and Voila! a new answer comes out. 

That said, the opposite of Variables, called Constants, aren't so bad either. After all, there will always be 360 degrees in a circle and  π  will always start with 3.14. 

So if we want to, when calculating the distance to Melanie's Cafe, we can use constants for those coordinates, instead of variables. 

📓 Let's Create a UDF for Measuring Distance from Melanie's Café
Melanie's Café isn't a real place but Mel's app will need to do a LOT of calculations with that fictional location in mind. Maybe it would make sense to create a Function (defined by us, the Users, not Snowflake) that we can refer to.

When a user defines a function it's called...you guessed it... a User-Defined Function (or UDF). 

You can create UDFs in a variety of languages but we'll stick to SQL for now. 

Create a second Schema in Mel's Database and call it LOCATIONS. Make sure it is owned by SYSADMIN.  

We need to give our UDF a name, so how about DISTANCE_TO_MC (for Distance to Melanie's Café). 

We need to pass in the point we want to measure the distance FROM. We'll call that the "location" and shorten it to "LOC". So we'll pass in LOC_LAT as the Latitude and LOC_LNG as the Longitude. 

*/
USE ROLE sysadmin;
USE DATABASE mels_smoothie_challenge_db;
CREATE SCHEMA IF NOT EXISTS locations;

/*
🥋 Filling in the Function Code
The first point in the distance function will be based on the fictional location for Melanie's Cafe. It's a CONSTANT.  Figure out what constants you need to replace the ?s with.

The second set of numbers will be sent into the function as variables. 

The distance will be returned. 
*/  

-- Melanie's Location into a 2 Variables (mc for melanies cafe)
SET mc_lng='-104.97300245114094';
SET mc_lat='39.76471253574085';

CREATE OR REPLACE FUNCTION DISTANCE_TO_MC(loc_lng NUMBER(38,32),loc_lat NUMBER(38,32))
RETURNS FLOAT
AS
$$
st_distance(
    st_makepoint('-104.97300245114094','39.76471253574085')
    ,st_makepoint(loc_lng,loc_lat)
    )
$$
; 

-- 🥋 Test the New Function!
--Tivoli Center into the variables 
SET tc_lng='-105.00532059763648'; 
SET tc_lat='39.74548137398218';

SELECT DISTANCE_TO_MC($tc_lng,$tc_lat);

/*
🥋 Create a List of Competing Juice Bars in the Area
Mel uses the OSM Wiki to get a lead on how to look up Juice Bars in OSM data. He finds that they are generally being classified as fast food, but someone named EzekielT is suggesting they would be better classified as a new amenity type called juice_bar. Until then, we will search for them under several food amenity categories (but we'll include the suggested type, just in case).
*/

SELECT * 
FROM openstreetmap_denver.denver.v_osm_den_amenity_sustenance
WHERE 
  (
    (amenity IN ('fast_food','cafe','restaurant','juice_bar'))
    AND 
    (
      name ILIKE '%jamba%' OR name ILIKE '%juice%'
      OR name ILIKE '%superfruit%'
    )
  )
  OR 
  (cuisine LIKE '%smoothie%' OR cuisine LIKE '%juice%');

/*
 As of June 2022, the select above gave us a list of 14 juice and smoothie providers.

As of June 2024, the select gave us 15 juice and smoothie providers. 

Of course, the Sonra data in the share is live and Sonra likely pulls from OSM all the time, so it can, and probably will, change. 

🎯 Convert the List into a View
Create a view called COMPETITION with the SELECT statement above.

Make sure the view is in the LOCATIONS schema and is owned by SYSADMIN. 
*/   
USE ROLE sysadmin;
CREATE OR REPLACE VIEW locations.competition
AS
SELECT * 
FROM openstreetmap_denver.denver.v_osm_den_amenity_sustenance
WHERE 
  (
    (amenity IN ('fast_food','cafe','restaurant','juice_bar'))
    AND 
    (
      name ILIKE '%jamba%' OR name ILIKE '%juice%'
      OR name ILIKE '%superfruit%'
    )
  )
  OR 
  (cuisine LIKE '%smoothie%' OR cuisine LIKE '%juice%')
;

-- 🥋 Which Competitor is Closest to Melanie's?
SELECT
  name,
  cuisine,
  ST_DISTANCE(
    ST_MAKEPOINT('-104.97300245114094','39.76471253574085'),
    coordinates
  ) AS distance_to_melanies,
  *
FROM  competition
ORDER BY distance_to_melanies;

/*
📓 Why Not Use the UDF We Just Created? 
Since the Sonra data is not separated into Latitude and Longitude, it would be hard to use our function. Our function expects the two coordinates to be passed in separately, and the Sonra data has each point stored as full geoJSON GEOGRAPHY objects in the COORDINATES column. 

We could try to parse the COORDINATES column back into Latitude and Longitude numbers. If we did that, we could pass them into our UDF where the UDF would to reassemble them back into a POINT again. That would work. But there's a better way!

We need a function that can accept the Sonra GEOGRAPHY object instead of two numbers. 

🥋 Changing the Function to Accept a GEOGRAPHY Argument 
*/

CREATE OR REPLACE FUNCTION DISTANCE_TO_MC(lng_and_lat GEOGRAPHY)
RETURNS FLOAT
AS
$$
   st_distance(
        st_makepoint('-104.97300245114094','39.76471253574085')
        ,lng_and_lat
        )
  $$
;

-- 🥋 Now We Can Use it In Our Sonra Select

SELECT
  name,
  cuisine,
  DISTANCE_TO_MC(coordinates) AS distance_to_melanies,
  *
FROM  competition
ORDER BY distance_to_melanies;  

/*
📓 What the Heck is Going On? 
First we had a function called DISTANCE_TO_MC and it had two arguments. Then, we ran a CREATE OR REPLACE statement that defined the DISTANCE_TO_MC UDF so that it had just one argument. Maybe you expected only one function called DISTANCE_TO_MC would exist after that. But you look in your LOCATIONS Schema under FUNCTIONS and you find that there are two!
If you are new to coding, you may not know about something called "overloading" a function. Overloading sounds like a bad thing, but it's actually pretty cool. 

Basically, it means that you can have different ways of running the same function and Snowflake will figure out which way to run the UDF, based on what you send it. So if you send the UDF two numbers it will run our first version of the function and if you pass it one geography point, it will run the second version. 

This means we can run the function several different ways and they will all result in the same answer.  When speaking about a FUNCTION plus its ARGUMENTS we can refer to it as the FUNCTION SIGNATURE. 

*/

-- 🥋 Different Options, Same Outcome!
-- Tattered Cover Bookstore McGregor Square
SET tcb_lng='-104.9956203'; 
SET tcb_lat='39.754874';

--this will run the first version of the UDF
SELECT DISTANCE_TO_MC($tcb_lng,$tcb_lat);

--this will run the second version of the UDF, bc it converts the coords 
--to a geography object before passing them into the function
SELECT DISTANCE_TO_MC(ST_MAKEPOINT($tcb_lng,$tcb_lat));

--this will run the second version bc the Sonra Coordinates column
-- contains geography objects already
SELECT
  name,
  DISTANCE_TO_MC(coordinates) AS distance_to_melanies,
  ST_ASWKT(coordinates)
FROM openstreetmap_denver.denver.v_osm_den_shop
WHERE shop='books' 
  AND name LIKE '%Tattered Cover%'
  AND addr_street LIKE '%Wazee%';

/*
🎯 Create a View of Bike Shops in the Denver Data
Mel is thinking it might make sense to do a cross promotion with bike shops. He needs to find all the bike shops in the Denver data as a first step. Can you help?

Create a view that pulls all the bike shops in Denver into a view called DENVER_BIKE_SHOPS. Make sure the view is in the LOCATIONS schema and is owned by SYSADMIN. 

HINTS: 

There are 33 bike shops in the data set right now. (This may vary over time but should not vary by a LOT.)
You can find the shops in either the V_OSM_DEN_SHOP_OUTDOORS_AND_SPORT_VEHICLES or the V_OSM_DEN_SHOP table. The benefit of using the more specific view is that the columns included are more directly related to a bike shop. 
You can use a WHERE <column> = 'bicycle' -- you just have to figure out which column.  This is the ONLY thing you need in the WHERE clause. It's a much simpler view definition than the one we used for smoothie shops!
Be sure to include a column called DISTANCE_TO_MELANIES that calculates the distance to Melanie's Café for each Bike Shop

*/
SELECT *
FROM openstreetmap_denver.denver.v_osm_den_shop_outdoors_and_sport_vehicles
LIMIT 100
;
CREATE VIEW denver_bike_shops AS
SELECT
  name,
  ST_DISTANCE(ST_MAKEPOINT('-104.97300245114094','39.76471253574085'), coordinates) AS distance_to_melanies,
  coordinates
FROM openstreetmap_denver.denver.v_osm_den_shop_outdoors_and_sport_vehicles
WHERE shop IN ('bicycle');

SELECT *
FROM denver_bike_shops
;

USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DLKW08' AS step,
      (
        SELECT TRUNCATE(distance_to_melanies)
        FROM mels_smoothie_challenge_db.locations.denver_bike_shops
        WHERE name LIKE '%Mojo%'
      ) AS actual,
      14084 AS expected,
      'Bike Shop View Distance Calc works' AS description
  ); 

