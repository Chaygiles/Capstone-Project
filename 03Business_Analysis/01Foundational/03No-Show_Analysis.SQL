
/*
========================================================
QUESTION 3: NO-SHOW AND CANCELLATION ANALYSIS
========================================================

BUSINESS QUESTION:
Which departments, providers, and appointment types
experience the highest no-show and cancellation rates?

OBJECTIVE:
Analyze appointment attendance patterns to identify
areas with scheduling inefficiencies and potential
opportunities to improve patient attendance.

APPROACH:
1. Count total appointments across three analysis levels:
   - Department
   - Provider
   - Appointment Type

2. Calculate the number of no-shows and cancellations
   using conditional aggregation.

3. Use GROUPING SETS to generate all three summaries
   within a single query.

4. Calculate no-show and cancellation percentages
   to compare performance across categories.

CTEs:
- appointment_summary: Aggregates appointment totals, no-shows,
  and cancellations by analysis level.

FINAL ANALYSIS:
Calculate attendance-related rates and rank categories
by their no-show rates to identify scheduling concerns.

========================================================
*/

WITH appointment_summary AS (
    SELECT
        CASE
            WHEN GROUPING(d.department_id) = 0 THEN 'Department'
            WHEN GROUPING(p.provider_id) = 0 THEN 'Provider'
            ELSE 'Appointment Type'
        END AS analysis_level,

        CASE
            WHEN GROUPING(d.department_id) = 0 THEN d.department_name
            WHEN GROUPING(p.provider_id) = 0 THEN CONCAT('Provider ', p.provider_id)
            ELSE a.appointment_type
        END AS category,

        COUNT(a.appointment_id) AS total_appointments,
        COUNT(*) FILTER (WHERE a.status = 'No-Show') AS total_no_shows,
        COUNT(*) FILTER (WHERE a.status = 'Cancelled') AS total_cancelled

    FROM appointments a
    INNER JOIN providers p
        ON a.provider_id = p.provider_id
    INNER JOIN departments d
        ON p.department_id = d.department_id

    GROUP BY GROUPING SETS (
        (d.department_id, d.department_name),
        (p.provider_id),
        (a.appointment_type)
    )
)

SELECT
    analysis_level,
    category,
    total_appointments,
    total_no_shows,
    total_cancelled,
    ROUND(total_no_shows * 100.0 / NULLIF(total_appointments, 0), 2) AS no_show_rate,
    ROUND(total_cancelled * 100.0 / NULLIF(total_appointments, 0), 2) AS cancellation_rate

FROM appointment_summary

ORDER BY
    CASE analysis_level
        WHEN 'Department' THEN 1
        WHEN 'Provider' THEN 2
        WHEN 'Appointment Type' THEN 3
    END,
    no_show_rate DESC,
    total_appointments DESC;
