"""
PCLL Prototype - Personal Cognitive Load Ledger
================================================

A simple working prototype demonstrating the core PCLL logic:
- Tracks daily cognitive load using a banking metaphor
- 100 CU (Cognitive Units) = full daily capacity
- Withdrawals = cognitive costs (contexts, decisions, unresolved items)
- Deposits = recovery activities
- Deficits carry over at 20% rate

Run: python pcll_prototype.py
"""

import sqlite3
from dataclasses import dataclass, field
from typing import List, Optional
from datetime import datetime, timedelta
from enum import Enum


# =============================================================================
# SECTION 1: DATA STRUCTURES
# =============================================================================

class CognitiveState(Enum):
    """
    Cognitive state based on closing balance.
    Maps balance ranges to human-readable states.
    """
    WELL_RESTED = "WELL_RESTED"      # Balance >= 70 CU
    MODERATE = "MODERATE"             # Balance 40-69 CU
    DEPLETED = "DEPLETED"             # Balance 1-39 CU
    DEFICIT = "DEFICIT"               # Balance -49 to 0 CU
    SEVERE_DEFICIT = "SEVERE_DEFICIT" # Balance <= -50 CU


@dataclass
class DailyInput:
    """
    User's daily input data - collected in <60 seconds.
    
    Attributes:
        date: ISO format date string (YYYY-MM-DD)
        context_count: Number of different contexts/projects worked on (0-20+)
        decision_count: Number of significant decisions made (0-30+)
        unresolved_count: Open loops/pending items at end of day (0-50+)
        recovery_quality: Self-rated recovery quality (1-10 scale)
    """
    date: str
    context_count: int          # How many different things did you work on?
    decision_count: int         # How many decisions did you make?
    unresolved_count: int       # How many open items are pending?
    recovery_quality: int       # How well did you recover? (1=poor, 10=excellent)


@dataclass
class ComponentBreakdown:
    """
    Breakdown of cognitive costs by component.
    Each cost is calculated using specific formulas from the spec.
    """
    context_cost: float = 0.0       # Cost of context switching
    decision_cost: float = 0.0      # Cost of decision-making
    passive_drain: float = 0.0      # Background drain from open loops
    recovery_deposit: float = 0.0   # Recovery credits earned


@dataclass
class LedgerEntry:
    """
    A single day's ledger entry - the core accounting record.
    
    Follows double-entry bookkeeping principles:
    - Opening balance: Where you start the day
    - Withdrawals: Cognitive costs (debits)
    - Deposits: Recovery activities (credits)
    - Closing balance: Where you end the day
    """
    date: str
    opening_balance: float
    total_withdrawals: float
    total_deposits: float
    closing_balance: float
    cognitive_state: CognitiveState
    components: ComponentBreakdown
    
    def __str__(self) -> str:
        """Pretty print the ledger entry."""
        return (
            f"📅 {self.date}\n"
            f"   Opening:     {self.opening_balance:+.1f} CU\n"
            f"   Withdrawals: {self.total_withdrawals:-.1f} CU\n"
            f"   Deposits:    {self.total_deposits:+.1f} CU\n"
            f"   ─────────────────────\n"
            f"   Closing:     {self.closing_balance:+.1f} CU  [{self.cognitive_state.value}]"
        )


# =============================================================================
# SECTION 2: CONSTANTS (from PCLL spec)
# =============================================================================

# Base costs per unit
CONTEXT_BASE_COST = 2.0          # CU per context
CONTEXT_SWITCH_COST = 1.5        # CU per switch (contexts - 1)
DECISION_BASE_COST = 8.0         # CU per decision
PASSIVE_DRAIN_RATE = 0.75        # CU per unresolved item
RECOVERY_BASE = 40.0             # Base recovery at quality 5

# Multipliers for high load
CONTEXT_HIGH_LOAD_THRESHOLD = 10
CONTEXT_HIGH_LOAD_PENALTY = 1.2  # 20% extra cost

DECISION_FATIGUE_THRESHOLD_1 = 10
DECISION_FATIGUE_THRESHOLD_2 = 20
DECISION_FATIGUE_MULTIPLIER_1 = 1.15
DECISION_FATIGUE_MULTIPLIER_2 = 1.3

# Carryover rate for deficits
DEFICIT_CARRYOVER_RATE = 0.20    # 20% of deficit carries to next day

# Balance thresholds for state classification
WELL_RESTED_THRESHOLD = 70
MODERATE_THRESHOLD = 40
DEPLETED_THRESHOLD = 1
SEVERE_DEFICIT_THRESHOLD = -50


# =============================================================================
# SECTION 3: CALCULATION FUNCTIONS
# =============================================================================

def calculate_context_cost(context_count: int) -> float:
    """
    Calculate cognitive cost from context switching.
    
    Formula:
        Base: contexts × 2 CU
        Switches: (contexts - 1) × 1.5 CU
        Penalty: ×1.2 if contexts >= 10
    
    Example:
        5 contexts = (5 × 2) + (4 × 1.5) = 10 + 6 = 16 CU
    """
    if context_count <= 0:
        return 0.0
    
    # Base cost for each context
    base_cost = context_count * CONTEXT_BASE_COST
    
    # Additional cost for switching between contexts
    switch_cost = max(0, context_count - 1) * CONTEXT_SWITCH_COST
    
    total = base_cost + switch_cost
    
    # Apply high-load penalty if too many contexts
    if context_count >= CONTEXT_HIGH_LOAD_THRESHOLD:
        total *= CONTEXT_HIGH_LOAD_PENALTY
    
    return round(total, 1)


def calculate_decision_cost(decision_count: int) -> float:
    """
    Calculate cognitive cost from decision-making.
    
    Formula:
        Base: decisions × 8 CU
        Fatigue: ×1.15 if >10 decisions, ×1.3 if >20
    
    Why 8 CU? Decisions require evaluation, comparison, and commitment.
    They're the most cognitively expensive single activity.
    
    Example:
        5 decisions = 5 × 8 = 40 CU
        15 decisions = 15 × 8 × 1.15 = 138 CU (fatigue kicks in)
    """
    if decision_count <= 0:
        return 0.0
    
    base_cost = decision_count * DECISION_BASE_COST
    
    # Apply fatigue multiplier based on decision count
    if decision_count > DECISION_FATIGUE_THRESHOLD_2:
        base_cost *= DECISION_FATIGUE_MULTIPLIER_2
    elif decision_count > DECISION_FATIGUE_THRESHOLD_1:
        base_cost *= DECISION_FATIGUE_MULTIPLIER_1
    
    return round(base_cost, 1)


def calculate_passive_drain(unresolved_count: int) -> float:
    """
    Calculate background cognitive drain from open loops.
    
    Formula:
        Drain: unresolved × 0.75 CU
    
    Why? Unresolved items consume mental bandwidth even when
    not actively working on them (Zeigarnik effect).
    
    Example:
        10 open items = 10 × 0.75 = 7.5 CU constant drain
    """
    if unresolved_count <= 0:
        return 0.0
    
    return round(unresolved_count * PASSIVE_DRAIN_RATE, 1)


def calculate_recovery_deposit(recovery_quality: int) -> float:
    """
    Calculate cognitive recovery from rest/activities.
    
    Formula:
        Deposit = 40 × (quality / 5)
        
        Quality 5 (baseline) = 40 CU
        Quality 10 (excellent) = 80 CU
        Quality 1 (poor) = 8 CU
    
    This is the only way to "deposit" back into your account.
    
    Example:
        Quality 7 = 40 × (7/5) = 56 CU recovered
    """
    # Clamp quality to valid range
    quality = max(1, min(10, recovery_quality))
    
    # Linear scaling: quality 5 = factor 1.0
    factor = quality / 5.0
    
    return round(RECOVERY_BASE * factor, 1)


def determine_state(balance: float) -> CognitiveState:
    """
    Map closing balance to cognitive state.
    
    Thresholds:
        >= 70 CU: WELL_RESTED (green zone)
        40-69 CU: MODERATE (yellow zone)
        1-39 CU: DEPLETED (orange zone)
        -49 to 0: DEFICIT (red zone)
        <= -50: SEVERE_DEFICIT (critical)
    """
    if balance >= WELL_RESTED_THRESHOLD:
        return CognitiveState.WELL_RESTED
    elif balance >= MODERATE_THRESHOLD:
        return CognitiveState.MODERATE
    elif balance >= DEPLETED_THRESHOLD:
        return CognitiveState.DEPLETED
    elif balance > SEVERE_DEFICIT_THRESHOLD:
        return CognitiveState.DEFICIT
    else:
        return CognitiveState.SEVERE_DEFICIT


def calculate_opening_balance(previous_closing: Optional[float]) -> float:
    """
    Calculate opening balance for a new day.
    
    Rules:
        1. First day: Start at 100 CU (full capacity)
        2. After positive day: Reset to 100 CU
        3. After deficit: 100 + (deficit × 0.20)
    
    The 20% carryover means deficits don't fully reset overnight.
    You need intentional recovery to clear debt.
    
    Example:
        Previous close: -50 CU
        Carryover: -50 × 0.20 = -10 CU
        Opening: 100 + (-10) = 90 CU
    """
    if previous_closing is None:
        return 100.0  # First day baseline
    
    if previous_closing >= 0:
        return 100.0  # Full reset for positive balances
    
    # Deficit carryover: 20% of negative balance
    carryover = previous_closing * DEFICIT_CARRYOVER_RATE
    return round(100.0 + carryover, 1)


# =============================================================================
# SECTION 4: LEDGER UPDATE FUNCTION
# =============================================================================

def update_ledger(
    daily_input: DailyInput,
    previous_closing: Optional[float] = None
) -> LedgerEntry:
    """
    Core ledger update function - processes a day's input into a ledger entry.
    
    This is the heart of the PCLL system. It:
    1. Calculates opening balance (with carryover if applicable)
    2. Computes all withdrawal costs (context, decision, passive)
    3. Computes recovery deposit
    4. Calculates closing balance
    5. Determines cognitive state
    
    Args:
        daily_input: User's daily cognitive load data
        previous_closing: Previous day's closing balance (None if first day)
    
    Returns:
        LedgerEntry with complete accounting for the day
    """
    # Step 1: Calculate opening balance
    # ---------------------------------
    # If this is the first day, start at 100 CU.
    # Otherwise, apply 20% deficit carryover rule.
    opening = calculate_opening_balance(previous_closing)
    
    # Step 2: Calculate all withdrawal costs
    # --------------------------------------
    # Each component represents a different type of cognitive expense.
    context_cost = calculate_context_cost(daily_input.context_count)
    decision_cost = calculate_decision_cost(daily_input.decision_count)
    passive_drain = calculate_passive_drain(daily_input.unresolved_count)
    
    # Total withdrawals = sum of all costs
    total_withdrawals = context_cost + decision_cost + passive_drain
    
    # Step 3: Calculate recovery deposit
    # -----------------------------------
    # This is the only way to add back to the balance.
    # Based on recovery quality (1-10 scale).
    recovery = calculate_recovery_deposit(daily_input.recovery_quality)
    
    # Step 4: Calculate closing balance
    # ----------------------------------
    # Simple accounting: Opening - Withdrawals + Deposits
    # Can go negative (deficit state).
    closing = round(opening - total_withdrawals + recovery, 1)
    
    # Step 5: Determine cognitive state
    # ----------------------------------
    # Map the closing balance to a human-readable state.
    state = determine_state(closing)
    
    # Step 6: Build and return the entry
    # -----------------------------------
    components = ComponentBreakdown(
        context_cost=context_cost,
        decision_cost=decision_cost,
        passive_drain=passive_drain,
        recovery_deposit=recovery
    )
    
    return LedgerEntry(
        date=daily_input.date,
        opening_balance=opening,
        total_withdrawals=total_withdrawals,
        total_deposits=recovery,
        closing_balance=closing,
        cognitive_state=state,
        components=components
    )


# =============================================================================
# SECTION 5: LOCAL STORAGE (SQLite)
# =============================================================================

def create_database(db_path: str = ":memory:") -> sqlite3.Connection:
    """
    Create SQLite database with ledger schema.
    
    Uses in-memory database by default for the prototype.
    Pass a file path for persistent storage.
    """
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    # Create ledger entries table
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS ledger_entries (
            date TEXT PRIMARY KEY,
            opening_balance REAL,
            total_withdrawals REAL,
            total_deposits REAL,
            closing_balance REAL,
            cognitive_state TEXT,
            context_cost REAL,
            decision_cost REAL,
            passive_drain REAL,
            recovery_deposit REAL,
            created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
    """)
    
    conn.commit()
    return conn


def save_entry(conn: sqlite3.Connection, entry: LedgerEntry) -> None:
    """Save a ledger entry to the database."""
    cursor = conn.cursor()
    cursor.execute("""
        INSERT OR REPLACE INTO ledger_entries (
            date, opening_balance, total_withdrawals, total_deposits,
            closing_balance, cognitive_state, context_cost, decision_cost,
            passive_drain, recovery_deposit
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """, (
        entry.date,
        entry.opening_balance,
        entry.total_withdrawals,
        entry.total_deposits,
        entry.closing_balance,
        entry.cognitive_state.value,
        entry.components.context_cost,
        entry.components.decision_cost,
        entry.components.passive_drain,
        entry.components.recovery_deposit
    ))
    conn.commit()


def get_all_entries(conn: sqlite3.Connection) -> List[dict]:
    """Retrieve all entries from the database."""
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM ledger_entries ORDER BY date")
    columns = [description[0] for description in cursor.description]
    return [dict(zip(columns, row)) for row in cursor.fetchall()]


# =============================================================================
# SECTION 6: MOCK DATA & 7-DAY SIMULATION
# =============================================================================

def generate_mock_week() -> List[DailyInput]:
    """
    Generate 7 days of realistic mock data.
    
    Simulates a typical work week:
    - Mon-Wed: Building intensity (more contexts, decisions)
    - Thu: Peak stress day (high load, poor recovery)
    - Fri: Winding down
    - Sat-Sun: Weekend recovery
    """
    base_date = datetime(2025, 12, 8)  # Starting Monday
    
    mock_data = [
        # Monday: Fresh start, moderate load
        DailyInput(
            date=(base_date + timedelta(days=0)).strftime("%Y-%m-%d"),
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=6
        ),
        
        # Tuesday: Ramping up
        DailyInput(
            date=(base_date + timedelta(days=1)).strftime("%Y-%m-%d"),
            context_count=7,
            decision_count=12,
            unresolved_count=10,
            recovery_quality=5
        ),
        
        # Wednesday: Heavy day
        DailyInput(
            date=(base_date + timedelta(days=2)).strftime("%Y-%m-%d"),
            context_count=10,
            decision_count=15,
            unresolved_count=15,
            recovery_quality=4
        ),
        
        # Thursday: Peak stress (enters deficit)
        DailyInput(
            date=(base_date + timedelta(days=3)).strftime("%Y-%m-%d"),
            context_count=12,
            decision_count=20,
            unresolved_count=20,
            recovery_quality=3
        ),
        
        # Friday: Trying to recover
        DailyInput(
            date=(base_date + timedelta(days=4)).strftime("%Y-%m-%d"),
            context_count=6,
            decision_count=8,
            unresolved_count=12,
            recovery_quality=5
        ),
        
        # Saturday: Weekend recovery
        DailyInput(
            date=(base_date + timedelta(days=5)).strftime("%Y-%m-%d"),
            context_count=2,
            decision_count=3,
            unresolved_count=8,
            recovery_quality=8
        ),
        
        # Sunday: Full recovery
        DailyInput(
            date=(base_date + timedelta(days=6)).strftime("%Y-%m-%d"),
            context_count=1,
            decision_count=2,
            unresolved_count=5,
            recovery_quality=9
        ),
    ]
    
    return mock_data


def run_simulation():
    """
    Run a 7-day simulation with mock data.
    
    Demonstrates the complete PCLL flow:
    1. Initialize database
    2. Process each day's input
    3. Track carryover between days
    4. Display results
    """
    print("=" * 60)
    print("  PCLL PROTOTYPE - 7-Day Simulation")
    print("=" * 60)
    print()
    print("Starting simulation with realistic work week data...")
    print("100 CU = full daily cognitive capacity")
    print()
    
    # Initialize in-memory database
    db = create_database()
    
    # Generate mock data
    week_data = generate_mock_week()
    
    # Process each day
    previous_closing = None
    entries: List[LedgerEntry] = []
    
    print("-" * 60)
    
    for daily_input in week_data:
        # Update ledger with carryover from previous day
        entry = update_ledger(daily_input, previous_closing)
        
        # Save to database
        save_entry(db, entry)
        
        # Track for next iteration
        entries.append(entry)
        previous_closing = entry.closing_balance
        
        # Display entry
        print(entry)
        print()
        
        # Show component breakdown
        print(f"   Components:")
        print(f"     Context switching: -{entry.components.context_cost:.1f} CU")
        print(f"     Decision making:   -{entry.components.decision_cost:.1f} CU")
        print(f"     Passive drain:     -{entry.components.passive_drain:.1f} CU")
        print(f"     Recovery:          +{entry.components.recovery_deposit:.1f} CU")
        print("-" * 60)
    
    # Summary statistics
    print()
    print("=" * 60)
    print("  WEEKLY SUMMARY")
    print("=" * 60)
    
    balances = [e.closing_balance for e in entries]
    avg_balance = sum(balances) / len(balances)
    min_balance = min(balances)
    max_balance = max(balances)
    deficit_days = sum(1 for b in balances if b < 0)
    
    print(f"""
    Days analyzed:    {len(entries)}
    Average balance:  {avg_balance:.1f} CU
    Lowest point:     {min_balance:.1f} CU
    Highest point:    {max_balance:.1f} CU
    Days in deficit:  {deficit_days}
    
    State distribution:
""")
    
    state_counts = {}
    for entry in entries:
        state = entry.cognitive_state.value
        state_counts[state] = state_counts.get(state, 0) + 1
    
    for state, count in state_counts.items():
        bar = "█" * (count * 5)
        print(f"      {state:15} {bar} ({count} days)")
    
    print()
    print("-" * 60)
    print("  INSIGHTS")
    print("-" * 60)
    
    # Generate simple insights based on the data
    if deficit_days > 0:
        print(f"  ⚠️  You spent {deficit_days} day(s) in deficit territory.")
        print(f"      Consider reducing load or improving recovery.")
    
    if min_balance < -30:
        print(f"  🔴 Severe deficit detected ({min_balance:.0f} CU).")
        print(f"      Thursday's load exceeded sustainable capacity.")
    
    if max_balance >= 70:
        print(f"  ✅ Good recovery achieved (peak: {max_balance:.0f} CU).")
        print(f"      Weekend rest helped restore capacity.")
    
    avg_recovery = sum(e.components.recovery_deposit for e in entries) / len(entries)
    avg_withdrawals = sum(e.total_withdrawals for e in entries) / len(entries)
    recovery_ratio = avg_recovery / avg_withdrawals if avg_withdrawals > 0 else 1
    
    print(f"\n  📊 Recovery ratio: {recovery_ratio:.0%}")
    if recovery_ratio < 0.5:
        print(f"      Low recovery vs. withdrawals. Aim for 50%+ ratio.")
    
    print()
    print("=" * 60)
    print("  Database contents (verification)")
    print("=" * 60)
    
    # Show database contents
    db_entries = get_all_entries(db)
    print(f"\n  Stored {len(db_entries)} entries in SQLite database.\n")
    
    print("  Date       | Opening | Close  | State")
    print("  " + "-" * 45)
    for row in db_entries:
        print(f"  {row['date']} | {row['opening_balance']:+6.1f} | {row['closing_balance']:+6.1f} | {row['cognitive_state']}")
    
    print()
    print("Simulation complete!")
    
    # Close database
    db.close()
    
    return entries


# =============================================================================
# SECTION 7: MAIN ENTRY POINT
# =============================================================================

if __name__ == "__main__":
    """
    Run the PCLL prototype simulation.
    
    This demonstrates:
    - Data structure definitions
    - Cognitive load calculations
    - Ledger update mechanics
    - Deficit carryover behavior
    - SQLite storage
    - 7-day output with insights
    """
    run_simulation()
