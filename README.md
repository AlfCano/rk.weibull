# rk.weibull: Reliability & Life Data Analysis for RKWard

![Version](https://img.shields.io/badge/Version-0.0.1-orange)
![License](https://img.shields.io/badge/License-GPLv3-blue.svg)
![AI Assistance](https://img.shields.io/badge/Created%20with-Gemini-4E86F8)

**rk.weibull** is an external plug-in for [RKWard](https://rkward.kde.org/) that brings industrial-grade Reliability Engineering tools to the RKWard environment. It interfaces with the open-source **`WeibullR`** package to perform Life Data Analysis (Weibull Analysis) and Warranty Prediction, serving as a free alternative to software like ReliaSoft Weibull++ or Minitab's Reliability module.

## Features

### 1. Life Data Analysis (Weibull)
*   **2-Parameter Weibull Fitting:** Fits the Slope ($\beta$) and Characteristic Life ($\eta$) to failure data.
*   **Flexible Data Input:** Handles complete data (failures) and right-censored data (suspensions).
*   **Analysis Methods:**
    *   **Maximum Likelihood Estimation (MLE):** Recommended for larger datasets ($N > 30$). Automatically applies Fisher Matrix confidence bounds.
    *   **Rank Regression (RR):** Standard Least Squares method ($X$ on $Y$ or $Y$ on $X$); automatically applies Pivotal confidence bounds.
*   **Visualization:** Generates standard Weibull Probability Plots (Weibull Canvas) with 95% confidence intervals.

### 2. Warranty Prediction (B-Life)
*   **B-Life Calculation:** Calculates the time by which a specific percentage of units will fail (e.g., $B_{10}$ Life).
*   **Integration:** Directly uses the fitted model objects from the Life Data Analysis component, ensuring consistency between the plot and the prediction.
*   **Robust Parameter Search:** Automatically detects and extracts parameters regardless of `WeibullR`'s internal naming conventions (case-insensitive search for `beta`/`eta` or `shape`/`scale`).

## Dependencies

This plugin relies on the following R packages:
*   `WeibullR`
*   `rkwarddev` (for development/building)

## Installation

### Installing from GitHub (Recommended)
1.  You can install the latest version directly from GitHub using the `devtools` or `remotes` package in R:

```r
library(devtools) # or library(remotes)
install_github("AlfCano/rk.weibull")
```

2.  Restart RKWard.

## Usage Guide

The plugin adds a new entry to the main menu under:
**Analysis > Industrial Stats > Reliability**

### Example: Analyzing Failure Data
**Scenario:** You have tested 50 components. Most failed, but some tests were suspended. You want to determine the $B_{10}$ life (when 10% will fail).

1.  **Generate Data:**
    ```r
    library(WeibullR)
    # Simulate 50 failure times
    times <- rweibull(50, shape=2, scale=100)
    # Status: 1 = Fail, 0 = Censored (Suspended)
    event <- rep(1, 50) 
    ```
2.  **Step 1: Fit the Model**
    *   Navigate to **Analysis > Industrial Stats > Reliability > Life Data Analysis**.
    *   **Time:** Select `times`.
    *   **Event:** Select `event`.
    *   **Method:** Select **Maximum Likelihood (MLE)**.
    *   **Save Weibull Object:** Enter `my_weibull_fit`.
    *   **Submit.**
    *   *Output:* Check the "Parameter Estimates" table ($\beta \approx 2$, $\eta \approx 100$) and the Probability Plot.

3.  **Step 2: Predict Warranty Life**
    *   Navigate to **Analysis > Industrial Stats > Reliability > Warranty Prediction**.
    *   **Fitted Weibull Object:** Select `my_weibull_fit` (from the previous step).
    *   **Probability:** Enter `0.1` (for 10% unreliability).
    *   **Submit.**
    *   *Output:* The "Predicted Life (Time)" value is your $B_{10}$ life.

## Author
**Alfonso Cano**  
Benemérita Universidad Autónoma de Puebla  
License: GPL (>= 3)

---
*This plugin was developed with the assistance of **Gemini**, a large language model by Google.*
