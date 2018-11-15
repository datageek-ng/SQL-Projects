USE DBA_TEST
-- Sort the pivot table by Month and then by different financial classes
SELECT MONTH, 
[COMMERCIAL], [MEDICARE], [MEDICAID], [SELF_PAYMENT]
FROM(
-- Select the specific month name from given visit date, financial class of insurance ( Self_payment when null)
-- and insurance payment + patient_payment as total_payment(0 when null)
select DATENAME(MONTH, VISIT_DATE)as MONTH, ISNULL(FINANCIAL_CLASS, 'SELF_PAYMENT') as FINANCIAL_CLASS,
ISNULL(TBL_TRANSACTIONS.INSURANCE_PAYMENT, 0) + ISNULL(PATIENT_PAYMENT, 0) AS TOTAL_PAYMENT 



from  
-- inner join transactions and patients
((((TBL_TRANSACTIONS 
 inner join TBL_PATIENTS on TBL_TRANSACTIONS.PATIENT_ID = TBL_PATIENTS.PATIENT_ID)
-- add inner join physicians
 inner join TBL_PHYSICIANS on TBL_TRANSACTIONS.PHYSICIAN_ID = TBL_PHYSICIANS.PHYSICIAN_ID)
-- add inner join departments
 inner join TBL_DEPARTMENTS on TBL_PHYSICIANS.DEPT_ID = TBL_DEPARTMENTS.DEPT_ID)
-- left outer join insurances to also get the patients with no insurance id's into the result
 left outer join TBL_INSURANCES on TBL_PATIENTS.INSURANCE_ID = TBL_INSURANCES.INSURANCE_ID)

-- Select transactions from only 2016 and 2017
where TX_ID in (
select TX_ID from TBL_TRANSACTIONS where VISIT_DATE between '2016-01-01' and '2017-12-31'
)
-- Consider this as Source (SRC)
 ) AS SRC

-- pivot sum(total payment) for a purticular financial class and declaring it as pivot variable (pvt)
PIVOT
(
SUM(TOTAL_PAYMENT)
FOR [FINANCIAL_CLASS] IN ([COMMERCIAL], [MEDICARE], [MEDICAID], [SELF_PAYMENT])
) AS PVT

-- order by occuring month names for convenience
ORDER BY (
     case MONTH 
     when 'January' then 0 
     when 'February' then 1
     when 'March' then 2
     when 'April' then 3
	 when 'May' then 4
	 when 'June' then 5
	 when 'July' then 6
	 when 'August' then 7
	 when 'September' then 8
	 when 'October' then 9
	 when 'November' then 10
	 when 'December' then 11
     end
)
