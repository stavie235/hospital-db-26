"""
Tests: medical procedure overlap triggers

  trg_procedure_room_overlap      — same room, overlapping times → blocked
  trg_procedure_doctor_overlap    — same surgeon, overlapping times → blocked (as primary or assistant)
  trg_procedure_assistant_overlap — same assistant in overlapping procedures → blocked
"""

from __future__ import annotations

import pytest
from helpers import (
    insert_department, insert_bed, insert_patient, insert_hospitalization,
    insert_director, insert_procedure_room, insert_medical_procedure,
    insert_procedure_catalog,
)


@pytest.fixture()
def base(cur):
    dept = insert_department(cur)
    bed = insert_bed(cur, department_id=dept)
    patient = insert_patient(cur)
    hosp = insert_hospitalization(
        cur,
        patient_id=patient,
        bed_id=bed,
        department_id=dept,
        admission_date="2025-05-01",
    )
    room = insert_procedure_room(cur)
    surgeon = insert_director(cur)
    pcode = insert_procedure_catalog(cur)
    return {
        "dept": dept, "bed": bed, "patient": patient,
        "hosp": hosp, "room": room, "surgeon": surgeon, "pcode": pcode,
    }


# ── Room overlap ──────────────────────────────────────────────────────────────

class TestRoomOverlap:
    def test_second_procedure_same_room_overlapping_is_rejected(self, cur, base):
        """Two procedures in the same room at the same time must be rejected."""
        insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=base["surgeon"],
            start_time="2025-05-10 08:00:00",
            end_time="2025-05-10 10:00:00",
            procedure_code=base["pcode"],
        )

        surgeon2 = insert_director(cur)
        with pytest.raises(Exception, match="45000|1644|χώρο"):
            insert_medical_procedure(
                cur,
                hospitalization_id=base["hosp"],
                room_id=base["room"],
                surgeon_id=surgeon2,
                start_time="2025-05-10 09:00:00",
                end_time="2025-05-10 11:00:00",
                procedure_code=base["pcode"],
            )

    def test_second_procedure_same_room_non_overlapping_is_allowed(self, cur, base):
        """Two procedures in the same room at different times must be accepted."""
        insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=base["surgeon"],
            start_time="2025-05-11 08:00:00",
            end_time="2025-05-11 10:00:00",
            procedure_code=base["pcode"],
        )

        room2 = insert_procedure_room(cur)
        surgeon2 = insert_director(cur)
        # Same room, but starts after first ends
        pid = insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=surgeon2,
            start_time="2025-05-11 10:00:00",
            end_time="2025-05-11 12:00:00",
            procedure_code=base["pcode"],
        )
        assert pid > 0

    def test_different_rooms_overlapping_time_is_allowed(self, cur, base):
        """Procedures in different rooms may overlap in time."""
        room2 = insert_procedure_room(cur)
        surgeon2 = insert_director(cur)

        insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=base["surgeon"],
            start_time="2025-05-12 08:00:00",
            end_time="2025-05-12 10:00:00",
            procedure_code=base["pcode"],
        )
        pid = insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=room2,
            surgeon_id=surgeon2,
            start_time="2025-05-12 09:00:00",
            end_time="2025-05-12 11:00:00",
            procedure_code=base["pcode"],
        )
        assert pid > 0


# ── Doctor overlap (primary surgeon) ─────────────────────────────────────────

class TestDoctorOverlap:
    def test_same_surgeon_in_overlapping_procedures_is_rejected(self, cur, base):
        """Same surgeon as primary in two overlapping procedures must be blocked."""
        room2 = insert_procedure_room(cur)

        insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=base["surgeon"],
            start_time="2025-05-15 08:00:00",
            end_time="2025-05-15 10:00:00",
            procedure_code=base["pcode"],
        )

        with pytest.raises(Exception, match="45000|1644|ιατρός"):
            insert_medical_procedure(
                cur,
                hospitalization_id=base["hosp"],
                room_id=room2,
                surgeon_id=base["surgeon"],
                start_time="2025-05-15 09:00:00",
                end_time="2025-05-15 11:00:00",
                procedure_code=base["pcode"],
            )

    def test_surgeon_as_assistant_then_as_primary_same_time_is_rejected(self, cur, base):
        """If a surgeon is first assigned as assistant in a procedure, they cannot
        be primary surgeon in an overlapping one."""
        room2 = insert_procedure_room(cur)
        other_surgeon = insert_director(cur)

        # Insert procedure where base["surgeon"] is NOT primary
        p1 = insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=other_surgeon,
            start_time="2025-05-16 08:00:00",
            end_time="2025-05-16 10:00:00",
            procedure_code=base["pcode"],
        )
        # base["surgeon"] as assistant in p1
        cur.execute(
            "INSERT INTO procedure_assistant (procedure_id, staff_id, role) VALUES (%s, %s, 'βοηθός')",
            (p1, base["surgeon"]),
        )

        # Now base["surgeon"] tries to be primary in overlapping procedure
        with pytest.raises(Exception, match="45000|1644"):
            insert_medical_procedure(
                cur,
                hospitalization_id=base["hosp"],
                room_id=room2,
                surgeon_id=base["surgeon"],
                start_time="2025-05-16 09:00:00",
                end_time="2025-05-16 11:00:00",
                procedure_code=base["pcode"],
            )

    def test_same_surgeon_sequential_procedures_is_allowed(self, cur, base):
        """Same surgeon can perform two procedures back-to-back."""
        room2 = insert_procedure_room(cur)

        insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=base["surgeon"],
            start_time="2025-05-17 08:00:00",
            end_time="2025-05-17 10:00:00",
            procedure_code=base["pcode"],
        )
        pid = insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=room2,
            surgeon_id=base["surgeon"],
            start_time="2025-05-17 10:00:00",
            end_time="2025-05-17 12:00:00",
            procedure_code=base["pcode"],
        )
        assert pid > 0


# ── Assistant overlap ─────────────────────────────────────────────────────────

class TestAssistantOverlap:
    def test_assistant_in_two_overlapping_procedures_is_rejected(self, cur, base):
        """Same assistant in two overlapping procedures must be blocked."""
        room2 = insert_procedure_room(cur)
        surgeon2 = insert_director(cur)
        assistant = insert_director(cur)

        p1 = insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=base["surgeon"],
            start_time="2025-05-20 08:00:00",
            end_time="2025-05-20 10:00:00",
            procedure_code=base["pcode"],
        )
        cur.execute(
            "INSERT INTO procedure_assistant (procedure_id, staff_id, role) VALUES (%s, %s, 'βοηθός')",
            (p1, assistant),
        )

        p2 = insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=room2,
            surgeon_id=surgeon2,
            start_time="2025-05-20 09:00:00",
            end_time="2025-05-20 11:00:00",
            procedure_code=base["pcode"],
        )
        with pytest.raises(Exception, match="45000|1644|βοηθός"):
            cur.execute(
                "INSERT INTO procedure_assistant (procedure_id, staff_id, role) VALUES (%s, %s, 'βοηθός')",
                (p2, assistant),
            )

    def test_assistant_in_sequential_procedures_is_allowed(self, cur, base):
        """Same assistant in back-to-back (non-overlapping) procedures must be accepted."""
        room2 = insert_procedure_room(cur)
        surgeon2 = insert_director(cur)
        assistant = insert_director(cur)

        p1 = insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=base["room"],
            surgeon_id=base["surgeon"],
            start_time="2025-05-21 08:00:00",
            end_time="2025-05-21 10:00:00",
            procedure_code=base["pcode"],
        )
        cur.execute(
            "INSERT INTO procedure_assistant (procedure_id, staff_id, role) VALUES (%s, %s, 'βοηθός')",
            (p1, assistant),
        )

        p2 = insert_medical_procedure(
            cur,
            hospitalization_id=base["hosp"],
            room_id=room2,
            surgeon_id=surgeon2,
            start_time="2025-05-21 10:00:00",
            end_time="2025-05-21 12:00:00",
            procedure_code=base["pcode"],
        )
        cur.execute(
            "INSERT INTO procedure_assistant (procedure_id, staff_id, role) VALUES (%s, %s, 'βοηθός')",
            (p2, assistant),
        )  # must not raise
