## ************************************
## Script name: CreateDrafts.R
## Purpose: Create drafts data set
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

source(paste0(file.location, 'IDREF.R'))
week_stats <- read.csv(paste0(file.location, sprintf('WeekStats_%g.csv', year)))
def_stats <- read.csv(paste0(file.location, 'DefScores_Raw.csv'))

week_stats <- week_stats[ ,c('playerID', 'fp', 'Pos')]
def_stats <- def_stats[which(def_stats$Year == year), ]


# ***************************************
# Creating position ranks
# ***************************************

# Total points by player
sum.stats <- week_stats %>% group_by(playerID, Pos) %>% summarize(Season_Points = sum(fp))
sum.stats.def <- def_stats %>% group_by(Player, Position) %>% summarize(Season_Points = sum(Score, na.rm = TRUE))

# Bind defensive points to data with players
colnames(sum.stats.def) <- c('playerID', 'Pos', 'Season_Points')
sum.stats <- rbind(sum.stats, sum.stats.def)

# Group by position and rank them by fantasy point total
sum.stats <- sum.stats %>% group_by(Pos) %>% 
  mutate(Position_Rank = order(order(Season_Points, decreasing = TRUE)))

# Remove those with NA for point total
sum.stats <- sum.stats[complete.cases(sum.stats), ]

# **************************************
# Create VBD Points
# ************************************
# VBD points compares a player's point total to that of basically the worst starter
# Traditionally, the 30th best reciever is used but I am in a 3 WR league so I use 36
sum.stats$VBD <- NA

# QB
sum.stats$VBD[sum.stats$Pos == 'QB'] <- sum.stats$Season_Points[sum.stats$Pos == 'QB'] - 
  sum.stats$Season_Points[sum.stats$Pos == 'QB' & sum.stats$Position_Rank == 12]

# RB
sum.stats$VBD[sum.stats$Pos == 'RB'] <- sum.stats$Season_Points[sum.stats$Pos == 'RB'] - 
  sum.stats$Season_Points[sum.stats$Pos == 'RB' & sum.stats$Position_Rank == 24]

# WR
sum.stats$VBD[sum.stats$Pos == 'WR'] <- sum.stats$Season_Points[sum.stats$Pos == 'WR'] - 
  sum.stats$Season_Points[sum.stats$Pos == 'WR' & sum.stats$Position_Rank == 36]

# TE
sum.stats$VBD[sum.stats$Pos == 'TE'] <- sum.stats$Season_Points[sum.stats$Pos == 'TE'] - 
  sum.stats$Season_Points[sum.stats$Pos == 'TE' & sum.stats$Position_Rank == 12]

# Change negatives and NA's to 0
# ********************************

sum.stats$VBD[is.na(sum.stats$VBD) | sum.stats$VBD < 0] <- 0


# *******************************************
# Merge our stats with our draft data set
# *******************************************

# Merge our id references table with drafts
# ******************************************
drafts <- merge(drafts, id_ref, by = 'Player', all.x = TRUE)

# Merge Drafts with our player stats
# ***********************************
drafts <- merge(drafts, sum.stats[ ,c('playerID', 'Season_Points', 'Position_Rank', 'VBD')], 
                by.x = 'GSIS_ID', by.y = 'playerID', all.x = TRUE)

# Merge Drafts with our defensive stats
# **************************************
# Renaming our variables to merge
sum.stats <- setNames(sum.stats[ ,c('playerID', 'Season_Points', 'Position_Rank')], 
                      c('Player', 'Season_Points_d', 'Position_Rank_d'))
# Merging with drafts
drafts <- merge(drafts, sum.stats[ ,c('Player', 'Season_Points_d', 'Position_Rank_d')],
                by = 'Player', all.x = TRUE)

# Calculating new columns which will combine these fields for DEF and other positions
drafts$Season_Points <- ifelse(is.na(drafts$Season_Points), drafts$Season_Points_d, drafts$Season_Points)
drafts$Position_Rank <- ifelse(is.na(drafts$Position_Rank), drafts$Position_Rank_d, drafts$Position_Rank)

# Remove added fields
drafts <- drafts[ ,which(names(drafts) %!in% c('Season_Points_d', 'Position_Rank_d'))]



# ************************************
# Creating a Season Improvement Field
# ************************************
# This field compares where a person was drafted and where they ended up
# This is used for best and worst draft pick calculations
# Because players can only drop to 'droppable' in real life, we use a'droppable'
#   level as the floor. The 'droppable' level is calculated by counting the number
#   of players drafted in a position


# Number of players drafted at each position
# *******************************************
pos.tbl <- drafts %>% group_by(Position) %>% summarize(Num_Players = n())


# Position rank floor
# ************************

drafts <- merge(drafts, pos.tbl, by = 'Position', all.x = TRUE)
drafts$Rank_Adj <- ifelse(drafts$Position_Rank > drafts$Num_Players, drafts$Num_Players, drafts$Position_Rank)


# Adding information for players who never played
# ************************************************
drafts$Season_Points[is.na(drafts$Position_Rank)] <- 0
drafts$VBD[is.na(drafts$VBD)] <- 0
drafts$Rank_Adj[is.na(drafts$Rank_Adj)] <- drafts$Num_Players[is.na(drafts$Rank_Adj)]

# Position rise or fall
# ************************
drafts$Season_Change <- 100 * ((drafts$Position_Pick/drafts$Num_Players) - (drafts$Rank_Adj/drafts$Num_Players))


# ************************************
# Add team to Defense
# ************************************
drafts$Team[drafts$Position == 'DEF'] <- toupper(substr(drafts$Player[drafts$Position == 'DEF'],
                                                str_locate(drafts$Player[drafts$Position == 'DEF'], '\\(') + 1,
                                                str_locate(drafts$Player[drafts$Position == 'DEF'], '\\)') - 1))

# ************************************
# Remove objects
# ************************************

rm(pos.tbl)
rm(id_ref)
rm(sum.stats)
rm(def_stats)
rm(sum.stats.def)
