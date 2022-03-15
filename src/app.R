library(ggplot2)
library(tidyverse)
library(tibble)
library(lubridate)
library(dplyr)
library(reshape2)
library(plotly)
library(patchwork)
library(dash)
library(dashCoreComponents)
library(dashHtmlComponents)

energy_data <- read.csv("../data/energydata_complete.csv")
drops <- c("rv1", "rv2")
energy_data <- energy_data[, !(names(energy_data) %in% drops)]
## Wrangling Section

energy_data <- read.csv("./data/energydata_complete.csv")
drops <- c("rv1", "rv2")
energy_data <- energy_data[, !(names(energy_data) %in% drops)]


sum(is.na(energy_data))
# No NA values present in the data


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


# Wrangle date column
energy_data$Date <- strptime(as.character(energy_data$Date),format="%Y-%m-%d %H:%M:%S") 
energy_data$Date <- as.POSIXct(energy_data$Date,tz = "UTC") 
energy_data$mhr <- floor_date(energy_data$Date,"hour")
energy_data$Day_of_week <- weekdays(energy_data$Date)
weekend_weekday <- function(x) {
  val <- weekdays(x)
  if (val == "Saturday" | val == "Sunday") {
    val2 <- "Weekend"
  } else {
    val2 <- "Weekday"
  }
  return(val2)
}
energy_data$Day_of_week <- as.factor(energy_data$Day_of_week)
energy_data$WeekStatus <- unlist(lapply(energy_data$Date, weekend_weekday))
data_weekstatus <- select(energy_data, Date, WeekStatus, Appliances, mhr)
data_weekstatus$Appliances <- data_weekstatus$Appliances/1000
data_weekstatus_subset <- subset(data_weekstatus, Date > "2016-01-10" & Date < "2016-01-17")

energy_data$Day_of_week <- as.factor(energy_data$Day_of_week)
energy_data$WeekStatus <- unlist(lapply(energy_data$Date, weekend_weekday))


# make Day_of_week an ordered factor
energy_data$Day_of_week <- factor(energy_data$Day_of_week, levels=c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday",
                                "Friday", "Saturday"))

energy_data$Date <- ymd_hms(energy_data$Date)

energy_data$Month <- months(energy_data$Date)
my_list <- c("Appliances", "Lights", "Month")
energy_data_subset <- energy_data[my_list]

energy_data_subset <- energy_data_subset %>%
  group_by(Month = fct_inorder(Month)) %>%
  summarise(across(c(Appliances, Lights), sum))

energy_data_subset <- melt(energy_data_subset, id = c("Month"))


app <- dash_app()
app %>% add_stylesheet("https://codepen.io/chriddyp/pen/bWLwgP.css")

roomlist_dropdown <-  dccDropdown(
  id = "Room",
  value = "Kitchen",
  options = list(list(label = "Kitchen", value = "Kitchen"),
                 list(label = "Living Room", value = "Living"),
                 list(label = "Laundry Room", value = "Laundry"),
                 list(label = "Office", value = "Office"),
                 list(label = "Bathroom", value = "Bath"),
                 list(label = "NS", value = "NS"),
                 list(label = "Iron Room", value = "Iron"),
                 list(label = "Teen Room", value = "Teen"),
                 list(label = "Parent's Room", value = "Parents")
  ),
  clearable=FALSE
)

## Plotting Section

#barplot Energy Consuption per Days of Week
bar_plot <- ggplot(energy_data, aes(x=Appliances, y=Day_of_week, 
    color=Day_of_week))+  
    labs(title = 'More Energy Consumed on Mondays?', x='Energy Consumption of Appliances (Wh)', y='Days', color='Days')+ 
    geom_col()+ theme_bw()
bar_plot

tempHum <- ggplot(energy_data) +
  aes(x= )

## Interactions

room_dropdown <-  dccDropdown(
  id = "room",
  value = "Kitchen",
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
  clearable=FALSE,
)


# area-plot
area_plot <- ggplot(energy_data_subset, aes(x = Month, y = value, group = variable, fill = variable)) +
  geom_area(alpha = 0.6) + geom_point(color = variable)
  labs(title = "Energy Used in House", y = "Energy use in Wh")


app$layout(dccGraph(figure=ggplotly(area_plot)))
## Layout

app$layout(dbcContainer(list(room_dropdown,
                             dccGraph(id='tempHum')
                             )
                        )
           )


## Callbacks

app$callback(
  output('tempHum', 'figure'),
  list(input('room', 'value')),
  function(ycol) {
    temp = paste(ycol, "_temp", sep="")
    hum = paste(ycol, "_hum", sep="")
    t <- ggplot(energy_data) +
      aes(x = Date,
          y = !!sym(temp),
          color = "Temperature") +
      geom_line(color = "red")

    h <- ggplot(energy_data) +
      aes(x = Date,
          y = !!sym(hum),
          color = "Humidity") +
      geom_line(color = "blue")

    subplot(ggplotly(t), ggplotly(h), nrows = 2, shareX = TRUE) |>
      layout( title = list(text = 'Room Temperature and Humidity'),
             xaxis = list(text = 'Date'))
  }
)

app$run_server(debug = T)
# app$run_server(host = "0.0.0.0", port = Sys.getenv('PORT', 8050))
