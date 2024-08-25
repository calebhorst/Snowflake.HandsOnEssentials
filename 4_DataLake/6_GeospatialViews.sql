/*
🥋 Look at the Parquet Data
Run a select, then click on any row to see it's data. Is this data nested?

Write a more sophisticated query to parse the data into columns. We give you the first two rows. We know you can figure out the rest.

Knowing what you do about Denver, Colorado's approximate longitude and latitude, do you see any issues with this data?  People who work as data professionals should constantly look at their data and question whether it is making sense. In this case, we see some issues. One of our jobs is to massage and cleanse the data as we get it ready to for use by others. 
*/
use mels_smoothie_challenge_db.trails;
select
    $1:sequence_1 as sequence_1
    ,$1:trail_name::varchar as trail_name
    ,$1:latitude as latitude
    ,$1:longitude as longitude
    ,$1:sequence_2 as sequence_2
    ,$1:elevation as elevation
from @trails_parquet (file_format => ff_parquet)
;

/*
🥋 Use a Select Statement to Fix Some Issues
According to some online blog posts, you don't need more than 8 decimal points on coordinates to get accuracy to within a millimeter. Remember that Latitudes are between 0 (the equator)  and 90 (the poles) so no more than 2 digits are needed left of the decimal for latitude data.

Longitudes are between 0 (the prime meridian) and 180. So no more than 3 digits are needed to the left of the decimal for longitude data.

If we cast both longitude and latitude data as NUMBER(11,8) we should be safe.  We have included the code for this select statement below. 
*/
--Nicely formatted trail data
select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng, --remember we did a gut check on this data
 $1:longitude::number(11,8) as lat
from @trails_parquet
(file_format => ff_parquet)
order by point_id;

/*
After running this select statement, you can copy and paste one set of coordinates into the WKT Playground site to see if it looks accurate. Snowflake has functions for working with geometry and geography data, but no way to overlay it on maps, yet. 

 🥋 Test One of the Points in WKT Playground
We selected the coordinates from POINT_ID = 1, wrapped them in POINT() and pasted them into WKT Playground!  Remember to zoom out. 

Check a few other points if you'd like. When you feel confident your query is good, lay a view on top of it and call it CHERRY_CREEK_TRAIL.

🎯 Create a View Called CHERRY_CREEK_TRAIL
Wrap the select statement in a CREATE VIEW.
Name it CHERRY_CREEK_TRAIL. 
Make sure it is in Mel's database, in his TRAILS schema.
Make sure it is owned by SYSADMIN. 
*/
use mels_smoothie_challenge_db.trails;
create or replace view CHERRY_CREEK_TRAIL
as
select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng, --remember we did a gut check on this data
 $1:longitude::number(11,8) as lat
from @trails_parquet
(file_format => ff_parquet)
order by point_id
;

select *
from CHERRY_CREEK_TRAIL
;

-- 🥋 Use || to Chain Lat and Lng Together into Coordinate Sets!
-- Now we can make pairs with a space in between, since we know that's how WKT Playground likes them formatted!
--Using concatenate to prepare the data for plotting on a map
select top 100 
 lng||' '||lat as coord_pair
,'POINT('||coord_pair||')' as trail_point
from cherry_creek_trail
;

-- The coord_pairs could come in very handy so we should add this column to our view! To add a column, you have to replace the old view. 
--To add a column, we have to replace the entire view
--changes to the original are shown in red
create or replace view cherry_creek_trail as
select 
 $1:sequence_1 as point_id,
 $1:trail_name::varchar as trail_name,
 $1:latitude::number(11,8) as lng,
 $1:longitude::number(11,8) as lat,
 lng||' '||lat as coord_pair
from @trails_parquet
(file_format => ff_parquet)
order by point_id
;

/*
🥋 Let's Collapse Sets Of Coordinates into Linestrings! 
We can use Snowflakes LISTAGG function and the new COORD_PAIR column to make LINESTRINGS we can paste into WKT Playground! 

Let's remember the syntax for LINESTRINGS. 

LINESTRING(
Coordinate Pair
COMMA
Coordinate Pair
COMMA
Coordinate Pair
(etc)
) 

🥋 Run this SELECT and Paste the Results into WKT Playground!
*/
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
from cherry_creek_trail
where point_id <= 10
group by trail_name
;

/*
Copy the results from Snowflake and paste them into WKT Playground to see the LineString you created by rolling up all the coordinates into a list. You'll see a small portion of the trail displayed over Denver's Confluence Park. 

🎯 Can You Make The Whole Trail into a Single LINESTRING? 
Can you make a single LINESTRING that runs from Franktown to Confluence Park? Just use the last SELECT statement, and change the limitation from less than 10 to less than 2450. Then, cut and paste it into WKT Playground.

The reason we have to limit it to 2450 is because the WKT Playground throws an error if you try to plot all 3,500 points. 
*/

select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
from cherry_creek_trail
where point_id <= 2450
group by trail_name
;

/*
🥋 Look at the geoJSON Data
Run a select on the geoJSON Stage, using the JSON file format you created. If you can't remember their names, just use SHOW commands to remind yourself. 

🥋 Normalize the Data Without Loading It!
*/
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json)
;

/*
 🥋 Visually Display the geoJSON Data
Again, we can manage and massage the data in Snowflake, but we can't really display it properly. So just as with the WKT formatted GeoSpatial data, we need another tool to visually display the data we store in Snowflake. For this exploration we'll go to geojson.io.

🎯 Create a View Called DENVER_AREA_TRAILS
Wrap the previous select statement in a CREATE VIEW statement.
Name it DENVER_AREA_TRAILS. 
Make sure it is in Mel's database, in his TRAILS schema.
Make sure it is owned by SYSADMIN. 
*/

create or replace view DENVER_AREA_TRAILS
as
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json)
;

use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
SELECT
'DLKW06' as step
 ,( select count(*) as tally
      from mels_smoothie_challenge_db.information_schema.views 
      where table_name in ('CHERRY_CREEK_TRAIL','DENVER_AREA_TRAILS')) as actual
 ,2 as expected
 ,'Mel\'s views on the geospatial data from Camila' as description
 ); 


