/*
📓  Time Zones Around the World
Data comes into many data-driven organizations from all over the world. Because of this, understanding how time zones work is a critical skill for a Data Engineer.

Just as the Prime Meridian (Zero Longitude) flows through Greenwich, England, United Kingdom, the time in that region has historically been used as THE starting point for other time zones. 

Many times you will see a time or time zone listed using a code like GMT+3 or GMT-4. The first example, GMT+3 could be read as, "Whatever time it is in Greenwich, England, plus 3 hours." The second example, GMT-4 could be read as, "Whatever time it is in Greenwich, England, minus 4 hours."

But people who live in Ghana, the Gambia or Greenland might not like referring to their home time zone by comparing it to Greenwich, England. This is one of several reasons UTC was created. UTC is a less UK-centric way of talking about time even though GMT+0 and UTC+0 result in the same timestamps.  

UTC stands for Universal Time, Coordinated (or Universal Coordinated Time, if you prefer).

The same time zone as GMT+0/UTC+0 is sometimes also called Zulu Time. This is based on military parlance where the letter Z is referred to as "Zulu." The Zulu people of KwaZulu-Natal actually happen to be in UTC+2.

You can read more about the nuances between these three standards but for this course, we will be talking about and using the UTC standard. 

timezones

The image above is from timeanddate.com. The Time and Date website has an interactive version of the image above that you can use to explore time zones. 

You'll need to know a few more initialisms for this lesson. NTZ means "No Time Zone." LTZ means "Local Time Zone." 

📓 UTC Timestamp Storage Parts/Format
format

YYYY means the 4-digit Year. 
MM means the 2-digit Month. 
DD means the 2-digit Day. 
HH is for the hour, usually on a 24 hour clock. 
MI is for the 2-digit Minutes past the hour. 
SS.SSS stands for 2-digit Seconds and 3-digit Milliseconds. 
+/- tells you the DIRECTION of OFFSET from UTC+0
HH:MI shows the offset hour and minute amount that the time represents from UTC. 

📓  Kishore & Agnie's LTZ
Kishore and Agnieszka live in Denver, Colorado, USA. So what is their LTZ, expressed in UTC? 

timezones

Kishore runs the command SELECT current_timestamp(); in a worksheet (in October) and sees -0600 as part of the results.

-0600 is the same thing as UTC-6.

This means Kishore's Snowflake session is currently using the Denver time zone. 

What time zone is your Snowflake Trial Account using?  Run the current_timestamp() command to find out. Our guess is that you'll see either UTC-7 (-0700) or UTC-8 (-0800) depending on the time of year it is (daylight savings time).

We can guess this because all Snowflake Trial Account use "America/Los_Angeles" as the default. This may be because Snowflake was founded in San Mateo, California, USA. 
*/