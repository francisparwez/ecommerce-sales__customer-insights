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
│   │   └── ecommerce_sales_customer_cleaned.csv
│   └── Raw
│       └── ecommerce_sales_customer.csv
├── PowerBI
├── Python
│   ├── 01_data_loading_and_inspection.ipynb
│   ├── 02_data_quality_assessment.ipynb
│   └── 03_data_cleaning.ipynb
├── Reports
├── Screenshots
├── SQL
└── README.md
```

## Project Workflow & Implementation

The project will be completed in the following stages:

1. **Data Loading & Inspection — Completed:** Loaded the 50,000-row, 18-column raw CSV dataset into Pandas and inspected its dimensions, columns, data types, sample records, and descriptive statistics. Validated order-level consistency and customer registration-date chronology. Identified 100 exact duplicate occurrences and missing values in `Category`, `Region`, `PaymentMethod`, and `ReturnDate`. Confirmed that each order is associated with one customer and one order date. The raw dataset was retained without cleaning.
2. **Data Quality Assessment — Assessment performed:** Used Pandas and NumPy to assess missing values and percentages, exact duplicates, categorical formatting, numerical validity, date consistency, financial calculation relationships, and potential statistical outliers using the IQR method. Findings include 90 missing `Category` values, 80 missing `Region` values, 79 missing `PaymentMethod` values, and 46,810 missing `ReturnDate` values (consistent with non-returned orders); 100 exact duplicate occurrences; 28 `Category` text variations representing 7 logical categories; 10 negative `UnitPrice` values; 15 zero `Quantity` values; and 12 `DiscountPct` values above 100%. Date logic and the three financial calculation checks passed with no mismatches. IQR analysis identified potential outliers in several numerical columns; all 1,588 `UnitPrice` outliers were associated with Smart Watch transactions. The assessment was performed without modifying the raw dataset.
3. **Data Cleaning — Completed:** Created a working copy of the raw dataset and preserved the original file. Removed 100 exact duplicate records; standardised `Category` text and recovered missing categories using the validated `ProductID`-to-category relationship; recovered missing `Region` values using the validated `Country`-to-region relationship; and labelled missing `PaymentMethod` values as `Unknown`. Replaced 10 negative `UnitPrice` values with the median valid price for the corresponding product, removed 15 records with zero `Quantity`, and capped 12 discounts above 100% at 100%. Recalculated `GrossSales`, `DiscountAmount`, and `NetSales`, converted the date columns to datetime, and validated the cleaned data. The resulting dataset contains 49,885 rows and 18 columns, with no duplicate records or invalid values in the checks performed. Missing `ReturnDate` values were retained because they are expected for non-returned orders. Exported the cleaned dataset to `Dataset/Cleaned/ecommerce_sales_customer_cleaned.csv`.
4. **Exploratory Data Analysis:** Analyse sales performance, customer purchasing behaviour, product and category trends, and regional performance.
5. **SQL Business Analysis:** Develop SQL queries to investigate business questions and calculate relevant sales and customer metrics.
6. **Power BI Dashboard:** Build an interactive dashboard with key performance indicators, sales analysis, and customer insights.
7. **Customer Segmentation:** Apply RFM analysis to classify customers using recency, frequency, and monetary value.
8. **Reporting & Documentation:** Summarise the analytical findings, business recommendations, and project implementation.

## Project Status

**Status:** Data loading and inspection completed; data quality assessment performed; data cleaning completed.

The raw dataset remains unchanged. The first Python notebook covers data loading, structural inspection, and initial validation. The second notebook assesses missing values, duplicates, categorical inconsistencies, numerical validity, date logic, financial calculation consistency, and potential statistical outliers. The third notebook performs the cleaning operations, validates the resulting dataset, and exports the cleaned CSV to `Dataset/Cleaned/`. Exploratory data analysis, SQL business analysis, dashboard development, customer segmentation, and final reporting remain pending.

## Disclaimer

This project is intended for educational and portfolio purposes. Dataset characteristics, sources, and any synthetic data usage will be documented as part of the project.
