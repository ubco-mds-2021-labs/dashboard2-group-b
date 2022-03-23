library(ggplot2)
library(tidyverse)
library(tibble)
library(lubridate)
library(dplyr)
library(reshape2)
library(plotly)
library(patchwork)
library(dash)


app <- Dash$new(external_stylesheets = dbcThemes$GRID)

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

