library(ggplot2)
library(tidyverse)
library(tibble)
library(lubridate)
library(dplyr)
library(reshape2)
library(plotly)
library(patchwork)
library(dash)

## Wrangling Section

energy_data <- read.csv('./data/energydata_complete.csv')
drops <- c("rv1","rv2")
energy_data <- energy_data[ , !(names(energy_data) %in% drops)]

sum(is.na(energy_data))
#No NA values present in the data

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

#Change to date type
energy_data$Date <- ymd_hms(energy_data$Date)

energy_data$Month <- months(energy_data$Date)


app = Dash$new(external_stylesheets = dbcThemes$BOOTSTRAP)


## Plotting Section
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
