# Panduan Statistika Multivariat Terapan dengan R

<div align="center">

📊 **Repository Pembelajaran Analisis Multivariat** 📊

*Menjelaskan konsep statistik dengan bahasa mudah dipahami tanpa mengorbankan ketepatan ilmiah*

[![R](https://img.shields.io/badge/R-276DC3?style=for-the-badge&logo=r&logoColor=white)](https://www.r-project.org/)
[![RStudio](https://img.shields.io/badge/RStudio-75AADB?style=for-the-badge&logo=rstudio&logoColor=white)](https://www.rstudio.com/)

</div>

---

## 👋 Selamat Datang!

Repository ini adalah **panduan lengkap** untuk mempelajari dan menerapkan **Statistika Multivariat Terapan** menggunakan R. Dirancang dengan gaya mentoring yang tenang dan jelas, panduan ini membantu Anda memahami konsep, menjalankan analisis, dan menginterpretasi hasil dengan benar.

## 🎯 Untuk Siapa Repository Ini?

- 📚 **Mahasiswa** yang belajar statistika multivariat
- 🔬 **Peneliti** yang perlu analisis data multivariat
- 📊 **Data Analyst** yang ingin memperdalam teknik multivariat
- 👨‍🏫 **Pengajar** yang mencari materi pembelajaran terstruktur

## 🌟 Mengapa Repository Ini?

✅ **Penjelasan Jelas**: Konsep rumit dijelaskan dengan bahasa sederhana  
✅ **Kode Lengkap**: Script R yang bisa langsung dijalankan  
✅ **Best Practices**: Mengikuti standar akademik dan industri  
✅ **Praktis**: Fokus pada penerapan, bukan hanya teori  
✅ **Asumsi & Diagnostik**: Tidak lupa cek asumsi model  
✅ **Interpretasi**: Bukan hanya output, tapi makna praktisnya  

## 📚 Struktur Repository

### 📖 Panduan & Dokumentasi
- **`README_STATS.md`** - Panduan lengkap konsep statistika multivariat
- **`README.md`** - File ini, overview repository

### 💻 Script R (Berurutan untuk Pembelajaran)

| File | Topik | Deskripsi |
|------|-------|-----------|
| `00_preprocessing_guide.R` | **Preprocessing Data** | Persiapan data: missing values, outliers, transformasi |
| `01_pca_analysis.R` | **Principal Component Analysis** | Reduksi dimensi dan eksplorasi struktur data |
| `02_cluster_analysis.R` | **Cluster Analysis** | Hierarchical & K-Means clustering |
| `03_manova_analysis.R` | **MANOVA** | Analisis varians multivariat |
| `04_complete_workflow_example.R` | **Workflow Lengkap** | Studi kasus end-to-end |

## 🚀 Quick Start

### 1. Install R dan RStudio

Jika belum punya:
- Download **R** dari [CRAN](https://cran.r-project.org/)
- Download **RStudio** dari [RStudio.com](https://www.rstudio.com/products/rstudio/download/)

### 2. Install Packages yang Diperlukan

Jalankan di R console:

```r
# Package untuk analisis multivariat
install.packages(c(
  "tidyverse",      # Manipulasi data modern
  "FactoMineR",     # PCA, MCA, analisis multivariat
  "factoextra",     # Visualisasi hasil FactoMineR
  "cluster",        # Cluster analysis
  "psych",          # Analisis psikometrik
  "car",            # Companion to Applied Regression
  "corrplot",       # Visualisasi korelasi
  "GGally",         # Scatterplot matrix
  "mvtnorm",        # Distribusi multivariat
  "biotools",       # Box's M test
  "heplots",        # MANOVA visualization
  "mice",           # Missing data imputation
  "VIM",            # Visualisasi missing data
  "MVN"             # Tes normalitas multivariat
))
```

### 3. Clone atau Download Repository

```bash
git clone https://github.com/Faiz14-uii/UAS_MPML.git
cd UAS_MPML
```

### 4. Mulai Belajar!

Buka file-file R secara berurutan:

```r
# 1. Mulai dengan preprocessing
source("00_preprocessing_guide.R")

# 2. Pelajari PCA
source("01_pca_analysis.R")

# 3. Lanjut cluster analysis
source("02_cluster_analysis.R")

# 4. MANOVA untuk perbandingan kelompok
source("03_manova_analysis.R")

# 5. Lihat workflow lengkap
source("04_complete_workflow_example.R")
```

## 📊 Metode yang Dibahas

### Analisis Eksploratori
- ✅ **PCA (Principal Component Analysis)** - Reduksi dimensi
- ✅ **Cluster Analysis** - Hierarchical & K-Means
- ✅ **Exploratory Data Analysis** - Visualisasi & deskriptif

### Analisis Konfirmatori
- ✅ **MANOVA** - Multivariate Analysis of Variance
- ⏳ **Discriminant Analysis** - Klasifikasi (coming soon)
- ⏳ **Canonical Correlation** - Hubungan antar set variabel (coming soon)

### Diagnostik & Asumsi
- ✅ Normalitas multivariat
- ✅ Homogenitas matriks kovarians
- ✅ Deteksi outlier (Mahalanobis distance)
- ✅ Multikolinearitas
- ✅ Missing data imputation

## 💡 Filosofi Pembelajaran

> *"Statistika bukan tentang angka, tapi tentang cerita yang diceritakan data"*

### Prinsip Panduan Ini:

1. **Pemahaman > Hafalan**: Mengerti "mengapa", bukan hanya "bagaimana"
2. **Praktik > Teori**: Langsung hands-on dengan kode R
3. **Asumsi Matters**: Selalu cek asumsi sebelum analisis
4. **Interpretasi Kontekstual**: Hasil statistik harus meaningful
5. **Kesalahan = Pembelajaran**: Dijelaskan pitfall yang umum

## 🎓 Cara Menggunakan Repository Ini

### Untuk Mahasiswa:
1. Ikuti script secara berurutan (00 → 04)
2. Jalankan kode baris per baris, pahami output
3. Coba modifikasi parameter, lihat efeknya
4. Gunakan dataset Anda sendiri setelah paham

### Untuk Pengajar:
1. Gunakan sebagai supplement materi kuliah
2. Script bisa jadi template tugas/praktikum
3. Modifikasi sesuai kebutuhan kurikulum
4. Encourage students untuk eksplorasi

### Untuk Peneliti:
1. Mulai dari `04_complete_workflow_example.R` untuk overview
2. Gunakan `00_preprocessing_guide.R` untuk data Anda
3. Pilih metode yang sesuai dengan research question
4. Adaptasi script untuk kebutuhan spesifik

## ⚠️ Catatan Penting

### Yang HARUS Diingat:
- 🔴 **Selalu cek asumsi** sebelum interpretasi hasil
- 🔴 **Outlier bisa mengubah kesimpulan** - tangani dengan hati-hati
- 🔴 **Effect size > p-value** - signifikansi statistik ≠ signifikansi praktis
- 🔴 **Garbage in, garbage out** - preprocessing menentukan kualitas analisis
- 🔴 **Dokumentasikan keputusan** - transparansi penting untuk reproducibility

### Yang JANGAN Dilakukan:
- ❌ P-hacking (mencoba berbagai metode sampai dapat p < 0.05)
- ❌ Mengabaikan asumsi yang dilanggar
- ❌ Interpretasi tanpa domain knowledge
- ❌ Copy-paste kode tanpa memahami
- ❌ Menggunakan default setting tanpa justifikasi

## 📖 Referensi & Bacaan Lanjutan

### Textbook Rekomendasi:
1. **Johnson & Wichern** - "Applied Multivariate Statistical Analysis" (klasik!)
2. **Hair et al.** - "Multivariate Data Analysis" (praktis)
3. **Tabachnick & Fidell** - "Using Multivariate Statistics" (detail)
4. **Rencher & Christensen** - "Methods of Multivariate Analysis" (teoritis)

### Resource Online:
- [R Documentation](https://www.rdocumentation.org/)
- [STHDA - Statistical Tools](http://www.sthda.com/english/)
- [Quick-R](https://www.statmethods.net/stats/index.html)
- [UCLA Statistical Consulting](https://stats.oer.ucla.edu/stat/r/)

## 🤝 Kontribusi

Repository ini adalah living document. Kontribusi sangat diterima!

**Cara Berkontribusi:**
1. Fork repository ini
2. Buat branch untuk fitur baru (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

**Yang Bisa Dikontribusikan:**
- Metode analisis baru (FA, SEM, dll)
- Dataset contoh tambahan
- Perbaikan bug atau typo
- Visualisasi lebih baik
- Terjemahan ke bahasa lain

## 📝 Lisensi

Repository ini untuk **tujuan pendidikan dan penelitian**. Silakan gunakan, modifikasi, dan bagikan dengan attribution yang sesuai.

## 👤 Tentang

**Proyek:** UAS - Modern Prediction and Machine Learning  
**Nama:** Ade Ahmad Faizal  
**Institusi:** Universitas Islam Indonesia (UII)

**Dibuat oleh:** Ahli Statistika Multivariat Terapan dengan pengalaman 10+ tahun

---

## 🆘 Butuh Bantuan?

Jika menemui kesulitan:
1. 📖 Baca komentar dalam script dengan teliti
2. 🔍 Cek dokumentasi package terkait
3. 💬 Buka issue di repository ini
4. 📧 Hubungi melalui email (jika tersedia)

---

## ⭐ Jika Repository Ini Membantu

Jangan lupa beri **star** ⭐ untuk mendukung pengembangan lebih lanjut!

---

<div align="center">

**Selamat Belajar dan Semoga Sukses! 🎓**

*"The best way to learn statistics is by doing statistics"*

Made with ❤️ for the R community

</div>