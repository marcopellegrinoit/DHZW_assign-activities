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

## Data Usage (in order)

1.  [`data_preparation.R`](data_preparation.R). The script aggregates the survey years and filters the trips of residents of highly urbanised postcodes. Output: `df_trips-higly_urbanized.csv`
2.  [`convert_trips_into_activities.R`](convert_trips_into_activities.R). The script transforms the trip collection into activities for each individual. Output: `df_activity_schedule-higly_urbanized.csv`
3.  [`matching_IDs_synthetic_ODiN.R`](matching_IDs_synthetic_ODiN.R). The script assigns each agent of a synthetic population to a demographically matching ODiN participant. The assignment is repeated each weekday to form a weekly schedule. The output is a dataframe that contains the ID of the matched participants. Output: `df_match_synthetic_ODiN_IDs.csv`
4.  [`combine_synthetic_ODiN_schedules.R`](combine_synthetic_ODiN_schedules.R). The script returns the full synthetic population activity weekly schedule. Output: `df_synthetic_activities.csv`

## Analysis

[`analysis/activity_distribution_plots.R`](analysis/activity_distribution_plots.R). The script returns the activity type distribution per week and per weekday. Distributions plotted: observed data (ODiN and OViN) of DHZW and highly urbanised postcodes together with the generated data.

## Data sources

OViN surveys from 2010 to 2017 and ODiN surveys from 2018 and 2019:

*   OViN 2010. Centraal Bureau voor de Statistiek (CBS) / Rijkswaterstaat (RWS), 2014, "Onderzoek Verplaatsingen in Nederland 2010 - OViN 2010 versie 2.0", [https://doi.org/10.17026/dans-zhs-ghwg](https://doi.org/10.17026/dans-zhs-ghwg), DANS Data Station Social Sciences and Humanities, V1.
*   OViN 2011. Centraal Bureau voor de Statistiek (CBS) / Rijkswaterstaat (RWS), 2014, "Onderzoek Verplaatsingen in Nederland 2011 - OViN 2011 versie 2.0", [https://doi.org/10.17026/dans-xv2-hapb](https://doi.org/10.17026/dans-xv2-hapb), DANS Data Station Social Sciences and Humanities, V2.
*   OViN 2012. Centraal Bureau voor de Statistiek (CBS) / Rijkswaterstaat (RWS), 2014, "Onderzoek Verplaatsingen in Nederland 2012 - OViN 2012 versie 2.0", [https://doi.org/10.17026/dans-2bs-q7u2](https://doi.org/10.17026/dans-2bs-q7u2), DANS Data Station Social Sciences and Humanities, V3.
*   OViN 2013. Centraal Bureau voor de Statistiek (CBS) / Rijkswaterstaat (RWS), 2014, "Onderzoek Verplaatsingen in Nederland 2013 - OViN 2013", [https://doi.org/10.17026/dans-x9h-dsdg](https://doi.org/10.17026/dans-x9h-dsdg), DANS Data Station Social Sciences and Humanities, V2.
*   OViN 2014. Centraal Bureau voor de Statistiek (CBS); Rijkswaterstaat (RWS), 2015, "Onderzoek Verplaatsingen in Nederland 2014 - OViN 2014", [https://doi.org/10.17026/dans-x95-5p7y](https://doi.org/10.17026/dans-x95-5p7y), DANS Data Station Social Sciences and Humanities, V2.
*   OViN 2015. Centraal Bureau voor de Statistiek (CBS); Rijkswaterstaat (RWS), 2017, "Onderzoek Verplaatsingen in Nederland 2015 - OViN 2015 versie 2.0", [https://doi.org/10.17026/dans-z2v-c39p](https://doi.org/10.17026/dans-z2v-c39p), DANS Data Station Social Sciences and Humanities, V2
*   OViN 2016. Centraal Bureau voor de Statistiek (CBS); Rijkswaterstaat (RWS), 2017, "Onderzoek Verplaatsingen in Nederland 2016 - OViN 2016", [https://doi.org/10.17026/dans-293-wvf7](https://doi.org/10.17026/dans-xxt-9d28), DANS Data Station Social Sciences and Humanities, V2.
*   OVin 2017. Centraal Bureau voor de Statistiek (CBS); Rijkswaterstaat (RWS), 2017, "Onderzoek Verplaatsingen in Nederland 2017 - OViN 2017", [https://doi.org/10.17026/dans-xxt-9d28](https://doi.org/10.17026/dans-xxt-9d28), DANS Data Station Social Sciences and Humanities, V2.
*   OViN 2018. Centraal Bureau voor de Statistiek (CBS); Rijkswaterstaat (RWS), 2018, "Onderzoek Onderweg in Nederland - ODiN 2018", [https://doi.org/10.17026/dans-xn4-q9ks](https://doi.org/10.17026/dans-xn4-q9ks), DANS Data Station Social Sciences and Humanities, V3.
*   ODiN 2019. Centraal Bureau voor de Statistiek (CBS); Rijkswaterstaat (RWS-WVL), 2020, "Onderzoek Onderweg in Nederland - ODiN 2019", [https://doi.org/10.17026/dans-xpv-mwpg](https://doi.org/10.17026/dans-xpv-mwpg), DANS Data Station Social Sciences and Humanities, V3