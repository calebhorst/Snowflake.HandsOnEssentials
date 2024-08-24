/*
📓 Knowing WHEN to Leave Data Where It Lands
So, if we can reach through our External Stages and access data where it is, without loading it into tables, why don't we ALWAYS do that?

And if we shouldn't ALWAYS do that, how will we know when to LEAVE IT (and not load it) and when NOT to LEAVE IT (and instead, load it)?

This is not easy to answer. The answer will depend on a lot of factors. For now, we can show you HOW to leave the data where it lands, even though we can't answer the WHENs and the WHYs for you. 

leave it where it lands

In this lesson, you'll learn different things you can do  with data even when you don't load it. We'll call it "non-loaded" so that we can separate the concept of data that is loaded into Snowflake and then output back into a stage using an "unload" process. This data that is NEVER loaded, we'll call "non-loaded." 

🥋 List Commands Versus Select Statements 
Run a list command on the @PRODUCT_METADATA Stage. 

You can do this either by setting the worksheet context to ZENAS_ATHLEISURE_DB.PRODUCT and running:
list @product_metadata;

or you can run:
list @zenas_athleisure_db.products.product_metadata;

How many columns are there, and how many rows (files)?  
*/
use role sysadmin;
list @zenas_athleisure_db.products.product_metadata;

/*
📓 Simple Selects on Non-Loaded Data
We've done this before in other workshops. Remember that we can query data in a file, before we even load it. Let's explore the 3 flat files in the PRODUCT_METADATA stage. 

We're going to use a select statement on files in the @PRODUCT_METADATA Stage We can't run a select star - it won't work for data that hasn't been loaded.

Since we know very little about the structure of the files, let's just see what appears in the first column ($1) of each file. 

🥋 Query Data in the ZMD 
select $1
from @product_metadata; 

How many rows did you get back? And can you make any sense of them?  

📓 One File at a Time?
Can you modify the select statement so it only queries one file at a time? Pick a file name from the LIST command, and try to change your SELECT statement so it only queries the data from one of the 3 files.

Try it, and then go to the next page to see how we wrote our query. 

HINT: Add a / after the stage name and type in one of the fllenames.
*/
use zenas_athleisure_db.products;
select $1
from @product_metadata; 

select $1
from @product_metadata/product_coordination_suggestions.txt; 

/*
📓 What is Going On Here?
The data looks really weird, right? 

Snowflake hasn't been told anything about how the data in these files is structured so it's just making assumptions.  Snowflake is presuming that the files are CSVs because CSVs are a very popular file-formatting choice. It's also presuming each row ends with CRLF (Carriage Return Line Feed) because CRLF is also very common as a row delimiter.

Snowflake hedges its bets and presumes if you don't tell it anything about your file, the file is probably a standard CSV.

By using these assumptions, Snowflake treats the product_coordination_suggestions.txt file as if it only has one column and one row. 

📓 How Can We Tell Snowflake More about the Structure of Our File?
Of course you know the answer because we've been using File Formats since Badge 1.

We need to create some File Formats to help guide Snowflake in handling these files.
*/

/*
📓 Wait, I Still Don't Know What's Going on in This File!
We need to create some File Formats to handle these files, but no one has told us how the files are set up!

This is actually really common when you work with data - you get a file and you actually have to look at it and try to figure out what's going on.

So, you open the file in good text editor and look at it (you can see what we saw, below). 

Okay, there are carets (^) in this file. What are they doing? Are they separating each row?

We can learn about our data by trying out some different file format settings. Let's create a quick file format and see how the data looks when we use it with our SELECT statement. 

🥋 Create an Exploratory File Format
Let's create a file format to test whether the carets are supposed to separate one row from another.  We'll name our file formats starting with "ZMD" for "Zena's Metadata"?
*/
create file format zenas_athleisure_db.products.zmd_file_format_1
RECORD_DELIMITER = '^';

-- 🥋 Use the Exploratory File Format in a Query
select $1
from @product_metadata/product_coordination_suggestions.txt
(file_format => zmd_file_format_1);

/*
📓 An Alternate Theory
What if the carets aren't the row separators? What if they are the column separators, instead?

Let's create a second exploratory file format, and see what things look like when we use that one. 
*/

-- 🥋 Testing Our Second Theory
create file format zenas_athleisure_db.products.zmd_file_format_2
FIELD_DELIMITER = '^';  

select $1, $2, $3, $4, $5, $6, $7, $8, $9, $10
from @product_metadata/product_coordination_suggestions.txt
(file_format => zmd_file_format_2);

/*
🥋 A Third Possibility?
What if the carets separate records and a different symbol is used to separate the columns? Can you write a new File Format  (call it zmd_file_format_3) to make the results look like this? 

You'll need to define both the field delimiter and the row delimiter to make it work. Be sure to replace the question marks with the real delimiters!
*/
create or replace file format zenas_athleisure_db.products.zmd_file_format_3
FIELD_DELIMITER = '='
RECORD_DELIMITER = '^'; 

select $1, $2
from @product_metadata/product_coordination_suggestions.txt
(file_format => zmd_file_format_3);

/*
📓 Those Exploratory File Formats Could Be More Useful
We created zmd_file_format_1 as an exploration. Then we created zmd_file_format_2 as another "guess." These were fine for exploring but we don't need them anymore because we created the very useful zmd_file_format_3. We'll keep file format 3 around and use it anytime we want to query the "product coordination suggestions" file. 

Let's repurpose file format 1 so it can be used to parse the file shown below. 

🎯 Revise zmd_file_format_1
Let's repurpose file format 1 so it can be used to parse another file in the ZMD stage! 

Here's your challenge lab task!

Rewrite zmd_file_format_1 to parse sweatsuit_sizes.txt
You can either DROP the old file format and create a new one with the same name, or you can add the phrase "OR REPLACE" to the "CREATE FILE FORMAT" statement.

Once you've replaced zmd_file_format_1, use it to query the sweatsuit_sizes.txt file. 
*/
create or replace file format zenas_athleisure_db.products.zmd_file_format_1
RECORD_DELIMITER = ';';

select $1 as sizes_available
from @product_metadata/sweatsuit_sizes.txt
(file_format => zmd_file_format_1 );

/*
📓 Another, More Useful, File Format
Let's repurpose file format 2 so it can be used to parse the swt_product_line file.  What delimiters do you think might be used in this file?  

What's the record delimiter and what's the field delimiter? 
🎯 Revamp zmd_file_format_2
Here's your challenge lab task!

Rewrite zmd_file_format_2 to parse swt_product_line.txt
We want to write a file format that will display data as shown below. 
*/

create or replace file format zenas_athleisure_db.products.zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER = ';';

select $1, $2, $3
from @product_metadata/swt_product_line.txt
(file_format => zmd_file_format_2 );

/*
🥋 One More Thing!
After you update zmd_file_format_2 to parse swt_product_line.txt let's fix some of the weird formatting issues in some of the columns.

Add the TRIM_SPACE property to the file format. Set the property to TRUE and re-run the SELECT. Did that fix some of the issues? 

Some issues are resolved but others are not!

We're going to fix the issues shown with the green rectangles in the next lab! Look back at the image of the raw file near the top of this page. What do you think is causing those? It can't be spaces because if it was, our TRIM_SPACE file format property added to the file format would have fixed them.
*/
create or replace file format zenas_athleisure_db.products.zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER = ';'
TRIM_SPACE = TRUE;

select $1, $2, $3
from @product_metadata/swt_product_line.txt
(file_format => zmd_file_format_2 );

/*
🎯 Make Sure All 3 File Formats Have a Trim Space Property
The [TRIM_SPACE = True] file format setting is a good thing to have in place for most file formats, so take the time now to make sure all 3 of your file formats have this setting. 

Even after doing this, we'll still see some weird spacing, so we have to infer it's not just extra white spaces. It must be some other character or characters that are causing the issues. 
*/

create or replace file format zenas_athleisure_db.products.zmd_file_format_1
RECORD_DELIMITER = ';'
TRIM_SPACE = TRUE
;

create or replace file format zenas_athleisure_db.products.zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER = ';'
TRIM_SPACE = TRUE
;

create or replace file format zenas_athleisure_db.products.zmd_file_format_3
FIELD_DELIMITER = '='
RECORD_DELIMITER = '^'
TRIM_SPACE = TRUE
; 

/*
🥋 Dealing with Unexpected Characters
Many data files use CRLF (Carriage Return Line Feed) as the record delimiter, so if a different record delimiter is used, the CRLF can end up displayed or loaded! When strange characters appear in your data, you can refine your select statement to deal with them. 

In SQL we can use ASCII references to deal with these characters. 

13 is the ASCII for Carriage return
10 is the ASCII for Line Feed
SQL has a function, CHR() that will allow you to reference ASCII characters by their numbers.  So, chr(13) is the same as the Carriage Return character and chr(10) is the same as the Line Feed character. 

In Snowflake, we can CONCATENATE two values by putting || between them (a double pipe). So we can look for CRLF by telling Snowflake to look for:

 chr(13)||chr(10)
*/
select
    replace($1, chr(13)||chr(10)) as sizes_available
from @product_metadata/sweatsuit_sizes.txt
(file_format => zmd_file_format_1 )
; 
/*
📓 Other Options for the REPLACE() Function 
Instead of using:

REPLACE($1, chr(13||char(10)) 

You could use: 

REPLACE($1, concat(chr(13),chr(10)))

Or you could use: 

REPLACE($1, '\r\n')

Like almost any task with SQL, there are options. You might have even another option in mind. 
*/

select
    replace($1, chr(13)||chr(10)) as sizes_available
from @product_metadata/sweatsuit_sizes.txt
(file_format => zmd_file_format_1 )
where sizes_available <> ''
; 

/*
🥋 Convert Your Select to a View
Add this line above your select statement, to convert the SELECT statement to a view.
*/
create or replace view zenas_athleisure_db.products.sweatsuit_sizes 
as 
select
  replace($1, chr(13)||chr(10)) as sizes_available
from @product_metadata/sweatsuit_sizes.txt
(file_format => zmd_file_format_1 )
where sizes_available <> ''
; 

select *
from zenas_athleisure_db.products.sweatsuit_sizes 
;

/*
🎯 Make the Sweatband Product Line File Look Great!
sweatband raw data and product image

Continue using ZMD_FILE_FORMAT_2 with the swt_product_line.txt file. 
Make sure ZMD_FILE_FORMAT_2 removes leading spaces in the data with the TRIM_SPACE property. 
Remove CRLFs from the data (via your select statement).
If there are any weird, empty rows, remove them (also via the select statement).
Put a view on top of it to make it easy to query in the future! Name your view:  zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE
Don't forget to NAME the columns in your Create View statement. You can see the names you should use for your columns in the screenshot. 
*/
create or replace file format zenas_athleisure_db.products.zmd_file_format_2
FIELD_DELIMITER = '|'
RECORD_DELIMITER = ';'
TRIM_SPACE = TRUE
;

create or replace view zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE 
as 
select
  replace($1, chr(13)||chr(10)) as product_code
  ,$2 as headband_description
  ,$3 as wristband_description
from @product_metadata/swt_product_line.txt
(file_format => ZMD_FILE_FORMAT_2 )
where product_code <> ''
; 
select *
from zenas_athleisure_db.products.SWEATBAND_PRODUCT_LINE 
;

/*
🎯 Make the Product Coordination Data Look great!
File format 3 is already working for the product coordination data set, since it doesn't have a lot going on. 
Continue using ZMD_FILE_FORMAT_3 with the PRODUCT_COORDINATION_SUGGESTIONS.TXT
Remove CRLFs from the data (via your select statement).
If there are any weird, empty rows, remove them (also via the select statement).
Put a view on top of it to make it easy to query in the future! Name your view:  zenas_athleisure_db.products.SWEATBAND_COORDINATION
Give your view columns nice names!
*/

create or replace view zenas_athleisure_db.products.SWEATBAND_COORDINATION 
as 
select
  replace($1, chr(13)||chr(10)) as product_code
  ,$2 as has_matching_sweatsuit
from @product_metadata/product_coordination_suggestions.txt
(file_format => ZMD_FILE_FORMAT_3 )
where product_code <> ''
; 
select *
from zenas_athleisure_db.products.SWEATBAND_COORDINATION 
;

use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from
(
 SELECT
   'DLKW02' as step
   ,( select sum(tally) from
        (select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATBAND_PRODUCT_LINE
        where length(product_code) > 7 
        union
        select count(*) as tally
        from ZENAS_ATHLEISURE_DB.PRODUCTS.SWEATSUIT_SIZES
        where LEFT(sizes_available,2) = char(13)||char(10))     
     ) as actual
   ,0 as expected
   ,'Leave data where it lands.' as description
); 

select product_code, has_matching_sweatsuit
from zenas_athleisure_db.products.sweatband_coordination;
select product_code, headband_description, wristband_description
from zenas_athleisure_db.products.sweatband_product_line;

select sizes_available
from zenas_athleisure_db.products.sweatsuit_sizes;