library(dplyr)
library(readr)
library(nnet)
library(tidyr)
library(purrr)
library("this.path")

################################################################################
# Transform ODiN into activities

setwd(paste0(this.path::this.dir(), "/data/processed"))
df_original <- read_csv("df_activity_trips.csv")

df_original <- df_original[order(df_original$agent_ID),]

df_original <- df_original %>%
  select(agent_ID, disp_activity, disp_start_time, disp_arrival_time, day_of_week)

df_original <-
  transform(df_original, next_start_time = c(disp_start_time[-1], NA))
df_original <-
  transform(df_original, nxt_ID = c(as.character(agent_ID[-1]), NA))
df_original$next_start_time <-
  ifelse(df_original$nxt_ID == df_original$agent_ID,
         df_original$next_start_time,
         1439)

df_activities_all <- data.frame(matrix(ncol = 6, nrow = 0))
colnames(df_activities_all) <-
  c('ODiN_ID',
    'activity_type',
    'start_time',
    'end_time',
    'duration',
    'activity_number')

list_ODiN_activities <-
  c('collection/delivery of goods', 'hiking', 'transport is the job')

for (ODiN_ID in unique(df_original$agent_ID)) {
  #ODiN_ID <- 56114533936
  df <- data.frame(matrix(ncol = 4, nrow = 0))
  colnames(df) <-
    c('ODiN_ID',
      'activity_type',
      'start_time',
      'end_time')
  
  df_activities <- df_original[df_original$agent_ID == ODiN_ID,]
  
  counter <- 1
  for (i in 1:nrow(df_activities)) {
    # add starting activity being at home
    if (counter == 1) {
      df[counter, ] = c(ODiN_ID,
                        'home',
                        0,
                        df_activities[1,]$disp_start_time)
    }
    
    # add the trip activity
    counter <- counter + 1
    if (df_activities[i,]$disp_activity %in% list_ODiN_activities) {
      df[counter, ] = c(
        ODiN_ID,
        df_activities[i,]$disp_activity,
        df_activities[i,]$disp_start_time,
        df_activities[i,]$disp_arrival_time
      )
    } else {
      df[counter, ] = c(
        ODiN_ID,
        'trip',
        df_activities[i,]$disp_start_time,
        df_activities[i,]$disp_arrival_time
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
        df_activities[i,]$next_start_time
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
      
      df[counter, ] = c(
        ODiN_ID,
        activity,
        df_activities[i,]$disp_arrival_time,
        df_activities[i,]$next_start_time
      )
    }
    
  }
  
  # remove trips and activities that I am not interested into
  df <- df %>%
    filter(
      activity_type == 'home' |
        activity_type == 'work' |
        activity_type == 'shopping' |
        activity_type == 'sport' |
        activity_type == 'school'
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
  df[nrow(df), ]$end_time <- 1439
  
  # add duration and activity number
  df$duration <- as.numeric(df$end_time) - as.numeric(df$start_time)
  df$activity_number <- 1:nrow(df)
  df$day_of_week <- df_activities[1,]$day_of_week
  
  df_activities_all <- rbind(df_activities_all, df)
  
}

# Save dataset
setwd(paste0(this.path::this.dir(), "/data/processed"))
write.csv(df_activities_all, 'df_activity_schedule_all.csv', row.names = FALSE)