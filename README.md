## Introduction
This repository is for coursera's <a href="https://class.coursera.org/getdata-006">Getting and Cleaning Data by Jeff Leek, PhD, Roger D. Peng, PhD, Brian Caffo, PhD</a> and contains following three files: 

<ol>
<li><a href="https://github.com/hidekoji/coursera_getting_and_cleaning_data/blob/master/README.md">README</a></li>
<li><a href="https://github.com/hidekoji/coursera_getting_and_cleaning_data/blob/master/run_analysis.R">run_analysis.R</a></li>
<li>Code Book</li>
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

In R, there is a function called `download.file` that allows you to download the file from an URL you provide as the argument. In this course project, I used temporary file, which is created by `tempfile()` function, for storing the zip file. Once you downloaded the zip file, you can use `unzip` function to explode the zip file.

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

As you can see below, since both test and train data has same number of columns for X, y and Subject data. You can use `rbind` function to join two data frames (datasets) vertically(i.e. by rows). Once you finished merging X, y and subject data, then as a last step, you can merge X, y, and Subject data horizontally(by columns) with `cbind`


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
## 1.3 Set column names to y_merged
#colnames(y_merged) <- 'AcitivityType'
## 1.4 merge subject_test and subject_train (keep all the records from both subject_test and subject_train)
subject_merged <- rbind(subject_test, subject_train)
## 1.5 merge X_merged, y_merged, and subject_,erged
merged.dataframe <- cbind(X_merged, y_merged,subject_merged)
````

### Extracts only the measurements on the mean and standard deviation for each measurement
The next step is data transformation and you need to filter data by only selecting mean or deviation columns for each measurement. If look into the features data frame's V2 column, you can see what aggregation function is used for each measurement like this.

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
You can grab descriptive activity names from activity labels. Since activities data frame only contains the look up code, you need to join the y_merged data frame with activity_labels data frame with `left_join` function. Now you have activity.lookup data frame. To get a merged data farme, use `cbind` like previous step and merge mean.std.X_merged, activities.lookup (only V2 column so need to do `select`), and subject_merged data frame.

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
