![GitHub](https://img.shields.io/badge/license-GPL--3.0-blue)

# Extracting and Assigning Activity Schedules to Individuals

**Utrecht University, The Netherlands. 2022 - 2023**

Author: Marco Pellegrino

Contributors: Jan de Mooij, Tabea Sonnenschein, Mehdi Dastani, Dick Ettema, Brian Logan, Judith A. Verstegen

## Description

Within the Den Haag Zuid-West distinct (The Netherlands), information regarding activities is solely available in the form of the mobility survey ODiN. Participants in the survey reported their trips for a selected day of the week, along with providing their demographic details. Firstly, the trips reported by the participants are converted into activities.

The activity schedules of the participants are matched with synthetic agents based on [demographic correspondence](matching_attributes.md). For simplicity, the following activity types are considered in this study:

*   Stay at home
*   Work
*   School
*   Sport
*   Shopping

Because of survey data scarcity of residents within the case study area, residents of postcodes with an equivalent degree of urbanisation, as defined by the "address density" metric provided by CBS, are used.

CBS. Degree of urbanisation. 2023. url: [https://www.cbs.nl/en-gb/our-services/methods/definitions/degree-of-urbanisation](https://www.cbs.nl/en-gb/our-services/methods/definitions/degree-of-urbanisation).

## Data sources

OViN surveys from 2010 to 2017 and ODiN surveys from 2018 and 2019. Centraal Bureau voor de Statistiek (CBS) and Rijkswaterstaat (RWS-WVL). Onderzoek Onderweg in Nederland - ODiN 2019. Version V3. 2020. doi: 10.17026/dans-xpv-mwpg. url: \[https://doi.org/10.](https://doi.org/10. 17026/dans-xpv-mwpg)  
\[17026/dans-xpv-mwpg\](https://doi.org/10. 17026/dans-xpv-mwpg)

## Data Usage (in order)

*   [`data_preparation.R`](data_preparation.R)
    *   The script aggregates the survey years and filters the trips of residents of highly urbanised postcodes.
    *   Output: `df_trips-higly_urbanized.csv`
*   [`convert_trips_into_activities.R`](convert_trips_into_activities.R)
    *   The script transforms the trip collection into activities for each individual.
    *   Output: `df_activity_schedule-higly_urbanized.csv`
*   [`matching_IDs_synthetic_ODiN.R`](matching_IDs_synthetic_ODiN.R)
    *   The script assigns each agent of a synthetic population to a demographically matching ODiN participant. The assignment is repeated each weekday to form a weekly schedule. The output is a dataframe that contains the ID of the matched participants.
    *   Output: `df_match_synthetic_ODiN_IDs.csv`
*   [`combine_synthetic_ODiN_schedules.R`](combine_synthetic_ODiN_schedules.R)
    *   The script returns the full synthetic population activity weekly schedule
    *   Output: `df_synthetic_activities.csv`

## Analysis

[`analysis/activity_distribution_plots.R`](analysis/activity_distribution_plots.R). The script returns the activity type distribution per week and per weekday. Distributions plotted: observed data (ODiN and OViN) of DHZW and highly urbanised postcodes together with the generated data.