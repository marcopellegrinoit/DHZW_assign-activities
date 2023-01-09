# DHZW_assign-travel-behaviours

 - [data_preparation_activity](https://github.com/mr-marco/DHZW_assign-travel-behaviours/blob/main/data_preparation_activity.R "data_preparation_activity.R")
	 - Put together various years [2013-2019] of ODiN and OViN into a big collection
	 - Output: *df_activity_trips.csv*
 - [generate_activity_summary](https://github.com/mr-marco/DHZW_assign-travel-behaviours/blob/main/generate_activity_summary.R "generate_activity_summary.R")
	 - Transform the trips collection into activities for each participant
	 - *df_activity_schedule_DHZW.csv*
 - [matching_IDs_synthetic_ODiN](https://github.com/mr-marco/DHZW_assign-travel-behaviours/blob/main/matching_IDs_synthetic_ODiN.R "matching_IDs_synthetic_ODiN.R")
	 - For each synthetic agent, a correspondent ODiN participant is assigned per each week day
	 - Output: *df_match_synthetic_ODiN_agents.csv*
 - [combine_synthetic_ODiN_schedule](https://github.com/mr-marco/DHZW_assign-travel-behaviours/blob/main/combine_synthetic_ODiN_schedules.R "combine_synthetic_ODiN_schedules.R")
	 - Returns the entire synthetic population activity schedule for an entire week
	 - Output: *df_synthetic_activities.csv*