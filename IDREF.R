## ************************************
## Script name: IDREF.R
## Purpose: Add player ID to Yahoo data for easier merging
## For: CreatingLineups.R
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-11
## ************************************
##
## Notes: 
##
##
##
## *************************************
  
# Rosters with Yahoo data names
source(paste0(file.location, 'CreateRosters.R'))

# Players with NFL data names
players <- read.csv(paste0(file.location, sprintf('Players_%g.csv', year)))

# Unique list of players who appeared on any manager's roster or draft
id_ref_roster <- setNames(data.frame(unique(roster[roster$Position != 'DEF',c('Player', 'Position')])), c('Player', 'Position'))
id_ref_draft <- setNames(data.frame(unique(drafts[which(drafts$Position != 'DEF'), c('Player', 'Position')])), c('Player', 'Position'))
id_ref <- setNames(unique(rbind(id_ref_roster, id_ref_draft)), c('Player', 'Position'))


# ***********************************************************
# Creating a name that's friendlier to the NFL data for merge
# ***********************************************************
# I'm adding a dot at the end to identify the suffix. Replacing the 'V'
#  for fifth-generation names was causing an error for names starting with it
id_ref$NFL_Name <- paste0(id_ref$Player, '_')

id_ref$NFL_Name <- gsub('Jr._', '', id_ref$NFL_Name)
id_ref$NFL_Name <- gsub('Sr._', '', id_ref$NFL_Name)
id_ref$NFL_Name <- gsub('IV_', '', id_ref$NFL_Name)
id_ref$NFL_Name <- gsub('V_', '', id_ref$NFL_Name)
id_ref$NFL_Name <- gsub('III_', '', id_ref$NFL_Name)
id_ref$NFL_Name <- gsub('II_', '', id_ref$NFL_Name)
id_ref$NFL_Name <- gsub('_', '', id_ref$NFL_Name)

id_ref$NFL_Name <- trimws(id_ref$NFL_Name, which = 'right', whitespace = ' ')

# **********************************************************
# Merge NFL data (players) with Yahoo data (id_ref)
# **********************************************************
# I'm merging with position because there were two Chris Thompson's in 2017
#  The Position field of the NFL data is cause for concern, however. 

id_ref <- merge(id_ref, players[ ,c('Player', 'GSIS_ID', 'Pos')], 
                by.x = c('NFL_Name', 'Position'), by.y = c('Player', 'Pos'), all.x = TRUE)

# ***********************************************************
# Players where NFL data name does not equal Yahoo data name
# ***********************************************************
#  I set the ID manually because the Yahoo name is what I 
#  want to keep

id_ref$GSIS_ID[id_ref$Player == 'Ben Watson'] <- '00-0022943' # Benjamin Watson
id_ref$GSIS_ID[id_ref$Player == 'DJ Moore'] <- '00-0034827' # D.J. Moore
id_ref$GSIS_ID[id_ref$Player == 'Michael Badgley'] <- '00-0034084' # Mike Badgley
id_ref$GSIS_ID[id_ref$Player == 'Daniel Herron'] <- '00-0029588' # Dan Herron
id_ref$GSIS_ID[id_ref$Player == 'Stevie Johnson'] <- '00-0026364' # Steve Johnson
id_ref$GSIS_ID[id_ref$Player == 'DJ Chark Jr.'] <- '00-0034777' # D.J. Chark
id_ref$GSIS_ID[id_ref$Player == 'Jaylen Samuels'] <- '00-0034331' # Issue with Position in 2018
id_ref$GSIS_ID[id_ref$Player == 'Ty Montgomery'] <- '00-0032200' # Issue with position in 2016

# ***********************************************************
# Remove the NFL data name & Position field
# ***********************************************************
id_ref <- id_ref[ ,which(names(id_ref) %!in% c('NFL_Name', 'Position'))]


# **********************************************************
# Add players who didn't make it into NFL roster data
# **********************************************************
# This seems to be an issue in the NFL data for players who did not finish
#   with a team. I am hardcoding them in.
# I am using week_stats to get their ID
id_ref$GSIS_ID[id_ref$Player == 'Kenjon Barner'] <- '00-0030465'
id_ref$GSIS_ID[id_ref$Player == 'Brandon Marshall'] <- '00-0024334'
id_ref$GSIS_ID[id_ref$Player == 'Robert Griffin III'] <- '00-0029665'
id_ref$GSIS_ID[id_ref$Player == 'Ben Tate'] <- '00-0027890'
id_ref$GSIS_ID[id_ref$Player == 'Charles Johnson'] <- '00-0030113'
id_ref$GSIS_ID[id_ref$Player == 'Donte Moncrief'] <- '00-0031339'


# *************************************************************
# Adding Team and Adjusting for midseason trades
# *************************************************************
# This is used for counting the number of times a manager has drafted from
#  a specific NFL team. Therefore, I am only concerned about the NFL team a player
#  was on at the beginning of the season
# This list does not include all trades

id_ref <- merge(id_ref, players[ ,c('GSIS_ID', 'Team')], by = 'GSIS_ID', all.x = TRUE)

id_ref$Team[id_ref$Team == 'LA'] <- 'LAR'
id_ref$Team[id_ref$Team == 'JAC'] <- 'JAX'
id_ref$Team[id_ref$Team == 'SD'] <- 'LAC'
id_ref$Team[id_ref$Team == 'STL'] <- 'LAR'

if(year == 2019){
  id_ref$Team[id_ref$Player == 'A.J. Green'] <- 'CIN' # Never played
  id_ref$Team[id_ref$Player == 'Kenyan Drake'] <- 'MIA' # trade
  id_ref$Team[id_ref$Player == 'Emmanuel Sanders'] <- 'DEN' # trade
  id_ref$Team[id_ref$Player == 'Mohamed Sanu'] <- 'ATL' # trade
  id_ref$Team[id_ref$Player == 'Zay Jones'] <- 'BUF' # trade
  id_ref$Team[id_ref$Player == 'Nick Vannett'] <- 'SEA' # trade
  id_ref$Team[id_ref$Player == 'Trevor Davis'] <- 'GB' # trade
  id_ref$Team[id_ref$Player == 'Demaryius Thomas'] <- 'NE' # trade
  id_ref$Team[id_ref$Player == 'Carlos Hyde'] <- 'KC' # trade
  id_ref$Team[id_ref$Player == 'Donte Moncrief'] <- 'PIT' # released
}

if(year == 2018){
  id_ref$Team[id_ref$Player == 'Jerick McKinnon'] <- 'SF' # never played
  id_ref$Team[id_ref$Player == 'Le\'Veon Bell'] <- 'PIT' # never played
  id_ref$Team[id_ref$Player == 'Brandon Marshall'] <- 'SEA' # released
  id_ref$Team[id_ref$Player == 'Kenjon Barner'] <- 'CAR' # released
  id_ref$Team[id_ref$Player == 'Ty Montgomery'] <- 'GB' # trade
  id_ref$Team[id_ref$Player == 'Golden Tate'] <- 'DET' # trade
  id_ref$Team[id_ref$Player == 'Demaryius Thomas'] <- 'DEN' # trade
  id_ref$Team[id_ref$Player == 'Amari Cooper'] <- 'OAK' # trade
  id_ref$Team[id_ref$Player == 'Carlos Hyde'] <- 'CLE' # trade
  id_ref$Team[id_ref$Player == 'Josh Gordon'] <- 'CLE' # trade
}

if(year == 2017){
  id_ref$Team[id_ref$Player == 'Andrew Luck'] <- 'IND' # Never played
  id_ref$Team[id_ref$Player == 'Cameron Meredith'] <- 'CHI' # Never Played
  id_ref$Team[id_ref$Player == 'Julian Edelman'] <- 'NE' # Never played
  id_ref$Team[id_ref$Player == 'Sebastian Janikowski'] <- 'OAK' # Released
  id_ref$Team[id_ref$Player == 'Malcolm Mitchell'] <- 'NE' # Released
  id_ref$Team[id_ref$Player == 'Spencer Ware'] <- 'KC' # Never played
  id_ref$Team[id_ref$Player == 'Kelvin Benjamin'] <- 'CAR' # traded
  id_ref$Team[id_ref$Player == 'Jay Ajayi'] <- 'MIA' # traded
  id_ref$Team[id_ref$Player == 'Dontrelle Inman'] <- 'LAC' # traded
  id_ref$Team[id_ref$Player == 'Adrian Peterson'] <- 'NO' # traded
  id_ref$Team[id_ref$Player == 'Jacoby Brissett'] <- 'NE' # traded
  id_ref$Team[id_ref$Player == 'Phillip Dorsett II'] <- 'IND' # traded
  id_ref$Team[id_ref$Player == 'Jermaine Kearse'] <- 'SEA' # traded
}

if(year == 2016){
  id_ref$Team[id_ref$Player == 'Shayne Graham'] <- 'ATL' # released
  id_ref$Team[id_ref$Player == 'Josh Gordon'] <- 'CLE' # never played
  id_ref$Team[id_ref$Player == 'Knile Davis'] <- 'KC' # trade
  id_ref$Team[id_ref$Player == 'Jeremy Kerley'] <- 'SF' # trade
  id_ref$Team[id_ref$Player == 'Sam Bradford'] <- 'PHI' # trade
}

if(year == 2015){
  id_ref$Team[id_ref$Player == 'Victor Cruz'] <- 'NYG' # never played
  id_ref$Team[id_ref$Player == 'Vernon Davis'] <- 'SF' # trade
}

if(year == 2014){
  id_ref$Team[id_ref$Player == 'Ben Tate'] <- 'CLE' # release
  id_ref$Team[id_ref$Player == 'Ray Rice'] <- 'BAL' # never played
  id_ref$Team[id_ref$Player == 'Percy Harvin'] <- 'SEA' # trade
}

# **********************************************************
# Check for bugs
# *********************************************************

cat('These players were on rosters but didnt show up in NFL data. Their name may be different in the \n
    two databases or they may have been released and aren\'t showing up in NFL data. Use week_stats for their id \n
    Or make sure they just didnt record any stats in', year, '\n')
print(id_ref[which(is.na(id_ref$GSIS_ID)), ])


# ********************************************
# Remove objects
# *********************************************

rm(players)
rm(id_ref_draft)
rm(id_ref_roster)