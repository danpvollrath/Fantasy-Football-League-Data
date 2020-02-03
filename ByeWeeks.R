## ************************************
## Script name:ByeWeeks.R
## Purpose: Create list of bye weeks for creating starting lineups
## For: Fantasy Football Data Project
## Location:  Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-12
## ************************************
##
## Notes: This process will give a player a 'Bye' for
## each team he played for that year. You may see byes in
## a week that a player scored for this reason. 
##
## *************************************

stats <- read.csv(paste0(file.location, sprintf("WeekStats_%g.csv", year))) 

# 2019
# ****************************
if(year == 2019) {
    player_team <- unique(stats[,c('playerID', 'Team', 'Pos')])
    
    bye_week <- c(4, 4, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12, 12, 12)
    bye_team <-c('NYJ', 'SF', 'DET', 'MIA', 'BUF', 'CHI', 'IND', 'OAK', 'CAR', 'CLE', 'PIT', 'TB', 'BAL', 'DAL',
                 'ATL', 'CIN', 'LAR', 'NO', 'DEN', 'HOU', 'JAX', 'NE', 'PHI', 'WAS', 'GB', 'NYG', 'SEA', 'TEN',
                 'ARI', 'KC', 'LAC', 'MIN')
    byes <- data.frame(bye_week, bye_team)
    byes$Year <- 2019
    byes$Bye <- 'Bye'
    
    byes_player <- merge(player_team, byes, by.x = 'Team', by.y = 'bye_team', all.x = TRUE)
}

# 2018
# ****************************
if(year == 2018) {
    player_team <- unique(stats[,c('playerID', 'Team', 'Pos')])
    
    bye_week <- c(4, 4, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 11, 11, 12, 12)
    bye_team <-c('CAR', 'WAS', 'CHI', 'TB', 'DET', 'NO', 'GB', 'OAK', 'PIT', 'SEA', 'ATL', 'DAL', 'LAC',
                 'TEN', 'ARI', 'CIN', 'IND', 'JAX', 'NYG', 'PHI', 'BAL', 'DEN', 'HOU', 'MIN', 'BUF',
                 'CLE', 'MIA', 'NE', 'NYJ', 'SF', 'KC', 'LAR')
    byes <- data.frame(bye_week, bye_team)
    byes$Year <- 2018
    byes$Bye <- 'Bye'
    
    byes_player <- merge(player_team, byes, by.x = 'Team', by.y = 'bye_team', all.x = TRUE)
}

# 2017
# ****************************

if(year == 2017) {
    player_team <- unique(stats[,c('playerID', 'Team', 'Pos')])
    
    bye_week <- c(1, 1, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11)
    bye_team <-c('MIA', 'TB', 'ATL', 'DEN', 'NO', 'WAS', 'BUF', 'CIN', 'DAL', 'SEA', 'DET', 'HOU',
                 'ARI', 'GB', 'JAX', 'LAR', 'NYG', 'TEN', 'CHI', 'CLE', 'LAC', 'MIN', 'NE', 'PIT',
                 'BAL', 'KC', 'OAK', 'PHI', 'CAR', 'IND', 'NYJ', 'SF')
    byes <- data.frame(bye_week, bye_team)
    byes$Year <- 2017
    byes$Bye <- 'Bye'
    
    byes_player <- merge(player_team, byes, by.x = 'Team', by.y = 'bye_team', all.x = TRUE)
}

# 2016
# ****************************

if(year == 2016) {
    player_team <- unique(stats[,c('playerID', 'Team', 'Pos')])
    
    bye_week <-c(4, 4, 5, 5, 5, 5, 6, 6, 7, 7, 8, 8, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12)
    bye_team <- c('PHI', 'GB', 'SEA', 'NO', 'KC', 'JAX', 'TB', 'MIN', 'DAL', 'CAR', 'SF', 'PIT', 'BAL',
                  'NYG', 'MIA', 'LAR', 'WAS', 'NE', 'HOU', 'CIN', 'CHI', 'ARI', 'OAK', 'IND', 'DET',
                  'BUF', 'SD', 'NYJ', 'DEN', 'ATL', 'TEN', 'CLE')
    byes <- data.frame(bye_week, bye_team)
    byes$Year <- 2016
    byes$Bye <- 'Bye'
    
    byes_player <- merge(player_team, byes, by.x = 'Team', by.y = 'bye_team', all.x = TRUE)
}

# 2015
# ****************************

if(year == 2015) {
    player_team <- unique(stats[,c('playerID', 'Team', 'Pos')])
    
    bye_week <-c(4, 4, 5, 5, 5, 5, 6, 6, 6, 6, 7, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 11, 11)
    bye_team <- c('NE', 'TEN', 'CAR', 'MIA', 'MIN', 'NYJ', 'DAL', 'OAK', 'STL', 'TB', 'CHI', 'CIN',
                  'DEN', 'GB', 'BUF', 'JAX', 'PHI', 'WAS','ARI', 'BAL', 'DET', 'HOU', 'KC', 'SEA', 
                  'ATL', 'IND', 'SD', 'SF', 'CLE', 'NO', 'NYG', 'PIT')
    byes <- data.frame(bye_week, bye_team)
    byes$Year <- 2015
    byes$Bye <- 'Bye'
    
    byes_player <- merge(player_team, byes, by.x = 'Team', by.y = 'bye_team', all.x = TRUE)
}

# 2014
# ****************************

if(year == 2014) {
    player_team <- unique(stats[,c('playerID', 'Team', 'Pos')])
    
    bye_week <- c(4, 4, 4, 4, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 10, 11, 11, 11, 11, 12, 12)
    bye_team <-c('ARI', 'CIN', 'CLE', 'DEN', 'SEA', 'STL', 'MIA', 'OAK', 'KC', 'NO', 'PHI', 'TB',
                 'NYG', 'SF', 'ATL', 'BUF', 'CHI', 'DET', 'GB', 'TEN', 'HOU', 'IND', 'MIN', 'NE',
                 'SD', 'WAS', 'BAL', 'DAL', 'JAX', 'NYJ', 'CAR', 'PIT')
    byes <- data.frame(bye_week, bye_team)
    byes$Year <- 2014
    byes$Bye <- 'Bye'
    
    byes_player <- merge(player_team, byes, by.x = 'Team', by.y = 'bye_team', all.x = TRUE)
}
# ***************************************
# Remove objects
# ***************************************

rm(bye_week)
rm(bye_team)
rm(byes)
rm(stats)
rm(player_team)
