# Snowflake.HandsOnEssentials
`learn.snowflake.com` hands on essentials courses
1. Badge 1: Data Warehousing Workshop
    - https://learn.snowflake.com/en/courses/uni-essdww101/
2. Badge 2: Collaboration, Marketplace & Cost Estimation Workshop
    - https://learn.snowflake.com/en/courses/uni-ess-cmcw/
3. Badge 3: Data Application Builders Workshop
    - https://learn.snowflake.com/en/courses/uni-ess-dabw/
4. Badge 4: Data Lake Workshop
    - https://learn.snowflake.com/en/courses/uni-ess-dlkw/
5. Badge 5: Data Engineering Workshop
    - https://learn.snowflake.com/en/courses/uni-ess-dngw/


# Helpful link for DORA validation checks and Badge Issuance
https://ysa.snowflakeuniversity.com/

# sqlfluff linting
Set to `snowflake` dialect

1. Setup a python environment with required packages (pip install -r requriements.txt)
2. Execute the python file sqlfluff_linter.py to lint and attempt fix each .sql file in the repo (py sqlfluff_linter.py)
    a. Note this could be setup to only lint changed files for a larger repo
3. Commit your changes with standards enforced!