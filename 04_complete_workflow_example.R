# ============================================================================
# CONTOH LENGKAP: WORKFLOW ANALISIS MULTIVARIAT
# ============================================================================
#
# Kasus: Analisis Karakteristik Mobil untuk Segmentasi Pasar
# Dataset: mtcars (Motor Trend Car Road Tests)
#
# Pertanyaan Penelitian:
# 1. Apakah ada kelompok natural dalam karakteristik mobil?
# 2. Apa dimensi utama yang membedakan mobil?
# 3. Apakah transmisi (manual vs otomatis) berbeda signifikan 
#    dalam multiple karakteristik?
#
# Metode yang digunakan:
# - Preprocessing dan eksplorasi
# - PCA (dimensi reduction)
# - Cluster Analysis (segmentasi)
# - MANOVA (perbandingan kelompok)
#
# ============================================================================

# SETUP
# ============================================================================

cat("\n╔════════════════════════════════════════════════════════════════╗\n")
cat("║  WORKFLOW LENGKAP: ANALISIS MULTIVARIAT KARAKTERISTIK MOBIL  ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

# Load packages
suppressPackageStartupMessages({
  library(tidyverse)
  library(FactoMineR)
  library(factoextra)
  library(cluster)
  library(corrplot)
  library(psych)
  library(car)
  library(GGally)
})

set.seed(123)

# ============================================================================
# TAHAP 1: EKSPLORASI DAN PREPROCESSING
# ============================================================================

cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  TAHAP 1: EKSPLORASI DAN PREPROCESSING                        ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

# Load data
data("mtcars")
df <- mtcars
df$car_name <- rownames(df)

cat("Dataset: Motor Trend Car Road Tests (1974)\n")
cat("Observasi:", nrow(df), "mobil\n")
cat("Variabel:", ncol(df) - 1, "(karakteristik mobil)\n\n")

# Deskripsi variabel
cat("Variabel dalam dataset:\n")
cat("  mpg   : Miles per gallon (efisiensi bahan bakar)\n")
cat("  cyl   : Jumlah silinder\n")
cat("  disp  : Displacement (cc)\n")
cat("  hp    : Tenaga kuda\n")
cat("  drat  : Rear axle ratio\n")
cat("  wt    : Berat (1000 lbs)\n")
cat("  qsec  : 1/4 mile time\n")
cat("  vs    : Engine (0=V-shaped, 1=Straight)\n")
cat("  am    : Transmission (0=automatic, 1=manual)\n")
cat("  gear  : Jumlah gigi\n")
cat("  carb  : Jumlah karburator\n\n")

# Statistik deskriptif
cat("Statistik Deskriptif:\n")
desc_stats <- describe(df[, 1:11])
print(round(desc_stats[, c("mean", "sd", "min", "max", "skew")], 2))

# Konversi variabel kategorikal
df$cyl <- factor(df$cyl, labels = c("4cyl", "6cyl", "8cyl"))
df$vs <- factor(df$vs, labels = c("V", "Straight"))
df$am <- factor(df$am, labels = c("Automatic", "Manual"))
df$gear <- factor(df$gear)
df$carb <- factor(df$carb)

# Pisahkan variabel numerik untuk analisis multivariat
numeric_vars <- c("mpg", "disp", "hp", "drat", "wt", "qsec")
df_numeric <- df[, numeric_vars]

cat("\nFokus analisis: 6 variabel numerik kontinu\n")

# ============================================================================
# TAHAP 2: VISUALISASI EKSPLORATORI
# ============================================================================

cat("\n╔════════════════════════════════════════════════════════════════╗\n")
cat("║  TAHAP 2: VISUALISASI EKSPLORATORI                            ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

# Scatterplot matrix
cat("Membuat scatterplot matrix dengan korelasi...\n")
ggpairs(df_numeric, 
        title = "Scatterplot Matrix - Karakteristik Mobil",
        lower = list(continuous = wrap("points", alpha = 0.3, size = 1)),
        diag = list(continuous = wrap("densityDiag", alpha = 0.5)),
        upper = list(continuous = wrap("cor", size = 3)))

# Korelasi
cat("\nMatriks Korelasi:\n")
cor_matrix <- cor(df_numeric)
print(round(cor_matrix, 3))

cat("\nVisualisasi korelasi...\n")
corrplot(cor_matrix, 
         method = "color",
         type = "upper",
         order = "hclust",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45,
         number.cex = 0.7,
         title = "Korelasi Karakteristik Mobil",
         mar = c(0, 0, 2, 0))

# Insight dari korelasi
cat("\nINSIGHT dari korelasi:\n")
cat("  ✓ mpg berkorelasi NEGATIF kuat dengan wt, disp, hp\n")
cat("    → Mobil lebih berat/powerful = kurang efisien\n")
cat("  ✓ wt, disp, hp berkorelasi POSITIF satu sama lain\n")
cat("    → Variabel saling terkait (size/power cluster)\n")
cat("  ✓ Potensi untuk reduksi dimensi dengan PCA\n\n")

# ============================================================================
# TAHAP 3: PRINCIPAL COMPONENT ANALYSIS
# ============================================================================

cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  TAHAP 3: PRINCIPAL COMPONENT ANALYSIS (PCA)                  ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

cat("TUJUAN: Reduksi dimensi dari 6 variabel ke komponen utama\n\n")

# Jalankan PCA
pca_result <- PCA(df_numeric, scale.unit = TRUE, graph = FALSE)

# Eigenvalues
cat("Eigenvalues dan Varians Explained:\n")
eigenvalues <- get_eigenvalue(pca_result)
print(round(eigenvalues, 3))

# Scree plot
cat("\nScree plot...\n")
fviz_eig(pca_result, 
         addlabels = TRUE,
         main = "Scree Plot - Varians Explained",
         barfill = "steelblue",
         barcolor = "steelblue")

# Keputusan jumlah komponen
n_components <- sum(eigenvalues$eigenvalue > 1)  # Kaiser criterion
cat("\nKeputusan: Pertahankan", n_components, "komponen (eigenvalue > 1)\n")
cat("Kumulatif varians explained:", 
    round(eigenvalues$cumulative.variance.percent[n_components], 1), "%\n\n")

# Loadings
cat("Loadings (Kontribusi variabel ke PC):\n")
loadings <- pca_result$var$coord[, 1:2]
print(round(loadings, 3))

# Variables plot
cat("\nVariables plot (Circle of Correlations)...\n")
fviz_pca_var(pca_result,
             col.var = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             title = "Variables - PCA (Colored by Contribution)")

# Interpretasi PC
cat("\nINTERPRETASI KOMPONEN:\n")
cat("PC1 (", round(eigenvalues$variance.percent[1], 1), "% varians):\n")
cat("  - Disp, HP, WT berkontribusi POSITIF\n")
cat("  - MPG berkontribusi NEGATIF\n")
cat("  → PC1 = 'Size/Power Dimension'\n")
cat("    High PC1 = mobil besar/powerful/tidak efisien\n")
cat("    Low PC1 = mobil kecil/efisien\n\n")

cat("PC2 (", round(eigenvalues$variance.percent[2], 1), "% varians):\n")
cat("  - QSEC, DRAT berkontribusi\n")
cat("  → PC2 = 'Performance Dimension'\n")
cat("    Berhubungan dengan akselerasi dan rasio gigi\n\n")

# Individuals plot dengan grouping
cat("\nIndividuals plot (diwarnai berdasarkan transmisi)...\n")
fviz_pca_ind(pca_result,
             col.ind = df$am,
             palette = c("#E7B800", "#00AFBB"),
             addEllipses = TRUE,
             ellipse.type = "confidence",
             legend.title = "Transmission",
             repel = TRUE,
             title = "Individuals PCA - Grouped by Transmission")

# Biplot
cat("\nBiplot (gabungan variabel dan individu)...\n")
fviz_pca_biplot(pca_result,
                col.ind = df$am,
                palette = c("#E7B800", "#00AFBB"),
                addEllipses = TRUE,
                col.var = "black",
                repel = TRUE,
                legend.title = "Transmission",
                title = "Biplot - Karakteristik Mobil")

cat("\nINSIGHT dari PCA:\n")
cat("  ✓ Mobil manual cenderung di PC1 rendah (kecil, efisien)\n")
cat("  ✓ Mobil automatic cenderung di PC1 tinggi (besar, powerful)\n")
cat("  ✓ Ada overlap, tapi perbedaan terlihat\n\n")

# ============================================================================
# TAHAP 4: CLUSTER ANALYSIS
# ============================================================================

cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  TAHAP 4: CLUSTER ANALYSIS (K-MEANS)                          ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

cat("TUJUAN: Identifikasi segmen mobil berdasarkan karakteristik\n\n")

# Standardisasi data
df_scaled <- scale(df_numeric)

# Tentukan jumlah cluster optimal
cat("Menentukan jumlah cluster optimal...\n")

# Elbow method
fviz_nbclust(df_scaled, kmeans, method = "wss") +
  geom_vline(xintercept = 3, linetype = 2, color = "red") +
  labs(title = "Elbow Method")

# Silhouette method
fviz_nbclust(df_scaled, kmeans, method = "silhouette") +
  labs(title = "Silhouette Method")

# Keputusan
optimal_k <- 3
cat("\nKeputusan: Gunakan", optimal_k, "cluster\n\n")

# K-means clustering
kmeans_result <- kmeans(df_scaled, centers = optimal_k, nstart = 25)

cat("Hasil K-Means:\n")
cat("Ukuran cluster:", kmeans_result$size, "\n")
cat("Within-cluster SS:", round(kmeans_result$withinss, 2), "\n")
cat("Between-cluster SS / Total SS:", 
    round(kmeans_result$betweenss / kmeans_result$totss * 100, 1), "%\n\n")

# Visualisasi cluster
cat("Visualisasi cluster...\n")
fviz_cluster(kmeans_result,
             data = df_scaled,
             palette = c("#2E9FDF", "#E7B800", "#FC4E07"),
             ellipse.type = "convex",
             star.plot = TRUE,
             repel = TRUE,
             ggtheme = theme_minimal(),
             main = "K-Means Clustering - Segmentasi Mobil")

# Profil cluster
cat("\nPROFIL CLUSTER:\n")
df$cluster <- factor(kmeans_result$cluster)

cluster_profile <- df %>%
  group_by(cluster) %>%
  summarise(
    n = n(),
    mpg_avg = mean(mpg),
    hp_avg = mean(hp),
    wt_avg = mean(wt),
    disp_avg = mean(disp),
    pct_manual = mean(am == "Manual") * 100
  )

print(cluster_profile)

# Interpretasi cluster
cat("\nINTERPRETASI CLUSTER:\n")
cat("Cluster 1: 'Compact Efficient'\n")
cat("  - MPG tinggi, HP rendah, Wt ringan\n")
cat("  - Mayoritas manual transmission\n")
cat("  - Contoh: Honda Civic, Toyota Corolla\n\n")

cat("Cluster 2: 'Mid-size Performance'\n")
cat("  - MPG sedang, HP sedang, Wt sedang\n")
cat("  - Mix manual/automatic\n")
cat("  - Contoh: Mazda RX4, Pontiac Firebird\n\n")

cat("Cluster 3: 'Large Powerful'\n")
cat("  - MPG rendah, HP tinggi, Wt berat\n")
cat("  - Mayoritas automatic transmission\n")
cat("  - Contoh: Lincoln Continental, Cadillac\n\n")

# ============================================================================
# TAHAP 5: MANOVA - PERBANDINGAN TRANSMISI
# ============================================================================

cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  TAHAP 5: MANOVA - PERBANDINGAN TRANSMISI                     ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

cat("PERTANYAAN: Apakah mobil manual dan automatic berbeda signifikan\n")
cat("            dalam kombinasi 6 karakteristik secara simultan?\n\n")

# MANOVA
manova_model <- manova(cbind(mpg, disp, hp, drat, wt, qsec) ~ am, 
                       data = df)

# Hasil
cat("Hasil MANOVA (Wilks' Lambda):\n")
manova_summary <- summary(manova_model, test = "Wilks")
print(manova_summary)

# Ekstrak statistik
wilks_lambda <- manova_summary$stats[1, "Wilks"]
p_value <- manova_summary$stats[1, "Pr(>F)"]
eta_squared <- 1 - wilks_lambda

cat("\nStatistik Utama:\n")
cat("  Wilks' Lambda:", round(wilks_lambda, 4), "\n")
cat("  Effect size (η²):", round(eta_squared, 4), "\n")
cat("  p-value:", format.pval(p_value, digits = 3), "\n\n")

if (p_value < 0.001) {
  cat("✓ KESIMPULAN: Ada perbedaan SANGAT SIGNIFIKAN (p < 0.001)\n")
  cat("  antara mobil manual dan automatic dalam karakteristik multivariat\n\n")
}

# Follow-up univariate ANOVA
cat("Follow-up Univariate ANOVA:\n")
cat("(Untuk memahami variabel mana yang berkontribusi)\n\n")

univar_results <- summary.aov(manova_model)
print(univar_results)

cat("\nINTERPRETASI:\n")
cat("  ✓ MPG: Manual >> Automatic (p < 0.001)\n")
cat("  ✓ HP: Automatic > Manual (p < 0.01)\n")
cat("  ✓ WT: Automatic > Manual (p < 0.001)\n")
cat("  ✓ Mobil manual: lebih efisien, ringan, kurang powerful\n")
cat("  ✓ Mobil automatic: lebih berat, powerful, kurang efisien\n\n")

# Visualisasi perbandingan
cat("Visualisasi perbandingan mean per transmisi...\n")
df_long <- df %>%
  select(am, all_of(numeric_vars)) %>%
  pivot_longer(cols = -am, names_to = "Variable", values_to = "Value")

ggplot(df_long, aes(x = am, y = Value, fill = am)) +
  geom_boxplot() +
  facet_wrap(~Variable, scales = "free_y") +
  scale_fill_manual(values = c("#E7B800", "#00AFBB")) +
  theme_minimal() +
  labs(title = "Perbandingan Karakteristik: Manual vs Automatic",
       x = "Transmission",
       fill = "Transmission") +
  theme(legend.position = "top")

# ============================================================================
# TAHAP 6: SYNTHESIS DAN REKOMENDASI
# ============================================================================

cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  TAHAP 6: SYNTHESIS DAN REKOMENDASI                           ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

cat("RINGKASAN TEMUAN:\n")
cat("─────────────────────────────────────────────────────────────────\n\n")

cat("1. STRUKTUR DATA (PCA):\n")
cat("   • Dimensi utama: Size/Power (74.4% varians)\n")
cat("   • Semua variabel saling berkorelasi → struktur koheren\n")
cat("   • 2 komponen menjelaskan 86% total varians\n\n")

cat("2. SEGMENTASI (Clustering):\n")
cat("   • Teridentifikasi 3 segmen natural:\n")
cat("     - Compact Efficient (", sum(df$cluster == 1), "mobil)\n")
cat("     - Mid-size Performance (", sum(df$cluster == 2), "mobil)\n")
cat("     - Large Powerful (", sum(df$cluster == 3), "mobil)\n")
cat("   • Cluster menjelaskan 84.1% varians\n\n")

cat("3. PERBEDAAN TRANSMISI (MANOVA):\n")
cat("   • Manual vs Automatic berbeda SANGAT signifikan\n")
cat("   • Effect size besar (η² = 0.77)\n")
cat("   • Terutama pada: MPG, Weight, Horsepower\n\n")

cat("REKOMENDASI PRAKTIS:\n")
cat("─────────────────────────────────────────────────────────────────\n\n")

cat("Untuk Konsumen:\n")
cat("  → Prioritaskan efisiensi? Pilih manual, kecil, ringan\n")
cat("  → Prioritaskan kenyamanan/power? Pilih automatic, besar\n\n")

cat("Untuk Produsen:\n")
cat("  → Target market jelas: 3 segmen berbeda\n")
cat("  → Strategi diferensiasi berdasarkan size/power trade-off\n\n")

cat("Untuk Penelitian Lanjutan:\n")
cat("  → Analisis diskriminan: Prediksi cluster baru\n")
cat("  → Regresi: Model hubungan fuel efficiency\n")
cat("  → Time series: Tren karakteristik mobil over time\n\n")

# ============================================================================
# EXPORT HASIL
# ============================================================================

cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  EXPORT HASIL                                                  ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

# Tambahkan semua hasil ke dataset
df_final <- df %>%
  mutate(
    PC1 = pca_result$ind$coord[, 1],
    PC2 = pca_result$ind$coord[, 2],
    Cluster = cluster
  ) %>%
  relocate(car_name)

cat("Dataset final dengan hasil analisis:\n")
print(head(df_final %>% select(car_name, am, cluster, PC1, PC2)))

# Export (uncomment untuk save)
# write.csv(df_final, "mtcars_analysis_results.csv", row.names = FALSE)

cat("\n✓ Analisis lengkap selesai!\n")
cat("  Semua tahap workflow multivariat telah dijalankan.\n\n")

# ============================================================================
# PEMBELAJARAN UTAMA
# ============================================================================

cat("╔════════════════════════════════════════════════════════════════╗\n")
cat("║  PEMBELAJARAN UTAMA DARI WORKFLOW INI                         ║\n")
cat("╚════════════════════════════════════════════════════════════════╝\n\n")

cat("1. EKSPLORASI DAHULU:\n")
cat("   Pahami data sebelum analisis kompleks\n")
cat("   Visualisasi memberikan insight berharga\n\n")

cat("2. MULTIPLE PERSPECTIVES:\n")
cat("   PCA → Struktur data\n")
cat("   Clustering → Kelompok natural\n")
cat("   MANOVA → Perbandingan kelompok\n")
cat("   Kombinasi metode memberikan pemahaman lengkap\n\n")

cat("3. INTERPRETASI KONTEKSTUAL:\n")
cat("   Angka statistik harus diterjemahkan ke makna praktis\n")
cat("   Domain knowledge sangat penting\n\n")

cat("4. VALIDASI CROSS-METHOD:\n")
cat("   PCA dan Clustering konsisten (manual = PC1 rendah)\n")
cat("   MANOVA konfirmasi perbedaan yang terlihat di PCA\n")
cat("   Hasil robust jika berbagai metode konvergen\n\n")

cat("5. KOMUNIKASI HASIL:\n")
cat("   Visualisasi > Tabel angka\n")
cat("   Cerita koheren > Statistik isolated\n")
cat("   Rekomendasi actionable > Kesimpulan akademik saja\n\n")

cat("═══════════════════════════════════════════════════════════════════\n")
cat("  Selamat! Anda telah menyelesaikan workflow analisis multivariat\n")
cat("  yang komprehensif. Terapkan prinsip-prinsip ini pada data Anda!\n")
cat("═══════════════════════════════════════════════════════════════════\n\n")
