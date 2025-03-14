import Mathlib

open Lean

syntax (name := cancelDischarger) "cancel_discharger " : tactic
syntax (name := cancelAux) "cancel_aux " term " at " term : tactic
syntax (name := cancel) "cancel " term " at " term : tactic

macro_rules | `(tactic| cancel_discharger) => `(tactic | positivity)
macro_rules
| `(tactic| cancel_discharger) =>`(tactic | fail "cancel failed, could not verify the following side condition:")

/-! ### powers -/
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := lt_of_pow_lt_pow (n := $a) (by cancel_discharger) $(mkIdent h))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := le_of_pow_le_pow (n := $a) (by cancel_discharger) (by cancel_discharger) $(mkIdent h))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := pow_eq_zero (n := $a) $(mkIdent h))


/-! ### multiplication, LHS and RHS -/
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := mul_left_cancel₀ (a := $a) (by cancel_discharger) $(mkIdent h))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := mul_right_cancel₀ (b := $a) (by cancel_discharger) $(mkIdent h))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := le_of_mul_le_mul_left (a := $a) $(mkIdent h) (by cancel_discharger))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := le_of_mul_le_mul_right (a := $a) $(mkIdent h) (by cancel_discharger))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := lt_of_mul_lt_mul_left (a := $a) $(mkIdent h) (by cancel_discharger))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := lt_of_mul_lt_mul_right (a := $a) $(mkIdent h) (by cancel_discharger))

/-! ### multiplication, just LHS -/
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := pos_of_mul_pos_right (a := $a) $(mkIdent h) (by cancel_discharger))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := pos_of_mul_pos_left (b := $a) $(mkIdent h) (by cancel_discharger))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := nonneg_of_mul_nonneg_right (a := $a) $(mkIdent h) (by cancel_discharger))
macro_rules
| `(tactic| cancel_aux $a at $h) =>
  let h := h.raw.getId
  `(tactic | replace $(mkIdent h):ident := nonneg_of_mul_nonneg_left (b := $a) $(mkIdent h) (by cancel_discharger))

-- TODO to trigger this needs some `guard_hyp` in the `cancel_aux` implementations
elab_rules : tactic
  | `(tactic| cancel $a at $_) => do
  let goals ← Elab.Tactic.getGoals
  let goalsMsg := MessageData.joinSep (goals.map MessageData.ofGoal) m!"\n\n"
  throwError "cancel failed: no '{a}' to cancel\n{goalsMsg}"

-- TODO build in a `try change 1 ≤ _ at h` to upgrade the `0 < _` result in the case of Nat
macro_rules | `(tactic| cancel $a at $h) => `(tactic| cancel_aux $a at $h; try apply $h)

example {a b c : ℝ} {cpos : 0 < c} (h1 : c*a ≤ c*b) : a ≤ b := by
  cancel c at h1

example {a b c : ℝ} {cpos : 3 < c} (h1 : c*a ≤ c*b) : a ≤ b := by
  cancel c at h1

example {t : ℝ} (h1 : t ^ 2 = 3 * t) (h2 : t ≥ 1) : t ≥ 2 := by
  have h3 :=
    calc t * t = t ^ 2 := by ring
      _ = 3 * t := by rw [h1]

  cancel t at h3

  linarith [h3]

example (a b k : ℝ) (k_pos : k ≠ 0) (eq : k*a = k*b) : a = b := by
  apply_fun (fun r ↦ (1/k) * r) at eq
  field_simp at eq
  exact eq

example (a b k : ℝ) (k_pos : 0 ≠ k) (eq : k*a = k*b) : a = b := by
  apply_fun (fun r ↦ k * r)
  dsimp
  exact eq
  exact mul_right_injective₀ (id (Ne.symm k_pos))
-- #min_imports in example (a : ℕ) (ha : a ≠ 0) : (0 < a ∨ a < 0) := by exact?

-- open Nat Finset

-- example (hn : n > 2): fib (n+2) = fib n + fib (n+1) := by
--   plausible

-- example : fib (n+2) = fib n + fib (n+1) := by
--   exact fib_add_two

-- example (h : n > 1 ): fib (n) = fib (n-1) + fib (n-2) := by
--   let n' := n - 2
--   have h' : n = n' + 2 := by
--     omega
--   rw [h']
--   simp
--   have : n' ≥ 0 := by linarith
--   -- conv =>
--   --   rhs
--   --   rw [add_comm]
--   rw  (occs := [2] ) [add_comm]
--   exact fib_add_two

-- example (m : ℕ) : fib (m + 2) * fib m - fib (m + 1) ^ 2 = (-1 : ℤ) ^ (m + 1) := by
--   induction m with
--   | zero => rfl
--   | succ n ih =>
--     rw [pow_add, pow_one]
--     repeat rw [fib_add_two] at *
--     push_cast at *
--     linear_combination -(1 * ih)

-- example (h : n > 1 ): fib (n) = fib (n-1) + fib (n-2) := by
--   plausible

-- example (h : n > 0 ): fib (n+3) = 2*fib (n+1) + fib (n) := by
--   plausible

-- #eval choose 3 2

-- #check sum_range_choose
-- #check sum_range_choose_halfway

-- theorem test (n : ℕ) : (∑ m ∈ range (n + 1), n.choose m) = 2 ^ n := by
--   -- plausible
--   have := (add_pow 1 1 n).symm
--   simpa [one_add_one_eq_two] using this


-- #eval fib 22
