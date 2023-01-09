filter_attributes_ODiN <- function(df) {
  df <- df %>%
    sjlabelled::remove_all_labels() %>%
    tibble()    # without this, results will be cast as a list
  
  df <- df %>%
    select(
      OPID,
      HHPers,
      HHPlOP,
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
      VerplNr
    ) %>%
    rename(
      agent_ID = OPID,
      hh_size = HHPers,
      hh_position = HHPlOP,
      gender = Geslacht,
      age = Leeftijd,
      migration_background = Herkomst,
      hh_std_income = HHGestInkG,
      day_of_week = Weekdag,
      disp_activity = Doel,
      disp_start_hour = VertUur,
      disp_start_min = VertMin,
      disp_arrival_hour = AankUur,
      disp_arrival_min = AankMin,
      year = Jaar,
      disp_start_home = VertLoc,
      disp_start_PC4 = VertPC,
      disp_counter = VerplNr
    ) %>%
    distinct()

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
      HHPlOP,
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
      VerplNr
    ) %>%
    rename(
      agent_ID = OPID,
      hh_size = HHPers,
      hh_position = HHPlOP,
      gender = Geslacht,
      age = Leeftijd,
      migration_background = Herkomst,
      hh_std_income = HHGestInkG,
      day_of_week = Weekdag,
      disp_activity = Doel,
      disp_start_hour = VertUur,
      disp_start_min = VertMin,
      disp_arrival_hour = AankUur,
      disp_arrival_min = AankMin,
      year = Jaar,
      disp_start_home = Vertrekp,
      disp_start_PC4 = VertPC,
      disp_counter = VerplNr
    ) %>%
    distinct()
  
  return(df)
}

format_values <- function(df){
  df$hh_position <- recode(
    df$hh_position,
    '1' = 'single household',
    '2' = 'couple',
    '3' = 'couple + child(ren)',
    '4' = 'couple + child(ren) + other(s)',
    '5' = 'couple + other(s)',
    '6' = 'single-parent household + child(ren)',
    '7' = 'single-parent household + child(ren) + other(s)',
    '8' = 'other household',
    '9' = 'unknown'
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
home_municipality_to_PC4 <- function(df, df_PC4) {
  # find the starting point of the first move, and set it as home
  df$hh_PC4=NA
  df[df$disp_counter==1,]$hh_PC4 = as.character(df[df$disp_counter==1,]$disp_start_PC4)
  
  # apply attribute to all the rows of the agent
  df <- df %>%
    group_by(agent_ID) %>% 
    mutate(hh_PC4 = zoo::na.locf(hh_PC4, na.rm=FALSE))
  
  # Remove useless column
  df <- subset(df, select=-c(disp_counter, disp_start_PC4))
  return(df)
}

# Filter agents that only start the day from home
filter_start_day_from_home <- function (df) {
  agents_home <- df %>% 
    group_by(agent_ID) %>% 
    filter(any(disp_start_home==1 &
                 disp_counter==1))
  df <- filter(df, (agent_ID %in% unique(agents_home$agent_ID)))
  
  
  # Filter agents starting the day from home
  df <- df[df$disp_start_home==1,]
  
  # Remove useless column
  df <- subset(df, select=-c(disp_start_home))
  return(df)
}