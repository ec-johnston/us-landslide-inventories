## Exploratory data analysis of landslide inventories available for the Pacific Coast Region of the United States

### Shapefile of US landslide inventories can be downloaded from: https://www.sciencebase.gov/catalog/item/5c7065b4e4b0fe48cb43fbd7

Jones, E.S., Mirus, B.B, Schmitt, R.G., Baum, R.L., Burns, W.J., Crawford, M., Godt, J.W., Kirschbaum, D.B., Lancaster, J.T., Lindsey, K.O., McCoy, K.E., Slaughter, S., and Stanley, T.A., 2019, Summary Metadata – Landslide Inventories across the United States: U.S. Geological Survey data release, https://doi.org/10.5066/P9E2A37P.

## Results of exploratory data analysis

For our study area, the Pacific Coast region of the coterminous United States (i.e., CA, OR, WA), landslides in the US Landslide Catalog come from five digital source inventories published by the California Geological Survey (n = 29,611), OR SLIDO: Statewide Landslide Information Database for Oregon (n = 13,047), NASA (an older version of the GLC/COOLR; n = 1,806), USGS Conterminous (n = 289), and USGS WA PS Railway (n = 132; Figures A and B below). 

![alt text](https://github.com/ec-johnston/landslide-inventories/blob/main/plots/Figures_A_B.png)

The formatting and temporal resolution of the “Date” attribute is inconsistent among inventories and sometimes is unreported (i.e., is associated with an “NA” value; e.g., Figure C below). A landslide trigger is not reported by the US Landslide Catalog. 

Unfortunately, all “Dates” associated with landslides reported by USGS Conterminous (n = 289), and USGS WA PS Railway (n = 132) are missing (“NA”), so we are unable to use these inventories within our daily-scale panel regression framework. 

![alt text](https://github.com/ec-johnston/landslide-inventories/blob/main/plots/Figures_C_D.png)

A majority of landslides (n = 18,491) in the California Geological Survey inventory are also associated with an “NA” date value (Figure C above). The remaining landslides from the California Geological Survey are reported at annual temporal resolution, with no landslides reported after 2004.  It’s possible that many of the landslides from the California Geological Survey are associated with storms that occurred between Jan. 3–5, 1982, which may have resulted in >18,000 landslides (as mentioned by the Reviewer). It appears that these tens of thousands of landslides are not concentrated in the Bay Area but are distributed along the entire California coast (and likely extended further north as well; Figure D above). However, given the lack of information about the date of occurrence, we cannot readily incorporate these landslides into our analysis. 

![alt text](https://github.com/ec-johnston/landslide-inventories/blob/main/plots/FigureE.png)

Within the OR SLIDO inventory, landslides are reported at inconsistent temporal resolution, with the majority (n = 10,789) reported at annual or greater than annual resolution (Figure E above). Of the 470 landslides reported by OR SLIDO at daily resolution between 2010 and 2017, 463 are not included in the COOLR. Of these landslides, 453 occurred in 2010 and were reported by the Oregon Department of Transportation (ODOT). The “Notes” associated with these 2010 ODOT landslides indicate they may have been associated with hillslope failure above and/or below major roads. Given that some but not all of these landslides are included in COOLR, and we are unsure of a trigger, we do not include the 463 landslides included in OR SLIDO but not COOLR in our analyses. 
