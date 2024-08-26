/*
🥋 Sign Up for a Snowflake Trial Account on AWS

Or continue using a Trial Account used for a previous workshop. Check the requirements below to be certain your current Trial will work. 

EDITION: Any. 

CLOUD PROVIDER: AWS 

REGION: Any (except Jakarta or Zurich) 

If you need a new Snowflake Trial, please use this link: https://signup.snowflake.com/?utm_cta=website-learn-snowflake-university_dngw

Questions about trial accounts or the process? See our FAQ page. 

❕ Setting Up Your Trial Account
Check to see if you have a warehouse named COMPUTE_WH that is sized XS and will auto-suspend. If you don't have one, create it. 
Check to see if you have a database named UTIL_DB and if you don't have one, consider creating one that can serve as the home to your DORA GRADER function. 
Make sure the SYSADMIN role owns the COMPUTE_WH, the UTIL_DB database, and the PUBLIC schema of the UTIL_DB database. 
🎯 Setting Some Defaults
You may want to set some DEFAULT values for your USER. 

These make using Snowflake more convenient by setting your worksheet context for you automatically.

Kishore's USERNAME in his Snowflake Account is KISHOREK (it's what he uses to login to Snowflake).

He runs the following commands:
alter user KISHOREK set default_role = 'SYSADMIN';
alter user KISHOREK set default_warehouse = 'COMPUTE_WH';
alter user KISHOREK set default_namespace = 'UTIL_DB.PUBLIC';

🧰 Run the Two Dora Setup Scripts
Before setting up DORA, you may need to create a UTIL_DB database. Set your role to SYSADMIN before creating it.  When that's been created, you can proceed to setting up the grader.

You will find copies of the two setup scripts here. There are two videos available on that page - the second one is in the troubleshooting section. If you have trouble with setting up DORA or using DORA, watch the troubleshooting video. 

🤖 Is DORA Working? Run This to Find Out!
*/
USE ROLE accountadmin;

SELECT util_db.public.grader(step, (actual = expected), actual, expected, description) AS graded_results FROM
  (
    SELECT 
      'DORA_IS_WORKING' AS step,
      (SELECT 123 ) AS actual,
      123 AS expected,
      'Dora is working!' AS description
  ); 

/*
🧰 Tell Us About Your Snowflake Trial Account
DORA Listening

When you were getting Badge 1: DWW, you used the app to update your name, email and display name. You also created a LINK ROW to tell DORA what Snowflake Trial Account you were using to complete the DWW labs.  

When you were getting Badge 2: CMCW, Badge 3: DABW, and Badge 4: DLKW you created new link rows even if you were using the same Snowflake Trial. 

For this workshop, start by creating a new DNGW link row. When you create a LINK ROW you are telling DORA what Snowflake Trial you are using to complete your DNGW lab work. This needs to be done even if you are still using the same Snowflake Trial Account.  

Once you've completed your LINK row, proceed with the course, but remember, you can come back to the app to see your DORA tests and make sure they are coming through PASSED and VALID as often as you'd like.
*/