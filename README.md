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
So the next step is read the exploede data files which are placed under UCI HAR Dataset folder.In this zip file there are following data sets:

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

