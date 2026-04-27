SELECT CONCAT('Level ', tr.urgency_level, ' / ', COALESCE(d.name, 'No hospitalization')) AS urgency_department,
       tr.urgency_level,
       COALESCE(d.name, 'No hospitalization') AS referral_department,
       COUNT(*) AS triage_cases,
       ROUND(AVG(TIMESTAMPDIFF(MINUTE, tr.arrival_time, tr.outcome_time)), 2) AS avg_wait_minutes,
       ROUND(100 * SUM(CASE WHEN tr.hospitalization_id IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS hospitalization_pct
FROM triage_record tr
LEFT JOIN hospitalization h ON h.hospitalization_id = tr.hospitalization_id
LEFT JOIN department d ON d.department_id = h.department_id
GROUP BY tr.urgency_level, referral_department
ORDER BY tr.urgency_level, triage_cases DESC, referral_department;
