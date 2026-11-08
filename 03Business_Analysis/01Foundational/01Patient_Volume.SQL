
/*
========================================================
QUESTION 1: PATIENT ENCOUNTER VOLUME ANALYSIS
========================================================

BUSINESS QUESTION:
How many healthcare encounters occur each month,
quarter, and year, and how many unique patients
receive care during those periods?

OBJECTIVE:
Analyze patient encounter volume over time to
identify utilization trends and changes in
patient activity.

APPROACH:
1. Use DATE_TRUNC to group encounters by month,
   quarter, and year.
2. Count total encounters for each period.
3. Count distinct patients to measure unique
   patient utilization.
4. Sort results chronologically within each
   reporting period.



FINAL ANALYSIS:
Compare encounter volume and unique patient counts
across monthly, quarterly, and yearly periods.

========================================================
*/

SELECT periods.time_period,
    DATE_TRUNC(periods.time_period, e.encounter_date) AS period_start,
    COUNT(e.encounter_id) AS total_encounters,
    COUNT(DISTINCT e.patid) AS unique_patients
FROM encounters e
CROSS JOIN (
    VALUES ('month'), ('quarter'), ('year')
) AS periods(time_period)
GROUP BY periods.time_period,
    DATE_TRUNC(periods.time_period, e.encounter_date)
ORDER BY
    CASE periods.time_period
        WHEN 'month' THEN 1
        WHEN 'quarter' THEN 2
        ELSE 3
    END,
    period_start DESC;


/*
========================================================
BUSINESS RESULTS / FINDINGS
========================================================

Results pending execution of the consolidated query.

ANALYSIS NOTES:
- Total encounters measure overall patient visits.
- Unique patients measure the number of different
  patients receiving care during each period.
- A patient with multiple encounters within the
  same period is counted only once as a unique patient.
- Comparing these metrics can reveal changes in
  utilization and repeat patient activity.

========================================================
*/
