library('haven')
library("dplyr")
library(tibble)
library(tidyr)
library(readr)
library("this.path")
setwd(this.path::this.dir())
source('src/utils.R')

################################################################################
# This script put together the various years of ODiN and OVin into a big collection

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

OViN2010 <- filter_attributes_OViN(OViN2010)
OViN2011 <- filter_attributes_OViN(OViN2011)
OViN2012 <- filter_attributes_OViN(OViN2012)
OViN2013 <- filter_attributes_OViN(OViN2013)
OViN2014 <- filter_attributes_OViN(OViN2014)
OViN2015 <- filter_attributes_OViN(OViN2015)
OViN2016 <- filter_attributes_OViN(OViN2016)
OViN2017 <- filter_attributes_OViN(OViN2017)
ODiN2018 <- filter_attributes_ODiN(ODiN2018)
ODiN2019 <- filter_attributes_ODiN(ODiN2019)

################################################################################
# ODiN

df_ODiN <- rbind(ODiN2018,
                 ODiN2019)

# Filter individuals that live in a PC4 with the same DHZW urbanization index.

# Find PC4 in The Netherlands with the same urbanization index of DHZW. STED is the index and 1 is the highest
# Extracted from: https://www.cbs.nl/nl-nl/dossier/nederland-regionaal/geografische-data/gegevens-per-postcode

setwd(this.dir())
setwd("../DHZW_shapefiles/data/codes")
df_urbanization_PC4 <-
  read_delim("PC4_CBS_2019_urbanization_index.csv", delim = ';')

# Read list of all PC4 in the Netherlands and their urbanization indexes.
setwd(this.dir())
setwd("../DHZW_shapefiles/data/codes")
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1

# Find all the PC4s in The Netherlands that have such STED index equals to 1 "Very highly urban" (environmental address density of 2500 or more addresses/km2)
PC4_urbanized_like_DHZW = df_urbanization_PC4[df_urbanization_PC4$STED ==
                                                1,]$PC4

# In ODiN, filter only individuals that live in such highly urbanized PC4s
df_ODiN <- df_ODiN[df_ODiN$hh_PC4 %in% PC4_urbanized_like_DHZW,]

################################################################################
# OViN

df_OViN <- rbind(OViN2010,
                 OViN2011,
                 OViN2012,
                 OViN2013,
                 OViN2014,
                 OViN2015,
                 OViN2016,
                 OViN2017)

# Since the residential PC4 is not given, for the individuals that at have least one displacement I retrieve it from the first displacement.
df_OViN <- extract_residential_PC4_from_first_displacement(df_OViN)

# Individuals that stay at home all day. Filter based on the given municipality urbanization index
df_OViN_stay_home <- df_OViN[is.na(df_OViN$disp_counter) & df_OViN$municipality_urbanization==1,]

# Individuals with at least a displacement. Filter on the extracted residential PC4 and its urbanization index (like with ODiN).
df_OViN_with_disp <- df_OViN[!is.na(df_OViN$disp_counter),]
df_OViN_with_disp <- df_OViN[df_OViN$hh_PC4 %in% PC4_urbanized_like_DHZW,]

df_OViN <- rbind(df_OViN_with_disp, df_OViN_stay_home)
df_OViN <- subset(df_OViN, select=-c(municipality_urbanization))

################################################################################

df <- rbind(df_OViN,
            df_ODiN)

# For individuals with at least a displacement, filter only the ones that start the  day from one. This is because in the simulation the delibration cycle is at midnight everyday, so the agetns must then start from home everyday.
df <- filter_start_day_from_home(df)

# is no moves (the individual stays at home all day), the counter is 0.
df[is.na(df$disp_counter),]$disp_counter <- 0

# format the values of the attributes
df <- format_values(df)

################################################################################
# Calculate times

df$disp_start_time <- df$disp_start_hour * 60 + df$disp_start_min
df$disp_arrival_time <-
  df$disp_arrival_hour * 60 + df$disp_arrival_min
df <-
  subset(
    df,
    select = -c(
      year,
      disp_start_hour,
      disp_start_min,
      disp_arrival_hour,
      disp_arrival_min
    )
  )

################################################################################
# Data cleaning

# Delete agents that have missing demographic information that are used later for the matching
IDs_to_delete = df[df$migration_background == 'unknown', ]$agent_ID
df <- df[!(df$agent_ID %in% IDs_to_delete),]

unique(df$gender)
unique(df$age)
unique(df$migration_background)
unique(df$day_of_week)

# Delete agents that have missing trip information. NA can be only for people that stay at home all day
IDs_to_delete = df[(is.na(df$disp_activity) | is.na(df$disp_start_time) | is.na(df$disp_arrival_time)) & df$disp_counter > 0,]$agent_ID
df <- df[!(df$agent_ID %in% IDs_to_delete),]

# just check some figures
nrow(df[is.na(df$disp_activity),])
nrow(df[is.na(df$disp_start_time),])
nrow(df[is.na(df$disp_arrival_time),])
nrow(df[is.na(df$disp_start_PC4),])
nrow(df[is.na(df$disp_arrival_PC4),])

# Save dataset
setwd(paste0(this.path::this.dir(), "/data/processed"))
write.csv(df, 'df_trips-higly_urbanized.csv', row.names = FALSE)