library(plyr)
library(ggplot2)
library(reshape2)
vehicles <- read.csv(unz("vehicles.csv.zip", "vehicles.csv"),
                     stringsAsFactors = F)
head(vehicles)
labels <- do.call(rbind, strsplit(readLines("varlabels.txt")," - "))

head(labels)

dim(vehicles)

names(vehicles)
summary(vehicles)

length(unique(vehicles[,"year"]))
first_year <- min(vehicles$year)
first_year
last_year <- max(vehicles$year)
last_year

length(unique(vehicles$year))
table(vehicles$fuelType1)
vehicles$trany[vehicles$trany==""] <- NA
vehicles$trany2 <- ifelse(substr(vehicles$trany,1,4)== "Auto","Auto","Manual")
vehicles$trany<- as.factor(vehicles$trany)
table(vehicles$trany2)

mpgByYr <- ddply(vehicles, ~year,summarise,avgMPG = mean(comb08),
                 avgHghy=mean(highway08),avgCity=mean(city08))

ggplot(mpgByYr,aes(year,avgMPG)) + geom_point() + geom_smooth(method = "loess") +
         xlab("Year") + ylab("Average MPG") + ggtitle("All Cars")

table(vehicles$fuelType1)

gasCars <- subset(vehicles,fuelType1 %in% c("Regular Gasoline", "Premium Gasoline", "Midgrade Gasoline") 
                  & fuelType2 == "" & atvType != "Hybrid")

mpgByYr_Gas <- ddply(gasCars , ~year,summarise,avgMPG = mean(comb08))

ggplot(mpgByYr_Gas,aes(year,avgMPG))+geom_point()+geom_smooth(method = "loess")+
   xlab("Year")+ylab("Average MPG")+ggtitle("Gasoline Cars")


gasCars$displ <- as.numeric(gasCars$displ)
ggplot(gasCars,aes(displ,comb08)) + geom_point()+geom_smooth(method = "loess")

byYear <- ddply(gasCars,~ year, summarise,avgMPG = mean(comb08)
                 ,avgDispl = mean(displ))
head(byYear)

byYear2 <- melt(byYear,id="year")
levels(byYear2$variable) <- c("Average MPG", "Avg engine
                              displacement")
head(byYear2)

ggplot(byYear2,aes(year,value)) + geom_point()+ geom_smooth()+
  facet_wrap(~variable, ncol=1,scales = "free_y")+xlab("Year") + ylab("")

gasCars4 <- subset(gasCars,cylinders == "4")

carsMake <- ddply(gasCars4, ~year, summarise, numberOfMakes =
                    length(unique(make)))
ggplot(carsMake, aes(year, numberOfMakes)) + geom_point() +
  labs(x = "Year", y = "Number of available makes") + ggtitle("Four cylinder cars")

uniqMakes <- dlply(gasCars4, ~year, function(x)
  unique(x$make))
commonMakes <- Reduce(intersect, uniqMakes)
carsCommonMakes4 <- subset(gasCars4, make %in% commonMakes)
avgMPG_commonMakes <- ddply(carsCommonMakes4, ~year + make,
                            summarise, avgMPG = mean(comb08))
ggplot(avgMPG_commonMakes, aes(year, avgMPG)) + geom_line() +
  facet_wrap(~make, nrow = 3)
