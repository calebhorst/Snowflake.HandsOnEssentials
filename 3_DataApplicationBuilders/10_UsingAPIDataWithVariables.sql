/*
📓 Adding the Requests Python Library to our SniS Project
To add any package to a SniS app, you need two steps:

1) Add the library to the requirements.txt file so that Streamlit knows to install it when starting up the project. 
2) Add the import statement to the body of the streamlit_app.py file so it is ready to be used in the code. 
Keep these rules in mind also. 

Anytime you change the streamlit_app.py file, and commit the changes in GitHub, the app will automatically start using the changes.
However, anytime you make changes to the requirements.txt file, you will need to reboot the app. 

🥋 Let's Call the Fruityvice API from Our SniS App!
We need to bring in a Python package library called requests.  The requests library allows us to build and sent REST API calls.  Paste the code below into the bottom of your SniS app. 

import requests
fruityvice_response = requests.get("https://fruityvice.com/api/fruit/watermelon")
st.text(fruityvice_response)

Response 200 from an API just means it was successful. Our problem here is in the format of the response. We just need to convert the response so we can read the response object's contents. 

🥋 Let's Expose the JSON Data Inside the Response Object
import requests
fruityvice_response = requests.get("https://fruityvice.com/api/fruit/watermelon")
st.text(fruityvice_response.json())

🥋 Let's Put the JSON into a Dataframe
import requests
fruityvice_response = requests.get("https://fruityvice.com/api/fruit/watermelon")
# st.text(fruityvice_response.json())
fv_df = st.dataframe(data=fruityvice_response.json(), use_container_width=True)


People often use df as shorthand for "dataframe." We'll call our dataframe fv_df, because it's our Fruityvice Dataframe. 
*/

/*
🥋 Let's Get the Fruityvice Data to Show Data for the Fruits Chosen
To do this, we need to rearrange our code lines. 

# Process ingredients selection
if ingredients_list:
    ingredients_string = ' '.join(ingredients_list)  # Join selected ingredients into a single string
    for fruit_chosen in ingredients_list:
        try:
            # Make API request to get details about each fruit
            fruityvice_response = requests.get("https://fruityvice.com/api/fruit/" + fruit_chosen)
            fruityvice_response.raise_for_status()  # Raise an error for bad responses (4xx or 5xx)
            
            if fruityvice_response.status_code == 200:
                fv_df = st.dataframe(data=fruityvice_response.json(), use_container_width=True)
            else:
                st.warning(f"Failed to fetch details for {fruit_chosen}")
        
        except requests.exceptions.RequestException as e:
            st.error(f"Failed to fetch details for {fruit_chosen}: {str(e)}")
*/

/*
📓 Not Every Fruit Will be Found
Some of the more exotic fruits are not in the Fruityvice database. Others are in there, but are not found in the search. 

"Strawberries" won't return data, but "Strawberry" will. This is a minor issue. Melanie wants her list to say "Strawberries" but Fruityvice is not something Mel has control over. 

It is not uncommon that what we want to appear on the GUI is different than the search term we are forced to use behind the scenes. Often, a multiselect or other user entry will be a name, while what is stored or searched on is a number or unique id.

One option would be to change the values in the FRUIT_OPTIONS table to match the values in Fruityvice. However, that would require the developer going back to customer (Mel going to Melanie) and asking for a change to the requirements. If Mel can figure out a way to fix things without going back to his customer, he might be able to save time and effort. If he were working in a corporate setting, he might need to clear his solution with his team lead or manager. 

In this case, Mel has just decided to add a column to the FRUIT_OPTIONS table called SEARCH_ON and he'll attempt to resolve as many issues as possible with this column. When he can no longer resolve look-up issues this way, he'll go back to Melanie to explain what fruits still can't present data. 
*/

/*
🎯 Let's Add the SEARCH_ON Field to Our FRUIT_OPTIONS Table
This is a challenge lab. That doesn't mean it's optional, it means you have to apply things you learned in earlier labs or workshops and figure you how to meet the challenge. 

You know how to use ALTER TABLE...ADD COLUMN command, so add a column to the FRUIT_OPTIONS table. (If you need help, review earlier labs or look it up in the Docs). 

Add the column SEARCH_ON, which will be what we use in the API call, instead of the fruit label seen in the GUI. 
For any fruit already that already returns results, you can just copy the value into the new field. So for "Kiwi" the SEARCH_ON column will also say "Kiwi." 
TIPS AND TRICKS: back and forth part b

back and forth part b
For example, Jack fruit is in there, it's just written differently. Can you figure out what to put in the SEARCH_ON column for that row? Remember there is an /all call that will show you every fruit in the database.  

You don't have to do all the rows, but at least do Apples, Blueberries, Jack Fruit, Raspberries and Strawberries. 
*/
use role sysadmin;
select * 
from smoothies.public.fruit_options;

alter table smoothies.public.fruit_options add column search_on varchar(100);

-- Apples, Blueberries, Jack Fruit, Raspberries and Strawberries. 
update smoothies.public.fruit_options
set search_on = 'Apples'
where fruit_name = 'Apples'
;
update smoothies.public.fruit_options
set search_on = 'Blueberry'
where fruit_name = 'Blueberries'
;
update smoothies.public.fruit_options
set search_on = 'Jackfruit'
where fruit_name = 'Jack Fruit'
;
update smoothies.public.fruit_options
set search_on = 'Raspberry'
where fruit_name = 'Raspberries'
;
update smoothies.public.fruit_options
set search_on = 'Strawberry'
where fruit_name = 'Strawberries'
;

select * 
from smoothies.public.fruit_options
where search_on is not null
;

/*
🥋 Add the New SEARCH_ON Column to the Dataframe that feeds the Multiselect

🎯 Bring In Pandas 
When we bring in a new Python library we need to add it to the requirements file, put in an import statement and reboot the app. Please do those things now. 

When you bring in Pandas to the Py file, call it pd in the same way we shorten streamlit to st. This is common in the Python coding world and it makes pandas easier to refer to. 

🥋 Make a Version of my_dataframe, but call it pd_df


🥋 A Strange-Looking Statement That Will Get Us the "Search On" Value

search_on=pd_df.loc[pd_df['FRUIT_NAME'] == fruit_chosen, 'SEARCH_ON'].iloc[0]
st.write('The search value for ', fruit_chosen,' is ', search_on, '.')

You can read more about loc and iloc functions here: https://pandas.pydata.org/docs/reference/api/pandas.DataFrame.loc.html

🎯 Preparing Records for Your Final DORA Check
As you may have noticed, it is easier for us to use DORA to check the data behind the apps than the apps themselves. An intermediate-level database developer could fake the entire workshop and do nothing with Streamlit. We get that, we just don't understand why anyone would (Streamlit is FUN!). Still, there will be those that do it anyway and when we catch them we always feel sad for them.

For our last lab we'll be checking for a variety of orders. If you have followed along and built your apps to spec, creating these orders using your app will take fewer than 3 minutes. Please create the orders we describe below in make sure the fruits are in the order we describe them:

Create an order for a person named Kevin and use the fruits Apples, Lime and Ximenia (in that order). DO NOT mark the order as filled. 
Create an order for a person named Divya and use the fruits Dragon Fruit, Guava, Figs, Jackfruit and Blueberries (in that order!). Mark the order as FILLED.  
Create an order for a person named Xi and use the fruits Vanilla Fruit and Nectarine (in that order). Mark the order as FILLED. 
If you mess this up you can truncate the table and start over. You only need these 3 records to finish the workshop (presuming you passed all prior checks). 
*/

-- Set your worksheet drop lists
USE UTIL_DB.PUBLIC;

select *
from smoothies.public.orders
order by order_ts desc
;

-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
   SELECT 'DABW008' as step 
   ,( select sum(hash_ing) from
      (select hash(ingredients) as hash_ing
       from smoothies.public.orders
       where order_ts is not null 
       and name_on_order is not null 
       and (name_on_order = 'Kevin' and order_filled = FALSE and hash_ing = 7976616299844859825) 
       or (name_on_order ='Divya' and order_filled = TRUE and hash_ing = -6112358379204300652)
       or (name_on_order ='Xi' and order_filled = TRUE and hash_ing = 1016924841131818535))
     ) as actual 
   , 2881182761772377708 as expected 
   ,'Followed challenge lab directions' as description
); 

select current_account() as account_locator;
select current_organization_name()||'.'||current_account_name() as account_id;