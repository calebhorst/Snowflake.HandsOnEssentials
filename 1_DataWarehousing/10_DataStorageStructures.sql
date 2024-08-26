-- Create a New Database and Table
USE ROLE sysadmin;

// Create a new database and set the context to use the new database
CREATE DATABASE library_card_catalog COMMENT = 'DWW Lesson 10 ';

//Set the worksheet context to use the new database
USE DATABASE library_card_catalog;

// Create Author table
CREATE OR REPLACE TABLE author (
  author_uid NUMBER,
  first_name VARCHAR(50),
  middle_name VARCHAR(50),
  last_name VARCHAR(50)
);

// Insert the first two authors into the Author table
INSERT INTO author(author_uid, first_name, middle_name, last_name)  
VALUES
(1, 'Fiona', '','Macdonald'),
(2, 'Gian','Paulo','Faleschini');

// Look at your table with it's new rows
SELECT * 
FROM author;

-- Create a Sequence 
/*
A sequence is a counter. It can help you create unique ids for table rows. 
- There are ways to create unique ids within a single table called an AUTO-INCREMENT column. 
- Those are easy to set up and work well in a single table. 

A sequence can give you the power to split information across different tables and put the same ID in all tables as a way to make it easy to link them back together later. 
*/
-- NOTE:  If you do not include the word ORDER, your values will skip by 100 each time. 
CREATE SEQUENCE IF NOT EXISTS library_card_catalog.public.seq_author_uid
START = 1
INCREMENT = 1
ORDER
COMMENT = 'Use this to fill in USTHOR_UID'
;

-- View the Sequence Object
DESC SEQUENCE library_card_catalog.public.seq_author_uid;

-- Query the Sequence
USE ROLE sysadmin;

//See how the nextval function works
SELECT seq_author_uid.nextval;

-- Use the Sequence By Querying It
SELECT seq_author_uid.nextval;

-- Double It Up!
SELECT
  seq_author_uid.nextval,
  seq_author_uid.nextval;

SHOW SEQUENCES;

-- Recreate the Sequence with a Different Starting Value
/*
We will create the sequence again, this time with code. And this time we want it to start counting with the number 3 because there are already 2 rows in the table.

We want the next row we add to our authors table to have an AUTHOR_UID of 3. 
*/

-- Reset the Sequence then Add Rows to Author
//Drop and recreate the counter (sequence) so that it starts at 3 
// then we'll add the other author records to our author table
CREATE OR REPLACE SEQUENCE library_card_catalog.public.seq_author_uid
START = 3 
INCREMENT = 1 
ORDER
COMMENT = 'Use this to fill in the AUTHOR_UID every time you add a row';

//Add the remaining author records and use the nextval function instead 
//of putting in the numbers
INSERT INTO author(author_uid,first_name, middle_name, last_name) 
VALUES
(seq_author_uid.nextval, 'Laura', 'K','Egendorf'),
(seq_author_uid.nextval, 'Jan', '','Grover'),
(seq_author_uid.nextval, 'Jennifer', '','Clapp'),
(seq_author_uid.nextval, 'Kathleen', '','Petelinsek');

-- Create a 2nd Counter, a Book Table, and a Mapping Table
USE DATABASE library_card_catalog;
USE ROLE sysadmin;

// Create a new sequence, this one will be a counter for the book table
CREATE OR REPLACE SEQUENCE library_card_catalog.public.seq_book_uid
START = 1
INCREMENT = 1
ORDER
COMMENT = 'Use this to fill in the BOOK_UID every time you add a new row';


// Create the book table and use the NEXTVAL as the 
// default value each time a row is added to the table

CREATE OR REPLACE TABLE book
(
  book_uid NUMBER DEFAULT seq_book_uid.nextval,
  title VARCHAR(50),
  year_published NUMBER(4,0)
);

// Insert records into the book table
// You don't have to list anything for the
// BOOK_UID field because the default setting
// will take care of it for you

INSERT INTO book(title, year_published)
VALUES
('Food',2001),
('Food',2006),
('Food',2008),
('Food',2016),
('Food',2015);

// Create the relationships table
// this is sometimes called a "Many-to-Many table"
CREATE TABLE book_to_author
(
  book_uid NUMBER,
  author_uid NUMBER
);

//Insert rows of the known relationships
INSERT INTO book_to_author(book_uid, author_uid)
VALUES
(1,1),  // This row links the 2001 book to Fiona Macdonald
(1,2),  // This row links the 2001 book to Gian Paulo Faleschini
(2,3),  // Links 2006 book to Laura K Egendorf
(3,4),  // Links 2008 book to Jan Grover
(4,5),  // Links 2016 book to Jennifer Clapp
(5,6); // Links 2015 book to Kathleen Petelinsek


//Check your work by joining the 3 tables together
//You should get 1 row for every author
SELECT * 
FROM book_to_author ASba 
INNER JOIN author ASa 
  ON ba.author_uid = a.author_uid 
INNER JOIN book ASb 
  ON ba.book_uid=b.book_uid; 


-- Set your worksheet drop lists
USE ROLE accountadmin;
USE util_db.public;
-- DO NOT EDIT THE CODE 
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (  
  SELECT
    'DWW15' AS step,
    (
      SELECT COUNT(*) 
      FROM library_card_catalog.public.book_to_author ASba 
      INNER JOIN library_card_catalog.public.author         ASa 
        ON ba.author_uid = a.author_uid 
      INNER JOIN library_card_catalog.public.book           ASb 
        ON ba.book_uid=b.book_uid
    ) AS actual,
    6 AS expected,
    '3NF DB was Created.' AS description  
); 