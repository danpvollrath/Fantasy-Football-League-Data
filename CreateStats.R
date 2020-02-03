## ************************************
## Script name: CreatingStats.R
## Purpose: Getting Weekly Stats for Each Player
## For: Fantasy Football Tableau Dashboard
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-06
## ************************************
##
## Notes: 
## - For now, I'm keeping all the fields from the games in 
## the final data set in case I decide to make something with them
## later
##
##
##
##
## *************************************

year <- 2019
numWeeks <- 16

options(stringsAsFactors = FALSE)

library(nflscrapR)
library(reshape)

positions <- c("QUARTERBACK", "RUNNING_BACK", "WIDE_RECEIVER", "TIGHT_END", "FIELD_GOAL_KICKER")
games <- scrape_game_ids(year, type = "reg") # takes about two minutes
teams <- unique(games$home_team)

## ******************************
## Getting list of players
## ******************************

# This takes a long time, about 2.5 hours
#  I'm not sure why it takes so long, I should find a static table
start.time <- Sys.time()

for(i in 1:32){
  players_tmp <- season_rosters(year, teams = teams[i], positions = positions)
  if(i == 1){players <- players_tmp}else{
    players <- rbind(players, players_tmp)}
  cat(i, "teams complete", "\n")
}


## *********************************
## *******************************
## Getting weekly game statistics
## *******************************
# **********************************

# *****************************
## Rushing, Recieving, Passing
## ****************************

# Getting data
# *****************************

# Get data
# Should take 1-2 minutes
week_stats <- season_player_game(year, Weeks = numWeeks)


# Bring in week of season information
week_stats <- merge(week_stats, games[, c('game_id', 'week')], by.x = 'game.id', by.y = 'game_id', all.x = TRUE)

# Rename Col 'week' into 'Week'
week_stats <- rename(week_stats, c('week' = 'Week'))

# Hardcoding over data problems
# ********************************

# 2018
week_stats$pass.twoptm[week_stats$game.id == '2018092000' & week_stats$playerID == 'J.Landry'] <- 1
week_stats$rushtds[week_stats$game.id == '2018111805' & week_stats$playerID == 'M.Evans'] <- 1

# 2017
week_stats$recyds[week_stats$game.id == '2017091004' & week_stats$name == 'Da.Johnson'] <- 67 #1yd diff
week_stats$recyds[week_stats$game.id == '2017101503' & week_stats$name == 'A.Thielen'] <- 96 #1yd diff
week_stats$recyds[week_stats$game.id == '2017100900' & week_stats$name == 'T.Cohen'] <- -6 #5yd diff
week_stats$passyds[week_stats$game.id == '2017111909' & week_stats$name == 'T.Brady'] <- 340 #1yd diff
week_stats$recyds[week_stats$game.id == '2017111909' & week_stats$name == 'R.Gronkowski'] <- 37 #1yd diff
week_stats$rushtds[week_stats$game.id == '2017112606' & week_stats$name == 'N.Agholor'] <- 1 #fumble recovery td
week_stats$fumbslost[week_stats$game.id == '2017120303' & week_stats$name == 'T.Cohen'] <- 1 #lost fumble
week_stats$passyds[week_stats$game.id == '2017121705' & week_stats$name == 'D.Brees'] <- 281 #lost fumble
week_stats$passyds[week_stats$game.id == '2017122411' & week_stats$name == 'D.Prescott'] <- 181
week_stats$recyds[week_stats$game.id == '2017122411' & week_stats$name == 'D.Bryant'] <- 43

# 2016
week_stats$passyds[week_stats$game.id == '2016091808' & week_stats$name == 'C.Palmer'] <- 304
week_stats$passyds[week_stats$game.id == '2016100210' & week_stats$name == 'D.Brees'] <- 207
week_stats$rushyds[week_stats$game.id == '2016100207' & week_stats$name == 'I.Crowell'] <- 120
week_stats$fumbslost[week_stats$game.id == '2016091809' & week_stats$name == 'R.Wilson'] <- 0 # No lost fumble 
week_stats$rushyds[week_stats$game.id == '2016100210' & week_stats$name == 'M.Ingram'] <- 56
week_stats$rushyds[week_stats$game.id == '2016110300' & week_stats$name == 'J.Winston'] <- 11 # stat correction 
week_stats$recyds[week_stats$game.id == '2016110604' & week_stats$name == 'B.Marshall'] <- 46 # stat correction
week_stats$rushyds[week_stats$game.id == '2016111307' & week_stats$name == 'M.Mariota'] <- 0 # stat correction
week_stats$recyds[week_stats$game.id == '2016111310' & week_stats$name == 'L.Fitzgerald'] <- 132 # stat correction
week_stats$rushyds[week_stats$game.id == '2016121805' & week_stats$name == 'S.Ware'] <- 69 # stat correction
week_stats$recyds[week_stats$game.id == '2016122408' & week_stats$name == 'A.Cooper'] <- 76 # stat correction
week_stats$passyds[week_stats$game.id == '2016122408' & week_stats$name == 'D.Carr'] <- 232 # stat correction
week_stats$rushyds[week_stats$game.id == '2016122408' & week_stats$name == 'F.Gore'] <- 72 # stat correction

## *******************************
## Kicker points
## *******************************
# The play by play data is missing extra points, so I'm using the weekly data source
#  used for offensive statistics as my source for extra point information while 
#  using this data source for field goal data

# Takes about an hour, at least for me
pb <- txtProgressBar(min = 0, max = nrow(games), style = 3)
for(i in 1:nrow(games)){
  
  # Pull data for game
  PlayerGameData_tmp <- scrape_game_play_by_play(games[i, 'game_id'], season = year, type = 'reg')
  
  # Filter to made field goals and extra points
  PlayerGameData_tmp <- PlayerGameData_tmp[which(PlayerGameData_tmp$field_goal_result == 'made'), ]
  
  # If no field goals in a game, move to next game
  if(nrow(PlayerGameData_tmp) > 0){
      # Limiting to columns we need
      PlayerGameData_tmp <- PlayerGameData_tmp[ ,c('kicker_player_id', 'kick_distance', 'play_type')]
      
      # Setting the week number
      PlayerGameData_tmp$Week <- games$week[i]
      
      # Append new data to old data
      if(i==1){PlayerGameData <- PlayerGameData_tmp}else{
        PlayerGameData <- rbind(PlayerGameData, PlayerGameData_tmp)}
  }
  
  # Update progress
  setTxtProgressBar(pb, i)
}

PlayerGameData <- rename(PlayerGameData, c('week' = 'Week'))

# Check to make sure the number of field goals we get from p-b-p data
#   matches the number we see in our weekly stats dataset
# *******************************************************************

PGD.chk <- PlayerGameData %>% group_by(kicker_player_id, Week) %>% summarise(kicks = length(kicker_player_id))
kickers <- week_stats[,c('playerID', 'Week','game.id', 'fgm', 'xpmade')]
PGD.chk <- merge(PGD.chk, kickers, by.x = c('kicker_player_id', 'Week'), by.y = c('playerID', 'Week'), all.x = TRUE)
PGD.chk <- PGD.chk[which(PGD.chk$Week <= 16), ]
PGD.chk$Check <- (PGD.chk$kicks == PGD.chk$fgm)
table(PGD.chk$Check)


## *****************************************
## Turning statistics into fantasy points
## *****************************************

# This will require hand-holding by someone trying to 
# use this programming for different leagues

# Rushing, Receiving, Pass, Return data
# ****************************************
week_stats$fp.pass.yds <- week_stats$passyds * 0.04
week_stats$fp.pass.tds <- week_stats$pass.tds * 6.0
week_stats$fp.pass.ints <- week_stats$pass.ints * -3
week_stats$fp.rush.yds <- week_stats$rushyds * 0.10
week_stats$fp.rush.tds <- week_stats$rushtds * 6.0
week_stats$fp.rec.yds <- week_stats$recyds * 0.10
week_stats$fp.rec.tds <- week_stats$rec.tds * 6.0
week_stats$fp.ret.tds <- (week_stats$kickret.tds + week_stats$puntret.tds) * 6
week_stats$fp.two.pnts <- (week_stats$pass.twoptm + week_stats$rush.twoptm + week_stats$rec.twoptm) * 2.0
week_stats$fp.fumbls <- week_stats$fumbslost * -2.0

# Kicking data
# *******************************

# Add fantasy points to field goal data
kickstats <- PlayerGameData
kickstats$fp.kick <- 0
kickstats$fp.kick[PlayerGameData$kick_distance >= 50] <- 5
kickstats$fp.kick[between(PlayerGameData$kick_distance, 40, 49)] <- 4
kickstats$fp.kick[PlayerGameData$kick_distance < 40] <- 3

# Aggregate individual kicks by week
kickstats <- kickstats %>% group_by(kicker_player_id, Week) %>% summarise(fp.kick = sum(fp.kick))

  # Merge in xp data
kickstats <- merge(week_stats[ ,c('playerID', 'Week', 'xpmade')], kickstats, 
                    by.x = c('playerID', 'Week'), by.y = c('kicker_player_id', 'Week'), all.x = TRUE)

# Add extra points and field goals
kickstats$fp.kick <- rowSums(kickstats[ ,c('xpmade', 'fp.kick')], na.rm = TRUE)

# Remove the xp field
kickstats <- kickstats[ ,-which(names(kickstats) == 'xpmade')]



# **********************************************
# Merging Offensive data w/ kicking data
# **********************************************

week_stats <- merge(week_stats, kickstats, 
                    by = c('playerID', 'Week'),
                    all.x = TRUE)

# Remove week 17
week_stats <- week_stats[which(week_stats$Week <= numWeeks), ]

# Final fantasy point data
week_stats$fp <- rowSums(week_stats[ ,c("fp.pass.yds", "fp.pass.tds", "fp.pass.ints", "fp.rush.yds",
                                        "fp.rush.tds", "fp.rec.yds", "fp.rec.tds", "fp.ret.tds",
                                        "fp.two.pnts", "fp.fumbls", "fp.kick")],
                         na.rm = TRUE)

## *********************************************
## Merging player info with fantasy point data
## *********************************************

week_stats <- merge(week_stats, players[ ,c('Player', 'Pos', 'GSIS_ID')],
                    by.x = 'playerID', by.y = 'GSIS_ID', all.x = TRUE)


# ***********************************************************
# Players who do not have a position
# ***********************************************************

week_stats$Pos[week_stats$Pos == 'FB'] <- 'RB' # All fullbacks
week_stats$Pos[week_stats$playerID == '00-0027890'] <- 'RB' # Ben Tate
week_stats$Pos[week_stats$playerID == '00-0029892'] <- 'RB' # Kyle Juszczyk



## *******************************
## Save File
## *******************************


write.csv(players, sprintf("C:/Users/danpv/OneDrive/Documents/Fantasy Football Project/Players_%g.csv", year), 
          row.names = FALSE)
write.csv(week_stats, sprintf("C:/Users/danpv/OneDrive/Documents/Fantasy Football Project/WeekStats_%g.csv", year),
          row.names = FALSE)
# KickStats doesn't get used anywhere else, but it takes so long to pull that I am saving it
write.csv(PlayerGameData, sprintf("C:/Users/danpv/OneDrive/Documents/Fantasy Football Project/KickStats_%g.csv", year),
          row.names = FALSE)
