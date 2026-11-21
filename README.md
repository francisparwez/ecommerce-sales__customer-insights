# E-Commerce Sales & Customer Insights Dashboard

## Project Overview

This project focuses on analysing e-commerce sales and customer data to identify business trends, evaluate sales performance, understand customer behaviour, and generate actionable business insights.

The project follows an end-to-end data analytics workflow using Python, SQL, and Power BI. The dataset will be used to support sales analysis, product performance analysis, regional comparisons, customer segmentation, and interactive business intelligence reporting.

## Project Objectives

- Assess and prepare the raw e-commerce dataset for analysis.
- Identify and address data quality issues, including missing values, duplicate records, inconsistent values, and invalid data.
- Perform exploratory data analysis to understand sales trends, product performance, and customer behaviour.
- Use SQL to answer business questions and calculate relevant performance metrics.
- Develop an interactive Power BI dashboard to communicate key findings.
- Apply RFM analysis to segment customers based on recency, frequency, and monetary value.
- Present findings and recommendations through clear documentation and reporting.

## Tools & Technologies

- **Python:** Data loading, inspection, quality assessment, cleaning, and exploratory data analysis.
- **Pandas & NumPy:** Data manipulation and numerical analysis.
- **SQL:** Data querying, aggregation, and business analysis.
- **Power BI:** Data modelling, DAX calculations, and interactive dashboard development.
- **Git & GitHub:** Version control and project documentation.

## Project Structure

```text
ecommerce-sales__customer-insights/
├── Dataset
│   ├── Cleaned
│   └── Raw
│       └── ecommerce_sales_customer.csv
├── PowerBI
├── Python
│   ├── 01_data_loading_and_inspection.ipynb
│   ├── 02_data_quality_assessment.ipynb
│   ├── 03_data_cleaning.ipynb
│   └── 04_exploratory_data_analysis.ipynb
├── Reports
├── Screenshots
├── SQL
│   └── ecommerce_analysis.sql
└── README.md
```

## Project Workflow & Implementation

The project will be completed in the following stages:

1. **Data Loading & Inspection — Completed:** Loaded the 50,000-row, 18-column raw CSV dataset into Pandas and inspected its dimensions, columns, data types, sample records, and descriptive statistics. Validated order-level consistency, customer registration dates, duplicate records, and missing-value counts. Confirmed that each order is associated with one customer and one order date. Identified 100 exact duplicate rows and missing values in `Category`, `Region`, `PaymentMethod`, and `ReturnDate`. The raw dataset was retained without performing cleaning.
2. **Data Quality Assessment:** Investigate missing values, duplicate records, inconsistent formatting, invalid values, and potential outliers.
3. **Data Cleaning:** Apply appropriate cleaning and validation steps, preserving the original raw dataset and saving the processed data separately.
4. **Exploratory Data Analysis:** Analyse sales performance, customer purchasing behaviour, product and category trends, and regional performance.
5. **SQL Business Analysis:** Develop SQL queries to investigate business questions and calculate relevant sales and customer metrics.
6. **Power BI Dashboard:** Build an interactive dashboard with key performance indicators, sales analysis, and customer insights.
7. **Customer Segmentation:** Apply RFM analysis to classify customers using recency, frequency, and monetary value.
8. **Reporting & Documentation:** Summarise the analytical findings, business recommendations, and project implementation.

## Project Status

**Status:** Dataset setup, loading, and initial inspection completed.

The raw dataset has been added to the project and inspected using the first Python notebook. Its structure, descriptive statistics, order-level consistency, registration-date chronology, duplicate records, and missing values have been checked. Data quality assessment, cleaning, exploratory analysis, SQL analysis, dashboard development, customer segmentation, and reporting remain pending.

## Disclaimer

This project is intended for educational and portfolio purposes. Dataset characteristics, sources, and any synthetic data usage will be documented as part of the project.
