# energy_consumption_plot.R

# Data 552 Milestone4 Dashboard Sub-plots
# This file contains 3 plots
# Energy consumption of appliances for each month, room temperature for a selected date, room humidity for a selected date
# The date change of the room temperature and humidity plots will be based on the hover data on the energy consumption plots

# Date: Mar 19th, 2022
# Author: Nelson Tang

library(ggplot2)
library(dplyr)
library(plotly)
library(hrbrthemes)

# An interactive plot
# energy consumption of appliances for each month
# start, end date are callback from date range picker
energy_consumption <- function(start_date, end_date) {
  
  #' energy consumption of appliances for each month
  #' 
  #' @param start_date A Date. 
  #' @param end_date A Date.
  #' @return A plotly object. 
  #' @examples
  #' energy_consumption("2016-01-11", "2016-05-27")
  
  
  # sum energy use in each date
  group_by_date <- energy_data %>%
    subset(energy_data$date_only >= start_date & energy_data$date_only <= end_date,
           select = c(date_only, Appliances, Lights)) %>%
    group_by(date_only) %>%
    summarise(total_energy_used = sum(Appliances+Lights)) %>%
    mutate(Month = months(date_only)) %>%
    mutate(Date = date_only)
  
  jan_xlim <- c("2016-01-01", "2016-01-31")
  feb_xlim <- c("2016-02-01", "2016-01-29")
  mar_xlim <- c("2016-03-01", "2016-01-31")
  apl_xlim <- c("2016-04-01", "2016-01-30")
  may_xlim <- c("2016-05-01", "2016-01-27")
  
  #print(max(group_by_date$sum_appliances))
  plot_list = list()
  counter = 1
  
  for (month in unique(group_by_date$Month)) {
    
    # set xlimit for different month
    if (month == "January") {
      xlims <- c("2016-01-01", "2016-01-31")
    }else if (month == "February") {
      xlims <- c("2016-02-01", "2016-02-29")
    }else if (month == "March") {
      xlims <- c("2016-03-01", "2016-03-31")
    }else if (month == "April") {
      xlims <-  c("2016-04-01", "2016-04-30")
    }else if (month == "May") {
      xlims <- c("2016-05-01", "2016-05-31")
    }
    
    subset_data <- subset(group_by_date, Month == month)
    
    mean_energy = mean(subset_data$total_energy_used)
    # if dataset is small, fewer data values than degrees of freedom, we can not use stat_smooth()
    if (nrow(subset_data) <= 9) {
      p <- ggplot(subset_data, 
                  aes(x=Date, y=total_energy_used)) +
        #geom_line(color="#69b3a2", size=1) +
        geom_point(size=1.5, color="#69b3a2") +
        geom_area( fill="#69b3a2", alpha=0.4) +
        geom_hline(yintercept = mean_energy, 
                   alpha=0.4, 
                   size = 0.6, 
                   linetype = "dashed") +
        theme_ipsum() +
        scale_x_date(limits = as.Date(xlims)) +
        scale_y_continuous(limits = c(0,27150), breaks = c(10000, mean_energy,20000))
    }else{
      p <- ggplot(subset_data, 
                  aes(x=Date, y=total_energy_used)) +
        #geom_line(color="#69b3a2", size=1) +
        geom_point(size=1.5, color="#69b3a2") +
        stat_smooth(geom = 'area', 
                    method = 'loess', 
                    span = 1/4, 
                    alpha = 1/2, 
                    fill = "#69b3a2", 
                    se = FALSE) +
        geom_hline(yintercept = mean_energy, 
                   alpha=0.3, 
                   size = 0.3, 
                   linetype = "dashed") +
        theme_ipsum() +
        scale_x_date(limits = as.Date(xlims)) +
        scale_y_continuous(limits = c(0,27150), breaks = c(10000, mean_energy,20000))
      
    }
    
    # add plot in list
    plot_list[[counter]] <- ggplotly(p, height = 650)
    counter = counter + 1
  }
  
  # layout for ggplot
  w <- subplot(plot_list,nrows = length(plot_list), titleY = FALSE) %>%
    layout(title = list(text = "<b>Total Energy Consumption (Wh)</b>"))
  
  # add hover text to each month in subplot
  for(i in c(1,4,7,10,13)[1:length(plot_list)]){
    #points text
    text_1 <-  paste0("Actual Data Point", "<br />", "Date: ",
                      as.Date(round(as.numeric(w$x$data[[i]]$x)), origin = "1970-01-01"), "<br />", "Total Energy Used: ", w$x$data[[1]]$y)
    #smooth line text
    text_2 <-  paste0("Smooth Data Curve", "<br />" ,  "Date: ",
                      as.Date(round(as.numeric(w$x$data[[i+1]]$x)), origin = "1970-01-01"), "<br />", "Smoothed Energy Used: ", round(w$x$data[[2]]$y))
    w <- w %>%
      style(text= text_1, traces = i) %>%
      style(text = text_2, traces = i+1)
  }
  
  return(w)
}

# room temp for a selected date
# hoverData is callback from energy consumption plot
# value is callback from room dropdown
selected_date_temp_plot <- function(hoverData,value) {
  
  #' Room temperature for a selected date
  #' 
  #' @param hoverData A list. Callback from energy consumption plot
  #' @param value A String. Callback from room dropdown
  #' @return A plotly object. 
  #' @examples
  #' selected_date_temp_plot(list(points = list(list(customdata = "2016-1-11"))), "Outside")
  
  hum = paste(value, "_hum", sep="")
  
  # get date from hoverdata
  # if not selected then set as customdata
  if (is.null(hoverData$points[[1]]$text)) {
    date <- hoverData$points[[1]]$customdata
  }else{
    date <- substr(hoverData$points[[1]]$text, 30, 39)
  }
  
  # select date in data
  seleteted_data <- energy_data %>%
    subset(energy_data$date_only == unlist(date[1]))
  
  title <- paste(value,"Humidity on", unlist(date[1]), sep = ' ')
  
  p <- ggplot(seleteted_data, aes(x=Date, y=!!sym(hum))) +
    geom_line(color="#69b3a2", size=1) +
    geom_point(size=1.5, color="#69b3a2", alpha = 0.4) +
    theme_ipsum() +
    ggtitle(title)+
    ylab("Humidity in %")
  
  ggplotly(p,height = 350)
}

# room hum for a single day
# hoverData is callback from energy consumption plot
# value is callback from room dropdown
selected_date_hum_plot <- function(hoverData,value) {
  
  #' Room humidity for a selected date
  #' 
  #' @param hoverData A list. Callback from energy consumption plot
  #' @param value A String. Callback from room dropdown
  #' @return A plotly object. 
  #' @examples
  #' selected_date_hum_plot(list(points = list(list(customdata = "2016-1-11"))), "Outside")
  
  # get date from hoverdata
  # if not selected then set as customdata
  
  if (is.null(hoverData$points[[1]]$text)) {
    date <- hoverData$points[[1]]$customdata
  }else{
    #date <- substr(hoverData$points[[1]]$text, 7, 16)
    date <- substr(hoverData$points[[1]]$text, 30, 39)
  }
  
  # select date in data
  temp = paste(value, "_temp", sep="")
  seleteted_data <- energy_data %>%
    subset(energy_data$date_only == unlist(date[1]))
  
  title <- paste(value, "Temperature on", unlist(date[1]), sep = ' ')
  p <- ggplot(seleteted_data, aes(x=Date, y=!!sym(temp))) +
    geom_line(color="#69b3a2", size=1) +
    geom_point(size=1.5, color="#69b3a2", alpha = 0.4) +
    theme_ipsum() +
    ggtitle(title) +
    ylab("Temperature in Celsius")
  
  ggplotly(p,height = 350)
}