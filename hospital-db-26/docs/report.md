: Έγγραφο που συνοψίζει όλα τα βήματα της εργασίας σας, περιλαμβάνοντας screenshots,
για τα ερωτήματα 4 και 6.

## Ανάλυση Ερωτημάτων Q4 & Q6 — EXPLAIN / FORCE INDEX

### Q4 — Μέσος Όρος Αξιολόγησης Ιατρού

#### Εκτέλεση με index (idx_doctor_evaluation_doctor)

![EXPLAIN Q4 με index](screenshots/q4_with_index.png)

#### Εκτέλεση με FORCE INDEX (PRIMARY)

![EXPLAIN Q4 με FORCE INDEX](screenshots/q4_force_index.png)

#### Σύγκριση

| | Κανονική εκτέλεση | FORCE INDEX (PRIMARY) |
|---|---|---|
| key (doctor_evaluation) | idx_doctor_evaluation_doctor | PRIMARY |
| rows | 2 | 150 |
| Χρόνος εκτέλεσης | 0.020 sec | 0.021 sec |

Το ερώτημα Q4 αναζητά τις αξιολογήσεις συγκεκριμένου ιατρού (doctor_id = 2) στον πίνακα doctor_evaluation. Ο optimizer επιλέγει αυτόματα τον index idx_doctor_evaluation_doctor, εκτιμώντας 2 γραμμές αντί για πλήρη σάρωση. Με FORCE INDEX (PRIMARY), αναγκάζεται να χρησιμοποιήσει τον primary key (eval_id), ο οποίος δεν βοηθά στην αναζήτηση βάσει doctor_id, με αποτέλεσμα σάρωση 150 γραμμών. Ο χρόνος εκτέλεσης δεν διαφέρει αισθητά (0.020 vs 0.021 sec) γιατί ο μικρός πίνακας χωράει στη μνήμη χωρίς disk I/O. Σε μεγαλύτερο dataset, η διαφορά rows θα αντικατοπτριζόταν άμεσα στον χρόνο απόκρισης.

---

### Q6 — Ιστορικό Νοσηλειών Ασθενή

#### Εκτέλεση με index (idx_hospitalization_patient)

![EXPLAIN Q6 με index](screenshots/q6_with_index.png)

#### Εκτέλεση με FORCE INDEX (idx_hospitalization_icd)

![EXPLAIN Q6 με FORCE INDEX](screenshots/q6_force_index.png)

#### Σύγκριση

| | Κανονική εκτέλεση | FORCE INDEX (idx_hospitalization_icd) |
|---|---|---|
| key (hospitalization) | idx_hospitalization_patient | idx_hospitalization_icd |
| rows | 6 | 500 |
| Χρόνος εκτέλεσης | 0.023 sec | 0.020 sec |

Το ερώτημα Q6 εντοπίζει τις νοσηλείες συγκεκριμένου ασθενή (patient_id = 8) στον πίνακα hospitalization. Ο optimizer επιλέγει τον idx_hospitalization_patient, εκτιμώντας 6 γραμμές. Με FORCE INDEX στον idx_hospitalization_icd, ο οποίος αφορά το πεδίο icd10_code και όχι το patient_id, ο optimizer αδυνατεί να αξιοποιήσει τον index για το JOIN condition και εκτιμά σάρωση 500 γραμμών. Ο χρόνος παραμένει παρόμοιος (0.023 vs 0.020 sec) λόγω του μικρού μεγέθους του πίνακα που χωράει στο buffer pool. Η εκφώνηση αναφέρει ρητά ότι οι διαφορές στα query plans γίνονται ορατές με ικανό αριθμό δεδομένων — σε παραγωγικό σύστημα η διαφορά σε rows (6 vs 500) θα είχε άμεσο αντίκτυπο στον χρόνο εκτέλεσης.