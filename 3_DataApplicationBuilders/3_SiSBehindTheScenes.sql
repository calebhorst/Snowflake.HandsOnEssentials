-- 🥋 The Internal Stage that Stores Your SiS App
-- You already know that creating your app resulted in the creation of an Internal Stage with a randomized name. Go now to your internal stage so we can explore it. 

-- 📓 How SiS Apps Run
/*
Remember that when we first set up the App, we chose a WAREHOUSE to associate with it.  There are some important things to know about how SiS apps use their assigned warehouse. If you need to check which compute resource you associated with your app, it is easy to check.

A warehouse will usually shut down within a few minutes of being idle (check the Auto-Suspend setting of the warehouse), but when a warehouse is associated with a SiS app, it runs for a minimum of 15 minutes by default. 

Keeping the webpage of the SiS app open, will keep the warehouse active and can end up draining your Trial Account credits. So, exit the SiS app page anytime you take a break from this workshop.  

Sometimes it's hard to remember to shut down the SiS App page, so let's set up a resource monitor to make sure we don't leave our app running 20 hours a day! If we run out of credits and want to keep working, we can always edit the resource monitor to allow more credits.
*/

-- 🎯 Set Up a Resource Monitor
use role accountadmin;
create resource monitor if not exists four_daily_credits 
with credit_quota = 4
frequency = daily
start_timestamp = immediately
triggers
    on 75 percent do notify
    on 85 percent do suspend
    on 95 percent do suspend_immediate
;


-- 🥋 Can I use Pandas? What about Numpy?
/*
If you are already familiar with Python, you may already be imagining all the different things you could build if you were able to import different Python libraries.

The good news is that many libraries are supported in Snowflake Snowpark!  You can refer to a list of them here:  https://repo.anaconda.com/pkgs/snowflake/

But, beware. Not all packages in the Anaconda channel for Snowpark can be used for SiS. Because of this, use the list as a starting point and then test the packages you want to use in your SiS app by typing in the import statement for the library you want to use. 

If you don't see an error message about the package you just imported, you can use that package. 
*/

-- Set your worksheet drop lists
use util_db.public;
-- DO NOT EDIT ANYTHING BELOW THIS LINE
select GRADER(step, (actual = expected), actual, expected, description) as graded_results from (
  SELECT 'DABW003' as step
 ,(select ascii(fruit_name) from smoothies.public.fruit_options
where fruit_name ilike 'z%') as actual
 , 90 as expected
 ,'A mystery check for the inquisitive' as description
);