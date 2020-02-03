## ************************************
## Script name: GetSeason.R
## Purpose: Get a season of information using other project files
## For: Fantasy Football Project
## Location: Documnets.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-15
## ************************************
##
## Notes: 
##
##
##
## *************************************

options(stringsAsFactors = FALSE)

library(dplyr)
library(stringr)
library(tidyr)
library(lubridate)
library(devtools)
library(nflscrapR)
library(httr)
library(reshape)

'%!in%' <- function(x,y)!('%in%'(x,y))

numWeeks <- 16 # number of weeks the league plays
rosterSize <- 14 # number of spots on a team (including bench)
firstYear <- 2014 # first season of data we are using
lastYear <- 2019 # last season of data we are using

# number of managers in a league each year
leagueSizeTbl <- data.frame('Year' = 2014:2019, 'Size' = c(10, 10, 12, 12, 12, 12))

# The location of all R and raw files
file.location <- "C:/Users/danpv/OneDrive/Documents/Fantasy Football Project/"


# ************************************************************
# Create Stats
# ************************************************************

# Run CreateStats.R for each year
# I had to go back and update some player's stats when getting errors
#  in CreateLineups.R. Those updates are in the code but will likely need
#  to be added to as this is run for different leagues. If there was a 
#  problem with a player's stats but that player wasn't started in my league
#  that week, I wouldn't have gotten an error. 

# *************************************************************
# Creating Matchups.csv, Drafts.csv
# *************************************************************

# Create Matchups.csv, creates file with all years
# This gets used by CreateLineups.R, CreateTeams.R
source(paste0(file.location, 'CleanMatchups.R'))


for(year in firstYear:lastYear){
  
  # Create Drafts
  source(paste0(file.location, 'CreateDrafts.R'))
  
  
  if(year == firstYear){
    drafts_final <- drafts
    rosters_final <- roster
  }else{
    drafts_final <- rbind(drafts_final, drafts)
    rosters_final <- rbind(rosters_final, roster)
  }
  
}


# **********************************************************
# Creating Starting_Rosters.csv
# *********************************************************
# Run CreateLineups.R for each season until you have all
#  the StartingRosters_YYYY.csv files saved
#  That process takes a lot of data cleaning and manual
#  processing

starting_roster_final <- rbind(read.csv(paste0(file.location, 'StartingRosters_2019.csv')),
                               read.csv(paste0(file.location, 'StartingRosters_2018.csv')),
                               read.csv(paste0(file.location, 'StartingRosters_2017.csv')),
                               read.csv(paste0(file.location, 'StartingRosters_2016.csv')))

# *********************************************************
# Create Teams.csv
#**********************************************************
for(year in 2016:2019){
  
  source(paste0(file.location, 'CreateTeams.R'))
  
  if(year == 2016){
    teams_final <- teams
  }else{
    teams_final <- rbind(teams_final, teams)
  }
  
}

# Create Average Points & Rank by Position Across All Years
# **********************************************************

pospts <- starting_roster_final %>% group_by(Manager, Position) %>% summarize(AllTime_Pos_Points = mean(fp))
pospts <- cast(pospts, Manager~Position, sum, value = 'AllTime_Pos_Points')

colnames(pospts) <- paste0('AllTime_', colnames(pospts), '_pts')

teams_final <- merge(teams_final, pospts, by.x = 'Manager', by.y = 'AllTime_Manager_pts', all.x = TRUE)

ranksqb <- teams_final %>%  group_by(Manager) %>% summarize(AllTime_QB_rank = mean(AllTime_QB_pts))
ranksqb <- ranksqb %>% mutate(AllTime_QB_rank = rank(desc(AllTime_QB_rank)))
ranksrb <- teams_final %>%  group_by(Manager) %>% summarize(AllTime_RB_rank = mean(AllTime_RB_pts))
ranksrb <- ranksrb %>% mutate(AllTime_RB_rank = rank(desc(AllTime_RB_rank)))
rankswr <- teams_final %>%  group_by(Manager) %>% summarize(AllTime_WR_rank = mean(AllTime_WR_pts))
rankswr <- rankswr %>% mutate(AllTime_WR_rank = rank(desc(AllTime_WR_rank)))
rankste <- teams_final %>%  group_by(Manager) %>% summarize(AllTime_TE_rank = mean(AllTime_TE_pts))
rankste <- rankste %>% mutate(AllTime_TE_rank = rank(desc(AllTime_TE_rank)))
ranksk <- teams_final %>%  group_by(Manager) %>% summarize(AllTime_K_rank = mean(AllTime_K_pts))
ranksk <- ranksk %>% mutate(AllTime_K_rank = rank(desc(AllTime_K_rank)))
ranksdef <- teams_final %>%  group_by(Manager) %>% summarize(AllTime_DEF_rank = mean(AllTime_DEF_pts))
ranksdef <- ranksdef %>% mutate(AllTime_DEF_rank = rank(desc(AllTime_DEF_rank)))

ranks <- merge(ranksqb, ranksrb, by = 'Manager', all.x = TRUE)
ranks <- merge(ranks, rankswr, by = 'Manager', all.x = TRUE)
ranks <- merge(ranks, rankste, by = 'Manager', all.x = TRUE)
ranks <- merge(ranks, ranksk, by = 'Manager', all.x = TRUE)
ranks <- merge(ranks, ranksdef, by = 'Manager', all.x = TRUE)

teams_final <- merge(teams_final, ranks, by = 'Manager', all.x = TRUE)



# ***********************************************************
# Save Final Data Sets !!!
# ***********************************************************
write.csv(matchups, paste0(file.location, 'Matchups.csv'), row.names = FALSE)
write.csv(drafts_final, paste0(file.location, 'Drafts.csv'), row.names = FALSE)
write.csv(teams_final, paste0(file.location, 'Teams.csv'), row.names = FALSE)
write.csv(starting_roster_final, paste0(file.location, 'Starting_Rosters.csv'), row.names = FALSE)
