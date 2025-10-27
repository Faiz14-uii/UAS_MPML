# Testing Guide for R Scripts

## Prerequisites

Before running the R scripts, ensure you have:

1. **R installed** (version 4.0.0 or higher recommended)
   - Download from: https://cran.r-project.org/

2. **RStudio installed** (optional but highly recommended)
   - Download from: https://www.rstudio.com/products/rstudio/download/

3. **Required packages installed**
   - See `requirements.txt` for complete list
   - Or run the installation script below

## Quick Installation of All Packages

Open R or RStudio and run:

```r
# Core packages
install.packages(c(
  "tidyverse", "FactoMineR", "factoextra", "cluster", 
  "psych", "car", "corrplot", "GGally", "mvtnorm", 
  "biotools", "heplots", "mice", "VIM", "MVN",
  "NbClust", "dendextend", "plotly", "moments",
  "fossil", "knitr", "rmarkdown"
))

# Verify installation
library(tidyverse)
library(FactoMineR)
library(factoextra)
print("✓ All core packages installed successfully!")
```

## Testing Individual Scripts

### Test 1: Preprocessing Guide

```r
# Run the preprocessing guide
source("00_preprocessing_guide.R")
```

**Expected Output:**
- Summary statistics of the airquality dataset
- Missing value analysis
- Outlier detection (univariate and multivariate)
- Distribution checks
- Visualizations (boxplots, histograms, Q-Q plots)

**Success Criteria:**
- No errors
- Plots are generated
- Console shows step-by-step progress

### Test 2: PCA Analysis

```r
# Run PCA analysis
source("01_pca_analysis.R")
```

**Expected Output:**
- Correlation matrix of iris dataset
- KMO and Bartlett's test results
- Eigenvalues and scree plot
- Biplot showing individuals and variables
- Interpretation of principal components

**Success Criteria:**
- Scree plot shows clear eigenvalue decline
- Biplot separates iris species visually
- PC1 explains > 70% variance

### Test 3: Cluster Analysis

```r
# Run cluster analysis
source("02_cluster_analysis.R")
```

**Expected Output:**
- Dendrogram for hierarchical clustering
- Elbow plot for optimal k
- Cluster visualization
- Cluster profiles
- Silhouette plot for validation

**Success Criteria:**
- Dendrogram shows clear hierarchical structure
- Optimal k is identified (should be around 2-4)
- Silhouette width > 0.5

### Test 4: MANOVA

```r
# Run MANOVA analysis
source("03_manova_analysis.R")
```

**Expected Output:**
- Box's M test for homogeneity
- MANOVA results (Wilks' Lambda)
- Follow-up univariate ANOVA
- HE plots and canonical discriminant plots
- Effect sizes

**Success Criteria:**
- Wilks' Lambda is significant (p < 0.001)
- Effect size (η²) is substantial
- Follow-up ANOVAs show which variables contribute

### Test 5: Complete Workflow

```r
# Run complete workflow example
source("04_complete_workflow_example.R")
```

**Expected Output:**
- All steps from exploration to conclusions
- Multiple visualizations
- Integration of PCA, clustering, and MANOVA
- Synthesis of findings
- Practical recommendations

**Success Criteria:**
- All analyses run without errors
- Results are consistent across methods
- Clear narrative from start to finish

## Troubleshooting

### Problem: "Package not found"

**Solution:**
```r
# Install the missing package
install.packages("package_name")
```

### Problem: "Object not found"

**Solution:**
- Make sure to run scripts in order (00 → 04)
- Some scripts use built-in datasets
- Restart R session if needed

### Problem: "Cannot open connection"

**Solution:**
- Set working directory to script location
```r
setwd("path/to/UAS_MPML")
```

### Problem: Plots not showing

**Solution in RStudio:**
- Check Plots pane (bottom-right)
- Use `dev.off()` to reset graphics device
- Increase plot window size

**Solution in R console:**
```r
# Use X11 or appropriate device
X11()  # Linux
quartz()  # Mac
windows()  # Windows
```

### Problem: Out of memory

**Solution:**
```r
# Increase memory limit (Windows)
memory.limit(size = 8000)

# Clear workspace
rm(list = ls())
gc()
```

## Running Tests Systematically

Create a test script `run_all_tests.R`:

```r
# ============================================
# Systematic Testing of All Scripts
# ============================================

cat("\n╔══════════════════════════════════════════╗\n")
cat("║  Testing All Multivariate Analysis Scripts  ║\n")
cat("╚══════════════════════════════════════════╝\n\n")

# Test 1: Preprocessing
cat("Test 1: Preprocessing Guide...\n")
tryCatch({
  source("00_preprocessing_guide.R")
  cat("✓ Test 1 PASSED\n\n")
}, error = function(e) {
  cat("✗ Test 1 FAILED:", conditionMessage(e), "\n\n")
})

# Clear workspace between tests
rm(list = ls()[!ls() %in% c("original_objects")])

# Test 2: PCA
cat("Test 2: PCA Analysis...\n")
tryCatch({
  source("01_pca_analysis.R")
  cat("✓ Test 2 PASSED\n\n")
}, error = function(e) {
  cat("✗ Test 2 FAILED:", conditionMessage(e), "\n\n")
})

rm(list = ls()[!ls() %in% c("original_objects")])

# Test 3: Cluster
cat("Test 3: Cluster Analysis...\n")
tryCatch({
  source("02_cluster_analysis.R")
  cat("✓ Test 3 PASSED\n\n")
}, error = function(e) {
  cat("✗ Test 3 FAILED:", conditionMessage(e), "\n\n")
})

rm(list = ls()[!ls() %in% c("original_objects")])

# Test 4: MANOVA
cat("Test 4: MANOVA...\n")
tryCatch({
  source("03_manova_analysis.R")
  cat("✓ Test 4 PASSED\n\n")
}, error = function(e) {
  cat("✗ Test 4 FAILED:", conditionMessage(e), "\n\n")
})

rm(list = ls()[!ls() %in% c("original_objects")])

# Test 5: Complete Workflow
cat("Test 5: Complete Workflow...\n")
tryCatch({
  source("04_complete_workflow_example.R")
  cat("✓ Test 5 PASSED\n\n")
}, error = function(e) {
  cat("✗ Test 5 FAILED:", conditionMessage(e), "\n\n")
})

cat("\n╔══════════════════════════════════════════╗\n")
cat("║  All Tests Completed!                   ║\n")
cat("╚══════════════════════════════════════════╝\n\n")
```

Then run:
```r
source("run_all_tests.R")
```

## Validation Checklist

After running all scripts, verify:

- [ ] All scripts run without errors
- [ ] Visualizations are generated correctly
- [ ] Statistical outputs match expected ranges
- [ ] Interpretations are displayed
- [ ] No warning messages about critical issues
- [ ] Memory usage is acceptable
- [ ] Execution time is reasonable (< 5 min per script)

## Performance Benchmarks

Expected execution times (on modern laptop):

| Script | Expected Time |
|--------|---------------|
| 00_preprocessing_guide.R | 30-60 seconds |
| 01_pca_analysis.R | 20-40 seconds |
| 02_cluster_analysis.R | 45-90 seconds |
| 03_manova_analysis.R | 30-60 seconds |
| 04_complete_workflow_example.R | 60-120 seconds |

**Total:** ~3-6 minutes for all scripts

## Next Steps After Testing

1. **Modify with Your Data:**
   ```r
   # Load your own dataset
   my_data <- read.csv("your_data.csv")
   
   # Follow the same workflow patterns
   # Adapt variable names and parameters
   ```

2. **Create Reports:**
   ```r
   # Use knitr to create HTML/PDF reports
   library(knitr)
   knitr::spin("01_pca_analysis.R", format = "Rmd")
   rmarkdown::render("01_pca_analysis.Rmd")
   ```

3. **Experiment:**
   - Change parameters (number of clusters, PCs to retain)
   - Try different datasets
   - Add additional visualizations
   - Combine methods in new ways

## Getting Help

If you encounter issues:

1. Check R documentation: `?function_name`
2. Read package vignettes: `vignette("package_name")`
3. Search online: [Stack Overflow](https://stackoverflow.com/questions/tagged/r)
4. Consult textbooks in README.md references
5. Open an issue in this repository

---

**Happy Testing! 🎓**
