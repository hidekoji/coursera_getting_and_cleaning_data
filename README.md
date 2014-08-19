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

In R, there is a function called `download.file` that allows you to download the file from an URL you provide as the argument. In this course project, download the zip file to temporary folder which is created by `tempfile()` function.
Once you downloaded the zip file, you can use `unzip` function to explode the zip file.

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

