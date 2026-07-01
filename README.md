# Walmart Data Analysis: End-to-End SQL + Python Project P-9

## Project Overview

![Project Pipeline](https://github.com/najirh/Walmart_SQL_Python/blob/main/walmart_project-piplelines.png)


This project is an end-to-end data analysis solution designed to extract critical business insights from Walmart sales data. We utilize Python for data processing and analysis, SQL for advanced querying, and structured problem-solving techniques to solve key business questions. The project is ideal for data analysts looking to develop skills in data manipulation, SQL querying, and data pipeline creation.

---

## Project Steps

### 1. Set Up the Environment
   - **Tools Used**: Visual Studio Code (VS Code), Python, SQL (MySQL and PostgreSQL)
   - **Goal**: Create a structured workspace within VS Code and organize project folders for smooth development and data handling.

### 2. Set Up Kaggle API
   - **API Setup**: Obtain your Kaggle API token from [Kaggle](https://www.kaggle.com/) by navigating to your profile settings and downloading the JSON file.
   - **Configure Kaggle**: 
      - Place the downloaded `kaggle.json` file in your local `.kaggle` folder.
      - Use the command `kaggle datasets download -d <dataset-path>` to pull datasets directly into your project.

### 3. Download Walmart Sales Data
   - **Data Source**: Use the Kaggle API to download the Walmart sales datasets from Kaggle.
   - **Dataset Link**: [Walmart Sales Dataset](https://www.kaggle.com/najir0123/walmart-10k-sales-datasets)
   - **Storage**: Save the data in the `data/` folder for easy reference and access.

### 4. Install Required Libraries and Load Data
   - **Libraries**: Install necessary Python libraries using:
     ```bash
     pip install pandas numpy sqlalchemy mysql-connector-python psycopg2
     ```
   - **Loading Data**: Read the data into a Pandas DataFrame for initial analysis and transformations.

### 5. Explore the Data
   - **Goal**: Conduct an initial data exploration to understand data distribution, check column names, types, and identify potential issues.
   - **Analysis**: Use functions like `.info()`, `.describe()`, and `.head()` to get a quick overview of the data structure and statistics.

### 6. Data Cleaning
   - **Remove Duplicates**: Identify and remove duplicate entries to avoid skewed results.
   - **Handle Missing Values**: Drop rows or columns with missing values if they are insignificant; fill values where essential.
   - **Fix Data Types**: Ensure all columns have consistent data types (e.g., dates as `datetime`, prices as `float`).
   - **Currency Formatting**: Use `.replace()` to handle and format currency values for analysis.
   - **Validation**: Check for any remaining inconsistencies and verify the cleaned data.

### 7. Feature Engineering
   - **Create New Columns**: Calculate the `Total Amount` for each transaction by multiplying `unit_price` by `quantity` and adding this as a new column.
   - **Enhance Dataset**: Adding this calculated field will streamline further SQL analysis and aggregation tasks.

### 8. Load Data into MySQL and PostgreSQL
   - **Set Up Connections**: Connect to MySQL and PostgreSQL using `sqlalchemy` and load the cleaned data into each database.
   - **Table Creation**: Set up tables in both MySQL and PostgreSQL using Python SQLAlchemy to automate table creation and data insertion.
   - **Verification**: Run initial SQL queries to confirm that the data has been loaded accurately.

### 9. SQL Analysis: Complex Queries and Business Problem Solving
   - **Business Problem-Solving**: Write and execute complex SQL queries to answer critical business questions, such as:
     - Revenue trends across branches and categories.
     - Identifying best-selling product categories.
     - Sales performance by time, city, and payment method.
     - Analyzing peak sales periods and customer buying patterns.
     - Profit margin analysis by branch and category.
     - Branches having high sales but poor customer satisfaction
     - Product categories which is genarating high revenue but low profitability
   

## Requirements

- **Python 3.8+**
- **SQL Databases**: MySQL, PostgreSQL
- **Python Libraries**:
  - `pandas`, `numpy`, `sqlalchemy`, `mysql-connector-python`, `psycopg2`
- **Kaggle API Key** (for data downloading)

## Getting Started

1. Clone the repository:
   ```bash
   git clone <repo-url>
   ```
2. Install Python libraries:
   ```bash
   pip install -r requirements.txt
   ```
3. Set up your Kaggle API, download the data, and follow the steps to load and analyze.

---

## Business Problem 1: Which branches have high sales but poor customer satisfaction

```sql

with business_status1 as (
select branch,sum(total_amount) as total_revenue,avg(rating) as avg_rating,
case when sum(total_amount)>25000 and avg(rating)<6 then 'High sales --low satisfaction'
when sum(total_amount) between 10000 and 25000 and avg(rating) between 6 and 8 then 'Medium sales and Medium satisfaction'
when sum(total_amount)>25000 and avg(rating)>8 then 'Strong Performnace'
else 'Need attention'
end as business_status
from walmart_sales
group by 1
order by 1
)
select branch,total_revenue,avg_rating,business_status
from business_status1
where business_status = 'High sales --low satisfaction'
```
**Business Insight:** Certain branches maintain strong short term revenue despite low customer ratings,indicating potential long-term retention risk

**Recommendation:** 

- investigate customer complaints in low-rated branches
- analyze staffing and checkout wait times
- improve inventory availability
- launch customer satisfaction initiatives

## Business Problem 2: Which product category generate high revenue but low profitability

```sql

with category_segmentation1 as(
select category,sum(total_amount) as total_revenue,avg(profit_margin) as avg_profit_margin,
case when sum(total_amount)>60000 and avg(profit_margin)>0.60 then 'High margin category'
when sum(total_amount)>60000 and avg(profit_margin)<0.40 then 'Volume heavy but profit light'
when sum(total_amount) between 40000 and 60000 and avg(profit_margin) between 0.40 and 0.60 then 'revenue driver but weak profitability'
else 'low margin'
end as category_segmentation
from walmart_sales
group by 1
order by 2 desc
) 
select category,total_revenue,avg_profit_margin,category_segmentation
from category_segmentation1
where category_segmentation= 'Volume heavy but profit light'
```

**Business Insight:** Fashion accessories,home & lifestyle and electronics_accessories has the highest revenue but below average margins,indicating potential 
over_discounting or supply chain inefficiencies

**Recommendation:**
- reduce excessive discounting in low margin categories
- re-negotiate supplier pricing
- increase marketing for profitable categories

## Business Problem 3: Identify 5 branch with highest revenue decrease ratio

```sql

with revenue_2022 as (
select branch,sum(total_amount) as total_revenue
from walmart_sales
where extract( year from to_date(date,'dd/mm/yy'))=2022
group by 1
order by 1
),

 revenue_2023 as
(
select branch,sum(total_amount) as total_revenue
from walmart_sales
where extract( year from to_date(date,'dd/mm/yy'))=2023
group by 1
order by 1
)
select ls.branch,ls.total_revenue as last_year_revenue,cs.total_revenue as current_year_revenue,
round((ls.total_revenue-cs.total_revenue)::numeric/ls.total_revenue::numeric*100,2) as rdr
from revenue_2022 ls join revenue_2023 cs on ls.branch=cs.branch
where ls.total_revenue>cs.total_revenue
order by 4 desc
limit 5
```

**Business Insight:** allows the management to pinpoint locations bleeding market share or failing to adapt to local demand

**Recommendation:**
- Regional Pricing & Competitor Audits
- Targeted Inventory Optimization
- Digital Integration & Delivery
- Store-Level Marketing & B2B Partnerships

## Business Problem 4: Categorize the sales into three groups Morning,Afternoon and Evening and also find out no of transactions
in each shift

```sql

select count(*) as no_of_transaction,
case when extract(hour from (time::time))<12 then 'Morning'
     when extract(hour from (time::time)) between 12 and 17 then 'Afternoon'
	 else 'Evening'
	 end as shift
from walmart_sales
group by 2
```

**Business Insight:** allows the management for staffing&resource allocation and inventory&replenishment operations

**Recommendation:**
- **Morning Shift:** Typically sees lighter, convenience-driven traffic (e.g., grocery top-ups, breakfast items).
- Recommendation: Keep staffing lean but ensure fast, express checkout lanes are open. Focus on fresh produce and bakery restocking early.
- **Afternoon Shift:** Often the busiest time for large family trips or weekend shopping.
- Recommendation: Maximize register availability and open all checkout lanes to prevent long wait times. Schedule heavy floor stocking during off-peak windows to avoid aisle congestion.
- **Evening Shift:** High traffic from working professionals grabbing dinner supplies or household essentials.
- Recommendation: Ensure high-demand grab-and-go items, deli sections, and self-checkout areas are fully operational and well-staffed

  

  




