"""
Tests: trg_doctor_supervisor_insert/update  and  trg_doctor_no_cycle_insert/update

Rules enforced:
  1. Ειδικευόμενος must have a supervisor.
  2. Διευθυντής must NOT have a supervisor.
  3. No circular supervision chain.
"""

from __future__ import annotations

import pytest
from helpers import insert_doctor, insert_director, insert_trainee, insert_staff


# ── trg_doctor_supervisor_insert ─────────────────────────────────────────────

class TestSupervisorInsert:
    def test_trainee_without_supervisor_is_rejected(self, cur):
        """Ειδικευόμενος with supervisor_id=NULL must raise SIGNAL 45000."""
        sid = insert_staff(cur, staff_type="doctor", age=28)
        with pytest.raises(Exception, match="45000|1644|Ειδικευόμενος"):
            cur.execute(
                """
                INSERT INTO doctor (staff_id, license_number, specialty, `rank`, supervisor_id)
                VALUES (%s, %s, 'Παθολογία', 'Ειδικευόμενος', NULL)
                """,
                (sid, f"LIC{sid}"),
            )

    def test_trainee_with_supervisor_is_accepted(self, cur):
        """Ειδικευόμενος with a valid supervisor_id must insert without error."""
        sup = insert_director(cur)
        trainee_sid = insert_trainee(cur, supervisor_id=sup)
        cur.execute("SELECT staff_id FROM doctor WHERE staff_id = %s", (trainee_sid,))
        assert cur.fetchone() is not None

    def test_director_with_supervisor_is_rejected(self, cur):
        """Διευθυντής with supervisor_id set must raise SIGNAL 45000."""
        sup = insert_director(cur)
        sid = insert_staff(cur, staff_type="doctor", age=50)
        with pytest.raises(Exception, match="45000|1644|Διευθυντής"):
            cur.execute(
                """
                INSERT INTO doctor (staff_id, license_number, specialty, `rank`, supervisor_id)
                VALUES (%s, %s, 'Χειρουργική', 'Διευθυντής', %s)
                """,
                (sid, f"LIC{sid}", sup),
            )

    def test_director_without_supervisor_is_accepted(self, cur):
        """Διευθυντής without supervisor must insert cleanly."""
        sid = insert_director(cur)
        cur.execute("SELECT `rank` FROM doctor WHERE staff_id = %s", (sid,))
        row = cur.fetchone()
        assert row[0] == "Διευθυντής"

    def test_epimilitisB_needs_no_supervisor(self, cur):
        """Επιμελητής Β (non-trainee, non-director) is accepted with or without supervisor."""
        sid = insert_doctor(cur, rank="Επιμελητής Β", supervisor_id=None)
        cur.execute("SELECT staff_id FROM doctor WHERE staff_id = %s", (sid,))
        assert cur.fetchone() is not None


# ── trg_doctor_supervisor_update ─────────────────────────────────────────────

class TestSupervisorUpdate:
    def test_promoting_to_trainee_without_supervisor_is_rejected(self, cur):
        """Changing rank to Ειδικευόμενος while clearing supervisor must be rejected."""
        sid = insert_doctor(cur, rank="Επιμελητής Β", supervisor_id=None)
        with pytest.raises(Exception, match="45000|1644|Ειδικευόμενος"):
            cur.execute(
                "UPDATE doctor SET `rank` = 'Ειδικευόμενος', supervisor_id = NULL WHERE staff_id = %s",
                (sid,),
            )

    def test_giving_director_a_supervisor_via_update_is_rejected(self, cur):
        """Setting supervisor_id on a Διευθυντής via UPDATE must be rejected."""
        director = insert_director(cur)
        other_director = insert_director(cur)
        with pytest.raises(Exception, match="45000|1644|Διευθυντής"):
            cur.execute(
                "UPDATE doctor SET supervisor_id = %s WHERE staff_id = %s",
                (other_director, director),
            )


# ── trg_doctor_no_cycle_insert ───────────────────────────────────────────────

class TestNoCycleInsert:
    def test_self_supervision_is_rejected(self, cur):
        """A doctor cannot be their own supervisor (direct self-loop)."""
        # We first insert as Επιμελητής Α (no supervisor needed)
        sid = insert_doctor(cur, rank="Επιμελητής Α", supervisor_id=None)
        # Now try to set them as their own supervisor via update (cycle check on update)
        with pytest.raises(Exception, match="45000|1644|Κυκλική"):
            cur.execute(
                "UPDATE doctor SET supervisor_id = %s WHERE staff_id = %s",
                (sid, sid),
            )

    def test_two_node_cycle_is_rejected(self, cur):
        """A <-> B supervision cycle must be rejected."""
        a = insert_doctor(cur, rank="Επιμελητής Α", supervisor_id=None)
        b = insert_doctor(cur, rank="Επιμελητής Α", supervisor_id=a)
        # Now try to make A supervised by B — creates A→B→A cycle
        with pytest.raises(Exception, match="45000|1644|Κυκλική"):
            cur.execute(
                "UPDATE doctor SET supervisor_id = %s WHERE staff_id = %s",
                (b, a),
            )

    def test_valid_chain_is_accepted(self, cur):
        """A linear supervision chain A→B→C should be accepted."""
        director = insert_director(cur)
        senior = insert_doctor(cur, rank="Επιμελητής Α", supervisor_id=director)
        trainee = insert_trainee(cur, supervisor_id=senior)
        cur.execute(
            "SELECT supervisor_id FROM doctor WHERE staff_id = %s", (trainee,)
        )
        assert cur.fetchone()[0] == senior
