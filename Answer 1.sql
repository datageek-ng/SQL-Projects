--Answer 1 - Select details of all patients aged less than 18 years on the visit date who were seen in more than one department in calendar year 2017.
-- The result set should have ONLY one record for each patient and department combination. 
 use DBA_TEST
select distinct TBL_TRANSACTIONS.PATIENT_ID,
 TBL_PATIENTS.PATIENT_NAME,
  TBL_PATIENTS.BIRTH_DATE,
  TBL_DEPARTMENTS.DEPT_NAME,
  COUNT(TBL_TRANSACTIONS.VISIT_DATE) AS VISIT_COUNT
-- joining four tables together as inner join to get intersecting values in all tables because we want to see columns from each tables
 from  
 (((TBL_TRANSACTIONS 
 inner join TBL_PATIENTS on TBL_TRANSACTIONS.PATIENT_ID = TBL_PATIENTS.PATIENT_ID)
 inner join TBL_PHYSICIANS on TBL_TRANSACTIONS.PHYSICIAN_ID = TBL_PHYSICIANS.PHYSICIAN_ID)
 inner join TBL_DEPARTMENTS on TBL_PHYSICIANS.DEPT_ID = TBL_DEPARTMENTS.DEPT_ID)
 
 where
-- Drilling down to rows with patients who are below 18 during visit
 DATEDIFF(year, BIRTH_DATE, VISIT_DATE) < 18

 and 
-- Drilling down 2017 data
 (TBL_TRANSACTIONS.VISIT_DATE >= Convert(datetime, '2017-01-01') and 
 TBL_TRANSACTIONS.VISIT_DATE <= Convert(datetime, '2017-12-31'))

 and

 PATIENT_NAME in (
-- selecting names of patients who are under 18 and visited multiple departments in 2017
select TBL_PATIENTS.PATIENT_NAME
-- joining four tables together as inner join to get intersecting values in all tables because we want to see columns from each tables
from  
 (((TBL_TRANSACTIONS 
 inner join TBL_PATIENTS on TBL_TRANSACTIONS.PATIENT_ID = TBL_PATIENTS.PATIENT_ID)
 inner join TBL_PHYSICIANS on TBL_TRANSACTIONS.PHYSICIAN_ID = TBL_PHYSICIANS.PHYSICIAN_ID)
 inner join TBL_DEPARTMENTS on TBL_PHYSICIANS.DEPT_ID = TBL_DEPARTMENTS.DEPT_ID)
 -- Drilling down 2017 data
 where
 (TBL_TRANSACTIONS.VISIT_DATE >= Convert(datetime, '2017-01-01') and 
 TBL_TRANSACTIONS.VISIT_DATE <= Convert(datetime, '2017-12-31'))
 -- Drilling down to rows with patients who are below 18 during visit
  and 
 DATEDIFF(year, BIRTH_DATE, VISIT_DATE) < 18

 -- grouping for getting departments visited count for each patient
 group by PATIENT_NAME
 -- Filtering list of people who have visited multiple departments in 2017 with age less than 18
 having COUNT(distinct (TBL_PHYSICIANS.DEPT_ID)) > 1
)
-- grouping for getting visit count for each patient for each department
GROUP BY TBL_TRANSACTIONS.PATIENT_ID,
 TBL_PATIENTS.PATIENT_NAME,
  TBL_PATIENTS.BIRTH_DATE,
  TBL_DEPARTMENTS.DEPT_NAME
-- just for convenience - optional
order by PATIENT_ID