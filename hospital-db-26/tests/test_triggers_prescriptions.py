"""
Tests: trg_prescription_allergy_check

Rule: A prescription for a drug whose active substance(s) the patient is
allergic to must be rejected with SIGNAL 45000.
"""

from __future__ import annotations

import pytest
from helpers import (
    insert_department, insert_bed, insert_patient, insert_hospitalization,
    insert_doctor, insert_director, insert_drug, insert_substance,
    link_drug_substance, add_patient_allergy, insert_prescription,
)


@pytest.fixture()
def base(cur):
    """Minimal set of rows every test in this module needs."""
    dept = insert_department(cur, director_id=None)
    bed = insert_bed(cur, department_id=dept)
    patient = insert_patient(cur)
    hosp = insert_hospitalization(
        cur,
        patient_id=patient,
        bed_id=bed,
        department_id=dept,
        admission_date="2025-03-01",
    )
    doctor = insert_director(cur)
    return {"dept": dept, "bed": bed, "patient": patient, "hosp": hosp, "doctor": doctor}


class TestPrescriptionAllergyCheck:
    def test_prescription_blocked_when_patient_allergic(self, cur, base):
        """Prescribing a drug whose substance the patient is allergic to must raise SIGNAL."""
        drug = insert_drug(cur)
        substance = insert_substance(cur)
        link_drug_substance(cur, drug_id=drug, substance_id=substance)
        add_patient_allergy(cur, patient_id=base["patient"], substance_id=substance)

        with pytest.raises(Exception, match="45000|1644|αλλεργικός"):
            insert_prescription(
                cur,
                hospitalization_id=base["hosp"],
                doctor_id=base["doctor"],
                patient_id=base["patient"],
                drug_id=drug,
            )

    def test_prescription_allowed_when_no_allergy(self, cur, base):
        """Prescribing a drug the patient is NOT allergic to must succeed."""
        drug = insert_drug(cur)
        substance = insert_substance(cur)
        link_drug_substance(cur, drug_id=drug, substance_id=substance)
        # No allergy record added

        rx_id = insert_prescription(
            cur,
            hospitalization_id=base["hosp"],
            doctor_id=base["doctor"],
            patient_id=base["patient"],
            drug_id=drug,
        )
        assert rx_id > 0

    def test_prescription_blocked_only_for_matching_substance(self, cur, base):
        """Patient allergic to substance A; drug contains only substance B — must be allowed."""
        drug = insert_drug(cur)
        substance_b = insert_substance(cur)
        substance_a = insert_substance(cur)
        link_drug_substance(cur, drug_id=drug, substance_id=substance_b)
        add_patient_allergy(cur, patient_id=base["patient"], substance_id=substance_a)

        rx_id = insert_prescription(
            cur,
            hospitalization_id=base["hosp"],
            doctor_id=base["doctor"],
            patient_id=base["patient"],
            drug_id=drug,
        )
        assert rx_id > 0

    def test_prescription_blocked_when_drug_has_multiple_substances_and_one_matches(
        self, cur, base
    ):
        """Drug has 2 substances; patient allergic to one → prescription must be blocked."""
        drug = insert_drug(cur)
        sub1 = insert_substance(cur)
        sub2 = insert_substance(cur)
        link_drug_substance(cur, drug_id=drug, substance_id=sub1)
        link_drug_substance(cur, drug_id=drug, substance_id=sub2)
        add_patient_allergy(cur, patient_id=base["patient"], substance_id=sub2)

        with pytest.raises(Exception, match="45000|1644|αλλεργικός"):
            insert_prescription(
                cur,
                hospitalization_id=base["hosp"],
                doctor_id=base["doctor"],
                patient_id=base["patient"],
                drug_id=drug,
            )
