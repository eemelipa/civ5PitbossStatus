# civ5PitbossStatus
Script for publishing&amp;updating civilization 5 pitboss game status to a website.

The script monitors the blinking icons on civ 5 pitboss map view to infer which players haven't yet played. Use simultaneous turns since war declaration might otherwise change the ordering of player icons.

Screenshots are taken from the timer and the score screen.

How to get started:
1. Install AutoIt https://www.autoitscript.com/

2. Set up your pitboss running

3. Put the pitboss to map view

4. Set up the script (coords, player names, and your ip&s3 conf) -- AutoIt window info tool is good for figuring out the coordinates

5. run it with AutoIt

# Email notifications on turn change
The logic uploads "turn_change.txt" file to aws s3 when enough players change from "turn played" to "turn not played". AWS lambda can receive events from S3 and based on those trigger email sending via SES. Once the lambda function sees "turn_changed.txt" file change it will send the emails.
