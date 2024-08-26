-- Transfer Ownership of Your Database to the SYSADMIN Role
GRANT OWNERSHIP ON DATABASE demo_db TO ROLE sysadmin;

-- Switch Your System Role Back to SYSADMIN
USE ROLE sysadmin;

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

 -- Learning About Snowflake System Roles

/*
Use the Roles diagram to explore the roles that have been assigned to you. Notice that in the diagram, some roles are linked to others in what looks like an org chart or family tree. This is because some roles get subsets of rights from other roles.

-- ROLE CREATION AS INHERITANCE
When Thierry and Benoit were first setting up Snowflake ROLES in Benoit's apartment  they created the all-powerful ACCOUNTADMIN. Then, like a parent, giving some DNA to one child and some DNA to another, they set up system ROLES like SECURITYADMIN and SYSADMIN.

In this way, when ROLES are first designed, there is the idea of setting up different "children" to inherit from "parents" just as you might dole out DNA, or assets in a Last Will and Testament.
*/

/*
-- BOGO Roles for New Users!
As a new Snowflake Trial Account USER, you are given the ACCOUNTADMIN ROLE  by the Trial provisioning process.

And again, because of the way those ROLES were originally designed (a long time ago by Thierry and Benoit), you automatically get the roles that are below ACCOUNTADMIN in that chart. This is also often referred to as "role inheritance," but we don't think the inheritance metaphor is helpful here. We think the metaphor of inheritance works great during role creation but not as well during role assignment. We think using that term during role assignment leads to some critical misunderstandings.

See, with DNA or property inheritance, things often move from an older and more powerful person and end up in the hands of someone younger and less powerful. So there is a downward flow implied by the word inheritance.

With these automatically-awarded Snowflake roles, their use feels more like Buy One Get One Free promotion (BOGO!) at a fast food place!

Giving SYSADMIN as a free perk to an all-powerful ACCOUNTADMIN feels more like a free bag of chips with the purchase of a sandwich. So, instead of the "role inheritance" we think it's amusing to refer to the lower roles as BOGO roles. Because technically, you aren't giving ACCOUNTADMIN anything, other than the chance to pretend they have less power than they actually do. That doesn't feel like inheritance.

BECAUSE OF BOGO, HIGHER ROLES CAN IMPERSONATE LOWER ROLES

Once we have those BOGO ROLES in our drop-list of ROLE options, the action of switching to a lower role could be thought of as "impersonation." And we can say that a higher role can impersonate a lower role anytime they want. In your Trial Account, you can impersonate a SYSADMIN by setting your role to SYSADMIN.  This impersonation power only flows downward in the chart or tree. If you had been awarded SYSADMIN directly, you would not be able to impersonate ACCOUNTADMIN.
*/

/*
-- Discretionary Access Control (DAC)
Beyond RBAC, there is another facet of Snowflake's access model called Discretionary Access Control (DAC), which means "you create it, you own it." If SYSADMIN creates a database, they own it and so they can delete it, change the name, and more.

We see DAC models when we create an MS Word Doc, an email or a Google Sheets document. We created it, so we own it. We created it, so we can delete it! We created it, so we can rename it!

Because of the combination of RBAC and DAC in Snowflake, when we create something, the ROLE we were using at the time we created it, is the role that OWNS it.
*/

/*
-- Higher Roles Have Custodial Oversight
Imagine your child was given a t-shirt at their school as a free promotion, and when they arrived home, you took the t-shirt from them and threw it in the trash. That sounds like a crazy parenting choice, and one that might make your kid cry, but hear us out. The child says, "But that was my t-shirt!" and you say, "As your parent, anything you own, is actually owned by me until you are 18 years old!!"

In that sense, it could be said that any possession of a child is legally "inherited" by the parent. But again, "inherit" doesn't seem like the best metaphor here.

As parents, we definitely have the right to enter our children's bedrooms and look around. We can rearrange things, put locks on the doors, remove items, paint the walls, and more. Legally, these are sometimes called "custodial rights" and our decisions can fall under "custodial oversight."

Think of ACCOUNTADMIN as a sort of "parent" of SYSADMIN, with "custodial rights." SYSADMIN can create a database and by creating it, they are the OWNER of that database. But because SYSADMIN is a "child" of ACCOUNTADMIN, ACCOUNTADMIN can take the database away from SYSADMIN and give it to a SECURITYADMIN if they want to.

ACCOUNTADMIN can also delete something owned by SYSADMIN, rename it, or carry out any other task on anything created or owned by SYSADMIN. SYSADMIN cannot do the same things to items owned by ACCOUNTADMIN.
*/

/*
-- Default Role Assignment
Totally unrelated to any other rules of ROLE design, hierarchy, inheritance, BOGO, or custodial oversight, there is the concept of a DEFAULT ROLE. This is a USER setting that is designed for convenience. Each USER has a role assigned as their default. The default role that has been assigned to you as a Trial Account User is the ACCOUNTADMIN role. This just means that each time you log in to Snowflake, your role will be set to ACCOUNTADMIN. You can change your default role to something different but we don't recommend you do that for your trial account because we have written the workshop labs with the presumption that you will use ACCOUNTADMIN for most tasks.
*/

/*
-- Role Hierarchy Rules Review
If two ROLES are linked by a blue line:

The higher role can be DIRECTLY given to a USER and the USER will automatically (BOGO!) be awarded all the lower roles in the same org chart or family tree.
If a USER has a higher role, they will be able to impersonate all lower ROLES in the same linked tree, without being explicitly given those ROLES.
The higher role has custodial oversight of all objects OWNED by a linked, lower role.
Each USER has a default role they are assigned. This is the ROLE they are set to each time they log in. It doesn't do much more than that, so it is convenience, only and does not affect the current role a user is using.
*/

-- Give SYSADMIN "Access" to the PUBLIC Schema
USE ROLE accountadmin;
GRANT OWNERSHIP ON SCHEMA demo_db.public TO ROLE sysadmin;

USE ROLE sysadmin;
SHOW SCHEMAS;

-- Create a New Database Called UTIL_DB
USE ROLE sysadmin;
CREATE DATABASE IF NOT EXISTS util_db;

-- How Does Changing Your Role Affect What Databases You Can See?
/*
1. View the list of Databases.
2. Change your role.
3. Notice that for some roles, not all 4 databases are visible.

NOTE: Many times when using Snowflake, something might seem to disappear. You may see a "Does Not Exist error" when you know that the item in question has been created. In those instances, you should begin by checking your role!!
*/

-- How Does Changing Your Role Affect What Warehouses You Can See? 
/*
1. Start with your role set to ACCOUNTADMIN.
2. Navigate to the Warehouses page.
3. View a warehouse added to your trial for you.
4. Change ROLE other roles, notice that the warehouses listed changes.
*/

-- CHALLENGE LAB: Make the Warehouse Available to SYSADMIN 
-- Give the SYSADMIN role access to the COMPUTE_WH. 
USE ROLE accountadmin;
GRANT OWNERSHIP ON WAREHOUSE compute_wh TO ROLE sysadmin REVOKE CURRENT GRANTS;

USE ROLE sysadmin;
SHOW WAREHOUSES;


