# SDS-HM
# HW2-3: Two-Sample Testing with Classifiers

## 📌 Project Overview
This project explores two-sample testing using classification-based approaches. The main objective is to determine whether two distributions are significantly different using hypothesis testing techniques combined with machine learning classifiers.

The study is divided into:
- **Theoretical Derivation of Bayes Classifier** 📚
- **Empirical Evaluation of Classifier Performance** 🧪
- **Monte Carlo Simulations** 🎲
- **Application on Real-World Heart Rate Zone Data** 🏃‍♂️

---
## 📂 Repository Structure
```
hw2-3-two-sample-testing/
│── data/                     # Folder for datasets
│   ├── hw_data.RData         # Provided dataset for HR Zones
│── src/                      # Source code files
│   ├── hw2_3_analysis.Rmd    # Main RMarkdown file
│   ├── hw2_3_analysis.html   # Rendered HTML output
│── results/                  # Results and visualizations
│   ├── plots/                # Folder for generated plots
│   ├── accuracy_results.csv  # Performance results of classifiers
│── README.md                 # Main documentation
│── LICENSE                   # Open-source license (optional)
│── .gitignore                # Ignore unnecessary files (e.g., .Rproj)
```

---
## 🚀 Getting Started
### **Prerequisites**
Ensure you have the following installed:
- **R** (Latest Version) 🔢
- **RStudio** (Recommended) 🖥️
- **Required R Packages**
  ```r
  install.packages(c("ggplot2", "dplyr", "tidyr", "rpart", "rpart.plot", "pROC"))
  ```

### **Running the Analysis**
1. Clone this repository:
   ```sh
   git clone https://github.com/yourusername/hw2-3-two-sample-testing.git
   cd hw2-3-two-sample-testing
   ```
2. Open `hw2_3_analysis.Rmd` in **RStudio**.
3. Run the R Markdown file to generate results:
   ```r
   rmarkdown::render("src/hw2_3_analysis.Rmd")
   ```
4. The results will be available in `results/`.

---
## 📊 Methodology

### **1️⃣ Theoretical Bayes Classifier**
- Derivation of the **Bayes optimal decision rule**.
- Computing probability densities using uniform distributions.
- Establishing the decision boundary analytically.

### **2️⃣ Simulation & Monte Carlo Testing**
- Generating synthetic data for evaluating classifier performance.
- Comparing **Bayes Classifier**, **Logistic Regression**, and **Decision Trees**.
- Conducting **Monte Carlo simulations** to assess accuracy over multiple runs.
- Evaluating model performance using:
  - **Confusion Matrices**
  - **ROC Curves & AUC Scores**
  - **Statistical Significance Tests (t-test, ANOVA)**

### **3️⃣ Application to Heart Rate Zones Data**
- Working with **real-world HR Zones** from running sessions.
- Implementing **Friedman’s two-sample testing procedure**.
- Extracting meaningful **statistical summaries from time-series data**.
- Analyzing whether distributions differ across heart rate zones.

---
## 📈 Results & Findings
- **Monte Carlo simulations** confirmed that classifiers **converge to Bayes’ accuracy** under sufficient data.
- **Logistic Regression provides a smooth decision boundary**, performing robustly under limited data.
- **Decision Trees suffer from overfitting**, leading to lower accuracy and unstable decision boundaries.
- **Friedman’s approach successfully detects differences in HR Zones**, validating the application of two-sample testing in real-world settings.

---
## 📜 License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
## 📧 Contact & Contributions
Feel free to fork the repository, submit PRs, or reach out for collaborations! ✨

