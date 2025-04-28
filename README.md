# UK Government Grantmaking Analysis

Comprehensive data-driven analysis of UK government grant allocations, identifying funding trends, departmental overlaps, and policy impacts through advanced statistical, semantic, and predictive modeling techniques. The project delivers actionable insights into the evolution of UK governmental funding behavior and highlights the societal and economic shifts reflected through grant distribution patterns over nearly three decades.

---

## Project Overview

This project undertakes a detailed examination of publicly available UK government grant data from 1997 to 2024. Utilizing rigorous data engineering, exploratory data analysis, semantic processing, and machine learning, the study addresses key research questions regarding governmental grantmaking strategies and their evolution over time. The work emphasizes the interplay between policy initiatives, economic crises, and resource allocation strategies.

- **Client:** 360Giving
- **University:** Lancaster University - SCC.460 Final Project

---

## Research Objectives

- Investigate thematic and temporal variations in UK government grantmaking.
- Assess the extent of organizational funding overlaps across different departments.
- Evaluate the alignment between government grant allocations and declared policy priorities.
- Quantify the impacts of the COVID-19 pandemic and the Energy Bill Support Scheme on funding distribution.
- Identify inequalities in the distribution of funds across recipient organizations and geographic regions.

---

## Methodological Framework

- **Agile Methodology**: Employed Scrum practices with weekly sprints for iterative development and continuous refinement of research objectives.
- **Data Exploration**: Conducted a comprehensive review, merging disparate datasets to mitigate sparsity and enhance analytical robustness.
- **Data Preprocessing**: Systematic cleaning, normalization, augmentation with demographic and geospatial metadata, and resolution of inconsistencies within the raw data.
- **Exploratory Data Analysis (EDA)**: Applied statistical summarization, feature correlation analysis, and advanced visualization techniques (heatmaps, scatter plots, bar charts).
- **Semantic Analysis**: Applied natural language processing (NLP) to extract and quantify thematic elements from grant descriptions, capturing policy trends and thematic shifts.
- **Predictive Modeling**: Developed and benchmarked LightGBM, XGBoost, ensemble models, and neural networks to model and predict grant award amounts, coupled with hyperparameter optimization.

---

## Principal Findings

- **Temporal Funding Shifts**:
  - Significant escalation in grants during 2020, corresponding to emergency responses to the COVID-19 pandemic.
  - Post-pandemic reallocation toward energy initiatives aligns with strategic government efforts to address energy security and economic recovery.
- **Departmental Funding Overlaps**:
  - Evidence of significant interdepartmental funding coordination targeting municipal authorities and local councils, revealing complex funding networks.
- **Semantic Trends**:
  - Analysis of descriptive terms highlighted critical shifts in governmental priorities, with "lockdown" and "pandemic" prevalent in 2020, transitioning toward "energy" and "relief" in subsequent years.
- **Charity Sector Funding Inequities**:
  - Gini coefficient of 0.886 underscores profound disparities in charity funding distribution; 24.7% of total charity funding was allocated to the top 10 recipients.
- **City-Level Grant Analysis**:
  - While total grant amounts favored major urban centers, several mid-sized cities demonstrated disproportionately high grant-per-capita rates, suggesting targeted local investments.
- **Predictive Model Performance**:
  - Despite LightGBM outperforming other models, prediction error margins remain substantial, reflecting the inherent complexity and noise in grant allocation patterns.

---

## Data Provenance

- UK Cabinet Office Grant Datasets (1997-2024)
- 360Giving Grant Data Standard
- UK Postcode Database
- World Cities Population Dataset

---

## Tools and Technologies

- **Languages**: R, Python
- **Libraries**: tidyverse, spacyr, LightGBM, XGBoost, Leaflet, Scikit-learn
- **Platforms**: GitHub, Trello, RStudio, Jupyter Notebooks
- **Visualization Tools**: Leaflet interactive maps, Seaborn, Matplotlib

---

## Research Team

- Andrejs Sorstkins
- ChingHsuan Chen
- Ryan Alghamdi
- Adam Missen
- Junxian Huang

---

## Acknowledgments

All supporting scripts, datasets, and visualization outputs are available [here](https://github.com/AndreyShor/Grant-Project).

---

## Future Research Directions

- Conduct micro-level analysis focusing on small and private sector grants, identifying hidden patterns within aggregate funding data.
- Explore the dynamics of foreign government investment allocations through dedicated data segmentation and analysis.
- Improve predictive modeling accuracy through advanced feature selection, deep learning models, and time-series analysis to better model grant distribution volatility.
- Extend semantic analysis to longitudinal studies of policy language evolution in grantmaking over successive governmental terms.

---
