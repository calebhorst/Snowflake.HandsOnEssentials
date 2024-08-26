-- Create a Table & File Format for Nested JSON Data
// Create an Ingestion Table for the NESTED JSON Data
CREATE OR REPLACE TABLE library_card_catalog.public.nested_ingest_json 
(
  "RAW_NESTED_BOOK" VARIANT
);

-- Load table with file data
USE ROLE accountadmin;
SELECT $1
FROM
  @util_db.public.my_internal_stage/json_book_author_nested.txt
  (FILE_FORMAT => library_card_catalog.public.json_file_format)
;

COPY INTO library_card_catalog.public.nested_ingest_json
FROM @util_db.public.my_internal_stage
FILES = ( 'json_book_author_nested.txt')
FILE_FORMAT = ( FORMAT_NAME=library_card_catalog.public.json_file_format )
;

-- Query the Nested JSON Data
USE library_card_catalog.public;

//a few simple queries
SELECT raw_nested_book
FROM nested_ingest_json;

SELECT raw_nested_book:year_published
FROM nested_ingest_json;

SELECT raw_nested_book:authors
FROM nested_ingest_json;

//Use these example flatten commands to explore flattening the nested book and author data
SELECT value:first_name
FROM nested_ingest_json,
  LATERAL FLATTEN(input => raw_nested_book:authors);

SELECT value:first_name
FROM nested_ingest_json,
  TABLE(FLATTEN(raw_nested_book:authors));

//Add a CAST command to the fields returned
SELECT
  value:first_name::VARCHAR,
  value:last_name::VARCHAR
FROM nested_ingest_json,
  LATERAL FLATTEN(input => raw_nested_book:authors);

//Assign new column  names to the columns using "AS"
SELECT
  value:first_name::VARCHAR AS first_nm,
  value:last_name::VARCHAR AS last_nm
FROM nested_ingest_json,
  LATERAL FLATTEN(input => raw_nested_book:authors);


-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.
USE ROLE accountadmin;
USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (   
  SELECT
    'DWW17' AS step,
    (
      SELECT row_count 
      FROM library_card_catalog.information_schema.tables 
      WHERE table_name = 'NESTED_INGEST_JSON'
    ) AS actual,
    5 AS expected,
    'Check number of rows' AS description  
); 

-- Create a Database, Table & File Format for Nested JSON Data
//Create a new database to hold the Twitter file
CREATE DATABASE social_media_floodgates 
COMMENT = 'There\'s so much data from social media - flood warning';

USE DATABASE social_media_floodgates;

//Create a table in the new database
CREATE TABLE social_media_floodgates.public.tweet_ingest 
("RAW_STATUS" VARIANT) 
COMMENT = 'Bring in tweets, one row per tweet or status entity';

//Create a JSON file format in the new database
CREATE FILE FORMAT social_media_floodgates.public.json_file_format 
TYPE = 'JSON' 
COMPRESSION = 'AUTO' 
ENABLE_OCTAL = FALSE 
ALLOW_DUPLICATE = FALSE 
STRIP_OUTER_ARRAY = TRUE 
STRIP_NULL_VALUES = FALSE 
IGNORE_UTF8_ERRORS = FALSE;

-- Load and View the Nested JSON File 
-- Upload the data into the new table of the new database you just created. Use the file format you just created. 
USE ROLE accountadmin;
SELECT $1
FROM
  @util_db.public.my_internal_stage/nutrition_tweets.json
  (FILE_FORMAT => social_media_floodgates.public.json_file_format)
;

COPY INTO social_media_floodgates.public.tweet_ingest
FROM @util_db.public.my_internal_stage
FILES = ( 'nutrition_tweets.json')
FILE_FORMAT = ( FORMAT_NAME=social_media_floodgates.public.json_file_format )
;

-- After loading, view the rows in the table. 
SELECT *
FROM social_media_floodgates.public.tweet_ingest
;

-- Query the Nested JSON Tweet Data!
//select statements as seen in the video
SELECT raw_status
FROM tweet_ingest;

SELECT raw_status:entities
FROM tweet_ingest;

SELECT raw_status:entities:hashtags
FROM tweet_ingest;

//Explore looking at specific hashtags by adding bracketed numbers
//This query returns just the first hashtag in each tweet
SELECT raw_status:entities:hashtags[0].text
FROM tweet_ingest;

//This version adds a WHERE clause to get rid of any tweet that 
//doesn't include any hashtags
SELECT raw_status:entities:hashtags[0].text
FROM tweet_ingest
WHERE raw_status:entities:hashtags[0].text IS NOT NULL;

//Perform a simple CAST on the created_at key
//Add an ORDER BY clause to sort by the tweet's creation date
SELECT raw_status:created_at::DATE
FROM tweet_ingest
ORDER BY raw_status:created_at::DATE;

//Flatten statements that return the whole hashtag entity
SELECT value
FROM tweet_ingest
,
  LATERAL FLATTEN(input => raw_status:entities:hashtags);

SELECT value
FROM tweet_ingest,
  TABLE(FLATTEN(raw_status:entities:hashtags));

//Flatten statement that restricts the value to just the TEXT of the hashtag
SELECT value:text
FROM tweet_ingest
,
  LATERAL FLATTEN(input => raw_status:entities:hashtags);


//Flatten and return just the hashtag text, CAST the text as VARCHAR
SELECT value:text::VARCHAR
FROM tweet_ingest
,
  LATERAL FLATTEN(input => raw_status:entities:hashtags);

//Flatten and return just the hashtag text, CAST the text as VARCHAR
// Use the AS command to name the column
SELECT value:text::VARCHAR AS the_hashtag
FROM tweet_ingest
,
  LATERAL FLATTEN(input => raw_status:entities:hashtags);

//Add the Tweet ID and User ID to the returned table
SELECT
  raw_status:user:id AS user_id,
  raw_status:id AS tweet_id,
  value:text::VARCHAR AS hashtag_text
FROM tweet_ingest
,
  LATERAL FLATTEN(input => raw_status:entities:hashtags);


-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.
USE ROLE accountadmin;
USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DWW18' AS step,
      (
        SELECT row_count 
        FROM social_media_floodgates.information_schema.tables 
        WHERE table_name = 'TWEET_INGEST'
      ) AS actual,
      9 AS expected,
      'Check number of rows' AS description  
  ); 

-- Create a View of the Tweet Data Looking "Normalized"
CREATE OR REPLACE VIEW social_media_floodgates.public.hashtags_normalized AS
(
  SELECT
    raw_status:user:id AS user_id,
    raw_status:id AS tweet_id,
    value:text::VARCHAR AS hashtag_text
  FROM social_media_floodgates.public.tweet_ingest
  ,
    LATERAL FLATTEN(input => raw_status:entities:hashtags)
);

-- Set your worksheet drop lists. DO NOT EDIT THE DORA CODE.
USE ROLE accountadmin;
USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DWW19' AS step,
      (
        SELECT COUNT(*) 
        FROM social_media_floodgates.information_schema.views 
        WHERE table_name = 'HASHTAGS_NORMALIZED'
      ) AS actual,
      1 AS expected,
      'Check number of rows' AS description
  ); 


SELECT CURRENT_ACCOUNT() AS account_locator;
SELECT CURRENT_ORGANIZATION_NAME()||'.'||CURRENT_ACCOUNT_NAME() AS account_id;