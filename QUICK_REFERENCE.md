# Quick Reference: Statistika Multivariat dengan R

## Kapan Menggunakan Metode Apa?

### Decision Tree untuk Memilih Metode

```
Apakah Anda punya...?

├─ BANYAK VARIABEL BERKORELASI
│  └─ Tujuan: Reduksi dimensi
│     ├─ Data numerik → PCA (01_pca_analysis.R)
│     ├─ Data kategorikal → MCA (Multiple Correspondence Analysis)
│     └─ Data mixed → FAMD (Factor Analysis of Mixed Data)
│
├─ INGIN MENEMUKAN KELOMPOK
│  └─ Tujuan: Clustering
│     ├─ Tidak tahu jumlah kelompok → Hierarchical Clustering (02_cluster_analysis.R)
│     ├─ Tahu jumlah kelompok → K-Means (02_cluster_analysis.R)
│     └─ Data besar, outlier banyak → PAM (Partition Around Medoids)
│
├─ PERBANDINGAN KELOMPOK
│  └─ Tujuan: Tes perbedaan
│     ├─ 1 variabel dependen → ANOVA
│     ├─ Multiple variabel dependen → MANOVA (03_manova_analysis.R)
│     └─ Dengan kovariat → MANCOVA
│
├─ KLASIFIKASI/PREDIKSI
│  └─ Tujuan: Assign ke kelompok
│     ├─ Supervised → Discriminant Analysis
│     ├─ Unsupervised → Cluster Analysis
│     └─ Binary outcome → Logistic Regression
│
└─ HUBUNGAN ANTAR SET VARIABEL
   └─ Tujuan: Korelasi kompleks
      ├─ 2 set variabel → Canonical Correlation
      ├─ Model teoritis → SEM (Structural Equation Modeling)
      └─ Prediksi dengan banyak predictor → Multivariate Regression
```

---

## Cheat Sheet Asumsi

| Metode | Asumsi Utama | Test | Robustness |
|--------|--------------|------|------------|
| **PCA** | - Linearitas<br>- Korelasi antar variabel | KMO, Bartlett | Cukup robust |
| **K-Means** | - Cluster spherical<br>- Ukuran seimbang | Silhouette | Sensitif outlier |
| **Hierarchical** | - Jarak meaningful | Cophenetic corr. | Lebih robust |
| **MANOVA** | - Normal multivariat<br>- Homogenitas kovarians<br>- Independensi | Shapiro-Wilk, Box's M | Robust jika n > 20 |
| **Discriminant** | - Normal multivariat<br>- Homogenitas kovarians | Shapiro-Wilk, Box's M | QDA lebih robust |

---

## Kode Cepat (Copy-Paste Ready)

### 1. Load Data & Eksplorasi Cepat

```r
# Import data
df <- read.csv("data.csv")

# Quick look
str(df)
summary(df)
head(df)

# Visualisasi cepat
library(GGally)
ggpairs(df[, 1:5])  # 5 variabel pertama
```

### 2. Cek Missing Values

```r
# Hitung missing
colSums(is.na(df))

# Visualisasi
library(VIM)
aggr(df, numbers = TRUE)

# Impute dengan MICE
library(mice)
imp <- mice(df, m = 5, method = 'pmm', seed = 123)
df_clean <- complete(imp)
```

### 3. Deteksi Outlier

```r
# Outlier univariat (IQR method)
library(tidyverse)
df %>%
  summarise(across(where(is.numeric), 
    ~sum(abs(scale(.)) > 3, na.rm = TRUE)))

# Outlier multivariat (Mahalanobis)
df_numeric <- df %>% select(where(is.numeric))
mahal <- mahalanobis(df_numeric, 
                     colMeans(df_numeric), 
                     cov(df_numeric))
threshold <- qchisq(0.999, df = ncol(df_numeric))
outliers <- which(mahal > threshold)
```

### 4. PCA Quick

```r
library(FactoMineR)
library(factoextra)

# Run PCA
pca <- PCA(df[, numeric_vars], scale.unit = TRUE, graph = FALSE)

# Scree plot
fviz_eig(pca, addlabels = TRUE)

# Biplot
fviz_pca_biplot(pca, repel = TRUE)

# Scores
scores <- pca$ind$coord
```

### 5. Clustering Quick

```r
library(cluster)
library(factoextra)

# Standardize
df_scaled <- scale(df[, numeric_vars])

# Optimal k
fviz_nbclust(df_scaled, kmeans, method = "silhouette")

# K-means
km <- kmeans(df_scaled, centers = 3, nstart = 25)

# Visualize
fviz_cluster(km, data = df_scaled)
```

### 6. MANOVA Quick

```r
library(car)

# Run MANOVA
manova_fit <- manova(cbind(var1, var2, var3) ~ group, data = df)

# Results
summary(manova_fit, test = "Wilks")

# Follow-up ANOVA
summary.aov(manova_fit)
```

---

## Interpretasi Cepat

### Eigenvalues (PCA)
- **> 1**: Komponen penting (Kaiser criterion)
- **Cumulative variance 70-80%**: Cukup untuk kebanyakan aplikasi

### Silhouette Width (Clustering)
- **0.71-1.00**: Strong structure ✓
- **0.51-0.70**: Reasonable structure
- **0.26-0.50**: Weak structure
- **< 0.25**: No structure ✗

### Wilks' Lambda (MANOVA)
- **0**: Perbedaan sempurna
- **1**: Tidak ada perbedaan
- **p < 0.05**: Perbedaan signifikan

### Effect Size (η²)
- **0.01**: Small effect
- **0.06**: Medium effect
- **0.14**: Large effect

### Correlation
- **0.0-0.3**: Weak
- **0.3-0.7**: Moderate
- **0.7-1.0**: Strong

---

## Troubleshooting Cepat

| Problem | Solution |
|---------|----------|
| "Singular matrix" | - Hapus variabel yang perfect correlated<br>- Periksa constant variables<br>- Tambah regularization |
| "Non-positive definite" | - Periksa missing values<br>- Hapus outlier ekstrem<br>- Cek korelasi = 1.0 |
| Clustering tidak bagus | - Coba standardisasi<br>- Hapus outlier<br>- Coba metode berbeda (PAM) |
| MANOVA not significant | - Cek sample size (min 20/group)<br>- Periksa asumsi<br>- Pertimbangkan transformasi |
| Plots tidak muncul | - Cek graphics device<br>- Perbesar plot window<br>- `dev.off()` untuk reset |

---

## Workflow Template

```r
# ===== TEMPLATE ANALISIS MULTIVARIAT =====

# 1. SETUP
library(tidyverse)
library(FactoMineR)
library(factoextra)

# 2. LOAD DATA
df <- read.csv("your_data.csv")

# 3. EKSPLORASI
summary(df)
ggpairs(df)

# 4. PREPROCESSING
# - Handle missing values
# - Detect outliers
# - Transform if needed
# - Standardize

# 5. ANALISIS UTAMA
# - PCA / Clustering / MANOVA
# - Sesuai tujuan penelitian

# 6. VALIDASI
# - Cek asumsi
# - Cross-validation
# - Sensitivity analysis

# 7. INTERPRETASI
# - Effect sizes
# - Visualizations
# - Domain context

# 8. LAPORAN
# - Dokumentasi
# - Reproducible code
# - Clear conclusions
```

---

## Package Essentials

```r
# Install ini dulu (minimal)
install.packages(c(
  "tidyverse",    # Data wrangling
  "FactoMineR",   # PCA, MCA
  "factoextra",   # Visualisasi
  "cluster",      # Clustering
  "car",          # MANOVA
  "corrplot",     # Korelasi
  "psych",        # Deskriptif
  "mice"          # Missing data
))
```

---

## Visualisasi Favorit

```r
# 1. Correlation heatmap
library(corrplot)
corrplot(cor(df), method = "color", type = "upper", 
         order = "hclust", addCoef.col = "black")

# 2. Scatterplot matrix
library(GGally)
ggpairs(df, aes(color = group))

# 3. PCA biplot
fviz_pca_biplot(pca, repel = TRUE, 
                col.var = "contrib",
                gradient.cols = c("blue", "yellow", "red"))

# 4. Cluster dendrogram
fviz_dend(hc, k = 3, rect = TRUE, 
          k_colors = c("red", "blue", "green"))

# 5. Cluster plot
fviz_cluster(km, data = df_scaled, 
             ellipse.type = "convex", 
             star.plot = TRUE)
```

---

## Export Hasil

```r
# Save plots
ggsave("plot.png", width = 10, height = 8, dpi = 300)
pdf("plot.pdf", width = 10, height = 8)

# Save data
write.csv(df_results, "results.csv", row.names = FALSE)
saveRDS(model, "model.rds")

# Create report
library(knitr)
knitr::spin("analysis.R", format = "Rmd")
rmarkdown::render("analysis.Rmd", output_format = "html_document")
```

---

## Resources Cepat

- **Dokumentasi R**: `?function_name` atau `help(package_name)`
- **Vignettes**: `vignette(package = "package_name")`
- **Cheat Sheets**: https://www.rstudio.com/resources/cheatsheets/
- **Quick-R**: https://www.statmethods.net/
- **STHDA**: http://www.sthda.com/english/

---

## Tips Produktivitas

1. **Keyboard Shortcuts (RStudio)**:
   - `Ctrl + Enter`: Run line/selection
   - `Ctrl + Shift + M`: Pipe operator `%>%`
   - `Alt + -`: Assignment `<-`
   - `Ctrl + Shift + C`: Comment/uncomment

2. **Reproducibility**:
   ```r
   set.seed(123)  # Selalu set seed!
   sessionInfo()  # Dokumentasikan environment
   ```

3. **Efficiency**:
   ```r
   # Use pipes
   df %>% filter(x > 10) %>% select(a, b) %>% summarise(mean_a = mean(a))
   
   # Vectorize
   apply(df, 2, mean)  # Lebih cepat dari loop
   ```

---

**Simpan file ini untuk referensi cepat! 📌**
