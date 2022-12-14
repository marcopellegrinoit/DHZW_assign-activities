library(readr)
library(dplyr)

# compare DHZW and the highly urbanized area pool

################################################################################

setwd(paste0(this.path::this.dir(), "/data/processed"))
df_urbanization_PC4 <-
  read_delim("PC4_CBS_2019_urbanization_index.csv", delim = ';')

setwd(paste0(this.path::this.dir(), "/data/codes"))
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

df_urbanization_PC4_DHZW = df_urbanization_PC4[df_urbanization_PC4$PC4 %in% DHZW_PC4_codes, ]
# all the PC4 of DHZW are "Very highly urban" (environmental address density of 2 500 or more addresses/km2)

# so, find all the PC4s in The Netherlands that have such STED index equals to 1

PC4_urbanized_like_DHZW = df_urbanization_PC4[df_urbanization_PC4$STED ==
                                                1, ]$PC4

################################################################################


library(sf)

setwd(this.path::this.dir())

df_PC4 <- st_read('data/CBS-PC4-2019')

df_PC4 <- df_PC4 %>%
  select(PC4,
         MAN,
         VROUW,
         INW_014,
         INW_1524,
         INW_2544,
         INW_4564,
         INW_65PL,
         P_NL_ACHTG,
         P_WE_MIG_A,
         P_NW_MIG_A) %>%
  rename(
    'male' = 'MAN',
    'female' = 'VROUW',
    'age_0_14' = 'INW_014',
    'age_15_24' = 'INW_1524',
    'age_25_44' = 'INW_2544',
    'age_45_64' = 'INW_4564',
    'age_over_65' = 'INW_65PL',
    'migration_Dutch' = 'P_NL_ACHTG',
    'migration_Western' = 'P_WE_MIG_A',
    'migration_Non_Western' = 'P_NW_MIG_A'
  )


df_PC4 <- as.data.frame(df_PC4)
df_PC4 = subset(df_PC4, select = -c(geometry))

df_PC4[df_PC4 == -99997] <- 0

# DHZW formatting

df_PC4_DHZW <- df_PC4[df_PC4$PC4 %in% DHZW_PC4_codes,]

df_PC4_DHZW = subset(df_PC4_DHZW, select = -c(PC4))

df_PC4_DHZW <- df_PC4_DHZW %>%
  summarise_all(.funs = sum,na.rm=T)

df_PC4_DHZW[1, c('male', 'female')] <- df_PC4_DHZW[1, c('male', 'female')] / sum(df_PC4_DHZW[1, c('male', 'female')])
df_PC4_DHZW[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')] <- df_PC4_DHZW[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')] / sum(df_PC4_DHZW[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')])
df_PC4_DHZW[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')] <- df_PC4_DHZW[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')] / sum(df_PC4_DHZW[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')])

# Pool formatting

df_PC4_pool <- df_PC4[df_PC4$PC4 %in% PC4_urbanized_like_DHZW,]

df_PC4_pool = subset(df_PC4_pool, select = -c(PC4))

df_PC4_pool <- df_PC4_pool %>%
  summarise_all(.funs = sum,na.rm=T)

df_PC4_pool[1, c('male', 'female')] <- df_PC4_pool[1, c('male', 'female')] / sum(df_PC4_pool[1, c('male', 'female')])
df_PC4_pool[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')] <- df_PC4_pool[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')] / sum(df_PC4_pool[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')])
df_PC4_pool[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')] <- df_PC4_pool[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')] / sum(df_PC4_pool[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')])
                                              
################################################################################
# Plot comparison

library (ggplot2)
library(tidyr)

# Gender

df_PC4_pool_gender <- df_PC4_pool %>%
  select(male, female) %>%
  pivot_longer(cols = c('male', 'female'), names_to = "gender", values_to = "proportion")
df_PC4_pool_gender$dataset <- 'pool'

df_PC4_DHZW_gender <- df_PC4_DHZW %>%
  select(male, female) %>%
  pivot_longer(cols = c('male', 'female'), names_to = "gender", values_to = "proportion")
df_PC4_DHZW_gender$dataset <- 'DHZW'

df_PC4_gender_plot <- rbind(df_PC4_pool_gender, df_PC4_DHZW_gender)

ggplot(df_PC4_gender_plot, aes(gender, proportion)) +
  geom_bar(
           aes(fill = dataset),
           position = "dodge",
           stat = "identity",
           width=0.4)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ggtitle("Proportions of genders")+
  ylab("Proportion (%)")+
  xlab("Gender")+
  labs(fill = "Dataset")+
  theme(legend.title=element_text(size=20),
        legend.text=element_text(size=15)) +
  ylim(0, 1)

# Age groups

df_PC4_pool_age <- df_PC4_pool %>%
  select(age_0_14, age_15_24, age_25_44, age_45_64, age_over_65) %>%
  pivot_longer(cols = c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65'), names_to = "agegroup", values_to = "proportion")
df_PC4_pool_age$dataset <- 'pool'

df_PC4_DHZW_age <- df_PC4_DHZW %>%
  select(age_0_14, age_15_24, age_25_44, age_45_64, age_over_65) %>%
  pivot_longer(cols = c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65'), names_to = "agegroup", values_to = "proportion")
df_PC4_DHZW_age$dataset <- 'DHZW'

df_PC4_age_plot <- rbind(df_PC4_pool_age, df_PC4_DHZW_age)

ggplot(df_PC4_age_plot, aes(agegroup, proportion)) +
  geom_bar(
    aes(fill = dataset),
    position = "dodge",
    stat = "identity",
    width=0.4)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ggtitle("Proportions of group ages")+
  ylab("Proportion (%)")+
  xlab("Gender")+
  labs(fill = "Dataset")+
  theme(legend.title=element_text(size=20),
        legend.text=element_text(size=15)) +
  ylim(0, 1)

# Migration

df_PC4_pool_migration <- df_PC4_pool %>%
  select(migration_Dutch, migration_Western, migration_Non_Western) %>%
  pivot_longer(cols = c('migration_Dutch', 'migration_Western', 'migration_Non_Western'), names_to = "migration", values_to = "proportion")
df_PC4_pool_migration$dataset <- 'pool'

df_PC4_DHZW_migration <- df_PC4_DHZW %>%
  select(migration_Dutch, migration_Western, migration_Non_Western) %>%
  pivot_longer(cols = c('migration_Dutch', 'migration_Western', 'migration_Non_Western'), names_to = "migration", values_to = "proportion")
df_PC4_DHZW_migration$dataset <- 'DHZW'

df_PC4_migration_plot <- rbind(df_PC4_pool_migration, df_PC4_DHZW_migration)

ggplot(df_PC4_migration_plot, aes(migration, proportion)) +
  geom_bar(
    aes(fill = dataset),
    position = "dodge",
    stat = "identity",
    width=0.4)+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  ggtitle("Proportions of migration backgrounds")+
  ylab("Proportion (%)")+
  xlab("Gender")+
  labs(fill = "Dataset")+
  theme(legend.title=element_text(size=20),
        legend.text=element_text(size=15)) +
  ylim(0, 1)

################################################################################
# Test

library(EMT)
# p-value > 0.5 means equal

out <- multinomial.test(as.numeric(df_PC4_pool[1, c('male', 'female')]), as.numeric(df_PC4_DHZW[1, c('male', 'female')]))
multinomial.test(as.numeric(df_age[2,]), as.numeric(df_age[2,]), size=5)
multinomial.test(as.numeric(df_PC4_pool[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')]), as.numeric(df_PC4_DHZW[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')]))

observed <- as.numeric(df_PC4_pool[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')])
expProb <- as.numeric(df_PC4_DHZW[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')])

# KL
library(philentropy)
df_gender <- rbind(as.numeric(df_PC4_pool[1, c('male', 'female')]),
                   as.numeric(df_PC4_DHZW[1, c('male', 'female')]))
KL(df_gender)

df_age <- rbind(as.numeric(df_PC4_pool[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')]),
                as.numeric(df_PC4_DHZW[1, c('age_0_14', 'age_15_24', 'age_25_44', 'age_45_64', 'age_over_65')]))
KL(df_age)

df_migration <- rbind(as.numeric(df_PC4_pool[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')]),
                      as.numeric(df_PC4_DHZW[1, c('migration_Dutch', 'migration_Western', 'migration_Non_Western')]))
KL(df_migration)