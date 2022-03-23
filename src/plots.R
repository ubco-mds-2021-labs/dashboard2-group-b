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
        #display = 'inline-grid',
        padding = '10px 10px 10px 10px'
    )
)

# temp and hum for a single day
single_day_plot <- div(
    dccGraph(id='out-temp'),
    dccGraph(id='out-hum'),
    style = list(
        border = 'thin lightgrey solid',
        width = "70%",
        #display = 'inline-grid',
        backgroundColor = 'rgb(250, 250, 250)',
        padding = '10px 10px 10px 10px'
    )
)

# temp and hum for a date range
temp_hum_plot <- div(
    dccGraph(id='tempHum'),
    style = list(
        border = 'thin lightgrey solid',
        width = 400,
        #display = 'inline-grid',
        backgroundColor = 'rgb(250, 250, 250)',
        padding = '10px 10px 10px 10px'
    )
)

# area plot for a date range
area_plot <- div(
    dccGraph(id = 'area-plot'),
    style = list(
        border = 'thin lightgrey solid',
        width = 400,
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
        width = 400,
        backgroundColor = 'rgb(250, 250, 250)',
        padding = '10px 10px 10px 10px'
    )
)

# header
markdown_text <-"# Energy Use of Appliance in a Low-Energy House"

# Header 

header <- div(
    dccMarkdown(markdown_text),
    style = list(
        position = "fixed",
        top = 0,
        left = 0,
        width = "100%",
        height = "8%",
        backgroundColor = 'rgb(79, 134, 224)'
    )
)

collaborators <-"
  
  Harpreet Kaur
  
  Chad Wheeler
  
  Nelson Tang
  
  Nyanda Redwood

"
data_reference <- "[Appliances energy prediction Data Set](http://archive.ics.uci.edu/ml/datasets/Appliances+energy+prediction)"

github <- "[GitHub Link](https://github.com/ubco-mds-2021-labs/dashboard2-group-b)"

# sidebar for controller
setting_block <- dbcContainer(
    list(
        div(
            html$h2("Select Date Range: "),
            date_range_picker
        ),
        div(
            html$h2("Select Room: "),
            room_dropdown
        ),
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
    ), 
    fluid = TRUE, 
    style = list(
        position = "fixed",
        top = 110,
        left = 0,
        width = 300,
        height = "80%",
        border = 'thin lightgrey solid',
        backgroundColor = 'rgb(250, 250, 250)',
        padding = '10px 10px 10px 10px'
    )
)

# plots block1
plots_block1 <- dbcContainer(
    # first row
    dbcRow(
        list(
            dbcCol(energy_point),
            dbcCol(single_day_plot)
        )
    ),
    fluid = TRUE,
    style = list(
        position = "relative",
        top = 110,
        left = 180,
        width = "80%",
        height = "40%",
        border = 'thin lightgrey solid',
        backgroundColor = 'rgb(250, 250, 250)',
        padding = '10px 10px 10px 10px'
    )
)


# plots block2
plots_block2 <- dbcContainer(
    # first row
    dbcRow(
        list(
            dbcCol(temp_hum_plot),
            dbcCol(weekday_plot),
            dbcCol(area_plot)
        )
    ),
    fluid = TRUE,
    style = list(
        position = "relative",
        top = 150,
        left = 180,
        width = "80%",
        height = "40%",
        border = 'thin lightgrey solid',
        backgroundColor = 'rgb(250, 250, 250)',
        padding = '10px 10px 10px 10px'
    )
)