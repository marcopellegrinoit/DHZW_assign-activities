library("this.path")
library(dplyr)
library (readr)
library(sf)
setwd(this.path::this.dir())

# Load PC4 DHZW
setwd('../../data/codes')
DHZW_PC4_codes <-
  read.csv("DHZW_PC4_codes.csv",
           sep = ";" ,
           header = F)$V1

setwd(this.path::this.dir())
df_schools <- st_read('schoolgebouwen')

df_schools <- df_schools %>%
  select(bestemming,
         school,
         postcode,
         geometry) %>%
  rename(type = bestemming,
         name = school,
         PC6 = postcode) %>%
  mutate(PC6 = gsub(' ', '', PC6)) %>%
  mutate(PC4 = gsub('.{2}$', '', PC6)) %>%
  filter(PC4 %in% DHZW_PC4_codes)

st_geometry(df_schools[df_schools$name == "De Ark Chr. Basisschool" & df_schools$PC6 == '2546SP', ]) <-  st_sfc(st_point(c(78426, 452620)))
st_geometry(df_schools[df_schools$name == "De Wissel" & df_schools$PC6 == '2541RL' & df_schools$type == 'GYM', ]) <-  st_sfc(st_point(c(79395.0, 451325)))
st_geometry(df_schools[df_schools$name == "De Kleine Wereld" & df_schools$PC6 == '2531VP' & df_schools$type == 'GYM', ]) <-  st_sfc(st_point(c(80640, 452449)))

plot(df_schools$geometry)

df_schools$category = ''
df_schools[df_schools$type == 'SO/VSO' | df_schools$type == 'BO' | df_schools$type == 'BO-Voorschool', ]$category = 'primary school'
df_schools[df_schools$type == 'VO' | df_schools$type == 'GYM' | df_schools$type == 'Sport', ]$category = 'secondary school'

df_schools = df_schools %>%
  select(-c(type)) %>%
  distinct(name, PC4, category, .keep_all = TRUE)

st_write(df_schools, 'municipality_schools', driver = "ESRI Shapefile")