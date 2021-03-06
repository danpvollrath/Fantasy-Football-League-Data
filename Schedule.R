## ************************************
## Script name: Schedule.R
## Purpose: Schedule of Mondays, final dates for weekly lineups
## For: Fantasy Football Project
## Location: Documents.Fantasy Football Project
## Author: Dan Vollrath
## Email: danpvollrath@gmail.com
## Date Created: 2020-01-14
## ************************************
##
## Notes: 
##
##
##
## *************************************

# These are Mondays in the seasons
# I start With week 0 because my code checks for transactions
#   between two dates

Monday_Game_Date <- c('2019-6-1', # Start of 2019
                      '2019-9-9', 
                      '2019-9-16', 
                      '2019-9-23', # Week 3 2019
                      '2019-9-30',
                      '2019-10-7',
                      '2019-10-14', # Week 6 2019
                      '2019-10-21', 
                      '2019-10-28', 
                      '2019-11-4', # Week 9 2019
                      '2019-11-11',
                      '2019-11-18', 
                      '2019-11-25', # Week 12 2019
                      '2019-12-2', 
                      '2019-12-9',
                      '2019-12-16', # Week 15 2019
                      '2019-12-23', 
                      '2019-12-30', 
                      '2018-6-1', # Start of 2018
                      '2018-9-10', 
                      '2018-9-17', 
                      '2018-9-24', # Week 3 2018
                      '2018-10-1',
                      '2018-10-8', 
                      '2018-10-15', # Week 6 2018
                      '2018-10-22', 
                      '2018-10-29', 
                      '2018-11-5', # Week 9 2018
                      '2018-11-12', 
                      '2018-11-19', 
                      '2018-11-26', # Week 12 2018
                      '2018-12-3', 
                      '2018-12-10',
                      '2018-12-17', # Week 15 2018
                      '2018-12-24', 
                      '2018-12-31', 
                      '2017-6-1', # Start of 2017
                      '2017-9-11', 
                      '2017-9-18', 
                      '2017-9-25', # Week 3 2017
                      '2017-10-2',
                      '2017-10-9', 
                      '2017-10-16', # Week 6 2017
                      '2017-10-23', 
                      '2017-10-30', 
                      '2017-11-6', # week 9 2017
                      '2017-11-13', 
                      '2017-11-20', 
                      '2017-11-27', # Week 12 2017
                      '2017-12-4', 
                      '2017-12-11',
                      '2017-12-18', # Week 15 2017
                      '2017-12-25', 
                      '2017-12-31',
                      '2016-6-1', # Start of 2016
                      '2016-9-12',
                      '2016-9-19',
                      '2016-9-26', # Week 3 2016
                      '2016-10-3',
                      '2016-10-10',
                      '2016-10-17', # Week 6 2016
                      '2016-10-24',
                      '2016-10-31',
                      '2016-11-7', # Week 9 2016
                      '2016-11-14',
                      '2016-11-21',
                      '2016-11-28', # Week 12 2016
                      '2016-12-5',
                      '2016-12-12',
                      '2016-12-19', # Week 15 2016
                      '2016-12-26',
                      '2016-1-2',
                      '2015-6-1', # Start of 2015
                      '2015-9-14',
                      '2015-9-21',
                      '2015-9-28', # Week 3 2015
                      '2015-10-5',
                      '2015-10-12',
                      '2015-10-19', # Week 6 2015
                      '2015-10-26',
                      '2015-11-2',
                      '2015-11-9', # Week 9 2015
                      '2015-11-16',
                      '2015-11-23',
                      '2015-11-30', # Week 12 2015
                      '2015-12-7',
                      '2015-12-14',
                      '2015-12-21', # Week 15 2015
                      '2015-12-28',
                      '2015-1-4',
                      '2014-6-1', # Start of 2014
                      '2014-9-8',
                      '2014-9-15',
                      '2014-9-22', # Week 3 2014
                      '2014-9-29',
                      '2014-10-6',
                      '2014-10-13', # Week 6 2014
                      '2014-10-20',
                      '2014-10-27',
                      '2014-11-3', # Week 9 2014
                      '2014-11-10',
                      '2014-11-17',
                      '2014-11-24', # Week 12 2014
                      '2014-12-1',
                      '2014-12-8',
                      '2014-12-15', # Week 15 2014
                      '2014-12-22',
                      '2014-12-29'
) 

# Creating a vector with week numbers, 0 through 17
Week <- c(0:17, 0:17, 0:17, 0:17, 0:17, 0:17)

# Year field
Year <- c('2019', '2019', '2019', '2019', '2019', '2019', '2019', '2019', '2019',
          '2019', '2019', '2019', '2019', '2019', '2019', '2019', '2019', '2019',
          '2018', '2018', '2018', '2018', '2018', '2018', '2018', '2018', '2018',
          '2018', '2018', '2018', '2018', '2018', '2018', '2018', '2018', '2018',
          '2017', '2017', '2017', '2017', '2017', '2017', '2017', '2017', '2017',
          '2017', '2017', '2017', '2017', '2017', '2017', '2017', '2017', '2017',
          '2016', '2016', '2016', '2016', '2016', '2016', '2016', '2016', '2016',
          '2016', '2016', '2016', '2016', '2016', '2016', '2016', '2016', '2016',
          '2015', '2015', '2015', '2015', '2015', '2015', '2015', '2015', '2015',
          '2015', '2015', '2015', '2015', '2015', '2015', '2015', '2015', '2015',
          '2014', '2014', '2014', '2014', '2014', '2014', '2014', '2014', '2014',
          '2014', '2014', '2014', '2014', '2014', '2014', '2014', '2014', '2014'
)

# Combine vectors into data frame
sched <- data.frame(Monday_Game_Date, Week, Year)

# Format variables
sched$Monday_Game_Date <- as.Date(sched$Monday_Game_Date, format = "%Y-%m-%d")
sched$Week <- as.integer(sched$Week)
sched$Year <- as.integer(sched$Year)

# Remove objects
rm(Monday_Game_Date); rm(Week); rm(Year)