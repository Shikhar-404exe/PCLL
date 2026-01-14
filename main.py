#!/usr/bin/env python3
"""
Personal Cognitive Load Ledger (PCLL)
======================================

Main entry point for the PCLL application.

Usage:
    python main.py log          # Log today's cognitive load
    python main.py status       # View current balance
    python main.py week         # View weekly summary
    python main.py history      # View recent entries
    python main.py demo         # Run demo with sample data

For more options:
    python main.py --help

IMPORTANT DISCLAIMER:
    PCLL is a productivity tracking tool, not a medical or mental health
    application. It does not diagnose conditions or provide medical advice.
    See 'python main.py disclaimer' for full terms.
"""

import sys
import os
from datetime import datetime, timedelta

# Add project root to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from src.cli import main as cli_main, print_header, print_separator
from src.models import DailyInput
from src.ledger import PCLLLedger, format_balance_display, format_trend_display
from src.database import create_database, create_memory_database
from src.insights import InsightGenerator, format_insight_display
from src.config import Disclaimers


def run_demo():
    """
    Run a demonstration of PCLL with sample data.
    Uses in-memory database (no persistence).
    """
    print()
    print_header("PCLL DEMONSTRATION")
    print()
    print("This demo simulates 7 days of cognitive load tracking.")
    print("Using in-memory database (data will not persist).")
    print()
    print(Disclaimers.FOOTER_DISCLAIMER)
    print()
    input("Press Enter to continue...")
    print()
    
    # Create in-memory ledger
    db = create_memory_database()
    ledger = PCLLLedger(database=db)
    insight_gen = InsightGenerator()
    
    # Sample week data (matches Section 7.2 example)
    sample_days = [
        # Day 1 (Monday) - Moderate workload
        {
            "date": "2025-12-08",
            "context_count": 6,
            "decision_count": 8,
            "unresolved_count": 6,
            "recovery_quality": 5,
            "note": "Normal Monday, client meeting in afternoon"
        },
        # Day 2 (Tuesday) - High stress day
        {
            "date": "2025-12-09",
            "context_count": 12,
            "decision_count": 18,
            "unresolved_count": 12,
            "recovery_quality": 2,
            "subjective_depletion": 9,
            "note": "Production crisis, urgent fixes needed"
        },
        # Day 3 (Wednesday) - Debt carryover
        {
            "date": "2025-12-10",
            "context_count": 8,
            "decision_count": 10,
            "unresolved_count": 10,
            "recovery_quality": 4,
            "subjective_depletion": 7,
            "note": "Still recovering from yesterday"
        },
        # Day 4 (Thursday) - Recovery attempt
        {
            "date": "2025-12-11",
            "context_count": 4,
            "decision_count": 6,
            "unresolved_count": 4,
            "recovery_quality": 8,
            "subjective_depletion": 4,
            "note": "Lighter day, took proper breaks"
        },
        # Day 5 (Friday) - Light day
        {
            "date": "2025-12-12",
            "context_count": 3,
            "decision_count": 4,
            "unresolved_count": 2,
            "recovery_quality": 7,
            "note": "Wrapped up week, early finish"
        },
        # Day 6 (Saturday) - Rest
        {
            "date": "2025-12-13",
            "context_count": 1,
            "decision_count": 2,
            "unresolved_count": 2,
            "recovery_quality": 9,
            "note": "Weekend rest"
        },
        # Day 7 (Sunday) - Rest
        {
            "date": "2025-12-14",
            "context_count": 1,
            "decision_count": 1,
            "unresolved_count": 1,
            "recovery_quality": 10,
            "note": "Full rest day"
        },
    ]
    
    print("=" * 60)
    print(" SIMULATING 7-DAY WEEK")
    print("=" * 60)
    print()
    
    for day_data in sample_days:
        # Create input
        daily_input = DailyInput(
            date=day_data["date"],
            context_count=day_data["context_count"],
            decision_count=day_data["decision_count"],
            unresolved_count=day_data["unresolved_count"],
            recovery_quality=day_data["recovery_quality"],
            subjective_depletion=day_data.get("subjective_depletion"),
            text_note=day_data.get("note")
        )
        
        # Add entry
        entry = ledger.add_daily_entry(daily_input)
        
        # Display
        state_icon = "✓" if entry.closing_balance >= 30 else "⚠️" if entry.closing_balance >= 0 else "❌"
        print(f"{state_icon} {entry.date}: {format_balance_display(entry.closing_balance)}")
        print(f"   Contexts: {day_data['context_count']}, Decisions: {day_data['decision_count']}, "
              f"Recovery: {day_data['recovery_quality']}/10")
        if day_data.get("note"):
            print(f"   Note: {day_data['note']}")
        print()
    
    print_separator()
    print()
    
    # Weekly trends
    trends = ledger.calculate_weekly_trends()
    if trends:
        print(format_trend_display(trends))
        print()
    
    # Generate insights
    entries = ledger.get_recent_entries(7)
    if entries and trends:
        insights = insight_gen.generate_weekly_insights(entries, trends)
        if insights:
            print("INSIGHTS GENERATED:")
            for insight in insights:
                print(f"  {format_insight_display(insight)}")
            print()
    
    # Summary stats
    stats = ledger.get_summary_stats(7)
    print_separator()
    print("WEEK SUMMARY:")
    print(f"  Days Logged:     {stats['total_days']}")
    print(f"  Avg Balance:     {stats['avg_balance']:.0f} CU")
    print(f"  Min Balance:     {stats['min_balance']:.0f} CU")
    print(f"  Max Balance:     {stats['max_balance']:.0f} CU")
    print(f"  Deficit Days:    {stats['deficit_days']}")
    print(f"  Avg Withdrawals: {stats['avg_withdrawals']:.0f} CU/day")
    print(f"  Avg Deposits:    {stats['avg_deposits']:.0f} CU/day")
    print_separator()
    print()
    
    print("Demo complete. Run 'python main.py log' to start tracking your own data.")
    print()
    print(Disclaimers.FOOTER_DISCLAIMER)


def run_quick_test():
    """
    Run a quick test to verify all components work.
    """
    print("Running quick component test...")
    print()
    
    errors = []
    
    # Test 1: Models
    try:
        from src.models import DailyInput, DailyLedgerEntry, CognitiveState
        input_test = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        assert input_test.validate() == [], "Validation should pass"
        print("✓ Models: OK")
    except Exception as e:
        errors.append(f"Models: {e}")
        print(f"✗ Models: {e}")
    
    # Test 2: Calculator
    try:
        from src.calculator import CognitiveLoadCalculator, extract_features
        calc = CognitiveLoadCalculator()
        features = extract_features(input_test)
        assert features.context_count == 5
        cost, _ = calc.calculate_context_cost(5)
        assert cost > 0, "Context cost should be positive"
        print("✓ Calculator: OK")
    except Exception as e:
        errors.append(f"Calculator: {e}")
        print(f"✗ Calculator: {e}")
    
    # Test 3: Database
    try:
        from src.database import create_memory_database
        db = create_memory_database()
        assert db.get_entry_count() == 0
        print("✓ Database: OK")
    except Exception as e:
        errors.append(f"Database: {e}")
        print(f"✗ Database: {e}")
    
    # Test 4: Ledger
    try:
        from src.ledger import PCLLLedger
        ledger = PCLLLedger(database=db)
        entry = ledger.add_daily_entry(input_test)
        assert entry.closing_balance is not None
        assert entry.cognitive_state is not None
        print("✓ Ledger: OK")
    except Exception as e:
        errors.append(f"Ledger: {e}")
        print(f"✗ Ledger: {e}")
    
    # Test 5: Insights
    try:
        from src.insights import InsightGenerator
        gen = InsightGenerator()
        # May or may not generate insight depending on values
        insight = gen.generate_daily_insight(entry)
        print("✓ Insights: OK")
    except Exception as e:
        errors.append(f"Insights: {e}")
        print(f"✗ Insights: {e}")
    
    # Test 6: Config/Guardrails
    try:
        from src.config import SafetyGuardrails, CUConstants
        is_valid, violations = SafetyGuardrails.validate_text("Your balance is 50 CU")
        assert is_valid, "Clean text should validate"
        is_valid, violations = SafetyGuardrails.validate_text("You should see a doctor about depression")
        assert not is_valid, "Clinical text should fail"
        print("✓ Config/Guardrails: OK")
    except Exception as e:
        errors.append(f"Config: {e}")
        print(f"✗ Config: {e}")
    
    print()
    if errors:
        print(f"FAILED: {len(errors)} component(s) have errors")
        return False
    else:
        print("ALL TESTS PASSED ✓")
        return True


def main():
    """Main entry point."""
    # Check for special commands before passing to CLI
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "demo":
            run_demo()
            return
        
        if command == "test":
            success = run_quick_test()
            sys.exit(0 if success else 1)
        
        if command == "--version":
            from src import __version__
            print(f"PCLL version {__version__}")
            return
    
    # Pass to CLI
    cli_main()


if __name__ == "__main__":
    main()
