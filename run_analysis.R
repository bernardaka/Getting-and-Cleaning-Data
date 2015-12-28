library(data.table)
library(reshape2)

#1.Merges the training and the test sets to create one data set.
X_train <-read.table("data/UCI HAR Dataset/train/X_train.txt")
X_test <-read.table("data/UCI HAR Dataset/test/X_test.txt")

subject_train <-read.table("data/UCI HAR Dataset/train/subject_train.txt")
subject_test <-read.table("data/UCI HAR Dataset/test/subject_test.txt")

y_train <-read.table("data/UCI HAR Dataset/train/y_train.txt")
y_test <-read.table("data/UCI HAR Dataset/test/y_test.txt")

#load data column names
features <- read.table("data/UCI HAR Dataset/features.txt")[,2]

#2.Extract only the measurements on the mean and standard deviation for 
# each measurement.
extract_features <- grepl("mean|std", features)

names(X_test) = features
names(X_train) =features

X_test = X_test[,extract_features]
X_train = X_train[,extract_features]

#3.Uses descriptive activity names to name the activities in the data set
#load activity lables
activity_labels <- read.table("data/UCI HAR Dataset/activity_labels.txt")[,2]

#4.Appropriately labels the data set with descriptive variable names. 
y_test[,2] = activity_labels[y_test[,1]]
names(y_test) = c("Activity_ID", "Activity_Label")
names(subject_test) = "subject"

y_train[,2] = activity_labels[y_train[,1]]
names(y_train) = c("Activity_ID", "Activity_Label")
names(subject_train) = "subject"

#bind data
test_data <- cbind(as.data.table(subject_test), y_test, X_test)
train_data <- cbind(as.data.table(subject_train), y_train, X_train)

#5.From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.

# Merge test and train data
data = rbind(test_data, train_data)

id_labels = c("subject", "Activity_ID", "Activity_Label")
data_labels = setdiff(colnames(data), id_labels)
melt_data = melt(data, id = id_labels, measure.vars = data_labels)

# apply mean function to dataset using dcast function
tidy_data   = dcast(melt_data, subject + Activity_Label ~ variable, mean)

write.table(tidy_data, file = "data/tidy_data.txt")

