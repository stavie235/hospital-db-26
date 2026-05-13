"""
Tests: evaluation triggers

  trg_evaluation_discharged       — hospitalization evaluation only after discharge_date is set
  trg_doctor_evaluation_check     — doctor evaluation requires (a) completed hosp AND
                                     (b) the doctor prescribed during that hospitalization
"""

from __future__ import annotations

import pytest
from helpers import (
    insert_department, insert_bed, insert_patient, insert_hospitalization,
    insert_director, insert_drug, insert_prescription,
)


@pytest.fixture()
def hosp_open(cur):
    """Returns an open (not yet discharged) hospitalization + supporting IDs."""
    dept = insert_department(cur)
    bed = insert_bed(cur, department_id=dept)
    patient = insert_patient(cur)
    doctor = insert_director(cur)
    h_id = insert_hospitalization(
        cur,
        patient_id=patient,
        bed_id=bed,
        department_id=dept,
        admission_date="2025-10-01",
        discharge_date=None,
    )
    return {"hosp": h_id, "patient": patient, "doctor": doctor, "dept": dept, "bed": bed}


@pytest.fixture()
def hosp_closed(cur):
    """Returns a discharged hospitalization + supporting IDs."""
    dept = insert_department(cur)
    bed = insert_bed(cur, department_id=dept)
    patient = insert_patient(cur)
    doctor = insert_director(cur)
    h_id = insert_hospitalization(
        cur,
        patient_id=patient,
        bed_id=bed,
        department_id=dept,
        admission_date="2025-10-01",
    )
    # Discharge the patient
    cur.execute(
        "UPDATE hospitalization SET discharge_date = '2025-10-10' WHERE hospitalization_id = %s",
        (h_id,),
    )
    return {"hosp": h_id, "patient": patient, "doctor": doctor, "dept": dept, "bed": bed}


# ── trg_evaluation_discharged ─────────────────────────────────────────────────

class TestEvaluationDischarged:
    def test_evaluation_of_open_hospitalization_is_rejected(self, cur, hosp_open):
        """Evaluating an open hospitalization (no discharge_date) must raise SIGNAL."""
        with pytest.raises(Exception, match="45000|1644|ολοκληρωμένη"):
            cur.execute(
                """
                INSERT INTO evaluation
                    (hospitalization_id, nursing_care, cleanliness, food, overall)
                VALUES (%s, 4, 4, 3, 4)
                """,
                (hosp_open["hosp"],),
            )

    def test_evaluation_of_discharged_hospitalization_is_accepted(self, cur, hosp_closed):
        """Evaluating a completed hospitalization must succeed."""
        cur.execute(
            """
            INSERT INTO evaluation
                (hospitalization_id, nursing_care, cleanliness, food, overall)
            VALUES (%s, 5, 4, 3, 4)
            """,
            (hosp_closed["hosp"],),
        )
        cur.execute(
            "SELECT evaluation_id FROM evaluation WHERE hospitalization_id = %s",
            (hosp_closed["hosp"],),
        )
        assert cur.fetchone() is not None


# ── trg_doctor_evaluation_check ──────────────────────────────────────────────

class TestDoctorEvaluationCheck:
    def test_doctor_evaluation_on_open_hosp_is_rejected(self, cur, hosp_open):
        """Doctor evaluation for open hospitalization must raise SIGNAL."""
        with pytest.raises(Exception, match="45000|1644|ολοκληρωμένη"):
            cur.execute(
                """
                INSERT INTO doctor_evaluation (hospitalization_id, doctor_id, medical_care)
                VALUES (%s, %s, 5)
                """,
                (hosp_open["hosp"], hosp_open["doctor"]),
            )

    def test_doctor_evaluation_without_prescription_is_rejected(self, cur, hosp_closed):
        """Doctor evaluation when the doctor never prescribed in that hospitalization must raise SIGNAL."""
        other_doctor = insert_director(cur)  # doctor who never prescribed
        with pytest.raises(Exception, match="45000|1644|συνταγογραφήσει"):
            cur.execute(
                """
                INSERT INTO doctor_evaluation (hospitalization_id, doctor_id, medical_care)
                VALUES (%s, %s, 4)
                """,
                (hosp_closed["hosp"], other_doctor),
            )

    def test_doctor_evaluation_with_prescription_is_accepted(self, cur, hosp_closed):
        """Doctor evaluation is accepted when the doctor has a prescription in that hospitalization."""
        drug = insert_drug(cur)
        # hosp_closed["doctor"] prescribes during this hospitalization
        # We need to get the patient_id from the hospitalization
        cur.execute(
            "SELECT patient_id FROM hospitalization WHERE hospitalization_id = %s",
            (hosp_closed["hosp"],),
        )
        patient_id = cur.fetchone()[0]

        insert_prescription(
            cur,
            hospitalization_id=hosp_closed["hosp"],
            doctor_id=hosp_closed["doctor"],
            patient_id=patient_id,
            drug_id=drug,
            start_date="2025-10-02",
        )

        cur.execute(
            """
            INSERT INTO doctor_evaluation (hospitalization_id, doctor_id, medical_care)
            VALUES (%s, %s, 5)
            """,
            (hosp_closed["hosp"], hosp_closed["doctor"]),
        )
        cur.execute(
            "SELECT eval_id FROM doctor_evaluation WHERE hospitalization_id = %s AND doctor_id = %s",
            (hosp_closed["hosp"], hosp_closed["doctor"]),
        )
        assert cur.fetchone() is not None

    def test_doctor_evaluation_from_different_hospitalization_prescription_is_rejected(
        self, cur, hosp_closed
    ):
        """A doctor who prescribed during a DIFFERENT hospitalization of the same patient
        cannot be evaluated in this one."""
        dept2 = hosp_closed["dept"]
        bed2 = insert_bed(cur, department_id=dept2)

        # Get patient_id
        cur.execute(
            "SELECT patient_id FROM hospitalization WHERE hospitalization_id = %s",
            (hosp_closed["hosp"],),
        )
        patient_id = cur.fetchone()[0]

        # Insert a second (open) hospitalization for the same patient
        hosp2 = insert_hospitalization(
            cur,
            patient_id=patient_id,
            bed_id=bed2,
            department_id=dept2,
            admission_date="2025-11-01",
        )

        drug = insert_drug(cur)
        # Doctor prescribes only in hosp2, not in hosp_closed["hosp"]
        insert_prescription(
            cur,
            hospitalization_id=hosp2,
            doctor_id=hosp_closed["doctor"],
            patient_id=patient_id,
            drug_id=drug,
            start_date="2025-11-02",
        )

        # Evaluation for hosp_closed should still be rejected
        with pytest.raises(Exception, match="45000|1644|συνταγογραφήσει"):
            cur.execute(
                """
                INSERT INTO doctor_evaluation (hospitalization_id, doctor_id, medical_care)
                VALUES (%s, %s, 4)
                """,
                (hosp_closed["hosp"], hosp_closed["doctor"]),
            )
