/*
📓 Non-Loaded Data is Easy, Let's Do Some More!
For the metadata files, we created file formats and then used those file formats when we created views. It was pretty easy, right? 

Remember that Zena (and you) started by creating two Stage objects that you uploaded files into.

Zena then focused her efforts on one of those stages - the PRODUCT_METADATA stage - that happens to contain only STRUCTURED data files. She learned to use FILE FORMATS and VIEWS to make the files very accessible without even loading her data into a Snowflake table!  

Zena has another other Stage objects she set up. Next, she wants to use her SWEATSUITS stage, however, that stage contains images.

Images are considered UNSTRUCTURED data, so she's wondering if accessing images without loading them will be just as easy as the flat files. 

Zena's not sure but she'll give it a try!

🎯 Run a List Command On the SWEATSUITS Stage
Run a LIST command on the SWEATSUITS Stage you created.

What do you see? 
*/
LIST @zenas_athleisure_db.products.SWEATSUITS;

/*
📓 Let's Query the Unstructured Unloaded Data!
Do it again for another stage

Zena has shifted her focus to the SWEATSUITS stage and plans to repeat what she did with the last stage. She's run the list command and was able to see a list of the files. Now she plans to query using the $1, $2, $3 way of accessing the columns in unloaded/external data, but will that work?

Once she queries the data she can also build file formats to make the data look nice, right? 

Uh-oh! It's giving us an error message!

🥋 Try to Query an Unstructured Data File
*/

SELECT $1
FROM @zenas_athleisure_db.products.sweatsuits
; 

/*
🥋 What's Going On?
Zena decided to try to find out. She had a hunch that Snowflake might be trying to read the file as if it were semi-structured data. So she did a quick test.

Opening the image file in a simple text editor, she thinks it's likely that Snowflake is seeing something similar to what her text editor is seeing. She needs a better way. She wants Snowflake to give her list of files not the insides of each file, separated into multiple rows.

🥋 Query with 2 Built-In Meta-Data Columns
*/
USE zenas_athleisure_db.products;
SELECT
  metadata$filename,
  metadata$file_row_number
FROM @sweatsuits/._purple_sweatsuit.png;

/*
🎯 Write a Query That Returns Something More Like a List Command
 Can you write a query that would GROUP BY the file name and look something like the results below?

Use either the MAX function or a COUNT to get an idea of the comparative file size for all the files in the stage.
*/

SELECT
  metadata$filename,
  MAX(metadata$file_row_number) AS num_rows
FROM @sweatsuits
GROUP BY 1
;

/*
📓 File Formats for Unstructured Data? Nope. 
 

Just as the  SELECT $1 Query method won't work for Unstructured Data, neither will file formats.

File formats come in 6 flavors - CSV, JSON, XML, PARQUET, ORC, & AVRO. Notice that nothing in that list says "PDF" or "Image" or "PNG" or "JPG." 

For images, we'll have to find a better way. Luckily, the better way exists!

It's a Directory Table. A directory table was set up on your Stage when you created it. You might not have noticed it, but it's there and it's enabled.  

🥋 Query the Directory Table of a Stage
*/

SELECT * 
FROM DIRECTORY(@sweatsuits);

/*
📓 What About Functions for Directory Tables?
Zena has already seen that she can't really query the image files the same way she can non-loaded flat files. She's also seen that the preferred way to get information about the files is to use a directory table. Now she's wondering just how much she can do with a directory table and the columns it returns. 

Can she run functions on the columns? And if she creates a SELECT that makes her data look a little nicer, can she put a view on top of it? 

🥋 Start By Checking Whether Functions will Work on Directory Tables 
*/

SELECT 
  REPLACE(relative_path, '._', ' ') AS no_underscores_filename,
  REPLACE(no_underscores_filename, '.png') AS just_words_filename,
  INITCAP(just_words_filename) AS product_name
FROM DIRECTORY(@sweatsuits)
;

/*
📓 Cool Snowflake SQL Trick!
Did you notice that Zena was able to define a column using the AS syntax, and then use that column name in the very next line of the same SELECT? This is not true in many other database systems and can be very convenient when developing complex syntax.

Zena is new to SQL so she tried it, and it worked! She knows she could NEST the functions instead of creating 3 columns on her way to her goal. Now that she's tested things, she's going to NEST the functions progressively.

🎯 Nest 3 Functions into 1 Statement
We did the first one for you as an example.  

Now, can you nest them all into a single column and name it "PRODUCT_NAME"? 

Don't expect to get it right the first time unless you are experienced with SQL. Add the functions one at a time and then go on to add the next. Keep copies of each stage so if you mess up, you can go back to your last successful version. 
*/
SELECT  INITCAP(REPLACE(REPLACE(REPLACE(relative_path, '_', ' '), '.', ' '), 'png', ' ')) AS product_name
FROM DIRECTORY(@sweatsuits)
;

/*
📓 Functions Work on Directory Tables, What About Joins? 
Zena was able to use functions on the directory table, just as she would if it was a regular, internal Snowflake table. 

Can she also join a directory table to a regular, internal Snowflake table?  She wants to try it. 

If that works, can she join the directory table and the regular internal table to one of the views she created earlier on the external staged data? She wants to try that, too!

Let's work alongside Zena and give those things a try! 

🥋 Create an Internal Table in the Zena Database
*/

--create an internal table for some sweatsuit info
CREATE OR REPLACE TABLE zenas_athleisure_db.products.sweatsuits (
  color_or_style VARCHAR(25),
  file_name VARCHAR(50),
  price NUMBER(5,2)
);

--fill the new table with some data
INSERT INTO  zenas_athleisure_db.products.sweatsuits 
(color_or_style, file_name, price)
VALUES
('Burgundy', '._burgundy_sweatsuit.png',65),
('Charcoal Grey', '._charcoal_grey_sweatsuit.png',65),
('Forest Green', '._forest_green_sweatsuit.png',64),
('Navy Blue', '._navy_blue_sweatsuit.png',65),
('Orange', '._orange_sweatsuit.png',65),
('Pink', '._pink_sweatsuit.png',63),
('Purple', '._purple_sweatsuit.png',64),
('Red', '._red_sweatsuit.png',68),
('Royal Blue',	'._royal_blue_sweatsuit.png',65),
('Yellow', '._yellow_sweatsuit.png',67);

-- 🎯 Can You Join These?
-- This challenge lab does not include step-by-step details. Can you join the directory table and the new sweatsuits table?
SELECT  INITCAP(REPLACE(REPLACE(REPLACE(relative_path, '_', ' '), '.', ' '), 'png', ' ')) AS product_name
FROM DIRECTORY(@sweatsuits) AS d
INNER JOIN zenas_athleisure_db.products.sweatsuits AS s ON d.relative_path = s.file_name
;

/*
🎯 Replace the * With a List of Columns
Narrow down the columns available so that you return results like those shown below. 

Create a view named PRODUCT_LIST. 
*/
CREATE OR REPLACE VIEW zenas_athleisure_db.products.product_list
AS
SELECT 
  INITCAP(REPLACE(REPLACE(REPLACE(d.relative_path, '_', ' '), '.', ' '), 'png', ' ')) AS product_name,
  s.file_name,
  s.color_or_style,
  s.price::NUMBER(38,2) AS price,
  d.file_url
FROM DIRECTORY(@sweatsuits) AS d
INNER JOIN zenas_athleisure_db.products.sweatsuits AS s ON d.relative_path = s.file_name
;

SELECT *
FROM zenas_athleisure_db.products.product_list
;

/*
📓  Adding a Cross Join
Zena needs to create fake sweat suit listings for every color in the PRODUCT_LIST view, and every size in the SWEATSUIT_SIZES view we created earlier.

We can do this with a quick CROSS JOIN.  Cross Joins are also called "cartesian products" and many times when data professionals talk about cartesian products they are describing a bad join that resulted in many more records than they intended. In this case, though, the cartesian product (multiplicative) is our goal. 

Remember that Cross Joins are different than Outer Joins. While both joins can result in an "explosion" of rows, the resulting columns look different.

If Zena were building a REAL athleisure website, she wouldn't want to offer every color sweat suit in every size, instead she would probably want to create size rows only for those sweat suits she had in inventory. In this case though, Zena is just working on a proof of concept, so a CROSS join will be great, because it's fast! 

🥋 Add the CROSS JOIN 
*/
SELECT * 
FROM product_list ASp
CROSS JOIN sweatsuit_sizes;

CREATE OR REPLACE VIEW zenas_athleisure_db.products.catalog
AS
SELECT * 
FROM product_list ASp
CROSS JOIN sweatsuit_sizes
;

-- The CATALOG view should return 180 rows. 
SELECT *
FROM zenas_athleisure_db.products.catalog
;


USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DLKW03' AS step,
      ( SELECT COUNT(*) FROM zenas_athleisure_db.products.catalog) AS actual,
      180 AS expected,
      'Cross-joined view exists' AS description
  ); 

/*
📓 What is a Data Lake?
Even though this workshop is called the Data Lake Workshop (DLKW), we haven't yet discussed what exactly we mean when we say "Data Lake." The Data Lake metaphor was introduced to the world in 2011 by James Dixon, who was the Chief Technology Officer for a company called Pentaho, at that time.

Dixon said:

If you think of a data mart as a store of bottled water -- cleansed and packaged and structured for easy consumption -- the data lake is a large body of water in a more natural state. The contents of the data lake stream in from a source to fill the lake, and various users of the lake can come to examine, dive in, or take samples.
When we talk about Data Lakes at Snowflake, we tend to mean data that has not been loaded into traditional Snowflake tables. We might also call these traditional tables "native" Snowflake tables, or "regular" tables. 

As we've already seen, Structured and Semi-structured data that is sitting outside of Snowflake tables can be easily accessed and analyzed using familiar Snowflake tools like views, file formats, and SQL queries. 

We've also seen how Unstructured data, not loaded into Snowflake, can be accessed with a special Snowflake tool called a Directory Table. We've also seen how Directory Tables can be used in combination with functions, joins, internal tables, and standard views to access that non-loaded data. 

And through all this, we've seen that bringing together loaded and non-loaded data is a simple and seamless process.  When some data is loaded and some is left in a non-loaded state the two types can be joined and queried together, this is sometimes referred to as a Data Lakehouse. 


📓 WHAT You Can, WHERE You Can - With Snowflake's Many HOW-You-Cans
Depending on your role in a data-driven organization:

You may have the power to move data into Snowflake tables, or you may not.
You may have the power to update data already loaded in Snowflake tables, or you may not.
You may have the power to copy data from one stage to another, or you may not.
Snowflake makes it possible for you to do WHAT you can, WHERE you can, because Snowflake keeps adding new HOW-You-Cans to the Snowflake toolset. 

So, while a worker in one department might think "I'll just run an update statement on that table," another worker trying to achieve the same goal might need to modify a view in their little corner of Snowflake, while another might be able to add a file to a cloud folder and put a stage and view on top of that file, and then join it to data someone else has loaded. 

All the different Hands-On Essentials workshops help you learn about various WHATs and HOWs of Snowflake.

This workshop focuses more specifically on one of the WHEREs. In this case, the WHERE is external. The WHERE is external to Snowflake's native tables. 

📓  Zena's Work So Far
Zena has been able to develop her website prototype very quickly by not bothering to load the data.  

She also added a quick internal table and used that in a join with her non-loaded data. She wants to add another internal table and do few more things. Her proof of concept is really taking shape!

🥋 Add the Upsell Table and Populate It
*/

-- Add a table to map the sweatsuits to the sweat band sets
CREATE TABLE zenas_athleisure_db.products.upsell_mapping
(
  sweatsuit_color_or_style VARCHAR(25),
  upsell_product_code VARCHAR(10)
);

--populate the upsell table
INSERT INTO zenas_athleisure_db.products.upsell_mapping
(
  sweatsuit_color_or_style,
  upsell_product_code 
)
VALUES
('Charcoal Grey','SWT_GRY'),
('Forest Green','SWT_FGN'),
('Orange','SWT_ORG'),
('Pink', 'SWT_PNK'),
('Red','SWT_RED'),
('Yellow', 'SWT_YLW');

/*
📓 When Data is Left Where it Lands...
When data is left in the Lake-- (aka "left where it lands") -- (aka left in the stage) -- developers without the time or permissions to cleanse, normalize, and store it will need to be creative at times to get what they need, from whatever is already available.

In Zena's case, she's just trying to fast-track her website prototype! She prefers to think of her methods as relentlessly resourceful. 

As developers, we often look at the code of others and wonder, "What were they thinking when they wrote this mess?"

Klaus thinks this about Zena's code.
Zena thinks that about Mel's code.
Mel thinks that about Klaus' code. 
What do you think of the view below? Zena just wrote for her website prototype. (Yikes! Right?)

🥋 Zena's View for the Athleisure Web Catalog Prototype
*/

-- Zena needs a single view she can query for her website prototype
USE zenas_athleisure_db.products;
CREATE VIEW catalog_for_website AS 
SELECT
  color_or_style,
  price,
  file_name,
  GET_PRESIGNED_URL(@sweatsuits, file_name, 3600) AS file_url,
  size_list,
  COALESCE('Consider: ' ||  headband_description || ' & ' || wristband_description, 'Consider: White, Black or Grey Sweat Accessories')  AS upsell_product_desc
FROM
  (
    SELECT
      color_or_style,
      price,
      file_name,
      LISTAGG(sizes_available, ' | ') WITHIN GROUP (ORDER BY sizes_available) AS size_list
    FROM catalog
    GROUP BY color_or_style, price, file_name
  ) ASc
LEFT JOIN upsell_mapping ASu
  ON c.color_or_style = u.sweatsuit_color_or_style
LEFT JOIN sweatband_coordination ASsc
  ON u.upsell_product_code = sc.product_code
LEFT JOIN sweatband_product_line ASspl
  ON sc.product_code = spl.product_code;

USE util_db.public;
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT
      'DLKW04' AS step,
      (
        SELECT COUNT(*) 
        FROM zenas_athleisure_db.products.catalog_for_website 
        WHERE upsell_product_desc NOT LIKE '%e, Bl%'
      ) AS actual,
      6 AS expected,
      'Relentlessly resourceful' AS description
  ); 

/*
🖼️  Zena's Web Catalog Prototype! 
Zena wants to show Mel her new Athleisure Catalog prototype. She calls to tell him about it.  

Zena provides the web address of her app, and Mel promises to send her something to look at in a few days. 

You can also create the app if you would like to. Setting up your own version of Zena's Web Catalog prototype is completely OPTIONAL. It should take about 15 minutes if you want to give it a try. 

We'll show you two ways to do it.

You can do it with very simple code that requires a little more manual work. 
Or you can do it a slightly more complex way, that will be more like you would do for a production app.
If you did not do the DABW Workshop, it might not seem as easy. Even if you didn't do the workshop, you can try to set up the app. But if you get stuck, we can't really help - we'll just suggest you do the DABW workshop. 
*/

-- 🥋 Create Zena's Streamlit App (Optional)
/*
📓 Getting the Images to Display
There are two options for getting the images to display. You can either:

Put copies of the images in the same stage as the app, or
Use pre-signed URLs and give your app access to the stage where you originally stored your sweatsuit images.
We'll show you both ways, but if you want to stop after the first method, feel free. 
*/

-- 🥋 Load Copies of Image into Your App Stage
/*
Load copies of the image files into your app's stage. 

Once you have loaded the files, re-run the app and it should work. 

📓 The Second Option - Pre-signed URLs
Pre-signed URLs are a way for you to serve images to external users by giving them a link that has permissions for a limited period of time. 

If you look at the CATALOG_FOR_WEBSITE view, you can see we already created a presigned URL you can use. When the view is queried, the clock starts. The url will have 3600 seconds (1 hour) of access to the image. 

Right now you can see that on line 21 of the app code we pull the file_url into the dataframe. On line 29 we set a variable called URL to the file_url. But, after that we don't use the variable. 

On the last line of the app we have some code commented out. Remove the hash sign and run the app to expose the pre-signed url. 

🥋 Replace the Image Source
*/