# Healthcare Analytics Capstone

**An end-to-end PostgreSQL project covering relational database design, data quality, healthcare operations, revenue-cycle analysis, advanced SQL, and reusable reporting.**

**SQL phase:** 14 of 14 capstone questions completed  
**Data:** 100% synthetic healthcare records; no real patients or protected health information (PHI)  
**Source period:** January 1, 2024 – August 1, 2026  
**Primary tools:** PostgreSQL, pgAdmin 4, SQL, VS Code, Git/GitHub  
**Next phase:** Trend comparisons and business intelligence visualizations

---

## Project overview

Healthcare operations generate connected information about patient visits, providers, departments, diagnoses, insurance claims, and payments. An analyst must be able to turn those transactional records into trustworthy answers without inflating counts or revenue when joining one-to-many tables.

This capstone models that workflow in PostgreSQL. I designed and refined a relational database, loaded 11 source CSV files, validated and cleaned the records, then completed 14 business-oriented SQL analyses spanning foundational aggregations through functions and performance tuning.

The project addresses four primary business themes:

1. **Patient access and utilization:** How often patients receive care, which services see the most activity, and where repeat utilization occurs.
2. **Operational performance:** Where missed appointments occur and how providers compare within departments.
3. **Revenue cycle:** What is billed, contractually allowed, paid, collected, denied, or potentially uncollected.
4. **Reusable analytics:** How views, database functions, indexing, and query plans can make recurring reporting more maintainable.

> **Portfolio scope:** This is an analytical simulation using synthetic data. Findings identify patterns in the supplied dataset, not verified problems at a real healthcare organization.

## Data and relational model

The source package contains **11 related CSV tables**. These are the original source counts from the data dictionary; certain cleaned database counts may differ where records were corrected or deduplicated.

| Table | Source rows | Purpose |
| --- | ---: | --- |
| `departments` | 8 | Healthcare departments and specialties |
| `insurance_plans` | 8 | Payers and plan attributes |
| `pat` (source: `patients`) | 1,520 | Synthetic patient demographic and registration records |
| `providers` | 40 | Providers and department assignments |
| `appointments` | 9,200 | Scheduled visits and appointment outcomes |
| `encounters` | 8,477 | Completed healthcare encounters and visit details |
| `diagnoses` | 14,989 | Encounter-related diagnosis entries |
| `procedures` | 7,344 | Clinical procedures and charges |
| `medications` | 4,489 | Medication orders |
| `claims` | 8,477 | Billing, allowed amounts, responsibilities, and claim status |
| `payments` | 12,386 | Individual claim-level payment transactions |

### Important relationships

- A **department** has multiple **providers** and **encounters**.
- A **patient** can have multiple **appointments** and **encounters**.
- An **encounter** can be associated with **diagnoses**, **procedures**, **medication orders**, and **claims**.
- An **insurance plan** is associated with claims through `claims.plan_id`.
- A **claim** can have more than one **payment**; transactions are joined using `claim_id` and `patid` where applicable.

**Implemented naming conventions:** The PostgreSQL patient table is named `pat`, with `patid` as its patient key and `dob` for date of birth. Some source data-dictionary labels use `patients` and `patient_id`; SQL should follow the implemented schema. The claims foreign key is `plan_id`. The `diagnoses` table was also updated to include `encounter_id`.

**Why grain matters:** Joining claims directly to multiple payment rows can repeat billed and allowed amounts. For revenue questions, I aggregate payments to the appropriate claim/patient level before joining them to claim totals. I also use `COUNT(DISTINCT ...)` where one encounter or claim can map to multiple diagnosis records.

## Database build, import, and cleaning

The preparation stage included:

- Creating the PostgreSQL database and table structures with primary keys and foreign-key relationships.
- Importing the 11 CSV datasets in dependency-aware order and resolving datatype, column-mapping, and foreign-key problems.
- Updating selected columns and relationships with `ALTER TABLE`, including appointment/claim status lengths and valid nullable fields.
- Validating row counts, missing values, duplicate demographics, relationship integrity, and unusual financial values.
- Reviewing **13 missing ZIP-code entries**, inconsistent city capitalization, and **20 potentially duplicated patient demographic records**. The relevant cleaning and normalization work was completed before the analysis phase.
- Retaining meaningful exceptions, such as legitimately unscheduled encounters and claims that have no insurer payment.
- Repairing the missing `diagnoses.encounter_id` relationship to enable encounter-based diagnosis analysis.

**Material limitation:** The diagnosis-to-encounter mapping was reconstructed for this synthetic project. Therefore, diagnosis-specific claim findings reflect *synthetic assignments*, not independently validated clinical associations. Claims may appear in several diagnosis-category groups; those group counts should not be added together as though they were disjoint.

## The 14 completed SQL business questions

Each question is framed around a decision or reporting need, with SQL comments documenting the business question, objective, approach, query logic, and observed findings where available.

| # | Analysis | Business purpose | Main SQL techniques |
| ---: | --- | --- | --- |
| **1** | Patient volume and encounter trends | Count encounters and distinct patients by month, quarter, and year. | `DATE_TRUNC`, `COUNT`, `COUNT(DISTINCT)`, `GROUP BY` |
| **2** | Department revenue analysis | Compare billed, allowed, insurer-paid, and collected amounts by department without duplicating claim values. | Multi-table joins, payment pre-aggregation, CTEs, `SUM` |
| **3** | No-show and cancellation analysis | Compare missed and cancelled appointments by department, provider, and appointment type. | `CASE`, conditional aggregation, `GROUPING SETS`, `NULLIF` |
| **4** | Claims denial analysis | Compare denial rates and volumes across payers, departments, and diagnosis categories. | CTEs, joins, conditional `COUNT(DISTINCT)` |
| **5** | Patient responsibility collections | Compare patient responsibility against actual patient payments and estimate outstanding balances and collection rates. | CTEs, `LEFT JOIN`, aggregation, `COALESCE` |
| **6** | Provider performance scorecard | Rank providers *within departments* by encounter volume, collected revenue, and no-show rate. | CTEs, payment pre-aggregation, `RANK()`, `PARTITION BY` |
| **7** | High-utilization patients and common diagnoses | Identify frequent patients and the diagnosis descriptions associated with their encounters. | CTEs, `DENSE_RANK()`, joins, grouped counts |
| **8** | Repeat acute-care utilization | Detect repeat Emergency Department or inpatient encounters within 30, 60, or 90 days. | `LAG`/`LEAD`, partitions, date arithmetic |
| **9** | Rolling department trends | Calculate three-month rolling encounter volume and payment collections by department. | Monthly CTE, window frames, rolling `SUM()` |
| **10** | Leading diagnosis by department and year | Determine the most frequent diagnosis categories within each department/year comparison. | CTEs, conditional grouping, ranking/window functions |
| **11** | Revenue leakage by payer | Quantify the gaps between billed, allowed, and collected amounts for each payer. | Multi-stage aggregation, reconciled claim/payment totals |
| **12** | Performance tuning | Inspect execution plans and buffers; compare query revisions and indexing behavior. | `EXPLAIN (ANALYZE, BUFFERS)`, indexes, plan analysis |
| **13** | Reusable reporting views | Publish patient-utilization and encounter-financial results as reusable queryable views. | `CREATE OR REPLACE VIEW`, aggregation, joins |
| **14** | Reusable KPI function | Package date-filtered business KPI logic into a PostgreSQL function for repeatable analysis. | PostgreSQL `CREATE FUNCTION`, parameters, reusable SQL logic |

### How selected analyses work

**Questions 2, 5, 6, and 11 — financially accurate joins.** Claims and payment transactions exist at different levels of detail. A claim may have multiple payments, so payments must be summarized at the appropriate level before being combined with amounts stored once per claim. `claims.paid_amount` and the summed `payments.amount` are separate measures and should not automatically be treated as interchangeable. Source-specific payment filters are necessary when distinguishing insurer payments from patient payments.

**Question 6 — department-relative rankings.** Volume and collections are ranked from highest to lowest, while the lowest no-show rate ranks best. `PARTITION BY department_id` prevents a provider from being evaluated against providers in unrelated departments.

**Question 8 — repeat utilization.** Analytical date windows compare encounters for the same patient in time order. A repeat visit within 30/60/90 days is an *encounter-timing measure*, not proof of an avoidable hospital readmission.

**Question 9 — rolling windows.** A three-row window sums three successive monthly observations per department. If a reporting calendar contains missing months, a date spine would be needed to guarantee a literal three-calendar-month window.

**Question 10 — diagnosis rankings.** Rankings should be generated within each department **and year** when identifying the top diagnosis category for each combination; ties should be handled consistently.

**Question 12 — interpreting performance measurements.** Execution time, sort operations, join types, buffers, and sequential/index scans are reviewed together. A newly created index is a persistent database object, but PostgreSQL may still choose a sequential scan if it estimates that as cheaper. Captured provider-scorecard plan executions across query iterations include **110.746 ms**, **78.437 ms**, and **76.092 ms**. These are observations from individual runs, **not** a controlled claim that indexing alone caused the difference.

**Question 13 — published view names.** The reusable views include `vw_patient_utilization` and `vw_encounter_financials`. The encounter-financial view exposes encounter/patient/department identifiers and summarized claim, billed, allowed, collected, and insurer-paid metrics. The department-revenue view was removed from the final scope of this question.

**Question 14 — stored KPI logic.** Parameterizing business metrics by a start and end date makes repeated time-period analysis easier without rewriting the underlying calculations. Date filtering must be applied consistently to the relevant encounter/transaction dates, and each KPI should have a clearly defined denominator and grain.

## Verified business findings

The following are results recorded in the completed SQL analysis files. They are intentionally selective; figures from other questions are not reproduced here without their final verified outputs.

### Appointment attendance — Question 3

| Metric | Verified result |
| --- | ---: |
| Total appointments | **9,200** |
| No-shows | **762 (8.28%)** |
| Cancellations | **816 (8.87%)** |
| Highest departmental no-show rate | **Cardiology — 9.38%** |
| Highest departmental cancellation rate | **Cardiology — 9.93%** |
| Most no-shows by department | **Emergency Medicine — 173** |
| Highest provider no-show rate | **Provider 24 — 11.64%** |
| Highest appointment-type no-show rate | **Telehealth — 10.37%** |
| Highest appointment-type cancellation rate | **Follow-up — 9.39%** |

**Interpretation:** The most missed appointments and the highest missed-appointment *rate* can indicate different priorities. These patterns merit scheduling and reminder-workflow investigation but do not establish a cause. Rates use all appointments within each group, including rescheduled appointments, as the denominator.

### Claims denials — Question 4

| Metric | Verified result |
| --- | ---: |
| Total claims | **8,477** |
| Paid / partially paid / pending | **6,965 / 746 / 289** |
| Denied claims | **477 (5.63%)** |
| Highest payer denial rate | **Apex Health — 6.05%** |
| Lowest payer denial rate | **CommonCare — 4.67%** |
| Highest departmental denial rate | **Primary Care — 6.97%** |
| Greatest departmental denial count | **Emergency Medicine — 144** |
| Highest diagnosis-category denial rate | **Gastrointestinal — 6.50%** |
| Greatest diagnosis-category denial count | **Symptoms — 174** |

**Interpretation:** Claim volume and denial rate should both inform the review queue. Diagnosis-category findings carry the synthetic-mapping limitation noted above. Categories overlap, so their individual claim counts are not additive.

## Reproducing the project

1. **Set up PostgreSQL and pgAdmin 4.** Create a database and apply the project’s final DDL and relationship updates.
2. **Load the CSVs in dependency order.** Load reference tables (`departments`, `insurance_plans`), then patients/providers, appointments/encounters, and dependent clinical/financial records. Confirm that foreign keys are present before importing child tables.
3. **Run validation and cleaning scripts.** Check record counts, duplicate demographics, missing data, and key relationships. Apply the documented schema adjustments and diagnosis relationship repair where necessary.
4. **Run analyses 1–12.** Execute the SQL in pgAdmin, reviewing each query’s comment header and findings. Question 12 includes execution-plan inspection and any intended index DDL.
5. **Create the Question 13 views.** Run the `CREATE OR REPLACE VIEW` statements before querying the views or using them in later reporting.
6. **Create and run the Question 14 function.** Run its `CREATE FUNCTION` statement, then invoke it with a valid start and end date according to the SQL function’s declared signature.

The two saved example analysis scripts in the Capstone Project materials are `question_3_no_show_analysis.sql` and `question_4_claims_denial_analysis.sql`. Other analysis script names should be taken from the actual GitHub repository rather than assumed from this README.

### Example reporting queries

```sql
-- View reusable patient-utilization results.
SELECT *
FROM vw_patient_utilization;

-- View encounter-level financial summaries.
SELECT *
FROM vw_encounter_financials;

-- Inspect the plan for a reporting query.
EXPLAIN (ANALYZE, BUFFERS)
SELECT *
FROM vw_encounter_financials
WHERE department_id = 1;
```

> These examples assume Questions 13 and 12 have already established the relevant database objects. Function invocation syntax is intentionally not guessed: use the exact function name and parameters declared in the final Question 14 SQL file.

## Analytical skills demonstrated

- **Database engineering foundations:** relational design, primary/foreign keys, schema adjustments, CSV imports, and data integrity checks.
- **SQL analytics:** joins, aggregation, CTEs, subqueries, conditional metrics, grouped comparisons, and date transformations.
- **Advanced SQL:** window functions (`RANK`, `DENSE_RANK`, `LAG`/`LEAD`), rolling frames, grouping sets, views, and database functions.
- **Financial reconciliation:** correct claim/payment grain, collection rates, denial rates, and payer-level gaps.
- **Performance and communication:** execution-plan inspection, indexing trade-offs, annotated code, transparent limitations, and business-focused interpretation.

## Next steps

The SQL portion of the capstone is complete. Planned portfolio extensions include:

- **Year-over-year comparison:** Compare 2024 and 2025 complete-year performance and examine 2026 year-to-date results separately; avoid treating the partial 2026 period as a full-year equivalent.
- **BI dashboards:** Build Tableau or Power BI visuals for utilization, no-shows, provider performance, collections, denials, and payer revenue gaps.
- **Python analysis:** Reuse the prepared datasets and SQL outputs for exploratory analysis, data checks, and visualizations.
- **Repository polish:** Keep the final SQL scripts, schema/cleaning files, documented outputs, data dictionary, and any dashboard screenshots organized together.

---

**Project status: SQL analysis phase completed (14/14 questions).**  
*README refreshed November 7, 2026. All quoted numerical findings above were limited to verified saved analysis outputs or explicitly labeled source-data counts.*
