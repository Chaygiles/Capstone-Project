/*
QUESTION 2: DEPARTMENT REVENUE ANALYSIS

Business Objective:
Compare billed, allowed, insurer-paid, and collected
revenue across hospital departments.

Analysis:
- Identify the total number of claims per department.
- Calculate total billed amounts for each department.
- Calculate total allowed amounts under insurance contracts.
- Determine total insurer-paid amounts.
- Calculate total collected payments.

Tables Used:
- departments
- encounters
- claims
- payments

Method:
INNER JOIN connects departments, encounters, and claims.

A CTE aggregates payments by claim and patient ID to
prevent multiple payment records from duplicating
billed and allowed amounts.

LEFT JOIN preserves claims that have no payment records.

Results are grouped by department and ranked by
the selected revenue metric.
*/

/*
SELECT d.department_name, COUNT(DISTINCT c.claim_id) AS Total_Claims, SUM(c.billed_amount) AS Total_Billed,
		SUM(c.allowed_amount) AS total_allowed 
FROM departments d
INNER JOIN encounters e
	ON e.department_id= d.department_id
INNER JOIN claims c
	ON c.encounter_id = e.encounter_id
GROUP BY d.department_name
ORDER BY total_claims DESC

*/

/*

This query identified the relationship between the tables and finances

SELECT
    table_name,
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name IN ('claims', 'payments')
ORDER BY
    table_name,
    ordinal_position;

*/

/*
Allowed Revenue

SELECT d.department_name, COUNT(DISTINCT c.claim_id) AS Total_Claims, 
	SUM(c.billed_amount) AS Total_Billed,
	SUM(c.allowed_amount) AS total_allowed, 
	SUM(p.amount) AS Total_Payment_Amounts
FROM departments d
INNER JOIN encounters e
	ON e.department_id= d.department_id
INNER JOIN claims c
	ON c.encounter_id = e.encounter_id
LEFT JOIN payments p
	ON c.patid = p.patid
	AND c.claim_id = p.claim_id
LEFT JOIN insurance_plans ip
	ON ip.plan_id = c.plan_id
GROUP BY d.department_name
ORDER BY total_claims DESC

*/

/* 
After joining the payments and claims tables, I noticed
that the total billed and total allowed amounts increased
incorrectly.

This occurred because some claims have multiple payment
records, causing the billed and allowed amounts to be
counted more than once.

To correct this, I created a CTE (Common Table Expression)
that calculates the total payments for each claim before
joining the results to the claims table.

I used a LEFT JOIN to ensure that claims without recorded
payments are still included in the billed and allowed totals

*/


/*

Collected Revenue

WITH Tot_pay AS ( 
		SELECT p.claim_id, p.patid,
			SUM(p.amount) AS Total_payment
		FROM payments p
		GROUP BY p.claim_id, p.patid
		)
SELECT d.department_name, COUNT(DISTINCT c.claim_id) AS Total_Claims, 
	SUM(c.billed_amount) AS Total_Billed,
	SUM(c.allowed_amount) AS Total_Allowed,
	SUM(tp.Total_payment) AS Total_Collected
FROM departments d
INNER JOIN encounters e
	ON e.department_id= d.department_id
INNER JOIN claims c
	ON c.encounter_id = e.encounter_id
LEFT JOIN Tot_pay tp
	ON c.claim_id = tp.claim_id
	AND c.patid = tp.patid
GROUP BY d.department_name
ORDER BY total_allowed DESC
*/		

/*
-- Insurer Paid Amount

WITH Tot_pay AS ( 
		SELECT p.claim_id, p.patid,
			SUM(p.amount) AS Total_payment
		FROM payments p
		GROUP BY p.claim_id, p.patid
		)
SELECT d.department_name, 
	COUNT(DISTINCT c.claim_id) AS Total_Claims, 
	SUM(c.billed_amount) AS Total_Billed,
	SUM(c.allowed_amount) AS Total_Allowed,
	COALESCE(SUM(tp.Total_payment), 0) AS Total_Collected,
	SUM(c.paid_amount) AS Total_Insurer_Paid
FROM departments d
INNER JOIN encounters e
	ON e.department_id= d.department_id
INNER JOIN claims c
	ON c.encounter_id = e.encounter_id
LEFT JOIN Tot_pay tp
	ON c.claim_id = tp.claim_id
	AND c.patid = tp.patid
GROUP BY d.department_name
ORDER BY Paid_Claims DESC */


-- Final query- Department Revenue Analysis

WITH Tot_pay AS ( 
		SELECT p.claim_id, p.patid,
			SUM(p.amount) AS Total_payment
		FROM payments p
		GROUP BY p.claim_id, p.patid
		)
SELECT d.department_id, d.department_name,
	COUNT(DISTINCT c.claim_id) AS Total_Claims, 
	SUM(c.billed_amount) AS Total_Billed,
	SUM(c.allowed_amount) AS Total_Allowed,
	COALESCE(SUM(tp.Total_payment), 0) AS Total_Collected,
	SUM(c.paid_amount) AS Total_Insurer_Paid
FROM departments d
INNER JOIN encounters e
	ON e.department_id= d.department_id
INNER JOIN claims c
	ON c.encounter_id = e.encounter_id
LEFT JOIN Tot_pay tp
	ON c.claim_id = tp.claim_id
	AND c.patid = tp.patid
GROUP BY d.department_id, d.department_name
ORDER BY Total_Collected DESC 


/*
Data Limitation:
The data dictionary does not explicitly define whether
claims.paid_amount represents insurer payments or total
claim-level payments.

This analysis reports the amount recorded as paid on claims
separately from the payment amounts in the payments table.

The distinction between insurer and patient payments
requires additional documentation to confirm.
*/

