library(dplyr)
library(readr)
library(nnet)
library(tidyr)
library(purrr)
library("this.path")

create_agegroups <- function (df) {
  df$agegroup = NA
  df <- df %>%
    mutate(agegroup = ifelse(age %in% c(0:5), 'agegroup_0_5', agegroup)) %>%      # kid
    mutate(agegroup = ifelse(age %in% c(6:11), 'agegroup_6_11', agegroup)) %>%    # primary school
    mutate(agegroup = ifelse(age %in% c(12:18), 'agegroup_12_18', agegroup)) %>%  # high-school
    mutate(agegroup = ifelse(age %in% c(19:25), 'agegroup_19_25', agegroup)) %>%  # university student
    mutate(agegroup = ifelse(age %in% c(26:30), 'agegroup_26_30', agegroup)) %>%  # work without children
    mutate(agegroup = ifelse(age %in% c(31:50), 'agegroup_31_50', agegroup)) %>%  # work with children
    mutate(agegroup = ifelse(age %in% c(51:67), 'agegroup_51_67', agegroup)) %>%  # retirement
    mutate(agegroup = ifelse(age >= 68, 'agegroup_over_68', agegroup))
  
  return(df)
}

################################################################################
# Assign prototypes to ODiN participants

setwd(paste0(this.path::this.dir(), "/data/processed"))
df_ODiN <- read_csv("df_activity_trips.csv")
df_ODiN <- create_agegroups(df_ODiN)

# Select unique agents from ODiN and their demographics
df_ODiN <- df_ODiN %>%
  select(agent_ID, day_of_week, agegroup, gender, migration_background) %>%
  distinct()

# Add ID to link each agent to its unique prototype
df_ODiN <- df_ODiN %>%
  group_by(agegroup, gender, migration_background) %>% 
  mutate(prototype_ID = cur_group_id()) %>%
  rename('ODiN_ID' = 'agent_ID') %>%
  ungroup

df_prototypes <- df_ODiN %>%
  select(agegroup, gender, migration_background, prototype_ID) %>%
  distinct()

df_ODiN <- df_ODiN %>%
  select(ODiN_ID, prototype_ID, day_of_week)
  
################################################################################
# Assign prototypes to synthetic agents

setwd(this.path::this.dir())
setwd('../DHZW_synthetic-population/output/synthetic-population-households')

df_synth_pop <- read_csv("synthetic_population_DHZW_2019_with_hh.csv")

df_synth_pop <- create_agegroups(df_synth_pop)

# Add ID to link each agent to its unique prototype
df_synth_pop <- df_synth_pop %>%
  select(agent_ID, agegroup, gender, migration_background)

df_synth_pop <- merge(df_synth_pop, df_prototypes)

df_synth_pop <- df_synth_pop %>%
  select(agent_ID, prototype_ID)

################################################################################

library(data.table)

setDT(df_ODiN)
setDT(df_synth_pop)
df_outcome <- df_synth_pop

# For each day of the week
for (i in unique(df_ODiN$day_of_week)) {

#  i = 1
  df_ODiN_day <- df_ODiN[df_ODiN$day_of_week==i,]
  
  df_ODiN_day <- df_ODiN_day %>%
    select(ODiN_ID, prototype_ID)
  
  df_match = df_ODiN_day[df_synth_pop, on = .(prototype_ID),
                               {ri <- sample(.N, 1L)
                               .(ODiN_ID = ODiN_ID[ri])}, by = .EACHI]
  
  df_match$agent_ID <- df_synth_pop$agent_ID
  
  df_match <- as.data.frame(df_match)
  df_match[paste0('ODiN_ID_', i)] <- df_match['ODiN_ID']
  df_match = subset(df_match, select = -c(ODiN_ID))
  
  df_outcome <- merge(df_outcome, df_match)
}

setwd(paste0(this.path::this.dir(), "/data/processed"))
write.csv(df_outcome, 'df_match_synthetic_ODiN_agents.csv', row.names = FALSE)