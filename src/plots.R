source("controller.R")
library(dash)
library(dashHtmlComponents) # Added for Tabs


## Tab 1
# energy consumption plot
energy_point <- div(
  dccGraph(
    id = 'energy-scatter',
    hoverData = list(points = list(list(customdata = "2016-1-11")))
  ),
  style = list(
    border = 'thin lightgrey solid',
    width = "95%",
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

# temp and hum for a single day
single_day_plot <- div(
  dccGraph(id='out-temp'),
  dccGraph(id='out-hum'),
  style = list(
    border = 'thin lightgrey solid',
    width = "75",
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

tab1_content <- dbcRow(
  list(
    dbcCol(energy_point),
    dbcCol(single_day_plot)
  )
)



## Tab 2
# temp and hum for a date range
temp_hum_plot <- div(
  dccGraph(id='tempHum'),
  style = list(
    border = 'thin lightgrey solid',
    width = "95%",
    #display = 'inline-grid',
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

# area plot for a date range
weekday_plot <- div(
  dccGraph(id = 'weekday-bar'),
  style = list(
    border = 'thin lightgrey solid',
    width = "95%",
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

tab2_content <- dbcRow(
  list(
    dbcCol(temp_hum_plot),
    dbcCol(weekday_plot)
  )
)


## Tab 3
# temp and hum for a date range
energy_temp_area <- div(
  dccGraph(id='energy-temp-area'),
  style = list(
    border = 'thin lightgrey solid',
    width = "95%",
    #display = 'inline-grid',
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

# area plot for a date range
energy_hum_area <- div(
  dccGraph(id = 'energy-hum-area'),
  style = list(
    border = 'thin lightgrey solid',
    width = "95%",
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)

tab3_content <- dbcRow(
  list(
    dbcCol(energy_temp_area),
    dbcCol(energy_hum_area)
  )
)


## Tab 4 About
collaborators <-"
  
  Harpreet Kaur
  
  Chad Wheeler
  
  Nelson Tang
  
  Nyanda Redwood

"
data_reference <- "[Appliances energy prediction Data Set](http://archive.ics.uci.edu/ml/datasets/Appliances+energy+prediction)"

github <- "[GitHub Link](https://github.com/ubco-mds-2021-labs/dashboard2-group-b)"

tab4_content <- dbcCol(
  list(
    div(
      html$h2("Collaborators: "),
      dccMarkdown(collaborators)
    ),
    div(
      html$h2("Data Source: "),
      dccMarkdown(data_reference)
    ),
    div(
      html$h2("Code Source: "),
      dccMarkdown(github)
    )
  )
)






tabs <- htmlDiv(list(
  dccTabs(
    id="tabs-with-classes",
    value='tab-1',
    parent_className='custom-tabs',
    className='custom-tabs-container',
    children=list(
      dccTab(
        id = 'tab1',
        label='Tab one',
        value='tab-1',
        className='custom-tab',
        selected_className='custom-tab--selected',
        children = tab1_content
      ),
      dccTab(
        label='Tab two',
        value='tab-2',
        className='custom-tab',
        selected_className='custom-tab--selected',
        # week days and temp hum plots go here
        children = tab2_content
      ),
      dccTab(
        label='Tab three',
        value='tab-3', className='custom-tab',
        selected_className='custom-tab--selected',
        children = tab3_content # Energy vs temp & hum plots go here
      ),
      dccTab(
        label='About',
        value='tab-4',
        className='custom-tab',
        selected_className='custom-tab--selected',
        children = tab4_content
      )
    )),
  htmlDiv(id='tabs-content-classes')
))


tab_block <- dbcContainer(
  list(
    tabs
  ),
  fluid = TRUE,
  style = list(
    position = "relative",
    top = 96,
    left = 195,
    #left = 242,
    width = "70%",
    height = "80%",
    border = 'thin lightgrey solid',
    backgroundColor = 'rgb(250, 250, 250)',
    padding = '10px 10px 10px 10px'
  )
)





# # area plot for a date range
# area_plot <- div(
#     dccGraph(id = 'area-plot'),
#     style = list(
#         border = 'thin lightgrey solid',
#         width = 400,
#         #display = 'inline-grid',
#         backgroundColor = 'rgb(250, 250, 250)',
#         padding = '10px 10px 10px 10px'
#     )
# )





# header
markdown_text <-"# Energy Consumption in a Low-Energy House"

# Header 

header <- div(
    dccMarkdown(markdown_text),
    style = list(
        position = "fixed",
        top = 0,
        left = 0,
        width = "100%",
        height = 100,
        backgroundColor = 'rgb(79, 134, 224)'
    )
)


# sidebar for controller
setting_block <- dbcContainer(
    list(
        div(
            html$h2("Select Date Range: "),
            date_range_picker
        ),
        div(
            html$h2("Click a circle to select a room: "),
            floorplan_selector
        )
    ), 
    fluid = TRUE, 
    style = list(
        position = "fixed",
        top = 100,
        left = 0,
        width = 350,
        # height = "80%",
        border = 'thin lightgrey solid',
        backgroundColor = 'rgb(250, 250, 250)',
        padding = '10px 10px 10px 10px',
        overflow_y = 'scroll'
    )
)



# # plots block2
# plots_block2 <- dbcContainer(
#     # first row
#     dbcRow(
#         list(
#             dbcCol(temp_hum_plot),
#             dbcCol(weekday_plot),
#             dbcCol(area_plot)
#         )
#     ),
#     fluid = TRUE,
#     style = list(
#         position = "relative",
#         top = 150,
#         left = 180,
#         width = "80%",
#         height = "40%",
#         border = 'thin lightgrey solid',
#         backgroundColor = 'rgb(250, 250, 250)',
#         padding = '10px 10px 10px 10px'
#     )
# )