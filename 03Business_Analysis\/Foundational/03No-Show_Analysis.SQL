
/*
========================================================
QUESTION 3: NO-SHOW ANALYSIS
========================================================

Business Question:
Calculate no-show and cancellation rates by
provider, department, and appointment type.

Objective:
Identify which departments, providers, and
appointment types experience the highest rates
of missed or cancelled appointments.

SQL Concepts:
- INNER JOIN
- GROUP BY
- CASE
- Conditional Aggregation
- Common Table Expressions (CTEs)
- UNION ALL
- ROUND and NULLIF
========================================================
*/


/*
========================================================
QUESTION 3: BUSINESS FINDINGS
========================================================

Overview:
Analyzed 9,200 appointments to identify no-show
and cancellation patterns across departments,
providers, and appointment types.

Overall Results:
- Total Appointments: 9,200
- Total No-Shows: 762
- Total Cancellations: 816
- Overall No-Show Rate: 8.28%
- Overall Cancellation Rate: 8.87%

Department Findings:
Cardiology had the highest no-show rate (9.38%)
and cancellation rate (9.93%).

Emergency Medicine recorded the most no-shows
(173), demonstrating that the highest number
of missed appointments does not necessarily
indicate the highest no-show percentage.

Provider Findings:
Provider 24 had the highest no-show rate
(11.64%) and cancellation rate (12.67%)
across 292 appointments.

These results may warrant further investigation
into scheduling and patient attendance patterns.

Appointment Type Findings:
Telehealth had the highest no-show rate
(10.37%), with 81 missed appointments
out of 781 total appointments.

Follow-up appointments had the highest
cancellation rate (9.39%) and accounted
for 314 no-shows and 359 cancellations.

Business Recommendations:
1. Investigate factors contributing to
   elevated no-show rates in Cardiology.

2. Review Provider 24's appointment patterns
   to identify potential scheduling issues.

3. Explore appointment reminders and patient
   communication for Telehealth visits.

4. Investigate ways to reduce missed and
   cancelled Follow-up appointments.

Methodology:
Rates were calculated using total appointments
within each group as the denominator, including
appointments marked Rescheduled.

These findings identify patterns and areas
for investigation, not confirmed causes.
========================================================
*/


/*
========================================================
SECTION 1: APPOINTMENT STATUS
========================================================

This query identifies the different appointment
statuses and counts how many appointments fall
under each status.

This allows us to understand the appointment
data before calculating no-show and
cancellation rates.

Results:
Completed:   7,277
No-Show:       762
Cancelled:     816
Rescheduled:   345
Total:       9,200
========================================================
*/

/*
SELECT
    status,
    COUNT(*) AS total_appointments
FROM appointments
GROUP BY status
ORDER BY total_appointments DESC;
*/


/*
========================================================
SECTION 2: OVERALL APPOINTMENT TOTALS
========================================================

This query calculates the total number of
appointments, no-shows, and cancellations.

COUNT() calculates the total appointments.

SUM() and CASE perform conditional aggregation:
- No-Show appointments receive a value of 1.
- Cancelled appointments receive a value of 1.
- Other statuses receive a value of 0.

SUM() adds the matching values to determine
the totals for each appointment status.
========================================================
*/

/*
SELECT
    COUNT(a.appointment_id) AS total_appointments,

    SUM(
        CASE
            WHEN a.status = 'No-Show' THEN 1
            ELSE 0
        END
    ) AS total_no_shows,

    SUM(
        CASE
            WHEN a.status = 'Cancelled' THEN 1
            ELSE 0
        END
    ) AS total_cancelled

FROM appointments a;
*/


/*
========================================================
SECTION 3: OVERALL NO-SHOW AND CANCELLATION RATES
========================================================

This query introduces a Common Table Expression
(CTE) named apt_sum.

The CTE calculates the appointment totals first.

The outer SELECT then uses those totals to
calculate the no-show and cancellation rates.

A CTE allows us to reference calculated columns
without repeating their aggregate expressions.

CTEs can improve readability and organization,
but they are not automatically more efficient
than subqueries.

Rate Formula:
(Count of matching appointments /
 Total appointments) * 100

100.0 ensures decimal division.
NULLIF() prevents division by zero.
ROUND() returns the percentage to 2 decimal places.

All appointment statuses, including Rescheduled,
are included in the denominator.

Expected Results:
No-Show Rate:       8.28%
Cancellation Rate:  8.87%
========================================================
*/

/*
WITH apt_sum AS (

    SELECT
        COUNT(a.appointment_id) AS total_appointments,

        SUM(
            CASE
                WHEN a.status = 'No-Show' THEN 1
                ELSE 0
            END
        ) AS total_no_shows,

        SUM(
            CASE
                WHEN a.status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) AS total_cancelled

    FROM appointments a
)

SELECT
    total_appointments,
    total_no_shows,
    total_cancelled,

    ROUND(
        total_no_shows * 100.0 /
        NULLIF(total_appointments, 0), 2
    ) AS no_show_rate,

    ROUND(
        total_cancelled * 100.0 /
        NULLIF(total_appointments, 0), 2
    ) AS cancellation_rate

FROM apt_sum;
*/


/*
========================================================
SECTION 4: DETAILED APPOINTMENT ANALYSIS
========================================================

This query analyzes appointments by combining
three dimensions:

1. Department
2. Provider
3. Appointment Type

INNER JOIN connects departments, providers,
and appointments.

GROUP BY combines appointments with the same
department, provider, and appointment type.

The CTE calculates the appointment totals for
each combination.

The outer SELECT calculates the percentage
of missed and cancelled appointments for
each combination.

The results are sorted from the highest to
lowest no-show rate.

This provides a detailed analysis but does
not yet calculate the overall rate for each
department, provider, or appointment type
individually.
========================================================
*/

/*
WITH apt_sum AS (

    SELECT
        d.department_id,
        d.department_name,
        p.provider_id,
        a.appointment_type,

        COUNT(a.appointment_id) AS total_appointments,

        SUM(
            CASE
                WHEN a.status = 'No-Show' THEN 1
                ELSE 0
            END
        ) AS total_no_shows,

        SUM(
            CASE
                WHEN a.status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) AS total_cancelled

    FROM departments d

    INNER JOIN providers p
        ON d.department_id = p.department_id

    INNER JOIN appointments a
        ON a.provider_id = p.provider_id

    GROUP BY
        d.department_id,
        d.department_name,
        p.provider_id,
        a.appointment_type
)

SELECT
    department_id,
    department_name,
    provider_id,
    appointment_type,
    total_appointments,
    total_no_shows,
    total_cancelled,

    ROUND(
        total_no_shows * 100.0 /
        NULLIF(total_appointments, 0), 2
    ) AS no_show_rate,

    ROUND(
        total_cancelled * 100.0 /
        NULLIF(total_appointments, 0), 2
    ) AS cancellation_rate

FROM apt_sum
ORDER BY no_show_rate DESC;
*/


/*
========================================================
SECTION 5: FINAL NO-SHOW ANALYSIS
========================================================

Business Question:
Calculate no-show and cancellation rates
by provider, department, and appointment type.

This final query uses two CTEs:

1. apt_sum
   Calculates appointment totals for each
   department, provider, and appointment-type
   combination.

2. cat_sum
   Uses the results from apt_sum to calculate
   separate totals by department, provider,
   and appointment type.

The final SELECT calculates the no-show and
cancellation percentages for each category.

UNION ALL combines the three analyses into
one results table without removing rows.

This query answers the complete business
question and is the final query for Question 3.

Note:
The INNER JOIN approach assumes every
appointment belongs to a valid provider and
department. Results should be interpreted
using that assumption.
========================================================
*/


-- CTE 1: Calculate appointment totals by combination

WITH apt_sum AS (

    SELECT
        d.department_id,
        d.department_name,
        p.provider_id,
        a.appointment_type,

        COUNT(a.appointment_id) AS total_appointments,

        SUM(
            CASE
                WHEN a.status = 'No-Show' THEN 1
                ELSE 0
            END
        ) AS total_no_shows,

        SUM(
            CASE
                WHEN a.status = 'Cancelled' THEN 1
                ELSE 0
            END
        ) AS total_cancelled

    FROM departments d

    INNER JOIN providers p
        ON d.department_id = p.department_id

    INNER JOIN appointments a
        ON a.provider_id = p.provider_id

    GROUP BY
        d.department_id,
        d.department_name,
        p.provider_id,
        a.appointment_type
),


/*
CTE 2: Summarize the appointment totals
separately by department, provider,
and appointment type.

Each SELECT calculates the totals for one
category. UNION ALL combines those results.
*/

cat_sum AS (

    -- Department analysis
    SELECT
        'Department' AS analysis_level,
        department_name AS category,

        SUM(total_appointments) AS total_appointments,
        SUM(total_no_shows) AS total_no_shows,
        SUM(total_cancelled) AS total_cancelled

    FROM apt_sum
    GROUP BY department_id, department_name

    UNION ALL

    -- Provider analysis
    SELECT
        'Provider' AS analysis_level,
        CONCAT('Provider ', provider_id) AS category,

        SUM(total_appointments) AS total_appointments,
        SUM(total_no_shows) AS total_no_shows,
        SUM(total_cancelled) AS total_cancelled

    FROM apt_sum
    GROUP BY provider_id

    UNION ALL

    -- Appointment type analysis
    SELECT
        'Appointment Type' AS analysis_level,
        appointment_type AS category,

        SUM(total_appointments) AS total_appointments,
        SUM(total_no_shows) AS total_no_shows,
        SUM(total_cancelled) AS total_cancelled

    FROM apt_sum
    GROUP BY appointment_type
)


/*
Final SELECT:

Retrieves the summarized appointment totals
from cat_sum and calculates both percentage
rates for every department, provider,
and appointment type.
*/

SELECT
    analysis_level,
    category,
    total_appointments,
    total_no_shows,
    total_cancelled,

    ROUND(
        total_no_shows * 100.0 /
        NULLIF(total_appointments, 0), 2
    ) AS no_show_rate,

    ROUND(
        total_cancelled * 100.0 /
        NULLIF(total_appointments, 0), 2
    ) AS cancellation_rate

FROM cat_sum

-- Organize by category, highest no-show rate first
ORDER BY
    CASE analysis_level
        WHEN 'Department' THEN 1
        WHEN 'Provider' THEN 2
        WHEN 'Appointment Type' THEN 3
    END,
    no_show_rate DESC,
    total_appointments DESC
