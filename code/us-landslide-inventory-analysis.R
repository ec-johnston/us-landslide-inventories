library(sf)
library(rgdal)
library(tidyverse)
library(sp)
library(data.table)
library(lubridate)
library(raster)


## Analysis of database from ScienceBase Catalog
## Download shpaefile of landslide inventories across US from: 
## https://www.sciencebase.gov/catalog/item/5c7065b4e4b0fe48cb43fbd7

source("~/landslides-precip/data/func.R")

setwd("~/Downloads/US_Landslide_1")
us_landslide <- rgdal::readOGR("shp", "US_Landslide_point")

## change CRS of raster
us_landslide_proj <- spTransform(us_landslide, crs(pacific_coast)) 

## crop to rectangular spatial extent of pacific coast & convert to dataframe
pacific_coast_landslides <- raster::crop(us_landslide_proj, pacific_coast_df)
landslides_df <- as.data.frame(pacific_coast_landslides, xy = TRUE, na.rm = TRUE) 
setnames(landslides_df, old = c("coords.x1", "coords.x2"), new = c("x", "y"))

landslides_df <- landslides_df[,c(10:11, 1:9, 12:13)]

## match center of x/y coordinates to center of grid cells in analyses 
landslides_df_xy_match <- match_xy_to_raster(data = landslides_df[,1:2], raster = pacific_coast)
landslides_df$x <- landslides_df_xy_match$x
landslides_df$y <- landslides_df_xy_match$y

pacific_coast_xy_match <- match_xy_to_raster(data = pacific_coast_df[,1:2], raster = pacific_coast)
pacific_coast_df$x <- pacific_coast_xy_match$x
pacific_coast_df$y <- pacific_coast_xy_match$y

## remove grid cells outside of pacific coast states 
## (i.e., go from rectangular spatial extent to outline of Pacific Coast states)
landslides_df <- inner_join(pacific_coast_df, landslides_df, by = c("x", "y"))

summary(landslides_df$Inventory)

## summarize data by landslide inventory 
summary_data <- as.data.frame(landslides_df %>% group_by(Inventory, .drop = FALSE) %>% tally(sort = TRUE))
summary_data$n <- as.numeric(summary_data$n)

summary_data <- summary_data %>% filter(n > 0) %>% mutate(Inventory = fct_reorder(Inventory, n))

## bar chart summarizing landslide inventories available for the Pacific Coast region
inventory_plot <- ggplot(summary_data, aes(x = Inventory, y = n)) + 
  geom_bar(stat = "identity") +
  ylab("# of landslides") +
  coord_flip() +
  ggtitle("Landslide Inventories in Pacific Coast Region") +
  theme_classic()


## Subsetting California Geological Survey (CA GS) inventory
landslides_df %>% filter(Inventory == "California GS") %>% group_by(Date) %>% tally %>% print(n = 40) 
California_GS <- as.data.frame(landslides_df %>% filter(Inventory == "California GS")) %>% drop_na(Date)
California_GS_NA <- anti_join(landslide_df[landslide_df$Inventory == "California GS", ], California_GS, by = "Date")

## Summarize CA GS inventory by date 
summary_data <- as.data.frame(landslides_df %>% filter(Inventory == "California GS") %>% group_by(Date) %>% tally %>% print(n = 40))
summary_data <- summary_data %>% mutate(Date = fct_reorder(Date, n))

## bar chart of CA GS inventory by date
ca_gs_plot <- ggplot(summary_data, aes(x = Date, y = n)) + 
  geom_bar(stat = "identity") +
  ylab("# of landslides") +
  coord_flip() + 
  ggtitle("California Geological Survey") +
  theme_classic()



## OR SLIDO Inventory
landslides_df %>% filter(Inventory == "OR Slido") %>% group_by(Date) %>% tally(sort = TRUE) %>% print(n = 500)
OR_slido <- landslides_df %>% filter(Inventory == "OR Slido")

## summarize by date
summary_data <- landslides_df %>% filter(Inventory == "OR Slido") %>% group_by(Date) %>% tally(sort = TRUE) %>% print(n = 500)
summary_data <- summary_data %>% mutate(Date = fct_reorder(Date, n))


## plot showing top 20 "Dates" in OR Slido
or_slido_plot <- ggplot(summary_data[1:20,], aes(x = Date, y = n)) + 
  geom_bar(stat = "identity") +
  ylab("# of landslides") +
  coord_flip() + 
  ggtitle("OR Slido") +
  theme_classic()

## subset dates that appear in "daily" format (00/00/0000 or 0/00/0000) 
format_1 <- grepl("[0-9]{2}/[0-9]{2}/[0-9]{2}", OR_slido$Date)
format_2 <- grepl("[0-9]{1}/[0-9]{2}/[0-9]{2}", OR_slido$Date)

dates_1 <- OR_slido[which(format_1 == TRUE),]
dates_2 <- OR_slido[which(format_2 == TRUE),]

dates_1$Date <- as.Date(as.character(dates_1$Date), "%m/%d/%Y")
dates_2$Date <- as.Date(as.character(dates_2$Date), "%m/%d/%Y")

dates <- as.data.frame(rbind(dates_1, dates_2))
dates$Year <- year(dates$Date)
dates$Month <- month(dates$Date)

OR_slido_filter <- dates %>% filter(Year > 2009 & Year < 2018) %>% rename(event_date = Date)

pacificCoast_landslideInventory_xy_match <- match_xy_to_raster(pacificCoast_landslideInventory, pacific_coast)
pacificCoast_landslideInventory$x <- pacificCoast_landslideInventory_xy_match$x
pacificCoast_landslideInventory$y <- pacificCoast_landslideInventory_xy_match$y


OR_slido_filter_xy_match <- match_xy_to_raster(OR_slido_filter, pacific_coast)
OR_slido_filter$x <- OR_slido_filter_xy_match$x
OR_slido_filter$y <- OR_slido_filter_xy_match$y



## 463 landslides in Oregon not included in NASA inventory
OR_slido_filter <- anti_join(OR_slido_filter, pacificCoast_landslideInventory, by = c("x", "y", "event_date"))

OR_slido_filter %>% group_by(Year) %>% tally()
OR_slido_filter %>% group_by(Month) %>% tally()


## usa maps 
usa <- map_data("usa") 
states <- map_data("state")
westCoast <- subset(states, region %in% c("california", "oregon", "washington"))

## map of landslide catalog
ggplot() +
  geom_polygon(data = westCoast, aes(x=long, y = lat, group = group), fill = "transparent", color = "black") + 
  geom_point(data = landslides_df, aes(x = x, y = y, color = Inventory), alpha = 0.5) +
  ggtitle("US Landslide Catalog (n = 45,068)") +
  scale_color_viridis_d() +
  theme_void() +
  coord_fixed(1.3) 

## CA GS map
ggplot() +
  geom_polygon(data = westCoast, aes(x=long, y = lat, group = group), fill = "transparent", color = "black") + 
  geom_point(data = California_GS_NA, aes(x = x, y = y), alpha = 0.1, color = "salmon1") +
  ggtitle("CA Geological Survey \n Date = NA (n = 18,491)") +
  theme_void() +
  coord_fixed(1.3) 

## map of OR SLIDO landslides
ggplot() +
  geom_polygon(data = westCoast, aes(x=long, y = lat, group = group), fill = "transparent", color = "black") + 
  geom_point(data = OR_slido_filter, aes(x = x, y = y), color = "salmon1") +
  theme_void() +
  ggtitle("OR SLIDO landslides \n reported at daily resolution \n between 2010 and 2017 (n = 463)") +
  theme(legend.position = "none") +
  coord_fixed(1.3)

## bar chart of OR slido landslides
ggplot() +
  geom_bar(data = OR_slido_filter, aes(as.factor(OR_slido_filter$Month))) +
  xlab("Month") +
  ylab("# of landslides") +
  ggtitle("Landslides reported by OR SLIDO in 2010 (n = 453)") +
  theme_classic()



