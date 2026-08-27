-- =========================================================
-- SECTION 1: INITIAL DATA CHECKS
-- =========================================================
---Count number of observations
SELECT COUNT(*) AS total_records
FROM births_raw;

---Find count of each GESTREC3 category
SELECT GESTREC3, COUNT (*) as group_count
FROM births_raw
GROUP BY GESTREC3;

-- =========================================================
-- SECTION 2: CREATE CLEANED DATASET
-- Remove records with unknown gestational age
-- =========================================================
CREATE TABLE births_clean AS
SELECT *
FROM births_raw 
WHERE GESTREC3 IN (1,2);

-- =========================================================
-- Section 3: Create preterm outcome
-- =========================================================
ALTER TABLE births_clean
ADD COLUMN preterm INTEGER;

UPDATE births_clean
SET preterm =
    CASE
        WHEN GESTREC3 = 1 THEN 1
        WHEN GESTREC3 = 2 THEN 0
    END;

---test that preterm logic worked
SELECT GESTREC3,
CASE 
	WHEN GESTREC3 = 1 THEN 1
	WHEN GESTREC3 = 2 THEN 0
	ELSE NULL
END AS preterm,
COUNT (*) AS preterm_count
FROM births_raw
GROUP BY preterm;

--check new table 
SELECT GESTREC3, COUNT(*) AS group_count
FROM births_clean
GROUP BY GESTREC3
ORDER BY GESTREC3;

---verify count of each level
SELECT preterm, COUNT(*) AS preterm_count
FROM births_clean
GROUP BY preterm;

-- =========================================================
-- Section 4: Create singleton birth dataset
-- =========================================================

---create singleton dataset
CREATE TABLE births_singles AS
SELECT *
FROM births_clean
WHERE DPLURAL = 1;

---count number of births in dplural variable
SELECT DPLURAL, COUNT(*) AS plural_count
FROM births_clean
GROUP BY DPLURAL;


-- =========================================================
-- Section 5: Query performance 
-- =========================================================

---Check query plan before creating index
EXPLAIN QUERY PLAN 
SELECT *
FROM births_clean
WHERE DPLURAL = 1; 

---result was SCAN births_clean
---execution time reported 14ms

---create index for DPLURAL
CREATE INDEX IF NOT EXISTS idx_births_clean_dplural
ON births_clean(DPLURAL);

--check query after creating index
EXPLAIN QUERY PLAN 
SELECT *
FROM births_clean
WHERE DPLURAL = 1; 
---resukt was SEARCH births_clean USING INDEX idx_births_clean_dplural (DPLURAL=?)
---execution time was 14ms
---query plan changed, even though the reported time was still 14ms



-- =========================================================
-- Section 6: Explore outcome variable
-- =========================================================

---check count of preterm in new table
SELECT preterm, COUNT (*) as preterm_count
FROM births_singles
GROUP BY preterm;

 -- =========================================================
-- Section 7: Explore predictor variables
-- =========================================================
---check FEDUC variable
SELECT FEDUC, COUNT (*) as fedu_count
FROM births_singles
GROUP BY FEDUC;

---check RF_GYHYPE variable
SELECT RF_GHYPE, COUNT (*) as rfghype_count
FROM births_singles
GROUP BY RF_GHYPE;

---check RF_PHYPE variable
SELECT RF_PHYPE, COUNT (*) as rfphype_count
FROM births_singles
GROUP BY RF_PHYPE;

---check RF_PDIAB variable
SELECT RF_PDIAB, COUNT (*) as rfpdiab_count
FROM births_singles
GROUP BY RF_PDIAB;

---check RF_GDIAB variable
SELECT RF_GDIAB, COUNT (*) as rfgdiab_count
FROM births_singles
GROUP BY RF_GDIAB;

---check cig_rec variable
SELECT CIG_REC, COUNT (*) as cig_count
FROM births_singles
GROUP BY CIG_REC;

---check precare5 variable
SELECT PRECARE5, COUNT (*) as precare_count
FROM births_singles
GROUP BY PRECARE5;

-- =========================================================
-- Section 8: Explore continuous variables
-- =========================================================

---check mager variable min/max
SELECT MIN(MAGER) AS min_mag, MAX(MAGER) AS max_mag, AVG(MAGER) AS avg_mag
FROM births_singles;

---check number of records for mothers under 18 or over 35
SELECT
	SUM(CASE WHEN MAGER < 18 THEN 1 ELSE 0 END) AS under_18,
	SUM(CASE WHEN MAGER >=35 THEN 1 ELSE 0 END) AS age_35_plus
FROM births_singles;


---check BMI variable min/max/avg
SELECT MIN(BMI) AS min_bmi, MAX(BMI) AS max_bmi, AVG(BMI) AS avg_bmi
FROM births_singles;

-- =========================================================
-- Section 9: Explore BMI 
-- =========================================================

---check BMI_R variable
SELECT BMI_R, COUNT(*) AS bmi_r_count
FROM births_singles
GROUP BY BMI_R
ORDER BY BMI_R;

---check raw BMI variable over 40
SELECT COUNT(*) AS bmi_over_40
FROM births_singles
WHERE BMI >= 40;


---check BMI and BMI_R to look at BMI code 99.9
SELECT BMI, BMI_R, COUNT(*) AS bmi_count
FROM births_singles
WHERE BMI_R <> 6 AND BMI >= 40
GROUP BY BMI, BMI_R;
---checking this means that I will use BMI_R for analysis instead


-- =========================================================
-- Section 10: Check missing/unknown values
-- =========================================================

---check MRACESHIP
SELECT MRACEHISP, COUNT(*) AS mrace
FROM births_singles
GROUP BY MRACEHISP;

---check MEDUC
SELECT MEDUC, COUNT (*) as medu_count
FROM births_singles
GROUP BY MEDUC;

---check null values
SELECT FEDUC, COUNT(*)
FROM births_singles
WHERE FEDUC = NULL;


---check null values for remaining variables
SELECT
	SUM(CASE WHEN FEDUC IS NULL THEN 1 ELSE 0 END) AS feduc_null,
	SUM(CASE WHEN MEDUC IS NULL THEN 1 ELSE 0 END) AS meduc_null,
	SUM(CASE WHEN RF_GDIAB IS NULL THEN 1 ELSE 0 END) AS rf_gdiab_null,
	SUM(CASE WHEN RF_PDIAB IS NULL THEN 1 ELSE 0 END) AS rf_pdiab_null,
	SUM(CASE WHEN RF_GHYPE IS NULL THEN 1 ELSE 0 END) AS rf_ghype_null,
	SUM(CASE WHEN RF_PHYPE IS NULL THEN 1 ELSE 0 END) AS rf_phype_null,
	SUM(CASE WHEN CIG_REC IS NULL THEN 1 ELSE 0 END) AS cig_rec_null,
	SUM(CASE WHEN PRECARE5 IS NULL THEN 1 ELSE 0 END) AS precare_null,
	SUM(CASE WHEN MAGER IS NULL THEN 1 ELSE 0 END) AS mager_null,
	SUM(CASE WHEN BMI_R IS NULL THEN 1 ELSE 0 END) AS bmi_r_null,
	SUM(CASE WHEN MRACEHISP IS NULL THEN 1 ELSE 0 END) AS mrace_null
FROM births_singles;