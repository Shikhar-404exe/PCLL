"""
Command Line Interface for PCLL
================================

Interactive CLI for daily input collection and ledger viewing.
Implements Section 8 daily input system (<60 seconds to complete).

Usage:
    python -m src.cli log        # Log today's cognitive load
    python -m src.cli status     # View current balance
    python -m src.cli week       # View weekly summary
    python -m src.cli history    # View recent entries
"""

import argparse
import sys
from datetime import datetime, timedelta
from typing import Optional

from .models import DailyInput, UserProfile
from .ledger import PCLLLedger, format_balance_display, format_trend_display
from .database import PCLLDatabase, create_database
from .insights import InsightGenerator, format_insight_display
from .config import Disclaimers, AppSettings


# =============================================================================
# DISPLAY HELPERS
# =============================================================================

def clear_screen():
    """Clear terminal screen."""
    print("\033[2J\033[H", end="")


def print_header(title: str):
    """Print a formatted header."""
    width = 60
    print("=" * width)
    print(f" {title}".center(width))
    print("=" * width)


def print_separator():
    """Print a separator line."""
    print("-" * 60)


def print_box(lines: list[str], title: str = ""):
    """Print content in a box."""
    width = 58
    print("┌" + "─" * width + "┐")
    if title:
        print(f"│ {title:<{width-1}}│")
        print("├" + "─" * width + "┤")
    for line in lines:
        # Truncate if too long
        display_line = line[:width-2] if len(line) > width-2 else line
        print(f"│ {display_line:<{width-1}}│")
    print("└" + "─" * width + "┘")


def get_input_int(prompt: str, min_val: int, max_val: int, default: Optional[int] = None) -> int:
    """
    Get integer input with validation.
    
    Args:
        prompt: The prompt to display
        min_val: Minimum allowed value
        max_val: Maximum allowed value
        default: Default value if user presses Enter
        
    Returns:
        Validated integer
    """
    while True:
        try:
            if default is not None:
                user_input = input(f"{prompt} [{default}]: ").strip()
                if user_input == "":
                    return default
            else:
                user_input = input(f"{prompt}: ").strip()
            
            value = int(user_input)
            if min_val <= value <= max_val:
                return value
            else:
                print(f"  Please enter a number between {min_val} and {max_val}")
        except ValueError:
            print("  Please enter a valid number")


def get_input_optional_int(prompt: str, min_val: int, max_val: int) -> Optional[int]:
    """
    Get optional integer input (Enter to skip).
    
    Args:
        prompt: The prompt to display
        min_val: Minimum allowed value
        max_val: Maximum allowed value
        
    Returns:
        Integer or None if skipped
    """
    while True:
        user_input = input(f"{prompt} (Enter to skip): ").strip()
        if user_input == "":
            return None
        try:
            value = int(user_input)
            if min_val <= value <= max_val:
                return value
            else:
                print(f"  Please enter a number between {min_val} and {max_val}")
        except ValueError:
            print("  Please enter a valid number or press Enter to skip")


def get_input_text(prompt: str, max_length: int = 500) -> Optional[str]:
    """
    Get optional text input.
    
    Args:
        prompt: The prompt to display
        max_length: Maximum allowed length
        
    Returns:
        Text or None if skipped
    """
    user_input = input(f"{prompt} (Enter to skip): ").strip()
    if user_input == "":
        return None
    return user_input[:max_length]


# =============================================================================
# DAILY INPUT COLLECTION
# =============================================================================

def collect_daily_input(date: Optional[str] = None) -> DailyInput:
    """
    Collect daily input from user via interactive prompts.
    Designed to complete in <60 seconds per Section 8.
    
    Args:
        date: Optional date string (defaults to today)
        
    Returns:
        Completed DailyInput object
    """
    if date is None:
        date = datetime.now().strftime("%Y-%m-%d")
    
    print()
    print_box([
        "Daily Cognitive Load Check-In",
        f"Date: {date}",
        "",
        "Answer 4-5 quick questions (~45 seconds)",
    ], "PCLL")
    print()
    
    # Q1: Context count
    print("Q1. How many distinct projects/tasks/topics did you work on today?")
    print("    (Count separate contexts that required mental switching)")
    context_count = get_input_int("    Number of contexts", 0, 50, default=5)
    print()
    
    # Q2: Decision count
    print("Q2. How many significant decisions did you make today?")
    print("    (Count decisions requiring >2 minutes of thought)")
    decision_count = get_input_int("    Number of decisions", 0, 100, default=5)
    print()
    
    # Q3: Unresolved count
    print("Q3. How many tasks/questions remain unresolved as you end today?")
    print("    (Count open items still on your mind)")
    unresolved_count = get_input_int("    Unresolved items", 0, 100, default=8)
    print()
    
    # Q4: Recovery quality
    print("Q4. Rate your breaks/recovery today:")
    print("    1 = No real breaks, worked through")
    print("    5 = Typical day, some breaks")
    print("    10 = Excellent recovery, protected time")
    recovery_quality = get_input_int("    Recovery quality (1-10)", 1, 10, default=5)
    print()
    
    # Q5: Subjective depletion (optional)
    print("Q5. How mentally drained do you feel right now? (Optional)")
    print("    1 = Fresh and energized")
    print("    10 = Completely exhausted")
    subjective_depletion = get_input_optional_int("    Depletion level (1-10)", 1, 10)
    print()
    
    # Optional: Text note
    print("Optional: Any notes about today? (brief description)")
    text_note = get_input_text("    Notes")
    print()
    
    return DailyInput(
        date=date,
        context_count=context_count,
        decision_count=decision_count,
        unresolved_count=unresolved_count,
        recovery_quality=recovery_quality,
        subjective_depletion=subjective_depletion,
        text_note=text_note
    )


# =============================================================================
# COMMAND HANDLERS
# =============================================================================

def cmd_log(args, db: PCLLDatabase):
    """Handle 'log' command - collect daily input and create entry."""
    
    # Check if user has accepted disclaimer
    profile = db.get_or_create_profile("default")
    if not profile.disclaimer_accepted:
        show_disclaimer()
        response = input("\nDo you accept these terms? (yes/no): ").strip().lower()
        if response != "yes":
            print("\nYou must accept the disclaimer to use PCLL.")
            return
        profile.disclaimer_accepted = True
        profile.disclaimer_accepted_date = datetime.now().isoformat()
        db.save_profile(profile)
        print("\nDisclaimer accepted. Continuing...\n")
    
    # Determine date
    if args.date:
        date = args.date
    else:
        date = datetime.now().strftime("%Y-%m-%d")
    
    # Check if entry already exists
    existing = db.get_entry(date)
    if existing:
        print(f"\nEntry for {date} already exists.")
        response = input("Overwrite? (yes/no): ").strip().lower()
        if response != "yes":
            print("Cancelled.")
            return
    
    # Collect input
    daily_input = collect_daily_input(date)
    
    # Validate
    errors = daily_input.validate()
    if errors:
        print("\nValidation errors:")
        for error in errors:
            print(f"  - {error}")
        return
    
    # Save raw input
    db.save_daily_input(daily_input)
    
    # Create ledger and add entry
    ledger = PCLLLedger(profile=profile, database=db)
    entry = ledger.add_daily_entry(daily_input)
    
    # Update profile
    db.increment_days_logged("default")
    
    # Display result
    print()
    print_separator()
    print("ENTRY RECORDED")
    print_separator()
    print(f"  Date:            {entry.date}")
    print(f"  Opening Balance: {entry.opening_balance:.0f} CU")
    print(f"  Withdrawals:     -{entry.total_withdrawals:.0f} CU")
    print(f"  Deposits:        +{entry.total_deposits:.0f} CU")
    print(f"  Closing Balance: {format_balance_display(entry.closing_balance)}")
    print(f"  Confidence:      {entry.confidence}%")
    print_separator()
    
    # Generate insight
    insight_gen = InsightGenerator()
    recent = ledger.get_recent_entries(7)
    trends = ledger.calculate_weekly_trends()
    insight = insight_gen.generate_daily_insight(entry, recent[:-1] if recent else [], trends)
    
    if insight:
        print()
        print("INSIGHT:")
        print(f"  {format_insight_display(insight)}")
        print()
    
    # Show footer disclaimer
    print()
    print(Disclaimers.FOOTER_DISCLAIMER)


def cmd_status(args, db: PCLLDatabase):
    """Handle 'status' command - show current balance."""
    ledger = PCLLLedger(database=db)
    
    recent = ledger.get_recent_entries(1)
    if not recent:
        print("\nNo entries found. Use 'pcll log' to record your first day.")
        return
    
    entry = recent[0]
    
    print()
    print_header("CURRENT STATUS")
    print()
    print(f"  Last Entry:      {entry.date}")
    print(f"  Balance:         {format_balance_display(entry.closing_balance)}")
    print(f"  State:           {entry.cognitive_state.value}")
    print()
    
    # Show streak info
    streaks = ledger.get_streak_info()
    if streaks['positive_streak'] > 0:
        print(f"  Positive Streak: {streaks['positive_streak']} days")
    if streaks['negative_streak'] > 0:
        print(f"  Deficit Streak:  {streaks['negative_streak']} days")
    
    # Show accumulated debt
    debt = ledger.get_accumulated_debt()
    if debt > 0:
        print(f"  Current Debt:    {debt:.0f} CU")
    
    print()
    print(Disclaimers.FOOTER_DISCLAIMER)


def cmd_week(args, db: PCLLDatabase):
    """Handle 'week' command - show weekly summary."""
    ledger = PCLLLedger(database=db)
    
    trends = ledger.calculate_weekly_trends()
    if trends is None:
        print(f"\nInsufficient data. Need at least {AppSettings.MIN_DAYS_FOR_TRENDS} days.")
        return
    
    print()
    print_header("WEEKLY SUMMARY")
    print()
    print(format_trend_display(trends))
    print()
    
    # Generate weekly insights
    entries = ledger.get_recent_entries(7)
    insight_gen = InsightGenerator()
    insights = insight_gen.generate_weekly_insights(entries, trends)
    
    if insights:
        print("INSIGHTS:")
        for insight in insights:
            print(f"  {format_insight_display(insight)}")
        print()
    
    print(Disclaimers.FOOTER_DISCLAIMER)


def cmd_history(args, db: PCLLDatabase):
    """Handle 'history' command - show recent entries."""
    ledger = PCLLLedger(database=db)
    
    days = args.days if args.days else 7
    entries = ledger.get_recent_entries(days)
    
    if not entries:
        print("\nNo entries found.")
        return
    
    print()
    print_header(f"LAST {len(entries)} DAYS")
    print()
    print(f"{'Date':<12} {'Open':>8} {'Close':>8} {'With':>8} {'Dep':>6} {'State':<12}")
    print("-" * 60)
    
    for entry in entries:
        state_short = entry.cognitive_state.value[:10]
        print(
            f"{entry.date:<12} "
            f"{entry.opening_balance:>7.0f} "
            f"{entry.closing_balance:>8.0f} "
            f"{entry.total_withdrawals:>8.0f} "
            f"{entry.total_deposits:>6.0f} "
            f"{state_short:<12}"
        )
    
    print("-" * 60)
    
    # Summary
    stats = ledger.get_summary_stats(days)
    print(f"\nAvg Balance: {stats['avg_balance']:.0f} CU | "
          f"Deficit Days: {stats['deficit_days']} | "
          f"Range: {stats['min_balance']:.0f} to {stats['max_balance']:.0f} CU")
    print()
    print(Disclaimers.FOOTER_DISCLAIMER)


def cmd_export(args, db: PCLLDatabase):
    """Handle 'export' command - export data to JSON."""
    import json
    
    print(Disclaimers.EXPORT_WARNING)
    response = input("\nContinue with export? (yes/no): ").strip().lower()
    if response != "yes":
        print("Export cancelled.")
        return
    
    data = db.export_all_data()
    
    filename = args.output if args.output else f"pcll_export_{datetime.now().strftime('%Y%m%d')}.json"
    
    with open(filename, 'w') as f:
        json.dump(data, f, indent=2)
    
    print(f"\nData exported to: {filename}")
    print(f"Entries exported: {len(data['ledger_entries'])}")


def cmd_disclaimer(args, db: PCLLDatabase):
    """Handle 'disclaimer' command - show full disclaimer."""
    show_disclaimer()


def show_disclaimer():
    """Display the full disclaimer."""
    print(Disclaimers.PRIMARY_DISCLAIMER)


def cmd_help_resources(args, db: PCLLDatabase):
    """Handle 'help-resources' command - show crisis resources."""
    print(Disclaimers.CRISIS_RESOURCES)


# =============================================================================
# MAIN CLI
# =============================================================================

def create_parser() -> argparse.ArgumentParser:
    """Create the argument parser."""
    parser = argparse.ArgumentParser(
        prog="pcll",
        description="Personal Cognitive Load Ledger - Track cognitive resource allocation",
        epilog="Note: PCLL is a productivity tool, not a medical or mental health application."
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Available commands")
    
    # log command
    log_parser = subparsers.add_parser("log", help="Log today's cognitive load")
    log_parser.add_argument(
        "--date", "-d",
        help="Date to log (YYYY-MM-DD format, defaults to today)"
    )
    
    # status command
    subparsers.add_parser("status", help="View current cognitive balance")
    
    # week command
    subparsers.add_parser("week", help="View weekly summary and trends")
    
    # history command
    history_parser = subparsers.add_parser("history", help="View recent entries")
    history_parser.add_argument(
        "--days", "-n",
        type=int,
        default=7,
        help="Number of days to show (default: 7)"
    )
    
    # export command
    export_parser = subparsers.add_parser("export", help="Export data to JSON")
    export_parser.add_argument(
        "--output", "-o",
        help="Output filename (default: pcll_export_DATE.json)"
    )
    
    # disclaimer command
    subparsers.add_parser("disclaimer", help="Show full disclaimer")
    
    # help-resources command
    subparsers.add_parser("help-resources", help="Show mental health resources")
    
    return parser


def main():
    """Main entry point for CLI."""
    parser = create_parser()
    args = parser.parse_args()
    
    if args.command is None:
        parser.print_help()
        return
    
    # Initialize database
    db = create_database()
    
    # Route to command handler
    commands = {
        "log": cmd_log,
        "status": cmd_status,
        "week": cmd_week,
        "history": cmd_history,
        "export": cmd_export,
        "disclaimer": cmd_disclaimer,
        "help-resources": cmd_help_resources,
    }
    
    handler = commands.get(args.command)
    if handler:
        try:
            handler(args, db)
        except KeyboardInterrupt:
            print("\n\nCancelled.")
            sys.exit(0)
        except Exception as e:
            print(f"\nError: {e}")
            sys.exit(1)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()
