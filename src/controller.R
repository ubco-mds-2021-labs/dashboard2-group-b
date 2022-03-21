# controller.R

# Data 552 Milestone4 Dashboard Controller
# This file contains a date range picker and a room dropdown

# Date: Mar 19th, 2022
# Author: Nelson Tang

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


# room dropdown
room_dropdown <-  dccDropdown(
  id = "room",
  value = "Outside",
  options = list(list(label = "Kitchen", value = "Kitchen"),
                 list(label = "Living Room", value = "Living"),
                 list(label = "Laundry Room", value = "Laundry"),
                 list(label = "Office", value = "Office"),
                 list(label = "Bathroom", value = "Bathroom"),
                 list(label = "NS", value = "NS"),
                 list(label = "Iron Room", value = "Ironroom"),
                 list(label = "Teen Room", value = "Teenroom"),
                 list(label = "Parent's Room", value = "Parentsroom"),
                 list(label = "Outside", value = "Outside")
  ),
  clearable=FALSE
)
