/*
📓  What is a Variable?
Variables are used in computing to change values while the code is actually running. 

You can create variables in a Snowflake Worksheet and then use them in other commands, as long as the commands are run from the same worksheet. 

NOTE: A worksheet is considered a "session" in Snowflake.
*/

-- 🥋 Create & Set a Local SQL Variable
set mystery_bag = 'What is in here?';

-- 🥋 Run a Select that Displays the Variable
select $mystery_bag;

-- 🥋 Change the Value and Run the Select Again
set mystery_bag = 'This bag is empty!';
select $mystery_bag;

-- 🥋 Do More With More Variables
set var1 = 2;
set var2 = 5;
set var3 = 7;
select $var1 + $var2 + $var3;

/*
📓  What is a Function?
A function is a way to make your code more organized. If you plan to do a certain thing many times, you can put the code into a little module called a FUNCTION. 

To create a function you:

Give it a name.
Tell it what you will be sending to it (if anything).
Tell it what its job or operation is (the code that makes up the function)
Tell it what you want it to send back to you when it's finished (if anything). 
We'll create a simple function that adds three numbers together. Notice that we don't use the $ sign in these next few labs. 
*/
-- 🥋 Create a Simple User Defined Function (UDF)
-- NOTE: Put your function in your UTIL_DB database!
use role sysadmin;
use util_db.public;
create function if not exists sum_mystery_bag_vars (
    var1 number
    ,var2 number
    ,var3 number
)
returns number
as
$$
select var1 + var2 + var3
$$
;

-- 🥋 Run Your New Function
select util_db.public.sum_mystery_bag_vars(12,36,204); -- 252

/*
📓  Where Did the $$$'s Go?
We only need the dollar sign symbol when referring to a local variable. 
We don't use them when variables are used in a function, unless, you're using local variables and sending them to the function. 
Compare the code below to the code from the previous lab, above and make sure you understand the difference. 
*/

-- 🥋 Combine Local Variables & Function Calls
set eeny  = 4;
set meeny = 37.2;
set miney_mo = -39;
select util_db.public.sum_mystery_bag_vars($eeny, $meeny, $miney_mo); -- 2.2

/*
📓This, That & The Other!!
In the code below, we have three lines for creating some local variables. Fill in the values and run the statements, before you run the DORA Code Check. The variables MUST be set in the same session (worksheet) as the DORA Check and it is probably best to set them right before you attempt the DORA Check. 

The variable values should be set to: 
-10.5
2
1000
*/

-- Set your worksheet drop lists

-- Set these local variables according to the instructions
set this = -10.5;
set that = 2;
set the_other =  1000;

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW006' as step
 ,( select util_db.public.sum_mystery_bag_vars($this,$that,$the_other)) as actual
 , 991.5 as expected
 ,'Mystery Bag Function Output' as description
);

/*
📓  Snowflake Functions versus User-Defined Functions
Your Snowflake account comes with hundreds of functions already defined. When you define your own functions, you can use the system functions as part of the logic for your user-defined functions! 

You can learn about the various system functions by looking in docs.snowflake.com. 

In the next lab, we'll use a system function called INITCAP() to update a string. INITCAP() reformats any words by making the first letter (the initial letter) a capital letter, and all subsequent letters in the word, lower case. 
*/
-- 🥋 Using a System Function to Fix a Variable Value
set alternating_caps_phrase = 'sPoNgEbOb MeMe';
select $alternating_caps_phrase;

/*
📓  Alternating Caps - Neutralized!
People often write phrases in alternating caps to mock a statement being made in a whining or whinging tone. 

Can you create a function that removes the whining tone by converting a phrase from alternating caps to init caps? 

🎯 CHALLENGE LAB:  Write a UDF that Neutralizes Alternating Caps Phrases!
Your function should be in the UTIL_DB.PUBLIC schema. 
Your function should be named NEUTRALIZE_WHINING
Your function should accept a single variable of type TEXT. It won't matter what you name the variable.
Your function should return a TEXT value. 
The value returned should be in formatted so that the first letter of each word is capitalized and all other letters are lower case. (HINT: Use INITCAP() in your function code with your variable name inside)
Test your code and make sure it works, because on the next page, you'll need to prove it works!
*/

use role sysadmin;
create or replace function UTIL_DB.PUBLIC.NEUTRALIZE_WHINING (
    v_input TEXT
)
returns TEXT 
as
$$
select initcap(v_input)
$$
;

-- Set your worksheet drop lists
use UTIL_DB.PUBLIC;
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'DABW007' as step
 ,( select hash(neutralize_whining('bUt mOm i wAsHeD tHe dIsHes yEsTeRdAy'))) as actual
 , -4759027801154767056 as expected
 ,'WHINGE UDF Works' as description
);
