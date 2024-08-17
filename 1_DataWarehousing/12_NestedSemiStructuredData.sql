-- Transfer Ownership of Your Database to the SYSADMIN Role
grant ownership on database demo_db to role sysadmin;

-- Switch Your System Role Back to SYSADMIN
use role sysadmin;

/*
-- Recent Role Changes
NEW ORGADMIN ROLE
Snowflake has added an additional role to the predefined set. This new role is named ORGADMIN. The ORGADMIN is a very, very powerful role that can tie multiple Snowflake accounts together and even generate accounts. We will not learn much about this role in the course because very few people use this role, and those who do use it, don't use it very often.

DEFAULT ROLE
In the past, the default role for Trial Accounts was SYSADMIN.

However, the default role for Trial Accounts has been changed to ACCOUNTADMIN. This means you will be using ACCOUNTADMIN for most things you do within your trial account and within this and other workshops.

In some ways this is good because you will not have to think about role as often, and you will be able to focus on learning about Snowflake data objects. In other ways, it's not great, since if you are using Snowflake for your job, you will almost never use ACCOUNTADMIN.

We will ask you to use your SYSADMIN role for a few tasks so you are familiar with switching between roles, since this is an important skill. 
 */

 