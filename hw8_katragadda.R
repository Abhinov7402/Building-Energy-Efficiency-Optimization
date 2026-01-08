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


energy_data <- read.csv("C:/Users/saiab/Desktop/IDA_ASSIGNMENTS/hw_8/ENB2012_data.csv", encoding = "UTF-8")

head(energy_data)
# Load dataset (replace 'your_dataset' with the actual dataset)
# Assume data is stored in a dataframe called 'data' and targets (Y1, Y2) are excluded for clustering
data <- energy_data[, 1:8]
head(data)

# Standardize data
data_scaled <- scale(data)

# 1. K-means Clustering
# Determine the optimal number of clusters using the Elbow method
fviz_nbclust(data_scaled, kmeans, method = "wss") + ggtitle("Optimal Clusters (K-means)")

# Apply k-means with optimal k (e.g., k = 4)
set.seed(123)  # For reproducibility
kmeans_result <- kmeans(data_scaled, centers = 4, nstart = 25)

# Add cluster labels to the dataset
data_scaled$cluster <- as.factor(kmeans_result$cluster)

#install.packages("Rtsne")
library(Rtsne)

# Perform t-SNE
set.seed(123)
tsne_result <- Rtsne(data_scaled[, continuous_features], dims = 2, perplexity = 30, verbose = TRUE, max_iter = 500)

# Create a data frame for plotting
tsne_df <- data.frame(tsne_result$Y, cluster = data_scaled$cluster)

# Visualize clusters
ggplot(tsne_df, aes(x = X1, y = X2, color = cluster)) +
  geom_point(size = 2, alpha = 0.7) +
  theme_minimal() +
  labs(title = "Clusters Visualization with t-SNE", x = "t-SNE 1", y = "t-SNE 2")










# 2. K-medoids Clustering
# Determine optimal k for k-medoids using silhouette analysis
fviz_nbclust(data_scaled, pam, method = "silhouette") + ggtitle("Optimal Clusters (K-medoids)")

# Apply k-medoids with optimal k (e.g., k = 4)
kmedoids_result <- pam(data_scaled, k = 4)














# 3. DBSCAN Clustering
# Determine optimal eps for DBSCAN using kNN distance plot
kNNdistplot(data_scaled, k = 5)
abline(h = 0.5, col = "red")  # Set appropriate threshold (e.g., 0.5)

# Apply DBSCAN
dbscan_result <- dbscan(data_scaled, eps = 0.5, minPts = 5)



















# Visualize clusters for each method
fviz_cluster(kmeans_result, data = data_scaled) + ggtitle("K-means Clustering")
fviz_cluster(kmedoids_result, data = data_scaled) + ggtitle("K-medoids Clustering")
fviz_cluster(list(data = data_scaled, cluster = dbscan_result$cluster), geom = "point") +
  ggtitle("DBSCAN Clustering")

# Compare clustering results
# Cluster sizes
kmeans_sizes <- table(kmeans_result$cluster)
kmedoids_sizes <- table(kmedoids_result$clustering)
dbscan_sizes <- table(dbscan_result$cluster)

# SSE (sum of squared errors) for K-means
kmeans_sse <- kmeans_result$tot.withinss

# Silhouette scores for k-medoids
kmedoids_silhouette <- silhouette(kmedoids_result$clustering, dist(data_scaled))
mean_silhouette_kmedoids <- mean(kmedoids_silhouette[, 3])

# Interpretation of one clustering result (e.g., K-means)
# Add cluster labels to the original dataset for interpretation
data_with_clusters <- cbind(data, Cluster = kmeans_result$cluster)

# Calculate summary statistics for each cluster
cluster_summary <- aggregate(. ~ Cluster, data = data_with_clusters, FUN = mean)

# Print results
print(cluster_summary)
