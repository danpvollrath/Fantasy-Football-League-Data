i <- 12 # week
j <- which("Dan" == managers)[[1]]


score <- matchups$Score[which(matchups$Manager == managers[j] &
                               matchups$Week_Num == i)]
score
# Perhaps eliminate players on bye
team <- roster[which(roster$Manager == managers[j] &
                       roster$Week == i), ]

# Check one players week_stats
check <- week_stats[which(week_stats$Week == 16 & week_stats$name == 'F.Gore'), ]

qbpts <- team$fp[which(team$Position == 'QB')]
rbpts <- team$fp[which(team$Position == 'RB')]
wrpts <- team$fp[which(team$Position == 'WR')]
tepts <- team$fp[which(team$Position == 'TE')]
kpts <- team$fp[which(team$Position == 'K')]
defpts <- team$fp[which(team$Position == 'DEF')]

for(qbn in 1:length(qbpts)) {
  qb <- team$fp[which(team$Position == 'QB')][[qbn]]
  for(rb1n in 1:(length(rbpts)-1)){
    rb1 <- team$fp[which(team$Position == 'RB')][[rb1n]] 
    for(rb2n in (rb1n+1):length(rbpts)){
      rb2 <- team$fp[which(team$Position == 'RB')][[rb2n]]
      for(wr1n in 1:(length(wrpts)-2)){
        wr1 <- team$fp[which(team$Position == 'WR')][[wr1n]] 
        for(wr2n in (wr1n+1):(length(wrpts)-1)){
          wr2 <- team$fp[which(team$Position == 'WR')][[wr2n]]
          for(wr3n in (wr2n+1):length(wrpts)){
            wr3 <- team$fp[which(team$Position == 'WR')][[wr3n]]
            for(ten in 1:length(tepts)){
              te <- team$fp[which(team$Position == 'TE')][[ten]]
              for(kn in 1:length(kpts)){
                k <- team$fp[which(team$Position == "K")][[kn]]
                for(defn in 1:length(defpts)){
                  def <- team$fp[which(team$Position == 'DEF')][[defn]]
                  current_score <- sum(qb, rb1, rb2, wr1, wr2, wr3, te, k, def)
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
                  counter <- counter + 1
                  
                  cat('Current Score:', current_score, '\n', 'Target Score:', score, '\n')
                  print(starters)
                }
              }
            }
          }
        }    
      }
    }
  }
}

# Count the times a player has been started in the past
#  This count will include the players current week appearance
#  This is used as reference for who might have been starting a particular week
starts_tbl <- starting_rosters[ ,c('Player', 'Week')] %>% 
  group_by(Player) %>% distinct(.) %>% mutate(NumStarts = 1:length(Player))

starting_rosters <- merge(starting_rosters, starts_tbl, by = c('Player', 'Week'), all.x = TRUE)

