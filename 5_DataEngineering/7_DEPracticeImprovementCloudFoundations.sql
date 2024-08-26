/*
📓 Data Engineer Skillset Improvements
When this project is over, Kishore could probably ask to join the Data Engineering team at his job. That team has already expressed interest and now that he can show them his project work, they would likely be ready to move him over.

pipeline

But, Kishore also knows there's a lot more for him to learn. Before showing his pipeline to the DE Team Manager, he asks the current DE team members to meet him in the break room for a lunchtime code review.

They look over his work, congratulate him on his pipeline work. When pressed, they offer a few suggestions for improvements.

pipeline

📓 Pipeline Improvements
His coworkers suggest the following improvements:

He could add some file metadata columns to the load so that he will have a record of what files he loaded and when.
He could move the logic from the PL_LOGs view into the same SELECT. (fewer pieces to maintain).
If he does change the select logic, he will then need a new target table to accommodate the output of the new select.
When he has a new select that matches the new target table, he can put it into a new COPY INTO statement.
After he has a new COPY INTO, he could put it into an Event-Driven Pipeline (instead of a task-based Time-Driven Pipeline)


Kishore is excited about tackling the suggested improvements and asks if they will be willing to answer questions if he gets stuck. They happily agree to answer any questions he has because if he joins the team, they can move on to more complex work and give him the junior tasks. They love the idea of him doing the bulk of the beginner work.

Kishore dives into the changes and writes a pretty cool select statement.

TIP: Don't just run the select listed below. Take some time to look at it. If you have completed Badge 4: Data Lake Workshop, you will recognize some familiar tricks.
*/

-- 🥋 A New Select with Metadata and Pre-Load JSON Parsing 
USE ags_game_audience.raw;
SELECT
  metadata$filename                          AS log_file_name, --new metadata column
  metadata$file_row_number                   AS log_file_row_id, --new metadata column
  CURRENT_TIMESTAMP(0)                       AS load_ltz, --new local time of load
  GET($1, 'datetime_iso8601')::TIMESTAMP_NTZ AS datetime_iso8601,
  GET($1, 'user_event')::TEXT                AS user_event,
  GET($1, 'user_login')::TEXT                AS user_login,
  GET($1, 'ip_address')::TEXT                AS ip_address
FROM
  @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
  (FILE_FORMAT => 'ff_json_logs');

/*
🎯 Create a New Target Table to Match the Select  (Using CTAS, if you want to)
You're going to create a new logs table in the RAW schema and call it ED_PIPELINE_LOGS. You could write this table definition any way you want. Use a template, write it manually, or use a CTAS.  ("ED" is for "Event-Driven" which we will explain later)

To create the table using CTAS, simply type CREATE TABLE <table name> AS on the line above your SELECT statement, and run it.

Using CTAS creates the table and loads it in one step, which is cool! But it does something weird. It makes every VARCHAR field VERY big. So if you use the CTAS as a shortcut to define your table, you'll want to tweak the table definition after the initial creation.


If you copy the definition and paste it into a worksheet to edit it, you will wipe out all the rows. That's fine. We're going to write a COPY INTO in the next step anyway.

FYI: We used 100 characters for all the VARCHARS except USER_EVENT. For that, we used 25.
*/
USE ROLE sysadmin;

CREATE OR REPLACE TABLE raw.ed_pipeline_logs (
  log_file_name VARCHAR(100),
  log_file_row_id NUMBER(18, 0),
  load_ltz TIMESTAMP_LTZ(0),
  datetime_iso8601 TIMESTAMP_NTZ(9),
  user_event VARCHAR(25),
  user_login VARCHAR(100),
  ip_address VARCHAR(100)
)
;

-- 🥋 Create the New COPY INTO 
--truncate the table rows that were input during the CTAS, if that's what you did
TRUNCATE TABLE ed_pipeline_logs;

--reload the table using your COPY INTO
COPY INTO ed_pipeline_logs
FROM (
  SELECT
    metadata$filename                          AS log_file_name,
    metadata$file_row_number                   AS log_file_row_id,
    CURRENT_TIMESTAMP(0)                       AS load_ltz,
    GET($1, 'datetime_iso8601')::TIMESTAMP_NTZ AS datetime_iso8601,
    GET($1, 'user_event')::TEXT                AS user_event,
    GET($1, 'user_login')::TEXT                AS user_login,
    GET($1, 'ip_address')::TEXT                AS ip_address
  FROM @AGS_GAME_AUDIENCE.RAW.UNI_KISHORE_PIPELINE
)
FILE_FORMAT = (FORMAT_NAME = ff_json_logs);

/*
📓 Developing Confidence as a Data Engineer

Kishore loves the new COPY INTO he built and he's glad his coworkers encouraged him to look for a way to combine the two steps. The new code is something to be proud of.

But he's also a little concerned because he had to do a lot of trial and error. To complete the SELECT and COPY INTO, he:

Did 5 searches on  docs.snowflake.com
Went to community.snowflake.com 3 times, and
Followed 2 tips from Stack Overflow
All of this looking around, and reading, and copy/pasting was required before he finally figured out the exact syntax to use for the JSON.

Does this mean he doesn't have what it takes to be a Data Engineer? Should he have had this syntax memorized already?



Of course not! Data Engineers use documentation. They use Community forums! They use Stack Overflow! And they do it daily! (Hourly?!?)

In fact, returning to the docs and the web multiple times means he has exactly the right tenacity and curiosity to continue improving.

Another reason he'll make a great Data Engineer is that he asked his more experienced Data Engineers for input.

Relying on other, more advanced Data Engineers to help you see room for improvement in your work is critical. In some teams a design-review meeting will be highly collaborative. In other teams, the lead Data Engineer may prescribe certain changes based on their personal design philosophy or requirements set by higher management.

In some organizations fast running pipelines might be the most important thing, while in others, cost might be more important. In yet another, it might always be the goal to have things that are a good compromise between the two.

Kishore should ask the lead DE what design principles are considered most critical for the team and how he should prioritize them if it seems like they are coming into conflict. Regular design reviews will also allow his lead to flag any issues if the values get out of balance.



In many teams, a discussion about combining the PL_LOGS view and the COPY INTO steps might have ended with the team agreeing to leave them as two separate steps. Looking at the last two values listed above, this decision came down to a contest between easy-to-maintain and atomicity. Leaving them as separate steps would have made the solution more atomic. Combining them makes the solution slightly easier to maintain for more advanced DEs who can read the code easily and don't want to have to search around to figure out where certain logic is implemented.

Data Engineering definitely requires technical skills, but a highly-technical Data Engineer isn't necessarily great at the job. The best Data Engineers are excellent because they are creative, too.

Kishore's coworkers explain that there are often no strictly right or wrong design decisions. His role as a Junior Data Engineer will be to know what Snowflake is capable of even if it takes trial and error to implement those capabilities. Over time he'll be expected to combine his knowledge and skills toward accomplishing the goal in a way that meets the organizations priorities.

📓 Event-Driven Pipelines
The pipeline Kishore (and you!) created before is a Time-Driven Pipeline.

A Time-Driven Pipeline is not always the best solution because it can waste money looking for data that isn't there, or allow a backlog to build up if it hasn't been scheduled correctly to meet demand.

The major alternative to Time-Driven Pipelines are Event-Driven Pipelines and they are made possible by a Snowflake object called a Snowpipe.

Our Event-Driven Pipeline will "sleep" until a certain event takes place, then it will wake up and respond to the event. In our case, the "event" we care about is a new file being written to our bucket. When our pipe "hears" that a file has arrived, it will grab the file and move it into Snowflake.

📓  Review, Progress, and Next Steps
Let's review the components of our old, Task-Driven pipeline, our recent changes, and our end goal.

Remember that we successfully created a Task-Driven or Time-Driven Pipeline that contained 4 steps.



Then, with the help of the other DEs, Kishore created a COPY INTO that removes the need for Step 3 View logic.

What does the new COPY INTO do to the Step 2 Task? Is that still needed? Or not?

And what about Step 4? Is that still needed? Does it need to be edited?



With regard to the old Step 2 Task, it will not be needed. It will be replaced with a Snowpipe.



That COPY INTO Kishore just created will serve as the portion of a Snowpipe we will soon create.

Step 4, the LOAD_LOGS_ENHANCED task, will be edited to point at a different source table and it will be part of our new Event-Driven Pipeline. But that will happen in a later lab.

For now, with those changes in mind, the image below is a preview of what our new Event-Driven Pipeline will look like when it is complete.



Now, you may be thinking, what the heck is that HUB thing? What the heck are those flags? And that conveyor belt? What is that?

Those are cloud engineering infrastructure objects that are leveraged by Snowflake to make continuous loading possible. So before we create the Snowpipe,it will benefit Kishore (and you) to understand how they work.
*/


/*
📓 Cloud-Based Services for Modern Data Pipelines
Modern data pipelines depend on cloud-based services offered by major cloud providers like Amazon Web Services (AWS), Microsoft Azure, and Google Cloud Platform (GCP).

Creating an Event-Driven Pipeline in Snowflake depends on 3 types of services created and managed by the cloud providers.

STORAGE
-----------------------------------------------------------------
AWS - S3 Buckets
Azure - Blob Storage
GCP - GCS Buckets

PUBLISH & SUBSCRIBE NOTIFICATION SERVICES (Hub & Spoke)
-----------------------------------------------------------------
AWS - Simple Notification Services (SNS)
Azure - Azure Web PubSub and Azure Event Hub
GCP - Cloud Pub/Sub

MESSAGE QUEUING  (Linear Messaging)
-----------------------------------------------------------------
AWS - Simple Queue Services (SQS)
Azure - Azure Storage Queues and Azure Service Bus Queues
GCP - Cloud Tasks
📓 A Closer Look at Pub/Sub Services
Publish and Subscribe services are based on a Hub and Spoke pattern. The HUB is a central controller that manages the receiving and sending of messages. The SPOKES are the solutions and services that either send or receive notifications from the HUB.

If a SPOKE is a PUBLISHER, that means they send messages to the HUB. If a SPOKE is a SUBSCRIBER, that means they receive messages from the HUB. A SPOKE can be both a publisher and a subscriber.

With messages flowing into and out of a Pub/Sub service from so many places, it could get confusing, fast. So Pub/Sub services have EVENT NOTIFICATIONS and TOPICS. A topic is a collection of event types. A SPOKE publishes NOTIFICATIONS to a TOPIC and subscribes to a TOPIC, which is a stream of NOTIFICATIONS.
*/

/*
🔭 << See that Symbol? That's a Telescope.
It looks weird. We think it looks more like a plane that is dumping black stuff out as it flies, but, yours might look better, depending on your browser or operating system.

In any event, we want you to slow down for a moment, read carefully, and absorb something important:

For the next few pages, you will be observing a process that we DO NOT WANT YOU TO FOLLOW ALONG WITH. We just want you to WATCH. Please don't post a bunch of comments saying "How do I set up AWS without a Credit Card?" and "You never told us we'd have to have an AWS console account?"  and "It's telling me that uni-kishore-pipeline already exists!"

We're going to tell you a story (and show you screenshots) about the process Kishore follows to set up a Snowpipe using AWS and Snowflake. Then, we'll ask you to follow a shorter set of steps to see a Snowpipe in action, in your own trial account.

Don't try to do every step in the process. Wait until you see a 🥋 or 🎯 before you try to take action. If you reach the end of this lesson and just really, really want to set up your own SNS topic, you can come back to this page and try to muddle through on your own. You might find this stuff helpful as you embark on your self-assigned task, but we will not be offering support for that task.

🔭 Kishore Logs into His AWS Console Account
You do not need to log in to an AWS Console. There is no requirement to sign up for one. For this section, just read and follow along!

He goes to SNS and creates a topic called dngw_topic.


He then goes to the bucket and sets up an Event Notification. The notification is called "a_new_file_is_here." Any time a PUT is run that puts a new file in the bucket, an event notification will be generated.

What will happen with that notification after it is generated?   It will be sent to to the SNS Topic named dngw_topic.


If you'd like to see the above steps, live, this video by YouTuber QuikStarts is short and full of helpful information. YOU ARE NOT EXPECTED TO PERFORM THE ABOVE STEPS IN THIS WORKSHOP.
*/

/*
🔭 Kishore Gets an SNS IAM Policy and Adds it to His Topic
JUST OBSERVE THIS STEP, DO NOT RUN THIS IN YOUR SNOWFLAKE TRIAL ACCOUNT FOR THIS WORKSHOP.

If you run the below step in your account before doing the next lab, you will not be able to get the badge for this workshop.  Wait until we tell you to carry out steps. This section is for observation only.

Kishore ran the command above and Snowflake sent back a policy for him. The policy looks like gibberish at first, but it's pretty simple.

It just says that a User (a Service Account, actually) is allowed to subscribe to the dngw_topic.

When setting up a Snowpipe in your own account (later) you may want to generate a policy like this that you can then copy into a topic but you should not do this step for this Workshop.

Kishore goes back in to AWS and copies the policy into the dngw_topic.

He has a few edits to make since he doesn't want to replace the whole policy, he just wants to add a section to it.

🔭 Kishore Gets an SNS IAM Policy and Adds it to His Topic
JUST OBSERVE THE STEPS ON THIS PAGE, YOU WILL RUN STEPS LIKE THIS IN YOUR NEXT LAB, BUT RIGHT NOW, JUST READ/LOOK/UNDERSTAND.

Kishore goes back to his Snowflake account and finally runs the command to create a Snowpipe. The AWS_SNS_TOPIC property is a lynchpin and it works like magic behind the scenes.

After the PIPE is created, Kishore runs a command to get a look at his PIPE.

The PIPE returns an interesting Key/Value Pair. The Key is "Notification Channel Name" and for Kishore, the value ends in u8Pg. He looks in his AWS Console and notices that his topic has a new subscription and the endpoint property matches the Notification Channel Name for his Snowpipe. His Snowpipe is complete!!
*/

