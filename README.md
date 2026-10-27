# Healthcare Database Capstone Project

## Project Overview

This project focuses on designing and building a healthcare database in PostgreSQL.

The goal of the project is to demonstrate my understanding of relational database design, SQL table creation, primary and foreign keys, data types, data imports, and troubleshooting database errors.

The database contains healthcare-related data including patients, providers, appointments, encounters, diagnoses, procedures, medications, claims, payments, departments, and insurance plans.


## Tools Used

- PostgreSQL
- pgAdmin
- SQL
- VS Code
- Git
- GitHub


## Database Structure

The database includes the following tables:

- departments
- insurance_plans
- pat
- providers
- appointments
- encounters
- diagnoses
- procedures
- medications
- claims
- payments


## Database Creation

I first created the healthcare database and designed the tables using PostgreSQL.

Primary keys were added to uniquely identify records, and foreign keys were used to create relationships between the tables.

Some foreign key columns were added later using ALTER TABLE because the referenced tables had not been created yet when I initially built the schema.


## Data Import

The data was imported from CSV files using the pgAdmin Import/Export tool.

During this process, I learned that tables with foreign key relationships must be imported in the correct order so that referenced records already exist.

The import order used was:

1. departments
2. insurance_plans
3. pat
4. providers
5. appointments
6. encounters
7. diagnoses
8. procedures
9. medications
10. claims
11. payments


## Issues Encountered and Changes Made

During the data import process, I encountered several errors that required me to troubleshoot the database schema and import configuration.

Some of the issues included:

- Foreign key constraint errors caused by importing child tables before parent tables
- CSV headers initially being treated as data
- Column order in a CSV not matching the table import order
- VARCHAR fields that were too short for some values
- A missing patient ID column in the medications table
- A table naming inconsistency between diagnosis and diagnoses
- Some encounters that did not have a scheduled appointment

I used ALTER TABLE statements to correct these issues without rebuilding the database.


## Schema Changes

Some of the changes made during testing included:

- Increased appointments.status from VARCHAR(10) to VARCHAR(15)
- Increased claims.claim_status from VARCHAR(10) to VARCHAR(20)
- Increased encounters.discharge_status from VARCHAR(20) to VARCHAR(25)
- Changed diagnosis_description to TEXT
- Renamed diagnosis to diagnoses
- Added patid to medications
- Allowed encounter appointment_id values to be NULL when an encounter was not connected to a scheduled appointment
- Added missing foreign key relationships


## What I Learned

This part of the project helped me better understand:

- Primary and foreign key relationships
- Referential integrity
- Table dependency order
- PostgreSQL data types
- ALTER TABLE
- CSV data imports
- Troubleshooting PostgreSQL errors
- Matching source data to a database schema
- Updating a database design after testing it with actual data


## Project Files

- `Capstone Project- CREATE healthcare DB & CREATE TABLE.sql`
  - Creates the database and original table structure

- `Capstone Project- Data Import & ALTER TABLE.sql`
  - Contains schema changes made while importing and validating the data


## Next Steps

The next phase of the project will focus on querying and analyzing the healthcare data using SQL.

