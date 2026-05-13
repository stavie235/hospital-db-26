# Master Guide — Νοσοκομείο Υγειόπολης
## Βάσεις Δεδομένων ΣΗΜΜΥ/ΕΜΠ 2025-2026

> Αυτός ο οδηγός καλύπτει **θεωρία + project-specific ανάλυση** για κάθε trigger, index και query.
> Στόχος: να μπορείς να αιτιολογήσεις κάθε σχεδιαστική επιλογή στην προφορική επίδειξη.

---

## Πίνακας Περιεχομένων

1. [Θεωρία Triggers](#μέρος-1--θεωρία-triggers)
2. [Θεωρία Indexes](#μέρος-2--θεωρία-indexes)
3. [Schema Overview](#μέρος-3--schema-overview)
4. [Κάθε Trigger αναλυτικά](#μέρος-4--κάθε-trigger-αναλυτικά)
5. [Κάθε Index αναλυτικά](#μέρος-5--κάθε-index-αναλυτικά)
6. [Query-by-Query ανάλυση](#μέρος-6--query-by-query-ανάλυση-q01-q15)
7. [Flashcards επίδειξης](#μέρος-7--flashcards-επίδειξης)
8. [Schema Design Decisions](#μέρος-8--schema-design-decisions)

---

# ΜΕΡΟΣ 1 — Θεωρία Triggers

## 1.1 Τι είναι trigger

Ένα trigger είναι **αυτόματος κώδικας που εκτελείται από τη ΒΔ** ως αντίδραση σε ένα event (INSERT, UPDATE, DELETE) σε έναν πίνακα. Δεν τον καλεί η εφαρμογή — τον εκτελεί αυτόματα ο RDBMS.

```
event (INSERT/UPDATE/DELETE)
        ↓
  [BEFORE trigger]   ← εδώ μπορείς να αλλάξεις NEW.*
        ↓
  εγγραφή γραμμής στη ΒΔ
        ↓
  [AFTER trigger]    ← εδώ η γραμμή έχει ήδη γραφτεί
```

## 1.2 BEFORE vs AFTER — η πιο σημαντική διάκριση

| | BEFORE | AFTER |
|---|---|---|
| Πότε εκτελείται | Πριν γραφτεί η γραμμή | Αφού γραφτεί η γραμμή |
| Μπορείς να αλλάξεις NEW.* | **ΝΑΙ** | **ΌΧΙ** (read-only) |
| Μπορείς να κάνεις SIGNAL (error) | ΝΑΙ | ΝΑΙ |
| Μπορείς να κάνεις UPDATE ίδιο πίνακα | ΔΕΝ ΧΡΕΙΑΖΕΤΑΙ (αλλάζεις NEW.*) | **ΌΧΙ** (infinite loop / error) |
| Μπορείς να κάνεις UPDATE άλλο πίνακα | ΝΑΙ | **ΝΑΙ** |
| Χρησιμοποιείται για | Validation + τροποποίηση τιμής | Cascading updates σε άλλους πίνακες |

**Κανόνας του αντίχειρα:**
- Θέλω να **αποτρέψω** ή να **τροποποιήσω** την εγγραφή → `BEFORE`
- Θέλω να **αντιδράσω** στην εγγραφή (αλλάζω άλλον πίνακα) → `AFTER`

## 1.3 NEW και OLD — πότε υπάρχουν

| Event | NEW | OLD |
|---|---|---|
| INSERT | ΝΑΙ (η νέα γραμμή) | ΌΧΙ |
| UPDATE | ΝΑΙ (η νέα τιμή) | ΝΑΙ (η παλιά τιμή) |
| DELETE | ΌΧΙ | ΝΑΙ (η διαγραμμένη γραμμή) |

**Παράδειγμα από το project:**
```sql
-- trg_hospitalization_cost: BEFORE UPDATE ON hospitalization
IF OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL THEN
    -- OLD: η παλιά γραμμή (χωρίς discharge_date)
    -- NEW: η νέα γραμμή (με discharge_date που μόλις δόθηκε)
    SET NEW.total_cost = v_base_cost + ...;
    -- Τροποποιούμε NEW.total_cost πριν γραφτεί → μόνο σε BEFORE
END IF;
```

## 1.4 Γιατί όχι UPDATE ίδιο πίνακα σε AFTER trigger

Στο MariaDB/MySQL, ένα `AFTER UPDATE ON hospitalization` trigger **δεν μπορεί να κάνει** `UPDATE hospitalization ...` γιατί:
1. Ο RDBMS ακόμα "κρατάει" τον πίνακα locked για το τρέχον statement
2. Θα προκαλούσε αναδρομική κλήση του ίδιου trigger → infinite loop
3. Το σύστημα το απαγορεύει με error

**Λύση:** Χρησιμοποίησε `BEFORE` trigger και τροποποίησε το `NEW.*` αντί για ξεχωριστό UPDATE.

## 1.5 Trigger vs CHECK constraint

| | CHECK | TRIGGER |
|---|---|---|
| Μπορεί να ελέγξει τιμές **ίδιας γραμμής** | ΝΑΙ | ΝΑΙ |
| Μπορεί να ελέγξει **άλλο πίνακα** | **ΌΧΙ** | **ΝΑΙ** |
| Μπορεί να ελέγξει **αθροίσματα/counts** | ΌΧΙ | ΝΑΙ |
| Μπορεί να **τροποποιήσει** τιμή | ΌΧΙ | ΝΑΙ (BEFORE) |
| Επιβάλλεται αυτόματα | ΝΑΙ | ΝΑΙ |

**Παραδείγματα από το project:**
- `CHECK (age >= 18 AND age <= 80)` → αρκεί CHECK (μόνο στήλες ίδιας γραμμής)
- `trg_prescription_allergy_check` → **πρέπει trigger** (ελέγχει patient_allergy + drug_substance = δύο άλλους πίνακες)
- `trg_shift_monthly_limit` → **πρέπει trigger** (μετράει COUNT από shift_assignment = άλλος πίνακας)

**Φράση για επίδειξη:** *"Το CHECK constraint δεν μπορεί να κοιτάξει άλλους πίνακες. Αυτός ο κανόνας απαιτεί να ελέγξω τον πίνακα X, οπότε πρέπει trigger."*

## 1.6 Trigger vs Foreign Key

Το FK εξασφαλίζει **αναφορική ακεραιότητα** (η τιμή υπάρχει στον αναφερόμενο πίνακα) αλλά δεν μπορεί να εφαρμόσει **business logic**.

| | FK | TRIGGER |
|---|---|---|
| "Αυτό το ID υπάρχει στον άλλο πίνακα" | ΝΑΙ | ΝΑΙ |
| "Αν condition X, τότε Y πρέπει να είναι Z" | **ΌΧΙ** | **ΝΑΙ** |
| Cascading DELETE/UPDATE | ΝΑΙ | ΝΑΙ |

**Παράδειγμα:** Το "Ειδικευόμενος πρέπει να έχει supervisor" είναι conditional business logic — ένα FK δεν μπορεί να το εκφράσει.

## 1.7 Trigger vs Application Layer

**Πότε βάζεις τον κανόνα στη ΒΔ (trigger):**
- Ο κανόνας πρέπει να ισχύει **ανεξάρτητα από το ποιος γράφει** στη ΒΔ (εφαρμογή, SQL script, admin)
- Ο κανόνας είναι **domain invariant** — δεν πρέπει ποτέ να παραβιαστεί
- Η εκφώνηση λέει ρητά: *"επιβάλλονται αυτόματα από το σύστημα και δεν μπορούν να παρακαμφθούν"*

**Πότε αφήνεις στην εφαρμογή:**
- Ο κανόνας αλλάζει συχνά (business rules που εξαρτώνται από config)
- Απαιτεί πολύπλοκη λογική που η ΒΔ δεν μπορεί να εκφράσει εύκολα

**Ο κανόνας minimum staffing (≥3 ιατροί, ≥6 νοσηλευτές, ≥2 διοικητικοί ανά βάρδια) επιβάλλεται μέσω BEFORE DELETE trigger** (`trg_shift_min_staffing`). Δεν μπορεί να ελεγχθεί στο INSERT γιατί η βάρδια στελεχώνεται σταδιακά — το 1ο άτομο θα αποτύγχανε πάντα. Αντ' αυτού, μόλις η βάρδια φτάσει σε έγκυρη στελέχωση, κάθε DELETE που θα την υποβάθμιζε κάτω από τα ελάχιστα μπλοκάρεται αυτόματα.

---

# ΜΕΡΟΣ 2 — Θεωρία Indexes

## 2.1 Τι είναι B-tree index

Ένα index είναι μια **ξεχωριστή δομή δεδομένων** (B-tree) που η ΒΔ διατηρεί παράλληλα με τον πίνακα. Αντί να ψάχνει κάθε γραμμή (full table scan), ακολουθεί το δέντρο και βρίσκει τις γραμμές σε O(log n).

```
Πίνακας hospitalization (500 γραμμές):
Χωρίς index: ο optimizer διαβάζει και τις 500 γραμμές → O(n)

Με index idx_hospitalization_patient ON (patient_id):
B-tree διαλεγμένο κατά patient_id:
         [250]
        /     \
    [125]     [375]
    / \        / \
  [8] [62]  [300][450]
   ↓
  rows με patient_id=8 → O(log n)
```

**Mental model:** Σκέψου ευρετήριο βιβλίου — αντί να διαβάσεις όλο το βιβλίο, πας στο ευρετήριο, βρίσκεις τη σελίδα, πηγαίνεις απευθείας.

## 2.2 PRIMARY KEY vs UNIQUE vs INDEX

| | PRIMARY KEY | UNIQUE INDEX | INDEX (regular) |
|---|---|---|---|
| Επιτρέπει NULL | ΌΧΙ | ΝΑΙ (1 NULL) | ΝΑΙ (πολλά NULL) |
| Επιτρέπει duplicates | ΌΧΙ | ΌΧΙ | **ΝΑΙ** |
| Ανά πίνακα | 1 | πολλά | πολλά |
| Clustered (InnoDB) | **ΝΑΙ** — τα data αποθηκεύονται με αυτή τη σειρά | ΌΧΙ | ΌΧΙ |
| Χρήση | Μοναδική ταυτοποίηση γραμμής | Εξασφάλιση μοναδικότητας | Επιτάχυνση queries |

**Σημαντικό για MariaDB/InnoDB:** Το PRIMARY KEY είναι **clustered** — τα δεδομένα του πίνακα αποθηκεύονται φυσικά ταξινομημένα κατά PK. Κάθε secondary index αποθηκεύει την PK τιμή για να βρει την πραγματική γραμμή.

## 2.3 Composite Index — η σειρά μετράει

```sql
CREATE INDEX idx_shift_dept_date ON shift(department_id, shift_date);
```

Αυτό το index είναι **ταξινομημένο πρώτα κατά department_id, μετά κατά shift_date**.

**Leftmost prefix rule:** Ο optimizer μπορεί να χρησιμοποιήσει αυτό το index για:
- `WHERE department_id = 3` ✓ (πρώτη στήλη)
- `WHERE department_id = 3 AND shift_date = '2026-04-06'` ✓ (και οι δύο στήλες)
- `WHERE shift_date = '2026-04-06'` ✗ (δεν ξεκινά από την πρώτη στήλη)

**Γιατί αυτή η σειρά για το Q08/Q12:** Τα queries φιλτράρουν `WHERE department_id = X AND shift_date = Y` — η πιο επιλεκτική στήλη (department_id) πρώτη.

## 2.4 Πότε ο optimizer ΧΡΗΣΙΜΟΠΟΙΕΙ index

1. **Equality:** `WHERE patient_id = 8` → χρησιμοποιεί index on patient_id
2. **Range:** `WHERE age < 35` → χρησιμοποιεί index on age
3. **JOIN:** `JOIN department d ON d.department_id = h.department_id` → χρησιμοποιεί index on department_id
4. **ORDER BY / GROUP BY:** Αν η ταξινόμηση ταυτίζεται με το index, αποφεύγει filesort
5. **Covering index:** Αν το index περιέχει όλες τις στήλες που χρειάζεται το query → δεν χρειάζεται να πάει στον πίνακα καθόλου

## 2.5 Πότε ο optimizer ΑΓΝΟΕΙ index

1. **Function on indexed column:**
   ```sql
   WHERE YEAR(admission_date) = 2025  -- ✗ ο optimizer δεν μπορεί να χρησιμοποιήσει index on admission_date
   WHERE admission_date >= '2025-01-01' AND admission_date < '2026-01-01'  -- ✓
   ```
   *Σημείωση: Στο project χρησιμοποιούμε YEAR() στα queries (Q01, Q02 κ.λπ.) — οι αντίστοιχοι indexes βοηθούν μέσω JOIN αλλά το YEAR() filter γίνεται full scan. Αυτό είναι επίτηδες design trade-off για readability.*

2. **Low cardinality:** Αν μια στήλη έχει μόνο 3 distinct τιμές (π.χ. staff_type: doctor/nurse/administrative), ο optimizer συχνά κάνει full scan γιατί ούτως ή άλλως θα διαβάσει πολλές γραμμές.

3. **Πολύ μικρός πίνακας:** Αν ο πίνακας χωράει σε 1-2 pages, full scan είναι εξίσου γρήγορο.

4. **OR conditions:** `WHERE a = 1 OR b = 2` — δύσκολο να χρησιμοποιηθεί composite index.

## 2.6 Cardinality

**Cardinality** = πόσες distinct τιμές έχει μια στήλη.

| Στήλη | Cardinality | Αξίζει index; |
|---|---|---|
| patient_id (500 ασθενείς) | ~500 | ΝΑΙ (πολύ high) |
| department_id (15 τμήματα) | 15 | ΝΑΙ (medium, χρησιμοποιείται σε JOIN) |
| staff_type (3 τιμές) | 3 | ΌΧΙ μόνο για αυτό, αλλά ΝΑΙ σε composite |
| urgency_level (1-5) | 5 | Μόνο αν το query ψάχνει συγκεκριμένο επίπεδο |

## 2.7 Ανάγνωση EXPLAIN output

```sql
EXPLAIN SELECT ... FROM hospitalization h JOIN patient p ON p.patient_id = h.patient_id WHERE p.patient_id = 8;
```

| id | select_type | table | type | possible_keys | key | rows | Extra |
|---|---|---|---|---|---|---|---|
| 1 | SIMPLE | p | const | PRIMARY | PRIMARY | 1 | |
| 1 | SIMPLE | h | ref | idx_hospitalization_patient | idx_hospitalization_patient | 6 | |

**Τι σημαίνει το `type`:**
- `ALL` → full table scan (κακό για μεγάλους πίνακες)
- `index` → full index scan (καλύτερο από ALL)
- `range` → index range scan (καλό)
- `ref` → index lookup για non-unique key (πολύ καλό)
- `const` / `eq_ref` → το καλύτερο — βρίσκει ακριβώς 1 γραμμή

**`rows`:** Εκτίμηση πόσες γραμμές θα εξεταστούν. Λιγότερες = καλύτερο.

**`Extra`:**
- `Using index` → covering index (δεν χρειάστηκε να πάει στον πίνακα)
- `Using filesort` → sorting γίνεται εκτός index (μπορεί να βελτιωθεί)
- `Using where` → WHERE filter μετά την ανάκτηση

## 2.8 Πότε ΔΕΝ βάζεις index

1. **Write-heavy tables:** Κάθε INSERT/UPDATE/DELETE πρέπει να ενημερώσει και τα indexes → overhead
2. **Πολύ μικρά tables** (π.χ. procedure_room με 10 γραμμές): full scan είναι εξίσου γρήγορο
3. **Low cardinality μόνη της:** Το staff_type (3 τιμές) μόνο του δεν αξίζει index
4. **Στήλες που χρησιμοποιούνται μόνο σε SELECT ***: Αν δεν υπάρχει WHERE/JOIN/ORDER BY, ο index δεν βοηθά

---

# ΜΕΡΟΣ 3 — Schema Overview

## 3.1 Ιεραρχία προσωπικού (ISA)

```
staff (γονικός πίνακας)
├── staff_id (PK)
├── amka, first_name, last_name, age, email, phone
├── hiring_date, staff_type, photo_url, description
│
├── doctor (staff_id FK → staff)
│   ├── license_number, specialty, rank
│   └── supervisor_id (self-referencing FK → doctor)
│
├── nurse (staff_id FK → staff)
│   ├── rank
│   └── department_id FK → department
│
└── administrative (staff_id FK → staff)
    ├── role, office_name
    └── department_id FK → department
```

**Γιατί ISA και όχι ένας πίνακας:** Ο ένας πίνακας θα είχε πολλά NULL (π.χ. η specialty μόνο για doctors, το rank διαφορετικής σημασίας για nurses). Το ISA εξασφαλίζει ότι κάθε τύπος έχει μόνο τα attributes που του ανήκουν, με type-specific constraints.

**ON DELETE CASCADE:** Αν διαγραφεί γραμμή από `staff`, διαγράφεται αυτόματα η αντίστοιχη γραμμή από `doctor/nurse/administrative`.

## 3.2 Κεντρικός πίνακας: hospitalization

Το `hospitalization` είναι ο "κόμβος" — σχεδόν όλα τα entities συνδέονται σε αυτόν:

```
patient ──────────────────────────────────────┐
bed ──────────────────────────────────────────┤
department ───────────────────────────────────┤
ken ──────────────────────────────────────────┤→ hospitalization
ICD10 ────────────────────────────────────────┘
         │
         ├──→ triage_record
         ├──→ evaluation
         ├──→ doctor_evaluation
         ├──→ lab_test
         ├──→ medical_procedure
         └──→ prescription
```

## 3.3 Reference tables (δεδομένα από εξωτερικές πηγές)

| Πίνακας | Πηγή | Περιεχόμενο |
|---|---|---|
| ICD10 | Υπ. Υγείας | Κωδικοί νόσων |
| ken | Υπ. Υγείας | Κλειστά Ενοποιημένα Νοσήλια |
| drug | EMA Article 57 | Εγκεκριμένα φάρμακα ΕΟΧ |
| active_substance | EMA Article 57 | Δραστικές ουσίες |
| procedure_catalog | Υπ. Υγείας | Ιατρικές πράξεις |
| lab_test_catalog | Υπ. Υγείας | Εργαστηριακές εξετάσεις |

## 3.4 M:N σχέσεις

| Junction table | Συνδέει | Επιπλέον πληροφορία |
|---|---|---|
| doctor_department | doctor ↔ department | (καμία) |
| drug_substance | drug ↔ active_substance | (καμία) |
| patient_allergy | patient ↔ active_substance | (καμία) |
| shift_assignment | shift ↔ staff | (καμία) |
| procedure_assistant | medical_procedure ↔ staff | role |

## 3.5 Κυκλική εξάρτηση — department ↔ doctor

**Πρόβλημα:** 
- `department` χρειάζεται `director_id → doctor`
- `nurse` και `administrative` χρειάζονται `department_id → department`
- `doctor` χρειάζεται να δημιουργηθεί ΠΡΙΝ το `department` (για να έχουμε director_id)
- Αλλά `doctor` extends `staff` — δεν εξαρτάται από `department`

**Λύση:** Δημιουργία `department` ΧΩΡΙΣ τo FK director_id, και μετά προσθήκη με `ALTER TABLE`:
```sql
ALTER TABLE department ADD CONSTRAINT fk_department_director
    FOREIGN KEY (director_id) REFERENCES doctor(staff_id)
    ON DELETE SET NULL ON UPDATE CASCADE;
```

## 3.6 Minimum staffing — BEFORE DELETE trigger

**Minimum staffing (≥3 ιατροί, ≥6 νοσηλευτές, ≥2 διοικητικοί ανά βάρδια):**
Υλοποιείται με `trg_shift_min_staffing` (BEFORE DELETE ON shift_assignment). Η λογική: δεν μπορεί να ελεγχθεί στο INSERT γιατί η βάρδια χτίζεται σταδιακά — το 1ο άτομο θα αποτύγχανε πάντα. Αντ' αυτού, μόλις η βάρδια αποκτήσει έγκυρη στελέχωση, η αφαίρεση ατόμου που θα την έφερνε κάτω από τα ελάχιστα μπλοκάρεται αυτόματα.

---

# ΜΕΡΟΣ 4 — Κάθε Trigger Αναλυτικά

## Trigger 1 & 2: trg_doctor_supervisor_insert / trg_doctor_supervisor_update

**Τι κάνει:** Επιβάλλει:
- Ειδικευόμενος → **πρέπει** να έχει supervisor
- Διευθυντής → **δεν μπορεί** να έχει supervisor

**BEFORE ή AFTER:** `BEFORE INSERT/UPDATE` — θέλουμε να **αποτρέψουμε** την εγγραφή αν παραβιάζεται ο κανόνας. Χρησιμοποιούμε `SIGNAL SQLSTATE '45000'` για να πετάξουμε error.

**Γιατί trigger και όχι CHECK:**
`CHECK (rank = 'Ειδικευόμενος' AND supervisor_id IS NOT NULL)` δεν αρκεί γιατί η συνθήκη είναι **conditional** (εξαρτάται από το rank). Το CHECK δεν μπορεί να εκφράσει "ΑΝ rank=X ΤΟΤΕ supervisor πρέπει να είναι Y".

**Ποια rule της εκφώνησης:** *"Οι ειδικευόμενοι έχουν υποχρεωτικά επόπτη, ενώ οι Διευθυντές δεν έχουν επόπτη."*

**Τι θα έσπαγε χωρίς αυτό:** Θα μπορούσες να εισάγεις Ειδικευόμενο χωρίς επόπτη (επικίνδυνο ιατρικά) ή Διευθυντή με επόπτη (λογικά άτοπο στη σχεσιακή ιεραρχία).

**Γιατί και INSERT και UPDATE:** Ο κανόνας πρέπει να ισχύει και κατά την αρχική εισαγωγή και κατά την αλλαγή rank ή supervisor.

**Πιθανή ερώτηση:** *"Γιατί χρειάζεσαι δύο triggers (insert + update) αντί για έναν;"*
**Απάντηση:** Στο MariaDB δεν μπορείς να ορίσεις trigger που πυροδοτείται για δύο events ταυτόχρονα. Πρέπει ξεχωριστός trigger για INSERT και ξεχωριστός για UPDATE.

---

## Trigger 3 & 4: trg_doctor_no_cycle_insert / trg_doctor_no_cycle_update

**Τι κάνει:** Απαγορεύει κυκλική αλυσίδα εποπτείας (π.χ. A→B→A, ή A→B→C→A).

**Λογική:**
```sql
SET current_sup = NEW.supervisor_id;
WHILE current_sup IS NOT NULL AND max_depth < 50 DO
    IF current_sup = NEW.staff_id THEN → cycle found → SIGNAL error
    SELECT supervisor_id INTO current_sup FROM doctor WHERE staff_id = current_sup;
    -- ανεβαίνουμε στην ιεραρχία ένα επίπεδο
END WHILE;
```
Ανεβαίνει τη supervision chain μέχρι να φτάσει σε NULL (Διευθυντή) ή να βρει κύκλο.

**Γιατί BEFORE:** Θέλουμε να αποτρέψουμε την εγγραφή.

**Γιατί trigger και όχι άλλο mechanism:** Η ανίχνευση κύκλου σε self-referencing σχέση απαιτεί traversal της ιεραρχίας — δεν υπάρχει SQL constraint για αυτό. Μόνο trigger (ή application code) μπορεί να το κάνει.

**max_depth = 50:** Safety measure — αν η ιεραρχία είναι πάνω από 50 επίπεδα (αδύνατο σε πραγματικό νοσοκομείο), σταματάμε για να αποφύγουμε infinite loop.

**Ποια rule:** *"Απαγορεύεται η κυκλική αλυσίδα εποπτείας."*

**Τι θα έσπαγε χωρίς αυτό:** Το Q13 (recursive CTE για ιεραρχία) θα έπεφτε σε infinite recursion.

---

## Trigger 5: trg_prescription_allergy_check

**Τι κάνει:** Πριν κάθε νέα συνταγογράφηση, ελέγχει αν ο ασθενής έχει αλλεργία σε κάποια δραστική ουσία του φαρμάκου.

```sql
SELECT COUNT(*) INTO allergy_count
FROM drug_substance ds
JOIN patient_allergy pa ON ds.substance_id = pa.substance_id
WHERE ds.drug_id = NEW.drug_id AND pa.patient_id = NEW.patient_id;
IF allergy_count > 0 THEN SIGNAL error;
```

**BEFORE INSERT:** Πρέπει να αποτρέψουμε την εγγραφή.

**Γιατί trigger και όχι CHECK:** Ο έλεγχος αφορά **δύο άλλους πίνακες** (drug_substance, patient_allergy) — το CHECK δεν μπορεί να "κοιτάξει" άλλους πίνακες.

**Γιατί trigger και όχι FK:** Δεν είναι θέμα αναφορικής ακεραιότητας — είναι business rule: "αν η ουσία του φαρμάκου βρίσκεται στις αλλεργίες του ασθενή, απαγόρευση".

**Ποια rule:** *"Απαγορεύεται η συνταγογράφηση φαρμάκου αν κάποια από τις δραστικές ουσίες του βρίσκεται στις αλλεργίες του ασθενή."*

**Πιθανή ερώτηση:** *"Τι γίνεται αν μια αλλεργία προστεθεί ΜΕΤΑ από μια συνταγογράφηση;"*
**Απάντηση:** Ο trigger ελέγχει μόνο κατά την εισαγωγή νέας συνταγογράφησης — δεν ακυρώνει υπάρχουσες. Αυτό είναι σωστό: η αλλεργία ανακαλύφθηκε μετά, οπότε η προηγούμενη συνταγογράφηση ήταν valid. Μελλοντικές συνταγογραφήσεις θα μπλοκαριστούν.

---

## Trigger 6 & 7: trg_evaluation_discharged / trg_doctor_evaluation_check

**trg_evaluation_discharged:**
- Επιτρέπει αξιολόγηση νοσηλείας **μόνο αν** υπάρχει `discharge_date`
- BEFORE INSERT on evaluation

**trg_doctor_evaluation_check:**
- (α) Νοσηλεία πρέπει να είναι ολοκληρωμένη (discharge_date IS NOT NULL)
- (β) Ο ιατρός πρέπει να έχει συνταγογραφήσει κατά τη νοσηλεία αυτή

```sql
SELECT COUNT(*) INTO v_rx_count FROM prescription
WHERE hospitalization_id = NEW.hospitalization_id AND doctor_id = NEW.doctor_id;
IF v_rx_count = 0 THEN SIGNAL error;
```

**Γιατί trigger:** Ελέγχει άλλους πίνακες (hospitalization για discharge_date, prescription για συνταγογράφηση).

**Ποια rule:** *"Αξιολόγηση επιτρέπεται μόνο σε ασθενείς με ολοκληρωμένη νοσηλεία. Ο ασθενής μπορεί να αξιολογήσει κάθε ιατρό που συνταγογράφησε κατά τη νοσηλεία του."*

**Πιθανή ερώτηση:** *"Γιατί ο έλεγχος discharge_date γίνεται δύο φορές — μία για evaluation και μία για doctor_evaluation;"*
**Απάντηση:** Επειδή είναι δύο ξεχωριστοί πίνακες με ξεχωριστά triggers. Το trg_doctor_evaluation_check ελέγχει ΕΠΙΠΛΕΟΝ και την ύπαρξη συνταγογράφησης.

---

## Triggers 8-12: Βάρδιες (Shift constraints)

### trg_shift_monthly_limit

**Τι κάνει:** Μηνιαίο όριο βαρδιών:
- Ιατροί: ≤ 15/μήνα
- Νοσηλευτές: ≤ 20/μήνα
- Διοικητικό: ≤ 25/μήνα

**Λογική:**
```sql
-- μετρά βάρδιες τρέχοντος μήνα για αυτό το μέλος
SELECT COUNT(*) INTO v_month_count FROM shift_assignment sa
JOIN shift s ON sa.shift_id = s.shift_id
WHERE sa.staff_id = NEW.staff_id
  AND YEAR(s.shift_date) = YEAR(v_shift_date)
  AND MONTH(s.shift_date) = MONTH(v_shift_date);
```

**BEFORE INSERT on shift_assignment** — αποτρέπουμε την ανάθεση.

**Γιατί trigger:** Αθροιστικός κανόνας (COUNT από άλλο πίνακα) — αδύνατο με CHECK.

---

### trg_shift_rest_period

**Τι κάνει:** Ελάχιστο 8 ώρες ανάπαυσης μεταξύ διαδοχικών βαρδιών του ίδιου ατόμου.

**Ωράρια:**
- morning: 07:00-15:00
- afternoon: 15:00-23:00
- night: 23:00-07:00 (επόμενη μέρα)

**Λογική overlap με 8h buffer:**
Για κάθε υπάρχουσα βάρδια του ατόμου:
```
existing_end + 8h > new_start   (παλιά βάρδια τελειώνει πολύ κοντά στην καινούρια)
AND
new_end + 8h > existing_start   (καινούρια βάρδια τελειώνει πολύ κοντά στην παλιά)
```
Αν ισχύουν και οι δύο → conflict → SIGNAL error.

**Παράδειγμα conflict:**
- Existing: night 23:00-07:00 (Τρίτη βράδυ → Τετάρτη πρωί)
- New: morning 07:00-15:00 (Τετάρτη)
- existing_end = 07:00 Τετ, existing_end + 8h = 15:00 Τετ
- new_start = 07:00 Τετ
- 15:00 > 07:00 → conflict! (δεν έχουν περάσει 8 ώρες)

**Γιατί trigger:** Εξαρτάται από τις υπάρχουσες βάρδιες στον πίνακα shift_assignment/shift.

---

### trg_shift_consecutive_nights

**Τι κάνει:** Απαγορεύει 4+ συνεχόμενες νυχτερινές βάρδιες.

**Λογική:** Αν η νέα βάρδια είναι night, μετράει αν υπάρχουν night βάρδιες τις 3 προηγούμενες νύχτες. Αν και οι 3 είναι night → reject.

```sql
AND s.shift_date IN (
    DATE_SUB(v_new_date, INTERVAL 1 DAY),
    DATE_SUB(v_new_date, INTERVAL 2 DAY),
    DATE_SUB(v_new_date, INTERVAL 3 DAY)
);
IF v_night_count >= 3 THEN SIGNAL error;
```

**Σημείωση:** Ελέγχει ακριβώς τις 3 προηγούμενες νύχτες. Αν λείπει μία (π.χ. Δευτέρα-Τετάρτη με κενό Τρίτη), δεν θεωρείται "συνεχόμενες" — σωστό κατά την εκφώνηση.

---

### trg_shift_trainee_requires_senior

**Τι κάνει:** Αν ο νέος εργαζόμενος στη βάρδια είναι Ειδικευόμενος, ελέγχει αν υπάρχει ήδη στη βάρδια τουλάχιστον ένας Επιμελητής Α ή Διευθυντής.

```sql
SELECT COUNT(*) INTO v_senior_count
FROM shift_assignment sa JOIN doctor d ON sa.staff_id = d.staff_id
WHERE sa.shift_id = NEW.shift_id
  AND d.`rank` IN ('Επιμελητής Α', 'Διευθυντής');
IF v_senior_count = 0 THEN SIGNAL error;
```

**Σημαντικό:** Αυτό σημαίνει ότι **πρώτα πρέπει να μπει ο senior** και μετά ο Ειδικευόμενος. Η σειρά εισαγωγής έχει σημασία!

**Γιατί trigger:** Cross-table check (ελέγχει shift_assignment + doctor).

**Ποια rule:** *"Σε κάθε βάρδια που συμμετέχει ειδικευόμενος, πρέπει να είναι παρών τουλάχιστον ένας Επιμελητής Α ή Διευθυντής."*

---

## Triggers 12-14: Επεμβάσεις (Procedure constraints)

### trg_procedure_room_overlap

**Τι κάνει:** Δεν επιτρέπει δύο ταυτόχρονες επεμβάσεις στον ίδιο χώρο.

**Λογική overlap:**
```sql
WHERE room_id = NEW.room_id
  AND NEW.start_time < COALESCE(end_time, '9999-12-31')  -- νέα ξεκινά πριν τελειώσει η άλλη
  AND start_time < COALESCE(NEW.end_time, '9999-12-31'); -- παλιά ξεκινά πριν τελειώσει η νέα
```
`COALESCE(end_time, '9999-12-31')` αντιμετωπίζει ongoing επεμβάσεις (χωρίς end_time) ως να τελειώνουν "στο μέλλον".

**BEFORE INSERT on medical_procedure.**

---

### trg_procedure_doctor_overlap

**Τι κάνει:** Ο ίδιος ιατρός δεν μπορεί να συμμετέχει ταυτόχρονα σε δύο επεμβάσεις (ούτε ως primary surgeon, ούτε ως assistant).

**Δύο έλεγχοι:**
1. Ελέγχει αν ο νέος primary surgeon είναι ήδη primary surgeon σε άλλη ταυτόχρονη επέμβαση
2. Ελέγχει αν είναι ήδη assistant σε άλλη ταυτόχρονη επέμβαση

```sql
-- Έλεγχος 1: ως primary surgeon
SELECT COUNT(*) INTO v_conflict FROM medical_procedure
WHERE primary_surgeon_id = NEW.primary_surgeon_id
  AND NEW.start_time < COALESCE(end_time, '9999-12-31')
  AND start_time < COALESCE(NEW.end_time, '9999-12-31');

-- Έλεγχος 2: ως assistant
SELECT COUNT(*) INTO v_conflict FROM procedure_assistant pa
JOIN medical_procedure mp ON pa.procedure_id = mp.procedure_id
WHERE pa.staff_id = NEW.primary_surgeon_id
  AND NEW.start_time < COALESCE(mp.end_time, '9999-12-31')
  AND mp.start_time < COALESCE(NEW.end_time, '9999-12-31');
```

---

### trg_procedure_assistant_overlap

**Τι κάνει:** Ο ίδιος assistant δεν μπορεί να συμμετέχει σε δύο ταυτόχρονες επεμβάσεις.

**Τρεις έλεγχοι:** (ως primary surgeon, ως assistant σε άλλη επέμβαση)

**BEFORE INSERT on procedure_assistant.**

**Ποια rule:** *"Ούτε ο ίδιος ιατρός να συμμετέχει σε δύο επεμβάσεις ταυτόχρονα."*

---

## Triggers 15-18: Κλίνες και κόστος νοσηλείας

### trg_hospitalization_bed_check

**Τι κάνει:** Ελέγχει αν η κλίνη είναι 'διαθέσιμη' πριν από κάθε νέα νοσηλεία.

```sql
SELECT status INTO v_status FROM bed WHERE id = NEW.bed_id;
IF v_status != 'διαθέσιμη' THEN SIGNAL error;
```

**BEFORE INSERT on hospitalization** — αποτρέπουμε την εγγραφή.

**Γιατί trigger και όχι CHECK:** Ελέγχει στον πίνακα `bed` — δεν είναι τιμή της ίδιας γραμμής.

---

### trg_hospitalization_bed_occupy

**Τι κάνει:** Αφού εισαχθεί νοσηλεία, σημειώνει την κλίνη ως 'κατειλημμένη'.

```sql
UPDATE bed SET status = 'κατειλημμένη' WHERE id = NEW.bed_id;
```

**AFTER INSERT on hospitalization** — τροποποιούμε **άλλον** πίνακα (bed) αφού η νοσηλεία έχει αποθηκευτεί. Εδώ χρειάζεται AFTER (όχι BEFORE) γιατί:
1. Δεν τροποποιούμε τη γραμμή της νοσηλείας — τροποποιούμε τον πίνακα bed
2. Θέλουμε να είμαστε σίγουροι ότι η νοσηλεία αποθηκεύτηκε πριν αλλάξουμε την κλίνη

---

### trg_hospitalization_bed_free

**Τι κάνει:** Όταν δοθεί discharge_date (έξοδος ασθενή), σημειώνει την κλίνη ως 'διαθέσιμη'.

```sql
IF OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL THEN
    UPDATE bed SET status = 'διαθέσιμη' WHERE id = NEW.bed_id;
END IF;
```

**AFTER UPDATE on hospitalization** — τροποποιούμε άλλον πίνακα (bed).

**Γιατί AFTER και όχι BEFORE:** Τροποποιούμε τον πίνακα `bed` (όχι τη γραμμή hospitalization), οπότε AFTER είναι σωστό. Δεν χρειάζεται BEFORE γιατί δεν αλλάζουμε `NEW.*`.

**Χρήση OLD/NEW:** Ελέγχουμε `OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL` για να βεβαιωθούμε ότι αυτό είναι η **πρώτη φορά** που δίνεται discharge_date (και όχι απλά μια άλλη αλλαγή στη γραμμή).

---

### trg_hospitalization_cost

**Τι κάνει:** Υπολογίζει το total_cost κατά την έξοδο, βάσει ΚΕΝ.

**Φόρμουλα ΚΕΝ:**
- Αν actual_days ≤ alos_days: `total_cost = base_cost`
- Αν actual_days > alos_days: `total_cost = base_cost + (actual_days - alos_days) × (base_cost / alos_days)`

```sql
IF OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL AND NEW.ken_code IS NOT NULL THEN
    SET v_actual_days = DATEDIFF(NEW.discharge_date, NEW.admission_date);
    IF v_actual_days > v_alos_days THEN
        SET NEW.total_cost = v_base_cost + (v_actual_days - v_alos_days) * (v_base_cost / v_alos_days);
    ELSE
        SET NEW.total_cost = v_base_cost;
    END IF;
END IF;
```

**BEFORE UPDATE on hospitalization** — ΚΡΙΣΙΜΟς: τροποποιεί `NEW.total_cost` πριν γραφτεί. Σε AFTER δεν θα μπορούσε να κάνει `SET NEW.total_cost`.

**Γιατί δεν υπολογίζουμε on-the-fly στο query:** Αποθηκεύουμε το total_cost στον πίνακα γιατί:
1. Η τιμή του ΚΕΝ μπορεί να αλλάξει μελλοντικά — το κόστος πρέπει να "παγώσει" τη στιγμή της εξόδου
2. Απλοποιεί τα queries (Q01, Q03 κ.λπ.) — δεν χρειάζεται να ξαναυπολογίζουν

---

# ΜΕΡΟΣ 5 — Κάθε Index Αναλυτικά

## Indexes στο πίνακα hospitalization

### idx_hospitalization_patient ON hospitalization(patient_id)

**Queries:** Q03, Q06, Q09 — JOIN με patient  
**Γιατί:** Το patient_id είναι η πιο συχνή στήλη JOIN. High cardinality (200 distinct values σε 500 γραμμές).  
**Χωρίς αυτό:** Κάθε JOIN patient→hospitalization θα ήταν full table scan των 500 γραμμών.

---

### idx_hospitalization_department ON hospitalization(department_id)

**Queries:** Q01, Q03 — GROUP BY department  
**Γιατί:** Ομαδοποίηση κατά department_id σε 500 γραμμές.  
**Cardinality:** 15 departments — medium, αλλά απαραίτητο για GROUP BY.

---

### idx_hospitalization_admission ON hospitalization(admission_date)

**Queries:** Q01, Q09, Q14 — GROUP BY YEAR(), range filters  
**Γιατί:** Date range scans και GROUP BY YEAR(admission_date).  
**Σημείωση:** Ο optimizer μπορεί να μη χρησιμοποιήσει τον index για `YEAR(admission_date) = 2025` (function on column), αλλά βοηθά σε range queries.

---

### idx_hospitalization_ken ON hospitalization(ken_code)

**Queries:** Q01 — LEFT JOIN με ken  
**Γιατί:** ken_code είναι VARCHAR — JOIN χωρίς index θα ήταν O(n) για κάθε γραμμή hospitalization.

---

### idx_hospitalization_icd ON hospitalization(icd10_code)

**Queries:** Q06, Q14 — LEFT JOIN με ICD10  
**Γιατί:** Αναζήτηση βάσει icd10_code σε JOIN με τον πίνακα ICD10.

---

## Indexes στο πίνακα doctor

### idx_doctor_specialty ON doctor(specialty)

**Queries:** Q02, Q05 — WHERE/JOIN βάσει specialty  
**Γιατί:** Q02 φιλτράρει `specialty = 'Χειρουργική'`. Χωρίς index → full scan 80 doctors.

---

### idx_doctor_rank ON doctor(`rank`)

**Queries:** Q13 — ιεραρχία εποπτείας ανά rank  
**Γιατί:** Η recursive CTE φιλτράρει βάσει rank για να βρει Διευθυντές/Επιμελητές.

---

### idx_doctor_supervisor ON doctor(supervisor_id)

**Queries:** Q13 — recursive CTE JOIN ON supervisor_id  
**Γιατί:** Η recursive CTE κάνει JOIN `doctor next_sup ON next_sup.staff_id = sup.supervisor_id` — χωρίς index → N^2 complexity για βαθιά ιεραρχία.

---

## Indexes στα shifts

### idx_shift_date ON shift(shift_date)

**Queries:** Q08, Q12 — WHERE/BETWEEN shift_date  
**Γιατί:** Date range filters σε shift table.

---

### idx_shift_dept_date ON shift(department_id, shift_date)

**Queries:** Q08, Q12 — composite filter dept+date  
**Γιατί composite:** Τα queries φιλτράρουν ΠΑΝΤΑ βάσει και department_id ΚΑΙ shift_date μαζί. Composite index καλύτερο από δύο ξεχωριστά γιατί ο optimizer βρίσκει τις γραμμές σε ένα lookup.  
**Leftmost prefix:** department_id πρώτα (high selectivity για ένα συγκεκριμένο τμήμα).

---

### idx_shift_assignment_staff ON shift_assignment(staff_id)

**Queries:** Q02, Q08, Q12 — JOIN staff σε βάρδιες  
**Γιατί:** Frequent JOIN pattern: "όλες οι βάρδιες αυτού του υπαλλήλου". Χωρίς index → full scan shift_assignment.

---

## Indexes σε εξετάσεις & επεμβάσεις

### idx_lab_test_hospitalization ON lab_test(hospitalization_id)

**Queries:** Γενικό JOIN lab_test → hospitalization  
**Γιατί:** Standard FK index για γρήγορο lookup "όλες οι εξετάσεις αυτής της νοσηλείας".

---

### idx_procedure_surgeon ON medical_procedure(primary_surgeon_id)

**Queries:** Q02, Q05, Q11 — JOIN χειρουργός  
**Γιατί:** Queries αναζητούν "όλες οι επεμβάσεις αυτού του ιατρού".

---

### idx_procedure_start_time ON medical_procedure(start_time)

**Queries:** Q02, Q11 — YEAR(start_time) filter  
**Γιατί:** Date filter για τρέχον έτος. Επίσης χρησιμοποιείται στα triggers για overlap detection.

---

## Indexes στο staff

### idx_staff_age ON staff(age)

**Queries:** Q05 — WHERE age < 35 (range query)  
**Γιατί:** Range query σε numeric column — ιδανικό για B-tree index. Χωρίς αυτό → full scan 260 staff.

---

## Indexes σε φάρμακα & ουσίες

### idx_drug_name ON drug(drug_name)

**Χρήση:** load.sql — JOIN κατά φόρτωση drug_substance data  
**Γιατί:** Κατά τη φόρτωση δεδομένων, γίνεται JOIN βάσει ονόματος φαρμάκου.

---

### idx_drug_substance_drug ON drug_substance(drug_id)

**Queries:** Q10 — JOIN ds ON drug_id (148k rows στο EMA dataset)  
**Γιατί:** Ο πίνακας drug_substance είναι πολύ μεγάλος (κάθε φάρμακο μπορεί να έχει πολλές ουσίες). Index απαραίτητο.

---

### idx_drug_substance_substance ON drug_substance(substance_id)

**Queries:** Q07, Q10 — JOIN ds ON substance_id  
**Trigger:** trg_prescription_allergy_check κάνει JOIN drug_substance.substance_id  
**Γιατί:** Αναζήτηση "ποια φάρμακα περιέχουν αυτή την ουσία".

---

## Indexes σε συνταγογράφηση

### idx_prescription_patient ON prescription(patient_id)

**Queries:** Q10 — JOIN συνταγές ίδιου ασθενή  
**Γιατί:** "Όλες οι συνταγές αυτού του ασθενή κατά τη νοσηλεία".

---

### idx_prescription_doctor ON prescription(doctor_id)

**Trigger:** trg_doctor_evaluation_check — ελέγχει αν ο ιατρός συνταγογράφησε  
**Γιατί:** Ο trigger εκτελείται πριν κάθε doctor evaluation — πρέπει να είναι γρήγορος.

---

### idx_prescription_hospitalization ON prescription(hospitalization_id)

**Queries:** Q10 — self-join ON hospitalization_id  
**Trigger:** trg_doctor_evaluation_check  
**Γιατί:** Frequent JOIN pattern "όλες οι συνταγές αυτής της νοσηλείας".

---

## Indexes σε αλλεργίες & αξιολογήσεις

### idx_patient_allergy_substance ON patient_allergy(substance_id)

**Queries:** Q07 — JOIN ουσία-αλλεργία  
**Trigger:** trg_prescription_allergy_check  
**Γιατί:** Ο allergy trigger τρέχει σε κάθε νέα συνταγογράφηση — πρέπει να βρίσκει γρήγορα αλλεργίες ανά substance_id.

---

### idx_triage_urgency ON triage_record(urgency_level)

**Queries:** Q15 — GROUP BY urgency_level  
**Γιατί:** 5 distinct values (1-5) — low cardinality, αλλά χρησιμοποιείται για GROUP BY που εξαλείφει filesort.

---

### idx_evaluation_hospitalization ON evaluation(hospitalization_id)

**Queries:** Q04, Q06 — JOIN αξιολόγηση  
**Trigger:** trg_evaluation_discharged, trg_doctor_evaluation_check  
**Γιατί:** Standard FK index.

---

### idx_doctor_evaluation_doctor ON doctor_evaluation(doctor_id)

**Queries:** Q04 — JOIN αξιολόγηση γιατρού  
**Γιατί:** "Όλες οι αξιολογήσεις αυτού του ιατρού" — core access pattern για Q04.  
**EXPLAIN Q04 result:** Με αυτόν τον index → rows=2, χωρίς αυτόν → rows=150 (full scan). Αυτό φαίνεται στο report.md.

---

# ΜΕΡΟΣ 6 — Query-by-Query Ανάλυση (Q01-Q15)

## Q01 — Έσοδα νοσοκομείου ανά τμήμα/έτος/ΚΕΝ/ασφαλιστικό φορέα

**Τεχνική:** Απλό GROUP BY με CASE για conditional aggregation.

**Indexes που χρησιμοποιούνται:**
- `idx_hospitalization_department` (JOIN department)
- `idx_hospitalization_patient` (JOIN patient)
- `idx_hospitalization_ken` (LEFT JOIN ken)

**Βασικό GROUP BY:**
```sql
GROUP BY d.department_id, YEAR(h.admission_date), h.ken_code, p.insurance_provider
```
Αυτό παράγει μία γραμμή για κάθε συνδυασμό τμήμα/έτος/ΚΕΝ/ασφαλιστικό.

**Το extra_alos_revenue:** Υπολογίζει επιπλέον έσοδα μόνο για νοσηλείες που ξεπέρασαν τη ΜΔΝ:
```sql
GREATEST(COALESCE(h.total_cost, k.base_cost) - k.base_cost, 0)
```
`GREATEST(..., 0)` εξασφαλίζει ότι ποτέ δεν επιστρέφουμε αρνητικό ποσό.

**Πιθανή ερώτηση:** *"Γιατί LEFT JOIN με ken και όχι INNER JOIN;"*
**Απάντηση:** Επειδή κάποιες νοσηλείες μπορεί να μην έχουν ken_code (NULL). Με INNER JOIN θα χάναμε αυτές τις γραμμές.

---

## Q02 — Ιατροί ανά ειδικότητα με εφημερίες και επεμβάσεις

**Τεχνική:** CTE για παράμετρο + LEFT JOINs με YEAR() filter στο JOIN condition.

**Κρίσιμη λεπτομέρεια:** Το YEAR() filter μπαίνει στο JOIN condition, όχι στο WHERE:
```sql
LEFT JOIN shift sh ON sh.shift_id = sa.shift_id AND YEAR(sh.shift_date) = YEAR(CURDATE())
```
Αν έμπαινε στο WHERE, θα μετέτρεπε τον LEFT JOIN σε INNER JOIN (οι ιατροί χωρίς βάρδια θα εξαφανίζονταν).

**Indexes:** `idx_doctor_specialty`, `idx_shift_assignment_staff`, `idx_procedure_surgeon`, `idx_procedure_start_time`

**Πιθανή ερώτηση:** *"Γιατί COUNT(DISTINCT sh.shift_id) και όχι COUNT(*);"*
**Απάντηση:** Γιατί το JOIN μπορεί να παράγει duplicates αν ένας ιατρός έχει πολλές βάρδιες. DISTINCT εξασφαλίζει ότι μετράμε μοναδικές βάρδιες.

---

## Q03 — Ασθενείς με >3 νοσηλείες στο ίδιο τμήμα

**Τεχνική:** GROUP BY patient+department + HAVING COUNT(*) > 3

**Indexes:** `idx_hospitalization_patient`, `idx_hospitalization_department`

**HAVING vs WHERE:** Το HAVING φιλτράρει **μετά** το GROUP BY (βάσει aggregate). Το WHERE δεν μπορεί να χρησιμοποιήσει COUNT(*) γιατί φιλτράρει **πριν** το GROUP BY.

---

## Q04 — Μέσος όρος αξιολόγησης συγκεκριμένου ιατρού

**Τεχνική:** CTE για παράμετρο + INNER JOINs

**Indexes:** `idx_doctor_evaluation_doctor` (κρίσιμος — φαίνεται στο EXPLAIN)

**EXPLAIN comparison (από report.md):**
- Με `idx_doctor_evaluation_doctor`: rows=2, type=ref
- Με FORCE INDEX (PRIMARY): rows=150, type=index

**Γιατί η διαφορά:** Ο PRIMARY KEY (eval_id) δεν βοηθά στην αναζήτηση βάσει doctor_id. Ο optimizer αναγκάζεται να σκανάρει τον ίδιο πίνακα σειριακά.

**Πιθανή ερώτηση:** *"Γιατί ο χρόνος εκτέλεσης δεν διαφέρει πολύ (0.020 vs 0.021);"*
**Απάντηση:** Ο μικρός πίνακας χωράει στο buffer pool (RAM). Σε παραγωγικό σύστημα με χιλιάδες αξιολογήσεις η διαφορά rows (2 vs 150) θα αντικατοπτριζόταν απευθείας σε χρόνο.

---

## Q05 — Νέοι ιατροί (<35) με περισσότερες χειρουργικές επεμβάσεις

**Τεχνική:** Multi-table JOIN με category filter

**Indexes:** `idx_staff_age`, `idx_procedure_surgeon`, `idx_doctor_specialty`

**Σημαντικό:** Το filter `AND pc.category = 'χειρουργική'` στο JOIN condition (όχι WHERE) — ωστόσο εδώ δεν υπάρχει LEFT JOIN οπότε δεν αλλάζει σημασιολογία.

**LIMIT 20:** Δεν ζητείται συγκεκριμένο αριθμός από την εκφώνηση ("τους περισσότερες") — LIMIT 20 είναι reasonable default.

---

## Q06 — Ιστορικό νοσηλειών ασθενή

**Τεχνική:** Δύο CTEs — μία για παράμετρο, μία για average overall evaluation

**Indexes:** `idx_hospitalization_patient`, `idx_hospitalization_icd`, `idx_evaluation_hospitalization`

**EXPLAIN comparison (από report.md):**
- Με `idx_hospitalization_patient`: rows=6, type=ref
- Με FORCE INDEX (idx_hospitalization_icd): rows=500, type=index

**Γιατί:** Το idx_hospitalization_icd αφορά το πεδίο icd10_code — δεν βοηθά στην αναζήτηση βάσει patient_id. Ο optimizer αδυνατεί να το αξιοποιήσει για το JOIN condition.

---

## Q07 — Αλλεργίες και φάρμακα ανά δραστική ουσία

**Τεχνική:** LEFT JOINs + COUNT(DISTINCT ...) για δύο ανεξάρτητες μετρήσεις

**Indexes:** `idx_patient_allergy_substance`, `idx_drug_substance_substance`

**Γιατί COUNT(DISTINCT patient_id) και COUNT(DISTINCT drug_id) και όχι COUNT(*):**
Χωρίς DISTINCT, αν μια ουσία βρίσκεται σε 3 φάρμακα και 2 ασθενείς είναι αλλεργικοί → 3×2=6 γραμμές λόγω JOIN, αλλά θέλουμε 3 φάρμακα και 2 ασθενείς.

---

## Q08 — Προσωπικό χωρίς εφημερία σε συγκεκριμένη ημερομηνία/τμήμα

**Τεχνική:** UNION ALL για τα 3 είδη προσωπικού + NOT EXISTS

**Indexes:** `idx_shift_assignment_staff`, `idx_shift_dept_date`

**NOT EXISTS vs LEFT JOIN IS NULL:**
```sql
-- NOT EXISTS (χρησιμοποιείται):
WHERE NOT EXISTS (SELECT 1 FROM shift_assignment sa JOIN shift sh WHERE ...)

-- Εναλλακτικό LEFT JOIN IS NULL:
LEFT JOIN shift_assignment sa ON ... WHERE sa.staff_id IS NULL
```
Και τα δύο δίνουν ίδιο αποτέλεσμα. NOT EXISTS είναι πιο readable και ο optimizer το μετατρέπει συχνά σε anti-join (εξίσου αποδοτικό).

**UNION ALL vs UNION:** UNION ALL είναι πιο γρήγορο (δεν κάνει deduplication). Εδώ δεν μπορεί να υπάρχει duplicate γιατί ένα staff_id ανήκει σε ένα μόνο subtype.

---

## Q09 — Ασθενείς με ίδιο αριθμό νοσηλείας ημερών

**Τεχνική:** Δύο CTEs + self-join βάσει (admission_year, total_days_in_year)

**Indexes:** `idx_hospitalization_patient`, `idx_hospitalization_admission`

**COALESCE για active hospitalizations:**
```sql
DATEDIFF(COALESCE(h.discharge_date, CURDATE()), h.admission_date)
```
Αν ο ασθενής είναι ακόμα νοσηλευόμενος (NULL discharge_date), χρησιμοποιεί CURDATE() για να υπολογίσει τρέχουσες μέρες.

---

## Q10 — Top-3 ζεύγη δραστικών ουσιών που συνταγογραφούνται μαζί

**Τεχνική:** Self-join prescription + M:N traversal βάσει overlapping dates

**Η πιο σύνθετη query:** Σχεδόν τυχαίο self-join με τέσσερις συνθήκες:
```sql
JOIN prescription p2 ON
  p2.hospitalization_id = p1.hospitalization_id  -- ίδια νοσηλεία
  AND p2.patient_id = p1.patient_id              -- ίδιος ασθενής
  AND p2.prescription_id > p1.prescription_id   -- αποφυγή A+B και B+A
  AND p1.start_date <= COALESCE(p2.end_date, p2.start_date)  -- overlap
  AND p2.start_date <= COALESCE(p1.end_date, p1.start_date)  -- overlap
```

**p2.prescription_id > p1.prescription_id:** Αποτρέπει τα διπλά ζεύγη (A+B = B+A). Κάθε ζεύγος εμφανίζεται μία φορά.

**ds2.substance_id > ds1.substance_id:** Ίδια λογική για τα ζεύγη ουσιών — αποτρέπει X+Y = Y+X.

**Indexes:** `idx_prescription_hospitalization`, `idx_drug_substance_drug`, `idx_drug_substance_substance`

---

## Q11 — Ιατροί ≥5 επεμβάσεις πίσω από τον top

**Τεχνική:** Δύο CTEs + CROSS JOIN

```sql
CROSS JOIN top_count tc
WHERE tc.top_current_year_procedures - pc.current_year_procedures >= 5
```

**CROSS JOIN:** Δεν υπάρχει JOIN condition — κάθε γραμμή procedure_counts συνδυάζεται με τη μία γραμμή top_count. Αποτελεσματικό γιατί το top_count έχει πάντα 1 γραμμή.

---

## Q12 — Στελέχωση ανά τμήμα/βάρδια/εβδομάδα

**Τεχνική:** UNION ALL για 3 υποκλάσεις + CASE για minimum requirements + FIELD() για ORDER BY

**FIELD() function:**
```sql
ORDER BY FIELD(assigned_staff.shift_type, 'morning', 'afternoon', 'night')
```
Ταξινομεί τα shift_type με συγκεκριμένη σειρά (πρωί→απόγευμα→νύχτα) αντί για αλφαβητική.

**Indexes:** `idx_shift_dept_date`, `idx_shift_assignment_staff`

---

## Q13 — Αναδρομική ιεραρχία εποπτείας

**Τεχνική:** WITH RECURSIVE CTE

```sql
WITH RECURSIVE supervision_chain AS (
    -- Base case: άμεσος επόπτης
    SELECT doc.staff_id, ..., 1 AS supervision_level
    FROM doctor doc JOIN doctor sup ON sup.staff_id = doc.supervisor_id
    
    UNION ALL
    
    -- Recursive case: επόπτης του επόπτη
    SELECT sc.doctor_id, ..., sc.supervision_level + 1
    FROM supervision_chain sc
    JOIN doctor sup ON sup.staff_id = sc.supervisor_staff_id
    JOIN doctor next_sup ON next_sup.staff_id = sup.supervisor_id
)
```

**Γιατί recursive CTE:** Δεν γνωρίζουμε εκ των προτέρων το βάθος της ιεραρχίας. Μόνο recursion μπορεί να ανεβεί αυθαίρετο αριθμό επιπέδων.

**Τερματισμός:** Η recursion σταματά όταν `sup.supervisor_id IS NULL` (Διευθυντής — δεν έχει επόπτη).

**Indexes:** `idx_doctor_supervisor` — κρίσιμος για το JOIN `ON next_sup.staff_id = sup.supervisor_id`.

---

## Q14 — ICD-10 κατηγορίες με ίδιο αριθμό εισαγωγών σε συνεχόμενα έτη

**Τεχνική:** CTE + self-join βάσει consecutive years

```sql
JOIN category_year_counts c2 ON
  c2.icd_category = c1.icd_category
  AND c2.admission_year = c1.admission_year + 1  -- συνεχόμενα έτη
  AND c2.admissions = c1.admissions              -- ίδιος αριθμός
WHERE c1.admissions >= 5 AND c2.admissions >= 5
```

**Indexes:** `idx_hospitalization_icd`, `idx_hospitalization_admission`

---

## Q15 — Κατανομή triage ανά επίπεδο επείγοντος

**Τεχνική:** GROUP BY urgency_level + COALESCE για τμήμα + TIMESTAMPDIFF

```sql
ROUND(AVG(TIMESTAMPDIFF(MINUTE, tr.arrival_time, tr.outcome_time)), 2) AS avg_wait_minutes
ROUND(100 * SUM(CASE WHEN tr.hospitalization_id IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) AS hospitalization_pct
```

**TIMESTAMPDIFF(MINUTE, ...):** Υπολογίζει διαφορά σε λεπτά μεταξύ arrival_time και outcome_time.

**COALESCE(d.name, 'No hospitalization'):** Ασθενείς που αποχώρησαν (χωρίς νοσηλεία) δεν έχουν department — τους βάζουμε σε κατηγορία "No hospitalization".

**Indexes:** `idx_triage_urgency`

---

# ΜΕΡΟΣ 7 — Flashcards Επίδειξης

> Διάβαζε αυτές πριν την επίδειξη. Κάθε ερώτηση είναι ρεαλιστική ερώτηση καθηγητή.

---

**Ε: Γιατί ο trg_hospitalization_cost είναι BEFORE UPDATE και όχι AFTER UPDATE;**
**Α:** Επειδή θέλω να τροποποιήσω το `NEW.total_cost` πριν γραφτεί η γραμμή. Σε AFTER trigger, το `NEW.*` είναι read-only. Επιπλέον, δεν μπορώ να κάνω `UPDATE hospitalization` μέσα σε AFTER trigger που πυροδοτείται από το hospitalization (infinite loop / error).

---

**Ε: Γιατί ο trg_hospitalization_bed_occupy είναι AFTER INSERT και όχι BEFORE;**
**Α:** Επειδή τροποποιώ τον πίνακα `bed` (άλλος πίνακας) αφού η νοσηλεία έχει ήδη καταχωρηθεί επιτυχώς. Δεν χρειάζομαι BEFORE γιατί δεν αλλάζω το `NEW.*` του hospitalization.

---

**Ε: Γιατί χρησιμοποιείς trigger για τον allergy check αντί για CHECK constraint;**
**Α:** Επειδή ο έλεγχος αφορά δύο άλλους πίνακες (drug_substance και patient_allergy). Το CHECK constraint δεν μπορεί να "κοιτάξει" άλλους πίνακες — μπορεί μόνο να ελέγξει τιμές της ίδιας γραμμής.

---

**Ε: Πώς υλοποιήθηκε ο κανόνας minimum staffing (≥3 ιατροί, ≥6 νοσηλευτές, ≥2 διοικητικοί ανά βάρδια);**
**Α:** Με BEFORE DELETE trigger (`trg_shift_min_staffing`) στο `shift_assignment`. Δεν μπορεί να ελεγχθεί στο INSERT γιατί η βάρδια χτίζεται ένα άτομο τη φορά — ο 1ος υπάλληλος που μπαίνει θα αποτύγχανε πάντα. Αντ' αυτού, μόλις η βάρδια αποκτήσει έγκυρη στελέχωση, κάθε DELETE που θα την έφερνε κάτω από τα ελάχιστα μπλοκάρεται αυτόματα.

---

**Ε: Τι σημαίνει το COALESCE(end_time, '9999-12-31') στους triggers επεμβάσεων;**
**Α:** Μια επέμβαση που δεν έχει τελειώσει ακόμα (end_time IS NULL) αντιμετωπίζεται ως να τελειώνει "στο άπειρο μέλλον". Αυτό εξασφαλίζει ότι δεν μπορείς να ξεκινήσεις νέα επέμβαση στον ίδιο χώρο όσο μια άλλη τρέχει.

---

**Ε: Γιατί το idx_shift_dept_date είναι composite (department_id, shift_date) και όχι δύο ξεχωριστά indexes;**
**Α:** Γιατί τα queries Q08 και Q12 φιλτράρουν ΠΑΝΤΑ βάσει και department_id ΚΑΙ shift_date μαζί. Ένας composite index είναι πιο αποδοτικός από δύο ξεχωριστά γιατί ο optimizer βρίσκει τις γραμμές σε ένα B-tree lookup αντί για δύο. Επίσης, το department_id είναι πρώτο γιατί έχει υψηλότερη selectivity (15 τμήματα, πολλές ημερομηνίες).

---

**Ε: Τι είναι το leftmost prefix rule για composite indexes;**
**Α:** Ένας composite index σε (A, B, C) μπορεί να χρησιμοποιηθεί για queries με WHERE A=?, WHERE A=? AND B=?, και WHERE A=? AND B=? AND C=?. Δεν μπορεί να χρησιμοποιηθεί για WHERE B=? ή WHERE C=? χωρίς το A.

---

**Ε: Γιατί ο πίνακας staff έχει το `staff_type` column ενώ υπάρχει ήδη η ISA ιεραρχία;**
**Α:** Για να μπορούμε να προσδιορίσουμε τον τύπο ενός υπαλλήλου μόνο από τον πίνακα staff χωρίς JOIN. Χρησιμοποιείται από το trigger trg_shift_monthly_limit που χρειάζεται να ξέρει τον τύπο για να εφαρμόσει το σωστό όριο βαρδιών.

---

**Ε: Γιατί η ISA ιεραρχία υλοποιήθηκε με ξεχωριστούς πίνακες και όχι ένα πίνακα staff;**
**Α:** Κάθε subtype έχει διαφορετικά attributes (specialty/rank για doctors, department_id/rank για nurses). Ένας πίνακας θα είχε πολλά NULL και δεν θα μπορούσε να επιβάλει type-specific constraints (π.χ. CHECK για τους valid ranks διαφέρει ανά subtype).

---

**Ε: Γιατί χρησιμοποιείς ALTER TABLE για το department.director_id αντί να το βάλεις στη CREATE TABLE;**
**Α:** Επειδή υπάρχει κυκλική εξάρτηση: το `department` πρέπει να αναφέρεται στο `doctor`, αλλά το `doctor` εξαρτάται από το `staff`. Η λύση είναι να δημιουργήσεις πρώτα το `department` χωρίς το FK, μετά να δημιουργήσεις τους σχετικούς πίνακες, και τέλος να προσθέσεις το FK με ALTER TABLE.

---

**Ε: Γιατί το patient_id είναι AUTO_INCREMENT και όχι το AMKA ως primary key;**
**Α:** Το AMKA είναι VARCHAR(11) — string primary key είναι πιο αργό σε JOINs (string comparison vs integer comparison). Επίσης, το AMKA μπορεί θεωρητικά να αλλάξει (π.χ. λάθος εισαγωγή), ενώ ένα surrogate key δεν αλλάζει ποτέ. Το AMKA διατηρείται ως UNIQUE constraint.

---

**Ε: Τι σημαίνει "clustered index" και γιατί έχει σημασία για το PRIMARY KEY;**
**Α:** Στο InnoDB (MariaDB), τα δεδομένα του πίνακα αποθηκεύονται φυσικά ταξινομημένα κατά PRIMARY KEY. Αυτό σημαίνει ότι range queries βάσει PK (π.χ. WHERE hospitalization_id BETWEEN 100 AND 200) είναι πολύ γρήγορες. Κάθε secondary index αποθηκεύει την PK τιμή — αυτό σημαίνει ότι lookup μέσω secondary index κάνει δύο βήματα: 1) βρες PK από index, 2) βρες row από clustered index.

---

**Ε: Γιατί χρησιμοποιείς NOT EXISTS στο Q08 αντί για LEFT JOIN IS NULL;**
**Α:** Και τα δύο δίνουν ίδιο αποτέλεσμα. NOT EXISTS είναι πιο readable (εκφράζει "αυτό το άτομο δεν εμφανίζεται στις βάρδιες"). Ο optimizer μετατρέπει συχνά το NOT EXISTS σε anti-join που είναι εξίσου αποδοτικό με LEFT JOIN IS NULL.

---

**Ε: Γιατί το Q10 χρησιμοποιεί p2.prescription_id > p1.prescription_id;**
**Α:** Αποφεύγει τα διπλά ζεύγη. Χωρίς αυτή τη συνθήκη, θα εμφανιζόταν τόσο το ζεύγος (A, B) όσο και το (B, A). Με p2.prescription_id > p1.prescription_id, εξασφαλίζουμε ότι κάθε ζεύγος εμφανίζεται μία φορά.

---

**Ε: Τι είναι η WITH RECURSIVE CTE και πότε χρειάζεται;**
**Α:** Μια recursive CTE χρησιμοποιείται όταν χρειάζεται να διατρέξουμε αναδρομικά μια ιεραρχία (tree/graph structure) χωρίς να γνωρίζουμε εκ των προτέρων το βάθος. Στο Q13, δεν γνωρίζουμε πόσα επίπεδα εποπτείας υπάρχουν — η recursion τερματίζει όταν βρει Διευθυντή (supervisor_id IS NULL).

---

**Ε: Γιατί το trg_shift_trainee_requires_senior ελέγχει αν υπάρχει ΗΔΗΗ senior ΠΡΙΝ εισαχθεί ο Ειδικευόμενος;**
**Α:** Αυτό σημαίνει ότι η σειρά εισαγωγής έχει σημασία: πρέπει πρώτα να μπει ο Επιμελητής Α ή Διευθυντής, και μετά ο Ειδικευόμενος. Αν ο Ειδικευόμενος μπει πρώτος, το trigger θα αποτύχει. Αυτό είναι acceptable — η εφαρμογή πρέπει να εισάγει με τη σωστή σειρά.

---

**Ε: Τι σημαίνει FORCE INDEX και πότε το χρησιμοποιείς;**
**Α:** FORCE INDEX υποχρεώνει τον optimizer να χρησιμοποιήσει συγκεκριμένο index αντί για αυτόν που θα επέλεγε μόνος του. Το χρησιμοποιείς για: (α) comparison/benchmark — να δεις πώς το query εκτελείται με διαφορετικό index, (β) σε σπάνιες περιπτώσεις όπου ο optimizer κάνει λάθος επιλογή. Στο project, το χρησιμοποιήσαμε σκόπιμα για το EXPLAIN comparison των Q4 και Q6.

---

**Ε: Γιατί το total_cost αποθηκεύεται στον πίνακα hospitalization αντί να υπολογίζεται on-the-fly στο query;**
**Α:** Δύο λόγοι: (α) "Παγώνει" το κόστος τη στιγμή εξόδου — αν αλλάξει ο ΚΕΝ κατάλογος μελλοντικά, το ιστορικό κόστος παραμένει σωστό, (β) Απλοποιεί τα queries — δεν χρειάζεται join με ken και υπολογισμός σε κάθε query που χρειάζεται το κόστος.

---

**Ε: Γιατί το evaluation έχει UNIQUE(hospitalization_id);**
**Α:** Γιατί η εκφώνηση ορίζει "ένα evaluation per νοσηλεία" — ο ασθενής αξιολογεί τη νοσηλεία μία φορά. Το UNIQUE constraint εξασφαλίζει αυτόν τον κανόνα σε επίπεδο ΒΔ.

---

**Ε: Γιατί η prescription έχει UNIQUE(doctor_id, patient_id, drug_id, start_date);**
**Α:** Η εκφώνηση ορίζει: "Κάθε συνδυασμός (ιατρός, ασθενής, φάρμακο, ημερομηνία έναρξης) είναι μοναδικός." Αυτό αποτρέπει διπλή συνταγογράφηση του ίδιου φαρμάκου από τον ίδιο ιατρό στον ίδιο ασθενή την ίδια μέρα.

---

**Ε: Τι είναι το cardinality και πώς επηρεάζει την απόφαση για index;**
**Α:** Cardinality = πλήθος distinct τιμών μιας στήλης. High cardinality (π.χ. patient_id με 200 values) → index αξίζει γιατί κάθε τιμή εντοπίζει λίγες γραμμές. Low cardinality (π.χ. staff_type με 3 values) → index μόνος του δεν αξίζει γιατί ο optimizer θα εξακολουθεί να διαβάζει πολλές γραμμές. Low cardinality column μπορεί να αξίζει ως δεύτερη στήλη σε composite index.

---

**Ε: Τι σημαίνει "covering index" και υπάρχει στο project;**
**Α:** Covering index = ένας index που περιέχει ΟΛΕς τις στήλες που χρειάζεται το query, οπότε ο optimizer δεν χρειάζεται να επιστρέψει στον πίνακα. Στο EXPLAIN φαίνεται ως "Using index". Στο project, ο `idx_doctor_evaluation_doctor` είναι (doctor_id) — το Q04 χρειάζεται επίσης eval_id, hospitalization_id κ.λπ., οπότε δεν είναι covering. Αλλά τα M:N junction indexes (π.χ. PRIMARY KEY του drug_substance) λειτουργούν ως covering για simple existence checks.

---

**Ε: Γιατί το photo_url αποθηκεύεται ως TEXT και όχι ως BLOB;**
**Α:** Δεν αποθηκεύουμε τα ίδια τα αρχεία στη ΒΔ — μόνο το URL τους (path ή web URL). TEXT είναι αρκετό για URL strings. Το BLOB θα χρησιμοποιούσαμε αν αποθηκεύαμε τα binary data των εικόνων, κάτι που δεν συνιστάται για performance λόγους.

---

**Ε: Γιατί το shift έχει UNIQUE(department_id, shift_date, shift_type);**
**Α:** Γιατί για κάθε τμήμα, κάθε ημέρα, μπορεί να υπάρχει μόνο μία βάρδια κάθε τύπου (morning/afternoon/night). Δεν έχει νόημα να υπάρχουν δύο "morning" βάρδιες για το ίδιο τμήμα την ίδια μέρα.

---

**Ε: Ο trg_doctor_no_cycle χρησιμοποιεί WHILE loop. Γιατί max_depth = 50;**
**Α:** Safety guard. Αν για οποιοδήποτε λόγο υπάρξει κύκλος στα δεδομένα (π.χ. corrupted data) που δεν εντοπίζεται από τον έλεγχο `current_sup = NEW.staff_id`, ο loop δεν θα τρέξει για πάντα. 50 είναι ένα αυθαίρετο (αλλά πολύ μεγαλύτερο από κάθε ρεαλιστική ιεραρχία) όριο.

---

**Ε: Γιατί το hospitalization έχει RESTRICT (και όχι CASCADE) στο ON DELETE για patient_id;**
**Α:** Δεν θέλουμε να διαγράφουμε νοσηλείες αν διαγραφεί ασθενής — αυτό θα ήταν κλινικά επικίνδυνο (χάνεις ιατρικό ιστορικό). Το RESTRICT αναγκάζει τον χρήστη να διαγράψει πρώτα τις νοσηλείες, αν πραγματικά θέλει να διαγράψει ασθενή.

---

**Ε: Γιατί το bed.status έχει default τιμή 'διαθέσιμη';**
**Α:** Κάθε νέα κλίνη που εισάγεται είναι φυσικά διαθέσιμη. Το default αποτρέπει την ανάγκη να ορίζεις ρητά την κατάσταση κατά την εισαγωγή.

---

# ΜΕΡΟΣ 8 — Schema Design Decisions

## 8.1 ISA Ιεραρχία: Γιατί τρεις πίνακες και όχι ένας

**Αν χρησιμοποιούσαμε ένα πίνακα staff:**
```sql
-- Αντί για ISA:
staff (staff_id, ..., staff_type, specialty, license_number, rank_doctor, rank_nurse, role, department_id, ...)
```

**Προβλήματα:**
- specialty, license_number → NULL για νοσηλευτές και διοικητικούς
- rank έχει διαφορετικό CHECK ανά τύπο — αδύνατο να το ορίσεις σε ένα πίνακα
- department_id → NULL για doctors (M:N σχέση)
- supervisor_id → NULL για nurses/administrative
- Πολλά NULLs = κακό database design

**Πλεονεκτήματα ISA:**
- Type-specific constraints (CHECK για ranks)
- Καθαρά attributes ανά τύπο
- Foreign keys σε σωστά entities (department.director_id → doctor, όχι → staff)

## 8.2 Γιατί bed.status managed by trigger

**Εναλλακτική:** Η εφαρμογή ενημερώνει το bed.status μετά κάθε νοσηλεία.

**Πρόβλημα:** Αν η εφαρμογή κολλήσει ή αποτύχει μεταξύ INSERT hospitalization και UPDATE bed → inconsistent state. Η ΒΔ θα νόμιζε ότι η κλίνη είναι διαθέσιμη ενώ χρησιμοποιείται.

**Trigger λύση:** Ατομικό — το INSERT hospitalization και το UPDATE bed γίνονται στο ίδιο transaction. Είτε και τα δύο επιτυγχάνουν, είτε και τα δύο αποτυγχάνουν.

## 8.3 Γιατί total_cost αποθηκεύεται (και δεν υπολογίζεται on-the-fly)

**Πρόβλημα αν υπολογίζαμε on-the-fly:** Αν αλλάξει το `ken.base_cost` στο μέλλον, τα υπολογισμένα ιστορικά κόστη θα αλλάζουν — λάθος. Το κόστος πρέπει να "παγώνει" τη στιγμή εξόδου.

**Επίσης:** Πολλά queries χρειάζονται total_cost (Q01, Q03, Q06) — αποφεύγουμε επανάληψη σύνθετης λογικής.

## 8.4 Γιατί drug_substance είναι M:N πίνακας

**Εναλλακτική:** `drug.substances = 'ουσία1|ουσία2|ουσία3'` (string με separator)

**Πρόβλημα:** Δεν μπορείς να κάνεις JOIN, αναζήτηση, ή FK constraints. Το `LIKE '%ουσία%'` είναι fragile.

**Σωστό:** Κάθε σχέση drug-substance είναι ξεχωριστή γραμμή στο drug_substance — επιτρέπει JOINs, indexes, και τον allergy trigger.

## 8.5 Γιατί patient_allergy αναφέρεται σε active_substance και όχι σε drug

Η αλλεργία είναι σε **δραστική ουσία**, όχι σε συγκεκριμένο φάρμακο. Αν είσαι αλλεργικός στην Αμοξικιλλίνη, δεν μπορείς να λάβεις ΚΑΝΕΝΑ φάρμακο που την περιέχει — ανεξαρτήτως εμπορικού ονόματος. Αυτό το εκφράζει σωστά η M:N μεταξύ patient και active_substance.

## 8.6 Γιατί triage_record.outcome ∈ {'αποχώρηση', 'νοσηλεία'}

Η εκφώνηση ορίζει: *"Ο ασθενής είτε παίρνει οδηγίες και αποχωρεί, είτε παραπέμπεται για νοσηλεία."* Ακριβώς δύο outcomes — CHECK constraint το εξασφαλίζει.

## 8.7 Γιατί evaluation.evaluation_date μπορεί να είναι NULL

Η εκφώνηση δεν απαιτεί ακριβή ημερομηνία αξιολόγησης — ο ασθενής μπορεί να αξιολογήσει "αργότερα" χωρίς ημερομηνία. Το trigger εξασφαλίζει μόνο ότι η νοσηλεία είναι ολοκληρωμένη.

## 8.8 Γιατί το shift είναι ξεχωριστός πίνακας (και δεν γίνεται M:N απευθείας staff-ημερομηνία)

Το shift αντιπροσωπεύει μια **συγκεκριμένη βάρδια ενός τμήματος** (department + date + type). Πολλά μέλη προσωπικού μπορούν να ανατεθούν στην ίδια βάρδια → M:N μέσω shift_assignment. Αν κάναμε απευθείας "staff-date-type" χωρίς shift entity, δεν θα μπορούσαμε να αναφερθούμε στη βάρδια ως ενότητα (π.χ. triggers για rest_period χρειάζονται shift ως entity).

---

## Quick Reference: Trigger → Πότε Πυροδοτείται

| Trigger | Event | Timing | Πίνακας |
|---|---|---|---|
| trg_doctor_supervisor_insert | INSERT | BEFORE | doctor |
| trg_doctor_supervisor_update | UPDATE | BEFORE | doctor |
| trg_doctor_no_cycle_insert | INSERT | BEFORE | doctor |
| trg_doctor_no_cycle_update | UPDATE | BEFORE | doctor |
| trg_prescription_allergy_check | INSERT | BEFORE | prescription |
| trg_evaluation_discharged | INSERT | BEFORE | evaluation |
| trg_doctor_evaluation_check | INSERT | BEFORE | doctor_evaluation |
| trg_shift_monthly_limit | INSERT | BEFORE | shift_assignment |
| trg_shift_rest_period | INSERT | BEFORE | shift_assignment |
| trg_shift_consecutive_nights | INSERT | BEFORE | shift_assignment |
| trg_shift_trainee_requires_senior | INSERT | BEFORE | shift_assignment |
| trg_procedure_room_overlap | INSERT | BEFORE | medical_procedure |
| trg_procedure_doctor_overlap | INSERT | BEFORE | medical_procedure |
| trg_procedure_assistant_overlap | INSERT | BEFORE | procedure_assistant |
| trg_hospitalization_bed_check | INSERT | BEFORE | hospitalization |
| trg_hospitalization_bed_occupy | INSERT | **AFTER** | hospitalization |
| trg_hospitalization_bed_free | UPDATE | **AFTER** | hospitalization |
| trg_hospitalization_cost | UPDATE | BEFORE | hospitalization |

---

## Quick Reference: Index → Queries

| Index | Πίνακας(Στήλες) | Queries |
|---|---|---|
| idx_hospitalization_patient | hospitalization(patient_id) | Q03, Q06, Q09 |
| idx_hospitalization_department | hospitalization(department_id) | Q01, Q03 |
| idx_hospitalization_admission | hospitalization(admission_date) | Q01, Q09, Q14 |
| idx_hospitalization_ken | hospitalization(ken_code) | Q01 |
| idx_hospitalization_icd | hospitalization(icd10_code) | Q06, Q14 |
| idx_doctor_specialty | doctor(specialty) | Q02, Q05 |
| idx_doctor_rank | doctor(rank) | Q13 |
| idx_doctor_supervisor | doctor(supervisor_id) | Q13 |
| idx_shift_date | shift(shift_date) | Q08, Q12 |
| idx_shift_dept_date | shift(department_id, shift_date) | Q08, Q12 |
| idx_shift_assignment_staff | shift_assignment(staff_id) | Q02, Q08, Q12 |
| idx_lab_test_hospitalization | lab_test(hospitalization_id) | general |
| idx_procedure_surgeon | medical_procedure(primary_surgeon_id) | Q02, Q05, Q11 |
| idx_procedure_start_time | medical_procedure(start_time) | Q02, Q11 |
| idx_staff_age | staff(age) | Q05 |
| idx_drug_name | drug(drug_name) | load.sql |
| idx_drug_substance_drug | drug_substance(drug_id) | Q10 |
| idx_drug_substance_substance | drug_substance(substance_id) | Q07, Q10 |
| idx_prescription_patient | prescription(patient_id) | Q10 |
| idx_prescription_doctor | prescription(doctor_id) | trigger |
| idx_prescription_hospitalization | prescription(hospitalization_id) | Q10, trigger |
| idx_patient_allergy_substance | patient_allergy(substance_id) | Q07, trigger |
| idx_triage_urgency | triage_record(urgency_level) | Q15 |
| idx_evaluation_hospitalization | evaluation(hospitalization_id) | Q04, Q06 |
| idx_doctor_evaluation_doctor | doctor_evaluation(doctor_id) | Q04 |

---

*Τελευταία ενημέρωση: 2026-05-12*
*Project: Νοσοκομείο Υγειόπολης — ΣΗΜΜΥ/ΕΜΠ 2025-2026*
