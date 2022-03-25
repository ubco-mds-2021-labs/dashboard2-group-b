library(ggplot2)
library(dplyr)
library(plotly)
library(hrbrthemes)


# function for energy consumption and room wise temperation variation
energy_temp_function <- function(room_name, start_date, end_date) {
  
  #' Temperature(in Celsius) and Energy consumption(in Wh) variations. It describes the total energy consumption for both the lights and appliances wrt the variation in a room`s temperature`
  #' 
  #' @param Room name as a string
  #' @param a datetype(start and end date) 
  #' @return A ggplotly object.
  #' @examples
  #' energy_temp_function("Kitchen","2016-01-11","2016-03-29")
  
  plot_title <- paste("Energy v/s", room_name ,"Temperature", sep = ' ')
  energy_data$room_temp <- energy_data[[paste(room_name, "_temp", sep="")]]
  
  energy_temp_subset <- energy_data %>%
    subset(energy_data$date_only >= start_date & energy_data$date_only <= end_date,
           select = c(room_temp, Appliances, Lights)) %>%
    group_by(room_temp) %>%
    summarise(sum_energy = sum(Lights + Appliances))

  energy_temp_plot <- ggplot(energy_temp_subset, aes(room_temp, sum_energy)) +
    stat_smooth(
      geom = "area",
      method = "loess",
      span = 1 / 4,
      alpha = 1 / 2,
      fill = "#69b3a2",
      se = FALSE
    ) +
    labs(title=plot_title,
         x =paste(room_name, "Temperature(in Celsius)", sep=" "), 
         y = "Energy Consumed(in Wh)")+
    theme_ipsum()+
    theme(
      axis.line = element_line(colour = "black"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      panel.background = element_blank()
          
          ) 
  
  
   ggplotly(energy_temp_plot)

}

#function called

#energy_temp_function("Kitchen","2016-01-11","2016-03-29")

# function for energy consumption and room wise humidity variation

energy_humidity_function <- function(room_name, start_date, end_date) {
  
  #' Humidity(in %) and Energy consumption(in Wh) variations. It describes the total energy consumption for both the lights and appliances wrt the variation in a room`s temperature`
  #' 
  #' @param Room name as a string
  #' @param a datetype(start and end date) 
  #' @return A ggplotly object.
  #' @examples
  #' energy_humidity_function("Kitchen","2016-01-11","2016-03-29")
  
  plot_title <- paste("Energy v/s", room_name ,"Humidity", sep = ' ')
  energy_data$room_humid <- energy_data[[paste(room_name, "_hum", sep="")]]
  
  
  energy_humid_subset <- energy_data %>%
    subset(energy_data$date_only >= start_date & energy_data$date_only <= end_date,select=c(room_humid,Lights,Appliances)) %>%
    group_by(room_humid) %>%
    summarise(sum_energy = sum(Lights + Appliances))
  
  
  energy_humidity_plot <- ggplot(energy_humid_subset, aes(room_humid, sum_energy)) +
    stat_smooth(
      geom = "area",
      method = "loess",
      span = 1 / 4,
      alpha = 1 / 2,
      fill = "#69b3a2",
      se = FALSE
    )+
    labs(title=plot_title,
         x =paste(room_name, "Humidity(in %)", sep=" "), y = "Energy Consumed(in Wh)")+theme_ipsum()+
    theme(
      axis.line = element_line(colour = "black"),
      panel.grid.major = element_blank(),
      panel.grid.minor = element_blank(),
      panel.border = element_blank(),
      panel.background = element_blank()
      
    ) 
  
  
  ggplotly(energy_humidity_plot)
  
}

#function called
#energy_humidity_function("Kitchen","2016-01-11","2016-03-29")
