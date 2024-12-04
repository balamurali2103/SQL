CREATE TABLE customer (
CustomerID varchar, 
Gender varchar, 
Age int,
Married Boolean,
NumberOfDependents int, 
City varchar,
ZipCode int,
Latitude decimal,
Longitude decimal,
NumberOfReferrals int ,
TenureInMonths int
)


copy customer
from 'C:\Program Files\PostgreSQL\17\pgAdmin 4\docs\files\projects\customer.csv' CSV header

create table payment(
CustomerID varchar,
Contract varchar, 
PaperlessBilling Boolean,
PaymentMethod varchar,
MonthlyCharge float(2),
TotalCharges float(2),
TotalRefunds float(2),
TotalExtraDataCharges float(2),
TotalLongDistanceCharges float(2), 
TotalRevenue float(2) 
)
copy  payment
from 'C:\Program Files\PostgreSQL\17\pgAdmin 4\docs\files\projects\Payment.csv' CSV HEADER

create table services (
CustomerID varchar,
Offer varchar,
PhoneService Boolean,
AvgMonthlyLongDistanceCharges float(2) ,
MultipleLines varchar,
InternetService Boolean,
InternetType varchar,
AvgMonthlyGBDownload int,
OnlineSecurity Boolean,
OnlineBackup Boolean,
DeviceProtectionPlan Boolean,
PremiumTechSupport Boolean,
StreamingTV Boolean,
StreamingMovies Boolean,
StreamingMusic Boolean,
UnlimitedData Boolean
)

copy  services
from 'C:\Program Files\PostgreSQL\17\pgAdmin 4\docs\files\projects\Services.csv' CSV HEADER

create table churn
(CustomerID varchar, CustomerStatus varchar, ChurnCategory varchar, ChurnReason varchar
)

copy  Churn
from 'C:\Program Files\PostgreSQL\17\pgAdmin 4\docs\files\projects\Churn.csv' CSV HEADER

select * from churn
select * from payment

Select a.customerid, a.monthlycharge , b.churncategory, b.churnreason
from payment as a 
left join churn as b on a.customerid = b.customerid
where a.contract = 'Month-to-Month'
group by a.customerid , monthlycharge, b.churncategory, b.churnreason


select a.customerid, b.age, a.totalcharges, a.contract 
From payment as a 
Right join 
(select customerid, age
from customer
where customerid in (Select customerid from churn where customerstatus = 'Churned')) as b 
on a.customerid = b.customerid
