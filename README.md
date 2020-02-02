# Fantasy-Football-League-Data
This repository helps you turn raw league data from Yahoo league archives into useful data sets containing prior-year lineup detail. Because Yahoo doesn't store prior lineups, just the overall matchup totals, this syntax is designed to help you reconstruct that information. The code is not designed as an out-of-the-box solution. I tried to make it as versatile as possible for different league formats but this code would need to be updated for different scoring formats, positions (especially leagues with a flex), weeks played, etc.

## Raw data sets
The raw data sets within this repo are from my league. They were copy and pasted directly from our league's archive site on Yahoo. There is probably a better way to pull this information off the site, but I do not have much experience with scraping. 

### Drafts_Raw.csv
This data is pulled from the 'Draft Results' section of the archived site. Yahoo splits the table into different rounds. You can copy and paste all as one and delete the 'Round #' rows or copy and paste each round individually. All years are combined into this one data set and the 'Year' field was added manually. You do not need to worry about Yahoo's truncation of the fantasy team name because it is dealt with in the code (it would only become a problem if two teams had the same first 10 characters in their name).

### Matchups_Raw.csv
This data is pulled from the 'Overview > Schedule' section for each team individually. The 'Manager_Team' field was added manually and represents the team name for the data (the first score value in the ###-### format of the 'Score' field). Year was added manually. Because the 'Overview > Schedule' section only includes regular season games, the 'Overview > Playoffs' section was used to manually record playoff matchups using the same format used for regular season games. I named these playoff matchups 'Playoffs Qtr', 'Playoffs Semi', 'Playoffs 5th', 'Playoffs 3rd', 'Playoffs Champ', 'Consolation Qtr', 'Consolation Semi', 'Consolation 9th', 'Consolation 11th', and 'Consolation Champ.' If your league has different settings or you want to use different names, you'll need to update **CleanMatchups.R**

### Transactions_Raw.csv
This data was pulled from the 'Transactions > All' section. Do not worry about empty fields for 'Date' and 'Type' (trades only), this is handled in the programming. The 'Year' field was again added manually, and represents the year of the season, not the year of the transaction. 

### Teams.Raw
This data was created manually by simply filling out the 'Manager_Team' field for a fantasy team's final team name. This team name field is used to clean the Drafts_Raw.csv data set so you want to make sure the 'Manager_Team' field is what shows up in the Yahoo archive, not, for instance, what the team name was at earlier times in the season. The 'Manager' field represents your league mate's names and should be unique and consistent. 'Year' is just the year of the season. If a manager had the same team name for multiple seasons, make sure there are separate rows for each year.

### Rivals.Raw
This data set is unique by manager and simply includes who their rival is, using the same name style used in **Teams.Raw**. I created this for part of a visualization and is not necessary.

### DefScores.Raw
The individual player statistics come from the R package [nflscrapr](https://github.com/maksimhorowitz/nflscrapR) by maksimhorowitz and ryurko. Creating defensive scoring from the play-by-play data set in this package seemed like a large project that might ultimately still be subject to multiple data errors. Therefore, I created a data set with defensive fantasy points aggregated for each team from [fantasydata.com](https://fantasydata.com/nfl/fantasy-football-leaders?position=7&season=2019&seasontype=1&scope=2&subscope=1&scoringsystem=1&startweek=1&endweek=1&aggregatescope=1&range=1). This source still has some issues and you'll notice those being dealt with in **CreateLineups.R**. The data set sometimes has the wrong number of turnovers and doesn't appear to count extra point returns. I found these errors by looking up individual games using [pro-football-reference.com](https://www.pro-football-reference.com/). The data cleaning of this data set in **CreateLineups.R** was only done when that value was causing an error. You'll likely need to adjust points for more team-week-year combinations if a team was started in your league but not in mine and has an error.

## GetSeason.R
This is our master script, although you'll really need to run **CreateStats.R** and **CreateLineups.R** individually as well. **CreateStats.R** is so slow that you'll be running one season at a time. **CreateLineups.R** takes some manual processing power (finding errors in statistics and choosing between rosters when multiple are possible) so you'd want to run that one season at a time as you update. This script is fairly straight-forward but runs many scripts within it.

## CreateStats.R
This syntax creates a data set of offensive and kicker statistics using nflscrapr. For kicker points, we actually use play-by-play data for field goals and weekly data for extra points. This was because the weekly data doesn't have individual field goal lengths and the play-by-play data is missing some extra points. There is some data cleaning done in this code which was added when I found errors while running **CreateLineups.R**. Many of these errors are related to stat corrections, which I looked up using [fantasy.nfl.com](https://fantasy.nfl.com/research/statcorrections). Some of these errors are also unique plays not captured in the weekly stats like an offensive fumble return touchdown. This script also includes the scoring settings for my league, so you'll need to update and adjust accordingly. The code then turns the statistics into fantasy points. This script has three outputs, **Players_YYYY.csv**, **WeekStats_YYYY.csv**, and **KickStats_YYYY.csv**. **Players_YYYY.csv** is used when we need to merge our Yahoo data sets with these data coming from the NFL. Specifically to match up player names and player ID's. **WeekStats_YYYY.csv** gives us our fantasy point data. **KickStats_YYYY.csv** is not used elsewhere but is such a slow process to pull the data that I save it. 

## CleanMatchups.R
This script cleans up our **Matchups_Raw.csv**. This script is also set to my league settings. I am setting the week number based on the *week name* I used in **Matchups_Raw.csv**. For example, 'Playoffs Qtr' = 14. This will need to be updated depending on your league.

## CreateDrafts.R
This script uses **IDREF.R**, **WeekStats_YYYY.csv**, and **DefScore_Raw.csv**. It calculates [Value Based Drafting](https://www.footballguys.com/05vbdrevisited.htm) points. This can be updated to fit your league. My 12-team league has 3 WR, so I use 36 as my number for the VBD calculation for WR. This syntax also creates Position_Rank which allows us to see how draft picks faired in the end. I also create a field called 'Season_Change' which is essentially how much a player rises or falls relative to his positional draft pick and the number of players picked in that position. I use this to calculate top draft pick and top draft busts. Because many more WRs score points than QBs, top draft bust was almost always the worst pick because they could fall to something like WR150. For that reason, I only drop them to a 'droppable' level if they fall below that, which I calculate as the number of players drafted at that position. 

## CreateLineups.R
This script is the most complex and time consuming part of the process. It uses most subscripts and raw data files. It starts with a data set from **IDREF.R** which has each player on each manager's roster for all weeks of a season. It adds in the fantasy point information. It adds in bye information which helps when cleaning the starting lineups. It also cleans the defensive fantasy point totals mentioned about **DefScores_Raw.csv**. It then runs through a loop for each manager and each week. Each loop tests every possible lineup variation to see if the point total from that possible lineup equals the matchup total we see from our Yahoo data. If leagues have different formats, this script would need to be adjusted. I did not want to try to make this loop for league's with a flex because it seems difficult and my league does not have a flex. I imagine what you could do is duplicate rows of RB's, WR's, and TE's, and make their position 'Flex', then just add flex as another position. 

If no lineup total is a match, the loop prints an error. There is likely a data error for a player. The best place to start looking for these errors is the stat corrections website and checking the defensive score, as mentioned above. This process is arduous. If I found an error in an offensive stat, I added it to the data cleaning section of **CreateStats.R** and re-creted **WeekStats_YYYY.csv** by only running the few lines of code that update the players stats and re-calculates the fantasy point totals. 

If multiple lineup possibilites add up to the matchup total, the loop prints that information. For these lineup possibilites, there is no automated way of selecting between them accurately. I've added in fields like bye information, number of times the player had been started, and where they were drafted to assist in the decision. I've created **LineupDuplicatesDebugger.R** to make the process easier but it can be challenging. More on that process can be found below. After I've chosen the lineup possibilites I want to get ride of, I go through and remove them from the starting_rosters object. 

## CreateTeams.R
Once the starting rosters data set has been created, this can be run from **GetSeason.R**. It sets where a team finished, how they finished in the regular season, and how they finished by points. It calculates how they finished at each position. It adds in rival information if you want it to.

----------------------------------------------------
# Subscripts
----------------------------------------------------

## CleanDrafts.R
Cleans up **Drafts_Raw.csv**. Gets called by **CreateRosters.R**.

## CleanTransactions.R
Cleans up **Transactions_Raw.csv**. Gets called by **CreateRosters.R**

## CreateRosters.R
Creates a data set of which players were on a team for each week. Gets called by **CreateLineups.R** and **IDREF.R**

## IDREF.R
This script uses Yahoo data from **CreateRosters.R** and **Players_YYYY.csv** created in **CreateStats.R** to add NFL ID's to Yahoo player names. This allows us to merge NFL data with our Yahoo data. We do this because names take on different formats across data sources and there are some players with the same names. This gets called by **CreateDrafts.R** and **CreateLineups.R**

## Schedule.R
This script creates a data set with the Monday for each week of a season. Because a manager can add and drop players on Sunday, even after they played if they were benched, then we use Monday as the final day for setting the weekly roster. This gets called by **CreateRosters.R**.

## ByeWeeks.R
One big contributor to duplicate lineup possibilites in **CreateLineups.R** is a player scoring zero. Then, a player in the same position on bye could have also started with the same result. This script creates a data set of weeks a player was on bye to help us see which lineup was likely the one started. If a player played for multiple teams in a season, he will have byes showing up for each week those teams had their bye. If a player shows up as on bye despite having points, this is the likely reason. Gets called by **CreateLineups.R**.

## LineupDebugger.R
This can be used to look at errors from running **CreateLineups.R**. It helps you create a data set for a specific manager and week. The script also prints out each possible lineup, that lineup's fantasy total, and the target fantasy total. I put a breakpoint in the loop to run one at a time. This is useful to see where potential data problems are. An example might be that **CreateLineups.R** shows that the smallest difference between target score and all possible scores is 0.1. But, the 0.1 difference lineup has a guy on bye. Looking through each possible lineup individually shows a good looking lineup that is 2.0 points off. This is likely an error for the defense point total. 

## LineupDuplicatesDebugger.R
There are typically only a couple type of reasons multiple lineup possibilites add up to the target score. 1) A starter scores 0 and multiple guys on the bench also got 0. I added bye information to help solve some of these issues quickly. Sometimes, it is not so clear. I used [pro-football-reference.com](https://www.pro-football-reference.com/) to see if a player was on the field during that week. Sometimes both guys didn't play or both did play and you'll have to make a judgement call about who 'started.' 2) A combination of guys score the same cumulative total (Ex. RB A scores 10, WR A scores 5, RB B scores 5, WR B scores 10). I added information about where players were drafted and how many times they were started up to that week to help with this decision. Sometimes they're easy, like knowing a guy wouldn't have put DeAndre Hopkins on the bench. Sometimes they were more difficult and I looked at the **starting_rosters** object to see if a guys was started in prior weeks. Sometimes I thought, 'I know this manager is a Vikings fan so I doubt he was benching Stefon Diggs.' It can get very subjective but it's all we can do. 3) Two players scored the same total. This is similar to issue 2 and is a judgement call. Sometimes it's obvious, sometimes it's very difficult.

This script only prints out the differences in the multiple lineups, so the options you're choosing from are easy to see. I used a spreadsheet to record the week, manager, and lineups that *weren't* started to add to the cleaning portion of **CreateLineups.R**

