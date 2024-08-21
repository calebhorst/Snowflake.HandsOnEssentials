-- 🥋 Remove the SelectBox

-- 🥋 Focus on the FRUIT_NAME Column
/*
To use a Snowpark COLUMN function named "col" we need to import it into our app. We'll place the import statement close to where we plan to use it. This will make more sense for beginners as they will be able to see why we imported it and how it is used. In a later lab, we'll move it up with other import statements in order to show good code organization.

from snowflake.snowpark.functions import col
my_dataframe = session.table("smoothies.public.fruit_options").select(col('FRUIT_NAME'))
*/

-- 📓 The Data Returned is both a list and a LIST
/*
We are placing the multiselect entries into a variable called "ingredients." We can then write "ingredients" back out to the screen.
    - Our ingredients variable is an object or data type called a LIST. So it's a list in the traditional sense of the word, but it is also a datatype or object called a LIST. A LIST is different than a DATAFRAME which is also different from a STRING!
    - We can use the st.write() and st.text() methods to take a closer look at what is contained in our ingredients LIST. 

ingredients_list = st.multiselect(
    'Choose up to 5 ingredients:'
    , my_dataframe
)
*/

-- 🥋 Display the LIST
/*
st.write(ingredients_list)
st.text(ingredients_list)
*/

-- 🥋 Cleaning Up Empty Brackets
/*
- Run your entry form (SiS App) without any ingredients in the selection box. Notice the empty brackets. Those look ugly. 
- To clean up these empty brackets, we can add an IF block. It's called a block because everything below it (that is indented) will be dependent on the IF statement. 


if ingredients_list:
    st.write(ingredients_list)
    st.text(ingredients_list)
*/

-- 🥋 Create a Place to Store Order Data
/*
Create a table in your SMOOTHIES database.
Make sure it is owned by SYSADMIN. 
Name it ORDERS.
Give it a single 200 character-limit text column named INGREDIENTS. 
*/

-- Create a ORDERS table in your SMOOTHIES database.
use role sysadmin;
create table if not exists smoothies.public.orders(
    ingredients varchar(200)
)
;

-- 📓 Changing the LIST to a STRING
/*
- In order to convert the list to a string, we need to first create a variable and then make sure Python thinks it contains a string.
    - We do this by setting our variable to ' ' -- which is an empty string.

Note: DO NOT PUT A SPACE BETWEEN THE QUOTES. IT MAY LOOK LIKE THERE IS A SPACE, BUT THERE IS NOT A SPACE. 
*/

-- 🥋 Create the INGREDIENTS_STRING Variable 
/*
if ingredients_list:
    st.write(ingredients_list)
    st.text(ingredients_list)

    ingredients_string = ''
*/

-- 📓 How a FOR LOOP Block Works
/*
To convert the LIST to a STRING we can add an FOR LOOP block. A FOR LOOP will repeat once FOR every value in the LIST. 

We can use the phrase:
    for fruit_chosen in ingredients_list:
    which actually means...
    for each fruit_chosen in ingredients_list multiselect box: do everything below this line that is indented. 

We never defined a variable named fruit_chosen, but Python understands that whatever is placed in that position is a counter for items in the list.

So we could just as easily say: 
    for x in ingredients_list:
    or 
    for each_fruit in ingredients_list:

The += operator means "add this to what is already in the variable" so each time the FOR Loop is repeated, a new fruit name is appended to the existing string. 

TIP: The variables ingredients_list and ingredients_string are easy to mix up. If you get an error, check these names to make sure you haven't used one when you were supposed to use the other.     

if ingredients_list:
    st.write(ingredients_list)
    st.text(ingredients_list)

    ingredients_string = ''

    for fruit_chosen in ingredients_list:
        ingredients_string += fruit_chosen

    st.write(ingredients_string)
*/

-- 🥋 Improve the String Output
/*
PRO TIP: This workshop does not represent amazingly efficient code. 
Instead, it presents easy to follow steps and incremental changes. 
If you are an experienced Python developer, this is not your time to shine. DORA will be checking for the solution we show in this module. 
    Several experienced Python developers have failed to get the badge because they knew "a better way" to do things. 
    If you don't care about getting the badge, feel free to get creative. If you want the badge, it's best to follow the example, warts and all. 
    Sorry, we don't want to punish creativity and efficiency, but we have to have a solution we can verify. 

if ingredients_list:
    ingredients_string = ''

    for fruit_chosen in ingredients_list:
        ingredients_string += fruit_chosen + ' '

    st.write(ingredients_string)

    my_insert_stmt = """ insert into smoothies.public.orders(ingredients)
                values ('""" + ingredients_string + """')"""
    
    st.write(my_insert_stmt)
    
*/

-- 🥋 Build a SQL Insert Statement & Test It
 /*
my_insert_stmt = """ insert into smoothies.public.orders(ingredients)
            values ('""" + ingredients_string + """')"""

st.write(my_insert_stmt)
*/

-- 🥋 Insert the Order into Snowflake
/*
if ingredients_string:
    session.sql(my_insert_stmt).collect()
    st.success('Your Smoothie is ordered!', icon="✅")

Test the form by starting an ingredients list from scratch. Use the x mark in the gray circle to wipe out all the chosen ingredients and start over.
After submitting a new order, check the Snowflake table to see if the order arrived in the table.
*/

select *
from smoothies.public.orders
;

-- 🥋 Truncate the Orders Table
truncate table smoothies.public.orders;

-- 🥋 Add a Submit Button
-- Make the second IF Block dependent not on the string having a value, but on the submit button being clicked by the customer. Once you have submitted an order, check the Snowflake table. 

select *
from smoothies.public.orders
;

-- 🎯 Submit a Few More Orders
/*
Keep submitting orders using your order form, until you have at least 5 DIFFERENT Order rows in your table.

In other words, don't just create one order and click the submit 5 times! Change the order contents each time. 
*/

-- Set your worksheet drop lists
-- DO NOT EDIT ANYTHING BELOW THIS LINE
use util_db.public;
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
SELECT 'DABW002' as step
 ,(select IFF(count(*)>=5,5,0)
    from (select ingredients from smoothies.public.orders
    group by ingredients)
 ) as actual
 ,  5 as expected
 ,'At least 5 different orders entered' as description
);