![GitHub](https://img.shields.io/badge/license-GPL--3.0-blue)

# Extracting and Assigning Activity Schedules to Individuals

## Table of Contents

1.  [Description](#description)
2.  [Data Sources](README_data.md)
3.  [Usage](#usage)
3.  [Analysis](#analysis)
4.  [Contributors](#contributors)
5.  [License](#license)

## Description

This project was undertaken at Utrecht University, The Netherlands, during 2022-2023 by Marco Pellegrino and a team of contributors. Within the Den Haag Zuid-West distinct (The Netherlands), information regarding activities is solely available in the form of the mobility survey ODiN. Participants in the survey reported their trips for a selected day of the week, along with providing their demographic details. Firstly, the trips reported by the participants are converted into activities. 

The activity schedules of the participants are matched with synthetic agents based on [demographic correspondence](matching_attributes.md). For simplicity, the following activity types are considered in this study:

*   Stay at home
*   Work
*   School
*   Sport
*   Shopping

Because of survey data scarcity of residents within the case study area, residents of postcodes with an equivalent degree of urbanisation, as defined by the "address density" metric provided by CBS, are used.

CBS. Degree of urbanisation. 2023. url: [https://www.cbs.nl/en-gb/our-services/methods/definitions/degree-of-urbanisation](https://www.cbs.nl/en-gb/our-services/methods/definitions/degree-of-urbanisation).

## Usage

1.  [`data_preparation.R`](data_preparation.R). The script aggregates the survey years and filters the trips of residents of highly urbanised postcodes. Output: `df_trips-higly_urbanized.csv`
2.  [`convert_trips_into_activities.R`](convert_trips_into_activities.R). The script transforms the trip collection into activities for each individual. Output: `df_activity_schedule-higly_urbanized.csv`
3.  [`match_IDs_synthetic_ODiN.R`](match_IDs_synthetic_ODiN.R). The script assigns each agent of a synthetic population to a demographically matching ODiN participant. The assignment is repeated each weekday to form a weekly schedule. The output is a dataframe that contains the ID of the matched participants. Output: `df_match_synthetic_ODiN_IDs.csv`
4.  [`merge_synthetic_ODiN_schedules.R`](merge_synthetic_ODiN_schedules.R). The script returns the full synthetic population activity weekly schedule. Output: `df_synthetic_activities.csv`

## Analysis

[`analysis/activity_distribution_plots.R`](analysis/activity_distribution_plots.R). The script returns the activity type distribution per week and per weekday. Distributions plotted: observed data (ODiN and OViN) of DHZW and highly urbanised postcodes together with the generated data.

To generate the activity schedule of trips of DHZW residents, it is necessary to modifying the individuals filtering in [`data_preparation.R`](data_preparation.R).

## Contributors

This project was made possible thanks to the hard work and contributions from:

*   Marco Pellegrino (Author)
*   Jan de Mooij
*   Tabea Sonnenschein
*   Mehdi Dastani
*   Dick Ettema
*   Brian Logan
*   Judith A. Verstegen

## License

This repository is licensed under the GNU General Public License v3.0 (GPL-3.0). For more details, see the [LICENSE](LICENSE) file.
