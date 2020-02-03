## ************************************
## Script name: CreateRoster.R
## Purpose: Creating a list of players on a roster each week
## For: Fantasy Football Dashboard
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-05
## ************************************
##
## Notes: Yahoo transaction data and draft data was downloaded using copy-paste from the league page
## There may be an API to automate this process, but I don't know how to do it.
##
##
## *************************************

options(stringsAsFactors = FALSE)
  
source(paste0(file.location, 'CleanDrafts.R')) 
source(paste0(file.location, 'CleanTransactions.R')) 
source(paste0(file.location, 'Schedule.R')) 

sched <- sched[which(sched$Year == year), ]

# **********************
# Set initial roster
# **********************

roster <- drafts[ ,c("Manager", "Player", "Position")]


# ***************************
# Create Rosters
# **************************

for(w in 1:numWeeks){
  #previous week
  x <- w-1
  
  if(w > 1){ 
    newroster <- roster[which(roster$Week == x), ]} else{
      newroster <- roster
    }
  newroster$Week <- w
  newtrans <- trans[which(trans$Date <= sched$Monday_Game_Date[sched$Week == w] & 
                            trans$Date > sched$Monday_Game_Date[sched$Week == x]), ]
  newtrans$Week <- w
  
  # Get the most recent transaction
  # This is used in case a manager added and dropped a player after adding within week
  newtrans <- newtrans[with(newtrans, order(Date, Time, Transaction_Type, decreasing = TRUE)), ]
  newtrans <- newtrans[!duplicated(newtrans[c("Manager", "Player")], fromLast = FALSE), ]
  
  
  ## Drops/Trades From
  newroster <- merge(newroster, 
                     newtrans[which(newtrans$Transaction_Type == "Drop" | newtrans$Transaction_Type == "Trade From"), 
                              c("Manager", "Player", "Position", "Transaction_Type")], 
                     by = c("Manager", "Player", "Position"), all.x = TRUE)
  
  newroster <- newroster[which(is.na(newroster$Transaction_Type)), ]
  
  ## Adds/Trades To
  newroster <- rbind(newroster,
                     newtrans[which(newtrans$Transaction_Type == "Add" | newtrans$Transaction_Type =="Trade To"), 
                              c("Manager", "Player", "Position", "Transaction_Type", "Week")])
  
  newroster <- newroster[(!duplicated(newroster[c("Manager", "Player")])), ]
  
  # Drop Transaction_Type field
  newroster <- newroster[ ,which(names(newroster) != 'Transaction_Type')]
  
  # If week 1, set roster to newroster. Else, append newroster to roster
  if(w == 1){
    roster <- newroster} else{
      roster <- rbind(roster, newroster)  
    }
  
}


# **************************************
# Add info about how player was aquired
# **************************************

# Drafted
# *********************************************
drafts$Drafted <- "Drafted"

roster <- merge(roster, drafts[ ,c('Player', 'Manager','Drafted', 'Round')],
                          by = c('Player', 'Manager'), all.x = TRUE)
colnames(roster)[colnames(roster) == 'Round'] <- 'Round_Drafted'

# Added/Traded To
# ***********************************************
added <- trans[which(trans$Transaction_Type %in% c('Add', 'Trade To')), ]
added <- added[with(added, order(Date, Time, decreasing = TRUE)), ]
added <- added[!duplicated(added[ ,c('Manager', 'Player')], fromLast = FALSE), ]

roster <- merge(roster, added[ ,c('Manager', 'Player', 'Transaction_Type')],
                by = c('Manager', 'Player'), all.x = TRUE)

# If the player was drafted by the manager, use that, otherwise use last Transaction_Type
#  If player was drafted, dropped, and added by same manager, show them as drafted
roster$Acquired <- roster$Drafted
roster$Acquired[is.na(roster$Acquired)] <- roster$Transaction_Type[is.na(roster$Acquired)]


# Add Year, remove Fields
# ***********************************
roster$Year <- year
roster <- roster[ ,which(names(roster) %!in% c('Drafted', 'Transaction_Type'))]

# *************************************
# Remove Objects
# *************************************
rm(trans)
rm(newtrans)
rm(newroster)
rm(sched)
rm(added)
rm(w)
rm(x)


