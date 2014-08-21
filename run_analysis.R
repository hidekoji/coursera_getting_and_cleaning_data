# 0. Read data
## 0.1 create a temp file
temp <- tempfile()
## 0.2 download data zip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp, method="curl", mode="wb")
## 0.3 unzip file and read data file.
unzip(temp)
## 0.4 Read features.txt
features <- read.table("UCI\ HAR\ Dataset/features.txt",stringsAsFactors = FALSE)
## 0.5 Read activity_labels.txt
activity_labels <- read.table("UCI\ HAR\ Dataset/activity_labels.txt")
## 0.6 Read X_test.txt
X_test <- read.table("UCI\ HAR\ Dataset/test/X_test.txt")
## 0.7 Read subject_test.txt
subject_test <- read.table("UCI\ HAR\ Dataset/test/subject_test.txt")
## 0.8 Read y_test.txt
y_test <- read.table("UCI\ HAR\ Dataset/test/y_test.txt")
## 0.9 Read X_train.txt
X_train <- read.table("UCI\ HAR\ Dataset/train/X_train.txt")
## 0.10 Read subject_train.txt
subject_train <- read.table("UCI\ HAR\ Dataset/train/subject_train.txt")
## 0.11 Read y_train.txt
y_train <- read.table("UCI\ HAR\ Dataset/train/y_train.txt")
unlink(temp)

# 1. Merge the training and the test sets to create one data set.
## 1.1 merge X_test and X_train (keep all the records from both X_test and X_train)
X_merged <- rbind(X_test, X_train)
## 1.2 merge y_test and y_train (keep all the records from both y_test and y_train)
y_merged <- rbind(y_test, y_train)
## 1.3 merge subject_test and subject_train (keep all the records from both subject_test and subject_train)
subject_merged <- rbind(subject_test, subject_train)
## 1.4 merge X_merged, y_merged, and subject_,erged
merged.dataframe <- cbind(X_merged, y_merged,subject_merged)

#2.Extracts only the measurements on the mean and standard deviation for each measurement.
library(plyr)
library(dplyr)
## 2.1 Get column names indexes that have mean() or std()
filtered.features <- features %>% filter(grepl("mean()",V2) | grepl("std()",V2))
## 2.2 From X_merged, only select columns that in filtered.features
mean.std.X_merged <- select(X_merged, filtered.features$V1)
## 2.3 Add back y_merged and subject_merged which are omitted by step 2.2
mreged.dataframe2 <- cbind(mean.std.X_merged, y_merged, subject_merged)

#3.Uses descriptive activity names to name the activities in the data set
## 3.1 Create lookup data set by merging y_merged (activitly records) with label (activitly_labels)
activities.lookup <- left_join(y_merged, activity_labels)
## 3.2 Create a merged data frame with mean.std.X_merged, descriptive activity name, and
## subject data frame
##
merged.dataframe3 <- cbind(mean.std.X_merged, select(activities.lookup, V2), subject_merged)

#4.Appropriately labels the data set with descriptive variable names.
## 4.1 Define function to get nice descriptive variable names for features
getNiceDescription <- function(colname){

  col = as.character(colname)
  list <- strsplit(x = col, split = "-")
  column<- list[[1]][1]
  col.type <- substr(column,1,1)
  col.name <- substr(column,2,nchar(column))
  col.aggfunc <- list[[1]][2]
  if (length(list[[1]]) == 3){
    col.direction <- list[[1]][3]
  } else {
    col.direction <- ""
  }

  #get nice name for function
  if(col.aggfunc == "mean()"){
    nice.aggname <- "MEAN"
  } else if (col.aggfunc == "std()") {
    nice.aggname <- "STANDARD_DEVIATION"
  } else if (col.aggfunc == "meanFreq()") {
    nice.aggname <- "MEAN_FREQUENCY"
  }

  #get a nice name for domain signal type
  if(col.type == "t"){
    nice.type = "TIME"
  } else if (col.type == "f"){
    nice.type = "FREQUENCY"
  }
  nice.colname <- ''
  # get nice name for rest
  if(col.name == "BodyAcc"){
    nice.colname <- "BODY_ACCELEROMETER"
  } else if(col.name == "GravityAcc") {
    nice.colname <- "GRAVITY_ACCELEROMETER"
  } else if(col.name == "BodyAccJerk") {
    nice.colname <- "BODY_ACCELEROMETER_JERK"
  } else if (col.name == "BodyGyro"){
    nice.colname <- "BODY_GYROSCOPE"
  } else if (col.name == "BodyGyroJerk"){
    nice.colname <- "BODY_GYROSCOPE_JERK"
  } else if (col.name == "BodyAccMag"){
    nice.colname <- "BODY_ACCELEROMETER_MAGNITUDE"
  } else if (col.name == "GravityAccMag"){
    nice.colname <- "GRAVITY_ACCELEROMETER_MAGNITUDE"
  } else if (col.name == "BodyAccJerkMag") {
    nice.colname <- "BODY_ACCELEROMETER_JERK_MAGINITUDE"
  } else if (col.name == "BodyGyroMag"){
    nice.colname <- "BODY_GYROSCOPE_MAGNITUDE"
  } else if (col.name == "BodyGyroJerkMag") {
    nice.colname <- "BODY_GYROSCOPE_JERK_MAGNITUDE"
  } else if (col.name == "BodyBodyAccJerkMag") {
    nice.colname <- "BODY_BODY_ACCELEROMETER_JERK_MAGNITUDE"
  } else if (col.name == "BodyBodyGyroMag"){
    nice.colname <- "BODY_BODY_GYROSCOPE_MAGNITUDE"
  } else if (col.name == "BodyBodyGyroJerkMag"){
    nice.colname <- "BODY_BODY_GYROSCOPE_JERK_MAGNITUDE"
  }
  if(nchar(col.direction)>0){
   return (paste(nice.aggname, nice.type, nice.colname, col.direction, sep = "_"))
  }  else {
   return (paste(nice.aggname, nice.type, nice.colname, sep = "_"))
  }
}
## 4.2 Add nice name description to features
rowcols <- filtered.features$V2
### 4.2.1 Call custom function to get a nice description
nicecols <- lapply(rowcols, function(x){getNiceDescription(x)})
### 4.2.2 Add calculated nice name to filtered.features data frame as desc column
filtered.features$desc <- unlist(nicecols)
mean.std.X_merged.labeled <- mean.std.X_merged
## 4.3 Set column names to mean.std.X_merged with nice label (aka desc column) in filtered.features
colnames(mean.std.X_merged.labeled) <- filtered.features$desc
## 4.4 Select activity lookup code
activities = select(activities.lookup, V2)
## 4.5 Set descriptive variable names to activities and subjects
colnames(activities) <- 'ACTIVITY'
colnames(subject_merged) <- 'SUBJECT'
## 4.6 Merge activities, subject_merged, and mean.std.X_merged.labeled
merged.dataframe4 <- cbind(activities, subject_merged, mean.std.X_merged.labeled)

#5.Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
groupColumns <- c("ACTIVITY","SUBJECT")
dataColumns <- colnames(mean.std.X_merged.labeled)
## 5.1 calculate average for each variable
merged.dataframe5 = ddply(merged.dataframe4, groupColumns,
                          function(x) colMeans(x[dataColumns]))
## 5.2 write the data frame to text file
write.table(merged.dataframe5, file = '/tmp/dataframe5.txt', row.names = FALSE)
