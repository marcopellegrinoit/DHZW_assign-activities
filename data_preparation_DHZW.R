library(haven)
library("dplyr")
library(tibble)
library(tidyr)
library(readr)
library("this.path")
setwd(this.path::this.dir())
source('src/utils.R')

# load DHZW area
setwd(paste0(this.path::this.dir(), "/data/codes"))
DHZW_neighborhood_codes <- read.csv("DHZW_neighbourhoods_codes.csv", sep = ";" ,header=F)$V1
DHZW_PC4_codes <- read.csv("DHZW_PC4_codes.csv", sep = ";" ,header=F)$V1
municipality_code = 518

# Load ODiNs and OViNs
setwd(paste0(this.path::this.dir(), "/data/OViN and OViN"))

OViN2010 <- read_sav("OViN2010.sav")
OViN2011 <- read_sav("OViN2011.sav")
OViN2012 <- read_sav("OViN2012.sav")
OViN2013 <- read_sav("OViN2013.sav")
OViN2014 <- read_sav("OViN2014.sav")
OViN2015 <- read_sav("OViN2015.sav")
OViN2016 <- read_sav("OViN2016.sav")
OViN2017 <- read_sav("OViN2017.sav")
ODiN2018 <- read_sav("ODiN2018.sav")
ODiN2019 <- read_sav("ODiN2019.sav")

# Filter attributes
OViN2010 <- rename(OViN2010, Wogem = WoGem)
OViN2010 <- rename(OViN2010, Rvm = RVm)
OViN2011 <- rename(OViN2011, Rvm = RVm)
OViN2012 <- rename(OViN2012, Rvm = RVm)
OViN2013 <- rename(OViN2013, Rvm = RVm)

OViN2010 <- select_attributes_OViN_2014(OViN2010)
OViN2011 <- select_attributes_OViN_2014(OViN2011)
OViN2012 <- select_attributes_OViN_2014(OViN2012)
OViN2013 <- select_attributes_OViN_2014(OViN2013)
OViN2014 <- select_attributes_OViN_2014(OViN2014)
OViN2015 <- select_attributes_OViN(OViN2015)
OViN2016 <- select_attributes_OViN(OViN2016)
OViN2017 <- select_attributes_OViN(OViN2017)
ODiN2018 <- select_attributes_ODiN(ODiN2018)
ODiN2019 <- select_attributes_ODiN(ODiN2019)

################################################################################
# Filter agents that live in DHZW

OViN2010 <- filter_start_day_from_home(OViN2010)
OViN2011 <- filter_start_day_from_home(OViN2011)
OViN2012 <- filter_start_day_from_home(OViN2012)
OViN2013 <- filter_start_day_from_home(OViN2013)
OViN2014 <- filter_start_day_from_home(OViN2014)
OViN2015 <- filter_start_day_from_home(OViN2015)
OViN2016 <- filter_start_day_from_home(OViN2016)
OViN2017 <- filter_start_day_from_home(OViN2017)
ODiN2018 <- filter_start_day_from_home(ODiN2018)
ODiN2019 <- filter_start_day_from_home(ODiN2019)

# Filter The Hague home address in OViN
OViN2010 <- filter_hh_municipality(OViN2010, municipality_code)
OViN2011 <- filter_hh_municipality(OViN2011, municipality_code)
OViN2012 <- filter_hh_municipality(OViN2012, municipality_code)
OViN2013 <- filter_hh_municipality(OViN2013, municipality_code)
OViN2014 <- filter_hh_municipality(OViN2014, municipality_code)
OViN2015 <- filter_hh_municipality(OViN2015, municipality_code)
OViN2016 <- filter_hh_municipality(OViN2016, municipality_code)
OViN2017 <- filter_hh_municipality(OViN2017, municipality_code)

# In OViN, convert the home address from municipality to PC4 level
OViN2010 <- home_municipality_to_PC4(OViN2010)
OViN2011 <- home_municipality_to_PC4(OViN2011)
OViN2012 <- home_municipality_to_PC4(OViN2012)
OViN2013 <- home_municipality_to_PC4(OViN2013)
OViN2014 <- home_municipality_to_PC4(OViN2014)
OViN2015 <- home_municipality_to_PC4(OViN2015)
OViN2016 <- home_municipality_to_PC4(OViN2016)
OViN2017 <- home_municipality_to_PC4(OViN2017)

# Filter DHZW in ODiN and OViN
OViN2010 <- filter_hh_PC4(OViN2010, DHZW_PC4_codes)
OViN2011 <- filter_hh_PC4(OViN2011, DHZW_PC4_codes)
OViN2012 <- filter_hh_PC4(OViN2012, DHZW_PC4_codes)
OViN2013 <- filter_hh_PC4(OViN2013, DHZW_PC4_codes)
OViN2014 <- filter_hh_PC4(OViN2014, DHZW_PC4_codes)
OViN2015 <- filter_hh_PC4(OViN2015, DHZW_PC4_codes)
OViN2016 <- filter_hh_PC4(OViN2016, DHZW_PC4_codes)
OViN2017 <- filter_hh_PC4(OViN2017, DHZW_PC4_codes)
ODiN2018 <- filter_hh_PC4(ODiN2018, DHZW_PC4_codes)
ODiN2019 <- filter_hh_PC4(ODiN2019, DHZW_PC4_codes)

OViN <- bind_rows(OViN2010,
                  OViN2011,
                  OViN2012,
                  OViN2013,
                  OViN2014,
                  OViN2015,
                  OViN2016,
                  OViN2017)
ODiN <- bind_rows(ODiN2018,
                  ODiN2019)

# Format modal choices, because they differ between ODiN and OViN
OViN <- format_modal_choice_OViN(OViN)
OViN <- format_role_OViN(OViN)

ODiN <- format_modal_choice_ODiN(ODiN)
ODiN <- format_role_ODiN(ODiN)


# Some statistics
print(paste0('N agents OViN 2014: ', length(unique(OViN2014$agent_ID))))
print(paste0('N agents OViN 2015: ', length(unique(OViN2015$agent_ID))))
print(paste0('N agents OViN 2016: ', length(unique(OViN2016$agent_ID))))
print(paste0('N agents OViN 2017: ', length(unique(OViN2017$agent_ID))))
print(paste0('N agents ODiN 2018: ', length(unique(ODiN2018$agent_ID))))
print(paste0('N agents ODiN 2019: ', length(unique(ODiN2019$agent_ID))))

print(paste0('N agents in total: ', length(unique(OViN2014$agent_ID))+
               length(unique(OViN2015$agent_ID))+
               length(unique(OViN2016$agent_ID))+
               length(unique(OViN2017$agent_ID))+
               length(unique(ODiN2018$agent_ID))+
               length(unique(ODiN2019$agent_ID))))

# Merge datasets into one
df <- bind_rows(OViN, ODiN)

# Save dataset
setwd(paste0(this.path::this.dir(), "/data/processed"))
write.csv(df, 'df_DHZW.csv', row.names=FALSE)

################################################################################
# Formatting of attributes and removal of incomplete

# Load DHZW dataset
setwd(paste0(this.path::this.dir(), "/data/Formatted"))
df <- read_csv("df_DHZW.csv")

print(length(unique(df$agent_ID))) # 710

# Remove displacements that are completely outside of DHZW
df <- df[df$disp_start_PC4 %in% DHZW_PC4_codes | df$disp_arrival_PC4 %in% DHZW_PC4_codes,]

print(length(unique(df$agent_ID))) # 710

# Remove agents that have incomplete information about displacements:
agents_incomplete <- df %>%
  group_by(agent_ID) %>%
  filter(any(
    !is.na(disp_id) & (
      is.na(disp_start_PC4) |
        is.na(disp_arrival_PC4) |
        is.na(disp_modal_choice) |
        is.na(disp_start_hour) |
        is.na(disp_start_min) |
        is.na(disp_arrival_hour) |
        is.na(disp_arrival_min)
    )
  ))
df <- filter(df, !(agent_ID %in% unique(agents_incomplete$agent_ID)))

print(length(unique(df$agent_ID))) # 707

# Format values in attributes
df <- format_values(df)

# Save dataset
setwd(paste0(this.path::this.dir(), "/data/Formatted"))
write.csv(df, 'df_DHZW.csv', row.names=FALSE)