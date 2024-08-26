-- 📓  Stakeholders, Customers, Requirements & Prototypes
/*
First, "STAKEHOLDERS" - Mel, Melanie and Igor are all Stakeholders in this project because their jobs are affected by how the app turns out. 

For Mel (the Developer), his mom Melanie is his "CUSTOMER" because it is her "REQUIREMENTS" he has to meet. 

When Melanie says, "I like that font!" or "Can you change the color of the background," she, as the Customer, is expressing "CUSTOMER REQUIREMENTS." 

Since Mel and Melanie have a strong relationship, he can trust her not to keep changing her mind and claiming she didn't. Because of their relationship their requirements don't require official documentation. But, if Mel were working for someone else, he might want to keep a record of every decision using email or some other written document. 

A "PROTOTYPE" is a semi-working version of something that helps STAKEHOLDERS discuss project REQUIREMENTS. In the 1980s and 1990s, teams used to spend months writing up an official Requirements Document and only when all stakeholders had "signed off" was the document passed to the developers. This was called a "Waterfall Method" -- you can research SDLC Waterfall Method and read more about it if you are curious. SDLC stands for Systems Development Life Cycle and just means "process or method for developing software."

Then, Rapid Prototyping (RAD, Agile, and others) became more popular. Mel doesn't realize it, but he's using an ITERATIVE SDLC, and it's based on RAPID PROTOTYPING.
*/

--🎭 Mel Sprints While Melanie Runs
/*
Using a rapid prototyping approach, Mel just builds whatever he can in a week and then on Saturdays, when Melanie is using her treadmill for her morning run, he gets her feedback.

So that's what he's doing now; He's presenting his version 1 prototype and getting her opinions on what is good, what needs to be changed, what needs to be added, and what things they forgot to consider. 

Today they came up with 4 To-Do items (often called "Action Items"). Two action items are fairly easy. Mel thinks he can add a name to each order pretty easily. He also has an idea for communicating orders to the kitchen. The other two are more difficult. He doesn't know how to check for more than 5 fruits and reject orders that have 6 or more fruits listed. Also, he doesn't have any idea how to check for fruits in stock before allowing smoothies to be ordered. 

Mel commits to delivering two things on their list in the coming week. He commits to researching the third item. The fourth item is "tabled" until they have some simpler issues resolved. Many times a customer will "gold plate" requirements when they are expressing how they want an app to look or behave. A good developer or requirements analyst will be able to track the different requirements according to whether they are "must haves" or "nice to haves." 

The inventory thing is very likely a "nice to have" not a "must have."
*/

-- 📓 Mel Plans Week #2 (Sprint #2)
/*
Since Mel meets with his mom about his prototype once every week, he plans his work one week at a time.

The short timeframes for planning are often called "Sprints." In old waterfall development projects, teams would set a date months or years in the future as a deadline, and then work backward setting "Milestone" dates for when each phase of the project HAD to be finished.

In Rapid Prototyping, the idea is that instead of setting dates far in the future, you do as much as you can in the time you are given, and then you show your customer what you have so far, and get their input on what should be done next. This gives the customer more chances to change their mind without delaying the project or causing a lot of extra costs.

When managed well, everyone is happier with the outcomes. Higher-level management may continue to have ideas about some big dates in the far future or the total amount they are willing to spend, but coders are only expected to estimate, commit and deliver a few weeks in advance.

Since Mel has already decided to finish two items on his list and research a third, he has a rough idea of what his week looks like. Now he just needs to break down his tasks into more precise steps.
*/

-- 🥋 Move Your Import COL Function Statement to Top of Code
-- Most coders keep all import statements at the top of the code so let's move the import statement for the COL function up below the other import statements. 

-- 🥋 Add a Name Box for Smoothie Orders
-- STREAMLIT DOCUMENTATION: https://docs.streamlit.io/library/api-reference/widgets/st.text_input
-- NOTE: While testing your new text_input, don't use labels with apostrophes like "Gina's Smoothie" -- Mel is building a prototype and doesn't have to account for every possible entry at this point so he hasn't dealt with apostrophes.
/*
name_on_order = st.text_input('Name on Smoothie:')
st.write('The name on your Smoothie will be:', name_on_order)
*/

-- 🥋 Use the ALTER Command to Add a New Column to Your Orders Table
ALTER TABLE smoothies.public.orders ADD COLUMN name_on_order VARCHAR(100)
;

SELECT *
FROM smoothies.public.orders
;

-- 🥋 Writing the NAME_ON_ORDER Entry to the Snowflake Table
/*
    my_insert_stmt = """ insert into smoothies.public.orders(ingredients, name_on_order)
                values ('""" + ingredients_string + """','""" + name_on_order + """')"""
*/
SELECT *
FROM smoothies.public.orders
WHERE name_on_order IS NOT NULL
;


-- 🎯 Build a New SiS App! 
/*
Mel has decided he's just going make a second app that can be used by the kitchen staff to see open orders and then mark them complete when they've been filled and given to the customer.  We think you can do this on your own!! You can either create a whole new app or you can duplicate your existing app and edit it. Call your new app Pending Smoothie Orders.

If you decide to duplicate the app, it will automatically be in the SMOOTHIES database and PUBLIC schema. If you create it new, make sure it is in the SMOOTHIES database and PUBLIC schema.

TIPS:
Most of the changes will just be you deleting things we don't need for our first version of this app.  After the lines that begin with "session" and "my_dataframe =" everything else can be deleted. 
You will need to add a column named ORDER_FILLED to the ORDERS table, so that an order can be marked "complete" or "filled." When you add the new column to the ORDERS table, the type should be BOOLEAN and right after the word BOOLEAN you should type DEFAULT FALSE. This will make sure that new orders are marked as "not yet filled". Note that BOOLEANS are sometimes displayed as TRUE/FALSE, sometimes as 1/0, and sometimes as a checkbox that is checked/not checked. 
You may want to mark some rows as "filled" before trying to get the app working. It will help to have some TRUE and some FALSE orders for testing. We ran the code below in a Snowflake worksheet to update all the orders we created before we started adding the NAME_ON_ORDER: 
       update smoothies.public.orders
       set order_filled = true
       where name_on_order is null;
In addition to using the COL function to select a single column from a table or a dataframe, you can use the FILTER() function and only include orders where ORDER_FILLED = FALSE.  
    my_dataframe = session.table("smoothies.public.orders").filter(col("ORDER_FILLED")==0).collect()
If you get stuck, don't worry, you will be able to see the code we used on upcoming pages -- but try not to jump ahead! Pushing yourself to figure things out will help you learn more, and retain what you learn. You can stop when your new app looks like the image below. 


NOTE: This is a challenge lab and it is supposed to be challenging. Notice we don't give you complete instructions. We want you to bridge gaps and apply prior learning. We want you to be proud of what you are able to piece together on your own. We have carefully designed this challenge to give you just enough information that you can be successful, but you will also have to show some initiative. 
*/

ALTER TABLE smoothies.public.orders ADD COLUMN order_filled BOOLEAN DEFAULT FALSE;

SELECT *
FROM smoothies.public.orders
;

UPDATE smoothies.public.orders
SET order_filled = TRUE
WHERE name_on_order IS NULL
;

-- Set your worksheet drop lists
USE util_db.public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE
SELECT GRADER(step, (actual = expected), actual, expected, description) AS graded_results FROM (
  SELECT
    'DABW004' AS step,
    (
      SELECT COUNT(*) FROM smoothies.information_schema.columns
      WHERE table_schema = 'PUBLIC' 
        AND table_name = 'ORDERS'
        AND column_name = 'ORDER_FILLED'
        AND column_default = 'FALSE'
        AND data_type = 'BOOLEAN'
    ) AS actual,
    1 AS expected,
    'Order Filled is Boolean' AS description
);