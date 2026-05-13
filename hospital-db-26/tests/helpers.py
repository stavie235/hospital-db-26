"""
Shared helper functions for building minimal test fixtures.

All insert helpers return the auto-increment id of the inserted row.
They do NOT commit — the `cur` fixture rolls back after each test.
"""

from __future__ import annotations
import uuid


def _uid() -> str:
    """11-digit unique string safe for AMKA/CHAR(11) columns."""
    return str(abs(hash(uuid.uuid4())) % 10**11).zfill(11)


# ── Staff / Doctor / Nurse / Administrative ───────────────────────────────────

def insert_staff(cur, *, staff_type: str = "doctor", age: int = 35) -> int:
    cur.execute(
        """
        INSERT INTO staff (amka, first_name, last_name, age, hiring_date, staff_type)
        VALUES (%s, 'Test', 'User', %s, '2020-01-01', %s)
        """,
        (_uid(), age, staff_type),
    )
    return cur.lastrowid


def insert_doctor(
    cur,
    *,
    rank: str = "Επιμελητής Α",
    specialty: str = "Παθολογία",
    supervisor_id: int | None = None,
    age: int = 40,
) -> int:
    sid = insert_staff(cur, staff_type="doctor", age=age)
    cur.execute(
        """
        INSERT INTO doctor (staff_id, license_number, specialty, `rank`, supervisor_id)
        VALUES (%s, %s, %s, %s, %s)
        """,
        (sid, _uid(), specialty, rank, supervisor_id),
    )
    return sid


def insert_director(cur, *, specialty: str = "Χειρουργική") -> int:
    """Insert a Διευθυντής (no supervisor allowed)."""
    return insert_doctor(cur, rank="Διευθυντής", specialty=specialty, supervisor_id=None)


def insert_trainee(cur, *, supervisor_id: int, specialty: str = "Παθολογία") -> int:
    """Insert an Ειδικευόμενος (supervisor required)."""
    return insert_doctor(cur, rank="Ειδικευόμενος", specialty=specialty, supervisor_id=supervisor_id)


def insert_nurse(cur, *, department_id: int, rank: str = "Νοσηλευτής", age: int = 30) -> int:
    sid = insert_staff(cur, staff_type="nurse", age=age)
    cur.execute(
        "INSERT INTO nurse (staff_id, `rank`, department_id) VALUES (%s, %s, %s)",
        (sid, rank, department_id),
    )
    return sid


def insert_administrative(cur, *, department_id: int, age: int = 35) -> int:
    sid = insert_staff(cur, staff_type="administrative", age=age)
    cur.execute(
        "INSERT INTO administrative (staff_id, role, department_id) VALUES (%s, 'Γραμματέας', %s)",
        (sid, department_id),
    )
    return sid


# ── Department / Bed ──────────────────────────────────────────────────────────

def insert_department(cur, *, director_id: int | None = None) -> int:
    name = "Τμήμα-" + _uid()[:8]
    cur.execute(
        """
        INSERT INTO department (name, num_beds, floor_building, director_id)
        VALUES (%s, 10, '1ος', %s)
        """,
        (name, director_id),
    )
    return cur.lastrowid


def insert_bed(cur, *, department_id: int, status: str = "διαθέσιμη") -> int:
    num = abs(hash(uuid.uuid4())) % 9000 + 1000
    cur.execute(
        "INSERT INTO bed (`number`, `type`, `status`, department_id) VALUES (%s, 'Απλή', %s, %s)",
        (num, status, department_id),
    )
    return cur.lastrowid


# ── Patient ───────────────────────────────────────────────────────────────────

def insert_patient(cur) -> int:
    cur.execute(
        """
        INSERT INTO patient (amka, first_name, last_name, age, gender,
                             insurance_provider)
        VALUES (%s, 'Ασθενής', 'Τεστ', 40, 'M', 'ΕΟΠΥΥ')
        """,
        (_uid(),),
    )
    return cur.lastrowid


# ── KEN / ICD10 ───────────────────────────────────────────────────────────────

def insert_ken(cur, *, base_cost: float = 500.0, alos_days: int = 5) -> str:
    code = "K" + _uid()[:6]
    cur.execute(
        "INSERT INTO ken (ken_code, description, base_cost, alos_days) VALUES (%s, 'Test KEN', %s, %s)",
        (code, base_cost, alos_days),
    )
    return code


def insert_icd10(cur) -> str:
    code = "A" + _uid()[:4]
    cur.execute(
        "INSERT INTO ICD10 (icd_code, description, category) VALUES (%s, 'Test ICD', 'Test')",
        (code,),
    )
    return code


# ── Hospitalization ───────────────────────────────────────────────────────────

def insert_hospitalization(
    cur,
    *,
    patient_id: int,
    bed_id: int,
    department_id: int,
    admission_date: str = "2025-01-01",
    discharge_date: str | None = None,
    ken_code: str | None = None,
) -> int:
    cur.execute(
        """
        INSERT INTO hospitalization
            (patient_id, bed_id, department_id, admission_date, discharge_date, ken_code)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (patient_id, bed_id, department_id, admission_date, discharge_date, ken_code),
    )
    return cur.lastrowid


# ── Shift ─────────────────────────────────────────────────────────────────────

def insert_shift(
    cur,
    *,
    department_id: int,
    shift_date: str,
    shift_type: str = "morning",
) -> int:
    cur.execute(
        """
        INSERT INTO shift (department_id, shift_date, shift_type)
        VALUES (%s, %s, %s)
        """,
        (department_id, shift_date, shift_type),
    )
    return cur.lastrowid


def assign_shift(cur, *, shift_id: int, staff_id: int) -> None:
    cur.execute(
        "INSERT INTO shift_assignment (shift_id, staff_id) VALUES (%s, %s)",
        (shift_id, staff_id),
    )


# ── Procedure room / catalog / medical_procedure ──────────────────────────────

def insert_procedure_room(cur) -> int:
    name = "ΑΙΘ-" + _uid()[:6]
    cur.execute(
        "INSERT INTO procedure_room (room_name, room_type) VALUES (%s, 'χειρουργείο')",
        (name,),
    )
    return cur.lastrowid


def insert_procedure_catalog(cur) -> str:
    code = "PC" + _uid()[:6]
    cur.execute(
        """
        INSERT INTO procedure_catalog (procedure_code, name, category)
        VALUES (%s, 'Test Procedure', 'χειρουργική')
        """,
        (code,),
    )
    return code


def insert_medical_procedure(
    cur,
    *,
    hospitalization_id: int,
    room_id: int,
    surgeon_id: int,
    start_time: str,
    end_time: str | None = None,
    procedure_code: str | None = None,
) -> int:
    if procedure_code is None:
        procedure_code = insert_procedure_catalog(cur)
    cur.execute(
        """
        INSERT INTO medical_procedure
            (procedure_code, hospitalization_id, room_id, primary_surgeon_id, start_time, end_time)
        VALUES (%s, %s, %s, %s, %s, %s)
        """,
        (procedure_code, hospitalization_id, room_id, surgeon_id, start_time, end_time),
    )
    return cur.lastrowid


# ── Drug / Substance / Prescription ──────────────────────────────────────────

def insert_drug(cur) -> int:
    cur.execute(
        "INSERT INTO drug (drug_name) VALUES (%s)",
        ("DrugTest-" + _uid()[:6],),
    )
    return cur.lastrowid


def insert_substance(cur) -> int:
    cur.execute(
        "INSERT INTO active_substance (substance_name) VALUES (%s)",
        ("SubstanceTest-" + _uid()[:8],),
    )
    return cur.lastrowid


def link_drug_substance(cur, *, drug_id: int, substance_id: int) -> None:
    cur.execute(
        "INSERT INTO drug_substance (drug_id, substance_id) VALUES (%s, %s)",
        (drug_id, substance_id),
    )


def add_patient_allergy(cur, *, patient_id: int, substance_id: int) -> None:
    cur.execute(
        "INSERT INTO patient_allergy (patient_id, substance_id) VALUES (%s, %s)",
        (patient_id, substance_id),
    )


def insert_prescription(
    cur,
    *,
    hospitalization_id: int,
    doctor_id: int,
    patient_id: int,
    drug_id: int,
    start_date: str = "2025-01-02",
) -> int:
    cur.execute(
        """
        INSERT INTO prescription
            (hospitalization_id, doctor_id, patient_id, drug_id, start_date)
        VALUES (%s, %s, %s, %s, %s)
        """,
        (hospitalization_id, doctor_id, patient_id, drug_id, start_date),
    )
    return cur.lastrowid
