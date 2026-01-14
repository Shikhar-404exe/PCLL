"""
PCLL Ledger Engine
===================

Core ledger operations implementing the double-entry cognitive accounting system.
Implements Section 7 of PCLL_System_Definition.md.

Features:
- Daily balance tracking with carryover
- Weekly trend analysis
- Historical data management
- State classification
"""

from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
import statistics

from .models import (
    DailyInput,
    DailyLedgerEntry,
    WeeklyTrends,
    CognitiveState,
    TrendDirection,
    ComponentBreakdown,
    UserProfile
)
from .config import CUConstants, AppSettings
from .calculator import (
    CognitiveLoadCalculator,
    calculate_opening_balance,
    calculate_carryover,
    linear_trend,
    calculate_volatility
)


class PCLLLedger:
    """
    Main ledger class for tracking cognitive load over time.
    Implements the core accounting metaphor with balance tracking,
    carryover mechanics, and trend analysis.
    """
    
    def __init__(
        self, 
        profile: Optional[UserProfile] = None,
        database=None
    ):
        """
        Initialize the ledger.
        
        Args:
            profile: Optional user profile for personalized coefficients
            database: Optional database instance for persistence
        """
        self.profile = profile
        self.database = database
        self.calculator = CognitiveLoadCalculator(profile)
        
        # In-memory storage if no database
        self._entries: Dict[str, DailyLedgerEntry] = {}
    
    def add_daily_entry(
        self, 
        daily_input: DailyInput,
        timestamp: Optional[datetime] = None
    ) -> DailyLedgerEntry:
        """
        Process daily input and add a new ledger entry.
        
        This is the main entry point for recording a day's cognitive activity.
        It calculates opening balance (with carryover), processes withdrawals
        and deposits, and stores the resulting entry.
        
        Args:
            daily_input: User's daily input responses
            timestamp: Optional timestamp (defaults to now)
            
        Returns:
            The created DailyLedgerEntry
        """
        if timestamp is None:
            timestamp = datetime.now()
        
        # Validate input
        errors = daily_input.validate()
        if errors:
            raise ValueError(f"Invalid daily input: {', '.join(errors)}")
        
        # Get previous day's closing balance for carryover
        previous_entry = self.get_previous_entry(daily_input.date)
        if previous_entry:
            opening_balance = calculate_opening_balance(previous_entry.closing_balance)
        else:
            opening_balance = calculate_opening_balance(None)
        
        # Calculate the full daily balance
        entry = self.calculator.calculate_daily_balance(
            daily_input=daily_input,
            opening_balance=opening_balance,
            timestamp=timestamp
        )
        
        # Store the entry
        self._store_entry(entry)
        
        return entry
    
    def get_entry(self, date: str) -> Optional[DailyLedgerEntry]:
        """
        Retrieve a ledger entry for a specific date.
        
        Args:
            date: Date string in ISO format (YYYY-MM-DD)
            
        Returns:
            DailyLedgerEntry if found, None otherwise
        """
        # Try database first
        if self.database:
            return self.database.get_entry(date)
        
        # Fall back to in-memory
        return self._entries.get(date)
    
    def get_previous_entry(self, current_date: str) -> Optional[DailyLedgerEntry]:
        """
        Get the entry from the day before the given date.
        
        Args:
            current_date: Date string in ISO format
            
        Returns:
            Previous day's entry if exists, None otherwise
        """
        try:
            date_obj = datetime.strptime(current_date, "%Y-%m-%d")
            previous_date = (date_obj - timedelta(days=1)).strftime("%Y-%m-%d")
            return self.get_entry(previous_date)
        except ValueError:
            return None
    
    def get_entries_range(
        self, 
        start_date: str, 
        end_date: str
    ) -> List[DailyLedgerEntry]:
        """
        Get all entries within a date range (inclusive).
        
        Args:
            start_date: Start date (YYYY-MM-DD)
            end_date: End date (YYYY-MM-DD)
            
        Returns:
            List of entries sorted by date
        """
        if self.database:
            return self.database.get_entries_range(start_date, end_date)
        
        # In-memory filtering
        entries = []
        for date_str, entry in self._entries.items():
            if start_date <= date_str <= end_date:
                entries.append(entry)
        
        return sorted(entries, key=lambda e: e.date)
    
    def get_recent_entries(self, days: int = 7) -> List[DailyLedgerEntry]:
        """
        Get the most recent N days of entries.
        
        Args:
            days: Number of days to retrieve
            
        Returns:
            List of entries sorted by date (oldest first)
        """
        if self.database:
            return self.database.get_recent_entries(days)
        
        # In-memory: sort all entries and take last N
        all_entries = sorted(
            self._entries.values(), 
            key=lambda e: e.date
        )
        return all_entries[-days:] if len(all_entries) > days else all_entries
    
    def calculate_weekly_trends(
        self, 
        end_date: Optional[str] = None,
        days: int = 7
    ) -> Optional[WeeklyTrends]:
        """
        Calculate aggregated metrics for trend analysis.
        Implements Section 7.1: Rolling Weekly Trend.
        
        Args:
            end_date: End date for the period (defaults to today)
            days: Number of days to analyze (default 7)
            
        Returns:
            WeeklyTrends object or None if insufficient data
        """
        if end_date is None:
            end_date = datetime.now().strftime("%Y-%m-%d")
        
        # Calculate start date
        end_dt = datetime.strptime(end_date, "%Y-%m-%d")
        start_dt = end_dt - timedelta(days=days - 1)
        start_date = start_dt.strftime("%Y-%m-%d")
        
        # Get entries for the period
        entries = self.get_entries_range(start_date, end_date)
        
        if len(entries) < AppSettings.MIN_DAYS_FOR_TRENDS:
            return None
        
        # Extract values for calculations
        opening_balances = [e.opening_balance for e in entries]
        closing_balances = [e.closing_balance for e in entries]
        withdrawals = [e.total_withdrawals for e in entries]
        deposits = [e.total_deposits for e in entries]
        
        # Calculate averages
        avg_opening = statistics.mean(opening_balances)
        avg_closing = statistics.mean(closing_balances)
        avg_withdrawals = statistics.mean(withdrawals)
        avg_deposits = statistics.mean(deposits)
        
        # Count deficit days
        deficit_days = sum(1 for e in entries if e.closing_balance < 0)
        
        # Recovery ratio (deposits / withdrawals)
        total_withdrawals = sum(withdrawals)
        total_deposits = sum(deposits)
        recovery_ratio = (
            total_deposits / total_withdrawals 
            if total_withdrawals > 0 else 1.0
        )
        
        # Trend analysis (linear regression on closing balances)
        balance_slope = linear_trend(closing_balances)
        trend_direction = determine_trend_direction(balance_slope)
        
        # Volatility (standard deviation of closing balances)
        volatility = calculate_volatility(closing_balances)
        
        return WeeklyTrends(
            avg_opening_balance=round(avg_opening, 1),
            avg_closing_balance=round(avg_closing, 1),
            avg_withdrawals=round(avg_withdrawals, 1),
            avg_deposits=round(avg_deposits, 1),
            deficit_days=deficit_days,
            recovery_ratio=round(recovery_ratio, 2),
            trend_direction=trend_direction,
            balance_slope=round(balance_slope, 2),
            volatility=round(volatility, 1),
            days_analyzed=len(entries),
            start_date=start_date,
            end_date=end_date
        )
    
    def get_current_state(self) -> Optional[CognitiveState]:
        """
        Get the most recent cognitive state.
        
        Returns:
            Current CognitiveState or None if no entries
        """
        recent = self.get_recent_entries(1)
        if recent:
            return recent[0].cognitive_state
        return None
    
    def get_current_balance(self) -> Optional[float]:
        """
        Get the most recent closing balance.
        
        Returns:
            Current balance in CU or None if no entries
        """
        recent = self.get_recent_entries(1)
        if recent:
            return recent[0].closing_balance
        return None
    
    def get_accumulated_debt(self) -> float:
        """
        Calculate current accumulated cognitive debt.
        
        Returns:
            Debt amount (positive value) or 0 if no debt
        """
        balance = self.get_current_balance()
        if balance is None or balance >= 0:
            return 0.0
        return abs(balance)
    
    def get_days_in_deficit(self, lookback: int = 30) -> int:
        """
        Count number of days ending in deficit within lookback period.
        
        Args:
            lookback: Number of days to analyze
            
        Returns:
            Count of deficit days
        """
        entries = self.get_recent_entries(lookback)
        return sum(1 for e in entries if e.closing_balance < 0)
    
    def get_streak_info(self) -> Dict[str, int]:
        """
        Get current streak information (consecutive days of same state type).
        
        Returns:
            Dict with 'positive_streak' and 'negative_streak' counts
        """
        entries = self.get_recent_entries(30)
        if not entries:
            return {'positive_streak': 0, 'negative_streak': 0}
        
        # Reverse to check from most recent
        entries = list(reversed(entries))
        
        positive_streak = 0
        negative_streak = 0
        
        # Count current positive streak
        for entry in entries:
            if entry.closing_balance >= 30:  # Above "depleted" threshold
                positive_streak += 1
            else:
                break
        
        # Count current negative streak (if no positive streak)
        if positive_streak == 0:
            for entry in entries:
                if entry.closing_balance < 0:
                    negative_streak += 1
                else:
                    break
        
        return {
            'positive_streak': positive_streak,
            'negative_streak': negative_streak
        }
    
    def _store_entry(self, entry: DailyLedgerEntry) -> None:
        """
        Store an entry to persistence layer.
        
        Args:
            entry: The entry to store
        """
        if self.database:
            self.database.save_entry(entry)
        else:
            self._entries[entry.date] = entry
    
    def get_summary_stats(self, days: int = 30) -> Dict[str, Any]:
        """
        Get summary statistics for a period.
        
        Args:
            days: Number of days to analyze
            
        Returns:
            Dictionary of summary statistics
        """
        entries = self.get_recent_entries(days)
        
        if not entries:
            return {
                'total_days': 0,
                'avg_balance': None,
                'min_balance': None,
                'max_balance': None,
                'deficit_days': 0,
                'avg_withdrawals': None,
                'avg_deposits': None
            }
        
        closing_balances = [e.closing_balance for e in entries]
        withdrawals = [e.total_withdrawals for e in entries]
        deposits = [e.total_deposits for e in entries]
        
        return {
            'total_days': len(entries),
            'avg_balance': round(statistics.mean(closing_balances), 1),
            'min_balance': round(min(closing_balances), 1),
            'max_balance': round(max(closing_balances), 1),
            'deficit_days': sum(1 for b in closing_balances if b < 0),
            'avg_withdrawals': round(statistics.mean(withdrawals), 1),
            'avg_deposits': round(statistics.mean(deposits), 1)
        }
    
    def clear_all_entries(self) -> None:
        """Clear all entries (use with caution)."""
        if self.database:
            self.database.clear_all()
        self._entries.clear()
    
    def export_entries(
        self, 
        start_date: Optional[str] = None,
        end_date: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """
        Export entries as list of dictionaries.
        
        Args:
            start_date: Optional start date filter
            end_date: Optional end date filter
            
        Returns:
            List of entry dictionaries
        """
        if start_date and end_date:
            entries = self.get_entries_range(start_date, end_date)
        else:
            entries = self.get_recent_entries(365)  # Last year
        
        return [entry.to_dict() for entry in entries]


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def determine_trend_direction(slope: float) -> TrendDirection:
    """
    Map balance slope to trend direction.
    Based on Section 7.1 trend thresholds.
    
    Args:
        slope: Linear regression slope of closing balances
        
    Returns:
        TrendDirection enum value
    """
    if slope < CUConstants.TREND_DETERIORATING_THRESHOLD:
        return TrendDirection.DETERIORATING
    elif slope < CUConstants.TREND_DECLINING_THRESHOLD:
        return TrendDirection.DECLINING
    elif slope < CUConstants.TREND_IMPROVING_THRESHOLD:
        return TrendDirection.STABLE
    elif slope < CUConstants.TREND_RAPID_IMPROVING_THRESHOLD:
        return TrendDirection.IMPROVING
    else:
        return TrendDirection.RAPIDLY_IMPROVING


def calculate_recovery_needed(current_balance: float) -> float:
    """
    Calculate how much recovery is needed to reach baseline.
    
    Args:
        current_balance: Current balance in CU
        
    Returns:
        CU needed to reach 70 (moderate state threshold)
    """
    target = CUConstants.STATE_MODERATE_THRESHOLD
    if current_balance >= target:
        return 0.0
    return target - current_balance


def format_balance_display(balance: float) -> str:
    """
    Format balance for display with state indicator.
    
    Args:
        balance: Balance value in CU
        
    Returns:
        Formatted string like "42 CU (MODERATE)"
    """
    if balance < CUConstants.STATE_SEVERE_DEFICIT_THRESHOLD:
        state = "SEVERE DEFICIT ⚠️"
    elif balance < CUConstants.STATE_DEFICIT_THRESHOLD:
        state = "DEFICIT"
    elif balance < CUConstants.STATE_DEPLETED_THRESHOLD:
        state = "DEPLETED"
    elif balance < CUConstants.STATE_MODERATE_THRESHOLD:
        state = "MODERATE"
    else:
        state = "WELL-RESTED ✓"
    
    return f"{balance:.0f} CU ({state})"


def format_trend_display(trends: WeeklyTrends) -> str:
    """
    Format weekly trends for display.
    
    Args:
        trends: WeeklyTrends object
        
    Returns:
        Multi-line formatted string
    """
    lines = [
        f"📊 Weekly Summary ({trends.days_analyzed} days)",
        f"   Avg Closing Balance: {trends.avg_closing_balance:.0f} CU",
        f"   Deficit Days: {trends.deficit_days}",
        f"   Recovery Ratio: {trends.recovery_ratio:.0%}",
        f"   Trend: {trends.trend_direction.value.replace('_', ' ').title()}",
        f"   Volatility: {trends.volatility:.1f}"
    ]
    return "\n".join(lines)


# =============================================================================
# SIMULATION UTILITIES (for testing/demo)
# =============================================================================

def simulate_week(
    ledger: PCLLLedger,
    inputs: List[DailyInput]
) -> List[DailyLedgerEntry]:
    """
    Simulate a week of entries for testing.
    
    Args:
        ledger: PCLLLedger instance
        inputs: List of DailyInput objects (one per day)
        
    Returns:
        List of created entries
    """
    entries = []
    for daily_input in inputs:
        entry = ledger.add_daily_entry(daily_input)
        entries.append(entry)
    return entries


def create_sample_input(
    date: str,
    context_count: int = 5,
    decision_count: int = 8,
    unresolved_count: int = 6,
    recovery_quality: int = 5
) -> DailyInput:
    """
    Create a sample daily input for testing.
    
    Args:
        date: Date string (YYYY-MM-DD)
        context_count: Number of contexts
        decision_count: Number of decisions
        unresolved_count: Number of unresolved items
        recovery_quality: Recovery quality 1-10
        
    Returns:
        DailyInput object
    """
    return DailyInput(
        date=date,
        context_count=context_count,
        decision_count=decision_count,
        unresolved_count=unresolved_count,
        recovery_quality=recovery_quality
    )
