library(readr)
library(dplyr)
library(this.path)
library(ggplot2)
library(gridExtra)

setwd(this.dir())
setwd('../data/processed')

df_DHZW <- read.csv('df_activity_schedule_DHZW.csv')
df_pool <- read.csv('df_activity_schedule_all.csv')

length(unique(df_DHZW$ODiN_ID))
length(unique(df_pool$ODiN_ID))

################################################################################
# all days together

df_DHZW.activities_all <- as.data.frame(table(df_DHZW$activity_type))
colnames(df_DHZW.activities_all) <- c('activity', 'frequency')
df_DHZW.activities_all$DHZW <- df_DHZW.activities_all$frequency/sum(df_DHZW.activities_all$frequency)
df_pool.activities_all <- as.data.frame(table(df_pool$activity_type))
colnames(df_pool.activities_all) <- c('activity', 'frequency')
df_pool.activities_all$pool <- df_pool.activities_all$frequency/sum(df_pool.activities_all$frequency)

df_comparison.activities_all <- merge(df_pool.activities_all, df_DHZW.activities_all, by='activity')
df_comparison.activities_all <- pivot_longer(df_comparison.activities_all, cols=c('DHZW', 'pool'), names_to = 'dataset', values_to = 'proportion')

df_comparison.activities_all$dataset <- recode(
  df_comparison.activities_all$dataset,
  'DHZW' = paste0('DHZW (', length(unique(df_DHZW$ODiN_ID)),' pp)'),
  'pool' = paste0('NL highly urbanized \n (', length(unique(df_pool$ODiN_ID)),' pp)')
)

plot_all <- ggplot(df_comparison.activities_all, aes(activity, proportion)) +
  geom_bar(aes(fill = dataset),
           position = "dodge",
           stat = "identity",
           width=0.4) +
  ggtitle("Comparison of all the activities")
plot_all

################################################################################
# Comparison of days of the week

list_plot_days = list()
for (i in c(1:7)) {
  df_DHZW.activities_day <- as.data.frame(table(df_DHZW[df_DHZW$day_of_week==i,]$activity_type))
  colnames(df_DHZW.activities_day) <- c('activity', 'frequency')
  df_DHZW.activities_day$DHZW <- df_DHZW.activities_day$frequency/sum(df_DHZW.activities_day$frequency)
  df_pool.activities_day <- as.data.frame(table(df_pool[df_pool$day_of_week==i,]$activity_type))
  colnames(df_pool.activities_day) <- c('activity', 'frequency')
  df_pool.activities_day$pool <- df_pool.activities_day$frequency/sum(df_pool.activities_day$frequency)
  
  df_comparison.activities_day <- merge(df_pool.activities_day, df_DHZW.activities_day, by='activity')
  df_comparison.activities_day <- pivot_longer(df_comparison.activities_day, cols=c('DHZW', 'pool'), names_to = 'dataset', values_to = 'proportion')
  
  df_comparison.activities_day$dataset <- recode(
    df_comparison.activities_day$dataset,
    'DHZW' = paste0('DHZW (', length(unique(df_DHZW[df_DHZW$day_of_week==i,]$ODiN_ID)),' pp)'),
    'pool' = paste0('NL highly urbanized \n (', length(unique(df_pool[df_pool$day_of_week==i,]$ODiN_ID)),' pp)')
  )
  
  plot_day <- ggplot(df_comparison.activities_day, aes(activity, proportion)) +
    geom_bar(aes(fill = dataset),
             position = "dodge",
             stat = "identity",
             width=0.4) +
    ggtitle(paste0('Day ', i))
  plot_day
  
  list_plot_days[[i]] <- plot_day
}

do.call("grid.arrange", c(list_plot_days, ncol=floor(sqrt(length(list_plot_days)))))
