# Οδηγός Βάσεων Δεδομένων — Από το Μηδέν
## Βασισμένος στο Project: Νοσοκομείο Υγειόπολης

> Αυτός ο οδηγός εξηγεί τη θεωρία των βάσεων δεδομένων σαν να μιλάμε σε κάποιον που δεν ξέρει ΤΙΠΟΤΑ. Κάθε έννοια εξηγείται από την αρχή, με παράδειγμα από το πραγματικό μας project.

---

## ΜΕΡΟΣ 1 — Τι είναι μια Βάση Δεδομένων;

### 1.1 Το πρόβλημα που λύνει

Φαντάσου ότι είσαι υπεύθυνος ενός νοσοκομείου. Έχεις εκατοντάδες ασθενείς, δεκάδες γιατρούς, χιλιάδες συνταγές, νοσηλείες, αποτελέσματα εξετάσεων. Πού τα βάζεις όλα αυτά;

**Επιλογή 1: Χαρτιά**
Κάθε ασθενής έχει έναν φάκελο. Αλλά αν θέλεις να βρεις "όλους τους ασθενείς με αλλεργία στην πενικιλίνη που νοσηλεύτηκαν φέτος" — θα χρειαστείς μέρες.

**Επιλογή 2: Excel**
Καλύτερο, αλλά αν έχεις 500 ασθενείς και 5.000 νοσηλείες και θέλεις να τα συσχετίσεις — γίνεται χάος.

**Επιλογή 3: Βάση Δεδομένων**
Αποθηκεύεις τα δεδομένα οργανωμένα σε **πίνακες**, και μπορείς να κάνεις ερωτήσεις ("queries") για να βρεις οτιδήποτε, αστραπιαία.

Μια **Βάση Δεδομένων (ΒΔ)** είναι ένα οργανωμένο σύστημα αποθήκευσης δεδομένων. Το πρόγραμμα που τη διαχειρίζεται λέγεται **RDBMS** (Relational Database Management System). Στο project μας χρησιμοποιούμε **MariaDB** (που είναι ουσιαστικά MySQL).

---

### 1.2 Πίνακας = Το βασικό δομικό στοιχείο

Ένας **πίνακας** (table) είναι σαν ένα φύλλο Excel:
- Κάθε **στήλη** (column / field) είναι ένα χαρακτηριστικό
- Κάθε **γραμμή** (row / record / tuple) είναι ένα αντικείμενο

**Παράδειγμα από το project μας — πίνακας `patient`:**

```
patient_id | first_name | last_name | age | insurance_provider
-----------+------------+-----------+-----+-------------------
1          | Γιώργος    | Παπάς     | 45  | ΕΟΠΥΥ
2          | Μαρία      | Νικολάου  | 32  | IKA
3          | Κώστας     | Δήμου     | 67  | Ιδιωτική
```

Κάθε γραμμή = ένας ασθενής. Κάθε στήλη = ένα χαρακτηριστικό του ασθενή.

Το νοσοκομείο μας έχει **26 πίνακες** συνολικά. Ο κάθε πίνακας αποθηκεύει μια διαφορετική "κατηγορία" πληροφοριών: ασθενείς, γιατρούς, νοσηλείες, φάρμακα, βάρδιες κλπ.

---

### 1.3 Τύποι Δεδομένων — Τι είδους πληροφορία χωράει σε κάθε στήλη

Όπως στη ζωή άλλο χωράει σε κούτα και άλλο σε ποτήρι, στη ΒΔ κάθε στήλη έχει έναν **τύπο δεδομένων** που καθορίζει τι επιτρέπεται να μπει εκεί.

**Κύριοι τύποι που βλέπουμε στο project μας:**

| Τύπος | Τι αποθηκεύει | Παράδειγμα από project |
|-------|--------------|------------------------|
| `INT` | Ακέραιος αριθμός | `patient_id`, `age`, `num_beds` |
| `VARCHAR(n)` | Κείμενο μέχρι n χαρακτήρες | `first_name VARCHAR(50)`, `specialty VARCHAR(80)` |
| `CHAR(n)` | Κείμενο ακριβώς n χαρακτήρες | `amka CHAR(11)` (το ΑΜΚΑ είναι πάντα 11 ψηφία) |
| `TEXT` | Μεγάλο κείμενο χωρίς όριο | `description TEXT`, `symptoms TEXT` |
| `DATE` | Ημερομηνία (YYYY-MM-DD) | `admission_date`, `hiring_date` |
| `DATETIME` | Ημερομηνία + ώρα | `arrival_time DATETIME`, `start_time DATETIME` |
| `DECIMAL(10,2)` | Δεκαδικός αριθμός | `total_cost DECIMAL(10,2)`, `base_cost DECIMAL(10,2)` |

**Γιατί έχει σημασία ο τύπος;**

Αν βάλεις `age` ως `VARCHAR`, τότε η ΒΔ θα δέχεται "σαράντα πέντε" ως ηλικία — κι εσύ δεν μπορείς να υπολογίσεις μέσο όρο σε κείμενο. Με `INT` η ΒΔ αρνείται να δεχτεί κείμενο και μπορείς να κάνεις `AVG(age)`.

**Παράδειγμα από το project:**
```sql
-- Στον πίνακα staff:
age INT                     -- μόνο αριθμοί
first_name VARCHAR(50)      -- κείμενο μέχρι 50 χαρακτήρες
hiring_date DATE            -- ημερομηνία πρόσληψης
photo_url TEXT              -- URL εικόνας (μακρύ string)
```

---

## ΜΕΡΟΣ 2 — Primary Key: Ο "Αριθμός Ταυτότητας" κάθε Γραμμής

### 2.1 Το πρόβλημα της αναγνώρισης

Φαντάσου δύο ασθενείς με το ίδιο όνομα: "Γιώργος Παπάς". Πώς ξέρεις ποιον εννοείς; Χρησιμοποιείς κάτι **μοναδικό** για τον καθένα.

Στη ΒΔ αυτό λέγεται **Primary Key (PK)** — πρωτεύον κλειδί. Είναι μια στήλη (ή συνδυασμός στηλών) που **μοναδικά ταυτοποιεί** κάθε γραμμή.

**Κανόνες Primary Key:**
1. Δεν μπορεί να είναι NULL (πρέπει πάντα να έχει τιμή)
2. Δεν μπορεί να επαναληφθεί (κάθε τιμή μοναδική)
3. Δεν αλλάζει (αν αλλάξει, χάνεται η σύνδεση με άλλα δεδομένα)

**Παραδείγματα από το project:**

```sql
-- Πίνακας patient: AUTO_INCREMENT integer
patient_id INT AUTO_INCREMENT
PRIMARY KEY (patient_id)
-- → 1, 2, 3, 4... αυτόματα

-- Πίνακας ken (Κλειστά Νοσήλια): φυσικό κλειδί
ken_code VARCHAR(20)
PRIMARY KEY (ken_code)
-- → 'K001', 'K002' κλπ (κωδικοί από το Υπ. Υγείας)

-- Πίνακας drug_substance: σύνθετο κλειδί
PRIMARY KEY (drug_id, substance_id)
-- → Συνδυασμός φαρμάκου+ουσίας είναι μοναδικός
```

### 2.2 AUTO_INCREMENT — Ο "αυτόματος αριθμητής"

Το `AUTO_INCREMENT` σημαίνει: "η ΒΔ αναθέτει αυτόματα τον επόμενο αριθμό".

```sql
-- Εισάγω νέο ασθενή:
INSERT INTO patient (first_name, last_name, ...) VALUES ('Μαρία', 'Δήμου', ...);
-- Η ΒΔ βάζει αυτόματα patient_id = 1

-- Εισάγω δεύτερο:
INSERT INTO patient (first_name, last_name, ...) VALUES ('Κώστας', 'Νικολάου', ...);
-- Η ΒΔ βάζει αυτόματα patient_id = 2
```

**Γιατί δεν χρησιμοποιούμε το ΑΜΚΑ ως PK για ασθενείς;**
Το `amka` είναι `CHAR(11)` — string. Τα JOINs με string είναι πιο αργά από integer. Επίσης, το ΑΜΚΑ μπορεί θεωρητικά να αλλάξει (λάθος εγγραφή). Ένα surrogate key (patient_id) δεν αλλάζει ποτέ. Το ΑΜΚΑ κρατάμε ως `UNIQUE` constraint — εγγυόμαστε ότι είναι μοναδικό αλλά δεν το χρησιμοποιούμε ως δείκτη στις σχέσεις.

### 2.3 Composite Primary Key — Όταν χρειάζονται δύο στήλες μαζί

Μερικές φορές μια στήλη δεν αρκεί. Χρειαζόμαστε **συνδυασμό** δύο στηλών.

```sql
-- Πίνακας shift_assignment:
PRIMARY KEY (shift_id, staff_id)
```

Αυτό σημαίνει: "ο ίδιος υπάλληλος μπορεί να ανατεθεί σε πολλές βάρδιες, αλλά στην ίδια βάρδια μπορεί να ανατεθεί μόνο μια φορά". Ούτε το shift_id μόνο του ούτε το staff_id μόνο του είναι μοναδικό — αλλά ο **συνδυασμός** τους είναι.

```
shift_id | staff_id   ← Composite PK
---------+---------
1        | 5          ← OK
1        | 7          ← OK (διαφορετικός υπάλληλος, ίδια βάρδια)
2        | 5          ← OK (ίδιος υπάλληλος, διαφορετική βάρδια)
1        | 5          ← ΑΠΑΓΟΡΕΥΕΤΑΙ (υπάρχει ήδη)
```

---

## ΜΕΡΟΣ 3 — NULL: Η "Άγνωστη Τιμή"

### 3.1 Τι είναι το NULL

`NULL` δεν είναι μηδέν. Δεν είναι κενό κείμενο. Είναι η **απουσία τιμής** — "δεν ξέρουμε" ή "δεν εφαρμόζεται".

**Παραδείγματα από το project:**

```sql
discharge_date DATE    -- NULL σημαίνει: ο ασθενής είναι ακόμα νοσηλευόμενος
total_cost DECIMAL     -- NULL σημαίνει: δεν έχει υπολογιστεί ακόμα
supervisor_id INT      -- NULL σημαίνει: ο γιατρός δεν έχει επόπτη (είναι Διευθυντής)
ken_code VARCHAR       -- NULL σημαίνει: δεν έχει ανατεθεί ΚΕΝ κατηγορία
```

### 3.2 Πώς συμπεριφέρεται το NULL

**Παγίδα:** `NULL = NULL` είναι... NULL (όχι TRUE)!

```sql
-- ΛΑΘΟΣ:
WHERE discharge_date = NULL    -- δεν επιστρέφει τίποτα!

-- ΣΩΣΤΟ:
WHERE discharge_date IS NULL   -- επιστρέφει νοσηλείες χωρίς έξοδο
WHERE discharge_date IS NOT NULL  -- νοσηλείες με έξοδο
```

### 3.3 COALESCE — Αντικατάσταση NULL με προεπιλεγμένη τιμή

Η `COALESCE(τιμή1, τιμή2)` επιστρέφει την πρώτη τιμή που **δεν είναι NULL**.

**Παραδείγματα από τα queries μας:**

```sql
-- Q09: Αν ο ασθενής είναι ακόμα νοσηλευόμενος (discharge_date IS NULL),
--       χρησιμοποίησε τη σημερινή ημέρα για να υπολογίσεις πόσες μέρες πέρασε
DATEDIFF(COALESCE(h.discharge_date, CURDATE()), h.admission_date)

-- Triggers επεμβάσεων: αν η επέμβαση δεν έχει τελειώσει ακόμα,
--                       θεώρησέ την σαν να τελειώνει στο απώτατο μέλλον
COALESCE(end_time, '9999-12-31')

-- Q01: αν δεν υπάρχει total_cost (δεν υπολογίστηκε ακόμα), χρησιμοποίησε το base_cost
COALESCE(h.total_cost, k.base_cost)
```

### 3.4 NOT NULL — Απαγόρευση NULL

Όταν μια τιμή είναι **υποχρεωτική**, βάζουμε `NOT NULL`:

```sql
-- Στον πίνακα patient:
first_name VARCHAR(50) NOT NULL    -- κάθε ασθενής ΠΡΕΠΕΙ να έχει όνομα
insurance_provider VARCHAR(50) NOT NULL  -- ΠΡΕΠΕΙ να έχει ασφαλιστικό φορέα
amka CHAR(11) NOT NULL             -- ΠΡΕΠΕΙ να έχει ΑΜΚΑ

-- Αλλά:
age INT                            -- η ηλικία μπορεί να είναι άγνωστη (χωρίς NOT NULL)
phone VARCHAR(15)                  -- μπορεί να μην έχει τηλέφωνο
```

---

## ΜΕΡΟΣ 4 — Constraints: Κανόνες που Φυλάει η ΒΔ

### 4.1 Τι είναι constraint

Ένα **constraint** (περιορισμός) είναι ένας κανόνας που η ΒΔ ελέγχει αυτόματα. Αν προσπαθήσεις να παραβιάσεις τον κανόνα, η ΒΔ αρνείται.

Σκέψου το σαν τα "checks" στα αεροδρόμια — δεν σε αφήνουν να μπεις αν δεν έχεις διαβατήριο, ανεξάρτητα από ποιος σε στέλνει.

### 4.2 CHECK Constraint

Ελέγχει αν μια τιμή πληροί συγκεκριμένη συνθήκη.

**Παραδείγματα από το project:**

```sql
-- staff: η ηλικία πρέπει να είναι μεταξύ 18 και 80
CHECK (age >= 18 AND age <= 80)

-- patient: η ηλικία πρέπει να είναι μεταξύ 0 και 120
CHECK (age >= 0 AND age <= 120)

-- doctor: ο βαθμός πρέπει να είναι ένας από τους 4 έγκυρους
CHECK (`rank` IN ('Ειδικευόμενος', 'Επιμελητής Β', 'Επιμελητής Α', 'Διευθυντής'))

-- triage_record: το επίπεδο επείγοντος 1-5
CHECK (urgency_level BETWEEN 1 AND 5)

-- hospitalization: η έξοδος δεν μπορεί να είναι πριν την είσοδο
CHECK (discharge_date IS NULL OR discharge_date >= admission_date)

-- shift: μόνο τρεις τύποι βάρδιας
CHECK (shift_type IN ('morning', 'afternoon', 'night'))
```

**Πότε δεν αρκεί το CHECK;**

Το CHECK μπορεί να ελέγξει μόνο τιμές **της ίδιας γραμμής**. Δεν μπορεί να κοιτάξει άλλους πίνακες. Για αυτό χρειαζόμαστε triggers (βλέπε ΜΕΡΟΣ 8).

```sql
-- Αυτό ΔΕΝ μπορεί να γίνει με CHECK:
-- "ο ειδικευόμενος πρέπει να έχει supervisor που υπάρχει στον πίνακα doctor"
-- Χρειάζεται trigger!
```

### 4.3 UNIQUE Constraint

Εγγυάται ότι δεν υπάρχουν δύο γραμμές με την ίδια τιμή σε αυτή τη στήλη.

**Παραδείγματα:**

```sql
-- staff: κάθε υπάλληλος έχει μοναδικό ΑΜΚΑ
UNIQUE (amka)

-- department: κάθε τμήμα έχει μοναδικό όνομα
UNIQUE (name)

-- evaluation: κάθε νοσηλεία έχει μόνο μία αξιολόγηση
UNIQUE (hospitalization_id)

-- shift: για κάθε τμήμα/ημέρα/τύπο υπάρχει μόνο μία βάρδια
UNIQUE (department_id, shift_date, shift_type)

-- prescription: ο ίδιος γιατρός δεν μπορεί να συνταγογραφήσει
--               το ίδιο φάρμακο στον ίδιο ασθενή την ίδια μέρα δύο φορές
UNIQUE (doctor_id, patient_id, drug_id, start_date)
```

### 4.4 DEFAULT — Προεπιλεγμένη τιμή

Αν δεν δώσεις τιμή κατά την εισαγωγή, η ΒΔ βάζει αυτόματα την default:

```sql
-- bed: κάθε νέα κλίνη είναι "διαθέσιμη" από προεπιλογή
`status` VARCHAR(30) DEFAULT 'διαθέσιμη'
```

---

## ΜΕΡΟΣ 5 — Foreign Key: Οι "Γέφυρες" μεταξύ Πινάκων

### 5.1 Το πρόβλημα της σύνδεσης

Στον πίνακα `hospitalization` έχουμε το `patient_id`. Αλλά τα στοιχεία του ασθενή (όνομα, ηλικία κλπ.) είναι στον πίνακα `patient`. Πώς "συνδέουμε" τους δύο πίνακες;

Με **Foreign Key (FK)** — ξένο κλειδί. Είναι μια στήλη σε έναν πίνακα που **αναφέρεται** στο Primary Key **άλλου** πίνακα.

```
πίνακας patient:         πίνακας hospitalization:
patient_id | first_name  hospitalization_id | patient_id | admission_date
-----------+-----------  ------------------+-----------+---------------
1          | Γιώργος     1                  | 1          | 2025-01-15
2          | Μαρία       2                  | 1          | 2025-06-20
                         3                  | 2          | 2025-03-10
                                             ↑
                              αυτό το patient_id αναφέρεται
                              στον πίνακα patient
```

### 5.2 Referential Integrity — "Δεν μπορείς να αναφερθείς σε κάτι που δεν υπάρχει"

Το FK εγγυάται ότι δεν μπορείς να βάλεις `patient_id = 999` στη νοσηλεία αν δεν υπάρχει ασθενής με id=999.

```sql
-- Στον πίνακα hospitalization:
FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
```

Αν προσπαθήσεις `INSERT INTO hospitalization (..., patient_id, ...) VALUES (..., 999, ...)` και δεν υπάρχει patient με id=999 — **ERROR**.

### 5.3 ON DELETE και ON UPDATE — Τι γίνεται όταν διαγράφεται το "γονικό" στοιχείο

Τι γίνεται αν διαγράψουμε έναν ασθενή που έχει νοσηλείες; Έχουμε τρεις επιλογές:

**CASCADE:** "Αν διαγράψεις τον ασθενή, διέγραψε και όλες τις νοσηλείες του"
```sql
-- emergency_contact: αν διαγραφεί ο ασθενής, διαγράφονται και οι επαφές έκτακτης ανάγκης
FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
    ON DELETE CASCADE ON UPDATE CASCADE
```

**RESTRICT:** "Δεν επιτρέπεται να διαγράψεις τον ασθενή αν έχει νοσηλείες"
```sql
-- hospitalization: αν ο ασθενής έχει νοσηλείες, απαγορεύεται η διαγραφή του
FOREIGN KEY (patient_id) REFERENCES patient(patient_id)
    ON DELETE RESTRICT ON UPDATE CASCADE
```

**SET NULL:** "Αν διαγράψεις τον επόπτη, βάλε NULL στο supervisor_id"
```sql
-- doctor: αν διαγράψεις τον supervisor, οι υφιστάμενοι δεν διαγράφονται
--          απλώς χάνουν τον επόπτη τους (supervisor_id → NULL)
FOREIGN KEY (supervisor_id) REFERENCES doctor(staff_id)
    ON DELETE SET NULL ON UPDATE CASCADE
```

**Ένας χάρτης των FK στο project μας:**
```
staff ──────────────────────────────────────────┐
  ├── doctor ──────────── doctor_department      │
  │     └── (supervisor_id → doctor.staff_id)   │ CASCADE
  ├── nurse ─────────────── department           │
  └── administrative ─────── department          │
                                                  │
patient ────────────── hospitalization ←──────────┘
                          ├── ken
                          ├── bed ← department
                          ├── ICD10
                          ├── evaluation
                          ├── doctor_evaluation
                          ├── lab_test
                          ├── medical_procedure ── procedure_room
                          │     └── procedure_assistant
                          ├── prescription ── drug ── drug_substance ── active_substance
                          └── triage_record                                   ↑
                                                         patient_allergy ─────┘
```

### 5.4 Κυκλική Εξάρτηση — Το "Κοτόπουλο και το Αυγό"

Στο project μας υπάρχει ένα ενδιαφέρον πρόβλημα:

- `department` χρειάζεται `director_id → doctor.staff_id`
- `doctor` είναι subtype του `staff` (δεν εξαρτάται από department)
- `nurse` χρειάζεται `department_id → department.department_id`

Άρα: για να δημιουργήσεις ένα department, χρειάζεται να υπάρχει doctor. Αλλά για να δημιουργήσεις nurse, χρειάζεται department. Αυτό **δεν** είναι κυκλική εξάρτηση γιατί doctor δεν εξαρτάται από department.

Αλλά αν βάλαμε το FK `director_id` στη CREATE TABLE του department, η ΒΔ θα έλεγε "ο πίνακας doctor δεν υπάρχει ακόμα" (αν δημιουργούμε department πριν τον doctor). Η λύση:

```sql
-- Δημιουργούμε department ΧΩΡΙΣ το FK
CREATE TABLE department (
    department_id INT AUTO_INCREMENT,
    director_id INT,          -- υπάρχει η στήλη αλλά χωρίς FK ακόμα
    ...
);

-- Αφού δημιουργηθούν και staff και doctor:
ALTER TABLE department
    ADD CONSTRAINT fk_department_director
    FOREIGN KEY (director_id) REFERENCES doctor(staff_id)
    ON DELETE SET NULL ON UPDATE CASCADE;
```

---

## ΜΕΡΟΣ 6 — Σχέσεις μεταξύ Πινάκων

### 6.1 Τύποι Σχέσεων

**1:1 (Ένα προς Ένα)**
Κάθε γραμμή του πίνακα Α αντιστοιχεί σε **ακριβώς μία** γραμμή του πίνακα Β.
Παράδειγμα: κάθε νοσηλεία έχει **το πολύ μία** αξιολόγηση (UNIQUE hospitalization_id στο evaluation).

**1:Ν (Ένα προς Πολλά)**
Κάθε γραμμή του πίνακα Α αντιστοιχεί σε **πολλές** γραμμές του πίνακα Β.
Παράδειγμα: ένας ασθενής → πολλές νοσηλείες. Ένα τμήμα → πολλές κλίνες.

**Μ:Ν (Πολλά προς Πολλά)**
Κάθε γραμμή του Α μπορεί να αντιστοιχεί σε πολλές του Β, και αντίστροφα.
Παράδειγμα: ένας γιατρός → πολλά τμήματα. Ένα τμήμα → πολλοί γιατροί.

### 6.2 Πώς υλοποιείται η Μ:Ν σχέση — Junction Table

Η ΒΔ **δεν μπορεί** να αποθηκεύσει απευθείας μια Μ:Ν σχέση. Χρειάζεται ένας **ενδιάμεσος πίνακας** (junction table / bridge table).

**Παράδειγμα — γιατρός και τμήμα:**

Δεν μπορούμε να βάλουμε στον doctor "τμήματα: 1,3,5" (αντι-κανονική μορφή). Δεν μπορούμε να βάλουμε στο department "γιατροί: 2,7,12" (ίδιο πρόβλημα).

Λύση: πίνακας `doctor_department`:
```sql
CREATE TABLE doctor_department (
    staff_id      INT NOT NULL,    -- FK → doctor
    department_id INT NOT NULL,    -- FK → department
    PRIMARY KEY (staff_id, department_id)
);
```

```
doctor:          doctor_department:    department:
staff_id         staff_id | dept_id    department_id | name
--------         ---------+---------   -------------+----------
2                2        | 1          1             | Καρδιολογία
7                2        | 3          3             | Χειρουργική
12               7        | 1          
                 7        | 3          
                 12       | 3          
```

**Όλοι οι junction tables του project:**

| Junction Table | Συνδέει | Επιπλέον στήλες |
|----------------|---------|-----------------|
| `doctor_department` | doctor ↔ department | — |
| `drug_substance` | drug ↔ active_substance | — |
| `patient_allergy` | patient ↔ active_substance | — |
| `shift_assignment` | shift ↔ staff | — |
| `procedure_assistant` | medical_procedure ↔ staff | `role` |

### 6.3 Self-Referencing FK — Πίνακας που αναφέρεται στον εαυτό του

Στο project υπάρχει κάτι ιδιαίτερο: ένας γιατρός έχει **επόπτη** που είναι **και αυτός γιατρός**. Άρα ο πίνακας `doctor` αναφέρεται στον εαυτό του:

```sql
CREATE TABLE doctor (
    staff_id      INT,
    supervisor_id INT,           -- αυτό είναι FK που δείχνει πίσω στο doctor!
    ...
    FOREIGN KEY (supervisor_id) REFERENCES doctor(staff_id)
);
```

```
doctor:
staff_id | first_name | supervisor_id
---------+------------+--------------
1        | Δημήτρης   | NULL          ← Διευθυντής, δεν έχει επόπτη
2        | Γιώργος    | 1             ← Επιμελητής, επόπτης ο staff_id=1
3        | Μαρία      | 2             ← Ειδικευόμενη, επόπτης ο staff_id=2
```

Αυτό δημιουργεί μια **ιεραρχική δομή** (δέντρο): Διευθυντής → Επιμελητής → Ειδικευόμενος.

---

## ΜΕΡΟΣ 7 — ISA Ιεραρχία: Κληρονομικότητα στη ΒΔ

### 7.1 Τι είναι το ISA

Το "IS-A" (είναι-ένα) είναι μια σχέση κληρονομικότητας. Στο project:
- Ένας γιατρός **IS-A** υπάλληλος (staff)
- Ένας νοσηλευτής **IS-A** υπάλληλος
- Ένας διοικητικός **IS-A** υπάλληλος

Όλοι μοιράζονται κοινά χαρακτηριστικά (ΑΜΚΑ, όνομα, ηλικία). Αλλά κάθε τύπος έχει και ξεχωριστά (γιατρός έχει specialty, νοσηλευτής έχει rank διαφορετικής κλίμακας).

### 7.2 Πώς υλοποιείται το ISA

**Επιλογή 1: Ένας πίνακας για όλους** (flat table)
```sql
-- ΔΕΝ το κάνουμε αυτό:
staff(staff_id, name, type, specialty, license_no, nurse_rank, role, office_name, department_id)
-- Πρόβλημα: ΤΕΡΑΣΤΙΑ NULL για κάθε γραμμή
-- Ένας γιατρός έχει NULL στο nurse_rank, NULL στο role, NULL στο office_name
-- Ένας νοσηλευτής έχει NULL στο specialty, NULL στο license_no κλπ.
```

**Επιλογή 2: ISA με ξεχωριστούς πίνακες** (που κάνουμε στο project)
```sql
-- Γονικός πίνακας: τα ΚΟΙΝΑ χαρακτηριστικά
CREATE TABLE staff (
    staff_id INT AUTO_INCREMENT PRIMARY KEY,
    amka, first_name, last_name, age, email, phone,
    hiring_date, staff_type, photo_url, description
);

-- Παιδικός πίνακας: ΤΑ ΕΙΔΙΚΑ χαρακτηριστικά γιατρού
CREATE TABLE doctor (
    staff_id INT PRIMARY KEY,           -- ΚΑΙ PK ΚΑΙ FK!
    license_number, specialty, rank, supervisor_id,
    FOREIGN KEY (staff_id) REFERENCES staff(staff_id) ON DELETE CASCADE
);
```

Η κλάση `doctor.staff_id` είναι **και Primary Key** (μοναδική αναγνώριση) **και Foreign Key** (αναφέρεται στο staff). Αυτό εξασφαλίζει ότι κάθε γιατρός **είναι** και υπάλληλος.

**ON DELETE CASCADE:** Αν διαγράψεις έναν υπάλληλο από το `staff`, διαγράφεται αυτόματα και από το `doctor`/`nurse`/`administrative`. Λογικό — αν δεν είναι πλέον υπάλληλος, δεν είναι και γιατρός.

### 7.3 Γιατί ISA και όχι ένας πίνακας

**Καθαρά attributes:** Το `specialty` ανήκει μόνο σε γιατρούς. Το `rank` έχει διαφορετικές επιτρεπτές τιμές για νοσηλευτές ('Βοηθός Νοσηλευτή', 'Νοσηλευτής', 'Προϊστάμενος') και γιατρούς ('Ειδικευόμενος', 'Επιμελητής Β' κλπ). Με ISA μπορούμε να έχουμε ξεχωριστά CHECK constraints.

**FK με νόημα:** Το `department.director_id` αναφέρεται στο `doctor(staff_id)` — όχι στο `staff(staff_id)`. Ο διευθυντής πρέπει να είναι **γιατρός** συγκεκριμένα.

**`staff_type` στο γονικό:** Παρόλο που έχουμε ISA, κρατάμε το `staff_type VARCHAR(20)` στον `staff` πίνακα. Γιατί; Για να μπορούμε να ξέρουμε τον τύπο ενός υπαλλήλου χωρίς να κάνουμε JOIN με τους υποπίνακες. Χρησιμοποιείται στον trigger `trg_shift_monthly_limit` για να βρει γρήγορα "είναι γιατρός ή νοσηλευτής ή διοικητικός".

---

## ΜΕΡΟΣ 8 — SQL: Η Γλώσσα των Ερωτήσεων

### 8.1 SELECT — "Δείξε μου"

Το `SELECT` λέει "θέλω να δω αυτές τις στήλες":

```sql
SELECT first_name, last_name, age FROM patient;
-- → επιστρέφει μόνο αυτές τις τρεις στήλες από όλους τους ασθενείς

SELECT * FROM patient;
-- → επιστρέφει ΟΛΕς τις στήλες (αστέρι = όλα)
```

### 8.2 WHERE — "Αλλά μόνο αν..."

Το `WHERE` φιλτράρει γραμμές:

```sql
SELECT * FROM staff WHERE age < 35;
-- → μόνο υπάλληλοι κάτω των 35 ετών (χρησιμοποιείται στο Q05)

SELECT * FROM hospitalization WHERE discharge_date IS NULL;
-- → μόνο ασθενείς που είναι ακόμα νοσηλευόμενοι

SELECT * FROM doctor WHERE specialty = 'Χειρουργική';
-- → μόνο χειρουργοί (χρησιμοποιείται στο Q02)
```

### 8.3 JOIN — "Συνδύασε δύο πίνακες"

Το `JOIN` παίρνει γραμμές από δύο πίνακες και τις συνδυάζει βάσει μιας κοινής τιμής.

**INNER JOIN:** επιστρέφει μόνο γραμμές που έχουν **ταίριασμα και στους δύο** πίνακες.

```sql
-- Q03: ασθενείς με τις νοσηλείες τους
SELECT p.first_name, h.admission_date
FROM hospitalization h
JOIN patient p ON p.patient_id = h.patient_id;
```

Σκέψου το έτσι: η ΒΔ παίρνει κάθε νοσηλεία, βρίσκει τον αντίστοιχο ασθενή (μέσω patient_id), και τα "κολλάει" μαζί σε μια γραμμή.

```
hospitalization:         patient:
hosp_id | patient_id    patient_id | first_name
--------+-----------    -----------+-----------
1       | 1          →  1          | Γιώργος
2       | 1          →  1          | Γιώργος
3       | 2          →  2          | Μαρία

Αποτέλεσμα JOIN:
hosp_id | patient_id | first_name
--------+-----------+-----------
1       | 1          | Γιώργος
2       | 1          | Γιώργος
3       | 2          | Μαρία
```

**LEFT JOIN:** επιστρέφει **όλες** τις γραμμές του αριστερού πίνακα, και NULL για τον δεξί αν δεν υπάρχει ταίριασμα.

```sql
-- Q01: LEFT JOIN με ken — νοσηλείες ΧΩΡΙΣ ken_code εμφανίζονται με NULL τιμές
LEFT JOIN ken k ON k.ken_code = h.ken_code
```

```
hospitalization:          ken:
ken_code                  ken_code | base_cost
--------                  ---------+---------
'K001'    → ταιριάζει     'K001'   | 1200.00
NULL      → ΔΕΝ ταιριάζει

Αποτέλεσμα LEFT JOIN:
ken_code | base_cost
---------+---------
'K001'   | 1200.00
NULL     | NULL        ← γραμμή από νοσηλεία χωρίς KEN, αλλά δεν εξαφανίζεται
```

Αν χρησιμοποιούσαμε INNER JOIN, οι νοσηλείες χωρίς KEN θα **εξαφανίζονταν** από τα αποτελέσματα.

**CROSS JOIN:** κάθε γραμμή του Α συνδυάζεται με κάθε γραμμή του Β (χωρίς συνθήκη).

```sql
-- Q11: συνδυάζει κάθε γιατρό με τη μοναδική γραμμή "top_count"
CROSS JOIN top_count tc
```

Χρησιμοποιείται μόνο όταν ένας πίνακας έχει **ακριβώς 1 γραμμή** (π.χ. το top_count έχει μόνο τον μέγιστο αριθμό επεμβάσεων) και θέλουμε να "επισυνάψουμε" αυτή την τιμή σε κάθε γραμμή άλλου πίνακα.

### 8.4 GROUP BY — "Ομαδοποίησε"

Το `GROUP BY` **συγκεντρώνει** γραμμές που μοιράζονται κοινές τιμές σε μία γραμμή ανά ομάδα.

```sql
-- Q03: πόσες νοσηλείες έχει κάθε ασθενής ανά τμήμα
SELECT p.patient_id, d.name, COUNT(*) AS hospitalizations
FROM hospitalization h
JOIN patient p ON p.patient_id = h.patient_id
JOIN department d ON d.department_id = h.department_id
GROUP BY p.patient_id, d.department_id;
```

Πριν GROUP BY: 500 γραμμές (μία ανά νοσηλεία)
Μετά GROUP BY: μία γραμμή ανά (ασθενής, τμήμα) συνδυασμό

**Κανόνας:** Μετά το GROUP BY, μπορείς να βάλεις στο SELECT μόνο:
1. Στήλες που έχεις στο GROUP BY
2. Aggregate functions (COUNT, SUM, AVG, MAX, MIN)

### 8.5 Aggregate Functions — Υπολογισμοί πάνω σε ομάδες

| Συνάρτηση | Τι κάνει | Παράδειγμα |
|-----------|---------|------------|
| `COUNT(*)` | Μετράει γραμμές | `COUNT(*) AS hospitalizations` |
| `COUNT(DISTINCT col)` | Μετράει μοναδικές τιμές | `COUNT(DISTINCT sh.shift_id)` |
| `SUM(col)` | Άθροισμα | `SUM(k.base_cost)` |
| `AVG(col)` | Μέσος όρος | `AVG(de.medical_care)` |
| `MAX(col)` | Μέγιστο | `MAX(current_year_procedures)` |
| `MIN(col)` | Ελάχιστο | — |
| `ROUND(x, n)` | Στρογγυλοποίηση | `ROUND(AVG(...), 2)` |

**COUNT(*) vs COUNT(DISTINCT):**

```sql
-- Q02: ένας γιατρός έχει ανατεθεί σε 10 βάρδιες → 10 γραμμές μετά το JOIN
-- COUNT(*) = 10 (αλλά θέλουμε να ξέρουμε πόσες ΔΙΑΦΟΡΕΤΙΚΕΣ βάρδιες)
-- COUNT(DISTINCT sh.shift_id) = 10 (αν όλες είναι διαφορετικές)

-- Σε πολύπλοκα JOINs μπορεί να υπάρχουν duplicates:
-- COUNT(DISTINCT) προστατεύει από λανθασμένη μέτρηση
```

### 8.6 HAVING — "Φίλτρο ΜΕΤΑ το GROUP BY"

Το `WHERE` φιλτράρει γραμμές **πριν** το GROUP BY.
Το `HAVING` φιλτράρει ομάδες **μετά** το GROUP BY.

```sql
-- Q03: ασθενείς με ΠΕΡΙΣΣΟΤΕΡΕΣ ΑΠΟ 3 νοσηλείες στο ίδιο τμήμα
GROUP BY p.patient_id, d.department_id
HAVING COUNT(*) > 3    -- αυτό ΔΕΝ μπορεί να μπει στο WHERE
                       -- γιατί το COUNT(*) δεν υπάρχει πριν το GROUP BY
```

Κανόνας: αν η συνθήκη περιλαμβάνει aggregate function → HAVING.

### 8.7 ORDER BY — "Ταξινόμησε"

```sql
ORDER BY hospitalizations DESC, total_cost DESC, patient
-- → πρώτα ταξινόμηση κατά νοσηλείες (φθίνουσα)
-- → αν ίδιες νοσηλείες, κατά κόστος (φθίνουσα)
-- → αν ίδιο κόστος, αλφαβητικά κατά όνομα (αύξουσα)
```

**FIELD() — custom ταξινόμηση:**
```sql
-- Q12: ταξινόμηση βαρδιών με συγκεκριμένη σειρά (πρωινή/απογευματινή/νυχτερινή)
ORDER BY FIELD(shift_type, 'morning', 'afternoon', 'night')
-- → morning=1, afternoon=2, night=3 (όχι αλφαβητική σειρά)
```

### 8.8 LIMIT — "Μόνο τα πρώτα Ν"

```sql
-- Q05: τους 20 νεότερους γιατρούς με τις περισσότερες χειρουργικές επεμβάσεις
ORDER BY surgeries_as_primary DESC
LIMIT 20

-- Q07: τις 100 πιο αλλεργιογόνες ουσίες
LIMIT 100

-- Q10: τα 3 πιο συχνά ζεύγη ουσιών
LIMIT 3
```

---

## ΜΕΡΟΣ 9 — CTE (WITH): Ενδιάμεσα "Υπο-ερωτήματα"

### 9.1 Τι είναι το CTE

CTE = Common Table Expression. Είναι σαν να δίνεις **όνομα** σε ένα υπο-ερώτημα και μετά το χρησιμοποιείς σαν κανονικό πίνακα.

**Χωρίς CTE (δύσκολο να διαβαστεί):**
```sql
SELECT *
FROM (SELECT patient_id, SUM(...) AS total FROM hospitalization GROUP BY patient_id) AS sub
WHERE sub.total > 1000;
```

**Με CTE (καθαρό):**
```sql
WITH patient_totals AS (
    SELECT patient_id, SUM(...) AS total
    FROM hospitalization
    GROUP BY patient_id
)
SELECT * FROM patient_totals WHERE total > 1000;
```

### 9.2 CTE για παράμετρο (params)

Μια έξυπνη χρήση: ορίζουμε παραμέτρους στο CTE για εύκολη αλλαγή:

```sql
-- Q04: αλλάζεις μόνο το '2' για να δεις άλλον γιατρό
WITH params AS (
    SELECT 2 AS selected_doctor_id
)
SELECT ... FROM doctor doc JOIN params ON doc.staff_id = params.selected_doctor_id ...

-- Q08: αλλάζεις ημερομηνία και τμήμα
WITH params AS (
    SELECT DATE('2026-04-06') AS selected_date,
           1 AS selected_department_id
)
```

### 9.3 Πολλαπλά CTEs

```sql
-- Q06: δύο CTEs
WITH params AS (
    SELECT 8 AS selected_patient_id    -- ορίζεις ποιον ασθενή θες
),
patient_eval AS (                       -- υπολογίζεις μέσο όρο αξιολόγησης
    SELECT h.patient_id, ROUND(AVG(ev.overall), 2) AS patient_avg_overall
    FROM hospitalization h
    JOIN evaluation ev ON ev.hospitalization_id = h.hospitalization_id
    GROUP BY h.patient_id
)
SELECT ...
FROM params
JOIN patient p ON p.patient_id = params.selected_patient_id
...
LEFT JOIN patient_eval pe ON pe.patient_id = p.patient_id
```

---

## ΜΕΡΟΣ 10 — UNION / UNION ALL: Ένωση Αποτελεσμάτων

### 10.1 Το πρόβλημα της ISA σε queries

Επειδή οι γιατροί, νοσηλευτές και διοικητικοί είναι σε **διαφορετικούς** πίνακες, για να τους δούμε **όλους μαζί** χρειαζόμαστε UNION:

```sql
-- Q08: βρες ΟΛΟ το προσωπικό ενός τμήματος (και γιατρούς, και νοσηλευτές, και διοικητικούς)
SELECT st.staff_id, 'doctor' AS staff_type, doc.specialty AS subclass, dd.department_id
FROM staff st JOIN doctor doc ON doc.staff_id = st.staff_id
JOIN doctor_department dd ON dd.staff_id = doc.staff_id

UNION ALL    -- ← ένωση με τους νοσηλευτές

SELECT st.staff_id, 'nurse' AS staff_type, n.rank AS subclass, n.department_id
FROM staff st JOIN nurse n ON n.staff_id = st.staff_id

UNION ALL    -- ← ένωση με τους διοικητικούς

SELECT st.staff_id, 'administrative' AS staff_type, a.role AS subclass, a.department_id
FROM staff st JOIN administrative a ON a.staff_id = st.staff_id
```

### 10.2 UNION vs UNION ALL

**UNION:** αφαιρεί duplicates (κάνει deduplication — αργό)
**UNION ALL:** κρατάει όλα (γρήγορο)

Εδώ χρησιμοποιούμε UNION ALL γιατί:
- Ένας υπάλληλος ανήκει σε **έναν μόνο** υποπίνακα (doctor Ή nurse Ή administrative)
- Άρα δεν μπορεί να υπάρχουν duplicates
- UNION ALL είναι πιο αποδοτικό

---

## ΜΕΡΟΣ 11 — Subqueries και NOT EXISTS

### 11.1 Subquery — Ερώτημα μέσα σε ερώτημα

```sql
-- Βρες ασθενείς που νοσηλεύτηκαν σε τμήμα με περισσότερα από 20 κρεβάτια:
SELECT * FROM patient
WHERE patient_id IN (
    SELECT patient_id FROM hospitalization
    WHERE department_id IN (
        SELECT department_id FROM department WHERE num_beds > 20
    )
);
```

### 11.2 NOT EXISTS — "Βρες αυτά που ΔΕΝ υπάρχουν"

```sql
-- Q08: βρες υπαλλήλους που ΔΕΝ έχουν βάρδια σε συγκεκριμένη ημέρα/τμήμα
WHERE NOT EXISTS (
    SELECT 1                              -- το "1" δεν σημαίνει τίποτα — θα μπορούσε να είναι και "*"
    FROM shift_assignment sa              -- απλώς ελέγχουμε αν ΥΠΑΡΧΕΙ γραμμή
    JOIN shift sh ON sh.shift_id = sa.shift_id
    WHERE sa.staff_id = es.staff_id
      AND sh.department_id = params.selected_department_id
      AND sh.shift_date = params.selected_date
)
```

Διαβάζεται: "επίστρεψε αυτόν τον υπάλληλο μόνο αν **δεν υπάρχει** κάποια βάρδια που να τον αφορά σε αυτή την ημέρα/τμήμα".

**NOT EXISTS vs LEFT JOIN IS NULL:**
```sql
-- Ισοδύναμο με NOT EXISTS:
LEFT JOIN shift_assignment sa ON sa.staff_id = es.staff_id AND ...
WHERE sa.staff_id IS NULL    -- αν το LEFT JOIN δεν βρήκε ταίριασμα → NULL

-- Ο optimizer τα μετατρέπει συχνά σε anti-join — ίδια απόδοση
-- NOT EXISTS: πιο ευανάγνωστο ("δεν υπάρχει βάρδια για αυτόν")
```

---

## ΜΕΡΟΣ 12 — Self-Join: Πίνακας που Συνδέεται με τον Εαυτό του

### 12.1 Πότε χρειάζεται

Όταν θέλεις να συγκρίνεις γραμμές **του ίδιου πίνακα** μεταξύ τους.

**Q09 — Ασθενείς με ίδιο αριθμό ημερών νοσηλείας:**

```sql
WITH patient_year_days AS (
    -- Για κάθε ασθενή/έτος: πόσες μέρες συνολικά νοσηλεύτηκε
    SELECT patient_id, YEAR(admission_date) AS yr, SUM(DATEDIFF(...)) AS total_days
    FROM hospitalization GROUP BY patient_id, yr
),
shared_lengths AS (
    -- Βρες ζεύγη (έτος, ημέρες) που εμφανίζονται σε >1 ασθενή
    SELECT yr, total_days, COUNT(*) AS patients_with_same_days
    FROM patient_year_days
    GROUP BY yr, total_days
    HAVING COUNT(*) > 1
)
-- Self-join: κάθε ασθενής "συναντάει" τις ομάδες με ίδιες ημέρες
SELECT pyd.* FROM patient_year_days pyd
JOIN shared_lengths sl ON sl.yr = pyd.yr AND sl.total_days = pyd.total_days
```

**Q14 — ICD10 κατηγορίες με ίδιο αριθμό εισαγωγών σε συνεχόμενα έτη:**

```sql
-- c1 και c2 είναι ΟΙ ΙΔΙΟΙ πίνακας category_year_counts — απλώς δύο "αντίγραφα"
JOIN category_year_counts c1
JOIN category_year_counts c2
  ON c2.icd_category = c1.icd_category        -- ίδια κατηγορία ασθένειας
 AND c2.admission_year = c1.admission_year + 1  -- το c2 είναι 1 χρόνο μετά το c1
 AND c2.admissions = c1.admissions             -- ίδιος αριθμός εισαγωγών
```

**Q10 — Ζεύγη ουσιών που συνταγογραφούνται μαζί:**

```sql
-- p1 και p2 είναι αντίγραφα του πίνακα prescription
JOIN prescription p2
  ON p2.hospitalization_id = p1.hospitalization_id  -- ίδια νοσηλεία
 AND p2.patient_id = p1.patient_id                  -- ίδιος ασθενής
 AND p2.prescription_id > p1.prescription_id        -- αποφεύγει A+B και B+A
 AND p1.start_date <= COALESCE(p2.end_date, p2.start_date)   -- overlap ημερομηνιών
 AND p2.start_date <= COALESCE(p1.end_date, p1.start_date)   -- overlap ημερομηνιών
```

**Γιατί `p2.prescription_id > p1.prescription_id`?**

Χωρίς αυτό, θα παίρναμε κάθε ζεύγος δύο φορές: (ουσία_Α, ουσία_Β) και (ουσία_Β, ουσία_Α). Με `p2.id > p1.id` εξασφαλίζουμε ότι κάθε ζεύγος εμφανίζεται **ακριβώς μια φορά**.

---

## ΜΕΡΟΣ 13 — WITH RECURSIVE: Αναδρομικά Ερωτήματα

### 13.1 Το πρόβλημα της ιεραρχίας

Στο Q13 θέλουμε να δούμε τη **ΣΥΝΟΛΙΚΗ αλυσίδα εποπτείας** κάθε γιατρού:
- Ο Ειδικευόμενος εποπτεύεται από Επιμελητή Β
- Ο Επιμελητής Β από Επιμελητή Α
- Ο Επιμελητής Α από Διευθυντή

Δεν ξέρουμε εκ των προτέρων πόσα επίπεδα υπάρχουν. Χρειαζόμαστε **αναδρομή**.

### 13.2 Δομή WITH RECURSIVE

```sql
WITH RECURSIVE supervision_chain AS (

    -- BASE CASE: Ξεκίνα από άμεσες σχέσεις εποπτείας
    SELECT doc.staff_id AS doctor_id,
           ...,
           1 AS supervision_level            -- πρώτο επίπεδο
    FROM doctor doc
    JOIN doctor sup ON sup.staff_id = doc.supervisor_id   -- βρες τον άμεσο επόπτη

    UNION ALL

    -- RECURSIVE CASE: Ανέβα ένα επίπεδο πιο πάνω
    SELECT sc.doctor_id,                      -- κρατάμε τον original γιατρό
           ...,
           sc.supervision_level + 1           -- αυξάνουμε το επίπεδο
    FROM supervision_chain sc                 -- χρησιμοποιούμε το αποτέλεσμα του προηγούμενου βήματος
    JOIN doctor sup ON sup.staff_id = sc.supervisor_staff_id
    JOIN doctor next_sup ON next_sup.staff_id = sup.supervisor_id   -- βρες τον επόπτη του επόπτη
)
SELECT * FROM supervision_chain ORDER BY doctor, supervision_level;
```

**Βήμα-βήμα για γιατρό Μαρία (Ειδικευόμενη):**

```
Βήμα 1 (base case):
  doctor_id=3 (Μαρία), supervisor=2 (Γιώργος), level=1

Βήμα 2 (recursive, level=2):
  doctor_id=3 (Μαρία), supervisor=1 (Δημήτρης), level=2

Βήμα 3 (recursive):
  sup.supervisor_id IS NULL → τερματισμός!
```

**Τερματισμός:** Η αναδρομή σταματά όταν `sup.supervisor_id IS NULL` — δηλαδή φτάσαμε στον Διευθυντή που δεν έχει επόπτη.

### 13.3 Γιατί χρειάζεται trigger κατά των κύκλων (trg_doctor_no_cycle)

Αν υπήρχε κύκλος (Α εποπτεύεται από Β, Β εποπτεύεται από Α), το recursive CTE **δεν θα τερμάτιζε ποτέ**. Για αυτό ο trigger `trg_doctor_no_cycle_insert/update` απαγορεύει κυκλικές αλυσίδες εποπτείας κατά την εισαγωγή/ενημέρωση.

---

## ΜΕΡΟΣ 14 — Triggers: Αυτόματος Κώδικας που Τρέχει η ΒΔ

### 14.1 Τι είναι trigger

Ένα **trigger** είναι κώδικας που η ΒΔ τρέχει **αυτόματα** ως αντίδραση σε ένα event (INSERT, UPDATE, DELETE) σε έναν πίνακα. Δεν τον καλεί η εφαρμογή — τρέχει από μόνος του.

Φαντάσου ότι τοποθετείς έναν φρουρό στην πόρτα. Κάθε φορά που κάποιος μπαίνει, ο φρουρός ελέγχει ταυτότητα. Δεν χρειάζεται να του πεις κάθε φορά — το κάνει αυτόματα.

### 14.2 BEFORE vs AFTER

```
Χρήστης ή εφαρμογή εκτελεί: INSERT INTO prescription VALUES (...)
                                    ↓
                         [BEFORE INSERT trigger]   ← μπορεί να αλλάξει NEW.* ή να ακυρώσει
                                    ↓
                    Εγγραφή γραμμής στη ΒΔ
                                    ↓
                         [AFTER INSERT trigger]    ← μπορεί να ενημερώσει ΑΛΛΟΥΣ πίνακες
```

**BEFORE:** Χρησιμοποιείται για:
- Validation (έλεγχος κανόνων) → αν αποτύχει, ρίχνει error με SIGNAL
- Υπολογισμός τιμής πριν γραφτεί (`SET NEW.total_cost = ...`)

**AFTER:** Χρησιμοποιείται για:
- Cascading updates σε ΑΛΛΟΥΣ πίνακες
- Δεν μπορεί να αλλάξει `NEW.*` (read-only)
- Δεν μπορεί να κάνει UPDATE στον ΙΔΙΟ πίνακα (infinite loop)

### 14.3 NEW και OLD

| Event | NEW | OLD |
|-------|-----|-----|
| INSERT | Η νέα γραμμή που θα γραφτεί | ΔΕΝ υπάρχει |
| UPDATE | Η γραμμή με τις νέες τιμές | Η γραμμή με τις παλιές τιμές |
| DELETE | ΔΕΝ υπάρχει | Η γραμμή που διαγράφηκε |

```sql
-- trg_hospitalization_cost: BEFORE UPDATE on hospitalization
-- Ελέγχουμε αν ΜΟΛΙΣ δόθηκε discharge_date (πριν δεν υπήρχε, τώρα υπάρχει)
IF OLD.discharge_date IS NULL AND NEW.discharge_date IS NOT NULL THEN
    -- OLD: η γραμμή πριν το UPDATE (χωρίς discharge_date)
    -- NEW: η γραμμή μετά το UPDATE (με discharge_date)
    SET NEW.total_cost = ...;   -- αλλάζουμε την τιμή ΠΡΙΝ γραφτεί
END IF;
```

### 14.4 SIGNAL — Ρίξε Error

```sql
SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'Ο Ειδικευόμενος πρέπει να έχει επόπτη';
```

Το `45000` είναι generic user-defined error. Ακυρώνει ολόκληρο το statement και επιστρέφει το μήνυμα στην εφαρμογή.

### 14.5 Όλα τα Triggers του project

**Γιατροί (4 triggers):**

```sql
-- trg_doctor_supervisor_insert / trg_doctor_supervisor_update
-- Κανόνας: Ειδικευόμενος ΠΡΕΠΕΙ να έχει supervisor
--           Διευθυντής ΔΕΝ ΜΠΟΡΕΙ να έχει supervisor
-- BEFORE INSERT/UPDATE ON doctor
-- Γιατί trigger και όχι CHECK:
--   Το CHECK δεν μπορεί να κάνει conditional "αν rank=X τότε supervisor=Y"
--   γιατί αφορά δύο στήλες με εξαρτημένη λογική

-- trg_doctor_no_cycle_insert / trg_doctor_no_cycle_update
-- Κανόνας: δεν επιτρέπεται κυκλική αλυσίδα εποπτείας
-- BEFORE INSERT/UPDATE ON doctor
-- Υλοποίηση: WHILE loop που ανεβαίνει την ιεραρχία ψάχνοντας για κύκλο
-- Γιατί trigger: απαιτεί traversal της ιεραρχίας — αδύνατο με CHECK ή FK
```

**Συνταγογράφηση (1 trigger):**

```sql
-- trg_prescription_allergy_check
-- Κανόνας: δεν επιτρέπεται συνταγογράφηση φαρμάκου αν ο ασθενής
--           είναι αλλεργικός σε κάποια δραστική ουσία του
-- BEFORE INSERT ON prescription
-- Λογική:
SELECT COUNT(*) INTO allergy_count
FROM drug_substance ds            -- ουσίες αυτού του φαρμάκου
JOIN patient_allergy pa ON ds.substance_id = pa.substance_id   -- αλλεργίες ασθενή
WHERE ds.drug_id = NEW.drug_id AND pa.patient_id = NEW.patient_id;
-- Γιατί trigger: ελέγχει 2 άλλους πίνακες (drug_substance, patient_allergy)
```

**Αξιολογήσεις (2 triggers):**

```sql
-- trg_evaluation_discharged
-- Κανόνας: αξιολόγηση νοσηλείας μόνο αν υπάρχει discharge_date
-- BEFORE INSERT ON evaluation

-- trg_doctor_evaluation_check
-- Κανόνας: (α) νοσηλεία ολοκληρωμένη + (β) ο γιατρός έχει συνταγογραφήσει
-- BEFORE INSERT ON doctor_evaluation
```

**Βάρδιες (5 triggers):**

```sql
-- trg_shift_monthly_limit
-- Κανόνας: γιατροί ≤15/μήνα, νοσηλευτές ≤20/μήνα, διοικητικοί ≤25/μήνα
-- BEFORE INSERT ON shift_assignment
-- Χρησιμοποιεί CASE για να επιλέξει το όριο ανά staff_type

-- trg_shift_rest_period
-- Κανόνας: τουλάχιστον 8 ώρες ανάπαυσης μεταξύ βαρδιών
-- Υπολογίζει ακριβείς ώρες έναρξης/λήξης για κάθε τύπο βάρδιας
-- Ελέγχει overlap: existing_end + 8h > new_start AND new_end + 8h > existing_start

-- trg_shift_consecutive_nights
-- Κανόνας: μέγιστο 3 συνεχόμενες νυχτερινές
-- Ελέγχει τις 3 προηγούμενες νύχτες

-- trg_shift_trainee_requires_senior
-- Κανόνας: αν μπει Ειδικευόμενος σε βάρδια, ΠΡΕΠΕΙ να υπάρχει ήδη
--           Επιμελητής Α ή Διευθυντής στην ίδια βάρδια
-- ΣΗΜΑΝΤΙΚΟ: ελέγχει αν υπάρχει senior ΠΡΙΝ μπει ο Ειδικευόμενος
--             → η σειρά εισαγωγής μετράει!

-- trg_shift_min_staffing
-- Κανόνας: ελάχιστη στελέχωση ≥3 ιατροί, ≥6 νοσηλευτές, ≥2 διοικητικοί
-- BEFORE DELETE ON shift_assignment
-- Δεν ελέγχεται στο INSERT γιατί η βάρδια χτίζεται σταδιακά (ένας-ένας).
-- Μόλις φτάσει σε έγκυρη στελέχωση, αφαίρεση που τη ρίχνει κάτω μπλοκάρεται.
```

**Επεμβάσεις (3 triggers):**

```sql
-- trg_procedure_room_overlap
-- Κανόνας: ο ίδιος χώρος δεν μπορεί να χρησιμοποιηθεί ταυτόχρονα
-- BEFORE INSERT ON medical_procedure
-- Overlap: A_start < B_end AND B_start < A_end

-- trg_procedure_doctor_overlap
-- Κανόνας: ο ίδιος γιατρός δεν μπορεί ταυτόχρονα σε 2 επεμβάσεις
--           (ούτε ως κύριος, ούτε ως βοηθός)

-- trg_procedure_assistant_overlap
-- Ίδιο για βοηθούς
-- BEFORE INSERT ON procedure_assistant
```

**Κλίνες & Κόστος (4 triggers):**

```sql
-- trg_hospitalization_bed_check   [BEFORE INSERT]
-- Ελέγχει αν η κλίνη είναι 'διαθέσιμη' πριν την εισαγωγή νοσηλείας

-- trg_hospitalization_bed_occupy  [AFTER INSERT]
-- Μετά την εισαγωγή νοσηλείας: κλίνη → 'κατειλημμένη'
-- AFTER (όχι BEFORE): ενημερώνουμε ΑΛΛΟ πίνακα (bed)
UPDATE bed SET status = 'κατειλημμένη' WHERE id = NEW.bed_id;

-- trg_hospitalization_bed_free    [AFTER UPDATE]
-- Μετά την έξοδο ασθενή (discharge_date ορίζεται): κλίνη → 'διαθέσιμη'

-- trg_hospitalization_cost        [BEFORE UPDATE]
-- Υπολογίζει total_cost βάσει ΚΕΝ κατά την έξοδο
-- BEFORE (όχι AFTER): γιατί αλλάζει NEW.total_cost
-- ΦΟΡΜΟΥΛΑ ΚΕΝ:
--   αν actual_days ≤ alos_days → total_cost = base_cost
--   αν actual_days > alos_days → total_cost = base_cost + (extra_days × base_cost/alos_days)
```

### 14.6 Trigger vs CHECK vs FK vs Application Layer

| Πότε χρησιμοποιώ | Τι κάνω |
|------------------|---------|
| **CHECK** | Απλός έλεγχος μιας/δύο τιμών **ίδιας γραμμής** |
| **UNIQUE** | Εξασφάλιση μοναδικότητας |
| **FK** | Referential integrity (η τιμή υπάρχει σε άλλο πίνακα) |
| **TRIGGER** | Έλεγχος που αφορά ΑΛΛΟΥΣ πίνακες, ή υπολογισμός τιμής, ή conditional logic |
| **BEFORE DELETE trigger** | Κανόνας που επιβάλλεται με αφαίρεση: μόλις η βάρδια φτάσει έγκυρη στελέχωση, η υποβάθμισή της μπλοκάρεται |

**Minimum staffing (≥3 γιατροί, ≥6 νοσηλευτές, ≥2 διοικητικοί ανά βάρδια)** υλοποιείται με **BEFORE DELETE trigger** (`trg_shift_min_staffing`). Δεν μπορεί να ελεγχθεί στο INSERT γιατί η βάρδια χτίζεται σταδιακά — ο 1ος υπάλληλος που μπαίνει θα "αποτύγχανε" πάντα. Αντ' αυτού: μόλις η βάρδια αποκτήσει έγκυρη στελέχωση, κάθε DELETE που θα τη ρίξει κάτω από τα ελάχιστα μπλοκάρεται αυτόματα.

---

## ΜΕΡΟΣ 15 — Indexes: Το "Ευρετήριο" της ΒΔ

### 15.1 Τι είναι index και γιατί χρειάζεται

Φαντάσου ένα βιβλίο 500 σελίδων. Χωρίς ευρετήριο, για να βρεις "Αλλεργία" διαβάζεις όλο το βιβλίο. Με ευρετήριο, πας κατευθείαν στη σελίδα 127.

Αντίστοιχα, χωρίς index η ΒΔ διαβάζει κάθε γραμμή ενός πίνακα (**full table scan**). Με index ακολουθεί ένα δέντρο (B-tree) και βρίσκει τις γραμμές σε **O(log n)** αντί O(n).

```
Πίνακας hospitalization (500 γραμμές):
Χωρίς index: διαβάζει 500 γραμμές → O(n)

Με index idx_hospitalization_patient ON (patient_id):
B-tree δέντρο:
           [250]
          /     \
      [125]     [375]
      / \        / \
    ...  ...   ...  ...
      ↓
   Βρίσκει γραμμές με patient_id=8 → O(log n)
```

### 15.2 PRIMARY KEY είναι Clustered Index

Στο InnoDB (MariaDB), τα δεδομένα αποθηκεύονται **φυσικά ταξινομημένα κατά PRIMARY KEY**. Αυτό λέγεται clustered index.

Πρακτική συνέπεια: `WHERE hospitalization_id BETWEEN 100 AND 200` είναι πολύ γρήγορο γιατί αυτές οι γραμμές είναι φυσικά κοντά στο δίσκο.

Κάθε secondary index αποθηκεύει την τιμή PK — άρα lookup μέσω secondary index κάνει 2 βήματα: 1) βρες PK από index, 2) βρες γραμμή από clustered index.

### 15.3 Composite Index — Δύο στήλες μαζί

```sql
CREATE INDEX idx_shift_dept_date ON shift(department_id, shift_date);
```

Αυτός ο index είναι ταξινομημένος: **πρώτα κατά department_id, μετά κατά shift_date** εντός κάθε τμήματος.

**Leftmost Prefix Rule:** Ο optimizer μπορεί να χρησιμοποιήσει αυτόν τον index για:
- `WHERE department_id = 3` ✓
- `WHERE department_id = 3 AND shift_date = '2026-04-06'` ✓
- `WHERE shift_date = '2026-04-06'` ✗ (δεν ξεκινά από την 1η στήλη)

**Γιατί department_id πρώτα (και όχι shift_date):**
- Ο φιλτράρει πιο πολύ (15 τμήματα vs πολλές ημερομηνίες)
- Τα Q08/Q12 φιλτράρουν ΠΑΝΤΑ ανά department_id

### 15.4 Πότε ο Optimizer ΧΡΗΣΙΜΟΠΟΙΕΙ index

1. **Equality:** `WHERE patient_id = 8` → χρησιμοποιεί index on patient_id
2. **Range:** `WHERE age < 35` → χρησιμοποιεί index on age
3. **JOIN:** `JOIN department ON d.department_id = h.department_id` → index on department_id
4. **ORDER BY / GROUP BY:** αν ταιριάζει με index, αποφεύγει filesort

### 15.5 Πότε ο Optimizer ΑΓΝΟΕΙ index

1. **Function πάνω σε indexed column:**
```sql
WHERE YEAR(admission_date) = 2025    -- ΔΕΝ χρησιμοποιεί index on admission_date
-- Η ΒΔ δεν ξέρει ποιες τιμές admission_date έχουν YEAR()=2025 χωρίς να τις ελέγξει

-- Αντίθετα, αυτό ΧΡΗΣΙΜΟΠΟΙΕΙ index:
WHERE admission_date >= '2025-01-01' AND admission_date < '2026-01-01'
```

Στο project χρησιμοποιούμε `YEAR()` για readability — αποδεκτό trade-off σε μικρά datasets.

2. **Low cardinality:** μόνο 3 τιμές (doctor/nurse/administrative) → συχνά full scan πιο γρήγορο
3. **Πολύ μικρός πίνακας:** `procedure_room` με 10 γραμμές → full scan πιο γρήγορο

### 15.6 EXPLAIN — Πώς "βλέπεις" τι κάνει ο optimizer

```sql
EXPLAIN SELECT ... FROM doctor_evaluation de WHERE de.doctor_id = 2;
```

```
| table | type  | key                        | rows | Extra      |
|-------|-------|----------------------------|------|------------|
| de    | ref   | idx_doctor_evaluation_doctor| 2    | Using where|
```

**Σημαντικά πεδία:**
- `type`: 
  - `ALL` = full table scan (κακό για μεγάλους πίνακες)
  - `ref` = index lookup (καλό)
  - `const` = βρήκε ακριβώς 1 γραμμή (άριστο)
  - `range` = range scan (καλό)
- `rows`: εκτίμηση πόσες γραμμές θα εξεταστούν
- `Extra`:
  - `Using index` = covering index (δεν χρειάστηκε να πάει στον πίνακα)
  - `Using filesort` = sorting εκτός index

**EXPLAIN comparison από το report (Q04):**

```
ΜΕ idx_doctor_evaluation_doctor:
  type=ref, rows=2    ← βρίσκει μόνο 2 γραμμές

ΜΕ FORCE INDEX (PRIMARY):
  type=index, rows=150  ← σκανάρει όλον τον πίνακα
```

Γιατί PRIMARY KEY (eval_id) δεν βοηθά: η αναζήτηση γίνεται **βάσει doctor_id**, όχι βάσει eval_id. Ο PRIMARY KEY ταξινομεί ανά eval_id — δεν βοηθά να βρούμε γρήγορα τιμές doctor_id.

### 15.7 Covering Index

Αν ο index περιέχει **όλες** τις στήλες που χρειάζεται το query, ο optimizer δεν χρειάζεται καν να πάει στον πίνακα — διαβάζει μόνο τον index.

```sql
-- idx_doctor_evaluation_doctor ON (doctor_id)
-- Το Q04 χρειάζεται: eval_id, hospitalization_id, doctor_id, medical_care
-- Άρα ΔΕΝ είναι covering — πρέπει να πάει στον πίνακα
-- Φαίνεται ως "Using index condition" ή απλώς "Using where"
```

---

## ΜΕΡΟΣ 16 — Ανάλυση Queries (Q01-Q15)

### Q01 — Έσοδα ανά Τμήμα/Έτος/ΚΕΝ/Ασφαλιστικό

**Τι ρωτάει:** Για κάθε συνδυασμό (τμήμα, έτος, ΚΕΝ κατηγορία, ασφαλιστικός φορέας): πόσες νοσηλείες έγιναν, πόσο έσοδο από βασικό ΚΕΝ, πόσο από επιπλέον μέρες, πόσο συνολικά;

**Βασικές τεχνικές:**

```sql
GROUP BY d.department_id, YEAR(h.admission_date), h.ken_code, p.insurance_provider
```

Κάθε ομάδα = μία γραμμή αποτελέσματος.

```sql
-- extra_alos_revenue: μόνο αν ο ασθενής ξεπέρασε τη μέση νοσηλεία ΚΕΝ
ROUND(SUM(
    CASE
        WHEN h.discharge_date IS NOT NULL
         AND DATEDIFF(h.discharge_date, h.admission_date) > k.alos_days
        THEN GREATEST(COALESCE(h.total_cost, k.base_cost) - k.base_cost, 0)
        ELSE 0
    END
), 2) AS extra_alos_revenue
```

- `DATEDIFF(discharge, admission)`: μέρες νοσηλείας
- `> k.alos_days`: ξεπέρασε τη μέση τυπική διάρκεια
- `COALESCE(h.total_cost, k.base_cost)`: αν δεν έχει υπολογιστεί total_cost, χρησιμοποίησε base_cost
- `GREATEST(..., 0)`: ποτέ αρνητικό έσοδο

**Γιατί LEFT JOIN με ken;** Κάποιες νοσηλείες δεν έχουν ken_code (NULL). Με INNER JOIN θα εξαφανίζονταν από τα αποτελέσματα — δεν θέλουμε αυτό.

**Indexes:** `idx_hospitalization_department`, `idx_hospitalization_patient`, `idx_hospitalization_ken`

---

### Q02 — Γιατροί ανά Ειδικότητα με Εφημερίες και Επεμβάσεις

**Τι ρωτάει:** Για μια επιλεγμένη ειδικότητα: κάθε γιατρός, πόσες βάρδιες φέτος, πόσες επεμβάσεις φέτος;

**Κρίσιμη λεπτομέρεια — YEAR filter στο JOIN:**

```sql
LEFT JOIN shift sh
  ON sh.shift_id = sa.shift_id
 AND YEAR(sh.shift_date) = YEAR(CURDATE())   -- ← στο JOIN, ΟΧΙ στο WHERE
```

Αν το `YEAR()` filter ήταν στο WHERE:
```sql
WHERE YEAR(sh.shift_date) = YEAR(CURDATE())
-- Αυτό μετατρέπει τον LEFT JOIN σε INNER JOIN!
-- Γιατροί χωρίς βάρδιες φέτος → εξαφανίζονται!
```

Στο JOIN condition: γιατροί χωρίς βάρδιες φέτος εμφανίζονται με `shift_id = NULL` (LEFT JOIN διατηρεί τη γραμμή).

**Indexes:** `idx_doctor_specialty`, `idx_shift_assignment_staff`, `idx_procedure_surgeon`, `idx_procedure_start_time`

---

### Q03 — Ασθενείς με >3 Νοσηλείες στο Ίδιο Τμήμα

**Τι ρωτάει:** Ποιοι ασθενείς έχουν νοσηλευτεί πάνω από 3 φορές στο ίδιο τμήμα;

```sql
GROUP BY p.patient_id, d.department_id
HAVING COUNT(*) > 3
```

**HAVING vs WHERE:**
- `WHERE COUNT(*) > 3` → ERROR (δεν υπάρχει ακόμα το COUNT πριν το GROUP BY)
- `HAVING COUNT(*) > 3` → σωστό (φιλτράρει ΜΕΤΑ την ομαδοποίηση)

**Indexes:** `idx_hospitalization_patient`, `idx_hospitalization_department`

---

### Q04 — Μέσος Βαθμός Αξιολόγησης Συγκεκριμένου Γιατρού

**Τι ρωτάει:** Για έναν συγκεκριμένο γιατρό (επιλέγεις το ID): μέσος βαθμός ιατρικής φροντίδας, μέσος βαθμός συνολικής νοσηλείας.

```sql
WITH params AS (SELECT 2 AS selected_doctor_id)
...
AVG(de.medical_care) AS avg_medical_care,     -- βαθμός γιατρού (doctor_evaluation)
AVG(ev.overall) AS avg_overall_hospitalization -- βαθμός νοσηλείας (evaluation)
```

**EXPLAIN comparison:**
- `idx_doctor_evaluation_doctor`: rows=2, type=ref ← πολύ καλό
- `FORCE INDEX (PRIMARY)`: rows=150, type=index ← πολύ χειρότερο

Ο PRIMARY KEY (eval_id) δεν βοηθά γιατί ψάχνουμε βάσει doctor_id, όχι eval_id.

---

### Q05 — Νέοι Γιατροί (<35) με Περισσότερες Χειρουργικές Επεμβάσεις

**Τι ρωτάει:** Γιατροί κάτω των 35 με τις περισσότερες χειρουργικές επεμβάσεις (top 20).

```sql
WHERE st.age < 35          -- range query → index on age
JOIN procedure_catalog pc
  ON pc.procedure_code = mp.procedure_code
 AND pc.category = 'χειρουργική'   -- filter ΣΤΟ JOIN, όχι στο WHERE
                                    -- (δεν αλλάζει semantics εδώ — INNER JOIN)
```

**Indexes:** `idx_staff_age`, `idx_procedure_surgeon`, `idx_doctor_specialty`

---

### Q06 — Ιστορικό Νοσηλειών Ασθενή

**Τι ρωτάει:** Για έναν ασθενή: όλες οι νοσηλείες με κόστος, διάγνωση ICD10, και μέσος βαθμός αξιολόγησης.

**EXPLAIN comparison (Q06):**
- `idx_hospitalization_patient`: rows=6, type=ref ← ο optimizer επιλέγει σωστά
- `FORCE INDEX (idx_hospitalization_icd)`: rows=500, type=index ← πολύ χειρότερο

Ο `idx_hospitalization_icd` αποθηκεύει το πεδίο icd10_code. Δεν βοηθά να βρούμε γρήγορα νοσηλείες βάσει patient_id.

---

### Q07 — Αλλεργίες και Φάρμακα ανά Δραστική Ουσία

**Τι ρωτάει:** Για κάθε δραστική ουσία: πόσοι ασθενείς είναι αλλεργικοί, πόσα φάρμακα την περιέχουν.

```sql
COUNT(DISTINCT pa.patient_id) AS allergic_patients
COUNT(DISTINCT ds.drug_id)    AS drugs_containing_substance
```

**Γιατί DISTINCT;** Αν κάνουμε LEFT JOIN patient_allergy και LEFT JOIN drug_substance, ένας ασθενής που είναι αλλεργικός σε μια ουσία AND αυτή η ουσία βρίσκεται σε 5 φάρμακα → 5 γραμμές για τον ίδιο ασθενή. COUNT(*) = 5 (λάθος). COUNT(DISTINCT patient_id) = 1 (σωστό).

---

### Q08 — Προσωπικό Χωρίς Εφημερία σε Συγκεκριμένη Ημέρα/Τμήμα

**Τι ρωτάει:** Ποιο προσωπικό ενός τμήματος ΔΕΝ έχει βάρδια σε συγκεκριμένη ημέρα;

**UNION ALL για τους 3 τύπους:** Γιατροί (με doctor_department), νοσηλευτές, διοικητικοί — ξεχωριστά subqueries, ενωμένα με UNION ALL.

**NOT EXISTS για τον αποκλεισμό:**
```sql
WHERE NOT EXISTS (
    SELECT 1 FROM shift_assignment sa JOIN shift sh ...
    WHERE sa.staff_id = es.staff_id
      AND sh.shift_date = params.selected_date
      AND sh.department_id = params.selected_department_id
)
```

---

### Q09 — Ασθενείς με Ίδιο Αριθμό Ημερών Νοσηλείας ανά Έτος

**Τι ρωτάει:** Ποιοι ασθενείς νοσηλεύτηκαν τον ίδιο συνολικό αριθμό ημερών (>15) μέσα στο ίδιο ημερολογιακό έτος;

**COALESCE για ενεργές νοσηλείες:**
```sql
DATEDIFF(COALESCE(h.discharge_date, CURDATE()), h.admission_date)
-- Ασθενής ακόμα νοσηλευόμενος: χρησιμοποίησε σημερινή ημέρα ως "discharge"
```

---

### Q10 — Top-3 Ζεύγη Δραστικών Ουσιών που Συνταγογραφούνται Μαζί

**Τι ρωτάει:** Ποια 3 ζεύγη ουσιών εμφανίζονται συχνότερα ταυτόχρονα στην ίδια νοσηλεία;

Αυτό είναι το πιο πολύπλοκο query. Βήματα:
1. Self-join `prescription p1 JOIN prescription p2` (ίδια νοσηλεία, διαφορετικά φάρμακα, overlapping ημερομηνίες)
2. JOIN με `drug_substance ds1, ds2` (ποιες ουσίες έχει κάθε φάρμακο)
3. JOIN με `active_substance s1, s2` (τα ονόματα των ουσιών)
4. `p2.prescription_id > p1.prescription_id`: αποφεύγει διπλό counting
5. `ds2.substance_id > ds1.substance_id`: αποφεύγει διπλό counting για ζεύγη ουσιών

---

### Q11 — Γιατροί ≥5 Επεμβάσεις Πίσω από τον Top

**Τι ρωτάει:** Ποιοι γιατροί έχουν τουλάχιστον 5 επεμβάσεις λιγότερες από τον γιατρό με τις περισσότερες;

```sql
WITH procedure_counts AS (
    -- Κάθε γιατρός + αριθμός επεμβάσεων φέτος
),
top_count AS (
    -- Ο μέγιστος αριθμός επεμβάσεων (1 γραμμή)
    SELECT MAX(current_year_procedures) AS top_current_year_procedures
    FROM procedure_counts
)
SELECT ...
FROM procedure_counts pc
CROSS JOIN top_count tc        -- κάθε γιατρός "βλέπει" το top
WHERE tc.top - pc.current >= 5  -- είναι ≥5 πίσω
```

CROSS JOIN λειτουργεί τέλεια εδώ γιατί `top_count` έχει ακριβώς 1 γραμμή.

---

### Q12 — Στελέχωση ανά Τμήμα/Βάρδια/Εβδομάδα

**Τι ρωτάει:** Για μια εβδομάδα: κάθε βάρδια κάθε τμήματος, πόσο προσωπικό κάθε κατηγορίας, και ποιο το ελάχιστο απαιτούμενο;

```sql
CASE assigned_staff.staff_type
    WHEN 'doctor' THEN 3        -- minimum 3 γιατροί
    WHEN 'nurse' THEN 6         -- minimum 6 νοσηλευτές
    WHEN 'administrative' THEN 2 -- minimum 2 διοικητικοί
END AS minimum_required_for_class
```

**FIELD() για custom ταξινόμηση:**
```sql
ORDER BY FIELD(shift_type, 'morning', 'afternoon', 'night')
-- morning → 1, afternoon → 2, night → 3
-- Χωρίς FIELD, θα ήταν αλφαβητική: afternoon(1), morning(2), night(3)
```

---

### Q13 — Αναδρομική Ιεραρχία Εποπτείας

**Τι ρωτάει:** Για κάθε γιατρό, ποιοι είναι ΟΛΟΙ οι επόπτες του (άμεσος, έμμεσος, κλπ.) σε ποιο επίπεδο;

Χρησιμοποιεί `WITH RECURSIVE` (βλέπε ΜΕΡΟΣ 13).

**Indexes:** `idx_doctor_supervisor` — κρίσιμος για το JOIN `ON next_sup.staff_id = sup.supervisor_id` στο recursive case.

---

### Q14 — ICD-10 Κατηγορίες με Ίδιο Αριθμό Εισαγωγών σε Συνεχόμενα Έτη

**Τι ρωτάει:** Ποιες κατηγορίες ασθένειας είχαν τον ίδιο αριθμό εισαγωγών σε δύο διαδοχικά χρόνια;

```sql
-- Self-join του CTE
JOIN category_year_counts c2
  ON c2.icd_category = c1.icd_category
 AND c2.admission_year = c1.admission_year + 1   -- συνεχόμενα έτη
 AND c2.admissions = c1.admissions               -- ίδιος αριθμός
WHERE c1.admissions >= 5                          -- τουλάχιστον 5 εισαγωγές
```

---

### Q15 — Κατανομή Triage ανά Επίπεδο Επείγοντος

**Τι ρωτάει:** Για κάθε συνδυασμό (επίπεδο επείγοντος, τμήμα που νοσηλεύτηκε): πόσα περιστατικά, μέση αναμονή, % νοσηλείας;

```sql
ROUND(AVG(TIMESTAMPDIFF(MINUTE, tr.arrival_time, tr.outcome_time)), 2) AS avg_wait_minutes
-- TIMESTAMPDIFF: διαφορά σε λεπτά μεταξύ άφιξης και αποτελέσματος

ROUND(100 * SUM(CASE WHEN tr.hospitalization_id IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2)
-- % ασθενών που νοσηλεύτηκαν (αντί να φύγουν)
```

```sql
COALESCE(d.name, 'No hospitalization')
-- Ασθενείς που έφυγαν σπίτι (όχι νοσηλεία): NULL department → 'No hospitalization'
```

---

## ΜΕΡΟΣ 17 — Normalization: Γιατί οι Πίνακες Είναι Οργανωμένοι Έτσι

### 17.1 Τι είναι Normalization

Normalization = διαδικασία οργάνωσης δεδομένων ώστε να αποφύγουμε:
- **Redundancy:** ίδια πληροφορία αποθηκευμένη πολλές φορές
- **Anomalies:** προβλήματα κατά INSERT/UPDATE/DELETE

### 17.2 1NF — Πρώτη Κανονική Μορφή

Κάθε κελί έχει **ατομική** (μη διαιρέσιμη) τιμή. Χωρίς επαναλαμβανόμενες ομάδες.

**Παράβαση 1NF (ΔΕΝ το κάνουμε):**
```sql
-- ΛΑΘΟΣ: πολλές ουσίες σε ένα κελί
drug(drug_id, drug_name, substances = 'ουσία1,ουσία2,ουσία3')
```

**Σωστό (1NF):**
```sql
-- Κάθε σχέση drug-substance ξεχωριστά
drug_substance(drug_id, substance_id)
```

### 17.3 2NF — Δεύτερη Κανονική Μορφή

Κάθε μη-κλειδί attribute εξαρτάται από το **ΟΛΟΚΛΗΡΟ** primary key (όχι από μέρος του).

Αφορά πίνακες με composite PK.

**Παράβαση 2NF (ΔΕΝ το κάνουμε):**
```sql
-- Αν είχαμε στον shift_assignment:
shift_assignment(shift_id, staff_id, department_name)
-- department_name εξαρτάται μόνο από shift_id, ΟΧΙ από (shift_id, staff_id)
-- Λύση: department_name ανήκει στον πίνακα shift
```

### 17.4 3NF — Τρίτη Κανονική Μορφή

Κάθε μη-κλειδί attribute εξαρτάται **μόνο** από το primary key — όχι από άλλο μη-κλειδί attribute (transitive dependency).

**Παράβαση 3NF:**
```sql
-- Αν στο hospitalization είχαμε:
(hospitalization_id, patient_id, patient_name, ...)
-- patient_name εξαρτάται από patient_id, ΟΧΙ από hospitalization_id
-- Λύση: patient_name ανήκει στον πίνακα patient
```

Ακριβώς αυτό κάνουμε: στοιχεία ασθενή → πίνακας patient. Στοιχεία κλίνης → πίνακας bed. Κ.ο.κ.

---

## ΜΕΡΟΣ 18 — Transactions και ACID

### 18.1 Τι είναι Transaction

Μια **transaction** είναι ένα σύνολο operations που εκτελούνται **ως ένα**: είτε τρέχουν όλα, είτε κανένα.

**Παράδειγμα:** Εισαγωγή νοσηλείας:
1. INSERT INTO hospitalization → δημιουργία εγγραφής
2. UPDATE bed SET status = 'κατειλημμένη' → ο trigger το κάνει αυτόματα

Αν αποτύχει το βήμα 2 (π.χ. crash), η νοσηλεία δεν πρέπει να υπάρχει. Transaction εξασφαλίζει ότι και τα δύο ή κανένα.

### 18.2 ACID Properties

| Ιδιότητα | Τι σημαίνει | Παράδειγμα |
|----------|-------------|------------|
| **Atomicity** | Όλα ή τίποτα | INSERT hospitalization + UPDATE bed — μαζί |
| **Consistency** | Η ΒΔ παραμένει σε έγκυρη κατάσταση | CHECK constraints, FK, triggers |
| **Isolation** | Παράλληλες transactions δεν παρεμβαίνουν | Δύο νοσηλείες δεν μπορούν να πάρουν ίδια κλίνη |
| **Durability** | Μετά το commit, τα δεδομένα παραμένουν | Δεν χάνεται ακόμα και σε crash |

---

## ΜΕΡΟΣ 19 — Σχεδιαστικές Αποφάσεις του Project

### 19.1 Γιατί total_cost αποθηκεύεται (και δεν υπολογίζεται on-the-fly)

Μπορούσαμε να υπολογίζουμε το κόστος κάθε φορά που το ζητάμε:
```sql
-- On-the-fly υπολογισμός
SELECT base_cost + (actual_days - alos_days) * (base_cost / alos_days) AS cost ...
```

Αλλά:
1. **Παγώνει τη στιγμή της εξόδου:** Αν αλλάξει το KEN αργότερα, το ιστορικό κόστος παραμένει σωστό
2. **Απλοποιεί queries:** Q01, Q03, Q06 χρησιμοποιούν `h.total_cost` — αν έπρεπε να υπολογίζουν κάθε φορά, θα ήταν πολύπλοκα

### 19.2 Γιατί photo_url αποθηκεύεται ως TEXT και όχι BLOB

Δεν αποθηκεύουμε τις εικόνες στη ΒΔ — μόνο το URL (path ή web link). TEXT αρκεί για URLs. BLOB θα χρησιμοποιούσαμε αν αποθηκεύαμε τα binary δεδομένα της εικόνας — κάτι που αποφεύγεται για performance λόγους.

### 19.3 Γιατί το evaluation έχει UNIQUE(hospitalization_id)

Ο ασθενής αξιολογεί τη νοσηλεία **μία φορά**. Το UNIQUE constraint εξασφαλίζει αυτόν τον κανόνα σε επίπεδο ΒΔ — δεν αρκεί η εφαρμογή.

### 19.4 Γιατί patient_allergy αναφέρεται σε active_substance και όχι σε drug

Η αλλεργία είναι σε **δραστική ουσία**, όχι σε εμπορικό φάρμακο. Αν είσαι αλλεργικός στην αμοξικιλλίνη, δεν μπορείς να πάρεις **κανένα** φάρμακο που την περιέχει — ανεξάρτητα από εμπορική ονομασία. Αυτό επιτρέπει στον trigger `trg_prescription_allergy_check` να ελέγχει σωστά.

### 19.5 Γιατί doctor δεν έχει department_id (αλλά nurse και administrative έχουν)

Ένας γιατρός μπορεί να ανήκει σε **πολλά** τμήματα (π.χ. καρδιολόγος που εφημερεύει και στην Καρδιολογία και στα Επείγοντα). Άρα χρειάζεται M:N → junction table `doctor_department`.

Νοσηλευτές και διοικητικοί ανήκουν σε **ένα** τμήμα → απλό FK αρκεί.

---

## ΜΕΡΟΣ 20 — Σύνοψη: Τι έμαθες

### Βασικές Έννοιες
- **Πίνακας:** δεδομένα οργανωμένα σε στήλες και γραμμές
- **Primary Key:** μοναδική αναγνώριση κάθε γραμμής
- **Foreign Key:** σύνδεση μεταξύ πινάκων
- **NULL:** απουσία τιμής (όχι μηδέν)
- **Constraints:** κανόνες που η ΒΔ φυλάει αυτόματα

### Σχέσεις
- **1:N:** ένας ασθενής → πολλές νοσηλείες
- **M:N:** ένας γιατρός ↔ πολλά τμήματα (μέσω junction table)
- **Self-referencing:** γιατρός → επόπτης (και αυτός γιατρός)
- **ISA:** γιατρός IS-A υπάλληλος

### SQL
- **SELECT/FROM/WHERE:** βασική ερώτηση
- **JOIN/LEFT JOIN:** συνδύαζε πίνακες
- **GROUP BY + Aggregates:** ομαδοποίηση και υπολογισμοί
- **HAVING:** φίλτρο μετά GROUP BY
- **CTE (WITH):** ονόμασε υποερωτήματα
- **WITH RECURSIVE:** αναδρομικά δέντρα/ιεραρχίες
- **UNION ALL:** ένωση αποτελεσμάτων
- **NOT EXISTS:** "βρες αυτά που δεν υπάρχουν"

### Triggers
- **BEFORE:** validation και υπολογισμός τιμής πριν γραφτεί
- **AFTER:** cascading updates σε άλλους πίνακες
- **SIGNAL:** ρίξε error για να ακυρωθεί η εγγραφή

### Indexes
- **B-tree:** δομή O(log n) για γρήγορες αναζητήσεις
- **Composite:** (A,B) leftmost prefix rule
- **EXPLAIN:** δες τι επιλέγει ο optimizer
- **Πότε ΔΕΝ βοηθά:** function on column, low cardinality, μικρός πίνακας

---

*Τελευταία ενημέρωση: 2026-05-12*
*Project: Νοσοκομείο Υγειόπολης — Βάσεις Δεδομένων ΣΗΜΜΥ 2025-2026*
