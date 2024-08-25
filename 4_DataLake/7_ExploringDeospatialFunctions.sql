/*
📓  Research GeoSpatial Functions Available in Snowflake
Navigate to docs.snowflake.com and search for "GeoSpatial Functions." You should see a list of functions. 

Did you notice that many of the functions start with ST_? This stands for "Spatial Type" because most of them were developed for use with GEOMETRY data types. They have been added to Snowflake in order to support Snowflake's GEOGRAPHY data objects. 

Did you notice that many of the functions start with ST_? This stands for "Spatial Type" because most of them were developed for use with GEOMETRY data types. They have been added to Snowflake in order to support Snowflake's GEOGRAPHY data objects. 

According to docs.snowflake.com which of the items listed below are categories of GeoSpatial Functions?
Transformation
Relationship and Measurement
Constructor
Accessor
Conversion/Output/Formatting
Conversion/Input/Parsing

🥋 Re-Using Earlier Code (with a Small Addition)
*/
use mels_smoothie_challenge_db.trails;
--Remember this code? 
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
,st_length(my_linestring) as length_of_trail --this line is new! but it won't work!
from cherry_creek_trail
group by trail_name;

/*
WKT Playground was nice enough to take our string (that looked like a GeoSpatial object) and convert it to a GeoSpatial Object and display it. But Snowflake will expect you to convert it yourself. That's easy! We can use the TO_GEOGRAPHY( ) function!

🎯 TO_GEOGRAPHY Challenge Lab!!
Can You Add the TO_GEOGRAPHY() Function to the query above so the length_of_trail column will work properly and no longer throw an error?

HINT: Before we can calculate the length of a LINESTRING, the data has to be a LINESTRING, not just a list of coordinates that looks like a LINESTRING (but is really just a plain, old STRING). 
Once you confirm how the functions work together, you will apply the same pattern to the other view - the DENVER_AREA_TRAILS view. 
*/
use mels_smoothie_challenge_db.trails;
select 
'LINESTRING('||
listagg(coord_pair, ',') 
within group (order by point_id)
||')' as my_linestring
,st_length(to_geography(my_linestring)) as length_of_trail --this line is new! but it won't work!
from cherry_creek_trail
group by trail_name;

/*
🎯 Calculate the Lengths for the Other Trails
Use Snowflake's GeoSpatial functions to derive the length of the trails that are available in the DENVER_AREA_TRAILS view. 

Start by testing the code on a SELECT statement. Once you have the code, you can add it to the view definition.

🎯 Change your DENVER_AREA_TRAILS view to include a Length Column!
You can use the code you just developed to add a length column to the view. You'll want to replace the original view, but add the column.

To get a copy of a CREATE OR REPLACE VIEW code block for your existing view, run this bit of code: 
*/
select get_ddl('view', 'DENVER_AREA_TRAILS');

create or replace view DENVER_AREA_TRAILS(
	FEATURE_NAME,
	FEATURE_COORDINATES,
	GEOMETRY,
    trail_length,
	FEATURE_PROPERTIES,
	SPECS,
	WHOLE_OBJECT
) as
select
$1:features[0]:properties:Name::string as feature_name
,$1:features[0]:geometry:coordinates::string as feature_coordinates
,$1:features[0]:geometry::string as geometry
,st_length(to_geography(geometry)) as length_of_trail
,$1:features[0]:properties::string as feature_properties
,$1:crs:properties:name::string as specs
,$1 as whole_object
from @trails_geojson (file_format => ff_json)
;

/*
📓  Bringing the Trails Together
Remember that we've done a lot of cool things even though we still haven't loaded any of this data!!

We have left the data where it landed (when Camila downloaded it from her fitness-tracking watch). And we have layered structure into our queries using file formats and views. We're not saying this is a great way to engineer data, we're teaching you about all the tools in the leave-it-where-it-lands toolbox.

And again, does it feel a little kludge-y sometimes? Yes! But depending on the project team, and the setting, and the project deadline - these no-loading tools might save you from spending critical time on the wrong tasks.

So, let's keep pushing the limits of this leave-it-where-it-lands strategy and layer on a little more of what we need to meet our goals. 

Let's try to get the data from CHERRY_CREEK_TRAIL and DENVER_AREA_TRAILS to look enough alike that we can run some GeoSpatial functions on all 5 trails at one time!

🥋 Create a View on Cherry Creek Data to Mimic the Other Trail Data
 */
 --Create a view that will have similar columns to DENVER_AREA_TRAILS 
--Even though this data started out as Parquet, and we're joining it with geoJSON data
--So let's make it look like geoJSON instead.
create or replace view DENVER_AREA_TRAILS_2 as
select 
trail_name as feature_name
,'{"coordinates":['||listagg('['||lng||','||lat||']',',') within group (order by point_id)||'],"type":"LineString"}' as geometry
,st_length(to_geography(geometry))  as trail_length
from cherry_creek_trail
group by trail_name;

-- 🥋 Use A Union All to Bring the Rows Into a Single Result Set
--Create a view that will have similar columns to DENVER_AREA_TRAILS 
select feature_name, geometry, trail_length
from DENVER_AREA_TRAILS
union all
select feature_name, geometry, trail_length
from DENVER_AREA_TRAILS_2;

/*
📓  Now We've Got GeoSpatial LineStrings for All 5 Trails in the Same View
We can also compare the lengths of the various trails (listed in meters, not cheeseburgers). 

🥋 But Wait! There's More!
*/
--Add more GeoSpatial Calculations to get more GeoSpecial Information! 
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth
, trail_length
from DENVER_AREA_TRAILS
union all
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth
, trail_length
from DENVER_AREA_TRAILS_2;

-- 🥋 Make it a View
create or replace view trails_and_boundaries as 
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth
, trail_length
from DENVER_AREA_TRAILS
union all
select feature_name
, to_geography(geometry) as my_linestring
, st_xmin(my_linestring) as min_eastwest
, st_xmax(my_linestring) as max_eastwest
, st_ymin(my_linestring) as min_northsouth
, st_ymax(my_linestring) as max_northsouth
, trail_length
from DENVER_AREA_TRAILS_2;

select *
from trails_and_boundaries
;

-- 📓  A Polygon Can be Used to Create a Bounding Box
select 'POLYGON(('|| 
    min(min_eastwest)||' '||max(max_northsouth)||','|| 
    max(max_eastwest)||' '||max(max_northsouth)||','|| 
    max(max_eastwest)||' '||min(min_northsouth)||','|| 
    min(min_eastwest)||' '||min(min_northsouth)||'))' AS my_polygon
from trails_and_boundaries;

use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
  'DLKW07' as step
   ,( select round(max(max_northsouth))
      from MELS_SMOOTHIE_CHALLENGE_DB.TRAILS.TRAILS_AND_BOUNDARIES)
      as actual
 ,40 as expected
 ,'Trails Northern Extent' as description
 ); 

 