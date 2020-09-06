# Road-Accidents-Shiny-App
## Exploring South Australia's Road Accidents Data

## Demo

```R
## Install missing packages
packagesRequired <- c("shiny", "maptools", "dplyr",
                      "leaflet", "rgeos", "RColorBrewer",
                      "data.table")

packagesToInstall <- packagesRequired[!(packagesRequired %in%
                                          installed.packages()[,"Package"])]

if(length(packagesToInstall)) install.packages(packagesToInstall)

## Run app from Github repo
shiny::runGitHub('asheshwor/crashsa')
```

## Screenshots

![App Screenshot 1](images/preview_1.png)
<small>Screenshot of Shiny App</small>

![App Screenshot 2](images/preview_2.png)
<small>Screenshot of app</small>

## Data source

The data from Department of Planning, Transport and Infrastructure was obtained from https://data.sa.gov.au/data/dataset/road-crashes-in-sa

Bounding box for suburbs extracted from https://data.sa.gov.au/data/dataset/suburb-boundaries

## To-do

* statistics of data being displayed
* filter by type of incidents
