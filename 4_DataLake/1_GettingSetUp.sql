/*
🥋 Sign Up for a Snowflake Trial Account on AWS

You must use AWS US West (Oregon) because in the last lesson you will set up an Iceberg table.

If you'd like to use your current trial, check the requirements below to be certain your current trial will work. activate account

AGAIN, you must use AWS US West (Oregon) because in the last lesson you will set up an Iceberg table.

Iceberg tables require that our admin account and your learner account be in the same region and we have chosen AWS US West (Oregon) for the admin account.  Snowflake Accounts cannot be "moved" from one region to another (nor can the be moved to a different cloud provider). Therefore, if you use an account in any other region you will not be able to get the badge (unless you choose to start over from the beginning). 

If you need a new Snowflake Trial, please use this link: https://signup.snowflake.com/?utm_cta=website-learn-snowflake-university_dlkw

Questions about trial accounts or the process? See our FAQ page. 

🥋 Find the Email from Snowflake & Activate Your Account

If you need to activate a new trial account, do that now.

activate account

If you do not receive an email, see our FAQ page for instructions on how to proceed. 
*/

/*
🧰  Setting Up A New Trial Account
If you have a new trial (not the same one you used for Badge 1: DWW) you will need to do a few setup tasks :

Transfer ownership of the COMPUTE_WH warehouse to  SYSADMIN. 
Create a database named UTIL_DB that is owned by SYSADMIN. 
Create the DORA API Integration and DORA GRADER function. 
You will find copies of the two DORA setup scripts here. 

🤖 Is DORA Working? Run This to Find Out!
*/

use role accountadmin;

select util_db.public.grader(step, (actual = expected), actual, expected, description) as graded_results from
(SELECT 
 'DORA_IS_WORKING' as step
 ,(select 123 ) as actual
 ,123 as expected
 ,'Dora is working!' as description
); 

select current_account() as account_locator;
select current_organization_name()||'.'||current_account_name() as account_id;
