source('wrangling.R')

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
  

  most_recent_click <- if(!is.null(ctx$triggered$value)) {

    unlist(strsplit(ctx$triggered$prop_id, "[.]"))[1]

  } else "Kitchen"
  
  most_recent_click
}

# Callback function for weekdays
weekday <- function(start_date, end_date) {
    #' Sum of Energy consumption for individual week day.
    #'
    #' @param hoverData A datetype object. Callback from date selector
    #' @param value A datetype object. Callback from date selector
    #' @return A plotly object.
    #' @examples
    #' weekday("2016-1-11", "2016-5-11")
  # make Day_of_week an ordered factor
  weekday <- factor(energy_data$weekday, levels=c("Saturday", "Friday", "Thursday", "Wednesday", "Tuesday", "Monday", "Sunday" 
  ))
  
  bar_plot <- ggplot(energy_data, aes(x=Appliances, y=weekday)) + 
    labs(title = 'Least Consumption on Tuesdays',
         x='Energy Consumption of Appliances (Wh)') + 
    geom_col(show.legend = FALSE) +
    theme_bw() + theme(axis.title.y=element_blank())
  ggplotly(bar_plot)
  
  ggplotly(bar_plot)
}

# Callbacks for temp and hum in a date range plot
date_range <- function(ycol, start_date, end_date) {
    #' Temperature and Humidity variations.
    #' 
    #' @param hoverData A datetype object. Callback from date selector
    #' @param a list of datetype and the room type 
    #' @return A plotly object.
    #' @examples Room object
    #' date_range("Kitchen","2016-1-11", "2016-5-11")
  
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





