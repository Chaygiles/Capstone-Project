
/*
========================================================
QUESTION 2: DEPARTMENT REVENUE ANALYSIS
========================================================

BUSINESS QUESTION:
How does revenue performance compare across hospital
departments based on total claims, billed amounts,
allowed amounts, and collected payments?

OBJECTIVE:
Evaluate department-level financial performance by
comparing claim volume, billed revenue, allowed revenue,
recorded payments, and claim-level paid amounts.

APPROACH:
1. Join departments, encounters, and claims to connect
   financial activity to each hospital department.
2. Calculate total claims, billed amounts, and allowed
   amounts for each department.
3. Aggregate payments by claim and patient to prevent
   duplicate financial totals.
4. Use LEFT JOIN to preserve claims without payments.
5. Calculate total collected and recorded paid amounts.
6. Rank departments by total collected revenue.

CTE:
Total_payments:
- Groups payments by claim_id and patid.
- Calculates total payments associated with each claim.
- Prevents multiple payment records from duplicating
  billed and allowed amounts during aggregation.

FINAL ANALYSIS:
The final query compares financial performance across
departments using the following metrics:

- Total_Claims: Number of claims per department.
- Total_Billed: Total amount billed for services.
- Total_Allowed: Total amount allowed under contracts.
- Total_Collected: Payments recorded in the payments table.
- Total_Insurer_Paid: Paid amounts recorded in claims.

Departments are ranked by Total_Collected in
descending order.

DATA LIMITATION:
The data dictionary does not explicitly confirm whether
claims.paid_amount represents insurer payments or total
claim-level payments.

Therefore, Total_Insurer_Paid reflects the recorded
claims.paid_amount values, but its interpretation as
insurer-only payments requires further validation.

Total_Collected and Total_Insurer_Paid should not be
added together because the amounts may overlap.

========================================================
*/

WITH Total_payments AS (
    SELECT claim_id, patid,
        SUM(amount) AS Total_Payment
    FROM payments
    GROUP BY claim_id, patid
)
SELECT d.department_id, d.department_name,
    COUNT(DISTINCT c.claim_id) AS Total_Claims,
    SUM(c.billed_amount) AS Total_Billed,
    SUM(c.allowed_amount) AS Total_Allowed,
    COALESCE(SUM(tp.Total_Payment), 0) AS Total_Collected,
    SUM(c.paid_amount) AS Total_Insurer_Paid
FROM departments d
INNER JOIN encounters e
    ON e.department_id = d.department_id
INNER JOIN claims c
    ON c.encounter_id = e.encounter_id
LEFT JOIN Total_payments tp
    ON tp.claim_id = c.claim_id
    AND tp.patid = c.patid
GROUP BY d.department_id, d.department_name
ORDER BY Total_Collected DESC;
