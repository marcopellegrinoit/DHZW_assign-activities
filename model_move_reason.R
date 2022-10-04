library(dplyr)
library(readr)

df_ODiN <- read_csv("df_DHZW.csv")

################################################################################
# group agents into prototypes

# Create agegroups
create_agegroups <- function (df) {
  df$agegroup = NA
  df <- df %>%
    mutate(agegroup = ifelse(age %in% c(0:5), 'agegroup_0_5', agegroup)) %>%
    mutate(agegroup = ifelse(age %in% c(6:11), 'agegroup_6_11', agegroup)) %>%
    mutate(agegroup = ifelse(age %in% c(12:18), 'agegroup_12_18', agegroup)) %>%
    mutate(agegroup = ifelse(age %in% c(19:25), 'agegroup_19_25', agegroup)) %>%
    mutate(agegroup = ifelse(age %in% c(26:30), 'agegroup_26_30', agegroup)) %>%
    mutate(agegroup = ifelse(age %in% c(31:50), 'agegroup_31_50', agegroup)) %>%
    mutate(agegroup = ifelse(age %in% c(51:67), 'agegroup_51_67', agegroup)) %>%
    mutate(agegroup = ifelse(age >= 68, 'agegroup_over_68', agegroup))
  
  return(df)
}

df_ODiN <- create_agegroups(df_ODiN)

# Select unique agents from ODiN and their demographics
df_ODiN_agents <- df_ODiN %>%
  select(agent_ID, hh_PC4, age, agegroup, gender, migration_background) %>%
  distinct()

# Add ID to link each agent to its unique prototype
df_ODiN_agents <- df_ODiN_agents %>%
  group_by(agegroup, gender, migration_background) %>% 
  mutate(prototype_ID =cur_group_id())

# For each ODiN agent, count how many have the same prototype
df_ODiN_agents <- df_ODiN_agents %>%
  group_by(prototype_ID) %>%
  mutate(freq_same_prototype = n())

# Save dataset that links agents to prototypes
setwd(paste0(this.path::this.dir(), "/data/Formatted"))
write.csv(df_ODiN_agents, 'df_ODiN_prototypes.csv', row.names = FALSE)

################################################################################
# Analysis of how many agents, displacements and rides there are for each prototype

df_ODiN <- merge(df_ODiN, df_ODiN_agents)

df_ODiN <- df_ODiN %>%
  group_by(prototype_ID) %>%
  mutate(freq_disps_prototype = n_distinct(disp_id)) %>%
  mutate(freq_ride_prototype = n_distinct(ride_id))

plot(table(df_ODiN$freq_same_prototype))
plot(table(df_ODiN$freq_disps_prototype))
plot(table(df_ODiN$freq_ride_prototype))

################################################################################
# Link ODiN prototypes with synthetic agents

df_prototypes <- df_ODiN_agents %>%
  select(prototype_ID, agegroup, gender, migration_background, freq_same_prototype) %>%
  distinct()

df_synth_pop <- read_csv("~/GitHub projects/DHZW_assign-travel-behaviours/data/synthetic_population_DHZW_2019_with_hh.csv")
df_synth_pop <- create_agegroups(df_synth_pop)

df_synth_pop_unique <- df_synth_pop %>%
  select(agegroup, gender, migration_background) %>%
  distinct()

df_match <- left_join(df_synth_pop_unique, df_prototypes, by=c('agegroup', 'gender', 'migration_background'))

################################################################################

df_motive_probabilities <- data.frame(matrix(ncol = 3, nrow = 0))
colnames(df_motive_probabilities) <- c("disp_motive", "n", "prob", "prototype_ID")

for (i in 1:nrow(df_prototypes)){
  df_motives = df_ODiN[df_ODiN$agegroup==df_prototypes[i,]$agegroup & df_ODiN$gender==df_prototypes[i,]$gender & df_ODiN$migration_background==df_prototypes[i,]$migration_background,]
  df_motives = df_motives %>%
    select(disp_id, disp_motive) %>%
    distinct()
  
  df_motives <- df_motives %>%
    group_by(disp_motive) %>%
    summarise(n = n())
  df_motives$prob <- df_motives$n / sum(df_motives$n)
  
  df_motives$prototype_ID <- df_prototypes[i,]$prototype_ID
  
  df_motive_probabilities <- rbind(df_motive_probabilities, df_motives)
}

df_motive_probabilities <- merge(df_motive_probabilities, df_prototypes, by=c('prototype_ID'))

write.csv(df_motive_probabilities, 'df_motive_probabilities.csv', row.names = FALSE)
