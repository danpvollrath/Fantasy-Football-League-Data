## ************************************
## Script name: CleanMatchups.R
## Purpose: Clean Raw Matchup File
## For: Fantasy Football Project
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-16
## ************************************
##
## Notes: 
##
##
##
## *************************************
  
  
matchups.raw <- read.csv(paste0(file.location, "Matchups_Raw.csv"), fileEncoding = "UTF-8-BOM")
teams.raw <- read.csv(paste0(file.location, "Teams_Raw.csv"), fileEncoding = "UTF-8-BOM")


# ****************************************************
# Create field for manager's score and opponent score
# ****************************************************

matchups.raw$Score <- substr(matchups.raw$Matchup, 1, str_locate(matchups.raw$Matchup, '-') -1)
matchups.raw$Opponent_Score <- substr(matchups.raw$Matchup, 
                             str_locate(matchups.raw$Matchup, '-') + 2,
                             nchar(matchups.raw$Matchup))
matchups.raw <- matchups.raw[ ,which(names(matchups.raw) != 'Matchup')]

matchups.raw$Score <- as.double(matchups.raw$Score)
matchups.raw$Opponent_Score <- as.double(matchups.raw$Opponent_Score)


# ******************************************
# Create binary win field
# ******************************************

matchups.raw$Win <- ifelse(matchups.raw$Outcome == 'Win', 1, 0)


# ************************************************************
# Create total score field of total points scored in matchup
# ************************************************************

matchups.raw$Total_Score <- matchups.raw$Score + matchups.raw$Opponent_Score

# ***************************************
# Turning Week into a week number field
# ***************************************

# First Playoff Round
matchups.raw$Week_Num <- ifelse(matchups.raw$Week %in% c('Playoffs Qtr', 'Consolation Qtr'), 14, NA)
# Second Playoff Round
matchups.raw$Week_Num <- ifelse(matchups.raw$Week %in% c('Playoffs Semi', 'Playoffs 5th',
                                                         'Consolation Semi', 'Consolation 11th'),
                                15, matchups.raw$Week_Num)
# Third Playoff Round (if needed)
matchups.raw$Week_Num <- ifelse(matchups.raw$Week %in% c('Playoffs Champ', 'Playoffs 3rd',
                                                         'Consolation Champ', 'Consolation 9th'),
                                16, matchups.raw$Week_Num)
# Regular Season
matchups.raw$Week_Num <- ifelse(is.na(matchups.raw$Week_Num), matchups.raw$Week, matchups.raw$Week_Num)

# Format Week_Num
matchups.raw$Week_Num <- as.integer(matchups.raw$Week_Num)


# *******************************************
# Create Regular Season vs Post Season Field
# *******************************************
matchups.raw$Season <- ifelse(matchups.raw$Week_Num < 14, 'Regular Season', 'Post Season')

# *******************************************
# Adding Manager and Opponent Manager fields
# *******************************************
matchups.raw <- merge(matchups.raw, teams.raw, by = c('Manager_Team', 'Year'), all.x = TRUE)
matchups.raw <- merge(matchups.raw, setNames(teams.raw, c('Manager_Team', 'Opponent_Manager', 'Year')),
                      by.x = c('Opponent_Manager_Team', 'Year'), by.y = c('Manager_Team', 'Year'), all.x = TRUE)



# ***************************************
# Final Object, remove others
# ***************************************

matchups <- matchups.raw
write.csv(matchups, paste0(file.location, 'Matchups.csv'), row.names = FALSE)

rm(matchups.raw)
rm(teams.raw)
 