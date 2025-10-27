# ============================================================================
# PANDUAN PREPROCESSING DATA UNTUK ANALISIS MULTIVARIAT
# ============================================================================
#
# File ini berisi langkah-langkah sistematis untuk mempersiapkan data
# sebelum melakukan analisis multivariat
#
# ============================================================================

# SETUP
# ============================================================================

library(tidyverse)    # Data manipulation
library(mice)         # Missing data imputation
library(VIM)          # Visualisasi missing data
library(outliers)     # Deteksi outlier
library(moments)      # Skewness & kurtosis
library(psych)        # Descriptive statistics
library(corrplot)     # Correlation visualization

set.seed(2024)

# ============================================================================
# LANGKAH 1: IMPORT DAN INSPEKSI DATA
# ============================================================================

cat("\n=== LANGKAH 1: IMPORT DAN INSPEKSI DATA ===\n")

# Contoh: Import dari CSV
# df <- read.csv("your_data.csv", header = TRUE, stringsAsFactors = FALSE)

# Untuk tutorial ini, gunakan dataset built-in
data("airquality")
df <- airquality

cat("\nDimensi data:\n")
cat("Baris:", nrow(df), ", Kolom:", ncol(df), "\n")

cat("\nStruktur data:\n")
str(df)

cat("\nSample data (6 baris pertama):\n")
print(head(df))

cat("\nSample data (6 baris terakhir):\n")
print(tail(df))

cat("\nNama variabel:\n")
print(names(df))

# ============================================================================
# LANGKAH 2: STATISTIK DESKRIPTIF
# ============================================================================

cat("\n=== LANGKAH 2: STATISTIK DESKRIPTIF ===\n")

# Summary dasar
cat("\nSummary statistik:\n")
print(summary(df))

# Statistik lebih detail
cat("\nStatistik deskriptif lengkap:\n")
desc_stats <- describe(df)
print(desc_stats)

# Identifikasi tipe variabel
cat("\nTipe variabel:\n")
cat("Numerik:", sum(sapply(df, is.numeric)), "\n")
cat("Kategorikal:", sum(sapply(df, is.factor)), "\n")
cat("Karakter:", sum(sapply(df, is.character)), "\n")

# ============================================================================
# LANGKAH 3: MISSING VALUES
# ============================================================================

cat("\n=== LANGKAH 3: ANALISIS MISSING VALUES ===\n")

# Hitung missing values
missing_count <- colSums(is.na(df))
missing_pct <- (missing_count / nrow(df)) * 100

cat("\nMissing values per variabel:\n")
missing_summary <- data.frame(
  Variable = names(df),
  Missing_Count = missing_count,
  Missing_Pct = round(missing_pct, 2)
)
print(missing_summary[missing_summary$Missing_Count > 0, ])

# Total missing
total_missing <- sum(is.na(df))
total_cells <- nrow(df) * ncol(df)
cat("\nTotal missing:", total_missing, "dari", total_cells, "cells",
    "(", round(total_missing/total_cells * 100, 2), "%)\n")

# Visualisasi missing data pattern
if (sum(is.na(df)) > 0) {
  cat("\nVisualisasi pola missing data...\n")
  aggr(df, 
       col = c('navyblue', 'red'),
       numbers = TRUE,
       sortVars = TRUE,
       labels = names(df),
       cex.axis = .7,
       gap = 3,
       ylab = c("Histogram of missing data", "Pattern"))
}

# ============================================================================
# LANGKAH 4: PENANGANAN MISSING VALUES
# ============================================================================

cat("\n=== LANGKAH 4: PENANGANAN MISSING VALUES ===\n")

if (sum(is.na(df)) > 0) {
  cat("\nPilihan penanganan missing values:\n")
  cat("1. Listwise deletion (hapus baris dengan NA)\n")
  cat("2. Mean/Median imputation\n")
  cat("3. Multiple imputation (MICE)\n")
  cat("4. Model-based imputation\n\n")
  
  # OPSI 1: Listwise deletion
  cat("OPSI 1: Listwise Deletion\n")
  df_complete <- na.omit(df)
  cat("Baris sebelum:", nrow(df), ", Baris setelah:", nrow(df_complete), "\n")
  cat("Data hilang:", nrow(df) - nrow(df_complete), "baris\n\n")
  
  # OPSI 2: Mean/Median imputation
  cat("OPSI 2: Mean Imputation (untuk variabel numerik)\n")
  df_mean_imp <- df
  numeric_vars <- names(df)[sapply(df, is.numeric)]
  for (var in numeric_vars) {
    df_mean_imp[[var]][is.na(df_mean_imp[[var]])] <- mean(df_mean_imp[[var]], na.rm = TRUE)
  }
  cat("Missing values setelah mean imputation:", sum(is.na(df_mean_imp)), "\n\n")
  
  # OPSI 3: Multiple Imputation (MICE)
  cat("OPSI 3: Multiple Imputation with MICE\n")
  cat("(Metode paling canggih, mempertimbangkan uncertainty)\n")
  
  # Jalankan MICE
  imp <- mice(df, m = 5, method = 'pmm', maxit = 10, seed = 2024, printFlag = FALSE)
  df_mice <- complete(imp, 1)  # Ambil imputasi pertama
  
  cat("Missing values setelah MICE:", sum(is.na(df_mice)), "\n")
  cat("✓ Rekomendasi: Gunakan MICE untuk analisis serius\n\n")
  
  # Gunakan data hasil MICE untuk analisis selanjutnya
  df_clean <- df_mice
  
} else {
  cat("✓ Tidak ada missing values dalam data\n")
  df_clean <- df
}

# ============================================================================
# LANGKAH 5: DETEKSI OUTLIER UNIVARIAT
# ============================================================================

cat("\n=== LANGKAH 5: DETEKSI OUTLIER UNIVARIAT ===\n")

# Deteksi outlier dengan IQR method
numeric_vars <- names(df_clean)[sapply(df_clean, is.numeric)]
cat("\nDeteksi outlier dengan IQR method (Q1 - 1.5*IQR, Q3 + 1.5*IQR):\n\n")

outlier_summary <- list()
for (var in numeric_vars) {
  Q1 <- quantile(df_clean[[var]], 0.25, na.rm = TRUE)
  Q3 <- quantile(df_clean[[var]], 0.75, na.rm = TRUE)
  IQR <- Q3 - Q1
  
  lower_bound <- Q1 - 1.5 * IQR
  upper_bound <- Q3 + 1.5 * IQR
  
  outliers <- df_clean[[var]] < lower_bound | df_clean[[var]] > upper_bound
  n_outliers <- sum(outliers, na.rm = TRUE)
  
  cat(sprintf("%-15s: %2d outliers (%.1f%%)\n", 
              var, n_outliers, (n_outliers/nrow(df_clean))*100))
  
  outlier_summary[[var]] <- list(
    lower = lower_bound,
    upper = upper_bound,
    count = n_outliers,
    indices = which(outliers)
  )
}

# Visualisasi boxplot
cat("\nVisualisasi boxplot untuk deteksi outlier...\n")
df_clean_long <- df_clean %>%
  select(all_of(numeric_vars)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Value")

ggplot(df_clean_long, aes(x = Variable, y = Value, fill = Variable)) +
  geom_boxplot(outlier.colour = "red", outlier.shape = 16) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none") +
  labs(title = "Deteksi Outlier Univariat",
       subtitle = "Titik merah = outlier potensial")

# ============================================================================
# LANGKAH 6: DETEKSI OUTLIER MULTIVARIAT
# ============================================================================

cat("\n=== LANGKAH 6: DETEKSI OUTLIER MULTIVARIAT ===\n")

cat("\nMahalanobis Distance untuk deteksi outlier multivariat:\n")

# Hanya variabel numerik
df_numeric <- df_clean %>% select(all_of(numeric_vars))

# Hitung Mahalanobis distance
center <- colMeans(df_numeric, na.rm = TRUE)
cov_matrix <- cov(df_numeric, use = "complete.obs")
mahal_dist <- mahalanobis(df_numeric, center, cov_matrix)

# Threshold: Chi-square dengan df = jumlah variabel
threshold <- qchisq(0.999, df = ncol(df_numeric))

# Identifikasi outlier
outliers_multivar <- mahal_dist > threshold
n_outliers_multivar <- sum(outliers_multivar)

cat("Threshold (χ² 99.9%):", round(threshold, 2), "\n")
cat("Jumlah outlier multivariat:", n_outliers_multivar, 
    "(", round(n_outliers_multivar/nrow(df_clean)*100, 2), "%)\n")

if (n_outliers_multivar > 0) {
  cat("Indeks outlier:", which(outliers_multivar), "\n")
  cat("\n⚠ Pertimbangkan untuk:\n")
  cat("  1. Investigasi nilai ekstrem (error data?)\n")
  cat("  2. Transformasi data\n")
  cat("  3. Robust methods\n")
  cat("  4. Hapus jika justifiable\n")
}

# Visualisasi Mahalanobis distance
cat("\nVisualisasi Mahalanobis distance...\n")
df_mahal <- data.frame(
  Index = 1:nrow(df_numeric),
  Mahalanobis = mahal_dist,
  Outlier = outliers_multivar
)

ggplot(df_mahal, aes(x = Index, y = Mahalanobis, color = Outlier)) +
  geom_point() +
  geom_hline(yintercept = threshold, linetype = "dashed", color = "red") +
  scale_color_manual(values = c("FALSE" = "blue", "TRUE" = "red")) +
  theme_minimal() +
  labs(title = "Mahalanobis Distance",
       subtitle = paste("Threshold =", round(threshold, 2)),
       y = "Mahalanobis Distance")

# ============================================================================
# LANGKAH 7: CEK DISTRIBUSI DAN NORMALITAS
# ============================================================================

cat("\n=== LANGKAH 7: CEK DISTRIBUSI DAN NORMALITAS ===\n")

cat("\nSkewness dan Kurtosis per variabel:\n")
for (var in numeric_vars) {
  skew <- skewness(df_clean[[var]], na.rm = TRUE)
  kurt <- kurtosis(df_clean[[var]], na.rm = TRUE)
  
  cat(sprintf("%-15s: Skew = %6.3f, Kurt = %6.3f", var, skew, kurt))
  
  # Interpretasi
  if (abs(skew) > 1) {
    cat(" [Skewed]")
  }
  if (abs(kurt - 3) > 1) {
    cat(" [Heavy tails]")
  }
  cat("\n")
}

cat("\nInterpretasi:\n")
cat("  Skewness: -1 to 1 = approximately symmetric\n")
cat("  Kurtosis: ~3 = normal, >3 = heavy tails, <3 = light tails\n\n")

# Shapiro-Wilk test untuk normalitas
cat("Shapiro-Wilk Test untuk Normalitas:\n")
cat("H0: Data berdistribusi normal\n\n")

for (var in numeric_vars) {
  # Shapiro test hanya untuk n < 5000
  if (nrow(df_clean) <= 5000) {
    shapiro_result <- shapiro.test(df_clean[[var]])
    cat(sprintf("%-15s: W = %.4f, p = %s", 
                var, 
                shapiro_result$statistic,
                format.pval(shapiro_result$p.value, digits = 3)))
    
    if (shapiro_result$p.value > 0.05) {
      cat(" [Normal]\n")
    } else {
      cat(" [Not normal]\n")
    }
  }
}

# Histogram dan QQ-plot
cat("\nVisualisasi distribusi...\n")
par(mfrow = c(length(numeric_vars), 2))
for (var in numeric_vars) {
  # Histogram
  hist(df_clean[[var]], 
       main = paste("Histogram:", var),
       xlab = var,
       col = "lightblue",
       breaks = 20)
  
  # QQ-plot
  qqnorm(df_clean[[var]], main = paste("Q-Q Plot:", var))
  qqline(df_clean[[var]], col = "red")
}
par(mfrow = c(1, 1))

# ============================================================================
# LANGKAH 8: TRANSFORMASI DATA
# ============================================================================

cat("\n=== LANGKAH 8: TRANSFORMASI DATA ===\n")

cat("\nJika data tidak normal atau skewed, pertimbangkan transformasi:\n")
cat("1. Log transformation: untuk right-skewed data\n")
cat("2. Square root: untuk count data\n")
cat("3. Box-Cox: otomatis menemukan transformasi optimal\n")
cat("4. Standardization (z-score): untuk skala berbeda\n\n")

# Contoh: Log transformation
cat("Contoh: Log transformation untuk variabel right-skewed\n")
# Pilih variabel dengan skewness > 1
skewed_vars <- numeric_vars[sapply(numeric_vars, function(v) {
  skewness(df_clean[[v]], na.rm = TRUE) > 1
})]

if (length(skewed_vars) > 0) {
  cat("Variabel right-skewed:", paste(skewed_vars, collapse = ", "), "\n")
  
  for (var in skewed_vars) {
    var_transformed <- paste0(var, "_log")
    # Tambah konstanta kecil jika ada nilai 0
    df_clean[[var_transformed]] <- log(df_clean[[var]] + 1)
    
    skew_before <- skewness(df_clean[[var]], na.rm = TRUE)
    skew_after <- skewness(df_clean[[var_transformed]], na.rm = TRUE)
    
    cat(sprintf("  %s: Skewness %.3f → %.3f\n", 
                var, skew_before, skew_after))
  }
}

# Standardisasi (Z-score)
cat("\nStandardisasi (mean=0, sd=1):\n")
cat("Penting untuk: PCA, clustering, jarak-based methods\n")

df_scaled <- df_clean
df_scaled[numeric_vars] <- scale(df_clean[numeric_vars])

cat("\nContoh data terstandarisasi:\n")
print(head(df_scaled[numeric_vars]))

# ============================================================================
# LANGKAH 9: KORELASI ANTAR VARIABEL
# ============================================================================

cat("\n=== LANGKAH 9: ANALISIS KORELASI ===\n")

# Matriks korelasi
cor_matrix <- cor(df_clean[numeric_vars], use = "complete.obs")

cat("\nMatriks korelasi:\n")
print(round(cor_matrix, 3))

# Visualisasi
cat("\nVisualisasi matriks korelasi...\n")
corrplot(cor_matrix, 
         method = "color",
         type = "upper",
         order = "hclust",
         addCoef.col = "black",
         tl.col = "black",
         tl.srt = 45,
         number.cex = 0.7,
         title = "Matriks Korelasi",
         mar = c(0, 0, 2, 0))

# Identifikasi korelasi tinggi
high_cor <- which(abs(cor_matrix) > 0.7 & cor_matrix != 1, arr.ind = TRUE)
if (nrow(high_cor) > 0) {
  cat("\n⚠ Korelasi tinggi (|r| > 0.7) terdeteksi:\n")
  for (i in 1:nrow(high_cor)) {
    row_var <- rownames(cor_matrix)[high_cor[i, 1]]
    col_var <- colnames(cor_matrix)[high_cor[i, 2]]
    cor_val <- cor_matrix[high_cor[i, 1], high_cor[i, 2]]
    cat(sprintf("  %s ↔ %s: r = %.3f\n", row_var, col_var, cor_val))
  }
  cat("\n  Pertimbangkan: multikolinearitas, hapus variabel redundan\n")
}

# ============================================================================
# LANGKAH 10: EXPORT DATA BERSIH
# ============================================================================

cat("\n=== LANGKAH 10: EXPORT DATA BERSIH ===\n")

# Simpan data yang sudah dibersihkan
# write.csv(df_clean, "data_cleaned.csv", row.names = FALSE)
# write.csv(df_scaled, "data_scaled.csv", row.names = FALSE)

cat("\nData preprocessing selesai!\n")
cat("\nRingkasan:\n")
cat("  - Data original:", nrow(df), "x", ncol(df), "\n")
cat("  - Data cleaned:", nrow(df_clean), "x", ncol(df_clean), "\n")
cat("  - Missing values:", sum(is.na(df_clean)), "\n")
cat("  - Outliers (multivariat):", n_outliers_multivar, "\n")

# ============================================================================
# CHECKLIST PREPROCESSING
# ============================================================================

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("CHECKLIST PREPROCESSING SEBELUM ANALISIS MULTIVARIAT\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

cat("□ 1. Import dan inspeksi data\n")
cat("□ 2. Periksa tipe variabel (numerik, kategorikal)\n")
cat("□ 3. Analisis dan tangani missing values\n")
cat("□ 4. Deteksi dan tangani outlier univariat\n")
cat("□ 5. Deteksi dan tangani outlier multivariat\n")
cat("□ 6. Cek distribusi dan normalitas\n")
cat("□ 7. Transformasi data jika perlu\n")
cat("□ 8. Standardisasi untuk metode distance-based\n")
cat("□ 9. Analisis korelasi dan multikolinearitas\n")
cat("□ 10. Export data bersih untuk analisis\n\n")

cat(paste(rep("=", 70), collapse = ""), "\n")

cat("\n💡 TIPS PENTING:\n\n")
cat("1. DOKUMENTASI: Catat semua keputusan preprocessing\n")
cat("2. JUSTIFIKASI: Setiap penghapusan data harus reasonable\n")
cat("3. TRANSPARANSI: Laporkan semua transformasi dalam paper\n")
cat("4. VALIDASI: Cek apakah preprocessing tidak mengubah kesimpulan\n")
cat("5. REPRODUCIBILITY: Simpan script, bukan hanya data final\n\n")

cat("✓ Preprocessing lengkap!\n")
cat("  Data siap untuk analisis multivariat\n\n")
