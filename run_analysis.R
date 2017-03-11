# download the data
if(!file.exists("./data")){dir.create("./data")}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="./data/file.zip",method="curl")
#unzip the data
unzip("./data/file.zip",exdir="./")

#gettng a list of files in extracted folder
path<-file.path("./","UCI HAR Dataset")
myfiles<-list.files(path,recursive=TRUE)

# Reading the desired data sets
Activitytest  <- read.table(file.path(path, "test" , "Y_test.txt" ),header = FALSE)
Activitytrain <- read.table(file.path(path, "train", "Y_train.txt"),header = FALSE)
Subjecttrain <- read.table(file.path(path, "train", "subject_train.txt"),header = FALSE)
Subjecttest  <- read.table(file.path(path, "test" , "subject_test.txt"),header = FALSE)
Featurestest  <- read.table(file.path(path, "test" , "X_test.txt" ),header = FALSE)
Featurestrain <- read.table(file.path(path, "train", "X_train.txt"),header = FALSE)

# Merging the training and test data sets
datasubject<-rbind(Subjecttrain,Subjecttest)
dataactivity<-rbind(Activitytest,Activitytrain)
datafeatures<-rbind(Featurestest,Featurestrain)

#naming the variables
names(datasubject)<-c("subject")
names(dataactivity)<-c("activity")
featurenames<-read.table(file.path(path,"features.txt"),head=FALSE)
names(datafeatures)<-featurenames$V2

#Merge the columns to get the data frame
binddata<-cbind(datasubject,dataactivity)
Data<-cbind(datafeatures,binddata)

#taking only mean and std
statdata<-featurenames$V2[grep("mean\\(\\)|std\\(\\)",featurenames$V2)]
selectednames<-c(as.character(statdata),"subject","activity")
Data<-subset(Data,select=selectednames)

# descriptive lables
activitylabels<-read.table(file.path(path,"activity_labels.txt"))
Data$activity <- factor(Data$activity, levels = activitylabels$V1, labels = activitylabels$V2)


#giving better names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

# creating tidy data set
library(dplyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)



