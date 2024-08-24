--🥋 Create a Sequence to Use as a Row ID
/*
We first learned about sequences in the Data Warehousing Workshop (DWW). And we saw how they are set up and how they work. Now we'll create one and use it to set up a unique id for each order. 
*/
use role sysadmin;
create sequence if not exists smoothies.public.order_seq
    start = 1
    increment = 2
    order
    comment = 'PRovide a unique id for each smoothie order'
;

--🥋 Truncate the Orders Table
/*
We can't add a column with a UNIQUE ID if the table has rows in it already. Truncate the Orders table to remove all rows. 
*/
truncate table SMOOTHIES.PUBLIC.ORDERS;

--🥋 Add the Unique ID Column  
alter table SMOOTHIES.PUBLIC.ORDERS 
add column order_uid integer --adds the column
default smoothies.public.order_seq.nextval  --sets the value of the column to sequence
constraint order_uid unique enforced; --makes sure there is always a unique value in the column

/*
If you see an error message, make sure you truncated the table before trying to add this new column.
*/ 

--🥋 Audit Ownership of All Your Objects
/*
Now is a good time to go through all your objects and make sure they are all owned by the SYSADMIN role. This will keep you from having issues with getting all the parts working together. Watch the short video below (1 1/2 minutes long, or 45 seconds if you watch it at double-speed). 
*/

--🥋 Test Your Apps
/*
Now that you know everything is owned by SYSADMIN, it should be easy to check and make sure all the pieces are working together.

Go in to your Ordering app and submit a few orders, then go into the Pending Orders app and mark a few orders as filled. As you make changes in the apps, check the ORDERS table in the database and make sure you are seeing the updates as you would expect. 

If anything isn't working properly go back and see where you might have skipped a step or made some other mistake. 

NOTE: You may see an error on the Pending Orders app whenever you don't have any unfilled orders, but that's okay.  We'll fix that later, right now focus on creating orders and then marking them filled.
*/

select *
from smoothies.public.orders
;


--🥋 The ORDERS Table Definition
/*
We've altered the table several times already so just to make sure everyone has the same definition, let's drop and recreate the table. 

We can also put the columns in a more intuitive order. In most tables, the unique id column is the first column.  This will also give us a fresh start on orders. 
*/
use role sysadmin;
create or replace table smoothies.public.orders (
       order_uid integer default smoothies.public.order_seq.nextval,
       order_filled boolean default false,
       name_on_order varchar(100),
       ingredients varchar(200),
       constraint order_uid unique (order_uid),
       order_ts timestamp_ltz default current_timestamp()
);

-- 🥋 Add a Merge Statement 
/*
To add the merge statement you need to import a Snowpark function called "when_matched". So, find the line where we import the col function, add a comma and then add when_matched. 

After importing the function, copy and paste the code below to create a Snowpark Merge statement. 

    og_dataset = session.table("smoothies.public.orders")
    edited_dataset = session.create_dataframe(editable_df)
    og_dataset.merge(edited_dataset
                     , (og_dataset['ORDER_UID'] == edited_dataset['ORDER_UID'])
                     , [when_matched().update({'ORDER_FILLED': edited_dataset['ORDER_FILLED']})]
                    )
*/                    

-- 🥋 Making the Success Message More Meaningful  
/*
It would be better to see the success message only when the MERGE Succeeds.
*/ 

-- 🥋 Making the GUI Look Better 
/*
It would be better not to see the table if there are no pending orders.
*/ 

/*
-- 📓 Limiting Smoothie Orders to Just 5 or Fewer Fruits
Remember that when Mel and Melanie were discussing this week's Sprint, Mel committed to getting the first two items on the TO-DO list completed. He promised to spend any extra time just researching the third TO-DO. 

He's got one more day before he meets with his mom to show her the second iteration of his Order prototype and the first iteration of his prototype SiS app for the kitchen.  He'll use the remaining time to research TO-DO #3. 

-- 🥋 Researching Limiting Entries on Streamlit Multiselects
Mel is delighted to see that Streamlit have a property called max_selections. That seems like a super-easy way to limit the fruits added to an order. 

Mel gives the property a try and it does seem to work. He has more than completed his work for this week's Sprint!!

NOTE: We found the max_selections does what we need it to do. But it's also a little wonky because it seems to give you the alert when you choose your fifth item instead of waiting until you try to add a 6th. That doesn't seem quite right to us, but perhaps we're missing something. 
*/

-- Set your worksheet drop lists
use util_db.public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DABW005' as step
 ,(select count(*) from SMOOTHIES.INFORMATION_SCHEMA.STAGES
where stage_name like '%(Stage)') as actual
 , 2 as expected
 ,'There seem to be 2 SiS Apps' as description
);
