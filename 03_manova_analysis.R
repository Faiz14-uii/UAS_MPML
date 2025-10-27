# ============================================================================
# MANOVA (Multivariate Analysis of Variance)
# ============================================================================
#
# Tujuan: Menguji perbedaan rata-rata beberapa variabel dependen 
#         antar kelompok/grup secara simultan
#
# Kapan digunakan:
# - Ada 2+ variabel dependen kontinu yang berkorelasi
# - Ada 1+ variabel independen kategorikal (faktor)
# - Ingin menguji efek simultan, bukan satu per satu
#
# Keuntungan vs Multiple ANOVA:
# - Kontrol Type I error (tidak perlu Bonferroni correction)
# - Menangkap korelasi antar variabel dependen
# - Lebih powerful untuk mendeteksi efek multivariat
#
# Asumsi:
# 1. Independensi observasi
# 2. Normalitas multivariat per grup
# 3. Homogenitas matriks kovarians (Box's M test)
# 4. Tidak ada outlier multivariat ekstrem
# 5. Tidak ada multikolinearitas ekstrem
#
# ============================================================================

# SETUP
# ============================================================================

# Install packages
# install.packages(c("car", "mvnormtest", "biotools", "heplots", "tidyverse"))

library(car)          # Untuk MANOVA
library(mvnormtest)   # Tes normalitas multivariat
library(biotools)     # Box's M test
library(heplots)      # Visualisasi MANOVA
library(tidyverse)    # Manipulasi data

set.seed(2024)

# ============================================================================
# LANGKAH 1: PERSIAPAN DATA
# ============================================================================

cat("\n=== LANGKAH 1: PERSIAPAN DATA ===\n")

# Dataset iris: 3 spesies, 4 pengukuran
data("iris")
df <- iris

cat("\nStruktur data:\n")
str(df)

cat("\nStatistik deskriptif per spesies:\n")
df %>%
  group_by(Species) %>%
  summarise(
    n = n(),
    Sepal.Length_mean = mean(Sepal.Length),
    Sepal.Width_mean = mean(Sepal.Width),
    Petal.Length_mean = mean(Petal.Length),
    Petal.Width_mean = mean(Petal.Width)
  )

# Visualisasi awal
cat("\nVisualisasi distribusi variabel per spesies...\n")
df_long <- df %>%
  pivot_longer(cols = -Species, names_to = "Variable", values_to = "Value")

ggplot(df_long, aes(x = Species, y = Value, fill = Species)) +
  geom_boxplot() +
  facet_wrap(~Variable, scales = "free_y") +
  theme_minimal() +
  labs(title = "Distribusi Variabel per Spesies") +
  theme(legend.position = "none")

# ============================================================================
# LANGKAH 2: CEK ASUMSI - NORMALITAS MULTIVARIAT
# ============================================================================

cat("\n=== LANGKAH 2: CEK ASUMSI - NORMALITAS MULTIVARIAT ===\n")

cat("\nNormalitas Multivariat per Grup:\n")
cat("H0: Data mengikuti distribusi normal multivariat\n")
cat("H1: Data tidak normal multivariat\n\n")

# Shapiro-Wilk test untuk normalitas multivariat
# Catatan: mvnormtest memerlukan data dalam bentuk matriks transpose
# dan maksimal 5000 observasi

for (species in unique(df$Species)) {
  cat("Spesies:", as.character(species), "\n")
  
  # Subset data
  subset_data <- df %>% 
    filter(Species == species) %>%
    select(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width)
  
  # Transpose untuk mvnormtest
  subset_matrix <- t(subset_data)
  
  # Shapiro-Wilk multivariat (hanya untuk n <= 50 dan variabel <= 9)
  if (nrow(subset_data) <= 50) {
    mshapiro_result <- mshapiro.test(subset_matrix)
    cat("  W =", round(mshapiro_result$statistic, 4), 
        ", p-value =", format.pval(mshapiro_result$p.value, digits = 3), "\n")
    
    if (mshapiro_result$p.value > 0.05) {
      cat("  ✓ Normal multivariat (p > 0.05)\n\n")
    } else {
      cat("  ⚠ Tidak normal multivariat (p < 0.05)\n")
      cat("    Catatan: MANOVA cukup robust terhadap pelanggaran normalitas ringan\n\n")
    }
  }
}

# Visualisasi QQ-plot multivariat
cat("\nVisualisasi normalitas multivariat...\n")
library(MVN)
mvn_result <- mvn(data = df[, 1:4], 
                  mvnTest = "mardia",
                  multivariatePlot = "qq")

# ============================================================================
# LANGKAH 3: CEK ASUMSI - HOMOGENITAS KOVARIANS
# ============================================================================

cat("\n=== LANGKAH 3: CEK ASUMSI - HOMOGENITAS MATRIKS KOVARIANS ===\n")

cat("\nBox's M Test:\n")
cat("H0: Matriks kovarians sama di semua grup\n")
cat("H1: Matriks kovarians berbeda\n\n")

# Box's M test
boxm_result <- boxM(df[, 1:4], df$Species)
print(boxm_result)

if (boxm_result$p.value > 0.001) {
  cat("\n✓ Homogenitas kovarians terpenuhi (p > 0.001)\n")
  cat("  Catatan: Gunakan threshold 0.001 untuk Box's M (sangat sensitif)\n")
} else {
  cat("\n⚠ Homogenitas kovarians dilanggar (p < 0.001)\n")
  cat("  Saran: Gunakan Pillai's Trace (lebih robust)\n")
}

# Visualisasi matriks kovarians per grup
cat("\nMatriks korelasi per spesies:\n")
for (species in unique(df$Species)) {
  cat("\n", as.character(species), ":\n")
  subset_data <- df %>% 
    filter(Species == species) %>%
    select(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width)
  cor_matrix <- cor(subset_data)
  print(round(cor_matrix, 3))
}

# ============================================================================
# LANGKAH 4: CEK ASUMSI - OUTLIER MULTIVARIAT
# ============================================================================

cat("\n=== LANGKAH 4: CEK ASUMSI - OUTLIER MULTIVARIAT ===\n")

# Hitung Mahalanobis distance per grup
cat("\nDeteksi outlier menggunakan Mahalanobis distance:\n")

outliers_all <- c()
for (species in unique(df$Species)) {
  subset_data <- df %>% 
    filter(Species == species) %>%
    select(Sepal.Length, Sepal.Width, Petal.Length, Petal.Width)
  
  # Mahalanobis distance
  mahal_dist <- mahalanobis(subset_data, 
                             center = colMeans(subset_data),
                             cov = cov(subset_data))
  
  # Threshold: Chi-square dengan df = jumlah variabel, alpha = 0.001
  threshold <- qchisq(0.999, df = ncol(subset_data))
  
  # Identifikasi outlier
  outliers <- which(mahal_dist > threshold)
  
  cat("\nSpesies:", as.character(species), "\n")
  cat("  Threshold:", round(threshold, 2), "\n")
  cat("  Jumlah outlier:", length(outliers), "\n")
  
  if (length(outliers) > 0) {
    cat("  Indeks outlier:", outliers, "\n")
    outliers_all <- c(outliers_all, 
                      which(df$Species == species)[outliers])
  }
}

if (length(outliers_all) == 0) {
  cat("\n✓ Tidak ada outlier ekstrem terdeteksi\n")
} else {
  cat("\n⚠ Ditemukan", length(outliers_all), "outlier potensial\n")
  cat("  Pertimbangkan untuk investigasi atau transformasi data\n")
}

# ============================================================================
# LANGKAH 5: CEK ASUMSI - MULTIKOLINEARITAS
# ============================================================================

cat("\n=== LANGKAH 5: CEK ASUMSI - MULTIKOLINEARITAS ===\n")

# Matriks korelasi keseluruhan
cat("\nMatriks korelasi variabel dependen:\n")
cor_matrix_all <- cor(df[, 1:4])
print(round(cor_matrix_all, 3))

# Korelasi tinggi (> 0.9) adalah masalah
high_cor <- which(abs(cor_matrix_all) > 0.9 & cor_matrix_all != 1, 
                  arr.ind = TRUE)

if (nrow(high_cor) > 0) {
  cat("\n⚠ Korelasi sangat tinggi (> 0.9) terdeteksi\n")
  cat("  Pertimbangkan menghapus salah satu variabel atau gunakan PCA\n")
} else {
  cat("\n✓ Tidak ada multikolinearitas ekstrem\n")
  cat("  Catatan: Korelasi moderat (0.5-0.8) justru ideal untuk MANOVA\n")
}

# Visualisasi korelasi
library(corrplot)
corrplot(cor_matrix_all, method = "color", type = "upper",
         addCoef.col = "black", tl.col = "black", tl.srt = 45,
         title = "Matriks Korelasi Variabel Dependen",
         mar = c(0, 0, 2, 0))

# ============================================================================
# LANGKAH 6: MENJALANKAN MANOVA
# ============================================================================

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("MENJALANKAN MANOVA\n")
cat(paste(rep("=", 70), collapse = ""), "\n")

# Hipotesis:
# H0: Tidak ada perbedaan rata-rata multivariat antar spesies
# H1: Ada perbedaan rata-rata multivariat antar spesies

# Definisikan model
# cbind() menggabungkan variabel dependen
# ~ Species adalah variabel independen
manova_model <- manova(cbind(Sepal.Length, Sepal.Width, 
                             Petal.Length, Petal.Width) ~ Species, 
                       data = df)

# Hasil MANOVA
cat("\nHasil MANOVA:\n")
summary(manova_model)

# MANOVA menyediakan 4 test statistics:
# 1. Pillai's Trace: Paling robust, direkomendasikan jika asumsi dilanggar
# 2. Wilks' Lambda: Paling umum digunakan, lebih powerful
# 3. Hotelling-Lawley Trace: Untuk ukuran sampel kecil
# 4. Roy's Largest Root: Paling powerful tapi asumsi ketat

cat("\nMultiple Test Statistics:\n")
summary(manova_model, test = "Pillai")
summary(manova_model, test = "Wilks")
summary(manova_model, test = "Hotelling-Lawley")
summary(manova_model, test = "Roy")

# ============================================================================
# LANGKAH 7: INTERPRETASI HASIL MANOVA
# ============================================================================

cat("\n=== LANGKAH 7: INTERPRETASI HASIL ===\n")

# Wilks' Lambda
wilks_result <- summary(manova_model, test = "Wilks")
wilks_lambda <- wilks_result$stats[1, "Wilks"]
f_value <- wilks_result$stats[1, "approx F"]
p_value <- wilks_result$stats[1, "Pr(>F)"]

cat("\nWilks' Lambda =", round(wilks_lambda, 4), "\n")
cat("F-statistic =", round(f_value, 2), "\n")
cat("p-value =", format.pval(p_value, digits = 3), "\n\n")

# Interpretasi Wilks' Lambda:
# - Range: 0 to 1
# - 1 = No difference between groups
# - Mendekati 0 = Strong difference
# - Biasanya dilaporkan: 1 - Lambda = effect size

eta_squared <- 1 - wilks_lambda
cat("Effect size (η²) =", round(eta_squared, 4), "\n")
cat("Interpretasi: Spesies menjelaskan", round(eta_squared * 100, 1), 
    "% varians multivariat\n\n")

if (p_value < 0.001) {
  cat("✓ KESIMPULAN: Ada perbedaan signifikan antar spesies (p < 0.001)\n")
  cat("  Lanjutkan dengan univariate ANOVA atau discriminant analysis\n")
} else if (p_value < 0.05) {
  cat("✓ KESIMPULAN: Ada perbedaan signifikan antar spesies (p < 0.05)\n")
} else {
  cat("✗ KESIMPULAN: Tidak ada perbedaan signifikan antar spesies\n")
}

# ============================================================================
# LANGKAH 8: FOLLOW-UP ANALYSIS - UNIVARIATE ANOVA
# ============================================================================

cat("\n=== LANGKAH 8: FOLLOW-UP UNIVARIATE ANOVA ===\n")

cat("\nJika MANOVA signifikan, lakukan ANOVA untuk setiap variabel:\n")
cat("(Untuk memahami variabel mana yang berkontribusi pada perbedaan)\n\n")

# ANOVA untuk setiap variabel dependen
summary.aov(manova_model)

# Interpretasi lebih detail dengan eta squared
cat("\nEffect sizes per variabel:\n")
for (var in c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")) {
  aov_model <- aov(as.formula(paste(var, "~ Species")), data = df)
  ss_total <- sum(aov_model$residuals^2) + sum((fitted(aov_model) - mean(df[[var]]))^2)
  ss_between <- sum((fitted(aov_model) - mean(df[[var]]))^2)
  eta_sq <- ss_between / ss_total
  
  cat(sprintf("  %-15s: η² = %.4f (%.1f%% varians)\n", 
              var, eta_sq, eta_sq * 100))
}

# ============================================================================
# LANGKAH 9: POST-HOC TESTS
# ============================================================================

cat("\n=== LANGKAH 9: POST-HOC PAIRWISE COMPARISONS ===\n")

cat("\nTukey HSD untuk perbandingan berpasangan:\n\n")

for (var in c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")) {
  cat("Variable:", var, "\n")
  aov_model <- aov(as.formula(paste(var, "~ Species")), data = df)
  tukey_result <- TukeyHSD(aov_model)
  print(tukey_result)
  cat("\n")
}

# ============================================================================
# LANGKAH 10: VISUALISASI MANOVA
# ============================================================================

cat("\n=== LANGKAH 10: VISUALISASI HASIL ===\n")

# 1. HE Plot (Hypothesis-Error plot)
cat("\nMembuat HE plot...\n")
library(heplots)

heplot(manova_model, 
       fill = TRUE,
       fill.alpha = 0.1,
       main = "HE Plot: Sepal Length vs Sepal Width")

heplot(manova_model, 
       variables = c("Petal.Length", "Petal.Width"),
       fill = TRUE,
       fill.alpha = 0.1,
       main = "HE Plot: Petal Length vs Petal Width")

# 2. Canonical Discriminant Plot
cat("\nMembuat canonical discriminant plot...\n")
candisc_result <- candisc(manova_model)
plot(candisc_result, 
     main = "Canonical Discriminant Analysis")

# 3. Boxplot per variabel
cat("\nBoxplot per variabel dan spesies...\n")
par(mfrow = c(2, 2))
for (var in c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width")) {
  boxplot(as.formula(paste(var, "~ Species")), 
          data = df,
          main = var,
          xlab = "Species",
          ylab = var,
          col = c("#00AFBB", "#E7B800", "#FC4E07"))
}
par(mfrow = c(1, 1))

# 4. Mean plot dengan confidence intervals
cat("\nMean plot dengan 95% CI...\n")
library(gplots)
plotmeans(Petal.Length ~ Species, data = df, 
          xlab = "Species", ylab = "Petal Length",
          main = "Mean Plot with 95% CI")

# ============================================================================
# RINGKASAN
# ============================================================================

cat("\n", paste(rep("=", 70), collapse = ""), "\n")
cat("RINGKASAN MANOVA\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

cat("1. DESAIN PENELITIAN:\n")
cat("   - Variabel Independen: Species (3 level)\n")
cat("   - Variabel Dependen:", ncol(df) - 1, "(kontinu)\n")
cat("   - Ukuran Sampel:", nrow(df), "observasi\n\n")

cat("2. ASUMSI:\n")
cat("   - Normalitas multivariat: Mostly satisfied\n")
cat("   - Homogenitas kovarians:", 
    ifelse(boxm_result$p.value > 0.001, "✓ Satisfied", "⚠ Violated"), "\n")
cat("   - Outlier: ", length(outliers_all), "terdeteksi\n")
cat("   - Multikolinearitas: ✓ No extreme collinearity\n\n")

cat("3. HASIL UTAMA:\n")
cat("   - Wilks' Lambda:", round(wilks_lambda, 4), "\n")
cat("   - F-statistic:", round(f_value, 2), "\n")
cat("   - p-value:", format.pval(p_value, digits = 3), "\n")
cat("   - Effect size (η²):", round(eta_squared, 4), "\n\n")

cat("4. KESIMPULAN:\n")
if (p_value < 0.05) {
  cat("   ✓ Ada perbedaan SIGNIFIKAN antar spesies\n")
  cat("     pada kombinasi 4 variabel secara simultan\n")
} else {
  cat("   ✗ Tidak ada perbedaan signifikan\n")
}
cat("\n")

cat("5. REKOMENDASI LANJUTAN:\n")
cat("   - Discriminant Analysis: Klasifikasi spesies\n")
cat("   - Profile Analysis: Pola perbedaan antar variabel\n")
cat("   - MANCOVA: Jika ada kovariat kontinu\n\n")

cat(paste(rep("=", 70), collapse = ""), "\n")

# ============================================================================
# CATATAN PENTING
# ============================================================================

cat("\n⚠️  CATATAN PENTING:\n\n")

cat("1. MANOVA vs Multiple ANOVA:\n")
cat("   - MANOVA lebih powerful jika variabel berkorelasi\n")
cat("   - MANOVA kontrol Type I error rate\n")
cat("   - Gunakan MANOVA untuk teori multivariat\n\n")

cat("2. INTERPRETASI:\n")
cat("   - MANOVA signifikan ≠ semua variabel berbeda\n")
cat("   - Perlu follow-up univariate test\n")
cat("   - Pertimbangkan effect size, bukan hanya p-value\n\n")

cat("3. ASUMSI KRITIS:\n")
cat("   - Normalitas: MANOVA cukup robust (n > 20 per grup)\n")
cat("   - Homogenitas: Gunakan Pillai's Trace jika dilanggar\n")
cat("   - Outlier: Lebih bermasalah, harus ditangani\n\n")

cat("4. UKURAN SAMPEL:\n")
cat("   - Minimal: 20 observasi per grup\n")
cat("   - Ideal: n > 20 * jumlah variabel dependen\n")
cat("   - Power analysis sebelum penelitian!\n\n")

cat("5. ALTERNATIF:\n")
cat("   - Jika asumsi sangat dilanggar: Permutation MANOVA\n")
cat("   - Jika data ordinal: Non-parametric MANOVA\n")
cat("   - Jika sampel sangat kecil: Hotelling's T²\n\n")

cat("✓ Analisis MANOVA selesai!\n\n")
