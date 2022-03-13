library(ggplot2)
library(tidyverse)
library(tibble)
library(lubridate)
library(dplyr)
library(reshape2)
library(plotly)
library(patchwork)

energy_data<-read.csv('../data/energydata_complete.csv')
drops <- c("rv1","rv2")
energy_data<-energy_data[ , !(names(energy_data) %in% drops)]

sum(is.na(energy_data))
#No NA values present in the data

#Change column names
colnames(energy_data) <- c("Date", "Appliances","Lights","Kitchen_temp","Kitchen_hum","Living_temp","Living_hum","Laundry_temp","Laundry_hum","Office_temp","Office_hum","Bathroom_temp","Bathroom_hum","NS_temp","NS_hum","Ironroom_temp","Ironroom_hum","Teenroom_temp","Teenroom_hum","Parentsroom_temp","Parentsroom_hum","Temp_out","Pressure","Humidity_out","Windspeed","Visibility","Dewpoint")

#Change to date type
energy_data$Date<-ymd_hms(energy_data$Date)

energy_data$Month=months(energy_data$Date)
my_list <- c("Appliances", "Lights", "Month")
energy_data_subset = energy_data[my_list]
energy_data_subset = energy_data_subset %>% group_by(Month) %>% 
  summarise(across(c(Appliances,Lights), sum))
    
energy_data_subset = melt(energy_data_subset, id=c("Month"))


ggplot(energy_data_subset,aes(x=Month,y=value),color=energy_data_subset$variable)
  geom_area(aes(fill="red"))+
  labs(title="Energy Used in House", y = "Energy use in Wh")+
  theme(axis.line = element_line(colour = "black"),
        panel.background = element_blank(), aspect.ratio=4/6) 
