# ============================================================================
# ANALISIS KOMPONEN UTAMA (Principal Component Analysis - PCA)
# ============================================================================
#
# Tujuan: Mereduksi dimensi data sambil mempertahankan informasi maksimal
# 
# Kapan digunakan:
# - Dataset memiliki banyak variabel yang berkorelasi
# - Ingin mengurangi dimensi untuk visualisasi atau analisis lanjutan
# - Ingin mengidentifikasi pola utama dalam data
#
# Asumsi:
# - Variabel numerik kontinu
# - Hubungan linear antar variabel
# - Tidak ada outlier ekstrem
# - Variabel sudah distandarisasi jika memiliki skala berbeda
#
# ============================================================================

# SETUP: Install dan load packages yang diperlukan
# ============================================================================

# Install packages (jalankan sekali)
# install.packages(c("FactoMineR", "factoextra", "corrplot", "tidyverse", "psych"))

# Load libraries
library(FactoMineR)   # Untuk PCA
library(factoextra)   # Untuk visualisasi
library(corrplot)     # Untuk matriks korelasi
library(tidyverse)    # Untuk manipulasi data
library(psych)        # Untuk deskriptif statistik

# Set seed untuk reprodusibilitas
set.seed(123)

# ============================================================================
# LANGKAH 1: PERSIAPAN DATA
# ============================================================================

cat("\n=== LANGKAH 1: PERSIAPAN DATA ===\n")

# Gunakan dataset iris (contoh klasik)
data("iris")
df <- iris

# Tampilkan struktur data
cat("\nStruktur data:\n")
str(df)

# Statistik deskriptif
cat("\nStatistik deskriptif:\n")
print(describe(df[, 1:4]))

# Pisahkan variabel numerik untuk PCA
# PCA hanya untuk variabel numerik!
df_numeric <- df[, 1:4]  # 4 variabel numerik
species <- df$Species     # Simpan variabel kategorikal untuk visualisasi

# ============================================================================
# LANGKAH 2: EKSPLORASI AWAL - KORELASI
# ============================================================================

cat("\n=== LANGKAH 2: ANALISIS KORELASI ===\n")

# Hitung matriks korelasi
cor_matrix <- cor(df_numeric)
cat("\nMatriks korelasi:\n")
print(round(cor_matrix, 3))

# Visualisasi korelasi
cat("\nMembuat visualisasi matriks korelasi...\n")
corrplot(cor_matrix, 
         method = "color",
         type = "upper",
         order = "hclust",
         tl.col = "black",
         tl.srt = 45,
         addCoef.col = "black",
         number.cex = 0.7,
         title = "Matriks Korelasi Variabel Iris",
         mar = c(0, 0, 2, 0))

# INTERPRETASI:
# - Korelasi tinggi antar variabel → PCA akan efektif
# - Korelasi rendah → PCA mungkin tidak memberikan reduksi dimensi yang baik

# ============================================================================
# LANGKAH 3: CEK ASUMSI - KMO dan Bartlett's Test
# ============================================================================

cat("\n=== LANGKAH 3: CEK KECUKUPAN DATA ===\n")

# KMO (Kaiser-Meyer-Olkin): Mengukur kecukupan sampling
# Nilai > 0.6 = acceptable, > 0.8 = very good
kmo_result <- KMO(cor_matrix)
cat("\nKMO Measure of Sampling Adequacy:\n")
cat("Overall MSA:", round(kmo_result$MSA, 3), "\n")

# Interpretasi KMO:
# 0.00 - 0.49: unacceptable
# 0.50 - 0.59: miserable
# 0.60 - 0.69: mediocre
# 0.70 - 0.79: middling
# 0.80 - 0.89: meritorious
# 0.90 - 1.00: marvelous

# Bartlett's test: Menguji apakah matriks korelasi berbeda dari matriks identitas
# H0: Variabel tidak berkorelasi (matriks korelasi = identitas)
# Jika p < 0.05, kita tolak H0 → variabel berkorelasi → PCA cocok
bartlett_result <- cortest.bartlett(cor_matrix, n = nrow(df_numeric))
cat("\nBartlett's Test of Sphericity:\n")
cat("Chi-square:", round(bartlett_result$chisq, 2), "\n")
cat("p-value:", format.pval(bartlett_result$p.value, digits = 3), "\n")

if (bartlett_result$p.value < 0.05) {
  cat("✓ Kesimpulan: Data cocok untuk PCA (variabel berkorelasi signifikan)\n")
} else {
  cat("✗ Perhatian: Data mungkin tidak cocok untuk PCA\n")
}

# ============================================================================
# LANGKAH 4: MENJALANKAN PCA
# ============================================================================

cat("\n=== LANGKAH 4: PRINCIPAL COMPONENT ANALYSIS ===\n")

# Jalankan PCA
# scale.unit = TRUE: Standardisasi variabel (penting jika skala berbeda!)
# ncp = 4: Jumlah komponen yang dihitung (default: semua)
pca_result <- PCA(df_numeric, 
                  scale.unit = TRUE,
                  ncp = 4,
                  graph = FALSE)

# Tampilkan summary
cat("\nSummary PCA:\n")
print(summary(pca_result, nbelements = Inf))

# ============================================================================
# LANGKAH 5: EIGENVALUES - Berapa Komponen yang Dipertahankan?
# ============================================================================

cat("\n=== LANGKAH 5: EIGENVALUES DAN VARIANS EXPLAINED ===\n")

# Eigenvalues: Variance explained by each PC
eigenvalues <- get_eigenvalue(pca_result)
cat("\nEigenvalues:\n")
print(round(eigenvalues, 3))

# KRITERIA untuk memilih jumlah komponen:
# 1. Kaiser criterion: Eigenvalue > 1
# 2. Scree plot: "Elbow" pada grafik
# 3. Cumulative variance: Biasanya 70-90%

# Hitung jumlah PC dengan eigenvalue > 1
n_components_kaiser <- sum(eigenvalues$eigenvalue > 1)
cat("\nKriteria Kaiser (eigenvalue > 1):", n_components_kaiser, "komponen\n")

# Komponen yang menjelaskan 80% varians
cumvar_80 <- which(eigenvalues$cumulative.variance.percent >= 80)[1]
cat("Komponen untuk 80% varians:", cumvar_80, "komponen\n")

# Visualisasi scree plot
cat("\nMembuat scree plot...\n")
fviz_eig(pca_result, 
         addlabels = TRUE,
         ylim = c(0, 100),
         main = "Scree Plot - Variance Explained per PC")

# ============================================================================
# LANGKAH 6: LOADING - Kontribusi Variabel ke PC
# ============================================================================

cat("\n=== LANGKAH 6: LOADINGS (KORELASI VARIABEL-PC) ===\n")

# Loadings: Korelasi antara variabel original dan PC
loadings <- pca_result$var$coord
cat("\nLoadings (korelasi variabel dengan PC):\n")
print(round(loadings, 3))

# Visualisasi kontribusi variabel ke PC1 dan PC2
cat("\nVisualisasi kontribusi variabel ke PC...\n")
fviz_pca_var(pca_result,
             col.var = "contrib",
             gradient.cols = c("#00AFBB", "#E7B800", "#FC4E07"),
             repel = TRUE,
             title = "Variabel - PCA")

# INTERPRETASI:
# - Panah panjang = variabel berkontribusi besar
# - Panah searah = variabel berkorelasi positif
# - Panah berlawanan = korelasi negatif
# - Sudut 90° = tidak berkorelasi

# ============================================================================
# LANGKAH 7: SCORES - Posisi Observasi pada PC
# ============================================================================

cat("\n=== LANGKAH 7: SCORES (KOORDINAT OBSERVASI) ===\n")

# Scores: Koordinat observasi pada PC baru
scores <- pca_result$ind$coord
cat("\nContoh scores (5 observasi pertama):\n")
print(round(head(scores, 5), 3))

# Visualisasi individu berdasarkan PC1 dan PC2
cat("\nVisualisasi individu pada PC...\n")
fviz_pca_ind(pca_result,
             col.ind = species,
             palette = c("#00AFBB", "#E7B800", "#FC4E07"),
             addEllipses = TRUE,
             ellipse.type = "confidence",
             legend.title = "Species",
             repel = TRUE,
             title = "Individuals - PCA")

# Biplot: Gabungan variabel dan individu
cat("\nMembuat biplot...\n")
fviz_pca_biplot(pca_result,
                col.ind = species,
                palette = c("#00AFBB", "#E7B800", "#FC4E07"),
                addEllipses = TRUE,
                col.var = "black",
                repel = TRUE,
                legend.title = "Species",
                title = "Biplot - PCA")

# ============================================================================
# LANGKAH 8: INTERPRETASI DAN PENAMAAN PC
# ============================================================================

cat("\n=== LANGKAH 8: INTERPRETASI KOMPONEN ===\n")

# Lihat kontribusi variabel ke setiap PC
contrib <- pca_result$var$contrib
cat("\nKontribusi variabel (%):\n")
print(round(contrib, 2))

# Interpretasi PC1 (contoh):
cat("\nInterpretasi PC1:\n")
pc1_contrib <- sort(contrib[, 1], decreasing = TRUE)
print(round(pc1_contrib, 2))
cat("PC1 = 'Overall size' (semua variabel berkontribusi positif)\n")

# Interpretasi PC2 (contoh):
cat("\nInterpretasi PC2:\n")
pc2_contrib <- sort(contrib[, 2], decreasing = TRUE)
print(round(pc2_contrib, 2))
cat("PC2 = 'Shape contrast' (petal vs sepal width)\n")

# ============================================================================
# LANGKAH 9: DIAGNOSTIK - OUTLIER
# ============================================================================

cat("\n=== LANGKAH 9: DETEKSI OUTLIER ===\n")

# Cos2: Quality of representation
# Nilai rendah = observasi tidak terwakili baik oleh PC
cos2_ind <- pca_result$ind$cos2
poor_quality <- which(rowSums(cos2_ind[, 1:2]) < 0.5)

if (length(poor_quality) > 0) {
  cat("\nObservasi dengan representasi buruk (cos2 < 0.5):\n")
  print(poor_quality)
} else {
  cat("\n✓ Semua observasi terwakili baik oleh 2 PC pertama\n")
}

# Contribution: Identifikasi observasi yang sangat berpengaruh
contrib_ind <- pca_result$ind$contrib
avg_contrib <- 100 / nrow(df_numeric)  # Kontribusi rata-rata
influential <- which(contrib_ind[, 1] > 2 * avg_contrib | 
                     contrib_ind[, 2] > 2 * avg_contrib)

if (length(influential) > 0) {
  cat("\nObservasi yang sangat berpengaruh:\n")
  print(influential)
}

# ============================================================================
# LANGKAH 10: EXPORT HASIL
# ============================================================================

cat("\n=== LANGKAH 10: EXPORT HASIL ===\n")

# Simpan scores untuk analisis lanjutan
df_with_pc <- cbind(df, scores[, 1:2])
names(df_with_pc)[(ncol(df)+1):(ncol(df)+2)] <- c("PC1", "PC2")

cat("\nData dengan PC ditambahkan:\n")
print(head(df_with_pc))

# Export ke CSV (opsional)
# write.csv(df_with_pc, "data_with_pca_scores.csv", row.names = FALSE)

# ============================================================================
# RINGKASAN DAN TIPS
# ============================================================================

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("RINGKASAN ANALISIS PCA\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

cat("1. REDUKSI DIMENSI:\n")
cat("   - Dari", ncol(df_numeric), "variabel menjadi", n_components_kaiser, 
    "komponen (Kaiser criterion)\n")
cat("   - Varians dijelaskan:", round(eigenvalues$cumulative.variance.percent[n_components_kaiser], 1), "%\n\n")

cat("2. KOMPONEN UTAMA:\n")
cat("   - PC1 menjelaskan", round(eigenvalues$variance.percent[1], 1), "% varians\n")
cat("   - PC2 menjelaskan", round(eigenvalues$variance.percent[2], 1), "% varians\n\n")

cat("3. INTERPRETASI:\n")
cat("   - Lihat loading dan biplot untuk memahami makna PC\n")
cat("   - Beri nama PC berdasarkan variabel yang berkontribusi besar\n\n")

cat("4. APLIKASI:\n")
cat("   - Gunakan PC scores untuk klasifikasi, clustering, atau regresi\n")
cat("   - Visualisasi data dalam ruang 2D/3D lebih mudah\n\n")

cat(rep("=", 70) + "\n")

# ============================================================================
# CATATAN PENTING & PERINGATAN
# ============================================================================

cat("\n⚠️  CATATAN PENTING:\n\n")
cat("1. STANDARDISASI:\n")
cat("   - Jika variabel memiliki satuan berbeda, HARUS distandarisasi\n")
cat("   - Gunakan scale.unit = TRUE di PCA()\n\n")

cat("2. INTERPRETASI:\n")
cat("   - PCA adalah eksploratori, bukan konfirmatori\n")
cat("   - Komponen tidak selalu memiliki interpretasi substantif\n\n")

cat("3. DATA KATEGORIKAL:\n")
cat("   - PCA TIDAK cocok untuk data kategorikal\n")
cat("   - Gunakan MCA (Multiple Correspondence Analysis) untuk kategorikal\n\n")

cat("4. OUTLIER:\n")
cat("   - PCA sensitif terhadap outlier\n")
cat("   - Periksa dan tangani outlier sebelum PCA\n\n")

cat("5. MISSING VALUES:\n")
cat("   - PCA tidak bisa menangani NA\n")
cat("   - Impute atau hapus missing values terlebih dahulu\n\n")

cat("✓ Analisis PCA selesai!\n\n")
