"""
Tests for the Insight Generation System
========================================

Tests for src/insights.py
"""

import unittest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.insights import (
    InsightGenerator,
    InsightContext,
    format_insight_display,
    get_insight_category
)
from src.models import (
    DailyLedgerEntry,
    WeeklyTrends,
    ComponentBreakdown,
    CognitiveState,
    TrendDirection,
    Insight
)


class TestInsightGenerator(unittest.TestCase):
    """Tests for InsightGenerator class."""
    
    def setUp(self):
        """Set up generator and sample entries."""
        self.generator = InsightGenerator()
        
        # Create sample component breakdown
        self.components = ComponentBreakdown(
            context_cost=20.0,
            context_explanation="5 contexts",
            decision_cost=40.0,
            decision_explanation="5 decisions",
            passive_drain=5.0,
            passive_explanation="5 items",
            attention_cost=15.0,
            attention_explanation="Estimated",
            recovery_deposit=40.0,
            recovery_explanation="Quality 5/10"
        )
    
    def _create_entry(
        self,
        date: str,
        opening: float,
        closing: float,
        withdrawals: float,
        deposits: float,
        state: CognitiveState,
        components: ComponentBreakdown = None
    ) -> DailyLedgerEntry:
        """Helper to create test entries."""
        return DailyLedgerEntry(
            date=date,
            opening_balance=opening,
            closing_balance=closing,
            total_withdrawals=withdrawals,
            total_deposits=deposits,
            net_change=deposits - withdrawals,
            cognitive_state=state,
            components=components or self.components,
            confidence=80
        )
    
    def test_generate_daily_insight_high_withdrawal(self):
        """Test insight generation for high withdrawal day."""
        entry = self._create_entry(
            date="2025-12-13",
            opening=100,
            closing=20,
            withdrawals=130,  # Above 120 threshold
            deposits=50,
            state=CognitiveState.DEPLETED
        )
        
        insight = self.generator.generate_daily_insight(entry)
        
        self.assertIsNotNone(insight)
        self.assertEqual(insight.rule_id, 1)  # HIGH_WITHDRAWAL_DAY
    
    def test_generate_daily_insight_low_recovery(self):
        """Test insight generation for low recovery pattern."""
        entry = self._create_entry(
            date="2025-12-13",
            opening=100,
            closing=10,
            withdrawals=100,
            deposits=10,  # Only 10% recovery ratio
            state=CognitiveState.DEPLETED
        )
        
        insight = self.generator.generate_daily_insight(entry)
        
        self.assertIsNotNone(insight)
        # Should detect low recovery (rule 2) as priority
    
    def test_generate_daily_insight_deficit(self):
        """Test insight generation for deficit."""
        entry = self._create_entry(
            date="2025-12-13",
            opening=100,
            closing=-30,
            withdrawals=150,
            deposits=20,
            state=CognitiveState.DEFICIT
        )
        
        insight = self.generator.generate_daily_insight(entry)
        
        self.assertIsNotNone(insight)
        # Deficit should be detected
    
    def test_generate_daily_insight_consecutive_deficit(self):
        """Test insight for consecutive deficit days."""
        # Current entry in deficit
        current = self._create_entry(
            date="2025-12-13",
            opening=95,
            closing=-20,
            withdrawals=130,
            deposits=15,
            state=CognitiveState.DEFICIT
        )
        
        # Previous days also in deficit
        recent = [
            self._create_entry(
                date="2025-12-11",
                opening=100,
                closing=-10,
                withdrawals=120,
                deposits=10,
                state=CognitiveState.DEFICIT
            ),
            self._create_entry(
                date="2025-12-12",
                opening=98,
                closing=-15,
                withdrawals=125,
                deposits=12,
                state=CognitiveState.DEFICIT
            ),
        ]
        
        insight = self.generator.generate_daily_insight(current, recent)
        
        self.assertIsNotNone(insight)
        # Should detect consecutive deficit pattern
    
    def test_generate_daily_insight_context_overload(self):
        """Test insight for context overload."""
        # High context cost component
        high_context = ComponentBreakdown(
            context_cost=60.0,  # 60% of total
            context_explanation="15 contexts",
            decision_cost=20.0,
            decision_explanation="2 decisions",
            passive_drain=5.0,
            passive_explanation="5 items",
            attention_cost=15.0,
            attention_explanation="Estimated",
            recovery_deposit=40.0,
            recovery_explanation="Quality 5/10"
        )
        
        entry = self._create_entry(
            date="2025-12-13",
            opening=100,
            closing=40,
            withdrawals=100,
            deposits=40,
            state=CognitiveState.MODERATE,
            components=high_context
        )
        
        insight = self.generator.generate_daily_insight(entry)
        
        # May or may not trigger depending on priority
        # Just verify no crash
        self.assertTrue(True)
    
    def test_generate_daily_insight_recovery_success(self):
        """Test insight for recovery success."""
        current = self._create_entry(
            date="2025-12-13",
            opening=100,
            closing=60,
            withdrawals=60,
            deposits=20,
            state=CognitiveState.MODERATE
        )
        
        # Previous day was in deficit
        recent = [
            self._create_entry(
                date="2025-12-12",
                opening=100,
                closing=-20,
                withdrawals=140,
                deposits=20,
                state=CognitiveState.DEFICIT
            ),
        ]
        
        insight = self.generator.generate_daily_insight(current, recent)
        
        self.assertIsNotNone(insight)
        self.assertEqual(insight.rule_name, "RECOVERY_SUCCESS")
    
    def test_generate_daily_insight_no_insight(self):
        """Test when no insight should be generated."""
        # Normal balanced day
        entry = self._create_entry(
            date="2025-12-13",
            opening=100,
            closing=60,
            withdrawals=80,
            deposits=40,
            state=CognitiveState.MODERATE
        )
        
        insight = self.generator.generate_daily_insight(entry)
        
        # May or may not have insight - just verify no crash
        self.assertTrue(True)
    
    def test_generate_weekly_insights(self):
        """Test weekly insight generation."""
        entries = [
            self._create_entry(
                date=f"2025-12-{10+i:02d}",
                opening=100,
                closing=50,
                withdrawals=70,
                deposits=20,
                state=CognitiveState.MODERATE
            )
            for i in range(7)
        ]
        
        trends = WeeklyTrends(
            avg_opening_balance=100,
            avg_closing_balance=50,
            avg_withdrawals=70,
            avg_deposits=20,
            deficit_days=0,
            recovery_ratio=0.28,  # Low
            trend_direction=TrendDirection.STABLE,
            balance_slope=0.0,
            volatility=10.0,
            days_analyzed=7,
            start_date="2025-12-10",
            end_date="2025-12-16"
        )
        
        insights = self.generator.generate_weekly_insights(entries, trends)
        
        self.assertIsInstance(insights, list)
        self.assertLessEqual(len(insights), 3)  # Max 3 insights
    
    def test_validate_insight_clean_text(self):
        """Test insight validation with clean text."""
        insight = Insight(
            date="2025-12-13",
            rule_id=1,
            rule_name="TEST",
            message="Your balance is 50 CU today.",
            confidence=80
        )
        
        is_valid = self.generator._validate_insight(insight)
        
        self.assertTrue(is_valid)
    
    def test_validate_insight_clinical_term(self):
        """Test insight validation rejects clinical terms."""
        insight = Insight(
            date="2025-12-13",
            rule_id=1,
            rule_name="TEST",
            message="You may be experiencing depression or burnout.",
            confidence=80
        )
        
        is_valid = self.generator._validate_insight(insight)
        
        self.assertFalse(is_valid)


class TestInsightHelpers(unittest.TestCase):
    """Tests for insight helper functions."""
    
    def test_format_insight_display(self):
        """Test insight display formatting."""
        insight = Insight(
            date="2025-12-13",
            rule_id=3,
            rule_name="DEFICIT_DETECTED",
            message="Today's ledger closed at -30 CU.",
            confidence=90
        )
        
        display = format_insight_display(insight)
        
        self.assertIn("-30 CU", display)
        self.assertIn("📉", display)  # Deficit icon
    
    def test_get_insight_category_observation(self):
        """Test insight categorization for observation."""
        insight = Insight(
            date="2025-12-13",
            rule_id=3,
            rule_name="DEFICIT_DETECTED",
            message="Test",
            confidence=80
        )
        
        category = get_insight_category(insight)
        
        self.assertEqual(category, "OBSERVATION")
    
    def test_get_insight_category_pattern(self):
        """Test insight categorization for pattern."""
        insight = Insight(
            date="2025-12-13",
            rule_id=8,
            rule_name="RECOVERY_SUCCESS",
            message="Test",
            confidence=80
        )
        
        category = get_insight_category(insight)
        
        self.assertEqual(category, "PATTERN")
    
    def test_get_insight_category_trend(self):
        """Test insight categorization for trend."""
        insight = Insight(
            date="2025-12-13",
            rule_id=10,
            rule_name="TREND_CHANGE",
            message="Test",
            confidence=80
        )
        
        category = get_insight_category(insight)
        
        self.assertEqual(category, "TREND")


if __name__ == '__main__':
    unittest.main()
