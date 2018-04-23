# Get the number of billionaires by state from Wikipedia.

library(rvest)

# Grab the page source
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
    z = ~billionaires.by.state$`Number of billionaires`, locations = ~code,
    color = ~billionaires.by.state$`Number of billionaires`, colors = 'Greens'
  ) %>%
  colorbar(title = "Number of billionaires") %>%
  layout(
    title = 'Billionaires by State (USA)',
    geo = g
  ) 


