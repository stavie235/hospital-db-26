"""
Tests: bed management triggers

  trg_hospitalization_bed_check   — admission blocked if bed not 'διαθέσιμη'
  trg_hospitalization_bed_occupy  — AFTER INSERT: bed → 'κατειλημμένη'
  trg_hospitalization_bed_free    — AFTER UPDATE: bed → 'διαθέσιμη' on discharge
  trg_hospitalization_cost        — BEFORE UPDATE: total_cost calculated from KEN on discharge
"""

from __future__ import annotations

import pytest
from helpers import (
    insert_department, insert_bed, insert_patient, insert_hospitalization,
    insert_ken,
)


@pytest.fixture()
def dept(cur):
    return insert_department(cur)


# ── Bed availability check ────────────────────────────────────────────────────

class TestBedCheck:
    def test_admission_to_occupied_bed_is_rejected(self, cur, dept):
        """Inserting a hospitalization on an occupied bed must raise SIGNAL."""
        bed = insert_bed(cur, department_id=dept, status="κατειλημμένη")
        patient = insert_patient(cur)
        with pytest.raises(Exception, match="45000|1644|κλίνη"):
            insert_hospitalization(
                cur,
                patient_id=patient,
                bed_id=bed,
                department_id=dept,
                admission_date="2025-04-01",
            )

    def test_admission_to_maintenance_bed_is_rejected(self, cur, dept):
        """Inserting a hospitalization on a maintenance bed must raise SIGNAL."""
        bed = insert_bed(cur, department_id=dept, status="υπό συντήρηση")
        patient = insert_patient(cur)
        with pytest.raises(Exception, match="45000|1644|κλίνη"):
            insert_hospitalization(
                cur,
                patient_id=patient,
                bed_id=bed,
                department_id=dept,
                admission_date="2025-04-01",
            )

    def test_admission_to_available_bed_is_accepted(self, cur, dept):
        """Inserting a hospitalization on an available bed must succeed."""
        bed = insert_bed(cur, department_id=dept, status="διαθέσιμη")
        patient = insert_patient(cur)
        h_id = insert_hospitalization(
            cur,
            patient_id=patient,
            bed_id=bed,
            department_id=dept,
            admission_date="2025-04-02",
        )
        assert h_id > 0


# ── Bed status lifecycle ──────────────────────────────────────────────────────

class TestBedLifecycle:
    def test_bed_becomes_occupied_after_admission(self, cur, dept):
        """After inserting a hospitalization, the bed status must change to 'κατειλημμένη'."""
        bed = insert_bed(cur, department_id=dept)
        patient = insert_patient(cur)
        insert_hospitalization(
            cur,
            patient_id=patient,
            bed_id=bed,
            department_id=dept,
            admission_date="2025-06-01",
        )
        cur.execute("SELECT status FROM bed WHERE id = %s", (bed,))
        assert cur.fetchone()[0] == "κατειλημμένη"

    def test_bed_becomes_available_after_discharge(self, cur, dept):
        """After setting discharge_date on a hospitalization, the bed must become 'διαθέσιμη'."""
        bed = insert_bed(cur, department_id=dept)
        patient = insert_patient(cur)
        h_id = insert_hospitalization(
            cur,
            patient_id=patient,
            bed_id=bed,
            department_id=dept,
            admission_date="2025-06-10",
        )
        cur.execute(
            "UPDATE hospitalization SET discharge_date = '2025-06-15' WHERE hospitalization_id = %s",
            (h_id,),
        )
        cur.execute("SELECT status FROM bed WHERE id = %s", (bed,))
        assert cur.fetchone()[0] == "διαθέσιμη"

    def test_bed_stays_occupied_on_non_discharge_update(self, cur, dept):
        """Updating a hospitalization field other than discharge_date must NOT free the bed."""
        bed = insert_bed(cur, department_id=dept)
        patient = insert_patient(cur)
        h_id = insert_hospitalization(
            cur,
            patient_id=patient,
            bed_id=bed,
            department_id=dept,
            admission_date="2025-06-20",
        )
        cur.execute(
            "UPDATE hospitalization SET admission_diagnosis = 'Πυρετός' WHERE hospitalization_id = %s",
            (h_id,),
        )
        cur.execute("SELECT status FROM bed WHERE id = %s", (bed,))
        assert cur.fetchone()[0] == "κατειλημμένη"


# ── Cost calculation ──────────────────────────────────────────────────────────

class TestHospitalizationCost:
    def test_cost_equals_base_when_stay_within_alos(self, cur, dept):
        """When actual days ≤ alos_days, total_cost must equal base_cost exactly."""
        ken_code = insert_ken(cur, base_cost=1000.00, alos_days=5)
        bed = insert_bed(cur, department_id=dept)
        patient = insert_patient(cur)
        h_id = insert_hospitalization(
            cur,
            patient_id=patient,
            bed_id=bed,
            department_id=dept,
            admission_date="2025-07-01",
            ken_code=ken_code,
        )
        # Stay 4 days (< alos 5)
        cur.execute(
            "UPDATE hospitalization SET discharge_date = '2025-07-05' WHERE hospitalization_id = %s",
            (h_id,),
        )
        cur.execute("SELECT total_cost FROM hospitalization WHERE hospitalization_id = %s", (h_id,))
        cost = float(cur.fetchone()[0])
        assert cost == pytest.approx(1000.00)

    def test_cost_exceeds_base_when_stay_beyond_alos(self, cur, dept):
        """When actual days > alos_days, total_cost must include daily surcharge."""
        # base_cost=1000, alos=5 days, actual=7 days → 2 extra days * (1000/5) = +400 → 1400
        ken_code = insert_ken(cur, base_cost=1000.00, alos_days=5)
        bed = insert_bed(cur, department_id=dept)
        patient = insert_patient(cur)
        h_id = insert_hospitalization(
            cur,
            patient_id=patient,
            bed_id=bed,
            department_id=dept,
            admission_date="2025-08-01",
            ken_code=ken_code,
        )
        cur.execute(
            "UPDATE hospitalization SET discharge_date = '2025-08-08' WHERE hospitalization_id = %s",
            (h_id,),
        )
        cur.execute("SELECT total_cost FROM hospitalization WHERE hospitalization_id = %s", (h_id,))
        cost = float(cur.fetchone()[0])
        # 7 actual days > 5 alos → cost = 1000 + (7-5)*(1000/5) = 1000 + 400 = 1400
        assert cost == pytest.approx(1400.00)

    def test_cost_not_set_without_ken_code(self, cur, dept):
        """When ken_code is NULL, total_cost must remain NULL after discharge."""
        bed = insert_bed(cur, department_id=dept)
        patient = insert_patient(cur)
        h_id = insert_hospitalization(
            cur,
            patient_id=patient,
            bed_id=bed,
            department_id=dept,
            admission_date="2025-09-01",
            ken_code=None,
        )
        cur.execute(
            "UPDATE hospitalization SET discharge_date = '2025-09-05' WHERE hospitalization_id = %s",
            (h_id,),
        )
        cur.execute("SELECT total_cost FROM hospitalization WHERE hospitalization_id = %s", (h_id,))
        assert cur.fetchone()[0] is None
