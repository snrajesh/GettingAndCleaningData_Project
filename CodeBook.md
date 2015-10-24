---
title: "Getting and Cleaning Data: Course Project"
author: "Rajesh Nambiar"
date: "October 23, 2015"
output: html_document
---

## Project Description:

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis


## Raw Data: 

One of the most exciting areas in all of data science right now is wearable computing - see for example [this article](http://www.insideactivitytracking.com/data-science-activity-tracking-and-the-battle-for-the-worlds-top-sports-brand/). Companies like Fitbit, Nike, and Jawbone Up are racing to develop the most advanced algorithms to attract new users. 
The data used for this from the course website represent data collected from the accelerometers from the Samsung Galaxy S smartphone. 

A full description is available at the site where the data was obtained: 

[Details about the study data](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) 

The data for the project: 

[Compressed Data](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) 


### Data Collection: 

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

**For each record it is provided**:

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

**The dataset includes the following files**:

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

**Notes**: 

- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

For more information about this dataset contact: activityrecognition@smartlab.ws

**License**:

Use of this dataset in publications must be acknowledged by referencing the following publication [1] 

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012

This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.

Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.


###############################################################################################  

##Data Analysis Synopsis:

1. The data is downloaded, uncompressed, and loaded into individual data frame tables using **dplyr** package.
2. Each file is loaded using **read.table** into its own data frame table (**tbl_df**) and assigned appropraite column names. 
3. The values in activity_label and features are reformatted to be tidy. 
4. The appraoch taken for reformating the values is : 
    * Removed all non-alphanumeric characters (punctuations)   
    * converted the text to lower case (eventhough camelCase is better for readability, to keep complaint with the lecture slides this is converetd to lower case)  
    * Also the frequency domain measurement variables (starting with "f" are transalted to "frequency"  
    * And the time domain measurement variables (starting with "t" are translated to "time"  
    * The typographical error for "bodybody" was replaced with "body"  
    * There were some duplicate measurements (proably truncated due to size) are made unique by appending activityid to the description.  
5. The measurement columns (x file) are named using feature names which make it descriptive & tidy variable name.
6. All the corresponding/relational data from feature-measurement(X data), subject data, activity (Y data) and activityLabels is combined for each group using **left_join** (*dplyr* package) and then are merged together to create a new dataset mergedDataset with using **bind_rows** (*dplyr* package). 
7. The columns with mean and std functions are extracted out to create a new dataset called tidyDataset. 
8. From the cleaned-up data, an new tidy data set (called *tidyDataSummary* is derived with the average of each variable for each activity and each subject (using *summarize_each*). The column-names are prefixed with "avg" to indicate that it is the average measurement. All the non-measurement columns are converted to "factor".
  
  
## Loading and preprocessing the data

The data is downloaded, uncompressed, and loaded into individual data frame tables using **dplyr** package.


### Download and unzip file:

```r
##
## Step 0: Download and unzip file
##


### A. Download file and unzip file
download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", 
              destfile = "./getdata-projectfiles-UCI HAR Dataset.zip")
unzip("./getdata-projectfiles-UCI HAR Dataset.zip")
```

  
### Load data:  

Each file is loaded into a data frame table using **dplyr** package and assigned appropraite column names. The variable-names are reformatted to be tidy. The measurement columns are named using tidy feature names.


```r
  ### Load dplyr package for easy data manipulation (install if needed)
  if (! require("dplyr")) {
    install.packages('dplyr'); 
    library(dplyr);
  }
```

**Reformat values**

The measurements in X data file is the 561 features from the feature list. The features has lot of non-alphanumeric characters (punctuations) in it, which is not in a tidy column name format. A generic fuction is used for cleaning up data to be no punctuations and all characters in lower case.


```r
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
```


**Load Activity-list**  

The activity_labels.txt file is loaded into data frame table activityLabels with column-names as activityid and activityRaw. The activity value is reformeted (as lower case with no non-alphanumeric characters) and stored as column activity. This is later used for updating activity in the data set using the activityid in the Y file.  


```r
## B. Load Activity-list lookup tables with column-names

activityLabels <- tbl_df(read.table("./UCI HAR Dataset/activity_labels.txt",sep = " ", header = FALSE, 
                                     as.is = TRUE, col.names = c("activityid", "activityRaw")));

# B2. Clean-up activity-name as these will be added as activity description to the final data set
activityLabels <- mutate(activityLabels, activity = reformatColumnName(activityRaw) );
```

**Load Features**

The features.txt file is loaded into data frame table features with column-names as featureid and featureRaw. The feature value is reformeted (as lower case with no non-alphanumeric characters) and stored as column feature This is later used for updating the column names of the measurement variables in the data set using their position in the X file.


```r
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
```
  
  
**Load Train Data**

All the Measurement data (X), activity data (Y), and subject data for the "train" data set group is loaded one by one. 
The measurement data from X_train.txt is loaded into table xTrain, with column name as feature-name from feature-list. A new sequenceid column is populated with sequence# within the file. This is used later for joining/binding all the relevant data together. 
The activity data from Y_train.txt is loaded into table yTrain, with column name as activityid. A new sequenceid column is populated with sequence# within the file. This is used later for joining/binding all the relevant data together. 
The subject data from subject_train.txt is loaded into table subjectTrain, with column name as activityid. A new sequenceid column is populated with sequence# within the file. This is used later for joining/binding all the relevant data together. 



```r
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
```

**Load Test Data**

All the Measurement data (X), activity data (Y), and subject data for the "test" data set group is loaded one by one. 
The measurement data from X_test.txt is loaded into table xTest, with column name as feature-name from feature-list. A new sequenceid column is populated with sequence# within the file. This is used later for joining/binding all the relevant data together. 
The activity data from Y_test.txt is loaded into table yTest, with column name as activityid. A new sequenceid column is populated with sequence# within the file. This is used later for joining/binding all the relevant data together. 
The subject data from subject_test.txt is loaded into table subjectTest, with column name as activityid. A new sequenceid column is populated with sequence# within the file. This is used later for joining/binding all the relevant data together. 


```r
## E. Load Test Data set

# E1. load X data (measurement data), with column name as feature-name from feature-list
tbXTest <- tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE, fill = TRUE, 
                             col.names = tbFeatures$feature))

# E2. If there are any duplicate activity in the file, the column-names will get appended with .1,.2,etc. 
# Replace them with x,y,z  
colnames(tbXTest) <- gsub('\\.1','y',gsub('\\.2','z',gsub('\\.3','w',colnames(tbXTest))))

# E3. Add seq# to each record to join them with other datasets later
tbXTest <- mutate(tbXTest, sequenceid = row_number())

# E4. Load Y data, (activity-label)
# Each row identifies the activity performed by the subject for each window sample. Its range is from 1 to 6
tbYTest <- tbl_df(read.table("./UCI HAR Dataset/test/Y_test.txt",header = FALSE, 
                             col.names = c('activityid')))

# E5. Add seq# to each record to join them with other datasets later
tbYTest <- mutate(tbYTest, sequenceid = row_number())


# E6. load subject data - 9 out of 30 subjects
# Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30
tbSubjectTest <- tbl_df(read.table("./UCI HAR Dataset/test/subject_test.txt",sep = "", header = FALSE,
                                   col.names = c('subjectid')))

# E7. Add seq# to each record to join them with other datasets later
tbSubjectTest <- mutate(tbSubjectTest, sequenceid = row_number())
```


## Tidy up data 


**1. Merge the training and test sets**
  
All the corresponding/relational data from feature-measurement(X data), subject data, activity (Y data) and activityLabels is combined for each group using **left_join** (*dplyr* package) and then are merged together to create a new dataset mergedDataset using **bind_rows** (*dplyr* package). 
The Measurement data (xTrain/xTest) is joined to subject data (subjectTrain/subjectTest) using sequenceid (sequence number within the file ), and then joined to activity data (yTrain/yTest) using sequenceid (sequence number within the file ), and activity is updated from activityLabels table using activityid. Then the merged data for the "train" data set group and "test" data set group are merged into one table mergedDataset. 


```r
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
```
  
  
**2. Extract the measurements on the mean and standard deviation for each measurement**
  
The columns with mean and std functions are extracted out to create a smaller/tidy data set.

First the id of features that has mean() or std() in it (not columns like meanFreq) are identified using **grep** and the corresponding ids (which will also be order of columns in mergedDataset) are stored into an integer vector ( using unlist & array to convert the 1-dimensional data frame to unnamed integer vector). These ids are then used to subset the columns with "mean" and "std" in the mergedDataset using **select** and saved as a new table, tidyDataset.



```r
##
## Step 2. Extracts only the measurements on the mean and standard deviation for each measurement.
##


# get the id of features that has mean() or std() in it (not columns like meanFreq)
# using unlist & array convert the 1-dimensional data frame to unnamed integer array

columns <- features %>% filter(grepl('mean()', featureRaw, fixed=TRUE) |
                            grepl('std()', featureRaw, fixed=TRUE));

columnsOfInterest <- unlist(array(select(columns,featureid)));

# subset the columns based on activityid (of mean() and std()), which is also the index of columns
# (because the measurement in X data was in the same order as values/rows in feature list, so is the merged data)
tidyDataset <- select(
    mergedDataset,
    datagroup, sequenceid, subjectid, activityid,
    columnsOfInterest
);

# Alternate option:

# tidyDataset <- select(mergedDataset, 
#                         datagroup, sequenceid, subjectid, activityid, activity, 
#                         contains('mean'), contains("std"), 
#                         -contains('meanfreq'), -starts_with('angle')  ## ignore columns that are not really mean()
#                         )
```
  
  
**3. Use descriptive activity names to name the activities in the data set**

The activiy description from the activity-labels.txt is reformated to be lowercase and have only Alphanumeric characters. This value is added to the mergedDataSet based on the activityid in the Y file as part of populating mergedDataset.


```r
##
## Step 3 Uses descriptive activity names to name the activities in the data set
##

# The activiy description from the activity-labels.txt is reformated to be all lowercase without any punctuations.
#   This value is added to the mergedDataSet based on the activityId in the Y file 

tidyDataset <- tidyDataset %>% 
    left_join(activityLabels, by = "activityid") %>%   ## append activity-name from activity file based on Id
    select(1:4, activity, 5:70)                         ## insert the activity column right after activityId
```
  
  
**4. Appropriately labels the data set with descriptive variable names**

The measurement variables from the features.txt is cleaned up to tidy and this value is used as the column-name of the measurement variables while loading X data, and is carried over to mergedDataSet and then to tidyDataset. 
The following steps were taken to tidy up the data:  
* Removed all non-alphanumeric characters (punctuations)   
* converted the text to lower case (eventhough camelCase is better for readability, to keep complaint with the lecture slides this is converetd to lower case)  
* Also the frequency domain measurement variables (starting with "f" are transalted to "frequency"  
* And the time domain measurement variables (starting with "t" are translated to "time"  
* The typographical error for "bodybody" was replaced with "body"  
* There were some duplicate measurements (proably truncated due to size) are made unique by appending activityid to the description.  


```r
##
## Step 4 Appropriately labels the data set with descriptive variable names. 
##

# The measurement varables from the features.txt is loaded into features table and is clened-up() to be lowercase and have only Alphanumeric characters) and stored in the column "feature". 
# This value is used as the column-name of the measurement variables while loading X data, and is carried over to mergedDataSet, and thus into tidyDataset  

# This is done along with x-data load in the previous steps D1, & E1, as part of loading xTrain & xTest

# D1. load X data (measurement data), with column name as feature-name from feature-list
xTrain <- tbl_df(read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE, fill = TRUE, 
                            col.names = features$feature));
# E1. load X data (measurement data), with column name as feature-name from feature-list
tbXTest <- tbl_df(read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE, fill = TRUE, 
                             col.names = tbFeatures$feature))
```
  
**5. Summarize data**

From the cleaned-up data, an independent tidy data set is derived with the average of each variable for each activity and each subject. This is done by by grouping subject and activity and summarized all the measurement variables to their mean value (using *summarize_each*). The column-names are prefixed with "avg" to indicate that it is the average measurement. All the non-measurement columns are converted to "factor".

This tidy data is in the wide format, as tidy data can be either in wide or long format. The wording in the rubric also suggest that either wide or long format is acceptable. The goal is to have each variable you measure in one column, each different observation of that variable in a different row. In this case, the wide format satisy these condistions.



```r
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
```


## Final Deliverable:


The summarized tidy data is written out to a file that can be used for later analysis. The format used is the default **write.table** format, which can be read back to R by anyone using the deafult **read.table** option with header=TRUE and row.names=FALSE.
  
  
**Final Tidy Data**


```r
write.table(tidyDataSummary, 'tidydata.txt',row.names = FALSE)
```
  
  
  
**To view the Data**

The below R code can be used to read data into R using "read.table".



```r
# Load tidy data
tidydata <- read.table('tidydata.txt', header = TRUE) 

# View the data
#View(tidydata)
```
  
  
**Variables**

The list of columns in the final data set:



<!-- html table generated in R 3.2.2 by xtable 1.7-4 package -->
<!-- Sat Oct 24 14:51:37 2015 -->
<table border=1>
<tr> <th>  </th> <th> column </th> <th> measurement </th>  </tr>
  <tr> <td align="right"> 1 </td> <td> activity </td> <td> activity performed </td> </tr>
  <tr> <td align="right"> 2 </td> <td> datagroup </td> <td> test or train data group </td> </tr>
  <tr> <td align="right"> 3 </td> <td> subjectid </td> <td> id for the subject </td> </tr>
  <tr> <td align="right"> 4 </td> <td> avgtimebodyaccmeanx </td> <td> avg of tBodyAcc-mean()-X </td> </tr>
  <tr> <td align="right"> 5 </td> <td> avgtimebodyaccmeany </td> <td> avg of tBodyAcc-mean()-Y </td> </tr>
  <tr> <td align="right"> 6 </td> <td> avgtimebodyaccmeanz </td> <td> avg of tBodyAcc-mean()-Z </td> </tr>
  <tr> <td align="right"> 7 </td> <td> avgtimebodyaccstdx </td> <td> avg of tBodyAcc-std()-X </td> </tr>
  <tr> <td align="right"> 8 </td> <td> avgtimebodyaccstdy </td> <td> avg of tBodyAcc-std()-Y </td> </tr>
  <tr> <td align="right"> 9 </td> <td> avgtimebodyaccstdz </td> <td> avg of tBodyAcc-std()-Z </td> </tr>
  <tr> <td align="right"> 10 </td> <td> avgtimegravityaccmeanx </td> <td> avg of tGravityAcc-mean()-X </td> </tr>
  <tr> <td align="right"> 11 </td> <td> avgtimegravityaccmeany </td> <td> avg of tGravityAcc-mean()-Y </td> </tr>
  <tr> <td align="right"> 12 </td> <td> avgtimegravityaccmeanz </td> <td> avg of tGravityAcc-mean()-Z </td> </tr>
  <tr> <td align="right"> 13 </td> <td> avgtimegravityaccstdx </td> <td> avg of tGravityAcc-std()-X </td> </tr>
  <tr> <td align="right"> 14 </td> <td> avgtimegravityaccstdy </td> <td> avg of tGravityAcc-std()-Y </td> </tr>
  <tr> <td align="right"> 15 </td> <td> avgtimegravityaccstdz </td> <td> avg of tGravityAcc-std()-Z </td> </tr>
  <tr> <td align="right"> 16 </td> <td> avgtimebodyaccjerkmeanx </td> <td> avg of tBodyAccJerk-mean()-X </td> </tr>
  <tr> <td align="right"> 17 </td> <td> avgtimebodyaccjerkmeany </td> <td> avg of tBodyAccJerk-mean()-Y </td> </tr>
  <tr> <td align="right"> 18 </td> <td> avgtimebodyaccjerkmeanz </td> <td> avg of tBodyAccJerk-mean()-Z </td> </tr>
  <tr> <td align="right"> 19 </td> <td> avgtimebodyaccjerkstdx </td> <td> avg of tBodyAccJerk-std()-X </td> </tr>
  <tr> <td align="right"> 20 </td> <td> avgtimebodyaccjerkstdy </td> <td> avg of tBodyAccJerk-std()-Y </td> </tr>
  <tr> <td align="right"> 21 </td> <td> avgtimebodyaccjerkstdz </td> <td> avg of tBodyAccJerk-std()-Z </td> </tr>
  <tr> <td align="right"> 22 </td> <td> avgtimebodygyromeanx </td> <td> avg of tBodyGyro-mean()-X </td> </tr>
  <tr> <td align="right"> 23 </td> <td> avgtimebodygyromeany </td> <td> avg of tBodyGyro-mean()-Y </td> </tr>
  <tr> <td align="right"> 24 </td> <td> avgtimebodygyromeanz </td> <td> avg of tBodyGyro-mean()-Z </td> </tr>
  <tr> <td align="right"> 25 </td> <td> avgtimebodygyrostdx </td> <td> avg of tBodyGyro-std()-X </td> </tr>
  <tr> <td align="right"> 26 </td> <td> avgtimebodygyrostdy </td> <td> avg of tBodyGyro-std()-Y </td> </tr>
  <tr> <td align="right"> 27 </td> <td> avgtimebodygyrostdz </td> <td> avg of tBodyGyro-std()-Z </td> </tr>
  <tr> <td align="right"> 28 </td> <td> avgtimebodygyrojerkmeanx </td> <td> avg of tBodyGyroJerk-mean()-X </td> </tr>
  <tr> <td align="right"> 29 </td> <td> avgtimebodygyrojerkmeany </td> <td> avg of tBodyGyroJerk-mean()-Y </td> </tr>
  <tr> <td align="right"> 30 </td> <td> avgtimebodygyrojerkmeanz </td> <td> avg of tBodyGyroJerk-mean()-Z </td> </tr>
  <tr> <td align="right"> 31 </td> <td> avgtimebodygyrojerkstdx </td> <td> avg of tBodyGyroJerk-std()-X </td> </tr>
  <tr> <td align="right"> 32 </td> <td> avgtimebodygyrojerkstdy </td> <td> avg of tBodyGyroJerk-std()-Y </td> </tr>
  <tr> <td align="right"> 33 </td> <td> avgtimebodygyrojerkstdz </td> <td> avg of tBodyGyroJerk-std()-Z </td> </tr>
  <tr> <td align="right"> 34 </td> <td> avgtimebodyaccmagmean </td> <td> avg of tBodyAccMag-mean() </td> </tr>
  <tr> <td align="right"> 35 </td> <td> avgtimebodyaccmagstd </td> <td> avg of tBodyAccMag-std() </td> </tr>
  <tr> <td align="right"> 36 </td> <td> avgtimegravityaccmagmean </td> <td> avg of tGravityAccMag-mean() </td> </tr>
  <tr> <td align="right"> 37 </td> <td> avgtimegravityaccmagstd </td> <td> avg of tGravityAccMag-std() </td> </tr>
  <tr> <td align="right"> 38 </td> <td> avgtimebodyaccjerkmagmean </td> <td> avg of tBodyAccJerkMag-mean() </td> </tr>
  <tr> <td align="right"> 39 </td> <td> avgtimebodyaccjerkmagstd </td> <td> avg of tBodyAccJerkMag-std() </td> </tr>
  <tr> <td align="right"> 40 </td> <td> avgtimebodygyromagmean </td> <td> avg of tBodyGyroMag-mean() </td> </tr>
  <tr> <td align="right"> 41 </td> <td> avgtimebodygyromagstd </td> <td> avg of tBodyGyroMag-std() </td> </tr>
  <tr> <td align="right"> 42 </td> <td> avgtimebodygyrojerkmagmean </td> <td> avg of tBodyGyroJerkMag-mean() </td> </tr>
  <tr> <td align="right"> 43 </td> <td> avgtimebodygyrojerkmagstd </td> <td> avg of tBodyGyroJerkMag-std() </td> </tr>
  <tr> <td align="right"> 44 </td> <td> avgfrequencybodyaccmeanx </td> <td> avg of fBodyAcc-mean()-X </td> </tr>
  <tr> <td align="right"> 45 </td> <td> avgfrequencybodyaccmeany </td> <td> avg of fBodyAcc-mean()-Y </td> </tr>
  <tr> <td align="right"> 46 </td> <td> avgfrequencybodyaccmeanz </td> <td> avg of fBodyAcc-mean()-Z </td> </tr>
  <tr> <td align="right"> 47 </td> <td> avgfrequencybodyaccstdx </td> <td> avg of fBodyAcc-std()-X </td> </tr>
  <tr> <td align="right"> 48 </td> <td> avgfrequencybodyaccstdy </td> <td> avg of fBodyAcc-std()-Y </td> </tr>
  <tr> <td align="right"> 49 </td> <td> avgfrequencybodyaccstdz </td> <td> avg of fBodyAcc-std()-Z </td> </tr>
  <tr> <td align="right"> 50 </td> <td> avgfrequencybodyaccjerkmeanx </td> <td> avg of fBodyAccJerk-mean()-X </td> </tr>
  <tr> <td align="right"> 51 </td> <td> avgfrequencybodyaccjerkmeany </td> <td> avg of fBodyAccJerk-mean()-Y </td> </tr>
  <tr> <td align="right"> 52 </td> <td> avgfrequencybodyaccjerkmeanz </td> <td> avg of fBodyAccJerk-mean()-Z </td> </tr>
  <tr> <td align="right"> 53 </td> <td> avgfrequencybodyaccjerkstdx </td> <td> avg of fBodyAccJerk-std()-X </td> </tr>
  <tr> <td align="right"> 54 </td> <td> avgfrequencybodyaccjerkstdy </td> <td> avg of fBodyAccJerk-std()-Y </td> </tr>
  <tr> <td align="right"> 55 </td> <td> avgfrequencybodyaccjerkstdz </td> <td> avg of fBodyAccJerk-std()-Z </td> </tr>
  <tr> <td align="right"> 56 </td> <td> avgfrequencybodygyromeanx </td> <td> avg of fBodyGyro-mean()-X </td> </tr>
  <tr> <td align="right"> 57 </td> <td> avgfrequencybodygyromeany </td> <td> avg of fBodyGyro-mean()-Y </td> </tr>
  <tr> <td align="right"> 58 </td> <td> avgfrequencybodygyromeanz </td> <td> avg of fBodyGyro-mean()-Z </td> </tr>
  <tr> <td align="right"> 59 </td> <td> avgfrequencybodygyrostdx </td> <td> avg of fBodyGyro-std()-X </td> </tr>
  <tr> <td align="right"> 60 </td> <td> avgfrequencybodygyrostdy </td> <td> avg of fBodyGyro-std()-Y </td> </tr>
  <tr> <td align="right"> 61 </td> <td> avgfrequencybodygyrostdz </td> <td> avg of fBodyGyro-std()-Z </td> </tr>
  <tr> <td align="right"> 62 </td> <td> avgfrequencybodyaccmagmean </td> <td> avg of fBodyAccMag-mean() </td> </tr>
  <tr> <td align="right"> 63 </td> <td> avgfrequencybodyaccmagstd </td> <td> avg of fBodyAccMag-std() </td> </tr>
  <tr> <td align="right"> 64 </td> <td> avgfrequencybodyaccjerkmagmean </td> <td> avg of fBodyBodyAccJerkMag-mean() </td> </tr>
  <tr> <td align="right"> 65 </td> <td> avgfrequencybodyaccjerkmagstd </td> <td> avg of fBodyBodyAccJerkMag-std() </td> </tr>
  <tr> <td align="right"> 66 </td> <td> avgfrequencybodygyromagmean </td> <td> avg of fBodyBodyGyroMag-mean() </td> </tr>
  <tr> <td align="right"> 67 </td> <td> avgfrequencybodygyromagstd </td> <td> avg of fBodyBodyGyroMag-std() </td> </tr>
  <tr> <td align="right"> 68 </td> <td> avgfrequencybodygyrojerkmagmean </td> <td> avg of fBodyBodyGyroJerkMag-mean() </td> </tr>
  <tr> <td align="right"> 69 </td> <td> avgfrequencybodygyrojerkmagstd </td> <td> avg of fBodyBodyGyroJerkMag-std() </td> </tr>
   </table>
  
  
  
**Details about each measurement variable**:

The features selected for this database come from the accelerometer and gyroscope 3-axial raw signals tAcc-XYZ and tGyro-XYZ. These time domain signals (prefix 't' to denote time) were captured at a constant rate of 50 Hz. Then they were filtered using a median filter and a 3rd order low pass Butterworth filter with a corner frequency of 20 Hz to remove noise. Similarly, the acceleration signal was then separated into body and gravity acceleration signals (tBodyAcc-XYZ and tGravityAcc-XYZ) using another low pass Butterworth filter with a corner frequency of 0.3 Hz. 

Subsequently, the body linear acceleration and angular velocity were derived in time to obtain Jerk signals (tBodyAccJerk-XYZ and tBodyGyroJerk-XYZ). Also the magnitude of these three-dimensional signals were calculated using the Euclidean norm (tBodyAccMag, tGravityAccMag, tBodyAccJerkMag, tBodyGyroMag, tBodyGyroJerkMag). 

Finally a Fast Fourier Transform (FFT) was applied to some of these signals producing fBodyAcc-XYZ, fBodyAccJerk-XYZ, fBodyGyro-XYZ, fBodyAccJerkMag, fBodyGyroMag, fBodyGyroJerkMag. (Note the 'f' to indicate frequency domain signals). 

These signals were used to estimate variables of the feature vector for each pattern:  
'-XYZ' is used to denote 3-axial signals in the X, Y and Z directions.

    tBodyAcc-XYZ
    tGravityAcc-XYZ
    tBodyAccJerk-XYZ
    tBodyGyro-XYZ
    tBodyGyroJerk-XYZ
    tBodyAccMag
    tGravityAccMag
    tBodyAccJerkMag
    tBodyGyroMag
    tBodyGyroJerkMag
    fBodyAcc-XYZ
    fBodyAccJerk-XYZ
    fBodyGyro-XYZ
    fBodyAccMag
    fBodyAccJerkMag
    fBodyGyroMag
    fBodyGyroJerkMag

The set of variables that were estimated from these signals are: 

    mean(): Mean value
    std(): Standard deviation
    mad(): Median absolute deviation 
    max(): Largest value in array
    min(): Smallest value in array
    sma(): Signal magnitude area
    energy(): Energy measure. Sum of the squares divided by the number of values. 
    iqr(): Interquartile range 
    entropy(): Signal entropy
    arCoeff(): Autorregresion coefficients with Burg order equal to 4
    correlation(): correlation coefficient between two signals
    maxInds(): index of the frequency component with largest magnitude
    meanFreq(): Weighted average of the frequency components to obtain a mean frequency
    skewness(): skewness of the frequency domain signal 
    kurtosis(): kurtosis of the frequency domain signal 
    bandsEnergy(): Energy of a frequency interval within the 64 bins of the FFT of each window.
    angle(): Angle between to vectors.

Additional vectors obtained by averaging the signals in a signal window sample. These are used on the angle() variable:

    gravityMean   
    tBodyAccMean   
    tBodyAccJerkMean  
    tBodyGyroMean   
    tBodyGyroJerkMean   

The complete list of variables of each feature vector is available in [features.txt](https://github.com/snrajesh/GettingAndCleaningData_Project/blob/master/UCI%20HAR%20Dataset/features.txt)
  
  
**Data Fields**

Summary of data and data variables can be viewed using str and summary.


```r
str(tidydata)
```

```
## 'data.frame':	180 obs. of  69 variables:
##  $ activity                       : Factor w/ 6 levels "laying","sitting",..: 1 1 1 1 1 1 1 1 1 1 ...
##  $ datagroup                      : Factor w/ 2 levels "test","train": 1 1 1 1 1 1 1 1 1 2 ...
##  $ subjectid                      : int  2 4 9 10 12 13 18 20 24 1 ...
##  $ avgtimebodyaccmeanx            : num  0.281 0.264 0.259 0.28 0.26 ...
##  $ avgtimebodyaccmeany            : num  -0.0182 -0.015 -0.0205 -0.0243 -0.0175 ...
##  $ avgtimebodyaccmeanz            : num  -0.107 -0.111 -0.108 -0.117 -0.108 ...
##  $ avgtimegravityaccmeanx         : num  -0.51 -0.421 -0.58 -0.453 -0.379 ...
##  $ avgtimegravityaccmeany         : num  0.753 0.915 -0.119 -0.139 0.803 ...
##  $ avgtimegravityaccmeanz         : num  0.6468 0.3415 0.9579 -0.0311 0.275 ...
##  $ avgtimebodyaccjerkmeanx        : num  0.0826 0.0934 0.0881 0.0738 0.0854 ...
##  $ avgtimebodyaccjerkmeany        : num  0.01225 0.00693 0.01156 0.0157 0.00774 ...
##  $ avgtimebodyaccjerkmeanz        : num  -0.0018 -0.00641 -0.00705 0.00717 -0.00437 ...
##  $ avgtimebodygyromeanx           : num  -0.01848 -0.00923 -0.01363 -0.01956 -0.01465 ...
##  $ avgtimebodygyromeany           : num  -0.1118 -0.093 -0.1589 -0.077 -0.0836 ...
##  $ avgtimebodygyromeanz           : num  0.145 0.17 0.101 0.105 0.145 ...
##  $ avgtimebodygyrojerkmeanx       : num  -0.102 -0.105 -0.104 -0.1 -0.099 ...
##  $ avgtimebodygyrojerkmeany       : num  -0.0359 -0.0381 -0.0276 -0.0389 -0.0411 ...
##  $ avgtimebodygyrojerkmeanz       : num  -0.0702 -0.0712 -0.0569 -0.0591 -0.0679 ...
##  $ avgtimebodyaccmagmean          : num  -0.977 -0.955 -0.931 -0.957 -0.948 ...
##  $ avgtimegravityaccmagmean       : num  -0.977 -0.955 -0.931 -0.957 -0.948 ...
##  $ avgtimebodyaccjerkmagmean      : num  -0.988 -0.97 -0.963 -0.976 -0.97 ...
##  $ avgtimebodygyromagmean         : num  -0.95 -0.93 -0.907 -0.938 -0.931 ...
##  $ avgtimebodygyrojerkmagmean     : num  -0.992 -0.985 -0.965 -0.971 -0.971 ...
##  $ avgfrequencybodyaccmeanx       : num  -0.977 -0.959 -0.947 -0.969 -0.956 ...
##  $ avgfrequencybodyaccmeany       : num  -0.98 -0.939 -0.934 -0.954 -0.951 ...
##  $ avgfrequencybodyaccmeanz       : num  -0.984 -0.968 -0.946 -0.964 -0.955 ...
##  $ avgfrequencybodyaccjerkmeanx   : num  -0.986 -0.979 -0.964 -0.979 -0.969 ...
##  $ avgfrequencybodyaccjerkmeany   : num  -0.983 -0.944 -0.964 -0.968 -0.963 ...
##  $ avgfrequencybodyaccjerkmeanz   : num  -0.986 -0.975 -0.956 -0.973 -0.967 ...
##  $ avgfrequencybodygyromeanx      : num  -0.986 -0.967 -0.93 -0.954 -0.957 ...
##  $ avgfrequencybodygyromeany      : num  -0.983 -0.972 -0.935 -0.955 -0.953 ...
##  $ avgfrequencybodygyromeanz      : num  -0.963 -0.961 -0.96 -0.97 -0.946 ...
##  $ avgfrequencybodyaccmagmean     : num  -0.975 -0.939 -0.927 -0.951 -0.944 ...
##  $ avgfrequencybodyaccjerkmagmean : num  -0.985 -0.962 -0.954 -0.969 -0.962 ...
##  $ avgfrequencybodygyromagmean    : num  -0.972 -0.962 -0.919 -0.938 -0.945 ...
##  $ avgfrequencybodygyrojerkmagmean: num  -0.99 -0.984 -0.956 -0.961 -0.964 ...
##  $ avgtimebodyaccstdx             : num  -0.974 -0.954 -0.942 -0.968 -0.955 ...
##  $ avgtimebodyaccstdy             : num  -0.98 -0.942 -0.916 -0.946 -0.949 ...
##  $ avgtimebodyaccstdz             : num  -0.984 -0.963 -0.941 -0.959 -0.948 ...
##  $ avgtimegravityaccstdx          : num  -0.959 -0.921 -0.922 -0.955 -0.936 ...
##  $ avgtimegravityaccstdy          : num  -0.988 -0.97 -0.97 -0.967 -0.974 ...
##  $ avgtimegravityaccstdz          : num  -0.984 -0.976 -0.971 -0.963 -0.96 ...
##  $ avgtimebodyaccjerkstdx         : num  -0.986 -0.978 -0.965 -0.978 -0.969 ...
##  $ avgtimebodyaccjerkstdy         : num  -0.983 -0.942 -0.964 -0.967 -0.963 ...
##  $ avgtimebodyaccjerkstdz         : num  -0.988 -0.979 -0.959 -0.976 -0.971 ...
##  $ avgtimebodygyrostdx            : num  -0.988 -0.973 -0.942 -0.962 -0.966 ...
##  $ avgtimebodygyrostdy            : num  -0.982 -0.961 -0.927 -0.954 -0.954 ...
##  $ avgtimebodygyrostdz            : num  -0.96 -0.962 -0.962 -0.972 -0.95 ...
##  $ avgtimebodygyrojerkstdx        : num  -0.993 -0.975 -0.945 -0.966 -0.967 ...
##  $ avgtimebodygyrojerkstdy        : num  -0.99 -0.987 -0.962 -0.967 -0.966 ...
##  $ avgtimebodygyrojerkstdz        : num  -0.988 -0.984 -0.977 -0.984 -0.97 ...
##  $ avgtimebodyaccmagstd           : num  -0.973 -0.931 -0.915 -0.94 -0.937 ...
##  $ avgtimegravityaccmagstd        : num  -0.973 -0.931 -0.915 -0.94 -0.937 ...
##  $ avgtimebodyaccjerkmagstd       : num  -0.986 -0.961 -0.955 -0.968 -0.963 ...
##  $ avgtimebodygyromagstd          : num  -0.961 -0.947 -0.899 -0.927 -0.936 ...
##  $ avgtimebodygyrojerkmagstd      : num  -0.99 -0.983 -0.953 -0.96 -0.962 ...
##  $ avgfrequencybodyaccstdx        : num  -0.973 -0.952 -0.941 -0.968 -0.955 ...
##  $ avgfrequencybodyaccstdy        : num  -0.981 -0.946 -0.913 -0.946 -0.951 ...
##  $ avgfrequencybodyaccstdz        : num  -0.985 -0.962 -0.942 -0.96 -0.948 ...
##  $ avgfrequencybodyaccjerkstdx    : num  -0.987 -0.98 -0.969 -0.979 -0.973 ...
##  $ avgfrequencybodyaccjerkstdy    : num  -0.985 -0.944 -0.967 -0.968 -0.965 ...
##  $ avgfrequencybodyaccjerkstdz    : num  -0.989 -0.98 -0.96 -0.979 -0.973 ...
##  $ avgfrequencybodygyrostdx       : num  -0.989 -0.975 -0.946 -0.965 -0.969 ...
##  $ avgfrequencybodygyrostdy       : num  -0.982 -0.956 -0.923 -0.953 -0.955 ...
##  $ avgfrequencybodygyrostdz       : num  -0.963 -0.966 -0.966 -0.975 -0.956 ...
##  $ avgfrequencybodyaccmagstd      : num  -0.975 -0.937 -0.922 -0.944 -0.942 ...
##  $ avgfrequencybodyaccjerkmagstd  : num  -0.985 -0.958 -0.955 -0.965 -0.962 ...
##  $ avgfrequencybodygyromagstd     : num  -0.961 -0.947 -0.903 -0.934 -0.94 ...
##  $ avgfrequencybodygyrojerkmagstd : num  -0.989 -0.983 -0.952 -0.961 -0.962 ...
```

```r
summary(tidydata)
```

```
##               activity  datagroup     subjectid    avgtimebodyaccmeanx
##  laying           :30   test : 54   Min.   : 1.0   Min.   :0.2216     
##  sitting          :30   train:126   1st Qu.: 8.0   1st Qu.:0.2712     
##  standing         :30               Median :15.5   Median :0.2770     
##  walking          :30               Mean   :15.5   Mean   :0.2743     
##  walkingdownstairs:30               3rd Qu.:23.0   3rd Qu.:0.2800     
##  walkingupstairs  :30               Max.   :30.0   Max.   :0.3015     
##  avgtimebodyaccmeany avgtimebodyaccmeanz avgtimegravityaccmeanx
##  Min.   :-0.040514   Min.   :-0.15251    Min.   :-0.6800       
##  1st Qu.:-0.020022   1st Qu.:-0.11207    1st Qu.: 0.8376       
##  Median :-0.017262   Median :-0.10819    Median : 0.9208       
##  Mean   :-0.017876   Mean   :-0.10916    Mean   : 0.6975       
##  3rd Qu.:-0.014936   3rd Qu.:-0.10443    3rd Qu.: 0.9425       
##  Max.   :-0.001308   Max.   :-0.07538    Max.   : 0.9745       
##  avgtimegravityaccmeany avgtimegravityaccmeanz avgtimebodyaccjerkmeanx
##  Min.   :-0.47989       Min.   :-0.49509       Min.   :0.04269        
##  1st Qu.:-0.23319       1st Qu.:-0.11726       1st Qu.:0.07396        
##  Median :-0.12782       Median : 0.02384       Median :0.07640        
##  Mean   :-0.01621       Mean   : 0.07413       Mean   :0.07947        
##  3rd Qu.: 0.08773       3rd Qu.: 0.14946       3rd Qu.:0.08330        
##  Max.   : 0.95659       Max.   : 0.95787       Max.   :0.13019        
##  avgtimebodyaccjerkmeany avgtimebodyaccjerkmeanz avgtimebodygyromeanx
##  Min.   :-0.0386872      Min.   :-0.067458       Min.   :-0.20578    
##  1st Qu.: 0.0004664      1st Qu.:-0.010601       1st Qu.:-0.04712    
##  Median : 0.0094698      Median :-0.003861       Median :-0.02871    
##  Mean   : 0.0075652      Mean   :-0.004953       Mean   :-0.03244    
##  3rd Qu.: 0.0134008      3rd Qu.: 0.001958       3rd Qu.:-0.01676    
##  Max.   : 0.0568186      Max.   : 0.038053       Max.   : 0.19270    
##  avgtimebodygyromeany avgtimebodygyromeanz avgtimebodygyrojerkmeanx
##  Min.   :-0.20421     Min.   :-0.07245     Min.   :-0.15721        
##  1st Qu.:-0.08955     1st Qu.: 0.07475     1st Qu.:-0.10322        
##  Median :-0.07318     Median : 0.08512     Median :-0.09868        
##  Mean   :-0.07426     Mean   : 0.08744     Mean   :-0.09606        
##  3rd Qu.:-0.06113     3rd Qu.: 0.10177     3rd Qu.:-0.09110        
##  Max.   : 0.02747     Max.   : 0.17910     Max.   :-0.02209        
##  avgtimebodygyrojerkmeany avgtimebodygyrojerkmeanz avgtimebodyaccmagmean
##  Min.   :-0.07681         Min.   :-0.092500        Min.   :-0.9865      
##  1st Qu.:-0.04552         1st Qu.:-0.061725        1st Qu.:-0.9573      
##  Median :-0.04112         Median :-0.053430        Median :-0.4829      
##  Mean   :-0.04269         Mean   :-0.054802        Mean   :-0.4973      
##  3rd Qu.:-0.03842         3rd Qu.:-0.048985        3rd Qu.:-0.0919      
##  Max.   :-0.01320         Max.   :-0.006941        Max.   : 0.6446      
##  avgtimegravityaccmagmean avgtimebodyaccjerkmagmean avgtimebodygyromagmean
##  Min.   :-0.9865          Min.   :-0.9928           Min.   :-0.9807       
##  1st Qu.:-0.9573          1st Qu.:-0.9807           1st Qu.:-0.9461       
##  Median :-0.4829          Median :-0.8168           Median :-0.6551       
##  Mean   :-0.4973          Mean   :-0.6079           Mean   :-0.5652       
##  3rd Qu.:-0.0919          3rd Qu.:-0.2456           3rd Qu.:-0.2159       
##  Max.   : 0.6446          Max.   : 0.4345           Max.   : 0.4180       
##  avgtimebodygyrojerkmagmean avgfrequencybodyaccmeanx
##  Min.   :-0.99732           Min.   :-0.9952         
##  1st Qu.:-0.98515           1st Qu.:-0.9787         
##  Median :-0.86479           Median :-0.7691         
##  Mean   :-0.73637           Mean   :-0.5758         
##  3rd Qu.:-0.51186           3rd Qu.:-0.2174         
##  Max.   : 0.08758           Max.   : 0.5370         
##  avgfrequencybodyaccmeany avgfrequencybodyaccmeanz
##  Min.   :-0.98903         Min.   :-0.9895         
##  1st Qu.:-0.95361         1st Qu.:-0.9619         
##  Median :-0.59498         Median :-0.7236         
##  Mean   :-0.48873         Mean   :-0.6297         
##  3rd Qu.:-0.06341         3rd Qu.:-0.3183         
##  Max.   : 0.52419         Max.   : 0.2807         
##  avgfrequencybodyaccjerkmeanx avgfrequencybodyaccjerkmeany
##  Min.   :-0.9946              Min.   :-0.9894             
##  1st Qu.:-0.9828              1st Qu.:-0.9725             
##  Median :-0.8126              Median :-0.7817             
##  Mean   :-0.6139              Mean   :-0.5882             
##  3rd Qu.:-0.2820              3rd Qu.:-0.1963             
##  Max.   : 0.4743              Max.   : 0.2767             
##  avgfrequencybodyaccjerkmeanz avgfrequencybodygyromeanx
##  Min.   :-0.9920              Min.   :-0.9931          
##  1st Qu.:-0.9796              1st Qu.:-0.9697          
##  Median :-0.8707              Median :-0.7300          
##  Mean   :-0.7144              Mean   :-0.6367          
##  3rd Qu.:-0.4697              3rd Qu.:-0.3387          
##  Max.   : 0.1578              Max.   : 0.4750          
##  avgfrequencybodygyromeany avgfrequencybodygyromeanz
##  Min.   :-0.9940           Min.   :-0.9860          
##  1st Qu.:-0.9700           1st Qu.:-0.9624          
##  Median :-0.8141           Median :-0.7909          
##  Mean   :-0.6767           Mean   :-0.6044          
##  3rd Qu.:-0.4458           3rd Qu.:-0.2635          
##  Max.   : 0.3288           Max.   : 0.4924          
##  avgfrequencybodyaccmagmean avgfrequencybodyaccjerkmagmean
##  Min.   :-0.9868            Min.   :-0.9940               
##  1st Qu.:-0.9560            1st Qu.:-0.9770               
##  Median :-0.6703            Median :-0.7940               
##  Mean   :-0.5365            Mean   :-0.5756               
##  3rd Qu.:-0.1622            3rd Qu.:-0.1872               
##  Max.   : 0.5866            Max.   : 0.5384               
##  avgfrequencybodygyromagmean avgfrequencybodygyrojerkmagmean
##  Min.   :-0.9865             Min.   :-0.9976                
##  1st Qu.:-0.9616             1st Qu.:-0.9813                
##  Median :-0.7657             Median :-0.8779                
##  Mean   :-0.6671             Mean   :-0.7564                
##  3rd Qu.:-0.4087             3rd Qu.:-0.5831                
##  Max.   : 0.2040             Max.   : 0.1466                
##  avgtimebodyaccstdx avgtimebodyaccstdy avgtimebodyaccstdz
##  Min.   :-0.9961    Min.   :-0.99024   Min.   :-0.9877   
##  1st Qu.:-0.9799    1st Qu.:-0.94205   1st Qu.:-0.9498   
##  Median :-0.7526    Median :-0.50897   Median :-0.6518   
##  Mean   :-0.5577    Mean   :-0.46046   Mean   :-0.5756   
##  3rd Qu.:-0.1984    3rd Qu.:-0.03077   3rd Qu.:-0.2306   
##  Max.   : 0.6269    Max.   : 0.61694   Max.   : 0.6090   
##  avgtimegravityaccstdx avgtimegravityaccstdy avgtimegravityaccstdz
##  Min.   :-0.9968       Min.   :-0.9942       Min.   :-0.9910      
##  1st Qu.:-0.9825       1st Qu.:-0.9711       1st Qu.:-0.9605      
##  Median :-0.9695       Median :-0.9590       Median :-0.9450      
##  Mean   :-0.9638       Mean   :-0.9524       Mean   :-0.9364      
##  3rd Qu.:-0.9509       3rd Qu.:-0.9370       3rd Qu.:-0.9180      
##  Max.   :-0.8296       Max.   :-0.6436       Max.   :-0.6102      
##  avgtimebodyaccjerkstdx avgtimebodyaccjerkstdy avgtimebodyaccjerkstdz
##  Min.   :-0.9946        Min.   :-0.9895        Min.   :-0.99329      
##  1st Qu.:-0.9832        1st Qu.:-0.9724        1st Qu.:-0.98266      
##  Median :-0.8104        Median :-0.7756        Median :-0.88366      
##  Mean   :-0.5949        Mean   :-0.5654        Mean   :-0.73596      
##  3rd Qu.:-0.2233        3rd Qu.:-0.1483        3rd Qu.:-0.51212      
##  Max.   : 0.5443        Max.   : 0.3553        Max.   : 0.03102      
##  avgtimebodygyrostdx avgtimebodygyrostdy avgtimebodygyrostdz
##  Min.   :-0.9943     Min.   :-0.9942     Min.   :-0.9855    
##  1st Qu.:-0.9735     1st Qu.:-0.9629     1st Qu.:-0.9609    
##  Median :-0.7890     Median :-0.8017     Median :-0.8010    
##  Mean   :-0.6916     Mean   :-0.6533     Mean   :-0.6164    
##  3rd Qu.:-0.4414     3rd Qu.:-0.4196     3rd Qu.:-0.3106    
##  Max.   : 0.2677     Max.   : 0.4765     Max.   : 0.5649    
##  avgtimebodygyrojerkstdx avgtimebodygyrojerkstdy avgtimebodygyrojerkstdz
##  Min.   :-0.9965         Min.   :-0.9971         Min.   :-0.9954        
##  1st Qu.:-0.9800         1st Qu.:-0.9832         1st Qu.:-0.9848        
##  Median :-0.8396         Median :-0.8942         Median :-0.8610        
##  Mean   :-0.7036         Mean   :-0.7636         Mean   :-0.7096        
##  3rd Qu.:-0.4629         3rd Qu.:-0.5861         3rd Qu.:-0.4741        
##  Max.   : 0.1791         Max.   : 0.2959         Max.   : 0.1932        
##  avgtimebodyaccmagstd avgtimegravityaccmagstd avgtimebodyaccjerkmagstd
##  Min.   :-0.9865      Min.   :-0.9865         Min.   :-0.9946         
##  1st Qu.:-0.9430      1st Qu.:-0.9430         1st Qu.:-0.9765         
##  Median :-0.6074      Median :-0.6074         Median :-0.8014         
##  Mean   :-0.5439      Mean   :-0.5439         Mean   :-0.5842         
##  3rd Qu.:-0.2090      3rd Qu.:-0.2090         3rd Qu.:-0.2173         
##  Max.   : 0.4284      Max.   : 0.4284         Max.   : 0.4506         
##  avgtimebodygyromagstd avgtimebodygyrojerkmagstd avgfrequencybodyaccstdx
##  Min.   :-0.9814       Min.   :-0.9977           Min.   :-0.9966        
##  1st Qu.:-0.9476       1st Qu.:-0.9805           1st Qu.:-0.9820        
##  Median :-0.7420       Median :-0.8809           Median :-0.7470        
##  Mean   :-0.6304       Mean   :-0.7550           Mean   :-0.5522        
##  3rd Qu.:-0.3602       3rd Qu.:-0.5767           3rd Qu.:-0.1966        
##  Max.   : 0.3000       Max.   : 0.2502           Max.   : 0.6585        
##  avgfrequencybodyaccstdy avgfrequencybodyaccstdz
##  Min.   :-0.99068        Min.   :-0.9872        
##  1st Qu.:-0.94042        1st Qu.:-0.9459        
##  Median :-0.51338        Median :-0.6441        
##  Mean   :-0.48148        Mean   :-0.5824        
##  3rd Qu.:-0.07913        3rd Qu.:-0.2655        
##  Max.   : 0.56019        Max.   : 0.6871        
##  avgfrequencybodyaccjerkstdx avgfrequencybodyaccjerkstdy
##  Min.   :-0.9951             Min.   :-0.9905            
##  1st Qu.:-0.9847             1st Qu.:-0.9737            
##  Median :-0.8254             Median :-0.7852            
##  Mean   :-0.6121             Mean   :-0.5707            
##  3rd Qu.:-0.2475             3rd Qu.:-0.1685            
##  Max.   : 0.4768             Max.   : 0.3498            
##  avgfrequencybodyaccjerkstdz avgfrequencybodygyrostdx
##  Min.   :-0.993108           Min.   :-0.9947         
##  1st Qu.:-0.983747           1st Qu.:-0.9750         
##  Median :-0.895121           Median :-0.8086         
##  Mean   :-0.756489           Mean   :-0.7110         
##  3rd Qu.:-0.543787           3rd Qu.:-0.4813         
##  Max.   :-0.006236           Max.   : 0.1966         
##  avgfrequencybodygyrostdy avgfrequencybodygyrostdz
##  Min.   :-0.9944          Min.   :-0.9867         
##  1st Qu.:-0.9602          1st Qu.:-0.9643         
##  Median :-0.7964          Median :-0.8224         
##  Mean   :-0.6454          Mean   :-0.6577         
##  3rd Qu.:-0.4154          3rd Qu.:-0.3916         
##  Max.   : 0.6462          Max.   : 0.5225         
##  avgfrequencybodyaccmagstd avgfrequencybodyaccjerkmagstd
##  Min.   :-0.9876           Min.   :-0.9944              
##  1st Qu.:-0.9452           1st Qu.:-0.9752              
##  Median :-0.6513           Median :-0.8126              
##  Mean   :-0.6210           Mean   :-0.5992              
##  3rd Qu.:-0.3654           3rd Qu.:-0.2668              
##  Max.   : 0.1787           Max.   : 0.3163              
##  avgfrequencybodygyromagstd avgfrequencybodygyrojerkmagstd
##  Min.   :-0.9815            Min.   :-0.9976               
##  1st Qu.:-0.9488            1st Qu.:-0.9802               
##  Median :-0.7727            Median :-0.8941               
##  Mean   :-0.6723            Mean   :-0.7715               
##  3rd Qu.:-0.4277            3rd Qu.:-0.6081               
##  Max.   : 0.2367            Max.   : 0.2878
```

```r
head(tidydata,1)
```

```
##   activity datagroup subjectid avgtimebodyaccmeanx avgtimebodyaccmeany
## 1   laying      test         2           0.2813734         -0.01815874
##   avgtimebodyaccmeanz avgtimegravityaccmeanx avgtimegravityaccmeany
## 1          -0.1072456             -0.5097542              0.7525366
##   avgtimegravityaccmeanz avgtimebodyaccjerkmeanx avgtimebodyaccjerkmeany
## 1              0.6468349              0.08259725              0.01225479
##   avgtimebodyaccjerkmeanz avgtimebodygyromeanx avgtimebodygyromeany
## 1            -0.001802649          -0.01847661           -0.1118008
##   avgtimebodygyromeanz avgtimebodygyrojerkmeanx avgtimebodygyrojerkmeany
## 1            0.1448828               -0.1019741              -0.03585902
##   avgtimebodygyrojerkmeanz avgtimebodyaccmagmean avgtimegravityaccmagmean
## 1               -0.0701783            -0.9774355               -0.9774355
##   avgtimebodyaccjerkmagmean avgtimebodygyromagmean
## 1                -0.9877417             -0.9500116
##   avgtimebodygyrojerkmagmean avgfrequencybodyaccmeanx
## 1                 -0.9917671               -0.9767251
##   avgfrequencybodyaccmeany avgfrequencybodyaccmeanz
## 1               -0.9798009                -0.984381
##   avgfrequencybodyaccjerkmeanx avgfrequencybodyaccjerkmeany
## 1                   -0.9858136                   -0.9827683
##   avgfrequencybodyaccjerkmeanz avgfrequencybodygyromeanx
## 1                   -0.9861971                -0.9864311
##   avgfrequencybodygyromeany avgfrequencybodygyromeanz
## 1                -0.9833216                -0.9626719
##   avgfrequencybodyaccmagmean avgfrequencybodyaccjerkmagmean
## 1                 -0.9751102                     -0.9853741
##   avgfrequencybodygyromagmean avgfrequencybodygyrojerkmagmean
## 1                   -0.972113                      -0.9902487
##   avgtimebodyaccstdx avgtimebodyaccstdy avgtimebodyaccstdz
## 1         -0.9740595         -0.9802774         -0.9842333
##   avgtimegravityaccstdx avgtimegravityaccstdy avgtimegravityaccstdz
## 1            -0.9590144            -0.9882119            -0.9842304
##   avgtimebodyaccjerkstdx avgtimebodyaccjerkstdy avgtimebodyaccjerkstdz
## 1             -0.9858722             -0.9831725              -0.988442
##   avgtimebodygyrostdx avgtimebodygyrostdy avgtimebodygyrostdz
## 1          -0.9882752          -0.9822916          -0.9603066
##   avgtimebodygyrojerkstdx avgtimebodygyrojerkstdy avgtimebodygyrojerkstdz
## 1              -0.9932358              -0.9895675              -0.9880358
##   avgtimebodyaccmagstd avgtimegravityaccmagstd avgtimebodyaccjerkmagstd
## 1           -0.9728739              -0.9728739               -0.9855181
##   avgtimebodygyromagstd avgtimebodygyrojerkmagstd avgfrequencybodyaccstdx
## 1            -0.9611641                -0.9897181              -0.9732465
##   avgfrequencybodyaccstdy avgfrequencybodyaccstdz
## 1              -0.9810251              -0.9847922
##   avgfrequencybodyaccjerkstdx avgfrequencybodyaccjerkstdy
## 1                  -0.9872503                  -0.9849874
##   avgfrequencybodyaccjerkstdz avgfrequencybodygyrostdx
## 1                  -0.9893454               -0.9888607
##   avgfrequencybodygyrostdy avgfrequencybodygyrostdz
## 1               -0.9819106               -0.9631742
##   avgfrequencybodyaccmagstd avgfrequencybodyaccjerkmagstd
## 1                -0.9751214                    -0.9845685
##   avgfrequencybodygyromagstd avgfrequencybodygyrojerkmagstd
## 1                 -0.9610984                     -0.9894927
```
  
  
  
# Sources

Raw Data: https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip

Description about the study: http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones

R Code used for analysis : [run_analysis.R](https://github.com/snrajesh/GettingAndCleaningData_Project/blob/master/run_analysis.R)



