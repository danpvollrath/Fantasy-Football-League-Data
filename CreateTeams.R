## ************************************
## Script name: CreateScoreRank.R
## Purpose: Create the Score Rank data set for Tableau
## For: Fantasy Football Project
## Location:Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-12
## ************************************
##
## Notes: 
##
##
##
## *************************************
  
matchups <- read.csv(paste0(file.location, 'Matchups.csv'), fileEncoding = "UTF-8-BOM")
starting_rosters <- read.csv(paste0(file.location, sprintf('StartingRosters_%g.csv', year)), fileEncoding = "UTF-8-BOM")
teams <- read.csv(paste0(file.location, 'Teams_Raw.csv'), fileEncoding = "UTF-8-BOM")
rivals <- read.csv(paste0(file.location, 'Rivals_Raw.csv'), fileEncoding = "UTF-8-BOM")
  
matchups <- matchups[which(matchups$Year == year), ]
teams <- teams[which(teams$Year == year), ]

leagueSize <- leagueSizeTbl$Size[leagueSizeTbl$Year == year]


# **********************************
# Final Result 
# **********************************

teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Playoffs Champ' & matchups$Outcome == 'Win']] <- 1
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Playoffs Champ' & matchups$Outcome == 'Loss']] <- 2
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Playoffs 3rd' & matchups$Outcome == 'Win']] <- 3
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Playoffs 3rd' & matchups$Outcome == 'Loss']] <- 4
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Playoffs 5th' & matchups$Outcome == 'Win']] <- 5
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Playoffs 5th' & matchups$Outcome == 'Loss']] <- 6
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Consolation Champ' & matchups$Outcome == 'Win']] <- 7
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Consolation Champ' & matchups$Outcome == 'Loss']] <- 8
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Consolation 9th' & matchups$Outcome == 'Win']] <- 9
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Consolation 9th' & matchups$Outcome == 'Loss']] <- 10
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Consolation 11th' & matchups$Outcome == 'Win']] <- 11
teams$Finish[teams$Manager == matchups$Manager[matchups$Week == 'Consolation 11th' & matchups$Outcome == 'Loss']] <- 12


# **********************************
# Reg Season Points and Points Finish
# **********************************

ptstbl <- matchups %>% group_by(Manager) %>% filter(Week_Num <= 13) %>% summarize(Season_Points = sum(Score))

ptstbl <- ptstbl[with(ptstbl, order(Season_Points, decreasing = TRUE)), ]
ptstbl$Points_Finish <- 1:leagueSize 

teams <- merge(teams, ptstbl, by = 'Manager', all.x = TRUE)


# **********************************
# Regular Season Finish 
# **********************************

winstbl <- matchups %>% group_by(Manager) %>% filter(Week_Num <= 13 & Outcome == 'Win') %>% summarize(Wins = n())
teams <- merge(teams, winstbl, by = 'Manager', all.x = TRUE)

teams <- teams[with(teams, order(Wins, Season_Points, decreasing = TRUE)), ]
teams$Regular_Season_Finish <- 1:leagueSize


# **********************************
# Positional Finishes
# **********************************

# Sum points by positon, cast long to wide
pospts <- starting_rosters %>% group_by(Manager, Position) %>% summarize(Season_Pos_Points = sum(fp))
pospts <- cast(pospts, Manager~Position, sum, value = 'Season_Pos_Points')

colnames(pospts) <- paste0(colnames(pospts), '_pts')

teams <- merge(teams, pospts, by.x = 'Manager', by.y = 'Manager_pts', all.x = TRUE)

# Position Points Rank
teams <- teams %>% mutate(QB_rank = rank(desc(QB_pts), ties.method = 'min'))
teams <- teams %>% mutate(RB_rank = rank(desc(RB_pts), ties.method = 'min'))
teams <- teams %>% mutate(WR_rank = rank(desc(WR_pts), ties.method = 'min'))
teams <- teams %>% mutate(TE_rank = rank(desc(TE_pts), ties.method = 'min'))
teams <- teams %>% mutate(K_rank = rank(desc(K_pts), ties.method = 'min'))
teams <- teams %>% mutate(DEF_rank = rank(desc(DEF_pts), ties.method = 'min'))

# **********************************
# Adding Rival info
# **********************************
teams <- merge(teams, rivals, by = 'Manager', all.x = TRUE)


# *********************************
# Adding Medal
# *********************************
# This is used for a visualization in Tableau

teams$Medal[teams$Finish == 1] <- 'Gold'
teams$Medal[teams$Finish == 2] <- 'Silver'
teams$Medal[teams$Finish == 3] <- 'Bronze'
teams$Medal[teams$Finish == leagueSize] <- 'Toilet'


# ***************************************
# Remove objects
# **************************************
rm(matchups)
rm(starting_rosters)
rm(rivals)
rm(pospts)
rm(winstbl)
