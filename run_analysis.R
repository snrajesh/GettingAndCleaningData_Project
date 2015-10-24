# Title: "Getting and Cleaning Data: Course Project"
# Author: "Rajesh Nambiar"
# Date: "October 23, 2015"
# 
# The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. 
# The goal is to prepare tidy data that can be used for later analysis. 
# You will be graded by your peers on a series of yes/no questions related to the project. 
# You will be required to submit: 
#     1) a tidy data set as described below, 
#     2) a link to a Github repository with your script for performing the analysis,  
#     3) a code book that describes the variables, the data, and any transformations or work that you performed 
#         to clean up the data called CodeBook.md. 
#     4)You should also include a README.md in the repo with your scripts. 
#         This repo explains how all of the scripts work and how they are connected.
# 
# You should create one R script called run_analysis.R that does the following. 
#     1) Merges the training and the test sets to create one data set.
#     2) Extracts only the measurements on the mean and standard deviation for each measurement. 
#     3) Uses descriptive activity names to name the activities in the data set
#     4) Appropriately labels the data set with descriptive variable names. 
#     5) From the data set in step 4, creates a second, independent tidy data set 
#         with the average of each variable for each activity and each subject.
#        
############################################################################################

#setup project working directory
#   wd <-getwd()
#   if(!file.exists("./GettingAndCleaningData_Project")){dir.create("./GettingAndCleaningData_Project")}
#   setwd('./GettingAndCleaningData_Project')
#   source('run_analysis.R')
#   

### Load dplyr package for easy data manipulation (install if needed)
if (! require("dplyr")) {
    install.packages('dplyr'); 
    library(dplyr);
}



##
## Step 0: Download file, load files into data.frame.tables, and do initial clean-up
##


### A. Download file and unzip file

download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
               destfile = "./getdata-projectfiles-UCI HAR Dataset.zip", mode="wb")
unzip("./getdata-projectfiles-UCI HAR Dataset.zip")


## A. custom function to standardize column-names -  removes non-alphaNumeric & convert into lower-case

reformatColumnName <- function(vColumnName = NULL) {
    
    # substitute/remove non-alphanumeric charcter, and convert to lower 
    vColumnName <-  tolower(stringr::str_replace_all(vColumnName,"[[:punct:]]", ""))
    
    # specific to the values in features-list
    # if first character is t change it to "time", if it is "f" change it to "frequency"
    vFirst <- substring(vColumnName,1,1)
    vFirst <- gsub(pattern="[t]", vFirst, replacement="time")
    vFirst <- gsub(pattern="[f]", vFirst, replacement="frequency")
    
    #replace first character with the above replacement value
    vColumnName <- paste(vFirst, substring(vColumnName, 2), sep = "")
    rm(vFirst)
    
    # specific to feature list: there is a typo - body is documented as bodybody
    vColumnName <- gsub('bodybody','body', vColumnName)
    
    return(vColumnName)    
}   


## B. Load Activity-list lookup tables with column-names

activityLabels <- tbl_df(read.table("./UCI HAR Dataset/activity_labels.txt",sep = " ", header = FALSE, 
                                    as.is = TRUE, col.names = c("activityid", "activityRaw")));

# B2. Clean-up activity-name as these will be added as activity description to the final data set
activityLabels <- mutate(activityLabels, activity = reformatColumnName(activityRaw) );


# C. Load Features List lookup tables with column-names
features <- tbl_df(read.table("./UCI HAR Dataset/features.txt",sep = " ", header = FALSE, 
                              as.is = TRUE, col.names = c("featureid", "featureRaw")));


# C2. Clean-up feature-name as these will be used as column-names later for measurements in the final data
features <- mutate(features, feature = reformatColumnName(featureRaw) );


# C3. clean-up duplicate feature values by appending id to it, as these will be used as column-names

tmp <- features %>%
    group_by(feature) %>%
    summarize(count=n()) %>%
    filter(count >1)  %>%                   ## identify feature values with more than one entry
    left_join(features,by='feature') %>%  ## join to original list to get id
    mutate(feature = paste0(feature,featureid)) %>%     ## append id to name to make it unique
    select (featureid,feature, featureRaw); 

features <- features %>%
    anti_join(tmp,by='featureid') %>%		## get the records that are not in the duplicate list
    select (featureid,feature, featureRaw)  %>%
    union(tmp) %>%							## merge it with the corrected values from previous dataset
    arrange (featureid,feature, featureRaw); 

rm(tmp)


## D. Load Train Data set

# D1. load X data (measurement data), with column name as feature-name from feature-list
xTrain <- tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE, fill = TRUE, 
                            col.names = features$feature));

# D2. If there are any duplicate activity in the file, the column-names will get appended with .1,.2,etc. 
# Replace them with x,y,z  
colnames(xTrain) <- gsub('\\.1','y',gsub('\\.2','z',gsub('\\.3','w',colnames(xTrain))))

# D3. Add seq# to each record to join them with other datasets later
xTrain <- mutate(xTrain, sequenceid =  row_number())


# D4. load Y data (activity-label)
# Each row identifies the activity performed by the subject for each window sample. Its range is from 1 to 6
yTrain <- tbl_df(read.table("./UCI HAR Dataset/train/Y_train.txt",header = FALSE, 
                            col.names = c('activityid')))

# D5. Add seq# to each record to join them with other datasets later
yTrain <- mutate(yTrain, sequenceid = row_number())


# D6. Load subject data - 21 out of 30 subject
# Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30
subjectTrain <- tbl_df(read.table("./UCI HAR Dataset/train/subject_train.txt",sep = "", header = FALSE,
                                  col.names = c('subjectid')))

# D7. Add seq# to each record to join them with other datasets later
subjectTrain <- mutate(subjectTrain, sequenceid = row_number())


## E. Load Test Data set

# E1. load X data (measurement data), with column name as feature-name from feature-list
xTest <- tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE, fill = TRUE, 
                           col.names = features$feature))

# E2. If there are any duplicate activity in the file, the column-names will get appended with .1,.2,etc. 
# Replace them with x,y,z  
colnames(xTest) <- gsub('\\.1','y',gsub('\\.2','z',gsub('\\.3','w',colnames(xTest))))

# E3. Add seq# to each record to join them with other datasets later
xTest <- mutate(xTest, sequenceid = row_number())

# E4. Load Y data, (activity-label)
# Each row identifies the activity performed by the subject for each window sample. Its range is from 1 to 6
yTest <- tbl_df(read.table("./UCI HAR Dataset/test/Y_test.txt",header = FALSE, 
                           col.names = c('activityid')))

# E5. Add seq# to each record to join them with other datasets later
yTest <- mutate(yTest, sequenceid = row_number())


# E6. load subject data - 9 out of 30 subjects
# Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30
subjectTest <- tbl_df(read.table("./UCI HAR Dataset/test/subject_test.txt",sep = "", header = FALSE,
                                 col.names = c('subjectid')))

# E7. Add seq# to each record to join them with other datasets later
subjectTest <- mutate(subjectTest, sequenceid = row_number())



##
## Step 1. Merge the training and the test sets to create one data set.
##

# update X data with subject data, activity (Y data) and activity-description -  for both train and test data set And combine them

#1.A combine train data
mergedDatasetTrain <- xTrain %>% 
    left_join(subjectTrain, by = "sequenceid") %>%    ## append subject ID data from subject file by seq# 
    left_join(yTrain, by = "sequenceid") %>%          ## append activiy ID from Y file by seq#
    #left_join(activityLabels, by = "activityid") %>% ## append activity-name from activity file based on Id
    mutate(datagroup = "train")                       ## append a field to mark as 'Train" data set

#1.B combine test data
mergedDatasetTest <- xTest %>% 
    left_join(subjectTest, by = "sequenceid") %>%     ## append subject ID data from subject file by seq# 
    left_join(yTest, by = "sequenceid") %>%           ## append activiy ID from Y file by seq#
    #left_join(activityLabels, by = "activityid") %>% ## append activity-name from activity file based on Id
    mutate(datagroup = "test")                        ## append a field to mark as 'Test" data set



# 1.c combine both train and test datasets into one table
mergedDataset <- bind_rows(mergedDatasetTrain, mergedDatasetTest) ;  

rm(mergedDatasetTrain);
rm(mergedDatasetTest);


##
## Step 2. Extracts only the measurements on the mean and standard deviation for each measurement.
##

# tidyDataset <- select(mergedDataset, 
#                         datagroup, sequenceid, subjectid, activityid, activity, 
#                         contains('mean'), contains("std"), 
#                         -contains('meanfreq'), -starts_with('angle')  ## ignore columns that are not really mean()
#                         )

# get the id of features that has mean() or std() in it (not columns like meanFreq)
# using unlist & array convert the 1-dimensional data frame to unnamed integer array

columnsOfInterest <- unlist(array(
    features %>% filter(grepl('mean()', featureRaw, fixed=TRUE) |
                            grepl('std()', featureRaw, fixed=TRUE)) %>% 
        select(featureid)
));

# subset the columns based on activityid (of mean() and std()), which is also the index of columns
# (because the measurement in X data was in the same order as values/rows in feature list, so is the merged data)
tidyDataset <- select(
    mergedDataset,
    datagroup, sequenceid, subjectid, activityid,
    columnsOfInterest
);



##
## Step 3 Uses descriptive activity names to name the activities in the data set
##

# The activiy description from the activity-labels.txt is reformated to be lowercase and have only Alphanumeric characters 
# This value is added to the tidyDataSet based on the activityId in the Y file 

tidyDataset <- tidyDataset %>% 
    left_join(activityLabels, by = "activityid") %>%        ## append activity-name from activity file based on Id
    select(1:4, activity, 5:70) ## insert the activity column right after activityId

##
## Step 4 Appropriately labels the data set with descriptive variable names. 
##

# The measurement varables from the features.txt is reformated to be lowercase and have only Alphanumeric characters 
# Also the frequency domain measurement variables (starting with "f" are transalted to "frequency" 
# And the time domain measurement variables (starting with "t" are transalted to "time" 
# The typographical error for "bodybody" was replaced with "body"
# There were some duplicate measurements (proably truncated due to size) are made unique by appending ID to the description
# This value is used as the column-name of the measurement variables while loading X data, and is carried over to mergedDataSet  


##
## Step 5. From the data set in step 4, creates a second, independent tidy data set with 
##			the average of each variable for each activity and each subject.
##

# 5.1 All measurement variables are grouped by subject and activity and summarized by their mean value

tidyDataSummary <-
    tidyDataset %>%
    group_by(activity, datagroup, subjectid) %>%
    select(-sequenceid) %>% 
    summarize_each(funs(mean), matches("mean"),matches("std")) %>%
    arrange(activity, datagroup, subjectid)

# set activity, datagroup, subjectid as factors
tidyDataSummary$activity <- as.factor(tidyDataSummary$activity)
tidyDataSummary$datagroup <- as.factor(tidyDataSummary$datagroup)
tidyDataSummary$subjectid <- as.factor(tidyDataSummary$subjectid)
#tidyDataSummary <- as.data.frame(unclass(tidyDataSummary))

# column-names are appended with averge to reflect that its the averge value
colnames(tidyDataSummary)[-(1:3)] <- paste0('avg', colnames(tidyDataSummary)[-(1:3)] )


##
## 6. The summarized tidy data is written out to a file for sharing.
##

write.table(tidyDataSummary, 'tidydata.txt',row.names = FALSE)



### The list of columns in the data set:

### Load xtable package to create/display table (install if needed)
if (! require("xtable")) {
    install.packages('xtable'); 
    library(xtable);
}

# get the column-names and description
tabColumns <- 
    bind_rows(
        as.data.frame(rbind(
            c(column='activity', measurement='activity performed'),
            c(column='datagroup', measurement='test or train data group'),
            c(column='subjectid', measurement='id for the subject')
        ),stringsAsFactors=FALSE),
        features %>%
            filter(grepl('mean()', featureRaw, fixed = TRUE) |
                       grepl('std()', featureRaw, fixed = TRUE)) %>%
            mutate(featureRaw = paste0('avg of ',featureRaw)) %>%
            rename(id = featureid, column = feature, measurement = featureRaw) %>%
            select(column, measurement)
    );

# use xtable to print as table
tabColumns <-xtable(tabColumns)
print(tabColumns, type='html')



##
## 7. Read back the summarized tidy data 
##


tidydata <- read.table('tidydata.txt', header = TRUE) 


# Summary of data and data variables can be viewed using str and summary.

str(tidydata)
summary(tidydata)
head(tidydata,1)


##########################################################################

# to create .md file from .rmd file

#library(knitr)
#knit2html("CodeBook.Rmd")
#browseURL("CodeBook.html")

# reset wd back to the initial one (using path saved in wd variable)
#setwd(wd);

# source('run_analysis.R')
