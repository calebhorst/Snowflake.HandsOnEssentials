-- Rename the Database You Got From the Share
use role accountadmin;
alter database global_weather__climate_data_for_bi
rename to weathersource;

use database weathersource;
show schemas;

-- How many tables appear in WeatherSource's share?
select *
from information_schema.tables
where table_catalog = 'WEATHERSOURCE'
and table_schema <> 'INFORMATION_SCHEMA'
and table_type like '%TABLE%'
;

-- How many secure views appear in WeatherSource's share (in the STANDARD_TILE schema)?
select *
from information_schema.tables
where table_catalog = 'WEATHERSOURCE'
and table_schema <> 'STANDARD_TILE'
and table_type like 'VIEW'
;


-- set your worksheet drop lists to the location of your GRADER function
--DO NOT EDIT ANYTHING BELOW THIS LINE
USE ROLE ACCOUNTADMIN;
USE UTIL_DB.PUBLIC;
--This DORA Check Requires that you RUN two Statements, one right after the other
show resource monitors in account;

--the above command puts information into memory that can be accessed using result_scan(last_query_id())
-- If you have to run this check more than once, always run the SHOW command immediately prior
select grader(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'CMCW09' as step
 ,( select IFF(count(*)>0,1,0) 
    from table(result_scan(last_query_id())) 
    where "name" = 'DAILY_3_CREDIT_LIMIT'
    and "credit_quota" = 3
    and "frequency" = 'DAILY') as actual
 , 1 as expected
 ,'Resource Monitors Exist' as description
); 