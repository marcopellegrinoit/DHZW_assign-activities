library(haven)
library("dplyr")
library(tibble)
library(tidyr)
library(readr)
library("this.path")
setwd(this.path::this.dir())
source('src/utils_activity_schedule.R')

################################################################################
# This script put together the various years of ODiN into a big collection

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

df <- bind_rows(
  OViN2010,
  OViN2011,
  OViN2012,
  OViN2013,
  OViN2014,
  OViN2015,
  OViN2016,
  OViN2017,
  ODiN2018,
  ODiN2019
)

df <- filter_start_day_from_home(df)
df <- home_municipality_to_PC4(df)
df <- format_values(df)

################################################################################
If (TRUE) {
  # Find PC4 in The Netherlands with the same urbanization index of DHZW
  setwd(paste0(this.path::this.dir(), "/data/processed"))
  df_urbanization_PC4 <-
    read_delim("PC4_CBS_2019_urbanization_index.csv", delim = ';')
  
  setwd(paste0(this.path::this.dir(), "/data/codes"))
  DHZW_PC4_codes <-
    read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1
  
  df_urbanization_PC4_DHZW = df_urbanization_PC4[df_urbanization_PC4$PC4 %in% DHZW_PC4_codes,]
  # all the PC4 of DHZW are "Very highly urban" (environmental address density of 2 500 or more addresses/km2)
  
  # so, find all the PC4s in The Netherlands that have such STED index equals to 1
  
  PC4_urbanized_like_DHZW = df_urbanization_PC4[df_urbanization_PC4$STED ==
                                                  1,]$PC4
  
  df <- df[df$hh_PC4 %in% PC4_urbanized_like_DHZW,]
} else {
  # Filter DHZW area only
  setwd(paste0(this.path::this.dir(), "/data/codes"))
  DHZW_PC4_codes <-
    read.csv("DHZW_PC4_codes.csv", sep = ";" , header = F)$V1
  
  df <- df[df$hh_PC4 %in% DHZW_PC4_codes,]
}


################################################################################
# Calculate departure time
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

df$hh_position <- recode(
  df$hh_position,
  'couple + child(ren)' = 'couple with children',
  'couple + child(ren) + other(s)' = 'couple with children',
  'single household' = 'single',
  'couple' = 'couple without children',
  'couple + other(s)' = 'couple without children',
  'single-parent household + child(ren)' = 'single-parent',
  'single-parent household + child(ren) + other(s)' = 'single-parent',
)

# Delete agents that have missing important information
IDs_to_delete = df[df$migration_background == 'unknown' |
                     df$hh_std_income == 11 |
                     is.na(df$hh_position) |
                     df$hh_position == 'unknown' |
                     df$hh_position == 'other household' |
                     is.na(df$disp_activity) |
                     is.na(df$disp_start_time) |
                     is.na(df$disp_arrival_time), ]
df <- df[!(df$agent_ID %in% IDs_to_delete),]

df[df$hh_size >= 5, ]$hh_size <- 5

# Save dataset
setwd(paste0(this.path::this.dir(), "/data/processed"))
write.csv(df, 'df_activity_trips.csv', row.names = FALSE)