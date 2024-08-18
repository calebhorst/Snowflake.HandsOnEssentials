-- Compare COMPUTE CREDIT Costs for Several Cloud/Region Choices

-- Cost of a Credit, sure. But what do we do with that?
    -- Once we know the cost of a credit for a given cloud/region/edition we can use that to calculate monthly compute costs. The formula requires 3 pieces of information. 
    -- Let's use a $3.00 per credit cost for our calculations. 

-- Credits Per Hour
    -- Credits used per hour depend on the size of the warehouse. For that we can use this page again: https://www.snowflake.com/pricing/pricing-guide/

-- Hours (Per Month)
    -- The last part of the formula is the number of hours per month the warehouse will be used. If ACME only downloads the data coming from WDE once a week, they will use far less than one hour of compute. 
    -- In fact, since the extract is fairly simple, it is likely to take less than a minute to run. If the warehouse is configured to AUTO-SUSPEND after 4 minutes of inactivity, and there are 4 weeks in the month, ACME will use just 4 x 5 minutes (20 minutes) of compute per month. 

-- Cloud Services Costs
    -- Scroll down to the Cloud Services section of the https://www.snowflake.com/pricing/pricing-guide/ page. 

-- Serverless Costs
    -- Looking at the list of Serverless Features, it may jump out at you that we saw Snowflake running Replication services. Keep in mind that replication will happen on the PROVIDING account (WDE) and not on the CONSUMING account (ACME). Again, as long as ACME only extracts the shared data, Snowflake can be expected to cost her well below $5/mo.

/*
In Badge 1, Lesson 2 we learned about the roles set up in every Snowflake Trial Account. Then, we noted that in these Hands-On Workshops, we have you using the ACCOUNTADMIN role a lot.

In the real world, most people will have roles that are: 

Not able to create a Warehouse.
Not able to change the size of a Warehouse.
Not able to modify Resource Monitors.
Not be able to view, create, or modify Budgets. 
So, thanks to Role-Based Access Control, most corporate workers using Snowflake will not be able to change a warehouse to 6XL and turn off Auto-Suspend.

*/

-- Resource Monitor Challenge Lab!
/*
    Set up a similar resource monitor in the ACME account.
    Allow 5 credits of usage per WEEK at the Account level.
    Name your Resource Monitor Weekly_5.
    Use the 95/85/75 action settings we used in the other monitor.
*/

use role accountadmin;
create resource monitor if not exists Weekly_5 
with credit_quota = 5
frequency = weekly
start_timestamp = immediately
triggers
    on 75 percent do notify
    on 85 percent do suspend
    on 95 percent do suspend_immediate
;

-- Centralized View for Both Accounts
/*
In this workshop, you have set up the ACME account to be a "child" account in your Trial Account's Organization, so you can see ACME's usage from a central dashboard. 

In production usage, two completely different companies cannot see each other's usage. 

In this workshop, you are given a group of free credits. When you created the ACME account, you began using two accounts to hit against the same pool of free credits. 
*/

-- Budgets! New in June 2023
/*
- Budgets are a new Snowflake feature and they are not currently available in Trial Accounts. 
- Because they are not available in the account you're using for this workshop, we'll simply learn a few facts about them, so that you will know they exist.
- When Budgets are available you find them on the same page as the Usage graphs. The Budgets "Tab" won't work if you haven't yet activated Budgets for your account. 

- Once you have activated them, you can see projections of where your usage might be heading for the month. 

- Resource Monitors allow you to track and control Warehouse/Compute usage, but as Snowflake users become more sophisticated using many serverless tasks and advanced features, Budgets have been added so that users have similar tracking and control for other aspects of Snowflake. 

- To learn more about Budgets, you can read about them in the DOCs (https://docs.snowflake.com/en/user-guide/budgets#label-enable-budgets)
*/


-- set your worksheet drop lists to the location of your GRADER function
--DO NOT EDIT ANYTHING BELOW THIS LINE

--This DORA Check Requires that you RUN two Statements, one right after the other
use role accountadmin;
use util_db.public;

show shares in account;
--the above command puts information into memory that can be accessed using result_scan(last_query_id())
-- If you have to run this check more than once, always run the SHOW command immediately prior
select grader(step, (actual = expected), actual, expected, description) as graded_results from (
 SELECT 'CMCW08' as step
 ,( select IFF(count(*)>0,1,0) 
    from table(result_scan(last_query_id())) 
    where "kind" = 'OUTBOUND'
    and "database_name" = 'INTL_DB') as actual
 , 1 as expected
 ,'Outbound Share Created From INTL_DB' as description
); 