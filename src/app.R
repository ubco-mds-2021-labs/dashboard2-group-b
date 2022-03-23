library(dash)
library(hrbrthemes)
source('src/plots.R')
source('src/functions.R')


app <- Dash$new(external_stylesheets = dbcThemes$GRID)


# set layout
app %>% set_layout(
  header,
  dccStore(id = 'room', storage_type = 'memory', data = "Kitchen"),
  setting_block,
  plots_block1,
  plots_block2
)


## Callbacks
app %>% add_callback(
  output('room', 'data'),
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
    room_selector(input1, input2, input3, input4, input5, input6, input7, input8, input9)
  }
)

app %>% add_callback(
  output('weekday-bar', 'figure'),
  list(
    input("my-date-picker-range", "start_date"),
    input("my-date-picker-range", "end_date")
  ),
  function(start_date, end_date) {
    weekday(start_date, end_date)
  }
)

app %>% add_callback(
  output('tempHum', 'figure'),
  list(input('room', 'data'),
       input("my-date-picker-range", "start_date"),
       input("my-date-picker-range", "end_date")),
  function(ycol, start_date, end_date) {
    date_range(ycol, start_date, end_date)
  }
)

app %>% add_callback(
  output('energy-scatter', 'figure'),
  list(
    input("my-date-picker-range", "start_date"),
    input("my-date-picker-range", "end_date")
  ),
  function(start_date, end_date) {
    energy_consumption(start_date, end_date)
  }
)
  
app %>% add_callback(
  output('out-hum', 'figure'),
  list(
    input('energy-scatter', 'hoverData'),
    input('room', 'data')
  ),
  function(hoverData,data) {
    selected_date_hum_plot(hoverData,data)
  }
)

app %>% add_callback(
  output('out-temp', 'figure'),
  list(
    input('energy-scatter', 'hoverData'),
    input('room', 'data')
  ),
  function(hoverData,data) {
    selected_date_temp_plot(hoverData,data)
  }
)

app$run_server()
