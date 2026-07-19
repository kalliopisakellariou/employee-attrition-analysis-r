#############################################################################################
# IBM HR Employee Attrition Analysis
#
#Author: Καλλιόπη Σακελλαρίου
# Language: R
#
# Description:
# This project analyzes employee attrition using
#hierarchical clustering, K-means clustering and decision tree classification.
#############################################################################################

library(NbClust)      
library(rpart)
library(rpart.plot)

#############################################################################################
# Load dataset 
#############################################################################################
data<-read.csv("WA_Fn-UseC_-HR-Employee-Attrition.csv", header=TRUE)

#############################################################################################
# Data inspection 
#############################################################################################

table(complete.cases(data))

#############################################################################################
#Data Preprocessing 
#############################################################################################

data2<- data [ , !(names(data) %in% c("EmployeeCount", "EmployeeNumber", "StandardHours"))]        
num.data<- data2[ , sapply(data2, is.numeric)]

#############################################################################################
# Data normalization
#############################################################################################

pmatrix <- scale(num.data)  

#############################################################################################
#Distance matrix 
#############################################################################################
distance_matrix<- dist(pmatrix)       

#############################################################################################
# Hierarchical Clustering
#############################################################################################
hc_model<- hclust(distance_matrix, method= "complete")  

#############################################################################################
# Determine the optimal number of clusters 
#############################################################################################
nbclust_result<- NbClust(pmatrix, min.nc=2, max.nc=10, method="complete")  

#############################################################################################
# Cluster assignment 
#############################################################################################
clusters<- cutree(hc_model, k=2)

#############################################################################################
# Visualize Dendrogramm
#############################################################################################
plot(hc_model, labels=FALSE, main= "Hierarchical CLustering Dendrogram", xlab="", sub="")
rect.hclust(hc_model, k=2, border="Red")
table(clusters)
data$Cluster<- as.factor(clusters)

#############################################################################################
# Cluster profiling
#############################################################################################
aggregate(. ~Cluster, data= data[, c(names(num.data), "Cluster")], mean)

#############################################################################################
# Attrition Analysis- Compare clusters with employee Attrition 
#############################################################################################
table(data$Cluster, data$Attrition)

#############################################################################################
# K-means Clustering 
#############################################################################################

set.seed(123)    
kmeans_model<- kmeans( pmatrix, centers=2, nstart=25)    
table(kmeans_model$cluster)

# Compare cluster membership with employee Attrition
table(kmeans_model$cluster, data$Attrition)
aggregate(num.data, by=list(cluster=kmeans_model$cluster), mean)

#############################################################################################
# Train/Test split 
#############################################################################################
set.seed(123)
train_index<- sample(1:nrow(data2), 0.8*nrow(data2))
train_data<- data2[train_index,]
test_data<-data2[-train_index,]

#############################################################################################
# Decision Tree Classification
#############################################################################################

tree_model<- rpart(Attrition~ ., data=train_data, method="class", control= rpart.control(cp=0.001, minsplit=20))
rpart.plot(tree_model, type=2, extra=104, fallen.leaves=TRUE)

#############################################################################################
# Model Prediction 
#############################################################################################
predictions<- predict (tree_model, test_data, type= "class")

#############################################################################################
# Model Evaluation- Confusion Matrix and Accurance 
#############################################################################################
table(Predicted=predictions, Actual=test_data$Attrition)
mean(predictions== test_data$Attrition)

