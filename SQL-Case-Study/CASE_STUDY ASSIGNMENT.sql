CREATE DATABASE fibernet_analysis;
USE fibernet_analysis;

--  Monthly Churn Trends Last 6 Months
SELECT YearMonth AS Period,
    COUNT(*) AS Churned_Customers
FROM churn_data
GROUP BY YearMonth
ORDER BY YearMonth DESC
LIMIT 6;

--  Churn Breakdown by Category
SELECT  Churn_Flag AS Category,
    Churn_Sub_Category AS Subcategory,
    COUNT(*) AS Total_Churns,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM churn_data), 2) AS Percentage
FROM churn_data
GROUP BY Churn_Flag, Churn_Sub_Category
ORDER BY Total_Churns DESC;


-- Churn by Sales Acquisition Type
SELECT s.Sales_acquisition_type AS Acquisition_Channel,
    COUNT(*) AS Churned_Customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM churn_data), 2) AS Percentage
FROM churn_data c
INNER JOIN sales_data s ON c.Billing_Account_Id = s.Billing_Account_Id
GROUP BY s.Sales_acquisition_type
ORDER BY Churned_Customers DESC;

-- Churn by Data Usage Tier
SELECT
    CASE 
        WHEN Usage_GB < 50 THEN 'Low (<50GB)'
        WHEN Usage_GB BETWEEN 50 AND 200 THEN 'Medium (50-200GB)'
        ELSE 'High (>200GB)'
    END AS Usage_Tier,
    COUNT(*) AS Churned_Customers,
    AVG(Usage_GB) AS Avg_Usage_GB
FROM churn_data
GROUP BY Usage_Tier
ORDER BY Churned_Customers DESC;

-- Churn by Product Type
SELECT  s.Product AS Service_Type,
    COUNT(*) AS Churned_Customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM churn_data), 2) AS Percentage
FROM churn_data c
INNER JOIN sales_data s ON c.Billing_Account_Id = s.Billing_Account_Id
GROUP BY s.Product
ORDER BY Churned_Customers DESC;

--  Geographic Churn Concentration
SELECT 
    l.Zone,
    l.Region_Name AS Region,
    l.Exchange_Name AS Exchange,
    COUNT(*) AS Churned_Customers
FROM churn_data c
INNER JOIN location_data l ON c.Billing_Account_Id = l.Billing_Account_Id
GROUP BY l.Zone, l.Region_Name, l.Exchange_Name
ORDER BY Churned_Customers DESC
LIMIT 10;

--  Early Churn Analysis
SELECT 
    DATE_FORMAT(s.Sale_Date, '%Y-%m') AS Joining_Month,
    c.Year_Month AS Churn_Month,
    COUNT(*) AS Early_Churn_Cases,
    TIMESTAMPDIFF(MONTH, s.Sale_Date, STR_TO_DATE(CONCAT(c.Year_Month, '-01'), '%Y-%m-%d')) AS Months_Active
FROM churn_data c
INNER JOIN sales_data s ON c.Billing_Account_Id = s.Billing_Account_Id
WHERE c.Churn_Flag = 'Early'
GROUP BY Joining_Month, Churn_Month
ORDER BY Joining_Month, Months_Active;

--  Top Salespersons with Highest Churn
WITH RankedSales AS (
    SELECT 
        l.Region_Name AS Region,
        s.sales_created_by AS Sales_Agent,
        COUNT(*) AS Churned_Accounts,
        ROW_NUMBER() OVER(PARTITION BY l.Region_Name ORDER BY COUNT(*) DESC) AS sales_rank  
    FROM churn_data c
    INNER JOIN sales_data s ON c.Billing_Account_Id = s.Billing_Account_Id
    INNER JOIN location_data l ON c.Billing_Account_Id = l.Billing_Account_Id
    GROUP BY l.Region_Name, s.sales_created_by
)
SELECT 
    Region,
    Sales_Agent,
    Churned_Accounts
FROM RankedSales
WHERE sales_rank <= 2  -- Changed to match the new alias
ORDER BY Region, Churned_Accounts DESC;
SELECT 
    Region,
    Sales_Agent,
    Churned_Accounts
FROM RankedSales
WHERE Rank <=2,
ORDER BY Region, Churned_Accounts DESC;

--  Root Cause of Chur
SELECT 
    Churn_Sub_Category AS Reason,
    COUNT(*) AS Cases,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM churn_data), 2) AS Percentage
FROM churn_data
GROUP BY Churn_Sub_Category
ORDER BY Cases DESC
LIMIT 5;

--  By Product Type (Technology Impact)
SELECT 
    s.Product AS Service_Type,
    COUNT(*) AS Churned_Customers,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM churn_data), 2) AS Percentage
FROM churn_data c
INNER JOIN sales_data s ON c.Billing_Account_Id = s.Billing_Account_Id
GROUP BY s.Product
ORDER BY Churned_Customers DESC;