# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

if(!library(reshape2, logical.return = TRUE)) {
    install.packages('reshape2')
    library(reshape2)
}


targetFolder <- 'UCI HAR Dataset'
filename <- 'getdata_dataset.zip'


if(!file.exists(targetFolder)) {
    if(!file.exists(filename)) {
        download.file(
            'https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip',
            filename
        )
    }
    
    #unzip the file
    unzip(filename)
}

# 1. Merges the training and the test sets to create one data set.
test.data <- read.table(file.path(targetFolder, 'test', 'X_test.txt'))
test.activities <- read.table(file.path(targetFolder, 'test', 'y_test.txt'))
test.subjects <- read.table(file.path(targetFolder, 'test', 'subject_test.txt'))

train.data <- read.table(file.path(targetFolder, 'train', 'X_train.txt'))
train.activities <- read.table(file.path(targetFolder, 'train', 'y_train.txt'))
train.subjects <- read.table(file.path(targetFolder, 'train', 'subject_train.txt'))

data.data <- rbind(train.data, test.data)
data.activities <- rbind(train.activities, test.activities)
data.subjects <- rbind(train.subjects, test.subjects)

full_data <- cbind(data.subjects, data.activities, data.data)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
features <- read.table(file.path(targetFolder, 'features.txt'))

requiredFeatures <- features[grep('-(mean|std)\\(\\)', features[, 2 ]), 2]
full_data <- full_data[, c(1, 2, requiredFeatures)]

# 3. Uses descriptive activity names to name the activities in the data set
activities <- read.table(file.path(targetFolder, 'activity_labels.txt'))

full_data[, 2] <- activities[full_data[,2], 2]

# 4. Appropriately labels the data set with descriptive variable names. 
colnames(full_data) <- c(
    'subject',
    'activity',
    # Remove the brackets from the features columns
    gsub('\\-|\\(|\\)', '', as.character(requiredFeatures))
)

full_data[, 2] <- as.character(full_data[, 2])

# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

final <- melt(full_data, id = c('subject', 'activity'))

final.mean <- dcast(final, subject + activity ~ variable, mean)

write.table(final.mean, file=file.path("tidy.txt"), row.names = FALSE, quote = FALSE)
