library(dplyr)

# helper function to create linux like path
path <- function(...) {
    paste(..., sep = "/")
}

# download archive
zip_file <- "archive.zip"
if (!file.exists(zip_file)){
    zip_url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(zip_url, zip_file, method="curl")
}  

data_folder <- "UCI HAR Dataset"

if (!file.exists(data_folder)) { 
    unzip(zip_file) 
}

# read features.txt and clean names
features <- tbl_df(read.csv(path(data_folder, "features.txt"), 
                            sep = " ", header = FALSE, 
                            col.names = c("id", "name")))
features$name <- gsub("[\\(|\\)]","",features$name)
features$name <- gsub("[-|,]",".",features$name)
features$name <- tolower(features$name)
# add boolean columns for mean/std
features$ismean <- grepl("mean",features$name)
features$isstd <- grepl("std",features$name)

# function to merge dimenstions with facts
ds <- function(src_name) {
    print(paste("Creating", src_name, "dataset..."))
    # activity codes
    activities <- read.table(path(data_folder, src_name, paste0("y_", src_name, ".txt")), 
                             header = FALSE, sep = "", col.names = c("activity_id"))
    # measurements
    x <- tbl_df(read.table(path(data_folder, src_name, paste0("X_", src_name, ".txt")), 
                           header = FALSE, sep = "",
                           col.names = features$name))
    
    # subjects
    subj <- read.table(path(data_folder, src_name, paste0("subject_", src_name,".txt")),
                       col.names = "subj_id")
    
    # add all together
    
    dataset <- mutate(cbind(activities, subj, x), src = src_name)
    
    # clean variables
    subj <- NULL
    activities <- NULL
    x <- NULL
    
    dataset
}

# Merges the training and the test sets to create one data set
df <- union(ds("test"), ds("train"))
print("Merges the training and the test sets to create one data set is done.")

# Extracts only the measurements on the mean and standard deviation for each measurement. 
col_names <- filter(features, !ismean & !isstd) %>% select(name)
df <- select(df, -one_of(as.character(col_names$name)))
print("Extracts measurements on the mean and standard deviation is done.")

# Uses descriptive activity names to name the activities in the data set
# read activity_labels.txt
activity_labels <- read.csv(path(data_folder, "activity_labels.txt"), header = FALSE, sep = " ",
                            col.names = c("activity_id", "activity_label"))
df <- left_join(df, activity_labels, by = "activity_id")
print("Uses descriptive activity names to name the activities in the data set is done.")


# Appropriately labels the data set with descriptive variable names.
print("Appropriately labels the data set with descriptive variable names id done at the beginning")

# Average of each variable for each activity and each subject.
mean_cols <- filter(features, ismean | isstd) %>% select(name)
df_avg <- df %>% group_by(subj_id, activity_label) %>% summarise_at(as.character(mean_cols$name), mean, na.rm = TRUE)

print("Average of each variable for each activity and each subject is done")

# write the result to csv file
if(!file.exists("data")) {
    dir.create("data")
}
write.csv(df_avg, path("data", "avg_per_subj_per_act.csv"), row.names = FALSE)

print("Result has been written to avg_per_subj_per_act.csv file.")

print("Cleaning...")
unlink(data_folder, recursive = TRUE)
unlink(zip_file)




