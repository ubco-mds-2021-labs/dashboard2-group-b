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
library(hrbrthemes)

#Dropdown for roomlist
room_dropdown <-  dccDropdown(
    id = "room",
    value = "Kitchen",
    options = list(
        list(label = "Kitchen", value = "Kitchen"),
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
    clearable = FALSE,
)

#Dropdown for date range
# date range picker
date_range_picker <- dccDatePickerRange(
    id = "my-date-picker-range",
    min_date_allowed = date("2016-1-11"),
    max_date_allowed = date("2016-5-27"),
    initial_visible_month = date("2016-1-11"),
    start_date = date("2016-1-11"),
    end_date = date("2016-5-27")
)

# room dropdown
room_dropdown <-  dccDropdown(
    id = "room",
    value = "Outside",
    options = list(
        list(label = "Kitchen", value = "Kitchen"),
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
    clearable = FALSE
)

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
        subset(
            energy_data$date_only >= start_date &
                energy_data$date_only <= end_date,
            select = c(date_only, Appliances)
        ) %>%
        group_by(date_only) %>%
        summarise(Appliances_Energy_Used = sum(Appliances)) %>%
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
        } else if (month == "February") {
            xlims <- c("2016-02-01", "2016-02-29")
        } else if (month == "March") {
            xlims <- c("2016-03-01", "2016-03-31")
        } else if (month == "April") {
            xlims <-  c("2016-04-01", "2016-04-30")
        } else if (month == "May") {
            xlims <- c("2016-05-01", "2016-05-31")
        }
        
        
        #spline_int <- as.data.frame(spline(month_data$Date, month_data$Appliances_Energy_Used))
        p <-
            ggplot(
                subset(group_by_date, Month == month),
                aes(x = Date, y = Appliances_Energy_Used)
            ) +
            geom_line(color = "#69b3a2", size = 1) +
            #geom_smooth(method = "loess")+
            geom_area(fill = "#69b3a2", alpha = 0.4) +
            geom_point(size = 1.5, color = "#69b3a2") +
            theme_ipsum() +
            scale_x_date(limits = as.Date(xlims)) +
            scale_y_continuous(limits = c(0, 27150))
        
        # add plot in list
        plot_list[[counter]] <- ggplotly(p, height = 900)
        # plot_list[[counter]] <- plot_list[[counter]]$x$data[[1]]$hoverinfo <- "none"
        counter = counter + 1
    }
    
    # layout for ggplot
    subplot(plot_list,
            nrows = length(plot_list),
            titleY = FALSE) %>%
        layout(title = list(text = "<b> Energy Consumption of Appliances (Wh) </b>"))
}

# room temp for a selected date
# hoverData is callback from energy consumption plot
# value is callback from room dropdown
selected_date_temp_plot <- function(hoverData, value) {
    #' Room temperature for a selected date
    #'
    #' @param hoverData A list. Callback from energy consumption plot
    #' @param value A String. Callback from room dropdown
    #' @return A plotly object.
    #' @examples
    #' selected_date_temp_plot(list(points = list(list(customdata = "2016-1-11"))), "Outside")
    
    hum = paste(value, "_hum", sep = "")
    
    # get date from hoverdata
    # if not selected then set as customdata
    if (is.null(hoverData$points[[1]]$text)) {
        date <- hoverData$points[[1]]$customdata
    } else{
        date <- substr(hoverData$points[[1]]$text, 7, 16)
    }
    
    # select date in data
    seleteted_data <- energy_data %>%
        subset(energy_data$date_only == unlist(date[1]))
    
    title <- paste(value, "Humidity on", unlist(date[1]), sep = ' ')
    
    p <- ggplot(seleteted_data, aes(x = Date, y = !!sym(hum))) +
        geom_line(color = "#69b3a2", size = 1) +
        geom_point(size = 1.5,
                   color = "#69b3a2",
                   alpha = 0.4) +
        theme_ipsum() +
        ggtitle(title) +
        ylab("Humidity in %")
    
    ggplotly(p)
}

# room hum for a single day
# hoverData is callback from energy consumption plot
# value is callback from room dropdown
selected_date_hum_plot <- function(hoverData, value) {
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
    } else{
        date <- substr(hoverData$points[[1]]$text, 7, 16)
    }
    
    # select date in data
    temp = paste(value, "_temp", sep = "")
    seleteted_data <- energy_data %>%
        subset(energy_data$date_only == unlist(date[1]))
    
    title <-
        paste(value, "Temperature on", unlist(date[1]), sep = ' ')
    p <- ggplot(seleteted_data, aes(x = Date, y = !!sym(temp))) +
        geom_line(color = "#69b3a2", size = 1) +
        geom_point(size = 1.5,
                   color = "#69b3a2",
                   alpha = 0.4) +
        theme_ipsum() +
        ggtitle(title) +
        ylab("Temperature in Celsius")
    
    ggplotly(p)
}
layout <- div(list(row1, row2))
