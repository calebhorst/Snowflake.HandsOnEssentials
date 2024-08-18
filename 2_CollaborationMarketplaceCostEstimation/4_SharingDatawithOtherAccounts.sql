-- Set Up an Account for ACME
    -- In the real world, ACME would set up their own account or just enter billing details for their existing trial, but this is a good opportunity for you to see how easy it is to create accounts using the ORGADMIN role. So that's what you're going to do next. 

-- Create an Azure Snowflake Account for ACME
Account Name: ACME
User Name: ACME_ADMIN
Password: Temp123456
Email: use personal email address

-- Account details
Account Name ACME
Account URL https://yedtcqv-acme.snowflakecomputing.com
Account Locator JO55124
Account Locator URL https://jo55124.central-us.azure.snowflakecomputing.com
Edition Standard
Cloud Microsoft Azure
Region Central US (Iowa)
-- Admin login
Admin User Name
ACME_ADMIN

-- Sign In to the ACME Account and Update Your Password


--CHALLENGE LAB: Set Up the ACME Account
/*
1. Create a warehouse called ACME_WH, make it size XS. 
2. Update the USER profile by setting the image, name, default ROLE and default WAREHOUSE. 

The warehouse should be owned by the SYSADMIN ROLE. 
The default ROLE should be SYSADMIN. 
The Profile Image and name should look like the image above. 
*/
use role sysadmin;

create warehouse if not exists acme_wh
warehouse_size = 'XSMALL'
;

alter user acme_admin 
set default_warehouse = 'acme_wh';

alter user acme_admin 
set default_role = 'sysadmin';

-- Martín Sets Up World Data Emporium as a Listing Provider

-- Martín Creates a Listing
    -- NOTE: Before creating the share, make sure all objects in your INTL_DB are owned by SYSADMIN. 
    -- Once you add an object to a share it becomes harder to transfer ownership. In that case, you have to remove the object from the share it, transfer ownership on the object, and then add it back to the share. So do yourself a favor and take care of it before creating the share.

-- Done within the web UI

-- "Get" the WDE Listing
    -- Remember when you had to "get" the sample data share back after dropping it? You'll repeat a similar set of steps to add the WDE listing to your ACME account.
    -- Pretend to be Caden, in the ACME account, looking for a listing sent to you by Martín. 

-- Done within the web UI

-- Add a Data Dictionary to the COUNTRY_CODE_TO_CURRENCY_CODE Table.
Descriptions you can add to the data dictionary:
-------------------------------------------------------------------------------------------------------------
Column	              |  Description
-------------------------------------------------------------------------------------------------------------
COUNTRY_CHAR_CODE	  |  Three-letter country code, like USA for the United States, or HKG for Hong Kong.
COUNTRY_NAME	      | Full name of country, like LAO PEOPLE’S DEMOCRATIC REPUBLIC (THE).
COUNTRY_NUMERIC_CODE  |  A number given to each country. Not unique.
CURRENCY_CHAR_CODE	  |  Three-letter currency code, like JPY for the Japanese Yen, or EUR for the Euro. 
CURRENCY_NAME	      |  Full name of the currency, like Mozambique Metical or Norwegian Krone.
CURRENCY_NUMERIC_CODE |  A number given to each currency. Not unique.
-------------------------------------------------------------------------------------------------------------

-- Done within the web UI

-- Add A Sample Query
-------------------------------------------------------------------------------------------------------------
Field	     |   Description
-------------------------------------------------------------------------------------------------------------
Title	     |   Show the Simple Country Code to Currency Code Mapping 
Description	 |   Based on the billing address of a customer, look up which currency applies to the order. 
Query	     |   select * from public.country_code_to_currency_code;
-------------------------------------------------------------------------------------------------------------

-- View the Listing in the ACME Account
-- Now that the listing has had some time to replicate, and improvements have been made, we'll again pretend to be Caden, using the ACME account and go view the listing. 

-- Get the Listing for the ACME Account
    -- If the listing now shows a blue Get button, go ahead and "get" the listing. If you need to change roles to get it, change roles. 
    -- Be sure to grant privileges to SYSADMIN. 

use role accountadmin;
GRANT USAGE ON SHARE GZTYZ23RRD TO ROLE SYSADMIN;

SHOW LISTINGS;
show shares;

select * from public.country_code_to_currency_code;

-- Swap to using the World Data Emporium account
-- Convert "Regular" Views to Secure Views
alter view intl_db.public.NATIONS_SAMPLE_PLUS_ISO
set secure; 

alter view intl_db.public.SIMPLE_CURRENCY
set secure; 

-- Add the Newly Secure Views to Your Outbound Share
-- Web UI


Exploring Usage Types
The menu that starts out saying [All Usage Types] can cause other menu options to appear after it depending on which Usage Type you select. Choose the Data Transfer option and then notice that there are 3 colors that represent 3 different transfer types. Purple represents the running of External Functions. The DORA GRADER is an External Function and so is the GREETING Function. So, the purple bar represents the amount of data you have transfered. 

45kB is a small amount of data -- less than one page of text in a Google Sheets document. 

-- View the ACCOUNTS View Data
select *
from snowflake.organization_usage.accounts
;