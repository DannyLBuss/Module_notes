##Install dependencies
library(devtools)
#devtools::install_github("ropensci/rgbif")
library(rgbif)
library(raster)
library(rgdal)
library(ggplot2)
library(httr)
library(sp)
library(GISTools)
library(rgeos)
library(maps)
library(mapdata)
library(rworldmap)
library(maptools)
library(mapproj)
library(ggmap)


vignette('rworldmap')
###PLOT GBIF DATA ON MAP 
species<-unique(compadre_temp$species_accepted)
key<-name_backbone(species[1])$usageKey

###Calculate area of globe per species
dat<-map_fetch(key = key)
dat2<-map_fetch2(key = key)
plot(dat2)

##Ocean polygons - marine ecoregions of the world
setwd("~/Desktop/Phylogenetic Imputation Project/MEOW")
ocean<-readShapePoly("meow_ecos.shp")

getwd()
##Ocean polygons - marine ecoregions of the world
setwd("~/Desktop/CDO Job Stuff/Papers/1. Phylogentic Imputation Whales/2. Data/ne_110m_ocean")
ocean2<-readShapePoly("ne_10m_ocean.shp")

##Land
setwd("~/Desktop/Phylogenetic Imputation Project/ne_10m_land")
land<-readShapePoly("ne_10m_land.shp")

##FAO regions polygons - marine ecoregions of the world
setwd("~/Desktop/Phylogenetic Imputation Project/FAO_AREAS")
FAO<-readShapePoly("FAO_AREAS.shp")

##Coastlines 
#setwd("~/Desktop/Phylogenetic Imputation Project/ne_10m_coastline")
#coast<-readShapePoly("ne_10m_coastline.shp")
mapWorld<-map("world")

###Setwd - fin whale
setwd("~/Desktop/Phylogenetic Imputation Project/species_2478_fin")
fin<-readShapePoly("species_2478.shp")
summary(fin)
attributes(fin@data)
plot(fin, border="white", col="grey", axes=TRUE)

###Overlay Fin data on Ocean
par(mar=c(1.9,1.9,1.9,1.9))
blues<-rgb(0.5,0.92,1, alpha=0.25)
lightblue<-rgb(0.9,1,1, alpha=0.5)
grey<-rgb(0.6,0.6,0.6, alpha=0.95)

#1. Add Fin Whale Data and Axes
plot(fin, border="white", col=grey, axes=TRUE, ylim=c(-90,90), xlim=c(-180,180))
#2. Add Ocean Boundaries
plot(ocean2, border="black", col=blues, add=TRUE) 
#3. Overlay and fill countries
plot(land, col="grey92", add=TRUE)


#fin_shape_df<-fortify(fin)
#map<-ggplot()+geom_path(data=fin_shape_df, aes(x=long, y=lat, group=group), colour='gray', size=.2)
#print(map)

###Calculate percentage cover for spatial distribution and ocean shapefiles
setwd("~/Desktop/Phylogenetic Imputation Project/species_8153_southern_right")
fin.map<-readOGR(dsn=".", layer="species_2478")
omari.map<-readOGR(dsn=".", layer="species_136623")
bowhead.map<-readOGR(dsn=".", layer="species_2467")
minke.map<-readOGR(dsn=".", layer="species_2474")
ant_minke.map<-readOGR(dsn=".", layer="species_2475")
edeni.map<-readOGR(dsn=".", layer="species_2476")
blue.map<-readOGR(dsn=".", layer="species_2477")
sei.map<-readOGR(dsn=".", layer="species_2480")
pgymyright.map<-readOGR(dsn=".", layer="species_3778")
Northpacific.map<-readOGR(dsn=".", layer="species_41711")
NorthAtlantic.map<-readOGR(dsn=".", layer="species_41712")
southernright.map<-readOGR(dsn=".", layer="species_8153")
grey.map<-readOGR(dsn=".", layer="species_8097")

ocean.map<-readOGR(dsn=".", layer="ne_10m_ocean")


fin.data<-cbind(id=rownames(fin.map@data), id_no=fin.map@data$id_no)
totals<-c("2","2478")
fin.data<-rbind(fin.data, totals)

ocean.data<-cbind(id=rownames(ocean.map@data), id_no=ocean.map@data$scalerank)

get.area<-function(polygon){
  row<- data.frame(id=polygon@ID, area=polygon@area, stringsAsFactors = F)
  return(row)
}

fin.areas<-do.call(rbind,lapply(fin.map@polygons, get.area))
17417.36+7907.25
total<-c(2,25324.61)
fin.areas<-rbind(fin.areas, total)

fin.data$id<-as.numeric(fin.data$id)
fin.data<-rbind(fin.data, total)
fin.data<-merge(fin.data, fin.areas, by= "id")

ocean.areas<-do.call(rbind,lapply(ocean.map@polygons, get.area))
ocean.data<-merge(ocean.data, ocean.areas, by= "id")
ocean.data$id_no<-gsub("0", "2478",ocean.data$id_no)

fin.smry<-aggregate(area~id_no, data=fin.data,sum)
ocean.smry<-aggregate(area~id_no, data=ocean.data,sum)
ocean.smry$id_no<-gsub("0", "2478",ocean.data$id_no)

smry<-merge(fin.data, ocean.smry, by="id_no")
smry$coverage<-with(smry,100*area.x/area.y)

