---
title: "Getting and Cleaning Data: Course Project"
author: "Rajesh Nambiar"
date: "October 23, 2015"
---

## Project Description:

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis


## Data: 

The data used for this from the course project is available  [here](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) as well as in Github.

A full description is available at [this site](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones) where the data was obtained

**The dataset includes the following files**:

- 'features.txt': List of all features.
- 'activity_labels.txt': Links the class labels with their activity name.
- 'train/X_train.txt': Training set.
- 'train/y_train.txt': Training labels.
- 'train/subject_train.txt': the subject who performed the activity.
- 'test/X_test.txt': Test set.
- 'test/y_test.txt': Test labels.
- 'test/subject_test.txt': the subject who performed the activity.

## Data Processing:

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


##Results

###Final summarized Data:

The summarized tidy data (from tidyDataSummary table) is written out to **tidydata.txt** file. The format used is the default **write.table** format in R, which can be easily read back to R by anyone using the deafult **read.table** option with header=TRUE.

***Note***:  
This tidy data is in the wide format, as tidy data can be either in wide or long format. The wording in the rubric also suggest that either wide or long format is acceptable. The goal is to have each variable you measure in one column, each different observation of that variable in a different row. In this case, the wide format satisy these condistions.

###Code BooK:

The details steps, the transformation rules applied, the corresponsidng R codes, and variables can be found in CodeBook.md ([GitHub Link](https://github.com/snrajesh/GettingAndCleaningData_Project/blob/master/CodeBook.md)).

###Data for Review:

The final summarized data is attached as tidydata.txt ([GitHub Link](https://github.com/snrajesh/GettingAndCleaningData_Project/blob/master/tidydata.txt)).

This can read into a R using the below code:

tidydata <- read.table('tidydata.txt', header = TRUE);   
View(tidydata)


###Code: 

The R code used for this is in run_analysis.R ([GitHub Link](https://github.com/snrajesh/GettingAndCleaningData_Project/blob/master/run_analysis.R)).

***Note***:  
Please note that the script has code to download the file to your current directory. If yo don't wish to download the file, please comment out the download command (in step 0,line 48-50).
The script also has command to read the output file back into R. If you wish not to do this, comment out read.table at command at the end (step 7, line 326)

The toal execution time for the whole script (including download) is about *90 seconds*.



