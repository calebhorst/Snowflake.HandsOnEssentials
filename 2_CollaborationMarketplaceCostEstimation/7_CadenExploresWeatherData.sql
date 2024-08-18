-- What Countries are Included in the HISTORY_DAY View?
select distinct
  country
from history_day
;
-- What Postal Codes Are Available from the Detroit Area?
select distinct
  postal_code
from weathersource.standard_tile.history_day
where postal_code like any ('481%','482%')
and country = 'US'
;

-- Convert Your Postal Code Query to a View
/*
    Create a new database so that you can create views that join the shared data from Weather Source, with local data. Call the new database MARKETING.
    Add a schema called MAILERS.
    Create a  view called DETROIT_ZIPS and put it in the MAILERS schema. The view should return 9 rows. 
    Make sure the database, schema and view are all owned by the SYSADMIN Role. 

    FYI: In the US, many people refer to Postal Codes as "Zip" Codes. 
*/
use role sysadmin;
create database if not exists marketing;
create schema if not exists mailers;
create or replace view marketing.mailers.detroit_zips
as
select distinct
  postal_code
from weathersource.standard_tile.history_day
where postal_code like any ('481%','482%')
and country = 'US'
;

select *
from marketing.mailers.detroit_zips as dz
inner join weathersource.standard_tile.history_day as hd on hd.postal_code = dz.postal_code
;

select count(1) --736,117
from weathersource.standard_tile.history_day
;

-- What's the Data Range on this Data Set?
/*
Let's figure out the time range covered by the data set. It may have a rolling window, meaning the data may change daily or weekly so your results you get may look different than what our query returns. 
*/
select 
    max(date_valid_std)
    ,min(date_valid_std)
from marketing.mailers.detroit_zips as dz
inner join weathersource.standard_tile.history_day as hd on hd.postal_code = dz.postal_code
;

select 
    max(date_valid_std)
    ,min(date_valid_std)
from marketing.mailers.detroit_zips as dz
inner join weathersource.standard_tile.forecast_day as fd on fd.postal_code = dz.postal_code
;

-- Can the Data Tell Me Which Day in the Next 2 Weeks Would Be Best for a Sale? 
/*
There are SO MANY columns to choose from. Lottie suggested that Caden just use the field with Average Cloud Cover Percentage since sunny days will generally be the best days in Detroit, regardless of whether it's winter or summer. 

Can you write a query that includes the date and the forecasted average cloud cover percentage for every date in the view?  We created that query and then noticed it had a lot more rows that just the 14 days in the date range. 

We remembered that we have 9 zip code rows per day! But we don't want to pick a day for each zip code! We want to pick just one day, using weather information for all the zip codes.

Caden asked Lottie what to do and Lottie asked Caden to just average the averages. (Yep, you read that right! One is Average Cloud Cover, but they are going to average across zip codes).

Caden used GROUP BY to get just one AVG per day. Can you do something like that and then sort (ORDER BY) to find the day with the lowest average cloud cover forecasted in the next two weeks?
*/
select 
    date_valid_std
    ,avg(avg_cloud_cover_tot_pct)
from marketing.mailers.detroit_zips as dz
inner join weathersource.standard_tile.history_day as hd on hd.postal_code = dz.postal_code
group by date_valid_std
order by avg(avg_cloud_cover_tot_pct)
;


create database if not exists util_db;
use role accountadmin;  
create or replace api integration dora_api_integration
api_provider = aws_api_gateway
api_aws_role_arn = 'arn:aws:iam::321463406630:role/snowflakeLearnerAssumedRole'
enabled = true
api_allowed_prefixes = ('https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora');

create or replace external function util_db.public.grader(
      step varchar
    , passed boolean
    , actual integer
    , expected integer
    , description varchar)
returns variant
api_integration = dora_api_integration 
context_headers = (current_timestamp, current_account, current_statement, current_account_name) 
as 'https://awy6hshxy4.execute-api.us-west-2.amazonaws.com/dev/edu_dora/grader'
; 

-- Is the GRADER Function working?
use role accountadmin;
use database util_db; 
use schema public; 

select grader(step, (actual = expected), actual, expected, description) as graded_results from
(SELECT 
 'DORA_IS_WORKING' as step
 ,(select 123) as actual
 ,123 as expected
 ,'Dora is working!' as description
); 


--THIS DORA CHECK MUST BE RUN IN THE ACME ACCOUNT!!!!!
select grader(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'CMCW10' as step
 ,( select count(*)
    from snowflake.account_usage.databases
    where (database_name in ('WEATHERSOURCE','INTERNATIONAL_CURRENCIES')
           and type = 'IMPORTED DATABASE'
           and deleted is null)
    or (database_name = 'MARKETING'
          and type = 'STANDARD'
          and deleted is null)
   ) as actual
 , 3 as expected
 ,'ACME Account Set up nicely' as description
); 

-- set the worksheet drop lists to match the location of your GRADER function
--DO NOT MAKE ANY CHANGES BELOW THIS LINE

--RUN THIS DORA CHECK IN YOUR ACME ACCOUNT

select grader(step, (actual = expected), actual, expected, description) as graded_results from (
SELECT 
  'CMCW11' as step
 ,( select count(*) 
   from MARKETING.MAILERS.DETROIT_ZIPS) as actual
 , 9 as expected
 ,'Detroit Zips' as description
); 