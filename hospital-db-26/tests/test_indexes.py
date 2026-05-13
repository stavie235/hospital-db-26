"""
Tests: all expected indexes exist in the hospital database.

Each test checks one index via information_schema.STATISTICS.
Tests are read-only and need no rollback.
"""

from __future__ import annotations

import pytest

# (table_name, index_name)
EXPECTED_INDEXES = [
    ("hospitalization", "idx_hospitalization_patient"),
    ("hospitalization", "idx_hospitalization_department"),
    ("hospitalization", "idx_hospitalization_admission"),
    ("hospitalization", "idx_hospitalization_ken"),
    ("hospitalization", "idx_hospitalization_icd"),
    ("doctor",          "idx_doctor_specialty"),
    ("doctor",          "idx_doctor_rank"),
    ("doctor",          "idx_doctor_supervisor"),
    ("shift",           "idx_shift_date"),
    ("shift",           "idx_shift_dept_date"),
    ("shift_assignment","idx_shift_assignment_staff"),
    ("lab_test",        "idx_lab_test_hospitalization"),
    ("medical_procedure","idx_procedure_surgeon"),
    ("medical_procedure","idx_procedure_start_time"),
    ("staff",           "idx_staff_age"),
    ("drug",            "idx_drug_name"),
    ("drug_substance",  "idx_drug_substance_drug"),
    ("drug_substance",  "idx_drug_substance_substance"),
    ("prescription",    "idx_prescription_patient"),
    ("prescription",    "idx_prescription_doctor"),
    ("prescription",    "idx_prescription_hospitalization"),
    ("patient_allergy", "idx_patient_allergy_substance"),
    ("triage_record",   "idx_triage_urgency"),
    ("evaluation",      "idx_evaluation_hospitalization"),
    ("doctor_evaluation","idx_doctor_evaluation_doctor"),
]


@pytest.mark.parametrize("table,index_name", EXPECTED_INDEXES)
def test_index_exists(db, table, index_name):
    cursor = db.cursor()
    cursor.execute(
        """
        SELECT COUNT(*)
        FROM information_schema.STATISTICS
        WHERE table_schema = %s
          AND table_name   = %s
          AND index_name   = %s
        """,
        (db.database, table, index_name),
    )
    (count,) = cursor.fetchone()
    cursor.close()
    assert count > 0, (
        f"Index '{index_name}' on table '{table}' not found in information_schema"
    )


def test_all_triggers_exist(db):
    """All 19 triggers from install.sql must be present."""
    expected = {
        "trg_doctor_supervisor_insert",
        "trg_doctor_supervisor_update",
        "trg_doctor_no_cycle_insert",
        "trg_doctor_no_cycle_update",
        "trg_prescription_allergy_check",
        "trg_evaluation_discharged",
        "trg_doctor_evaluation_check",
        "trg_shift_monthly_limit",
        "trg_shift_rest_period",
        "trg_shift_consecutive_nights",
        "trg_shift_trainee_requires_senior",
        "trg_shift_min_staffing",
        "trg_procedure_room_overlap",
        "trg_procedure_doctor_overlap",
        "trg_procedure_assistant_overlap",
        "trg_hospitalization_bed_check",
        "trg_hospitalization_bed_occupy",
        "trg_hospitalization_bed_free",
        "trg_hospitalization_cost",
    }

    cursor = db.cursor()
    cursor.execute(
        """
        SELECT trigger_name
        FROM information_schema.TRIGGERS
        WHERE trigger_schema = %s
        """,
        (db.database,),
    )
    found = {row[0] for row in cursor.fetchall()}
    cursor.close()

    missing = expected - found
    assert not missing, f"Missing triggers: {sorted(missing)}"
