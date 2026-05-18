# hospital-db-26

Σχεδιασμός και υλοποίηση βάσης δεδομένων για το Γενικό Νοσοκομείο «Υγειόπολης» — εργασία για το μάθημα Βάσεις Δεδομένων, ΣΗΜΜΥ/ΕΜΠ 2025-2026.

---

## ER Diagram

![ER Diagram](diagrams/er-diagram-hospital-latest-2.drawio.png)

Διαθέσιμο και σε PDF: [diagrams/er.pdf](diagrams/er.pdf)

---

## Relational Schema

[diagrams/relational.pdf](diagrams/relational.pdf)

---

## Πώς να τρέξεις το project

### Προαπαιτούμενα

- [Docker](https://www.docker.com/) και Docker Compose

### 1. Πρώτη εκκίνηση

```bash
cd code
docker compose up --build
```

Η εκκίνηση δημιουργεί αυτόματα το schema (`install.sql`) και φορτώνει τα δεδομένα (`load.sql`). Διαρκεί μερικά λεπτά.

### 2. Κανονική επανεκκίνηση

```bash
docker compose up
```

### 3. Διακοπή

```bash
docker compose down
```

### 4. Πλήρης επαναφορά (rebuild)

```bash
docker compose down
docker compose up --build
```

### 5. Query UI

Μετά την εκκίνηση, άνοιξε στον browser:

```
http://127.0.0.1:8765
```

Περιλαμβάνει SQL editor, schema browser και 15 αποθηκευμένα ερωτήματα ανάλυσης.

### 6. Σύνδεση με MySQL client

```
Host:     127.0.0.1
Port:     3307
User:     root
Password: root
Database: hospital
```

```bash
docker exec -it hospital_db mariadb -uroot -proot hospital
```

### 7. Επαλήθευση φόρτωσης

```bash
./verify_db.sh
```

---

## Παραδοχές

| # | Περιορισμός | Παραδοχή |
| - | --- | --- |
| 1 | Ελάχιστη στελέχωση βάρδιας (≥3 ιατροί, ≥6 νοσηλευτές, ≥2 διοικητικοί) | Επιβάλλεται μέσω BEFORE DELETE trigger (`trg_shift_min_staffing`) στον πίνακα `shift_assignment`. Καθώς η βάρδια στελεχώνεται σταδιακά (ένα INSERT ανά μέλος), ο έλεγχος στο INSERT είναι αδύνατος. Αντ' αυτού, μόλις η βάρδια φτάσει σε έγκυρη στελέχωση, η αφαίρεση προσωπικού που θα τη ρίξει κάτω από τα ελάχιστα μπλοκάρεται αυτόματα. Ο χειριστής οφείλει να διασφαλίσει ότι η βάρδια φτάνει την ελάχιστη στελέχωση πριν τεθεί σε ισχύ. |
| 2 | FIFO triage | Δεν απαιτεί constraint στη βάση. Η βάση αποθηκεύει `urgency_level` και `arrival_time`. Η σωστή σειρά εξυπηρέτησης εξασφαλίζεται με `ORDER BY urgency_level ASC, arrival_time ASC`. |
| 3 | Φάρμακα EMA Article 57 | Αφαιρέθηκαν φάρμακα με ελλιπή ή λανθασμένα substance names (fragments λόγω κακής ποιότητας δεδομένων στην πηγή). Αν ένα φάρμακο είχε έστω μία περίεργη ουσία, αφαιρέθηκε ολόκληρο ώστε κάθε φάρμακο να έχει πλήρη λίστα δραστικών ουσιών. Η εκφώνηση επιτρέπει ρητά απλοποίηση των δραστικών ουσιών. |
| 4 | `drug.description` | Χρησιμοποιείται για route of administration (π.χ. "Oral Use") όπως παρέχεται από το Excel της EMA, όχι για κειμενική περιγραφή του φαρμάκου. |
| 5 | `drug.ema_code` | Το πεδίο υπάρχει στο schema αλλά δεν φορτώνεται γιατί το Excel της EMA δεν παρέχει μοναδικό κωδικό ανά προϊόν. |
