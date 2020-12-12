library(reshape2)


#Get data
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"

if (!file.exists("./data")) {
  dir.create("./data")
  download.file(url, destfile = './data/raw_data.zip')
  unzip(zipfile = './data/raw_data.zip', exdir = './data')
}



# Read all data
x_train <- read.table("./data/UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./data/UCI HAR Dataset/train/Y_train.txt")
s_train <- read.table("./data/UCI HAR Dataset/train/subject_train.txt")

x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/Y_test.txt")
s_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

features <- read.table("./data/UCI HAR Dataset/features.txt")
activity_labels <- read.table("./data/UCI HAR Dataset/activity_labels.txt")
activity_labels[, 2] <- as.character(activity_labels[, 2])



# Merge data
x_data <- rbind(x_train, x_test)
y_data <- rbind(y_train, y_test)
s_data <- rbind(s_train, s_test)



# Extract mean and SD cols
selected_cols <- grep("-(mean|std).*", as.character(features[, 2]))
selected_colnames <- features[selected_cols, 2]
selected_colnames <- gsub("-mean", "Mean", selected_colnames)
selected_colnames <- gsub("-std", "Std", selected_colnames)
selected_colnames <- gsub("[-()]", "", selected_colnames)




# Use descriptive names
x_data <- x_data[selected_cols]
all_data <- cbind(s_data, y_data, x_data)
colnames(all_data) <- c("Subject", "Activity", selected_colnames)

all_data$Activity <- factor(all_data$Activity, levels = activity_labels[, 1], labels = activity_labels[, 2])
all_data$Subject <- as.factor(all_data$Subject)



# Generate a tidy dataset
melted_data <- melt(all_data, id = c("Subject", "Activity"))
tidy_data <- dcast(melted_data, Subject + Activity ~ variable, mean)

write.table(tidy_data, "./tidy_dataset.txt", row.names = FALSE, quote = FALSE)

