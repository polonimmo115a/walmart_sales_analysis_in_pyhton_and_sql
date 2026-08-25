# Walmart Revenue Intelligence: Sales & Profitability Analytics

## Project Overview
This project is an end-to-end data analysis solution designed to extract critical business insights from Walmart sales data. We utilize Python for data processing and analysis, SQL for advanced querying, and structured problem-solving techniques to solve key business questions. The project is ideal for data analysts looking to develop skills in data manipulation, SQL querying, and data pipeline creation.

This project explores a multi-branch sales dataset to diagnose operational bottlenecks, evaluate product performance, and optimize local marketing strategies across different cities. By converting raw transactional logs into relational business intelligence, this analysis directly supports key stakeholder decisions regarding resource allocation and inventory optimization.


---
## Business Problems

### 1. Customer Behavior & Payment Optimization

### 2. Regional & Branch Performance

### 3. Operational Efficiency & Staff Scheduling

---

## Expected Business Value

### 1. Staff Optimization: Align human resources with high-volume sales windows and busy days.

### 2. Targeted Marketing: Tailor localized promotional campaigns based on regional product category satisfaction.

### 3. Revenue Protection: Diagnose root causes behind underperforming locations flagged by YoY declines.

---

### 📋 Target Business Problems & Strategic Alignment

#### 1. Analyze Payment Methods and Sales
* **Core Question:** What are the different payment methods, and how many transactions and items were sold with each method?
* **Strategic Purpose:** Helps understand customer preferences for payment channels, directly aiding in checkout optimization and digital transaction cost strategies.

#### 2. Identify the Highest-Rated Category in Each Branch
* **Core Question:** Which category received the highest average rating in each branch?
* **Strategic Purpose:** Allows regional management to recognize and promote popular product lines in specific branches, enhancing branch-specific marketing and inventory allocation.

#### 3. Determine the Busiest Day for Each Branch
* **Core Question:** What is the busiest day of the week for each branch based on transaction volume?
* **Strategic Purpose:** Pinpoints operational demand trends to optimize weekly labor scheduling, reduce labor spend overhead, and avoid peak-hour stockouts.

#### 4. Calculate Total Quantity Sold by Payment Method
* **Core Question:** How many items were sold through each payment method?
* **Strategic Purpose:** Measures volume capacity across payment gateways to track shopping bag sizes relative to customer transaction categories.

#### 5. Analyze Category Ratings by City
* **Core Question:** What are the average, minimum, and maximum ratings for each category in each city?
* **Strategic Purpose:** Guides city-level promotions, allowing localized regional supply teams to address product gaps and improve customer experience trends.

#### 6. Calculate Total Profit by Category
* **Core Question:** What is the total profit for each category, ranked from highest to lowest?
* **Strategic Purpose:** Identifies key product lines driving net margins, which helps refine corporate pricing rules and item assortment plans.

#### 7. Determine the Most Common Payment Method per Branch
* **Core Question:** What is the most frequently used payment method in each branch?
* **Strategic Purpose:** Reveals branch-specific customer demographics, allowing individual store operations to streamline hardware placement and digital payment lane setups.

#### 8. Analyze Sales Shifts Throughout the Day
* **Core Question:** How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
* **Strategic Purpose:** Provides operational teams with data to schedule floor staff shifts and plan truck delivery offloading times effectively.

#### 9. Identify Branches with Highest Revenue Decline Year-Over-Year
* **Core Question:** Which branches experienced the largest decrease in revenue compared to the previous year?
* **Strategic Purpose:** Flags underperforming locations suffering from structural or local market pressures, serving as an early-warning signal for corporate turnaround strategies.

---

## 🛠️ Tech Stack & Dependencies
The following core Python libraries and database adapters are required to run this data pipeline:
* **Data Processing & Manipulation:** `pandas` (v2.2.3)
* **Database Object-Relational Mapping:** `SQLAlchemy`
* **MySQL Database Driver Connector:** `pymysql`
* **PostgreSQL Database Driver Connector:** `psycopg2`

---

## 📊 Dataset Schema Blueprint
The final cleaned dataset contains **9,969 verified transaction records** mapped across 12 distinct columns:

| Column Name | Data Type | Description |
| :--- | :--- | :--- |
| `invoice_id` | `int64` | Unique identification number for each retail receipt |
| `branch` | `object` | Designated Walmart branch code (e.g., `WALM003`) |
| `city` | `object` | The city where the branch location is situated |
| `category` | `object` | Product category department (e.g., `Health and beauty`) |
| `unit_price` | `float64` | The cost per individual item (cleaned decimal values) |
| `quantity` | `float64` | Total number of items purchased |
| `date` | `object` | Calendar date of the store transaction |
| `time` | `object` | Time stamp of the customer checkout window |
| `payment_method`| `object` | Digital/physical checkout channel (`Cash`, `Credit card`, `Ewallet`) |
| `rating` | `float64` | Customer feedback score ranging from 3.0 to 10.0 |
| `profit_margin` | `float64` | Net profit percentage margin on the transaction |
| `total` | `float64` | Engineered feature representing total sale price (`unit_price` × `quantity`) |

---

## 🚀 Step-by-Step Data Pipeline

### Step 1: Initial Discovery & Profiling
* Loaded the raw transaction file using `pd.read_csv('Walmart.csv', encoding_errors='ignore')`.
* Evaluated dimensions via `df.shape`, identifying an initial footprint of **10,051 records and 11 columns**.
* Executed structural inspects with `df.info()` and statistical summaries with `df.describe()` to evaluate data types and find columns containing missing data.

### Step 2: Deduplication
* Checked for absolute row duplicates via `df.duplicated().sum()`, isolating **51 duplicate records**.
* Cleared them using `df.drop_duplicates(inplace=True)` to shrink the data footprint down to **10,000 distinct logs**.

### Step 3: Imputation & Null Value Handling
* Monitored column gaps using `df.isnull().sum()`, which exposed **31 missing data fields** inside both `unit_price` and `quantity`.
* Purged rows containing missing elements using `df.dropna(inplace=True)` to produce a final baseline of **9,969 perfectly populated rows**.

### Step 4: Text Cleaning & Type Casting
* Discovered that `unit_price` was incorrectly categorized as a text string (`object`) because it contained active currency formatting signs (`$`).
* Stripped the dollar signs out of the string data and recast the entire array to decimal floats to allow mathematical processing:
```python
  df['unit_price'] = df['unit_price'].str.replace('$', '').astype(float)
  ```

### Step 5: Feature Engineering
* Generated a brand-new calculation metric column named `total` to represent overall transactional values before taxes are implemented:
  ```python
  df['total'] = df['unit_price'] * df['quantity']
  ```

### Step 6: Text Standardization
* Normalized database structural mapping constraints by rewriting all DataFrame string headers into unified, lowercase formats:
  ```python
  df.columns = df.columns.str.lower()
  ```

  ### Step 7: Exporting Sanity Baselines
* Generated a localized copy of the clean data output using `df.to_csv('walmart_clean_data.csv', index=False)`.

### Step 8: Multi-Engine Database Ingestion
* Programmatically pushed the formatted records directly into live target relational data structures using automated database engines:
  ```python
  # Ingestion into local MySQL instance
  engine_mysql = create_engine("mysql+pymysql://root@localhost:3306/walmart_db")
  df.to_sql(name='walmart', con=engine_mysql, if_exists='append', index=False)

  # Ingestion into local PostgreSQL instance
  engine_psql = create_engine("postgresql+psycopg2://postgres:YOUR_PASSWORD@localhost:5432/walmart_db")
  df.to_sql(name='walmart', con=engine_psql, if_exists='replace', index=False)
  ```
  
### 9. SQL Analysis: Complex Queries and Business Problem Solving
   - **Business Problem-Solving**: Write and execute complex SQL queries to answer critical business questions, such as:
     - Revenue trends across branches and categories.
     - Identifying best-selling product categories.
     - Sales performance by time, city, and payment method.
     - Analyzing peak sales periods and customer buying patterns.
     - Profit margin analysis by branch and category.
     - Branches having high sales but poor customer satisfaction
     - Product categories which is genarating high revenue but low profitability

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

## Business Problem 4: Categorize the sales into three groups Morning,Afternoon and Evening and also find out no of transactions in each shift


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


## Final Business Insights:

- Identified Top 5 branches with the highest revenue decline ratio between 2022 and 2023, helping uncover potential customer retention and operational issues.
- Branches generating revenue above 25,000+ but maintaining customer ratings below 6/10 were categorized as “High Sales – Low Satisfaction”, indicating future risks of customer churn and declining loyalty.
- Product categories generating more than 60,000+ revenue with profit margins below 40% were identified as “Volume Heavy but Profit Light”, highlighting revenue growth without sustainable profitability.
- Categories with profit margins above 60% were classified as High-Margin Categories, showing strong opportunities for strategic promotions and revenue optimization.
- Digital payment methods contributed the highest transaction volumes, showing a clear shift toward cashless purchasing behavior and customer convenience preferences.
- Afternoon and Evening shifts generated the highest number of transactions, indicating peak customer engagement periods and opportunities for staffing optimization.
- Branch-level analysis revealed that customer preferences and top-rated categories varied significantly by city and location, emphasizing the importance of localized inventory and marketing strategies.


## Business Recommendations:

- Improve customer service quality and operational efficiency in low-rated branches to reduce long-term customer dissatisfaction.
- Focus marketing campaigns on high-margin product categories to improve profitability instead of relying only on high-volume sales.
- Optimize staffing and inventory management during peak Afternoon and Evening sales periods.
- Introduce loyalty rewards and digital payment offers to improve customer retention and increase repeat purchases.
- Conduct branch-level root cause analysis for declining revenue branches to identify pricing, inventory, or competition-related issues.
- Reduce excessive discounting in low-profit categories and improve supplier cost optimization strategies.


## Final Conclusion:

The analysis revealed that while several Walmart branches generate strong revenue, profitability and customer satisfaction remain uneven across locations and product categories. By focusing on high-margin categories, improving customer experience in underperforming branches, and optimizing operational efficiency during peak sales periods, the business can significantly improve long-term profitability, customer retention, and sustainable revenue growth.

  

  




