library(dplyr)
library(readr)
library(nnet)
library(tidyr)
library(purrr)
library("this.path")

################################################################################
# This script takes a collection of ODiN and returns activities for each participant (instead of trips)

################################################################################
# Transform ODiN into activities

setwd(paste0(this.path::this.dir(), "/data/processed"))
df_original <- read_csv("df_trips-highly_urbanised.csv")

df_original <- df_original[order(df_original$agent_ID),]

df_original <- df_original %>%
  select(agent_ID, disp_activity, disp_start_time, disp_arrival_time, day_of_week)

# Transform minutes into seconds
df_original$disp_start_time <- df_original$disp_start_time * 60
df_original$disp_arrival_time <- df_original$disp_arrival_time * 60

# For each trip add the start time of the next trip
df_original <-
  transform(df_original, next_start_time = c(disp_start_time[-1], NA))
df_original <-
  transform(df_original, nxt_ID = c(as.character(agent_ID[-1]), NA))
df_original$next_start_time <-
  ifelse(df_original$nxt_ID == df_original$agent_ID,
         df_original$next_start_time,
         86399) # midnight

# activities where the trips is actually the activity
list_ODiN_activities <-
  c('collection/delivery of goods', 'hiking', 'transport is the job')

datalist = list()
ODiN_IDs <- unique(df_original$agent_ID)

for (n in 1:length(ODiN_IDs)) {
  ODiN_ID <- ODiN_IDs[n]
  
  df <- data.frame(matrix(ncol = 5, nrow = 0))
  colnames(df) <-
    c('ODiN_ID',
      'activity_type',
      'start_time',
      'day_of_week')
  
  df_activities <- df_original[df_original$agent_ID == ODiN_ID,]
  
  # Counter for the synthetic activities
  counter <- 1
  
  # Add the home activity
  df[counter, ] = c(ODiN_ID,
                    'home',
                    0,
                    df_activities[1,]$day_of_week)
  
  # if the agent stays at home all day, it has a record with NA value
  if(!is.na(df_activities[1,]$disp_activity)) {
    # there is at least one trip
    
    for (i in 1:nrow(df_activities)) {
      # add the trip activity
  
      if (df_activities[i,]$disp_activity %in% list_ODiN_activities &
          df_activities[i,]$disp_start_time < 86400 ) {
        # if the trip the activity itself
        counter <- counter + 1
        df[counter, ] = c(
          ODiN_ID,
          df_activities[i,]$disp_activity,
          df_activities[i,]$disp_start_time,
          df_activities[i,]$day_of_week
        )
      } else {
        # if the activity is the destination of the trip
        counter <- counter + 1
        df[counter, ] = c(
          ODiN_ID,
          'trip',
          df_activities[i,]$disp_start_time,
          df_activities[i,]$day_of_week
        )
      }
      
      #  Add the activity in the middle
      counter <- counter + 1
      if (df_activities[i,]$disp_activity %in% list_ODiN_activities) {
        prev_activity <- df[counter - 2, ]$activity_type
        df[counter, ] = c(
          ODiN_ID,
          prev_activity,
          df_activities[i,]$disp_arrival_time,
          df_activities[i,]$day_of_week
        )
      } else {
        if (df_activities[i,]$disp_activity == 'to home') {
          activity <- 'home'
        } else if (df_activities[i,]$disp_activity == 'to work') {
          activity <- 'work'
        } else if (df_activities[i,]$disp_activity == 'visit/stay') {
          activity <- 'visit/stay'
        } else if (df_activities[i,]$disp_activity == 'shopping') {
          activity <- 'shopping'
        } else if (df_activities[i,]$disp_activity == 'other leisure activities') {
          activity <- 'leisure'
        } else if (df_activities[i,]$disp_activity == 'services/personal care') {
          activity <- 'leisure'
        } else if (df_activities[i,]$disp_activity == 'sports/hobby') {
          activity <- 'sport'
        } else if (df_activities[i,]$disp_activity == 'pick up / bring people') {
          activity <- 'pick up / bring people'
        } else if (df_activities[i,]$disp_activity == 'other') {
          activity <- 'other'
        } else if (df_activities[i,]$disp_activity == 'follow education') {
          activity <- 'school'
        } else if (df_activities[i,]$disp_activity == 'business visit') {
          activity <- 'business visit'
        }
        
        # if the trip ends after midnight, I drop the following activity
        if (df_activities[i,]$disp_arrival_time <= 86400) {
          df[counter, ] = c(
            ODiN_ID,
            activity,
            df_activities[i,]$disp_arrival_time,
            df_activities[i,]$day_of_week
          )
        }

      }
      
    }
    
  }
  
  # remove trips and activities that I am not interested into
  df <- df %>%
    filter(
      activity_type == 'home' |
        activity_type == 'work' |
        activity_type == 'shopping' |
        activity_type == 'sport' |
        (activity_type=='school' & !(day_of_week==1 | day_of_week==7)) # school activities only during the week.
    )
  
  # merge together consequential activities of the same type
  df$remove <- F
  for (x in 1:nrow(df)) {
    if (x + 1 <= nrow(df)) {
      if (df[x, ]$activity_type == df[x + 1, ]$activity_type) {
        df[x, ]$remove <- T
        df[x + 1, ]$start_time <- df[x, ]$start_time
      }
    }
  }
  df <- df %>%
    filter(remove == F)
  df = subset(df, select = -c(remove))
  
  # make sure that the last activity goes till the end of the day
  df[nrow(df), ]$end_time <- 86400
  
  # add duration and activity number
  df$duration <- as.numeric(df$end_time) - as.numeric(df$start_time)
  df$activity_number <- 1:nrow(df)

  datalist[[n]] <- df
}

df_activities_all = do.call(rbind, datalist)

# Save dataset
setwd(paste0(this.path::this.dir(), "/data/processed"))
write.csv(df_activities_all, 'df_activity_schedule-higly_urbanized.csv', row.names = FALSE)