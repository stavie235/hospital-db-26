WITH category_year_counts AS (
    SELECT i.category AS icd_category,
           YEAR(h.admission_date) AS admission_year,
           COUNT(*) AS admissions
    FROM hospitalization h
    JOIN ICD10 i ON i.icd_code = h.icd10_code
    GROUP BY i.category, YEAR(h.admission_date)
)
SELECT c1.icd_category,
       c1.admission_year AS year_1,
       c2.admission_year AS year_2,
       c1.admissions AS admissions_year_1,
       c2.admissions AS admissions_year_2
FROM category_year_counts c1
JOIN category_year_counts c2
  ON c2.icd_category = c1.icd_category
 AND c2.admission_year = c1.admission_year + 1
 AND c2.admissions = c1.admissions
WHERE c1.admissions >= 5
  AND c2.admissions >= 5
ORDER BY c1.icd_category, c1.admission_year;
