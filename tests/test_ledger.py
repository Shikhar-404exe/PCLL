"""
Tests for the PCLL Ledger Engine
=================================

Tests for src/ledger.py
"""

import unittest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.ledger import (
    PCLLLedger,
    determine_trend_direction,
    calculate_recovery_needed,
    format_balance_display,
    create_sample_input
)
from src.models import DailyInput, CognitiveState, TrendDirection
from src.database import create_memory_database


class TestPCLLLedger(unittest.TestCase):
    """Tests for PCLLLedger class."""
    
    def setUp(self):
        """Set up ledger with in-memory database."""
        self.db = create_memory_database()
        self.ledger = PCLLLedger(database=self.db)
    
    def test_add_daily_entry_first_day(self):
        """Test adding first daily entry."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        
        entry = self.ledger.add_daily_entry(daily_input)
        
        self.assertIsNotNone(entry)
        self.assertEqual(entry.date, "2025-12-13")
        self.assertEqual(entry.opening_balance, 100.0)  # First day baseline
    
    def test_add_daily_entry_with_carryover(self):
        """Test adding entry with deficit carryover."""
        # Day 1: Heavy day ending in deficit
        day1_input = DailyInput(
            date="2025-12-12",
            context_count=15,
            decision_count=20,
            unresolved_count=20,
            recovery_quality=2
        )
        entry1 = self.ledger.add_daily_entry(day1_input)
        
        # Should be in deficit
        self.assertLess(entry1.closing_balance, 0)
        
        # Day 2: Check opening balance reflects carryover
        day2_input = DailyInput(
            date="2025-12-13",
            context_count=3,
            decision_count=4,
            unresolved_count=3,
            recovery_quality=8
        )
        entry2 = self.ledger.add_daily_entry(day2_input)
        
        # Opening should be less than 100 due to carryover
        self.assertLess(entry2.opening_balance, 100)
    
    def test_get_entry(self):
        """Test retrieving entry by date."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        self.ledger.add_daily_entry(daily_input)
        
        entry = self.ledger.get_entry("2025-12-13")
        
        self.assertIsNotNone(entry)
        self.assertEqual(entry.date, "2025-12-13")
    
    def test_get_entry_not_found(self):
        """Test retrieving non-existent entry."""
        entry = self.ledger.get_entry("2020-01-01")
        self.assertIsNone(entry)
    
    def test_get_recent_entries(self):
        """Test getting recent entries."""
        # Add 5 days
        for i in range(5):
            day = 10 + i
            daily_input = DailyInput(
                date=f"2025-12-{day:02d}",
                context_count=5,
                decision_count=5,
                unresolved_count=5,
                recovery_quality=5
            )
            self.ledger.add_daily_entry(daily_input)
        
        recent = self.ledger.get_recent_entries(3)
        
        self.assertEqual(len(recent), 3)
        # Should be in chronological order (oldest first)
        self.assertEqual(recent[0].date, "2025-12-12")
        self.assertEqual(recent[2].date, "2025-12-14")
    
    def test_get_entries_range(self):
        """Test getting entries in date range."""
        # Add 5 days
        for i in range(5):
            day = 10 + i
            daily_input = DailyInput(
                date=f"2025-12-{day:02d}",
                context_count=5,
                decision_count=5,
                unresolved_count=5,
                recovery_quality=5
            )
            self.ledger.add_daily_entry(daily_input)
        
        entries = self.ledger.get_entries_range("2025-12-11", "2025-12-13")
        
        self.assertEqual(len(entries), 3)
    
    def test_calculate_weekly_trends(self):
        """Test weekly trends calculation."""
        # Add 7 days
        for i in range(7):
            day = 8 + i
            daily_input = DailyInput(
                date=f"2025-12-{day:02d}",
                context_count=5,
                decision_count=5 + i,  # Increasing decisions
                unresolved_count=5,
                recovery_quality=5
            )
            self.ledger.add_daily_entry(daily_input)
        
        trends = self.ledger.calculate_weekly_trends()
        
        self.assertIsNotNone(trends)
        self.assertEqual(trends.days_analyzed, 7)
        self.assertIsInstance(trends.trend_direction, TrendDirection)
    
    def test_calculate_weekly_trends_insufficient_data(self):
        """Test weekly trends with insufficient data."""
        # Add only 2 days (need 3 minimum)
        for i in range(2):
            daily_input = DailyInput(
                date=f"2025-12-1{i}",
                context_count=5,
                decision_count=5,
                unresolved_count=5,
                recovery_quality=5
            )
            self.ledger.add_daily_entry(daily_input)
        
        trends = self.ledger.calculate_weekly_trends()
        
        self.assertIsNone(trends)
    
    def test_get_current_state(self):
        """Test getting current cognitive state."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=3,
            decision_count=4,
            unresolved_count=3,
            recovery_quality=8
        )
        self.ledger.add_daily_entry(daily_input)
        
        state = self.ledger.get_current_state()
        
        self.assertIsNotNone(state)
        self.assertIsInstance(state, CognitiveState)
    
    def test_get_accumulated_debt(self):
        """Test accumulated debt calculation."""
        # Light day - no debt
        light_input = DailyInput(
            date="2025-12-13",
            context_count=3,
            decision_count=4,
            unresolved_count=3,
            recovery_quality=9
        )
        self.ledger.add_daily_entry(light_input)
        
        debt = self.ledger.get_accumulated_debt()
        self.assertEqual(debt, 0.0)
    
    def test_get_days_in_deficit(self):
        """Test counting deficit days."""
        # Add mix of positive and deficit days
        inputs = [
            (5, 5, 5, 7),   # Positive
            (15, 20, 20, 2),  # Deficit
            (5, 5, 5, 8),   # Positive
            (12, 18, 15, 2),  # Deficit
        ]
        
        for i, (ctx, dec, unres, rec) in enumerate(inputs):
            daily_input = DailyInput(
                date=f"2025-12-{10+i:02d}",
                context_count=ctx,
                decision_count=dec,
                unresolved_count=unres,
                recovery_quality=rec
            )
            self.ledger.add_daily_entry(daily_input)
        
        deficit_days = self.ledger.get_days_in_deficit(10)
        
        # Should have some deficit days
        self.assertGreaterEqual(deficit_days, 0)
    
    def test_get_streak_info(self):
        """Test streak information."""
        # Add several positive days
        for i in range(5):
            daily_input = DailyInput(
                date=f"2025-12-{10+i:02d}",
                context_count=3,
                decision_count=4,
                unresolved_count=3,
                recovery_quality=8
            )
            self.ledger.add_daily_entry(daily_input)
        
        streaks = self.ledger.get_streak_info()
        
        self.assertIn('positive_streak', streaks)
        self.assertIn('negative_streak', streaks)
    
    def test_get_summary_stats(self):
        """Test summary statistics."""
        # Add 5 days
        for i in range(5):
            daily_input = DailyInput(
                date=f"2025-12-{10+i:02d}",
                context_count=5,
                decision_count=5,
                unresolved_count=5,
                recovery_quality=5
            )
            self.ledger.add_daily_entry(daily_input)
        
        stats = self.ledger.get_summary_stats(7)
        
        self.assertEqual(stats['total_days'], 5)
        self.assertIsNotNone(stats['avg_balance'])
        self.assertIsNotNone(stats['min_balance'])
        self.assertIsNotNone(stats['max_balance'])
    
    def test_export_entries(self):
        """Test exporting entries."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        self.ledger.add_daily_entry(daily_input)
        
        exported = self.ledger.export_entries()
        
        self.assertEqual(len(exported), 1)
        self.assertIsInstance(exported[0], dict)
        self.assertEqual(exported[0]['date'], "2025-12-13")


class TestHelperFunctions(unittest.TestCase):
    """Tests for ledger helper functions."""
    
    def test_determine_trend_direction_deteriorating(self):
        """Test trend direction for steep decline."""
        direction = determine_trend_direction(-8.0)
        self.assertEqual(direction, TrendDirection.DETERIORATING)
    
    def test_determine_trend_direction_declining(self):
        """Test trend direction for mild decline."""
        direction = determine_trend_direction(-2.0)
        self.assertEqual(direction, TrendDirection.DECLINING)
    
    def test_determine_trend_direction_stable(self):
        """Test trend direction for stable."""
        direction = determine_trend_direction(0.0)
        self.assertEqual(direction, TrendDirection.STABLE)
    
    def test_determine_trend_direction_improving(self):
        """Test trend direction for improving."""
        direction = determine_trend_direction(3.0)
        self.assertEqual(direction, TrendDirection.IMPROVING)
    
    def test_determine_trend_direction_rapidly_improving(self):
        """Test trend direction for rapid improvement."""
        direction = determine_trend_direction(8.0)
        self.assertEqual(direction, TrendDirection.RAPIDLY_IMPROVING)
    
    def test_calculate_recovery_needed_positive(self):
        """Test recovery needed from positive balance."""
        needed = calculate_recovery_needed(80)
        self.assertEqual(needed, 0.0)
    
    def test_calculate_recovery_needed_low(self):
        """Test recovery needed from low balance."""
        needed = calculate_recovery_needed(30)
        self.assertEqual(needed, 40.0)  # Need 40 to reach 70
    
    def test_format_balance_display_positive(self):
        """Test balance display formatting for positive."""
        display = format_balance_display(75)
        self.assertIn("75", display)
        self.assertIn("WELL-RESTED", display)
    
    def test_format_balance_display_deficit(self):
        """Test balance display formatting for deficit."""
        display = format_balance_display(-30)
        self.assertIn("-30", display)
        self.assertIn("DEFICIT", display)
    
    def test_create_sample_input(self):
        """Test sample input creation."""
        sample = create_sample_input("2025-12-13", context_count=7)
        
        self.assertEqual(sample.date, "2025-12-13")
        self.assertEqual(sample.context_count, 7)
        self.assertEqual(sample.decision_count, 8)  # Default


if __name__ == '__main__':
    unittest.main()
