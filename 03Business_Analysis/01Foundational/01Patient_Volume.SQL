/* Business analysis
	Count total healcare encounters and unique patients by month/quarter/year */

-- Total appointments that showed

SELECT Date_TRUNC('month', encounter_date) AS Mon_ENC,
	COUNT(encounter_id) AS Total_ENC
FROM encounters
GROUP BY Date_TRUNC('month', encounter_date)
ORDER BY Mon_ENC DESC

-- Total encounters and unique patients by month

SELECT Date_TRUNC('month', encounter_date) AS Mon_ENC,
	COUNT(encounter_id) AS Total_ENC,
	COUNT (DISTINCT patid) AS unique_patients
FROM encounters
GROUP BY Date_TRUNC('month', encounter_date)
ORDER BY Mon_ENC DESC

-- -- Total encounters and unique patients by quarter


SELECT Date_TRUNC('quarter', encounter_date) AS QRT_ENC,
	COUNT(encounter_id) AS Total_ENC,
	COUNT (DISTINCT patid) AS unique_patients
FROM encounters
GROUP BY Date_TRUNC('quarter', encounter_date)
ORDER BY QRT_ENC DESC


-- Total encounters and unique patients by year


SELECT Date_TRUNC('year', encounter_date) AS Yearly_ENC,
	COUNT(encounter_id) AS Total_Arrivals,
	COUNT (DISTINCT patid) AS unique_patients
FROM encounters
GROUP BY Date_TRUNC('year', encounter_date)
ORDER BY Yearly_ENC DESC
