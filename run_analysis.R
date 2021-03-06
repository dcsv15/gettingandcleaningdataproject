############################################################################### 
# Course Project: Getting-and-Cleaning-Data Week 4 project assignment
# Author: dcsv15 
# Date : 02/27/2016
#
#Project Assignment:
#The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. 
#The goal is to prepare tidy data that can be used for later analysis.  
#You will be graded by your peers on a series of yes/no questions related to the project.  
#You will be required to submit:  
#1) a tidy data set as described below,  
#2) a link to a Github repository with your script for performing the analysis, and  
#3) a code book that describes the variables, the data, and any transformations or work that you performed  
	#to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts.  
	#This repo explains how all of the scripts work and how they are connected.  


#One of the most exciting areas in all of data science right now is wearable computing - see for example this article .  
#Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained: 
#http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones 
#Here are the data for the project: 
#https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
#You should create one R script called run_analysis.R that does the following.  
#1) Merges the training and the test sets to create one data set. 
#2) Extracts only the measurements on the mean and standard deviation for each measurement.  
#3) Uses descriptive activity names to name the activities in the data set 
#4) Appropriately labels the data set with descriptive variable names.  
#5) Creates a second, independent tidy data set with the average of each variable for each activity and each subject.  


############################################################################### 


#Script begine here

getwd()
setwd("c:/coursera/datacleaning/week4/assign") 

#download required project data 
library(httr)  
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip" 
file <- "accelerometerdata.zip" 
if(!file.exists(file)){ 
	print("File does not exists, downloading now!") 
	download.file(url, file) 
} 


#Unzip the downloaded data, check if folder already exists before that 
datafolder <- "UCI HAR Dataset" 
resultsfolder <- "results" 
if(!file.exists(datafolder)){ 
	print("Unzip the downloaded file") 
	unzip(file, list = FALSE, overwrite = TRUE) 
}  

#Create results folders if it doesn't exist
if(!file.exists(resultsfolder)){ 
	print("Create results folder") 
	dir.create(resultsfolder) 
}  


#read txt and covnert to data.frame 
gettables <- function (filename,cols = NULL){ 
	print(paste("Getting table:", filename)) 
	f <- paste(datafolder,filename,sep="/") 
	data <- data.frame() 
	if(is.null(cols)){ 
		data <- read.table(f,sep="",stringsAsFactors=F) 
	} else { 
		data <- read.table(f,sep="",stringsAsFactors=F, col.names= cols) 
	} 
	data 
} 


#run and check gettables 
features <- gettables("features.txt") 


#read data and build database 
getdata <- function(type, features){ 
	print(paste("Getting data", type)) 
	subject_data <- gettables(paste(type,"/","subject_",type,".txt",sep=""),"id") 
	y_data <- gettables(paste(type,"/","y_",type,".txt",sep=""),"activity") 
	x_data <- gettables(paste(type,"/","X_",type,".txt",sep=""),features$V2) 
	return (cbind(subject_data,y_data,x_data)) 
} 


#run and check getdata 
test <- getdata("test", features) 
train <- getdata("train", features) 


#save the resulting data in the indicated folder 
saveresults <- function (data,name){ 
	print(paste("saving results", name)) 
	file <- paste(resultsfolder, "/", name,".csv" ,sep="") 
	write.csv(data,file) 
} 


# Necessary Task Required for this assignment #


#1) Merges the training and the test sets to create one data set. 
library(plyr) 
data <- rbind(train, test) 
data <- arrange(data, id) 


#2) Extracts only the measurements on the mean and standard deviation for each measurement.  
activity_mean_and_std <- data[,c(1,2,grep("std", colnames(data)), grep("mean", colnames(data)))] 
saveresults(mean_and_std,"activity_mean_and_std") 


#3) Uses descriptive activity names to name the activities in the data set 
activity_labels <- gettables("activity_labels.txt") 


#4) Appropriately labels the data set with descriptive variable names.  
data$activity <- factor(data$activity, levels=activity_labels$V1, labels=activity_labels$V2) 


#5) Creates a second, independent tidy data set with the average of each variable for each activity and each subject.  
activity_tidy_dataset <- ddply(activity_mean_and_std, .(id, activity), .fun=function(x){ colMeans(x[,-c(1:2)]) }) 
colnames(activity_tidy_dataset)[-c(1:2)] <- paste(colnames(activity_tidy_dataset)[-c(1:2)], "_mean", sep="") 
saveresults(activity_tidy_dataset,"activity_tidy_dataset") 


#This alternate additional method to create a tidy dataset text result file instead of csv 
#save the resulting data in the indicated folder 
saveresultstxt <- function (data,name){ 
	print(paste("saving results", name)) 
	file <- paste(resultsfolder, "/", name,".txt" ,sep="") 
	
	write.table(data,file, row.name = FALSE)
} 

saveresultstxt(activity_tidy_dataset,"activity_tidy_dataset") 

#End of script
