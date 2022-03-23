library(ggplot2)
library(tidyverse)
library(tibble)
library(lubridate)
library(dplyr)
library(reshape2)
library(plotly)
library(patchwork)
library(dash)


ground_floor_url <- "https://ars.els-cdn.com/content/image/1-s2.0-S0378778816308970-gr5_lrg.jpg"
upper_floor_url <- "https://ars.els-cdn.com/content/image/1-s2.0-S0378778816308970-gr6_lrg.jpg"
  

floorplan_selector <- html$div(
  html$img(
    src = ground_floor_url,
    height = 295,
    width = 335,
    useMap = "#ground-floor-map"
  ),
  html$map(
    list(
      html$area(
        id='Kitchen',
        shape='circle',
        coords='173,206,20',
        n_clicks=0,
        href="#"
      ),
      html$area(
        id='Living',
        shape='circle',
        coords='231,34,20',
        n_clicks=0,
        href="#"
      ),
      html$area(
        id='Laundry',
        shape='circle',
        coords='104,117,20',
        n_clicks=0,
        href="#"
      ),
      html$area(
        id='Office',
        shape='circle',
        coords='244,243,20',
        n_clicks=0,
        href="#"
      )
    ),
    name = 'ground-floor-map'
  ),
  html$div(
    html$img(
      src = upper_floor_url,
      height = 300,
      width = 315,
      useMap = "#upper-floor-map"
    ),
    html$map(
      list(
        html$area(
          id='Bathroom',
          shape='circle',
          coords='115,202,20',
          n_clicks=0,
          href="#"
        ),
        html$area(
          id='NS',
          shape='circle',
          coords='59,127,20',
          n_clicks=0,
          href="#"
        ),
        html$area(
          id='Ironroom',
          shape='circle',
          coords='212,82,20',
          n_clicks=0,
          href="#"
        ),
        html$area(
          id='Teenroom',
          shape='circle',
          coords='191,115,20',
          n_clicks=0,
          href="#"
        ),
        html$area(
          id='Parentsroom',
          shape='circle',
          coords='146,61,20',
          n_clicks=0,
          href="#"
        )
      ),
      name = 'upper-floor-map'
    )
  )
)


floorplan_callback <- app$callback(
  output('test', 'children'),
  list(
    input('Kitchen', 'n_clicks'),
    input('Living', 'n_clicks'),
    input('Laundry', 'n_clicks'),
    input('Office', 'n_clicks'),
    input('Bathroom', 'n_clicks'),
    input('NS', 'n_clicks'),
    input('Ironroom', 'n_clicks'),
    input('Teenroom', 'n_clicks'),
    input('Parentsroom', 'n_clicks')
  ),
  function(input1, input2, input3, input4, input5, input6, input7, input8, input9) {
    
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
)
