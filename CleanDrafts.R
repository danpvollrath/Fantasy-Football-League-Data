## ************************************
## Script name: CleanDrafts.R
## Purpose: Clean up raw drafts file
## For: Fantasy Football Project
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-15
## ************************************
##
## Notes: I think Jaylen Samuels 2018 position
##  might cause a problem
##
##
## *************************************
  
options(stringsAsFactors = FALSE)

drafts.raw <- read.csv(paste0(file.location, "Drafts_Raw.csv"), fileEncoding = "UTF-8-BOM")
teams <- read.csv(paste0(file.location, "Teams_Raw.csv"), fileEncoding = "UTF-8-BOM")

drafts.raw <- drafts.raw[which(drafts.raw$Year == year), ]
teams <- teams[which(teams$Year == year), ]


# *****************************************
# Add round, pick number
# ***************************************

# Add Pick
# ****************************
# Your raw data file must be in order for this to work
drafts.raw$Pick <- 1:nrow(drafts.raw)


# Add Round
# ****************************
drafts.raw$Round <- ceiling(drafts.raw$Pick / leagueSizeTbl$Size[leagueSizeTbl$Year == year])


# *************************************************
# Add 'Manager' field to drafts data set
# *************************************************

# Cleanup 'Manager_Team' field from Yahoo
# ****************************************
# The Yahoo field shortens long team names, leaving a '...' at the end
# This code uses the first 10 characters of a manager's team name
# If 2 managers have the same team name through 10 characters, this won't work

drafts.raw$Manager_Team <- substr(drafts.raw$Manager_Team, 1, 10)
teams$Manager_Team <- substr(teams$Manager_Team, 1, 10)

# Add Manager to drafts
# *******************************
drafts.raw <- merge(drafts.raw, teams[ ,c('Manager_Team', 'Manager')],
                    by = 'Manager_Team', all.x = TRUE)

# Remove Team_Manager field now that we don't need it
drafts.raw <- drafts.raw[ ,which(names(drafts.raw) != 'Manager_Team')]


# ********************************
# Clean up 'Player' field
# ********************************
# Splitting field into three columns: Player, Position
# ***********************************************************

drafts.raw$tmp <- substr(drafts.raw$Player, str_locate(drafts.raw$Player, '\\('), nchar(drafts.raw$Player))
drafts.raw$Player <- substr(drafts.raw$Player, 1, str_locate(drafts.raw$Player, '\\(') - 1)
drafts.raw$Position <- substr(drafts.raw$tmp, 
                              str_locate(drafts.raw$tmp, '-') + 2, 
                              str_locate(drafts.raw$tmp, '\\)') - 1)
drafts.raw$Team <- substr(drafts.raw$tmp,
                          str_locate(drafts.raw$tmp, '\\(') + 1,
                          str_locate(drafts.raw$tmp, '-') - 2)

drafts.raw <- drafts.raw[ ,which(names(drafts.raw) != 'tmp')]


# Updating the Player name for defenses so they are unique
# **********************************************************
drafts.raw$Player[drafts.raw$Position == "DEF"] <- 
  paste0(drafts.raw$Player[drafts.raw$Position == "DEF"], " (", drafts.raw$Team[drafts.raw$Position == "DEF"], ")")


# ****************************
# Add Position Pick
# ****************************
pos <- unique(drafts.raw$Position)

# Adds Position Pick
drafts.raw <- drafts.raw %>% group_by(Position) %>% 
  mutate(Position_Pick = order(order(Round, Pick, decreasing = FALSE)))


# **********************************
# Removing the Team field
# **********************************
# I'm removing the Team field because it represents a player's current
# team. Instead, I am bringing that in from IDREF in CreateDrafts.R
drafts.raw <- drafts.raw[ ,which(names(drafts.raw) != 'Team')]


# ***********************************
# Rename result, remove Objects
# ***********************************
drafts <- drafts.raw
rm(teams)
rm(pos)
rm(drafts.raw)
