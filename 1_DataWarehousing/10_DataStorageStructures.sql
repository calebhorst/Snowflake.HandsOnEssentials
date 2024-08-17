-- Create a New Database and Table
use role sysadmin;

// Create a new database and set the context to use the new database
create database library_card_catalog comment = 'DWW Lesson 10 ';

//Set the worksheet context to use the new database
use database library_card_catalog;

// Create Author table
create or replace table author (
   author_uid number 
  ,first_name varchar(50)
  ,middle_name varchar(50)
  ,last_name varchar(50)
);

// Insert the first two authors into the Author table
insert into author(author_uid, first_name, middle_name, last_name)  
values
(1, 'Fiona', '','Macdonald')
,(2, 'Gian','Paulo','Faleschini');

// Look at your table with it's new rows
select * 
from author;

-- Create a Sequence 
/*
A sequence is a counter. It can help you create unique ids for table rows. 
- There are ways to create unique ids within a single table called an AUTO-INCREMENT column. 
- Those are easy to set up and work well in a single table. 

A sequence can give you the power to split information across different tables and put the same ID in all tables as a way to make it easy to link them back together later. 
*/
-- NOTE:  If you do not include the word ORDER, your values will skip by 100 each time. 
create sequence if not exists library_card_catalog.public.seq_author_uid
start = 1
increment = 1
order
comment = 'Use this to fill in USTHOR_UID'
;

-- View the Sequence Object
desc sequence library_card_catalog.public.seq_author_uid;

-- Query the Sequence
use role sysadmin;

//See how the nextval function works
select seq_author_uid.nextval;

-- Use the Sequence By Querying It
select seq_author_uid.nextval;

-- Double It Up!
select seq_author_uid.nextval, seq_author_uid.nextval;

show sequences;

-- Recreate the Sequence with a Different Starting Value
/*
We will create the sequence again, this time with code. And this time we want it to start counting with the number 3 because there are already 2 rows in the table.

We want the next row we add to our authors table to have an AUTHOR_UID of 3. 
*/

-- Reset the Sequence then Add Rows to Author
//Drop and recreate the counter (sequence) so that it starts at 3 
// then we'll add the other author records to our author table
create or replace sequence library_card_catalog.public.seq_author_uid
start = 3 
increment = 1 
ORDER
comment = 'Use this to fill in the AUTHOR_UID every time you add a row';

//Add the remaining author records and use the nextval function instead 
//of putting in the numbers
insert into author(author_uid,first_name, middle_name, last_name) 
values
(seq_author_uid.nextval, 'Laura', 'K','Egendorf')
,(seq_author_uid.nextval, 'Jan', '','Grover')
,(seq_author_uid.nextval, 'Jennifer', '','Clapp')
,(seq_author_uid.nextval, 'Kathleen', '','Petelinsek');

-- Create a 2nd Counter, a Book Table, and a Mapping Table
use database library_card_catalog;
use role sysadmin;

// Create a new sequence, this one will be a counter for the book table
create or replace sequence library_card_catalog.public.seq_book_uid
  start = 1
  increment = 1
  ORDER
  comment = 'Use this to fill in the BOOK_UID every time you add a new row';


// Create the book table and use the NEXTVAL as the 
// default value each time a row is added to the table

create or replace table book
( book_uid number default seq_book_uid.nextval
 , title varchar(50)
 , year_published number(4,0)
);

// Insert records into the book table
// You don't have to list anything for the
// BOOK_UID field because the default setting
// will take care of it for you

insert into book(title, year_published)
values
 ('Food',2001)
,('Food',2006)
,('Food',2008)
,('Food',2016)
,('Food',2015);

// Create the relationships table
// this is sometimes called a "Many-to-Many table"
create table book_to_author
( book_uid number
  ,author_uid number
);

//Insert rows of the known relationships
insert into book_to_author(book_uid, author_uid)
values
 (1,1)  // This row links the 2001 book to Fiona Macdonald
,(1,2)  // This row links the 2001 book to Gian Paulo Faleschini
,(2,3)  // Links 2006 book to Laura K Egendorf
,(3,4)  // Links 2008 book to Jan Grover
,(4,5)  // Links 2016 book to Jennifer Clapp
,(5,6); // Links 2015 book to Kathleen Petelinsek


//Check your work by joining the 3 tables together
//You should get 1 row for every author
select * 
from book_to_author ba 
join author a 
on ba.author_uid = a.author_uid 
join book b 
on b.book_uid=ba.book_uid; 


-- Set your worksheet drop lists
use role accountadmin;
use util_db.public;
-- DO NOT EDIT THE CODE 
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (  
     SELECT 'DWW15' as step 
     ,( select count(*) 
      from LIBRARY_CARD_CATALOG.PUBLIC.Book_to_Author ba 
      join LIBRARY_CARD_CATALOG.PUBLIC.author a 
      on ba.author_uid = a.author_uid 
      join LIBRARY_CARD_CATALOG.PUBLIC.book b 
      on b.book_uid=ba.book_uid) as actual 
     , 6 as expected 
     , '3NF DB was Created.' as description  
); 