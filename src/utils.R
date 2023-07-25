filter_attributes_ODiN <- function(df) {
  df <- df %>%
    sjlabelled::remove_all_labels() %>%
    tibble()    # without this, results will be cast as a list
  
  df <- df %>%
    select(
      OPID,
      HHPers,
      HHSam,
      WoPC,
      Geslacht,
      Leeftijd,
      Herkomst,
      HHGestInkG,
      Weekdag,
      Doel,
      VertUur,
      VertMin,
      AankUur,
      AankMin,
      Jaar,
      VertLoc,
      VertPC,
      AankPC,
      VerplNr,
      Hvm
    ) %>%
    rename(
      agent_ID = OPID,
      hh_size = HHPers,
      hh_type = HHSam,
      hh_PC4 = WoPC,
      gender = Geslacht,
      age = Leeftijd,
      migration_background = Herkomst,
      hh_income_group = HHGestInkG,
      day_of_week = Weekdag,
      disp_activity = Doel,
      disp_start_hour = VertUur,
      disp_start_min = VertMin,
      disp_arrival_hour = AankUur,
      disp_arrival_min = AankMin,
      year = Jaar,
      disp_start_home = VertLoc,
      disp_start_PC4 = VertPC,
      disp_arrival_PC4 = AankPC,
      disp_counter = VerplNr,
      disp_modal_choice = Hvm
    ) %>%
    distinct()
  
  df$disp_modal_choice <- recode(
    df$disp_modal_choice,
    '1' = 'car',
    '2' = 'train',
    '3' = 'bus_tram',
    '4' = 'bus_tram',
    '5' = 'other',
    '6' = 'other',
    '7' = 'other',
    '8' = 'bike',
    '9' = 'walk',
    '10' =	'bus_tram',
    '11' =	'other',
    '12' =	'other',
    '13' =	'other',
    '14' =	'other',
    '15' =	'other',
    '16' =	'other',
    '17' =	'other',
    '18' =	'other',
    '19' =	'other',
    '20' =	'other',
    '21' =	'other',
    '22' =	'other',
    '24' =	'other',
    '24' =	'other'
  )
  
  return(df)
}

filter_attributes_OViN <- function(df) {
  df <- df %>%
    sjlabelled::remove_all_labels() %>%
    tibble()    # without this, results will be cast as a list
  
  df <- df %>%
    select(
      OPID,
      HHPers,
      HHSam,
      Geslacht,
      Leeftijd,
      Herkomst,
      HHGestInkG,
      Weekdag,
      Doel,
      VertUur,
      VertMin,
      AankUur,
      AankMin,
      Jaar,
      Vertrekp,
      VertPC,
      AankPC,
      VerplNr,
      Sted,
      Hvm
    ) %>%
    rename(
      agent_ID = OPID,
      hh_size = HHPers,
      hh_type = HHSam,
      gender = Geslacht,
      age = Leeftijd,
      migration_background = Herkomst,
      hh_income_group = HHGestInkG,
      day_of_week = Weekdag,
      disp_activity = Doel,
      disp_start_hour = VertUur,
      disp_start_min = VertMin,
      disp_arrival_hour = AankUur,
      disp_arrival_min = AankMin,
      year = Jaar,
      disp_start_home = Vertrekp,
      disp_start_PC4 = VertPC,
      disp_arrival_PC4 = AankPC,
      disp_counter = VerplNr,
      municipality_urbanization = Sted,
      disp_modal_choice = Hvm
    ) %>%
    distinct()
  
  df$disp_modal_choice <- recode(
    df$disp_modal_choice,
    '1' = 'train',
    '2' = 'other',
    '3' = 'other',
    '4' = 'bus_tram',
    '5' = 'bus_tram',
    '6' = 'car',
    '7' = 'other',
    '8' = 'other',
    '9' = 'other',
    '10' =	'car',
    '11' =	'other',
    '12' =	'other',
    '13' =	'other',
    '14' =	'other',
    '15' =	'bike',
    '16' =	'other',
    '17' =	'other',
    '18' =	'other',
    '19' =	'other',
    '20' =	'other',
    '21' =	'other',
    '22' =	'walk',
    '24' =	'other',
    '24' =	'other'
    )
    
  return(df)
}

format_values <- function(df){
  df$hh_type <- recode(
    df$hh_type,
    '1' = 'single',
    '2' = 'couple_without_children',
    '3' = 'couple_with_children',
    '4' = 'couple_with_children',
    '5' = 'couple_without_children',
    '6' = 'single_parent',
    '7' = 'single_parent',
    '8' = 'other',
    '9' = 'unknown',
    '10' = 'unknown'
  )
  
  df$hh_income_group <- recode(
    df$hh_income_group,
    '1' = 'income_1_10',
    '2' = 'income_2_10',
    '3' = 'income_3_10',
    '4' = 'income_4_10',
    '5' = 'income_5_10',
    '6' = 'income_6_10',
    '7' = 'income_7_10',
    '8' = 'income_8_10',
    '9' = 'income_9_10',
    '10' = 'income_10_10',
    '11' = 'unknown'
  )
  
  df$gender <- recode(df$gender, 
                      '1' =	'male',
                      '2' =	'female')
  
  df$migration_background <- recode(
    df$migration_background,
    '1' = 'Dutch',
    '2' = 'Western',
    '3' = 'Non_Western',
    '4' = 'unknown'
  )
  
  df$disp_activity <- recode(
    df$disp_activity,
    '1' = 'to home',
    '2' = 'to work',
    '3' = 'business visit',
    '4' = 'transport is the job',
    '5' = 'pick up / bring people',
    '6' = 'collection/delivery of goods',
    '7' = 'follow education',
    '8' = 'shopping',
    '9' = 'visit/stay',
    '10' =	'hiking',
    '11' =	'sports/hobby',
    '12' =	'other leisure activities',
    '13' =	'services/personal care',
    '14' =	'other'
  )
  
  return(df)
}

# Use the PC4 of the first day displacement (from home) as home address
extract_residential_PC4_from_first_displacement <- function(df) {
  df$hh_PC4=NA
  
  # Isolate the individuals that stay at home
  df_no_moves <- df[is.na(df$disp_counter),]
  
  # Consider individuals with at least a displacement. Find the starting point of the first move, and set it as home
  df <- df[!is.na(df$disp_counter),]
  df[df$disp_counter==1,]$hh_PC4 = as.character(df[df$disp_counter==1,]$disp_start_PC4)
  
  # apply residential PC4 to all the rows of the individual
  df <- df %>%
    group_by(agent_ID) %>% 
    #mutate(hh_PC4 = dplyr::first(hh_PC4)) %>%
    mutate(hh_PC4 = zoo::na.locf(hh_PC4, na.rm=FALSE))
  
  # add again the individuals that stay at home all day
  
  df <- rbind(df, df_no_moves)
  return(df)
}

# Filter agents that only start the day from home, or stay at home all day
filter_start_day_from_home <- function (df) {
  agents_home_IDs <- unique(df[((df$disp_start_home==1 & df$disp_counter==1) | is.na(df$disp_counter)),]$agent_ID)

  df[df$agent_ID %in% agents_home_IDs,]
  
  # Remove useless column
  df <- subset(df, select=-c(disp_start_home))
  return(df)
}