SELECT a.substance_id,
       LEFT(a.substance_name, 90) AS substance_name,
       COUNT(DISTINCT pa.patient_id) AS allergic_patients,
       COUNT(DISTINCT ds.drug_id) AS drugs_containing_substance
FROM active_substance a
LEFT JOIN patient_allergy pa ON pa.substance_id = a.substance_id
LEFT JOIN drug_substance ds ON ds.substance_id = a.substance_id
GROUP BY a.substance_id, a.substance_name
ORDER BY allergic_patients DESC, drugs_containing_substance DESC, substance_name
LIMIT 100;
