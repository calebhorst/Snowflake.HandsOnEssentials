# Snowflake.HandsOnEssentials
 learn.snowflake.com hands on essentials courses


# Helpful link for DORA validation checks and Badge Issuance
https://ysa.snowflakeuniversity.com/


select current_account() as account_locator;
select current_organization_name()||'.'||current_account_name() as account_id;