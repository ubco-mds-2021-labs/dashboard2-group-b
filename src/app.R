source('src/wrangling.R')

source('src/plots.R')
source('src/tab3.R')
source('src/energy_consumption_plot.R')
source('src/functions.R')
# don't change the source order



app <- Dash$new(external_stylesheets = dbcThemes$GRID)


# set layout
app %>% set_layout(
  header,
  dccStore(id = 'room', storage_type = 'memory', data = "Kitchen"),
  setting_block,
  tab_block
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
       input("my-date-picker-range", "end_date")
       ),
  function(ycol, start_date, end_date) {
    date_range(ycol, start_date, end_date)
  }
)

app %>% add_callback(
  output('energy-scatter', 'figure'),
  list(
    input("my-date-picker-range", "start_date"),
    input("my-date-picker-range", "end_date"),
    input('tabs-with-classes', 'value') # add there because there is a dash bug
                                        # more info: https://community.plotly.com/t/graph-resizes-arbitrarily-when-changing-between-tabs-in-a-dash-app/40308
  ),
  function(start_date, end_date,value) {
    energy_consumption(start_date, end_date)
  }
)

app %>% add_callback(
  output('out-hum', 'figure'),
  list(
    input('energy-scatter', 'hoverData'),
    input('room', 'data'),
    input('tabs-with-classes', 'value')
  ),
  function(hoverData,data,value) {
    selected_date_hum_plot(hoverData,data)
  }
)

app %>% add_callback(
  output('out-temp', 'figure'),
  list(
    input('energy-scatter', 'hoverData'),
    input('room', 'data'),
    input('tabs-with-classes', 'value')
  ),
  function(hoverData,data,value) {
    selected_date_temp_plot(hoverData,data)
  }
)

# Tab3 plot2
app %>% add_callback(
  output('energy-hum-area', 'figure'),
  list(input('room', 'data'),
       input("my-date-picker-range", "start_date"),
       input("my-date-picker-range", "end_date")
  ),
  function(data, start_date, end_date) {
    energy_humidity_function(data, start_date, end_date)
  }
)


# Tab3 plot1 
app %>% add_callback(
  output('energy-temp-area', 'figure'),
  list(input('room', 'data'),
       input("my-date-picker-range", "start_date"),
       input("my-date-picker-range", "end_date")
       ),
  function(data, start_date, end_date) {
    energy_temp_function(data, start_date, end_date)
  }
)


app$run_server(host = "0.0.0.0")
