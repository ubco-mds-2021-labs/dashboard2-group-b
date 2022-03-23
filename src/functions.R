# Function to select room
room_selector <- function(input1, input2, input3, input4, input5, input6, input7, input8, input9) {
  
  inputs <- c(input1, 
              input2,
              input3,
              input4, 
              input5, 
              input6, 
              input7, 
              input8, 
              input9)
  
  ctx <- callback_context()
  
  most_recent_click <- if(ctx$triggered$value) {
    
    unlist(strsplit(ctx$triggered$prop_id, "[.]"))[1]
    
  } else "Kitchen"
  
  most_recent_click
}

# Callback function for weekdays
weekday <- function(start_date, end_date) {
  group_by_weekday <- energy_data %>%
    subset(energy_data$date_only >= start_date & energy_data$date_only <= end_date,
           select = c(weekday, Appliances)) %>%
    group_by(weekday) %>%
    summarise(sum_appliances = sum(Appliances))
  
  # make Day_of_week an ordered factor
  weekday <- factor(weekday, levels=c("Saturday", "Friday", "Thursday", "Wednesday", "Tuesday", "Monday", "Sunday" 
  ))
  
  bar_plot <- ggplot(group_by_weekday, 
                     aes(x=sum_appliances, y=weekday, color=weekday))+  
    labs(title = 'Least Consumption on Tuesdays', 
         x='Energy Consumption of Appliances (Wh)', 
         y='Days', 
         color='Days') + 
    geom_col(show.legend = FALSE)+ theme_bw() #+ theme(legend.title = element_text(size=10), 
                                   #legend.key.size = unit(0.5, 'cm'),
                                   #legend.text = element_text(size=8))
  
  ggplotly(bar_plot)
}

# Callbacks for temp and hum in a date range plot
date_range <- function(ycol, start_date, end_date) {
  
  
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

# Energy use plot within date range
energy_use <- function(start_date, end_date) {
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

# Room humidity for a single day
room_hum <- function(hoverData,value) {
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

# Room temp for single day
room_temp <- function(hoverData,value) {
  
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

