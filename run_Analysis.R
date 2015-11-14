######################################################################

## Getting and Cleaning Data
## Course project
## Stefania C. Radopoulou
## November 2015

## This script does the following on the UCI HAR Dataset
## Downloads the folder with the data
## Unzips the folder
## Explores the files
## Reads the data from the files
## Merges the training and test sets and creates one dataset
## Extracts only the mean and standard deviation for each measurement
## Uses descriptive activity names to name the dataset's activities
## Labels the data set with descriptive variable names
## From the previous step, creates a second dataset, which is an independent tidy dataset with the average of each variable for each activity and each subject

#######################################################################

if(!file.exists("./data")){dir.create("./data")}

## Downloads the folder with the data
urlFile <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(urlFile, destfile = "./data/dataset.zip", method = "curl")

## Unzips the folder
unzip(zipfile = "./data/dataset.zip", exdir = "./data")

## get the UCI HAR Dataset
pathData <- file.path("./data", "UCI HAR Dataset")

## Explores the files
files <- list.files(pathData, recursive = TRUE)
files

## Reads the data from the files
activityDataTest <- read.table(file.path(pathData, "test", "Y_test.txt"), header = FALSE)
activityDataTrain <- read.table(file.path(pathData, "train", "Y_train.txt"), header = FALSE)
subjectDataTest <- read.table(file.path(pathData, "test", "subject_test.txt"), header = FALSE)
subjectDataTrain <- read.table(file.path(pathData, "train", "subject_train.txt"), header = FALSE)
featureDataTest <- read.table(file.path(pathData, "test", "X_test.txt"), header = FALSE)
featureDataTrain <- read.table(file.path(pathData, "train", "X_train.txt"), header = FALSE)
featureDataNames <- read.table(file.path(pathData, "features.txt"), head = FALSE)

## look at the properties of the data
str (activityDataTest)
str (activityDataTrain)
str (subjectDataTest)
str (subjectDataTrain)
str (featureDataTest)
str (featureDataTrain)

## Merges the training and test sets and creates one dataset
## concatenate the data
subjectData <- rbind(subjectDataTrain, subjectDataTest)
activityData <- rbind(activityDataTrain, activityDataTest)
featureData <- rbind(featureDataTrain, featureDataTest)

## set variable names
names(subjectData) <- c("subject")
names(activityData) <- c("activity")
names(featureData) <- featureDataNames$V2

## merge columns to create the data frame for all data
combinedData <- cbind(subjectData, activityData)
allData <- cbind (featureData, combinedData)

## Extracts only the mean and standard deviation for each measurement
## name the subset data features
subFeaturesNames <- featureDataNames$V2[grep("mean\\(\\)|std\\(\\)", featureDataNames$V2)]

## subset the data frame using names of selected features
names <- c(as.character(subFeaturesNames), "subject", "activity")
allData <- subset(allData, select = names)

## look at the new frame created
str(allData)

## Uses descriptive activity names to name the dataset's activities
## read the activity_labels text file
activityLabels <- read.table(file.path(pathData, "activity_labels.txt"), header = FALSE)

## factorize the variable activity in the allData frame with descritptive activity names
head (allData$activity, 30)

## Labels the data set with descriptive variable names
names(allData) <- gsub("-std$", "StandardDeviation", names(allData))
names(allData) <- gsub("-mean", "Mean", names(allData))
names(allData) <- gsub("^t", "time", names(allData))
names(allData) <- gsub("^f", "frequency", names(allData))
names(allData) <- gsub("Acc", "Accelerometer", names(allData))
names(allData) <- gsub("Gyro", "Gyroscope", names(allData))
names(allData) <- gsub("Mag", "Magnitude", names(allData))
names(allData) <- gsub("BodyBody", "Body", names(allData))

## look at the new names
names(allData)

## From the previous step, creates a second dataset, which is an independent tidy dataset with the average of each variable for each activity and each subject
dataSecond <- aggregate(. ~subject + activity, allData, mean)
dataSecond <- dataSecond[order(dataSecond$subject, dataSecond$activity),]
write.table(dataSecond, file = "tidydata.txt", row.names = FALSE)




