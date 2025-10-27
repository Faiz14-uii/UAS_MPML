# ============================================================================
# ANALISIS CLUSTER MULTIVARIAT
# ============================================================================
#
# Tujuan: Mengelompokkan observasi berdasarkan kesamaan karakteristik
#
# Kapan digunakan:
# - Ingin mengidentifikasi kelompok natural dalam data
# - Segmentasi pelanggan, klasifikasi objek
# - Eksplorasi struktur data
#
# Metode yang dibahas:
# 1. Hierarchical Clustering (Agglomerative)
# 2. K-Means Clustering
# 3. Validasi cluster
#
# ============================================================================

# SETUP
# ============================================================================

# Install packages (jika belum)
# install.packages(c("cluster", "factoextra", "dendextend", "NbClust", "tidyverse"))

library(cluster)      # Untuk clustering
library(factoextra)   # Untuk visualisasi
library(dendextend)   # Untuk dendrogram
library(NbClust)      # Untuk menentukan jumlah cluster optimal
library(tidyverse)    # Manipulasi data

set.seed(42)

# ============================================================================
# LANGKAH 1: PERSIAPAN DATA
# ============================================================================

cat("\n=== LANGKAH 1: PERSIAPAN DATA ===\n")

# Gunakan dataset USArrests
data("USArrests")
df <- USArrests

cat("\nStruktur data:\n")
str(df)

cat("\nStatistik deskriptif:\n")
summary(df)

# Tampilkan beberapa baris
cat("\nSample data:\n")
print(head(df))

# ============================================================================
# LANGKAH 2: PREPROCESSING - STANDARDISASI
# ============================================================================

cat("\n=== LANGKAH 2: STANDARDISASI DATA ===\n")

# PENTING: Standardisasi data sebelum clustering
# Karena variabel memiliki skala yang berbeda (%, per 100k)
# Tanpa standardisasi, variabel dengan range besar akan mendominasi

df_scaled <- scale(df)

cat("\nData setelah standardisasi (mean=0, sd=1):\n")
cat("Mean per variabel:\n")
print(colMeans(df_scaled))
cat("\nStd dev per variabel:\n")
print(apply(df_scaled, 2, sd))

# Tampilkan contoh
cat("\nSample data terstandarisasi:\n")
print(head(df_scaled))

# ============================================================================
# LANGKAH 3: EKSPLORASI - JARAK ANTAR OBSERVASI
# ============================================================================

cat("\n=== LANGKAH 3: MATRIKS JARAK ===\n")

# Hitung matriks jarak Euclidean
dist_matrix <- dist(df_scaled, method = "euclidean")

# Tampilkan sebagian matriks jarak
cat("\nContoh jarak antar negara bagian (partial):\n")
print(as.matrix(dist_matrix)[1:5, 1:5])

# Metode jarak lain yang umum:
# - "euclidean": √(Σ(x-y)²) - paling umum
# - "manhattan": Σ|x-y| - robust terhadap outlier
# - "maximum": max|x-y| - Chebyshev distance

# ============================================================================
# METODE 1: HIERARCHICAL CLUSTERING
# ============================================================================

cat("\n" + rep("=", 70) + "\n")
cat("METODE 1: HIERARCHICAL CLUSTERING\n")
cat(rep("=", 70) + "\n")

# Linkage methods:
# - "complete": Maximum distance (konservatif, cluster compact)
# - "single": Minimum distance (sensitif outlier, rantai panjang)
# - "average": Average distance (kompromi)
# - "ward.D2": Minimasi within-cluster variance (populer, cluster seimbang)

# Coba beberapa metode linkage
hc_complete <- hclust(dist_matrix, method = "complete")
hc_average <- hclust(dist_matrix, method = "average")
hc_ward <- hclust(dist_matrix, method = "ward.D2")

# Visualisasi dendrogram
cat("\nMembuat dendrogram...\n")

par(mfrow = c(2, 2))
plot(hc_complete, main = "Complete Linkage", xlab = "", sub = "")
plot(hc_average, main = "Average Linkage", xlab = "", sub = "")
plot(hc_ward, main = "Ward's Method", xlab = "", sub = "")
par(mfrow = c(1, 1))

# Fokus pada Ward's method (umumnya terbaik)
cat("\nMenggunakan Ward's method untuk analisis lanjutan...\n")

# Dendrogram yang lebih baik dengan factoextra
fviz_dend(hc_ward, k = 4,
          cex = 0.5,
          k_colors = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
          color_labels_by_k = TRUE,
          rect = TRUE,
          main = "Dendrogram - Ward's Method")

# ============================================================================
# LANGKAH 4: MENENTUKAN JUMLAH CLUSTER OPTIMAL
# ============================================================================

cat("\n=== LANGKAH 4: MENENTUKAN JUMLAH CLUSTER OPTIMAL ===\n")

# METODE 1: Elbow Method (Within-cluster sum of squares)
cat("\n1. Elbow Method:\n")
fviz_nbclust(df_scaled, kmeans, method = "wss") +
  geom_vline(xintercept = 4, linetype = 2) +
  labs(title = "Elbow Method",
       subtitle = "Cari 'siku' pada grafik")

# METODE 2: Silhouette Method
cat("\n2. Silhouette Method:\n")
fviz_nbclust(df_scaled, kmeans, method = "silhouette") +
  labs(title = "Silhouette Method",
       subtitle = "Pilih k dengan nilai tertinggi")

# METODE 3: Gap Statistic
cat("\n3. Gap Statistic (mungkin butuh waktu):\n")
gap_stat <- clusGap(df_scaled, 
                    FUN = kmeans, 
                    nstart = 25,
                    K.max = 10, 
                    B = 50)
fviz_gap_stat(gap_stat) +
  labs(title = "Gap Statistic Method")

# METODE 4: NbClust - 30 indeks sekaligus!
cat("\n4. NbClust - Konsensus dari 30 indeks:\n")
nb_result <- NbClust(df_scaled, 
                     distance = "euclidean",
                     min.nc = 2, 
                     max.nc = 10,
                     method = "ward.D2",
                     index = "all")

cat("\nKesimpulan dari berbagai metode:\n")
cat("Mayoritas indeks menyarankan:", names(which.max(table(nb_result$Best.nc[1,]))), "cluster\n")

# Berdasarkan hasil, kita pilih k = 4
optimal_k <- 4
cat("\n✓ Keputusan: Gunakan", optimal_k, "cluster\n")

# ============================================================================
# LANGKAH 5: POTONG DENDROGRAM - HIERARCHICAL
# ============================================================================

cat("\n=== LANGKAH 5: CUTTING DENDROGRAM ===\n")

# Potong dendrogram untuk mendapatkan cluster
clusters_hc <- cutree(hc_ward, k = optimal_k)

cat("\nJumlah observasi per cluster:\n")
print(table(clusters_hc))

# Tambahkan label cluster ke data
df_with_cluster_hc <- df %>%
  mutate(Cluster = as.factor(clusters_hc),
         State = rownames(df))

# Tampilkan beberapa negara bagian per cluster
cat("\nContoh negara bagian per cluster:\n")
for (i in 1:optimal_k) {
  cat("\nCluster", i, ":\n")
  states <- df_with_cluster_hc %>% 
    filter(Cluster == i) %>% 
    pull(State)
  cat(paste(head(states, 5), collapse = ", "), "\n")
}

# ============================================================================
# METODE 2: K-MEANS CLUSTERING
# ============================================================================

cat("\n" + rep("=", 70) + "\n")
cat("METODE 2: K-MEANS CLUSTERING\n")
cat(rep("=", 70) + "\n")

# K-means dengan k = 4
# nstart = 25: Coba 25 konfigurasi awal, pilih yang terbaik
kmeans_result <- kmeans(df_scaled, 
                        centers = optimal_k,
                        nstart = 25)

cat("\nHasil K-Means:\n")
print(kmeans_result)

# Cluster centers (centroid)
cat("\nPusat cluster (terstandarisasi):\n")
print(kmeans_result$centers)

# Konversi kembali ke skala original untuk interpretasi
centers_original <- kmeans_result$centers %*% 
  diag(attr(df_scaled, "scaled:scale")) +
  matrix(attr(df_scaled, "scaled:center"), 
         nrow = optimal_k, 
         ncol = ncol(df_scaled), 
         byrow = TRUE)

cat("\nPusat cluster (skala original):\n")
print(round(centers_original, 2))

# Within-cluster sum of squares
cat("\nWithin-cluster SS by cluster:\n")
print(kmeans_result$withinss)
cat("\nTotal within-cluster SS:", kmeans_result$tot.withinss, "\n")
cat("Between-cluster SS:", kmeans_result$betweenss, "\n")
cat("Ratio between_SS / total_SS:", 
    round(kmeans_result$betweenss / kmeans_result$totss * 100, 2), "%\n")

# Tambahkan ke data
df_with_cluster_km <- df %>%
  mutate(Cluster = as.factor(kmeans_result$cluster),
         State = rownames(df))

# ============================================================================
# LANGKAH 6: VISUALISASI CLUSTER
# ============================================================================

cat("\n=== LANGKAH 6: VISUALISASI CLUSTER ===\n")

# Visualisasi K-Means
cat("\nVisualisasi K-Means clustering...\n")
fviz_cluster(kmeans_result, 
             data = df_scaled,
             palette = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
             ellipse.type = "convex",
             star.plot = TRUE,
             repel = TRUE,
             ggtheme = theme_minimal(),
             main = "K-Means Clustering - 4 Clusters")

# Visualisasi Hierarchical
cat("\nVisualisasi Hierarchical clustering...\n")
fviz_cluster(list(data = df_scaled, cluster = clusters_hc),
             palette = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
             ellipse.type = "convex",
             repel = TRUE,
             ggtheme = theme_minimal(),
             main = "Hierarchical Clustering - 4 Clusters")

# ============================================================================
# LANGKAH 7: PROFILING CLUSTER
# ============================================================================

cat("\n=== LANGKAH 7: PROFILING CLUSTER ===\n")

# Statistik per cluster (K-Means)
cat("\nProfil Cluster (K-Means):\n")
cluster_profile <- df_with_cluster_km %>%
  group_by(Cluster) %>%
  summarise(
    N = n(),
    Murder_avg = mean(Murder),
    Assault_avg = mean(Assault),
    UrbanPop_avg = mean(UrbanPop),
    Rape_avg = mean(Rape)
  )

print(cluster_profile)

# Visualisasi profil cluster
cat("\nVisualisasi profil cluster...\n")
cluster_profile_long <- cluster_profile %>%
  select(-N) %>%
  pivot_longer(cols = -Cluster, names_to = "Variable", values_to = "Value")

ggplot(cluster_profile_long, aes(x = Variable, y = Value, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge") +
  facet_wrap(~Cluster, scales = "free_y") +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Profil Karakteristik per Cluster",
       y = "Nilai Rata-rata")

# ============================================================================
# LANGKAH 8: VALIDASI CLUSTER
# ============================================================================

cat("\n=== LANGKAH 8: VALIDASI CLUSTER ===\n")

# Silhouette analysis
cat("\n1. Silhouette Analysis:\n")
sil <- silhouette(kmeans_result$cluster, dist_matrix)
cat("Average silhouette width:", round(mean(sil[, 3]), 3), "\n")

# Interpretasi:
# 0.71-1.00: Strong structure
# 0.51-0.70: Reasonable structure
# 0.26-0.50: Weak structure
# < 0.25: No substantial structure

fviz_silhouette(sil, 
                palette = c("#2E9FDF", "#00AFBB", "#E7B800", "#FC4E07"),
                ggtheme = theme_minimal(),
                main = "Silhouette Plot")

# Identifikasi observasi dengan silhouette negatif (misclassified)
neg_sil <- which(sil[, 3] < 0)
if (length(neg_sil) > 0) {
  cat("\nObservasi dengan silhouette negatif (kemungkinan salah cluster):\n")
  print(rownames(df)[neg_sil])
}

# Dunn Index (higher is better)
cat("\n2. Dunn Index:\n")
dunn_idx <- dunn(dist_matrix, kmeans_result$cluster)
cat("Dunn Index:", round(dunn_idx, 4), "\n")
cat("(Nilai lebih tinggi = cluster lebih terpisah dan compact)\n")

# ============================================================================
# LANGKAH 9: PERBANDINGAN METODE
# ============================================================================

cat("\n=== LANGKAH 9: PERBANDINGAN HIERARCHICAL vs K-MEANS ===\n")

# Tabel kontingensi
cat("\nTabel kontingensi cluster:\n")
table_comparison <- table(Hierarchical = clusters_hc, 
                          KMeans = kmeans_result$cluster)
print(table_comparison)

# Adjusted Rand Index (mengukur agreement)
# Nilai 1 = perfect agreement, 0 = random, negatif = less than random
library(fossil)
ari <- adj.rand.index(clusters_hc, kmeans_result$cluster)
cat("\nAdjusted Rand Index:", round(ari, 3), "\n")
if (ari > 0.7) {
  cat("✓ Kedua metode menghasilkan cluster yang sangat mirip\n")
} else if (ari > 0.3) {
  cat("~ Kedua metode menghasilkan cluster yang cukup mirip\n")
} else {
  cat("✗ Kedua metode menghasilkan cluster yang berbeda\n")
}

# ============================================================================
# LANGKAH 10: INTERPRETASI & PENAMAAN CLUSTER
# ============================================================================

cat("\n=== LANGKAH 10: INTERPRETASI CLUSTER ===\n")

cat("\nBerdasarkan profil cluster, kita dapat memberi nama:\n\n")

# Analisis manual profil
for (i in 1:optimal_k) {
  cat("Cluster", i, ":\n")
  cat("  Ukuran:", sum(kmeans_result$cluster == i), "negara bagian\n")
  cat("  Karakteristik:\n")
  
  centers <- centers_original[i, ]
  
  # Identifikasi karakteristik menonjol
  if (centers["Murder"] > mean(df$Murder)) {
    cat("    - Tingkat pembunuhan TINGGI\n")
  } else {
    cat("    - Tingkat pembunuhan rendah\n")
  }
  
  if (centers["Assault"] > mean(df$Assault)) {
    cat("    - Tingkat penyerangan TINGGI\n")
  } else {
    cat("    - Tingkat penyerangan rendah\n")
  }
  
  if (centers["UrbanPop"] > mean(df$UrbanPop)) {
    cat("    - Populasi urban TINGGI\n")
  } else {
    cat("    - Populasi urban rendah\n")
  }
  
  cat("  Contoh negara bagian:\n")
  states <- rownames(df)[kmeans_result$cluster == i]
  cat("   ", paste(head(states, 3), collapse = ", "), "\n\n")
}

# ============================================================================
# EXPORT HASIL
# ============================================================================

cat("\n=== EXPORT HASIL ===\n")

# Simpan hasil
result_df <- df %>%
  mutate(
    State = rownames(df),
    Cluster_Hierarchical = clusters_hc,
    Cluster_KMeans = kmeans_result$cluster
  ) %>%
  relocate(State)

cat("\nData dengan label cluster:\n")
print(head(result_df))

# Export (opsional)
# write.csv(result_df, "clustering_results.csv", row.names = FALSE)

# ============================================================================
# RINGKASAN
# ============================================================================

cat("\n" + rep("=", 70) + "\n")
cat("RINGKASAN ANALISIS CLUSTER\n")
cat(rep("=", 70) + "\n\n")

cat("1. DATA:\n")
cat("   -", nrow(df), "observasi (negara bagian AS)\n")
cat("   -", ncol(df), "variabel (statistik kriminal)\n\n")

cat("2. PREPROCESSING:\n")
cat("   - Data distandarisasi (mean=0, sd=1)\n")
cat("   - Jarak: Euclidean\n\n")

cat("3. JUMLAH CLUSTER OPTIMAL:", optimal_k, "\n")
cat("   - Ditentukan berdasarkan multiple criteria\n\n")

cat("4. METODE:\n")
cat("   - Hierarchical (Ward's): ", length(unique(clusters_hc)), "cluster\n")
cat("   - K-Means: ", kmeans_result$size, "observasi per cluster\n")
cat("   - Variance explained:", 
    round(kmeans_result$betweenss / kmeans_result$totss * 100, 1), "%\n\n")

cat("5. VALIDASI:\n")
cat("   - Average Silhouette Width:", round(mean(sil[, 3]), 3), "\n")
cat("   - Dunn Index:", round(dunn_idx, 4), "\n")
cat("   - Agreement (ARI):", round(ari, 3), "\n\n")

cat(rep("=", 70) + "\n")

cat("\n⚠️  CATATAN PENTING:\n\n")
cat("1. STANDARDISASI wajib jika variabel beda skala\n")
cat("2. Jumlah cluster adalah KEPUTUSAN SUBYEKTIF\n")
cat("3. Interpretasi cluster harus berdasarkan DOMAIN KNOWLEDGE\n")
cat("4. K-Means sensitif terhadap OUTLIER\n")
cat("5. Hierarchical memberikan STRUKTUR HIRARKI lengkap\n")
cat("6. Clustering adalah EKSPLORATORI, bukan konfirmatori\n\n")

cat("✓ Analisis Cluster selesai!\n\n")
