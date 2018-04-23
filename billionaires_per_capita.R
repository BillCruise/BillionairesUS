# Get the number of billionaires by state from Wikipedia, then
# the population of each state, then calculate billionaires per capita.

library(rvest)

# Grab the billionaires page source
html <- read_html("https://en.wikipedia.org/wiki/List_of_U.S._states_by_the_number_of_billionaires")

# extract the wikitable nodes
tables <- html_nodes(html, ".wikitable")

# convert the table to a dataframe
billionaires.by.state <- html_table(tables)[[1]]

# "Georgia" is unambiguous in a list of U.S. states.
billionaires.by.state$`State/Region`[billionaires.by.state$`State/Region` == "Georgia (U.S. state)"] <- "Georgia"

# Add a state code for plotting, and get rid of any NA values (non-states)
billionaires.by.state$code <- setNames(state.abb, state.name)[billionaires.by.state$`State/Region`]
billionaires.by.state <- na.omit(billionaires.by.state)



# Grab the population page source
html <- read_html("https://en.wikipedia.org/wiki/List_of_U.S._states_and_territories_by_population")

# extract the wikitable nodes
tables <- html_nodes(html, ".wikitable")

# convert the table to a dataframe
population.by.state <- html_table(tables)[[1]]

# Keep only the state name and population estimate from 2017
population.by.state <- subset(population.by.state, select=c(3, 4))

# Add a state code for plotting, and get rid of any NA values (non-states)
population.by.state$code <- setNames(state.abb, state.name)[population.by.state$`State or territory`]
population.by.state <- na.omit(population.by.state)


# Sort both dataframes by state code.
billionaires.by.state <- billionaires.by.state[order(billionaires.by.state$code),]
population.by.state <- population.by.state[order(population.by.state$code),]

# Add the population column to the billionaires table
billionaires.by.state$population <- population.by.state$`Population estimate, July 1, 2017[4]`

# Convert columns to numeric before doing computations.
billionaires.by.state$`Number of billionaires` <- as.numeric(billionaires.by.state$`Number of billionaires`)
billionaires.by.state$population <- as.numeric(gsub(",", "", billionaires.by.state$population))

# Calculate billionaires per million people per state
billionaires.by.state$billionaires.per.million <- billionaires.by.state$`Number of billionaires` / (billionaires.by.state$population / 1000000.0)


billionaires.by.state <- billionaires.by.state[order(billionaires.by.state$billionaires.per.million, decreasing = TRUE),]



library(plotly)

# give state boundaries a white border
l <- list(color = toRGB("white"), width = 2)
# specify some map projection/options
g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showlakes = TRUE,
  lakecolor = toRGB('white')
)

p <- plot_geo(billionaires.by.state, locationmode = 'USA-states') %>%
  add_trace(
    z = ~billionaires.by.state$billionaires.per.million, locations = ~code,
    color = ~billionaires.by.state$billionaires.per.million, colors = 'Greens'
  ) %>%
  colorbar(title = "Billionaires per million residents") %>%
  layout(
    title = 'Billionaires per million by State (USA)',
    geo = g
  ) 

