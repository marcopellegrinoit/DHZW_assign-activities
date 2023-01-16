library(readr)
library(this.path)
library(dplyr)

setwd(this.dir())
setwd('../data/')

df <- read.csv('marginals_NL_84583NED.csv', sep=';')
df <- df[df$SoortRegio_2 == 'Wijk      ',]

df <- df %>%
  select(Gemeentenaam_1,
         Codering_3,
         AantalInwoners_5,
         Mannen_6,
         Vrouwen_7,
         k_0Tot15Jaar_8,
         k_15Tot25Jaar_9 ,
         k_25Tot45Jaar_10 ,
         k_45Tot65Jaar_11 ,
         k_65JaarOfOuder_12 ,
         WestersTotaal_17 ,
         NietWestersTotaal_18 ,
         OpleidingsniveauLaag_64 ,
         OpleidingsniveauMiddelbaar_65 ,
         OpleidingsniveauHoog_66,
         GemiddeldInkomenPerInwoner_72 ,
         MateVanStedelijkheid_115)

library(sf)
df_names <- st_read('map/WijkBuurtkaart_2019_v3')

df_almere <- readxl::read_xlsx('Stads.xlsx')

df_almere$wijk_code <- paste0('WK', df_almere$wijk_code, '  ')

marginal_almere <- merge(df, df_almere, by.x='WijkenEnBuurten', by.y='wijk_code')