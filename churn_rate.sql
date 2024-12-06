Select * from churn
Select * from customer
select * from payment
select * from services

--Identify the total number of customers and the churn rate
---------------------------------------------------------------------------------
SELECT
    COUNT(*) AS total_customers,
    COUNT(*) FILTER (WHERE customerstatus = 'Churned') AS churned_customers,
   	(COUNT(*) FILTER (WHERE customerstatus = 'Churned')::numeric / COUNT(*)) * 100 AS churn_percentage
FROM
    churn;
---------------------------------------------------------------------------------
-- Find the average age of churned customers
SELECT avg(age)
FROM customer
WHERE customerid in ( SELECT customerid FROM churn WHERE customerstatus = 'Churned'  )
---------------------------------------------------------------------------------
--Discover the most common contract types among churned customers
SELECT contract, count(customerid) as Churned_customers
FROM payment
WHERE customerid in ( SELECT customerid FROM churn WHERE customerstatus = 'Churned'  )
GROUP BY contract 
ORDER BY Churned_customers DESC
---------------------------------------------------------------------------------
--Analyze the distribution of monthly charges among churned customers wrt contract

SELECT contract, avg(monthlycharge)as AVG_Monthly_Charge
FROM payment
WHERE customerid in ( SELECT customerid FROM churn WHERE customerstatus = 'Churned'  )
GROUP BY contract 
ORDER BY AVG_Monthly_Charge DESC
---------------------------------------------------------------------------------
---Create a query to identify the contract types that are most prone to churn
--From Power BI HIghestchurn contract; combining them with reason 

Select a.customerid, sum(a.monthlycharge) as Monthly_Charge, b.churncategory, b.churnreason
from payment as a 
left join churn as b on a.customerid = b.customerid
where a.contract = 'Month-to-Month'
group by a.customerid ,b.churncategory, b.churnreason
order by churncategory = 'None' desc
---------------------------------------------------------------------------------
---Identify customers with high total charges who have churned

SELECT customerid, totalcharges
FROM payment
WHERE customerid in ( SELECT customerid FROM churn WHERE customerstatus = 'Churned'  )
ORDER BY totalcharges desc

---------------------------------------------------------------------------------
---Calculate the total charges distribution for churned and non-churned customers
Select count( distinct a.customerid) as total_users,
		sum(a.totalcharges) as Totalcharges,
		count (*) Filter (where b.customerstatus = 'Churned') as churned_users,
		sum (a.totalcharges) Filter (where b.customerstatus = 'Churned') as churn_users_sum
From payment as a 
Join Churn as b 
on a.customerid = b.customerid
---------------------------------------------------------------------------------
---Calculate the average monthly charges for different contract types among churned customers
select contract, avg(monthlycharge), count( customerid) as churnedcust
from payment
where customerid in (select customerid from churn where customerstatus ='Churned')
Group by contract
order by churnedcust desc
---------------------------------------------------------------------------------
--Identify customers who have both online security and online backup services and churned customers
Select onlinebackup, onlinesecurity,count(customerid)
from services 
where customerid in (select customerid from churn where customerstatus ='Churned') and onlinebackup = 'true' and onlinesecurity = 'true' 
group by onlinebackup, onlinesecurity
---------------------------------------------------------------------------------
-- Identify the average total charges for customers grouped by gender and marital status
Select a.gender,
	   a.married,
	   sum(b.totalcharges :: numeric) as Totalcharges 
From Customer as a 
Join payment as b 
on a.customerid = b.customerid
Group by a.gender,a.married
---------------------------------------------------------------------------------
--Calculate the average monthly charges for different age groups among churned customers
Select  a.age,
		count(a.customerid),
		avg (b.monthlycharge):: int
FROM Customer as a 
Join ( Select customerid, monthlycharge from payment where customerid In (Select customerid from Churn where customerstatus = 'Churned')) as b
on a.customerid = b.customerid
group by a.age 
order by avg (b.monthlycharge) desc
---------------------------------------------------------------------------------
--Calculate the average monthly charges for customers who have multiple lines and streaming TV
select s.multiplelines, s.streamingtv, avg(p.monthlycharge)
from services  as s
join payment  as p 
on s.customerid = p.customerid
where s.multiplelines = 'Yes' and s.streamingtv ='true'
group by s.multiplelines, s.streamingtv
---------------------------------------------------------------------------------
--Identify the customers who have churned and used the most online services
select onlinesecurity,onlinebackup, count(customerid)
From Services
where customerid in ( SELECT customerid FROM churn WHERE customerstatus = 'Churned'  )
	and onlinesecurity = 'true' and onlinebackup ='true'
	group by onlinesecurity,onlinebackup
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
--Create a view to find the customers with the highest monthly charges in each contract type

Create view High_Monthly_Charges As
SELECT customerid, contract, monthlycharge
from payment 
order by monthlycharge desc
 
Select * from High_Monthly_Charges
---------------------------------------------------------------------------------
--Create a view to identify customers who have churned, and the average monthly charges compared to the overall average
***CREATE VIEW churned_customer_avg_charges AS
SELECT
	a.customerid,
	avg(b.monthlycharge) as avg_monthlycharges,
	sum(b.monthlycharge) filter (where a.customerstatus = 'Churned')
FROM churn as a
join payment as b 
on a.customerid = b.customerid
where a.customerstatus = 'Churned'
Group by a.customerid

Select * from churned_customer_avg_charges
drop view churned_customer_avg_charges
---------------------------------------------------------------------------------
--Create a view to find the customers who have churned and their cumulative total charges over time

Create view Churned_cumulative_total_charges_over_time AS
Select a.customerid,
		a.tenureinmonths,
		b.totalcharges
FROM customer a
Join (select customerid, totalcharges from payment where customerid  in (select customerid from churn where customerstatus = 'Churned')) as b 
on a.customerid = b.customerid

Select * from Churned_cumulative_total_charges_over_time
drop view Churned_cumulative_total_charges_over_time

---------------------------------------------------------------------------------
--Stored Procedure to call churned members 

CREATE OR REPLACE PROCEDURE move_churned_employees()
LANGUAGE plpgsql
AS $$
DECLARE
  v_employee_record RECORD;
BEGIN
  -- Create the new table if it doesn't exist
  CREATE TABLE IF NOT EXISTS employees_left (
    customerstatus varchar,
    customerid varchar,
    churncategory varchar,
    churnreason varchar
  );

  -- Insert 'left' employees into the new table
  FOR v_employee_record IN
    SELECT * FROM churn WHERE customerstatus = 'Churned'
  LOOP
    INSERT INTO employees_left (customerstatus, customerid, churncategory, churnreason)
    VALUES (v_employee_record.customerstatus, v_employee_record.customerid, v_employee_record.churncategory, v_employee_record.churnreason);
  END LOOP;
END;
$$;

select * from churn

call move_churned_employees()

select * from employees_left

