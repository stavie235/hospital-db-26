SELECT CONCAT(LEFT(s1.substance_name, 45), ' + ', LEFT(s2.substance_name, 45)) AS substance_pair,
       s1.substance_name AS substance_1,
       s2.substance_name AS substance_2,
       COUNT(DISTINCT CONCAT(p1.hospitalization_id, ':', p1.patient_id)) AS occurrences
FROM prescription p1
JOIN prescription p2
  ON p2.hospitalization_id = p1.hospitalization_id
 AND p2.patient_id = p1.patient_id
 AND p2.prescription_id > p1.prescription_id
 AND p1.start_date <= COALESCE(p2.end_date, p2.start_date)
 AND p2.start_date <= COALESCE(p1.end_date, p1.start_date)
JOIN drug_substance ds1 ON ds1.drug_id = p1.drug_id
JOIN drug_substance ds2
  ON ds2.drug_id = p2.drug_id
 AND ds2.substance_id > ds1.substance_id
JOIN active_substance s1 ON s1.substance_id = ds1.substance_id
JOIN active_substance s2 ON s2.substance_id = ds2.substance_id
GROUP BY s1.substance_id, s1.substance_name, s2.substance_id, s2.substance_name
ORDER BY occurrences DESC, substance_pair
LIMIT 3;
