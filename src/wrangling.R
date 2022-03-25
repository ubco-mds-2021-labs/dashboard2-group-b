library(tidyverse)
library(lubridate)

energy_data<-read.csv('./data/energydata_complete.csv')

drops <- c("rv1","rv2")
energy_data<-energy_data[ , !(names(energy_data) %in% drops)]


#Change column names
colnames(energy_data) <- c("Date", 
                           "Appliances",
                           "Lights",
                           "Kitchen_temp",
                           "Kitchen_hum",
                           "Living_temp",
                           "Living_hum",
                           "Laundry_temp",
                           "Laundry_hum",
                           "Office_temp",
                           "Office_hum",
                           "Bathroom_temp",
                           "Bathroom_hum",
                           "NS_temp",
                           "NS_hum",
                           "Ironroom_temp",
                           "Ironroom_hum",
                           "Teenroom_temp",
                           "Teenroom_hum",
                           "Parentsroom_temp",
                           "Parentsroom_hum",
                           "Outside_temp",
                           "Pressure",
                           "Outside_hum",
                           "Windspeed",
                           "Visibility",
                           "Dewpoint")

energy_data['energy'] <- energy_data$Appliances + energy_data$Lights

#Change to date type
energy_data$Date <- ymd_hms(energy_data$Date)

energy_data$Month <- months(energy_data$Date)

energy_data$weekday  <- weekdays(energy_data$Date)

energy_data$date_only  <- date(energy_data$Date)
