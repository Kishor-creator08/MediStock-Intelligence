# MediStock Intelligence – Hospital Inventory Analytics

## Project Overview
MediStock Intelligence is a healthcare inventory analytics project designed to analyze medicine stock levels, identify low-stock medicines, monitor expiry risks, and support smarter procurement decisions across multiple hospitals.

## Objectives
- Analyze hospital-wise medicine inventory.
- Identify medicines below their reorder levels.
- Monitor medicines approaching expiry.
- Evaluate supplier delivery performance.
- Estimate procurement quantities and costs.
- Classify inventory risks and support decision-making.

## Tools & Technologies
- MySQL 8.0 – Database management and SQL analysis
- Python 3.14 – Data analysis and database integration
- MySQL Connector – Python–MySQL connectivity
- Matplotlib – Data visualization

## Database Tables
1. Hospitals
2. Medicines
3. Suppliers
4. Inventory

## Key Analysis
- Hospital-wise inventory analysis
- Low-stock identification
- Medicine expiry risk analysis
- Supplier delivery performance
- Inventory cost analysis
- Medicine-wise stock distribution
- Smart reorder and procurement analysis
- Supplier-wise procurement analysis
- Expiry-related financial risk
- Overall inventory risk classification

## Key Findings
- Total inventory records: 12
- Total stock quantity: 1,995 units
- Total inventory value: ₹9,992.50
- Low-stock records: 6
- Total shortage quantity: 300 units
- Expiry warning records: 2
- Estimated procurement requirement: 300 units
- Estimated procurement cost: ₹5,487.50
- Inventory value at expiry risk: ₹2,325

## Visualizations
Three charts were generated using Matplotlib:
1. Hospital-wise Inventory Value
2. Medicine-wise Stock Shortage
3. Medicine-wise Stock Distribution

## Project Structure
```text
MediStock_Intelligence/
│
├── SQL/
│   └── medistock_intelligence.sql
│
├── Python/
│   ├── medistock_analysis.py
│   └── medistock_visualization.py
│
├── Charts/
│   ├── hospital_inventory_value.png
│   ├── low_stock_shortage.png
│   └── medicine_stock_distribution.png
│
└── Documentation/
    └── README.md
```

## Business Value
This project demonstrates how healthcare inventory data can be used to identify stock shortages, monitor expiry exposure, estimate replenishment costs, and support hospital inventory planning.

## Note
This is a portfolio project using sample hospital inventory data. Supplier delivery classifications are based on the sample average delivery days. Expiry-risk values represent estimated inventory value at risk, not confirmed financial losses.