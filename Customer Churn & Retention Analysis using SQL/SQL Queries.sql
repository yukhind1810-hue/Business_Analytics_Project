CREATE TABLE customers (
    RowNumber INTEGER,
    CustomerId BIGINT,
    Surname VARCHAR(50),
    CreditScore INTEGER,
    Geography VARCHAR(20),
    Gender VARCHAR(10),
    Age INTEGER,
    Tenure INTEGER,
    Balance NUMERIC(12,2),
    NumOfProducts INTEGER,
    HasCrCard BOOLEAN,
    IsActiveMember BOOLEAN,
    EstimatedSalary NUMERIC(12,2),
    Exited BOOLEAN
);

-- Importing table in SQL
COPY customers
FROM 'C:\temp\Bank_Churn_Dataset.csv'
DELIMITER ','
CSV HEADER;

-- Understanding the table
Select count(*) from customers;

Select * from customers;

-- Count of churned customers
Select Count(exited) as Churned_Customers 
From Customers 
Where exited = 'True';

-- Count of Reatined Customers
Select Count(exited) as Retained_Customers
From Customers 
Where exited = 'False';

-- Count of Active but Churned Customers
Select count(exited) as Active_Churned_Customers
From Customers
Where exited = 'True' and isactivemember = 'True'
Group by isactivemember;

--Count of Inactive but Retained Customers
Select count(exited) as Inactive_Restained_Customers
From Customers
Where exited = 'False' and isactivemember = 'False'
Group by isactivemember;

--Count of Active and Retained Customers
Select count(exited) as Active_Retained_Customers
From Customers
Where exited = 'False' and isactivemember = 'True';

--Count of Inactive and Churned Customers
Select count(exited) as Inactive_Churned_Customers
From Customers
Where exited = 'True' and isactivemember = 'False';

-- Identify zero-balance customers who are inactive but retained
Select count(exited) as inactive_retained_zero_balance_count
From Customers
where exited = 'False' and isactivemember = 'False' and balance <= 0;

-- Identify zero-balance customers who are active but churned
Select count(exited) as active_churned_zero_balance_count
From Customers
where exited = 'True' and isactivemember = 'True' and balance <= 0;

-- Identify gender of customers who are inactive but retained
Select gender, count(exited) as gender_customer_count
From Customers
where exited = 'False' and isactivemember = 'False'
group by gender;

-- Identify gender of customers who are active but churned
Select gender, count(exited) as gender_customer_count
From Customers
where exited = 'True' and isactivemember = 'True'
group by gender;

-- Identify credit score of customers who are inactive but retained
Select count(exited) as low_credit_score_customer_count
From Customers
where exited = 'False' and isactivemember = 'False' and creditscore < 450;

-- Identify credit score of customers who are active but churned
Select count(exited) as low_credit_score_customer_count
From Customers
where exited = 'True' and isactivemember = 'True' and creditscore < 450;

-- Identify age group of customers who are inactive but retained
Select
	Case
		When age <= 30 Then 'Under 30'
		When age <= 50 Then 'Under 50'
		Else 'Above 50'
	End as age_group,
	count(exited) as customer_count
From Customers
Where exited = 'False'
	and isactivemember = 'False'
Group by age_group;

-- Identify age group of customers who are active but churned
Select
	Case
		When age <= 30 Then 'Under 30'
		When age <= 50 Then 'Under 50'
		Else 'Above 50'
	End as age_group,
	count(exited) as customer_count
From Customers
Where exited = 'True'
	and isactivemember = 'True'
Group by age_group;

-- Identify age group of customers who are inactive but retained
Select
	Case
		When tenure < 5 then 'Under 5'
		When tenure < 10 then '5-10'
		Else 'Above 10'
	End as tenure_group,
	count(exited) as customer_count
From Customers
Where exited = 'False'
	and isactivemember = 'False'
Group by tenure_group;

-- Identify age group of customers who are active but churned
Select
	Case
		When tenure < 5 then 'Under 5'
		When tenure < 10 then '5-10'
		Else 'Above 10'
	End as tenure_group,
	count(exited) as customer_count
From Customers
Where exited = 'True'
	and isactivemember = 'True'
Group by tenure_group;

-- Average account balance across all customers
Select ROUND(AVG(Balance), 2) from Customers;

-- Median balance using percentile function
Select ROUND(Percentile_Cont(0.5) WITHIN GROUP (ORDER BY Balance) :: numeric, 2) from Customers;

-- Maximum balance
Select MAX(Balance) from Customers;

-- Minimum balance
Select MIN(Balance) from Customers;

-- Average credit score across customers
Select ROUND(AVG(Creditscore), 2) from Customers;

-- Median credit score
Select ROUND(Percentile_Cont(0.5) WITHIN GROUP (ORDER BY Creditscore) :: numeric, 2) from Customers;

-- Maximum credit score
Select MAX(Creditscore) from Customers;

-- Minimum credit score
Select MIN(Creditscore) from Customers;

-- Identify top 5 active customers who churned despite engagement
SELECT
    CustomerId,
    CreditScore,
    Age,
    Tenure,
    Balance,
    NumOfProducts,
    IsActiveMember,
    Exited
FROM (
    SELECT
        CustomerId,
        CreditScore,
        Age,
        Tenure,
        Balance,
        NumOfProducts,
        IsActiveMember,
        Exited,
        ROW_NUMBER() OVER (ORDER BY Balance DESC) AS Ranked
    FROM Customers
    WHERE Exited = 'True'
      AND IsActiveMember = 'True'
) ranked_customers
WHERE Ranked <= 5;

-- High-value active customers who churned
SELECT
    CustomerId,
    CreditScore,
    Age,
    Tenure,
    Balance,
    NumOfProducts,
    IsActiveMember,
    Exited
FROM (
    SELECT
        CustomerId,
        CreditScore,
        Age,
        Tenure,
        Balance,
        NumOfProducts,
        IsActiveMember,
        Exited,
        ROW_NUMBER() OVER (ORDER BY Balance DESC) AS Ranked
    FROM Customers
    WHERE Exited = 'True'
      AND IsActiveMember = 'True'
      AND NumOfProducts > 2
      AND Tenure BETWEEN 5 AND 10
) ranked_customers
WHERE Ranked <= 5;

-- Top inactive but retained customers with high balances
SELECT
    CustomerId,
    CreditScore,
    Age,
    Tenure,
    Balance,
    NumOfProducts,
    IsActiveMember,
    Exited
FROM (
    SELECT
        CustomerId,
        CreditScore,
        Age,
        Tenure,
        Balance,
        NumOfProducts,
        IsActiveMember,
        Exited,
        ROW_NUMBER() OVER (ORDER BY Balance DESC) AS Ranked
    FROM Customers
    WHERE Exited = 'False'
      AND IsActiveMember = 'False'
) ranked_customers
WHERE Ranked <= 5;