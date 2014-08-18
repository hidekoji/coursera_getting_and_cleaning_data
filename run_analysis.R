# 0. Read data
## 0.1 create a temp file
temp <- tempfile()
## 0.2 download data zip file
download.file("https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",temp, method="curl", mode="wb")
## 0.3 unzip file and read data file.
unzip(temp)
## 0.4 Read activity_labels.txt
features <- read.table("UCI\ HAR\ Dataset/features.txt")
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
## 1.3 Set column names to y_merged
#colnames(y_merged) <- 'AcitivityType'
## 1.4 merge subject_test and subject_train (keep all the records from both subject_test and subject_train)
subject_merged <- rbind(subject_test, subject_train)
## 1.5 merge X_merged, y_merged, and subject_,erged
merged.dataframe <- cbind(X_merged, y_merged,subject_merged)

#2.Extracts only the measurements on the mean and standard deviation for each measurement. 
library(plyr)
library(dplyr)
## 2.1 Get column names indexes that have mean() or std()
filtered.features <- features %>% filter(grepl("mean()",V2) | grepl("std()",V2))
## 2.2 From X_merged, only select columns that in filtered_features
mean.std.X_merged <- select(X_merged, filtered.features$V1)
## 2.3 Add back y_merged and subject_merged which are omitted by step 2.2
mreged.dataframe2 <- cbind(mean.std.X_merged, y_merged, subject_merged)

#3.Uses descriptive activity names to name the activities in the data set
## 3.1 Create lookup data set by merging y_merged (activitly records) with label (activitly_labels)
activities.lookup <- left_join(y_merged, activity_labels)
## 3.2 Exclude activity Id column (col index is 80) from mean.std.X_merged
merged.dataframe3 <- cbind(mean.std.X_merged, select(activities.lookup, V2), subject_merged)

#4.Appropriately labels the data set with descriptive variable names. 
## 4.1 Set column names to X_merged with label in features
colnames(X_merged) <- features$V2
mean.std.X_merged.labeled <- select(X_merged, filtered.features$V1)
## Select activity lookup code
activities = select(activities.lookup, V2)
## Set descriptive variable names to activities and subjects
colnames(activities) <- 'Activity'
colnames(subject_merged) <- 'Subject'
## Merge activities, subject_merged, and mean.std.X_merged.labeled
merged.dataframe4 <- cbind(activities, subject_merged, mean.std.X_merged.labeled)

#5.Creates a second, independent tidy data set with the average of each variable for each activity and each subject. 
groupColumns <- c("Activity","Subject")
dataColumns <- colnames(mean.std.X_merged.labeled)
## 5.1 calculate average for each variable
merged.dataframe5 = ddply(merged.dataframe4, groupColumns, 
                          function(x) colMeans(x[dataColumns]))
## 5.2 write the data frame to text file
write.table(merged.dataframe5, file = '/tmp/dataframe5.txt', row.names = FALSE)
