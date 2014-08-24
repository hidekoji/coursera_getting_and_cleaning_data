## Introduction
This repository is for coursera's <a href="https://class.coursera.org/getdata-006">Getting and Cleaning Data by Jeff Leek, PhD, Roger D. Peng, PhD, Brian Caffo, PhD</a> and contains following three files: 

<ol>
<li><a href="https://github.com/hidekoji/coursera_getting_and_cleaning_data/blob/master/README.md">README</a></li>
<li><a href="https://github.com/hidekoji/coursera_getting_and_cleaning_data/blob/master/run_analysis.R">run_analysis.R</a></li>
<li><a href="https://github.com/hidekoji/coursera_getting_and_cleaning_data/blob/master/DataDictionary.md">Code Book (a.k.a Data Dictionary)</a></li>
</ol>

## About run_analysis.R

This R script consists of following parts:

<ol>
<li> Download data zip file from <a href="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip">the link</a> and explode it to a temp directory</li>
<li> Read data as R data frames</li>
<li> Merge the training and the test sets to create one data set</li>
<li> Extracts only the measurements on the mean and standard deviation for each measurement</li>
<li> Uses descriptive activity names to name the activities in the data set</li>
<li> Appropriately labels the data set with descriptive variable names </li>
<li> Creates a second, independent tidy data set with the average of each variable for each activity and each subject. </li>
</ol>

### Download data from <a href="https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip">the link</a> and exploade it to a temp directory

In R, there is a function called `download.file` that allows you to download data file from an URL you provide as the argument. In this course project, I used temporary file, which is created by `tempfile()` function, for storing the zip file. Once you downloaded the zip file, you can use `unzip` function to explode the zip file.

So the R code for downloading data looks like this:

````R
# 0. Read data
## 0.1 create a temp file
temp <- tempfile()
## 0.2 download data zip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp, method="curl", mode="wb")
## 0.3 unzip file and read data file.
unzip(temp)
````

### Read data as R data frames
The next step is read the exploeded data files which are placed under UCI HAR Dataset folder. In the zip file, there are following data sets:

* UCI HAR Dataset/features.txt
* UCI HAR Dataset/activity_labels.txt
* UCI HAR Dataset/test/X_test.txt
* UCI HAR Dataset/test/subject_test.txt
* UCI HAR Dataset/test/y_test.txt
* UCI HAR Dataset/train/X_train.txt
* UCI HAR Dataset/train/subject_train.txt
* UCI HAR Dataset/train/y_train.txt

You can use `read.table` function to read these txt files. As for features.txt, since you need to transform the data in next couple of steps, set `stringsAsFactors = FALSE` so that you can treat the string as character instead of factor.
Once you finished reading these files, you can unlink temp file with `unlink` function.

So the R code for reading data files looks like this. 

````R
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
````

### Merge the training and the test sets to create one data set
The next step is merging the trainig and the test sets and to do this task, you need to consider following three components.

* X data 
* y data
* Subject data

As you can see below, both test and train data have same number of columns for X, y and Subject data so you can use `rbind` function to join two data frames (datasets) vertically(i.e. by rows). Once you finished merging X, y and subject data, then as a last step, you can merge X, y, and Subject data horizontally(by columns) with `cbind`


````R
> dim(X_test)
[1] 2947  561
> dim(X_train)
[1] 7352  561
> dim(y_test)
[1] 2947    1
> dim(y_train)
[1] 7352    1
> dim(subject_test)
[1] 2947    1
> dim(subject_train)
[1] 7352    1
````

So the R code for merging training and the test sets to create one data set looks like this:

````R
# 1. Merge the training and the test sets to create one data set.
## 1.1 merge X_test and X_train (keep all the records from both X_test and X_train)
X_merged <- rbind(X_test, X_train)
## 1.2 merge y_test and y_train (keep all the records from both y_test and y_train)
y_merged <- rbind(y_test, y_train)
## 1.3 merge subject_test and subject_train (keep all the records from both subject_test and subject_train)
subject_merged <- rbind(subject_test, subject_train)
## 1.4 merge X_merged, y_merged, and subject_,erged
merged.dataframe <- cbind(X_merged, y_merged,subject_merged)
````

### Extracts only the measurements on the mean and standard deviation for each measurement
The next step is data transformation and you need to filter data by only selecting mean or deviation columns for each measurement. If you look into the features data frame's V2 column, you can see what aggregation function is used for each measurement like this.

````R
> head(features)
  V1                V2
1  1 tBodyAcc-mean()-X
2  2 tBodyAcc-mean()-Y
3  3 tBodyAcc-mean()-Z
4  4  tBodyAcc-std()-X
5  5  tBodyAcc-std()-Y
6  6  tBodyAcc-std()-Z
````

As a first step, you can filter this features data frame by using `grelpl` and `filter` function. As for `filter`, let's use [Hadley Wickham's dplyr](https://github.com/hadley/dplyr)  for the project. Once you get a filterd features data frame that only contains mean and stadard deviation data (i.e. column indexs), you can use dplyr's `select` function and select columns from X_merge data frame by passing column indexes obtained from filtered.features data frame's V1 column. Now you get a  filtered X data (mean.std.X_merged in my R code) as requested. So with `cbind` function let's create a merged data frame by combining mean.std.X_merged, y_merged, and subject_merged horizontally (i.e. by columns)

So the R code that Extracts only the measurements on the mean and standard deviation for each measurement looks like this:

````R
#2.Extracts only the measurements on the mean and standard deviation for each measurement. 
library(plyr)
library(dplyr)
## 2.1 Get column names indexes that have mean() or std()
filtered.features <- features %>% filter(grepl("mean()",V2) | grepl("std()",V2))
## 2.2 From X_merged, only select columns that in filtered.features
mean.std.X_merged <- select(X_merged, filtered.features$V1)
## 2.3 Add back y_merged and subject_merged which are omitted by step 2.2
mreged.dataframe2 <- cbind(mean.std.X_merged, y_merged, subject_merged)
````

### Uses descriptive activity names to name the activities in the data set
You can grab descriptive activity names from activity labels. Here is the labels in the activity_labels.

````R
> head(activity_labels)
  V1                 V2
1  1            WALKING
2  2   WALKING_UPSTAIRS
3  3 WALKING_DOWNSTAIRS
4  4            SITTING
5  5           STANDING
6  6             LAYING
````

Since activities data frame only contains the look up code, you need to join the y_merged data frame with activity_labels data frame with `left_join` function. Now you have activity.lookup data frame. To get a merged data farme, use `cbind` like previous step and merge mean.std.X_merged, activities.lookup (you only need V2 column so need to do `select`), and subject_merged data frame.

So the R code that Extracts only the measurements on the mean and standard deviation for each measurement looks like this:

````R
#3.Uses descriptive activity names to name the activities in the data set
## 3.1 Create lookup data set by merging y_merged (activitly records) with label (activitly_labels)
activities.lookup <- left_join(y_merged, activity_labels)
## 3.2 Create a merged data frame with mean.std.X_merged, descriptive activity name, and
## subject data frame 
## 
merged.dataframe3 <- cbind(mean.std.X_merged, select(activities.lookup, V2), subject_merged)
````

### Appropriately labels the data set with descriptive variable names
So how we can get descriptive variable names? As a starter, let's take a look at the filtered.features data frame. So you can see V2 columns contains some sort of variable names. But it uses too much abbreviation and difficult to understand.

````R
> head(filtered.features)
  V1                V2  
1  1 tBodyAcc-mean()-X 
2  2 tBodyAcc-mean()-Y 
3  3 tBodyAcc-mean()-Z 
4  4  tBodyAcc-std()-X 
5  5  tBodyAcc-std()-Y 
6  6  tBodyAcc-std()-Z 
````

If you look into the features_info.txt, you can see first small "t" stands for time and "f" for frequency domain signals.
Then it also says "Acc" stands for accelerometer and "Gyro" for gyroscope. Same apply to aggregate function name and "std" stands for standard deviation. Given these, let create a function that accpets original variable name and returns descriptive variable name. So the naming convention looks like

````
<AGGREGATION_FUNCTION>_<DOMAIN_SIGNAL_TYPE>_<SINGAL_FROM>_<SENSOR>_<AXIS>

DOMAIN_SIGNAL_TYPE: either TIME or FREQUENCY
SIGNAL_FROM :either BODY or GRAVITY
SENSOR: either ACCELEROMETER or GYROSCOPE
AXIS: X or Y or Z
````

So this converts `tBodyAcc-mean()-X` variable name to `MEAN_TIME_BODY_ACCELEROMETER_X` which I believe more descriptive

And the R function that takes care of conversion goes like this:

````R
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
  
  #get nice name for domain signal type
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
````

After you created the function, then you can use `lapply` function to do the name converson for all the variable names.
With this new descriptive variable names, call `colnames` function and set as column names (aka variable names) for the mean.std.X_merged.labeled data frame. also, set 'ACTIVITY' as descriptive variable name for activitites data frame and 'SUBJECT' for subject_merged data frame. Lastly, with `cbind` function, merge these three data frames by columns

And the R function that takes care of this part goes like this:


````R
## 4.2 Add nice name descfription to features
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
````

### Creates a second, independent tidy data set with the average of each variable for each activity and each subject.
The final step is another data transformation. This time you need to group merged data frame by activity and subject then aggregate data by calculating average for each data column. To do this, let's use `ddply` function. This function accepts group by columns and function that aggregate data. since you need to group by activity and subject, let's pass 'ACTIVITY' and 'SUBJECT' as group by columns. As for data column, with `colnames` function, you need to select whole columns available in mean.std.X_merged data frame. To calculate average of data column, you can use `colMeans()` function. Once you get the aggregated data frame, write the data frame to file system with `write.table` function.

```R
groupColumns <- c("ACTIVITY","SUBJECT")
dataColumns <- colnames(mean.std.X_merged.labeled)
## 5.1 calculate average for each variable
merged.dataframe5 = ddply(merged.dataframe4, groupColumns, 
                          function(x) colMeans(x[dataColumns]))
## 5.2 write the data frame to text file
write.table(merged.dataframe5, file = '/tmp/dataframe5.txt', row.names = FALSE)
```
