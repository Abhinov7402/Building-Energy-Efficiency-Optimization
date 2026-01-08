# Load required libraries
library(tidyverse)  #to support numerous data wrangling and file ingestion functionality
library(knitr)      #to support the "kable" command to generate a nice looking table
library(dplyr)
library(lattice)
library(caret)



library(cluster)    # For k-medoids
library(factoextra) # For visualizations
library(dbscan)     # For DBSCAN
library(ggplot2)    # For plotting


df <- read.csv("C:/Users/saiab/Desktop/IDA_ASSIGNMENTS/hw_8/ENB2012_data.csv", encoding = "UTF-8")


# Scale continuous features
continuous_features <- c("X1", "X2", "X3", "X4", "X5", "X7","X8" ,"Y1", "Y2")
df_scaled <- df
df_scaled[continuous_features] <- scale(df[continuous_features])

# Determine the optimal number of clusters using the Elbow method
fviz_nbclust(df_scaled, kmeans, method = "wss") + ggtitle("Optimal Clusters (K-means)")


######################################################################

# Perform PCA
pca_result <- prcomp(df_scaled[, continuous_features], center = TRUE, scale. = TRUE)

# Summary of PCA
summary(pca_result)  # Proportion of variance explained

# Plot variance explained by each principal component
library(ggplot2)

pca_variance <- data.frame(PC = paste0("PC", 1:length(pca_result$sdev)),
                           Variance = (pca_result$sdev)^2 / sum(pca_result$sdev^2))

ggplot(pca_variance, aes(x = PC, y = Variance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  theme_minimal() +
  labs(title = "Variance Explained by Principal Components",
       x = "Principal Component", y = "Proportion of Variance")

# Get the PCA scores
pca_scores <- as.data.frame(pca_result$x)


###############################
#  K Means


# Add cluster labels from k-means
set.seed(123)
kmeans_result <- kmeans(df_scaled[, continuous_features], centers = 3, nstart = 25)
pca_scores$cluster <- as.factor(kmeans_result$cluster)


# PCA Cluster Visualization
ggplot(pca_scores, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(size = 2, alpha = 0.7) +
  theme_minimal() +
  labs(title = "PCA Cluster Visualization",
       x = "Principal Component 1", y = "Principal Component 2",
       color = "Cluster")


# PCA Loadings
pca_loadings <- as.data.frame(pca_result$rotation)
pca_loadings$Feature <- rownames(pca_loadings)

# Plot Loadings for PC1 and PC2
ggplot(pca_loadings, aes(x = PC1, y = PC2, label = Feature)) +
  geom_point(color = "red", size = 3) +
  geom_text(vjust = 1.5) +
  theme_minimal() +
  labs(title = "PCA Loadings for PC1 and PC2",
       x = "PC1 Loadings", y = "PC2 Loadings")


# Heating Load by Cluster
ggplot(pca_scores, aes(x = cluster, y = df_scaled$Y1, fill = cluster)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Heating Load (Y1) Across Clusters",
       y = "Heating Load (Y1)", x = "Cluster")

# Cooling Load by Cluster
ggplot(pca_scores, aes(x = cluster, y = df_scaled$Y2, fill = cluster)) +
  geom_boxplot() +
  theme_minimal() +
  labs(title = "Cooling Load (Y2) Across Clusters",
       y = "Cooling Load (Y2)", x = "Cluster")



#####################################################
#   K Medoids
# Load required libraries
library(cluster)       # For k-medoids clustering
library(ggplot2)       # For visualization
library(factoextra)    # For PCA visualization and cluster analysis
library(dplyr)         # For data manipulation


# Extract PCA scores
pca_scores <- as.data.frame(pca_result$x)

# Perform k-medoids clustering on PCA scores (select first 2 components for simplicity)
set.seed(123)  # For reproducibility
pca_kmedoids <- pam(pca_scores[, 1:2], k = 3)  # Change k if needed

# Add cluster assignments to the PCA scores
pca_scores$cluster <- as.factor(pca_kmedoids$clustering)

# Visualize PCA with clusters
ggplot(pca_scores, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(size = 2, alpha = 0.7) +
  theme_minimal() +
  labs(title = "PCA with k-Medoids Clustering",
       x = "Principal Component 1",
       y = "Principal Component 2",
       color = "Cluster")


##########################################################################3
#               DB SCAN
#



# Extract PCA scores
pca_scores <- as.data.frame(pca_result$x)

# Perform DBSCAN clustering on the first two principal components
# Set eps (neighborhood size) and minPts (minimum points for a cluster) based on domain knowledge
dbscan_result <- dbscan(pca_scores[, 1:2], eps = 1, minPts = 5)

# Add cluster assignments to the PCA scores
pca_scores$cluster <- as.factor(ifelse(dbscan_result$cluster == 0, "Noise", dbscan_result$cluster))

# Visualize PCA with clusters (including noise)
ggplot(pca_scores, aes(x = PC1, y = PC2, color = cluster)) +
  geom_point(size = 2, alpha = 0.7) +
  theme_minimal() +
  labs(title = "PCA with DBSCAN Clustering",
       x = "Principal Component 1",
       y = "Principal Component 2",
       color = "Cluster") +
  scale_color_manual(values = c("Noise" = "black", "1" = "red", "2" = "blue", "3" = "green"))  # Customize colors

table(dbscan_result$cluster)






