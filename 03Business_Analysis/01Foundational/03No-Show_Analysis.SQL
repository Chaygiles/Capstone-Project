
/*
QUESTION 3: FINAL NO-SHOW ANALYSIS

The CTE calculates appointment totals by:
- Department
- Provider
- Appointment Type

GROUPING SETS creates these three summaries
without needing separate UNION ALL queries.

The final SELECT calculates percentage rates.
*/

WITH apt_sum AS (
    SELECT
        CASE
            WHEN GROUPING(d.department_id) = 0
                THEN 'Department'
            WHEN GROUPING(p.provider_id) = 0
                THEN 'Provider'
            ELSE 'Appointment Type'
        END AS analysis_level,

        CASE
            WHEN GROUPING(d.department_id) = 0
                THEN d.department_name
            WHEN GROUPING(p.provider_id) = 0
                THEN CONCAT('Provider ', p.provider_id)
            ELSE a.appointment_type
        END AS category,

        COUNT(a.appointment_id) AS total_appointments,

        SUM(CASE
            WHEN a.status = 'No-Show' THEN 1
            ELSE 0
        END) AS total_no_shows,

        SUM(CASE
            WHEN a.status = 'Cancelled' THEN 1
            ELSE 0
        END) AS total_cancelled

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

    ROUND(
        total_no_shows * 100.0 /
        NULLIF(total_appointments, 0), 2
    ) AS no_show_rate,

    ROUND(
        total_cancelled * 100.0 /
        NULLIF(total_appointments, 0), 2
    ) AS cancellation_rate

FROM apt_sum

ORDER BY
    CASE analysis_level
        WHEN 'Department' THEN 1
        WHEN 'Provider' THEN 2
        WHEN 'Appointment Type' THEN 3
    END,
    no_show_rate DESC,
    total_appointments DESC;
