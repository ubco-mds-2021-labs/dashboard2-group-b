library(ggplot2)
library(tidyverse)
library(tibble)
library(lubridate)
library(dplyr)
library(reshape2)
library(plotly)
library(patchwork)

energy_data<-read.csv("energydata_complete.csv")

sum(is.na(energy_data))
#No NA values present in the data

#Change column names
colnames(appdata) <- c("Date", "Appliances","Lights","Kitchen_temp","Kitchen_hum","Living_temp","Living_hum","Laundry_temp","Laundry_hum","Office_temp","Office_hum","Bathroom_temp","Bathroom_hum","NS_temp","NS_hum","Ironroom_temp","Ironroom_hum","Teenroom_temp","Teenroom_hum","Parentsroom_temp","Parentsroom_hum","Temp_out","Pressure","Humidity_out","Windspeed","Visibility","Dewpoint")

#Change to date type
appdata$Date<-ymd_hms(appdata$Date)
