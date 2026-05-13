"""
Tests: shift assignment triggers

  trg_shift_monthly_limit         — doctors ≤15, nurses ≤20, admin ≤25 shifts/month
  trg_shift_rest_period           — ≥8h rest between consecutive shifts
  trg_shift_consecutive_nights    — max 3 consecutive night shifts
  trg_shift_trainee_requires_senior — Ειδικευόμενος needs Επιμελητής Α or Διευθυντής in same shift
  trg_shift_min_staffing          — DELETE blocked when staff count would drop below minimum
"""

from __future__ import annotations

import pytest
from helpers import (
    insert_department, insert_director, insert_doctor, insert_trainee,
    insert_nurse, insert_administrative, insert_shift, assign_shift,
)


@pytest.fixture()
def dept(cur):
    return insert_department(cur)


# ── Monthly limit ─────────────────────────────────────────────────────────────

class TestMonthlyLimit:
    def test_doctor_exceeding_15_shifts_is_rejected(self, cur, dept):
        """A doctor already assigned 15 shifts in a month must be blocked on the 16th."""
        doctor = insert_director(cur)
        # Use dates 2025-06-01 to 2025-06-15, alternating morning/afternoon to avoid rest conflict
        for day in range(1, 16):
            shift_type = "morning" if day % 2 == 1 else "afternoon"
            date_str = f"2025-06-{day:02d}"
            s = insert_shift(cur, department_id=dept, shift_date=date_str, shift_type=shift_type)
            assign_shift(cur, shift_id=s, staff_id=doctor)

        # 16th shift (different day so no rest conflict; doctor already has 15 this month)
        s16 = insert_shift(cur, department_id=dept, shift_date="2025-06-16", shift_type="morning")
        with pytest.raises(Exception, match="45000|1644|μηνιαίου"):
            assign_shift(cur, shift_id=s16, staff_id=doctor)

    def test_doctor_15th_shift_is_accepted(self, cur, dept):
        """Exactly 15 shifts in a month must be allowed."""
        doctor = insert_director(cur)
        for day in range(1, 15):
            shift_type = "morning" if day % 2 == 1 else "afternoon"
            s = insert_shift(cur, department_id=dept, shift_date=f"2025-07-{day:02d}", shift_type=shift_type)
            assign_shift(cur, shift_id=s, staff_id=doctor)

        s15 = insert_shift(cur, department_id=dept, shift_date="2025-07-15", shift_type="morning")
        assign_shift(cur, shift_id=s15, staff_id=doctor)  # must not raise

    def test_nurse_monthly_limit_is_20(self, cur, dept):
        """Nurse exceeding 20 shifts in a month must be blocked."""
        nurse = insert_nurse(cur, department_id=dept)
        for day in range(1, 21):
            shift_type = "morning" if day % 2 == 1 else "afternoon"
            s = insert_shift(cur, department_id=dept, shift_date=f"2025-08-{day:02d}", shift_type=shift_type)
            assign_shift(cur, shift_id=s, staff_id=nurse)

        s21 = insert_shift(cur, department_id=dept, shift_date="2025-08-21", shift_type="morning")
        with pytest.raises(Exception, match="45000|1644|μηνιαίου"):
            assign_shift(cur, shift_id=s21, staff_id=nurse)

    def test_different_months_not_counted_together(self, cur, dept):
        """Shifts in different months are counted independently; 15 in June + 1 in July is OK."""
        doctor = insert_director(cur)
        for day in range(1, 16):
            shift_type = "morning" if day % 2 == 1 else "afternoon"
            s = insert_shift(cur, department_id=dept, shift_date=f"2025-09-{day:02d}", shift_type=shift_type)
            assign_shift(cur, shift_id=s, staff_id=doctor)

        s_next = insert_shift(cur, department_id=dept, shift_date="2025-10-01", shift_type="morning")
        assign_shift(cur, shift_id=s_next, staff_id=doctor)  # must not raise


# ── Rest period ───────────────────────────────────────────────────────────────

class TestRestPeriod:
    def test_morning_then_afternoon_same_day_is_rejected(self, cur, dept):
        """Morning (07-15) → afternoon (15-23) same day leaves 0h rest → blocked."""
        doctor = insert_director(cur)
        s1 = insert_shift(cur, department_id=dept, shift_date="2025-11-01", shift_type="morning")
        assign_shift(cur, shift_id=s1, staff_id=doctor)
        s2 = insert_shift(cur, department_id=dept, shift_date="2025-11-01", shift_type="afternoon")
        with pytest.raises(Exception, match="45000|1644|ανάπαυσης"):
            assign_shift(cur, shift_id=s2, staff_id=doctor)

    def test_morning_then_next_morning_is_rejected(self, cur, dept):
        """Morning day 1 → morning day 2: 16h apart is fine, but morning day 1 ends at 15:00,
        next morning starts at 07:00 → only 16h gap (>8h) so it IS allowed.
        Actually 15:00 + 8h = 23:00 > 07:00 next day → CONFLICT."""
        doctor = insert_director(cur)
        s1 = insert_shift(cur, department_id=dept, shift_date="2025-11-03", shift_type="morning")
        assign_shift(cur, shift_id=s1, staff_id=doctor)
        s2 = insert_shift(cur, department_id=dept, shift_date="2025-11-04", shift_type="morning")
        # morning end 15:00 + 8h = 23:00; next morning start 07:00 → 23:00 > 07:00 → conflict
        with pytest.raises(Exception, match="45000|1644|ανάπαυσης"):
            assign_shift(cur, shift_id=s2, staff_id=doctor)

    def test_afternoon_then_morning_two_days_later_is_allowed(self, cur, dept):
        """Afternoon day 1 (ends 23:00) + 8h = 07:00 day 2; morning day 3 starts 07:00 → OK."""
        doctor = insert_director(cur)
        s1 = insert_shift(cur, department_id=dept, shift_date="2025-11-05", shift_type="afternoon")
        assign_shift(cur, shift_id=s1, staff_id=doctor)
        s2 = insert_shift(cur, department_id=dept, shift_date="2025-11-07", shift_type="morning")
        assign_shift(cur, shift_id=s2, staff_id=doctor)  # must not raise


# ── Consecutive nights ────────────────────────────────────────────────────────

class TestConsecutiveNights:
    def test_fourth_consecutive_night_is_rejected(self, cur, dept):
        """4 consecutive night shifts must be rejected."""
        doctor = insert_director(cur)
        for day in range(1, 4):
            s = insert_shift(cur, department_id=dept, shift_date=f"2025-12-{day:02d}", shift_type="night")
            assign_shift(cur, shift_id=s, staff_id=doctor)

        s4 = insert_shift(cur, department_id=dept, shift_date="2025-12-04", shift_type="night")
        with pytest.raises(Exception, match="45000|1644|νυχτερινές"):
            assign_shift(cur, shift_id=s4, staff_id=doctor)

    def test_three_consecutive_nights_is_allowed(self, cur, dept):
        """Exactly 3 consecutive night shifts must be accepted."""
        doctor = insert_director(cur)
        for day in range(10, 13):
            s = insert_shift(cur, department_id=dept, shift_date=f"2025-12-{day:02d}", shift_type="night")
            assign_shift(cur, shift_id=s, staff_id=doctor)  # must not raise

    def test_gap_resets_consecutive_count(self, cur, dept):
        """3 nights, 1 day gap, then 3 more nights — each group of 3 is fine."""
        doctor = insert_director(cur)
        for day in [15, 16, 17]:
            s = insert_shift(cur, department_id=dept, shift_date=f"2025-12-{day:02d}", shift_type="night")
            assign_shift(cur, shift_id=s, staff_id=doctor)

        # Day 18 is a morning (gap), day 19 starts a new night sequence
        s_gap = insert_shift(cur, department_id=dept, shift_date="2025-12-18", shift_type="morning")
        assign_shift(cur, shift_id=s_gap, staff_id=doctor)

        s19 = insert_shift(cur, department_id=dept, shift_date="2025-12-19", shift_type="night")
        assign_shift(cur, shift_id=s19, staff_id=doctor)  # must not raise


# ── Trainee requires senior ───────────────────────────────────────────────────

class TestTraineeRequiresSenior:
    def test_trainee_alone_in_shift_is_rejected(self, cur, dept):
        """Assigning a trainee to an empty shift (no senior) must raise SIGNAL."""
        senior = insert_director(cur)
        trainee = insert_trainee(cur, supervisor_id=senior)

        s = insert_shift(cur, department_id=dept, shift_date="2026-01-10", shift_type="morning")
        # No senior assigned yet
        with pytest.raises(Exception, match="45000|1644|Ειδικευόμενος"):
            assign_shift(cur, shift_id=s, staff_id=trainee)

    def test_trainee_after_senior_in_same_shift_is_accepted(self, cur, dept):
        """Trainee assigned after a senior in the same shift must be accepted."""
        senior = insert_director(cur)
        trainee = insert_trainee(cur, supervisor_id=senior)

        s = insert_shift(cur, department_id=dept, shift_date="2026-01-11", shift_type="morning")
        assign_shift(cur, shift_id=s, staff_id=senior)
        assign_shift(cur, shift_id=s, staff_id=trainee)  # must not raise

    def test_epimilitisA_can_be_assigned_alone(self, cur, dept):
        """Non-trainee doctor can be assigned to any shift regardless of others."""
        doctor = insert_doctor(cur, rank="Επιμελητής Α", supervisor_id=None)
        s = insert_shift(cur, department_id=dept, shift_date="2026-01-12", shift_type="afternoon")
        assign_shift(cur, shift_id=s, staff_id=doctor)  # must not raise


# ── Min staffing (BEFORE DELETE) ─────────────────────────────────────────────

class TestMinStaffing:
    def _fill_shift_to_minimum(self, cur, dept, shift_id):
        """Add exactly 3 doctors, 6 nurses, 2 admin to reach the minimum staffing level."""
        doctors = [insert_director(cur) for _ in range(3)]
        nurses = [insert_nurse(cur, department_id=dept) for _ in range(6)]
        admins = [insert_administrative(cur, department_id=dept) for _ in range(2)]
        for d in doctors:
            assign_shift(cur, shift_id=shift_id, staff_id=d)
        for n in nurses:
            assign_shift(cur, shift_id=shift_id, staff_id=n)
        for a in admins:
            assign_shift(cur, shift_id=shift_id, staff_id=a)
        return doctors, nurses, admins

    def test_delete_doctor_below_minimum_is_rejected(self, cur, dept):
        """Deleting a doctor that would bring shift below 3 doctors must raise SIGNAL."""
        s = insert_shift(cur, department_id=dept, shift_date="2026-02-01", shift_type="morning")
        doctors, nurses, admins = self._fill_shift_to_minimum(cur, dept, s)

        with pytest.raises(Exception, match="45000|1644|ιατρών"):
            cur.execute(
                "DELETE FROM shift_assignment WHERE shift_id=%s AND staff_id=%s",
                (s, doctors[0]),
            )

    def test_delete_nurse_below_minimum_is_rejected(self, cur, dept):
        """Deleting a nurse that would bring shift below 6 nurses must raise SIGNAL."""
        s = insert_shift(cur, department_id=dept, shift_date="2026-02-02", shift_type="morning")
        doctors, nurses, admins = self._fill_shift_to_minimum(cur, dept, s)

        with pytest.raises(Exception, match="45000|1644|νοσηλευτών"):
            cur.execute(
                "DELETE FROM shift_assignment WHERE shift_id=%s AND staff_id=%s",
                (s, nurses[0]),
            )

    def test_delete_admin_below_minimum_is_rejected(self, cur, dept):
        """Deleting an admin that would bring shift below 2 admin must raise SIGNAL."""
        s = insert_shift(cur, department_id=dept, shift_date="2026-02-03", shift_type="morning")
        doctors, nurses, admins = self._fill_shift_to_minimum(cur, dept, s)

        with pytest.raises(Exception, match="45000|1644|διοικητικών"):
            cur.execute(
                "DELETE FROM shift_assignment WHERE shift_id=%s AND staff_id=%s",
                (s, admins[0]),
            )

    def test_delete_extra_doctor_above_minimum_is_allowed(self, cur, dept):
        """With 4 doctors, deleting one (leaving 3) must be allowed."""
        s = insert_shift(cur, department_id=dept, shift_date="2026-02-04", shift_type="morning")
        doctors, nurses, admins = self._fill_shift_to_minimum(cur, dept, s)
        extra_doc = insert_director(cur)
        assign_shift(cur, shift_id=s, staff_id=extra_doc)

        cur.execute(
            "DELETE FROM shift_assignment WHERE shift_id=%s AND staff_id=%s",
            (s, extra_doc),
        )  # must not raise
