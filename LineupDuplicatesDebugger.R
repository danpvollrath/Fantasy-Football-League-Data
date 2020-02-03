## ************************************
## Script name: LineupDuplicatesDebugger.R
## Purpose: To help look at multi-lineup possibilities
##  and decide which one was likely started
## For: Fantasy Football project
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-25
## ************************************
##
## Notes: 
##
##
##
## *************************************
  
week <- 5
manager <- 'Spencer'
ord <- c('QB', 'WR', 'RB', 'TE', 'K', 'DEF')
sr <- starting_rosters[which(starting_rosters$Manager == manager & starting_rosters$Week == week) ,
                       c('Player', 'Manager', 'Week', 'Position', 'Acquired', 'Round_Drafted', 'fp', 
                         'RecordedStat', 'Bye', 'LineupPossibility', 'NumStarts')]

sr <- sr[order(match(sr$Position, ord)), ]
sr <- sr[with(sr, order(sr$LineupPossibility, decreasing = FALSE)), ]

sr <- sr %>% group_by(Player) %>% mutate(NumOccurences = n())
sr <- sr[which(sr$NumOccurences < max(sr$LineupPossibility)), ]

for(y in 1:max(sr$LineupPossibility)){
  cat('Option:', y, '\n')
  print(data.frame(sr[which(sr$LineupPossibility == y), ]))
}

