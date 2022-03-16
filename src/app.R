library(ggplot2)
library(tidyverse)
library(tibble)
library(lubridate)
library(dplyr)
library(reshape2)
library(plotly)
library(patchwork)
library(dash)


energy_data<-read.csv('./data/energydata_complete.csv')

drops <- c("rv1","rv2")
energy_data<-energy_data[ , !(names(energy_data) %in% drops)]

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

energy_data$weekday  <- weekdays(energy_data$Date)

energy_data$date_only  <- date(energy_data$Date)




app <- Dash$new(external_stylesheets = dbcThemes$GRID)

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
  clearable=FALSE
)

date_range_picker <- dccDatePickerRange(
  id="my-date-picker-range",
  min_date_allowed=date("2016-1-11"),
  max_date_allowed=date("2016-5-27"),
  initial_visible_month=date("2016-1-11"),
  start_date=date("2016-1-11"),
  end_date=date("2016-5-27")
)


# energy consumption plot
energy_point <- div(
  dccGraph(
    id = 'energy-scatter',
    hoverData = list(points = list(list(customdata = "2016-1-11")))
  ),
  style = list(
    border = 'thin lightgrey solid',
    width = "95%",
    backgroundColor = 'rgb(250, 250, 250)',
    #display = 'inline-grid',
    padding = '10px 10px 10px 10px'
  )
)

# temp and hum for a single day
single_day_plot <- div(
  dccGraph(id='out-temp'),
  dccGraph(id='out-hum'),
  style = list(
    border = 'thin lightgrey solid',
    width = "70%",
    #display = 'inline-grid',
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

# temp and hum for a date range
temp_hum_plot <- div(
  dccGraph(id='tempHum'),
  style = list(
    border = 'thin lightgrey solid',
    width = 400,
    #display = 'inline-grid',
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

# area plot for a date range
area_plot <- div(
  dccGraph(id = 'area-plot'),
  style = list(
    border = 'thin lightgrey solid',
    width = 400,
    #display = 'inline-grid',
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)



# area plot for a date range
weekday_plot <- div(
  dccGraph(id = 'weekday-bar'),
  style = list(
    border = 'thin lightgrey solid',
    width = 400,
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

# header
markdown_text <-"# Energy Use of Appliance in a Low-Energy House"

# Header 

header <- div(
  dccMarkdown(markdown_text),
  style = list(
    # position = "fixed",
    top = 0,
    left = 0,
    width = "100%",
    height = "8%",
    backgroundColor = 'rgb(79, 134, 224)'
  )
)



# sidebar for controller
setting_block <- dbcContainer(
  list(
    div(
      html$h2("Select Date Range: "),
      date_range_picker
    ),
    div(
      html$h2("Select Room: "),
      room_dropdown
    )
  ), fluid = TRUE , 
  style = list(
    # position = "fixed",
    top = 110,
    left = 0,
    width = 300,
    height = "100%",
    border = 'thin lightgrey solid',
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

# plots block1
plots_block1 <- dbcContainer(
    # first row
    dbcRow(
      list(
        dbcCol(energy_point),
        dbcCol(single_day_plot)
      )
    ),
    #fluid = TRUE,
    style = list(
      # position = "fixed",
      top = 110,
      left = 330,
      width = "80%",
      height = "40%",
      border = 'thin lightgrey solid',
      backgroundColor = 'rgb(250, 250, 250)',
      padding = '10px 10px 10px 10px'
  )
)


# plots block2
plots_block2 <- dbcContainer(
  # first row
  dbcRow(
    list(
      dbcCol(temp_hum_plot),
      dbcCol(weekday_plot),
      dbcCol(area_plot)
    )
  ),
  #fluid = TRUE,
  style = list(
    # position = "fixed",
    top = 710,
    left = 330,
    width = "80%",
    height = "40%",
    border = 'thin lightgrey solid',
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)



# set layout
app %>% set_layout(
  header,
  setting_block,
  plots_block1,
  plots_block2
)



## Callbacks for area plot

app %>% add_callback(
  output('area-plot', 'figure'),
  list(
       input("my-date-picker-range", "start_date"),
       input("my-date-picker-range", "end_date")),
  function(start_date, end_date) {
    
    energy_data_subset <- energy_data %>%
      subset(energy_data$date_only >= start_date & energy_data$date_only <= end_date) %>%
      select("Appliances", "Lights", "Month") %>%
      group_by(Month = fct_inorder(Month)) %>%
      summarise(across(c(Appliances, Lights), sum)) %>%
      melt(id = c("Month"))

    p <- ggplot(energy_data_subset, 
                aes(x = Month, y = value, group = variable, fill = variable)) +
      geom_area(alpha = 0.6) + 
      #geom_point(color = variable) +
      labs(title = "Energy Used in House", y = "Energy use in Wh")+
      theme(legend.title = element_text(size=10), 
              legend.key.size = unit(0.5, 'cm'),
              legend.text = element_text(size=8))
    

    ggplotly(p)
  }
)



## Callbacks for weekdays

app %>% add_callback(
  output('weekday-bar', 'figure'),
  list(input("my-date-picker-range", "start_date"),
       input("my-date-picker-range", "end_date")),
  function(start_date, end_date) {
    group_by_weekday <- energy_data %>%
      subset(energy_data$date_only >= start_date & energy_data$date_only <= end_date,
             select = c(weekday, Appliances)) %>%
      group_by(weekday) %>%
      summarise(sum_appliances = sum(Appliances))

    bar_plot <- ggplot(group_by_weekday, 
                       aes(x=sum_appliances, y=weekday, color=weekday))+  
      labs(title = 'More Energy Consumed on Mondays?', 
           x='Energy Consumption of Appliances (Wh)', 
           y='Days', 
           color='Days') + 
      geom_col()+ theme_bw() + theme(legend.title = element_text(size=10), 
                                     legend.key.size = unit(0.5, 'cm'),
                                     legend.text = element_text(size=8))
    
    ggplotly(bar_plot)
  }
)



## Callbacks for temp and hum in a date range plot

app %>% add_callback(
  output('tempHum', 'figure'),
  list(input('room', 'value'),
       input("my-date-picker-range", "start_date"),
       input("my-date-picker-range", "end_date")),
  function(ycol, start_date, end_date) {
    
    
    temp = paste(ycol, "_temp", sep="")
    hum = paste(ycol, "_hum", sep="")
    
    selected_data <- energy_data %>%
      subset(energy_data$date_only >= start_date & energy_data$date_only <= end_date)
    
    t <- ggplot(selected_data) +
      aes(x = Date,
          y = !!sym(temp),
          color = "Temperature") +
      geom_line(color = "red")
    
    h <- ggplot(selected_data) +
      aes(x = Date,
          y = !!sym(hum),
          color = "Humidity") +
      geom_line(color = "blue")
    
    subplot(ggplotly(t), ggplotly(h), nrows = 2, shareX = TRUE) |>
      layout( title = list(text = 'Room Temperature and Humidity'),
              xaxis = list(text = 'Date'))
  }
)


# energy use plot in date range
app %>% add_callback(
  output('energy-scatter', 'figure'),
  list(
    input("my-date-picker-range", "start_date"),
    input("my-date-picker-range", "end_date")
  ),
  
  
  function(start_date, end_date) {
    # sum energy use in each date
    group_by_date <- energy_data %>%
      subset(energy_data$date_only >= start_date & energy_data$date_only <= end_date,
             select = c(date_only, Appliances)) %>%
      group_by(date_only) %>%
      summarise(sum_appliances = sum(Appliances))

    traces <- list()
    
    traces[[1]] <- list(
      x = group_by_date$date_only,
      y = group_by_date$sum_appliances,
      opacity=0.7,
      text = group_by_date$date_only,
      customdata = group_by_date[, "date_only"],
      mode = 'markers+lines',
      marker = list(
        'size'= 8,
        'opacity' = 0.7,
        'line' = list('width' = 0.3, 'color' = 'white')
      )
    )
    
    list(
      'data' = traces,
      'layout'= list(
        xaxis = list('title' = "Date"),
        yaxis = list('title' = "Appliances energy consumption in Wh"),
        margin = list('l' = 40, 'b' = 30, 't' = 10, 'r' = 0),
        height = 450,
        hovermode = 'closest'
      )
    )
  }
)


# room hum for a single day
app %>% add_callback(
  output('out-hum', 'figure'),
  list(
    input('energy-scatter', 'hoverData'),
    input('room', 'value')
  ),
  function(hoverData,value) {
    hum = paste(value, "_hum", sep="")
    
    date <- hoverData$points[[1]]$customdata
    
    # select date in data
    seleteted_data <- energy_data %>%
      subset(energy_data$date_only == unlist(date[1]))
    
    title <- paste(value,"Humidity on", unlist(date[1]), sep = ' ')

    list(
      'data' = list(list(
        x = seleteted_data[['Date']],
        y = seleteted_data[[hum]],
        mode = 'lines'
      )),
      'layout' = list(
        height = 225,
        margin = list('l' = 20, 'b' = 30, 'r' = 10, 't' = 10),
        # add text for title
        'annotations' = list(list(
          x = 0, 'y' = 0.95, xanchor = 'left', yanchor = 'bottom',
          xref = 'paper', yref = 'paper', showarrow = FALSE,
          align = 'left', bgcolor = 'rgba(255, 255, 255, 0.5)',
          text = title
        )),
        xaxis = list(showgrid = FALSE)
      )
    )
  }
)



# room temp for a single day
app %>% add_callback(
  output('out-temp', 'figure'),
  list(
    input('energy-scatter', 'hoverData'),
    input('room', 'value')
  ),
  function(hoverData,value) {
    
    date <- hoverData$points[[1]]$customdata
    
    # select date in data
    temp = paste(value, "_temp", sep="")
    seleteted_data <- energy_data %>%
      subset(energy_data$date_only == unlist(date[1]))
    
    title <- paste(value, "Temperature on", unlist(date[1]), sep = ' ')
    list(
      'data' = list(list(
        x = seleteted_data[['Date']],
        y = seleteted_data[[temp]],
        mode = 'lines'
      )),
      'layout' = list(
        height = 225,
        margin = list('l' = 20, 'b' = 30, 'r' = 10, 't' = 10),
        # add text for title
        'annotations' = list(list(
          x = 0, 'y' = 0.95, xanchor = 'left', yanchor = 'bottom',
          xref = 'paper', yref = 'paper', showarrow = FALSE,
          align = 'left', bgcolor = 'rgba(255, 255, 255, 0.5)',
          text = title
        )),
        #yaxis = list(type = axis_type),
        xaxis = list(showgrid = FALSE)
      )
    )
  }
)

app$run_server(host = "0.0.0.0")
