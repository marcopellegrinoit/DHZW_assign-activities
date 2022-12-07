pkgs <- c("sf", "sp", "rgdal", "spatialEco")
sapply(pkgs, require, character.only = T) #load packages
rm(pkgs)

library(readr)
library("this.path")
library(maptools)
setwd(this.path::this.dir())

df = st_read('CBS-PC6-2019-v2')

df$PC4 = gsub('.{2}$', '', df$PC6)

library(dplyr)

dhzw = df %>%
  filter(PC4 %in% DHZW_PC4_codes$X1)

dhzw = dhzw %>%
  select(PC6, geometry)

st_write(dhzw, 'DHZW_PC6_shapefile.shp')
