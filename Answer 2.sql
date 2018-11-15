use DBA_TEST
select DEPT_NAME, TBL_TRANSACTIONS.PATIENT_ID, PATIENT_NAME, 
-- replace insurance name with SELF-PAY when its null
ISNULL(TBL_INSURANCES.INSURANCE_NAME, 'SELF-PAY') AS INSURANCE_NAME,
-- replace NULL insurance payment to 0
SUM(CHARGES - (ISNULL(TBL_TRANSACTIONS.INSURANCE_PAYMENT, 0) + ISNULL(PATIENT_PAYMENT, 0)) ) AS OUTSTANDING_BALANCE

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

 -- perform analysis on the transactions that are only outstanding
where TBL_TRANSACTIONS.TX_ID IN (SELECT TX_ID FROM TBL_TRANSACTIONS
where
(TBL_TRANSACTIONS.CHARGES > ISNULL(TBL_TRANSACTIONS.INSURANCE_PAYMENT, 0) + 
TBL_TRANSACTIONS.PATIENT_PAYMENT)
)
-- grouping due to details organized by department are required
GROUP BY DEPT_NAME, TBL_TRANSACTIONS.PATIENT_ID, PATIENT_NAME, TBL_INSURANCES.INSURANCE_NAME
-- showing results in reverse order of outstanding balance in each department
ORDER BY DEPT_NAME ,OUTSTANDING_BALANCE DESC




