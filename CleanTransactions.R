## ************************************
## Script name: CreateTransactions.R
## Purpose: Create the Transactions data set
## For: Fantasy Football Dashboard
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-13
## ************************************
##
## Notes: 
##
##
##
## *************************************

trans.raw <- read.csv(paste0(file.location, "Transactions_Raw.csv"), fileEncoding = "UTF-8-BOM")
teams <- read.csv(paste0(file.location, "Teams_Raw.csv"), fileEncoding = "UTF-8-BOM")

trans.raw <- trans.raw[which(trans.raw$Year == year), ]
teams <- teams[which(teams$Year == year), ]

# ******************************
# Format variables
# ******************************
# Remove these player note tags and the NA tag for currently inactive players
# ****************************************************************************
trans.raw$Player <- str_remove_all(trans.raw$Player, '\n')
trans.raw$Player <- str_remove_all(trans.raw$Player, 'No new player Notes')
trans.raw$Player <- str_remove_all(trans.raw$Player, 'New Player Note')
trans.raw$Player <- str_remove_all(trans.raw$Player, 'Player Note')
trans.raw$Player <- str_remove_all(trans.raw$Player, 'NA')


# *******************************
# Clean trade rows
# *******************************
#  Trade rows are the only ones that give us a problem
#  They are 1 row per player. But we need one row for each transaction
#  ie one row for the manager trading a player away, one row for the manager
#  getting the player

# Downfilling columns Date and Transaction_Type because they only have 1 value per trade
# **************************************************************************************
trans.raw$Date[trans.raw$Date == ''] <- NA
trans.raw$Transaction_Type[trans.raw$Transaction_Type == ''] <- NA
trans.raw <- trans.raw %>% fill(Date, .direction = 'down')
trans.raw <- trans.raw %>% fill(Transaction_Type, .direction = 'down')

# Remove vetoed trades
# **************************
trans.raw <- trans.raw[which(trans.raw$Transaction_Type != 'Trade (vetoed)'), ]

# Create one record per player traded
# Turning rows with multiple players into separate rows
# Creating two rows for each player traded, going in both directions
# ***********************
trades_to <- trans.raw[which(trans.raw$Transaction_Type == 'Trade'), ]
trades_to$NumPlayers <- str_count(trades_to$Player, '\\)')

if(nrow(trades_to) > 0){
  i <- 1
  while(max(trades_to$NumPlayers) > 1){
    if(trades_to$NumPlayers[i] > 1){
      # Split fields with muliple players into two records
      a <- trades_to[i, ]
      a$Player[1] <- substr(a$Player[1], 1, str_locate(a$Player[1], '\\)'))
      b <- trades_to[i, ]
      b$Player[1] <- substr(b$Player[1], str_locate(b$Player[1], '\\)') + 1, nchar(b$Player[1]))
      # Drop previous record
      trades_to <- trades_to[-i, ]
      # Add new records to dataframe
      trades_to <- rbind(trades_to, a, b)
      # Recalculate the NumPlayers field
      trades_to$NumPlayers <- str_count(trades_to$Player, '\\)')
    }
    # If we've reached the botton, start over (used for trades_to with >2 players going one direction)
    if((i+1) > nrow(trades_to)){
      i <- 1} else{i <- i + 1}
  }
  
  # Drop NumPlayers field
  trades_to <- trades_to[ ,names(trades_to) != 'NumPlayers'] 
  
  # Signify that these are trades TO a team
  trades_to$Transaction_Type <- "Trade To"
  
  # Create records of trades from a team
  # ************************************
  trades_from <- trades_to
  trades_from$Transaction_Type <- "Trade From"
  
  
  # Add trades_to and trades_from to adds and drops
  # ************************************************
  trans.raw <- trans.raw[which(trans.raw$Transaction_Type != 'Trade'), ]
  trans.raw <- rbind(trans.raw, trades_to, trades_from)
}

# *************************
# Create Manager Field
# *************************

# Create 'Team_Manager' field
#*************************
trans.raw$Manager_Team[trans.raw$Transaction_Type %in% c('Add', 'Trade To')] <- 
  trans.raw$To[trans.raw$Transaction_Type %in% c('Add', 'Trade To')]
trans.raw$Manager_Team[trans.raw$Transaction_Type %in% c('Drop', 'Trade From')] <- 
  trans.raw$From[trans.raw$Transaction_Type %in% c('Drop', 'Trade From')]

# Add in 'Manager' field
# *****************************
trans.raw <- merge(trans.raw, teams[ ,c('Manager_Team', 'Manager')], 
                   by = 'Manager_Team', all.x = TRUE)


# ***************************************
# Format Date field 
# ****************************************

# Create Time 
trans.raw$Time <- format(as.POSIXct(strptime(trans.raw$Date, format = '%b %d %I:%M %p', tz = "")), format = "%H:%M")

# Create Date
trans.raw$Date <- as.Date(paste(year,
    month(as.POSIXlt(trans.raw$Date, format = '%b %d %I:%M %p')),
    day(as.POSIXlt(trans.raw$Date, format = '%b %d %I:%M %p')), sep = '-'))


# ********************************
# Clean up 'Player' field
# ********************************
# Splitting field into three columns: Player, Team, Position
# ***********************************************************
trans.raw$tmp <- substr(trans.raw$Player, str_locate(trans.raw$Player, '\\('), nchar(trans.raw$Player))
trans.raw$Player <- substr(trans.raw$Player, 1, str_locate(trans.raw$Player, '\\(') - 1)
trans.raw$Position <- substr(trans.raw$tmp, 
                              str_locate(trans.raw$tmp, '-') + 2, 
                              str_locate(trans.raw$tmp, '\\)') - 1)
trans.raw$Team <- substr(trans.raw$tmp, 2, str_locate(trans.raw$tmp, '-') - 2)
trans.raw <- trans.raw[ ,which(names(trans.raw) != 'tmp')]


# Updating the Player name for defenses so they are unique
# **********************************************************
trans.raw$Player[trans.raw$Position == "DEF"] <- 
  paste0(trans.raw$Player[trans.raw$Position == "DEF"], " (", trans.raw$Team[trans.raw$Position == "DEF"], ")")


# ****************************
# Drop unneeded fields
# ****************************
trans.raw <- trans.raw[ ,names(trans.raw) %!in% c('To', 'From', 'Manager_Team', 'Yahoo.Name')]


# *******************************
# Rename data set, drop objects
# ******************************
trans <- trans.raw
rm(trans.raw)
rm(teams)
if(nrow(trades_to) > 0){
  rm(trades_from)
  rm(a)
  rm(b)
}
rm(trades_to)
