SELECT CONCAT(d.name, ' / ', YEAR(h.admission_date), ' / ', h.ken_code) AS department_year_ken,
       d.name AS department,
       YEAR(h.admission_date) AS admission_year,
       h.ken_code,
       p.insurance_provider,
       COUNT(*) AS hospitalizations,
       ROUND(SUM(k.base_cost), 2) AS base_ken_revenue,
       ROUND(SUM(
           CASE
               WHEN h.discharge_date IS NOT NULL
                AND DATEDIFF(h.discharge_date, h.admission_date) > k.alos_days
               THEN GREATEST(COALESCE(h.total_cost, k.base_cost) - k.base_cost, 0)
               ELSE 0
           END
       ), 2) AS extra_alos_revenue,
       ROUND(SUM(COALESCE(h.total_cost, k.base_cost)), 2) AS total_revenue
FROM hospitalization h
JOIN department d ON d.department_id = h.department_id
JOIN patient p ON p.patient_id = h.patient_id
LEFT JOIN ken k ON k.ken_code = h.ken_code
GROUP BY d.department_id, d.name, YEAR(h.admission_date), h.ken_code, p.insurance_provider
ORDER BY admission_year, department, h.ken_code, p.insurance_provider;
