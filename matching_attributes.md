![GitHub](https://img.shields.io/badge/license-GPL--3.0-blue)

# Extracting and Assigning Activity Schedules to Individuals

**Utrecht University, The Netherlands. 2022 - 2023**

Author: Marco Pellegrino

Contributors: Jan de Mooij, Tabea Sonnenschein, Mehdi Dastani, Dick Ettema, Brian Logan, Judith A. Verstegen

## Matching attributes

The following demographics are used for the matching process, as they are available in both the survey data and the synthetic population data:

*   Age group (determined intuitively based on their perceived impact on mobility behaviour):
    *   From 0 to 5 years old: kid
    *   From 6 to 11 years old: primary school student
    *   From 12 to 18 years old: high-school student
    *   From 19 to 25 years old: university student
    *   From 26 to 30 years old: work without children
    *   From 31 to 50 years old: work with children
    *   From 51 to 67 years old: work with children
    *   Over 68 years old: retirement age
*   Gender:
    *   Male
    *   Female
*   Migration background:
    *   Dutch
    *   Western
    *   Non-Western

More matching attributes, such as the household standardised income group, can be used too. However, the more attributes, the smaller the pool of participants per combination of attributes is. A good balance should be maintained for heterogeneity. The literature review does not specify suitable or essential demographic attributes required for such an approach.