# Olist-Revenue-Analysis
Revenue analysis on olist e-commerce dataset (PostgreSQL + Power BI + python)
## Pareto analysis (80/20)
Question: Which product categories bring 80% of total revenue?

**Key Findings:** 17 out of 74 Categories Bring ~80 % of total revenue.

**Methodology:** 
 -Aggregating revenue by product category (SUM)
 -Sorting categories by revenue (ORDER BY)
 -Calculating cumulative revenue using window functions (SUM() OVER)
 -Calculating cumulative revenue percentage to identify the categories contributing to approximately 80% of total revenue
**Scope:**
- Delivered orders only, 2017-2018 (2016 excluded as only 4 months data are available)
- Revenue = item price, freight cost is excluded.
  
**Files:**
  - `pareto_analysis.sql`: the full postgreSQL query
  - `pareto_chart.png`: Pareto chart in  Power BI
  ## Upcoming
  - Price-Volume-Mix analysis
  - Full Power BI dashboard
  
 **Tools:** Python (only for data cleaning), PostgreSQL, Power BI
