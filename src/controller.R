# controller.R

# Data 552 Milestone4 Dashboard Controller
# This file contains a date range picker and a room dropdown

# Date: Mar 19th, 2022
# Author: Nelson Tang & Chad Wheeler

library(dash)
library(lubridate)

# date range picker
date_range_picker <- dccDatePickerRange(
  id="my-date-picker-range",
  min_date_allowed=date("2016-1-11"),
  max_date_allowed=date("2016-5-27"),
  initial_visible_month=date("2016-1-11"),
  start_date=date("2016-1-11"),
  end_date=date("2016-5-27")
)


# room selector
ground_floor_url <- "https://ars.els-cdn.com/content/image/1-s2.0-S0378778816308970-gr5_lrg.jpg"
upper_floor_url <- "https://ars.els-cdn.com/content/image/1-s2.0-S0378778816308970-gr6_lrg.jpg"

floorplan_selector <- html$div(
  html$img(
    src = ground_floor_url,
    height = 295,
    width = 335,
    useMap = "#ground-floor-map"
  ),
  html$map(
    list(
      html$area(
        id='Kitchen',
        shape='circle',
        coords='173,206,20',
        n_clicks=0,
        href="#"
      ),
      html$area(
        id='Living',
        shape='circle',
        coords='231,34,20',
        n_clicks=0,
        href="#"
      ),
      html$area(
        id='Laundry',
        shape='circle',
        coords='104,117,20',
        n_clicks=0,
        href="#"
      ),
      html$area(
        id='Office',
        shape='circle',
        coords='244,243,20',
        n_clicks=0,
        href="#"
      )
    ),
    name = 'ground-floor-map'
  ),
  html$div(
    html$img(
      src = upper_floor_url,
      height = 300,
      width = 315,
      useMap = "#upper-floor-map"
    ),
    html$map(
      list(
        html$area(
          id='Bathroom',
          shape='circle',
          coords='115,202,20',
          n_clicks=0,
          href="#"
        ),
        html$area(
          id='NS',
          shape='circle',
          coords='59,127,20',
          n_clicks=0,
          href="#"
        ),
        html$area(
          id='Ironroom',
          shape='circle',
          coords='212,82,20',
          n_clicks=0,
          href="#"
        ),
        html$area(
          id='Teenroom',
          shape='circle',
          coords='191,115,20',
          n_clicks=0,
          href="#"
        ),
        html$area(
          id='Parentsroom',
          shape='circle',
          coords='146,61,20',
          n_clicks=0,
          href="#"
        )
      ),
      name = 'upper-floor-map'
    )
  )
)
