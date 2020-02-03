## ************************************
## Script name: CreatingLineups.R
## For: Setting who was in starting lineup each week
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-11
## ************************************
##
## Notes: 
## - I could not find a downloadable data set with fantasy points
## for DST so I manually created one from fantasydata.com
## To save time, I only added scores for rostered DST's each week
## - The 'matchup' data set came from copy/pasting league data out of Yahoo.
## It's fairly easy when on the historic league data site but can be a pain
## for current season.
##
## *************************************

year <- 2015

options(stringsAsFactors = FALSE)

def_stats <- read.csv(paste0(file.location, 'DefScores_Raw.csv')) 
week_stats <- read.csv(paste0(file.location, sprintf('WeekStats_%g.csv', year)))
matchups <- read.csv(paste0(file.location, 'Matchups.csv'))
source(paste0(file.location,'IDREF.R'))
source(paste0(file.location, 'ByeWeeks.R'))


def_stats <- def_stats[which(def_stats$Year == year), ]
matchups <- matchups[which(matchups$Year == year), ]

## ***************************************
## Create data sets ----
## ***************************************

# Add weekly fantasy point data to manager roster
# ***********************************************

# Add IDs to Yahoo data
roster <- merge(roster, id_ref, by = 'Player', all.x = TRUE)

# Merge fantasy points with weekly roster
roster <- merge(roster, week_stats[ , c('playerID', 'Week', 'fp')], 
                by.x = c('GSIS_ID', 'Week'), by.y = c('playerID', 'Week'), all.x = TRUE)

# If a player was in week_stats. This was meant to help identify which starting lineup
#  was likely but doesn't seem useful. Targets don't appear in week_stats
roster$RecordedStat <- ifelse(is.na(roster$fp), 'No Stat Recorded', 'Recorded Stat')

# Turn NA's to 0
roster$fp[is.na(roster$fp)] <- 0

# Add defense stats data set to manager roster
# *********************************************

# Merge Defense scores with roster data set
roster <- merge(roster, def_stats[ ,c('Player', 'Week', 'Score')], by = c('Player', 'Week'), all.x = TRUE)

# Combine def scores w other scores
roster$fp <- rowSums(roster[ ,c('fp', 'Score')], na.rm = TRUE)
roster <- roster[ , -which(names(roster) == 'Score')]


# ***************************************
# Adding in byes
# ***************************************

roster <- merge(roster, byes_player[ ,c('bye_week', 'playerID', 'Bye')],
                by.x = c('GSIS_ID', 'Week'), by.y = c('playerID', 'bye_week'), all.x = TRUE)
roster$Bye[is.na(roster$Bye)] <- 'No Bye'


# ***************************************
# Hardcoding issues found with the data
# ***************************************
if(year == 2019){
  # There are some issues with the data in the source used for defensive points
  roster$fp[roster$Player == 'Green Bay (GB)' & roster$Week == 7] <- 4
  roster$fp[roster$Player == 'Tennessee (Ten)' & roster$Week == 9] <- 6 
  roster$fp[roster$Player == 'Atlanta (Atl)' & roster$Week == 12] <- 5
}

if(year == 2018){
  # Jaylen Samuels was a 'RB,TE' in 2018. He only started as a TE and would likely only have been
  #  started at TE
  roster$Position[roster$Player == 'Jaylen Samuels'] <- 'TE'
  # There were 2 scores I couldn't get to match up even with best effort. I estimated their starting
  # lineup by hand and these are the scores they ended up with. Each was 2 points off in opposite directions
  roster$fp[roster$Player == 'Jacksonville (Jax)' & roster$Week == 8] <- 8
  roster$fp[roster$Player == 'Denver (Den)' & roster$Week == 12] <- 13
  
}

if(year == 2017){
  # There are some issues with the data in the sources
  roster$fp[roster$Player == 'Seattle (Sea)' & roster$Week == 5] <- 16
  roster$fp[roster$Player == 'New England (NE)' & roster$Week == 6] <- 11
  roster$fp[roster$Player == 'New England (NE)' & roster$Week == 8] <- 11
  roster$fp[roster$Player == 'Seattle (Sea)' & roster$Week == 10] <- 9
  roster$fp[roster$Player == 'Cincinnati (Cin)' & roster$Week == 11] <- 10
  roster$fp[roster$Player == 'Detroit (Det)' & roster$Week == 12] <- 5
  roster$fp[roster$Player == 'Seattle (Sea)' & roster$Week == 13] <- 11
  roster$fp[roster$Player == 'Los Angeles (LAR)' & roster$Week == 13] <- 22
  roster$fp[roster$Player == 'Buffalo (Buf)' & roster$Week == 15] <- 10
  roster$fp[roster$Player == 'Philadelphia (Phi)' & roster$Week == 15] <- 8
  roster$fp[roster$Player == 'Jacksonville (Jax)' & roster$Week == 16] <- 3
  roster$fp[roster$Player == 'Philadelphia (Phi)' & roster$Week == 16] <- 21
}

if(year == 2016){
  roster$fp[roster$Player == 'Los Angeles (LAR)' & roster$Week == 2] <- 11
  roster$fp[roster$Player == 'Washington (Was)' & roster$Week == 5] <- 15
  roster$fp[roster$Player == 'Atlanta (Atl)' & roster$Week == 9] <- 5
  roster$fp[roster$Player == 'Denver (Den)' & roster$Week == 10] <- 13
  roster$fp[roster$Player == 'Arizona (Ari)' & roster$Week == 11] <- 6
  roster$fp[roster$Player == 'Philadelphia (Phi)' & roster$Week == 11] <- 3
  roster$fp[roster$Player == 'Oakland (Oak)' & roster$Week == 12] <- 13
  
}

# ***************************
# Create Starting lineups
# ***************************

managers <- unique(roster$Manager)

for(i in 1:3){
  for(j in 1:length(managers)){
    
    # Get score for manager that week from Yahoo data
    score <- matchups$Score[which(matchups$Manager == managers[j] &
                                    matchups$Week_Num == i)]
    
    # Get the players on roster that week
    team <- roster[which(roster$Manager == managers[j] &
                           roster$Week == i), ]
    
    # If a player had multiple positions, split them into two rows
    if(max(nchar(team$Position)) > 3){
      tmp1 <- team[which(nchar(team$Position) > 3), ]
      tmp1$Position <- substr(tmp1$Position, 1, str_locate(tmp1$Position, ',') - 1)
      
      tmp2 <- team[which(nchar(team$Position) > 3), ]
      tmp2$Position <- substr(tmp2$Position, str_locate(tmp2$Position, ',') + 1, nchar(tmp2$Position))
      
      team <- team[which(nchar(team$Position) <= 3), ]
      team <- rbind(team, tmp1, tmp2)
    }
    
    # This helps us when we calculate the smallest difference for all lineups to aid in error checking
    smallest_diff <- 100
    
    # - I'm setting this to 0. If a starting lineup isn't found we'll print an error
    # - I want to count the possible lineups that could be the starting lineup
    #   for each manager and week
    # There's not much I can do about it but it's good to know
    counter <- 0
    
    # Values represent the number of players at each position
    qbs <- ifelse(nrow(team[which(team$Position == 'QB'), ]) > 0, nrow(team[which(team$Position == 'QB'), ]), 1)
    rbs <- ifelse(nrow(team[which(team$Position == 'RB'), ]) > 0, nrow(team[which(team$Position == 'RB'), ]), 1)
    wrs <- ifelse(nrow(team[which(team$Position == 'WR'), ]) > 0, nrow(team[which(team$Position == 'WR'), ]), 1)
    tes <- ifelse(nrow(team[which(team$Position == 'TE'), ]) > 0, nrow(team[which(team$Position == 'TE'), ]), 1)
    ks <- ifelse(nrow(team[which(team$Position == 'QB'), ]) > 0, nrow(team[which(team$Position == 'K'), ]), 1)
    defs <- ifelse(nrow(team[which(team$Position == 'QB'), ]) > 0, nrow(team[which(team$Position == 'DEF'), ]), 1)
    
    for(qbn in 1:qbs) {
      if(nrow(team[which(team$Position == 'QB'), ]) > 0){
        qb <- team$fp[which(team$Position == 'QB')][[qbn]]}else{
          qb <- 0}
      for(rb1n in 1:(rbs-1)){
        rb1 <- team$fp[which(team$Position == 'RB')][[rb1n]] 
        for(rb2n in (rb1n+1):rbs){
          rb2 <- team$fp[which(team$Position == 'RB')][[rb2n]]
          for(wr1n in 1:(wrs-2)){
            wr1 <- team$fp[which(team$Position == 'WR')][[wr1n]] 
            for(wr2n in (wr1n+1):(wrs-1)){
              wr2 <- team$fp[which(team$Position == 'WR')][[wr2n]]
              for(wr3n in (wr2n+1):wrs){
                wr3 <- team$fp[which(team$Position == 'WR')][[wr3n]]
                for(ten in 1:tes){
                  te <- team$fp[which(team$Position == 'TE')][[ten]]
                  for(kn in 1:ks){
                    k <- team$fp[which(team$Position == "K")][[kn]]
                    for(defn in 1:defs){
                      if(nrow(team[which(team$Position == 'DEF'), ]) > 0){
                        def <- team$fp[which(team$Position == 'DEF')][[defn]]}else{
                          def <- 0}
                      
                      # Calculate score of current lineup
                      current_score <- sum(qb, rb1, rb2, wr1, wr2, wr3, te, k, def)
                      
                      # Count the difference in score, print the smalleste difference, helps with errors
                      difference <- abs(current_score - score)
                      smallest_diff <- min(difference, smallest_diff, na.rm = TRUE)
                      # If the current lineup equals the score, add lineup to data set of starting rosters
                      if(isTRUE(all.equal(current_score, score))){
                        starters <- rbind(team %>% subset(Position == 'QB') %>% slice(qbn),
                                          team %>% subset(Position == 'RB') %>% slice(rb1n),
                                          team %>% subset(Position == 'RB') %>% slice(rb2n),
                                          team %>% subset(Position == 'WR') %>% slice(wr1n),
                                          team %>% subset(Position == 'WR') %>% slice(wr2n),
                                          team %>% subset(Position == 'WR') %>% slice(wr3n),
                                          team %>% subset(Position == 'TE') %>% slice(ten),
                                          team %>% subset(Position == 'K') %>% slice(kn),
                                          team %>% subset(Position == 'DEF') %>% slice(defn)
                        )
                        
                        # Create a counter which counts the possible lineups that work
                        #   Add this counter as a column so we can identify these lineups
                        #   and go through them manually
                        counter <- counter + 1
                        starters$LineupPossibility <- counter
                        
                        # Bind starting lineups together
                        if(i == 1 & j == 1){
                          starting_rosters <- starters
                        }else{starting_rosters <- rbind(starting_rosters, starters)}
                      } #end of if current lineup == score
                    } # DEF
                  } # K
                } # TE
              } # WR3
            } # WR2   
          } # WR1
        } # RB2
      } # RB1
    } # QB
    # If we couldn't find a lineup that totals the score, print an error  
    if(counter == 0 & i < 14){cat('Error for', managers[j], 'in week', i, '---',
                                  'Smallest Difference =', smallest_diff, '\n')
    }else if(counter == 0 & i >= 14){cat('Error for', managers[j], 'in week', i,
                                         '--- Smallest Difference =', smallest_diff, 
                                         '(may not have had matchup this week)','\n')
    }else if(counter > 1){
      # If multiple possibilites, print warning
      cat(counter, 'possibilites for', managers[j], 'in week', i, '\n')
    }
  } # Manager loop
} # Weeks loop

# Count the times a player has been started in the past
#  This count will include the players current week appearance
#  This is used as reference for who might have been starting a particular week
starts_tbl <- starting_rosters[ ,c('Player', 'Week')] %>% 
  group_by(Player) %>% distinct(.) %>% mutate(NumStarts = 1:length(Player))

starting_rosters <- merge(starting_rosters, starts_tbl, by = c('Player', 'Week'), all.x = TRUE)


# ***********************************************
# Manually select which lineup was likely played
# ***********************************************

# Despite best efforts, there will always be some rosters with more
#  than one possible starting lineup. Two players in the same position
#  may score the same. A combination of multiple players may work out so that there 
#  are simply multiple possibilities. One person may get a 0 despite playing while another
#  may have been out. I went through them one by one and chose the one most likely to be the truth.
#  I used pro-football-reference.com to see if players played that week. I looked at prior start habbits
#  to see if the manager was regularly starting a certain player. I looked at matchups to see if it would
#  have made sense to start one player/DEF over another. I looked at whether a guy in one lineup would have
#  been a 'must-start.'

# I am selecting and removing the lineups I DONT want in this chunk
if(year == 2019){
  starting_rosters <- subset(starting_rosters, Week != 1 | Manager != 'Soda' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 2 | Manager != 'Toney' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 2 | Manager != 'Nic' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 2 | Manager != 'Colin' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Jon' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 4 | Manager != 'Tony' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Joe' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Soda' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Colin' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 6 | Manager != 'Toney' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 6 | Manager != 'Matt' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 6 | Manager != 'Nic' | LineupPossibility %!in% c(1, 2))
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Joe' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Spencer' | LineupPossibility %!in% c(2, 3))
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Nic' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Soda' | LineupPossibility %!in% c(2, 3))
  starting_rosters <- subset(starting_rosters, Week != 8 | Manager != 'Tony' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 8 | Manager != 'Nic' | LineupPossibility %!in% c(1, 2))
  starting_rosters <- subset(starting_rosters, Week != 8 | Manager != 'Colin' | LineupPossibility %!in% c(1, 3, 4))
  starting_rosters <- subset(starting_rosters, Week != 8 | Manager != 'Greco' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Toney' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Jon' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Dan' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Mike' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Nic' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Colin' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Dan' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Colin' | LineupPossibility %!in% c(2, 3))
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Tony' | LineupPossibility %!in% c(1, 2, 4))
  starting_rosters <- subset(starting_rosters, Week != 14 | Manager != 'Soda' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 14 | Manager != 'Nic' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Toney' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Soda' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Mike' | LineupPossibility != 1)
}

# I am selecting and removing the lineups I DONT want in this chunk
if(year == 2018){
  starting_rosters <- subset(starting_rosters, Week != 1 | Manager != 'Greco' | LineupPossibility %!in% c(1, 3))
  starting_rosters <- subset(starting_rosters, Week != 1 | Manager != 'Toney' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 1 | Manager != 'Nic' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Nic' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 4 | Manager != 'Greco' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Colin' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Toney' | LineupPossibility %!in% c(1, 2))
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Nic' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Colin' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Spencer' | LineupPossibility %!in% c(2, 3))
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Mike' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Toney' | LineupPossibility %!in% c(2, 3))
  starting_rosters <- subset(starting_rosters, Week != 8 | Manager != 'Greco' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Matt' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Colin' | LineupPossibility %!in% c(1, 3, 4))
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Jon' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Joe' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Mike' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Soda' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Jon' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Spencer' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Mike' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Spencer' | LineupPossibility %!in% c(1, 2))
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Mike' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 16 | Manager != 'Greco' | LineupPossibility != 2)
}

# I am selecting and removing the lineups I DONT want in this chunk
if(year == 2017){
  starting_rosters <- subset(starting_rosters, Week != 1 | Manager != 'Soda' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 2 | Manager != 'Colin' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 2 | Manager != 'Spencer' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 2 | Manager != 'Soda' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Tony' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Colin' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Soda' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Toney' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Matt' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Pender' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 4 | Manager != 'Joe' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 4 | Manager != 'Mike' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 4 | Manager != 'Pender' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Joe' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 6 | Manager != 'Dan' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 6 | Manager != 'Matt' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Tony' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Colin' | LineupPossibility %!in% c(2, 3))
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Toney' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 8 | Manager != 'Mike' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Dan' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Jon' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Spencer' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Toney' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Joe' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Tony' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Dan' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Joe' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Pender' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Joe' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Tony' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Jon' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Colin' | LineupPossibility %!in% c(1, 2, 4))
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Dan' | LineupPossibility %!in% c(1, 3))
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Greco' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Spencer' | LineupPossibility %!in% c(2, 3))
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Toney' | LineupPossibility %!in% c(1, 2))
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Tony' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Jon' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Colin' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Pender' | LineupPossibility != 1)
}

# I am selecting and removing the lineups I DONT want in this chunk
if(year == 2016){
  starting_rosters <- subset(starting_rosters, Week != 1 | Manager != 'Tony' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 2 | Manager != 'Dan' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Dan' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 3 | Manager != 'Jon' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 4 | Manager != 'Dan' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Dan' | LineupPossibility %!in% c(2, 3))
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Colin' | LineupPossibility %!in% c(1, 3, 4))
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Toney' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Spencer' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 5 | Manager != 'Greco' | LineupPossibility %!in% c(2, 3, 4))
  starting_rosters <- subset(starting_rosters, Week != 6 | Manager != 'Joe' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 6 | Manager != 'Mike' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 6 | Manager != 'Greco' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Joe' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Colin' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 7 | Manager != 'Jon' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 8 | Manager != 'Colin' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Tony' | LineupPossibility %!in% c(1, 3))
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Soda' | LineupPossibility %!in% c(1, 2))
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Colin' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 9 | Manager != 'Greco' | LineupPossibility %!in% c(1, 2, 4))
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Tony' | LineupPossibility %!in% c(1, 3))
  starting_rosters <- subset(starting_rosters, Week != 10 | Manager != 'Colin' | LineupPossibility %!in% c(1, 3, 4))
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Pender' | LineupPossibility != 2)
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Matt' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 11 | Manager != 'Toney' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 12 | Manager != 'Soda' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Dan' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Colin' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Toney' | LineupPossibility != 1)
  starting_rosters <- subset(starting_rosters, Week != 13 | Manager != 'Spencer' | LineupPossibility %!in% c(1, 2))
  starting_rosters <- subset(starting_rosters, Week != 14 | Manager != 'Colin' | LineupPossibility %!in% c(1, 3, 4))
  starting_rosters <- subset(starting_rosters, Week != 15 | Manager != 'Jon' | LineupPossibility != 2)
}

# Check results
tbl <- unique(starting_rosters[ ,c("Manager", "Week", "LineupPossibility")])
table(tbl$Manager, tbl$Week) == 1


# **************************************
#  Save File ----
# **************************************
write.csv(starting_rosters, paste0(file.location, sprintf('StartingRosters_%g.csv', year)),
          row.names = FALSE)


# **************************************
# Remove objects
# **************************************

rm(tbl)
rm(counter)
rm(starters)
rm(team)
rm(managers)
rm(qb); rm(rb1); rm(rb2); rm(wr1); rm(wr2); rm(wr3); rm(te); rm(k); rm(def)
rm(qbn); rm(rb1n); rm(rb2n); rm(wr1n); rm(wr2n); rm(wr3n); rm(ten); rm(kn); rm(defn)
rm(qbs); rm(rbs); rm(wrs); rm(tes); rm(ks); rm(defs)


