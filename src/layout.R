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


ground_floor_url <- "https://ars.els-cdn.com/content/image/1-s2.0-S0378778816308970-gr5_lrg.jpg"
upper_floor_url <- "https://ars.els-cdn.com/content/image/1-s2.0-S0378778816308970-gr6_lrg.jpg"
  

app$layout(
  html$div(
    list(
      html$img(
          src = "https://ars.els-cdn.com/content/image/1-s2.0-S0378778816308970-gr5_lrg.jpg",
          height = 400,
          width = 439,
          useMap = "#ground-floor-map"
      ),
      html$map(
        list(
          html$area(
            id='room_4',
            shape='circle',
            coords='319,331,20',
            n_clicks=0,
            href="#"
          ),
          html$area(
            id='room_1',
            shape='circle',
            coords='227,279,20',
            n_clicks=0,
            href="#"
          )
        ),
        name = 'ground-floor-map'
      ),
      html$div(id="test")
    )
  )
)

app$callback(
  output('test', 'children'),
  list(
    input('room_1', 'n_clicks'),
    input('room_4', 'n_clicks')
  ),
  function(input1, input2) {
    
    inputs <- c(input1, input2)
    
    ctx <- callback_context()

    most_recent_click <- if(ctx$triggered$value) {
      
      unlist(strsplit(ctx$triggered$prop_id, "[.]"))[1]
      
    } else "No room selected"
    
    html$div(
      html$table(
        html$tr(
          html$td(most_recent_click)
        )
      )
    )
  }
)


app$run_server(debug = T)
