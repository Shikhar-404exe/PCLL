"""
Tests for Data Models
======================

Tests for src/models.py
"""

import unittest
import sys
import os
import json

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.models import (
    DailyInput,
    ComponentBreakdown,
    DailyLedgerEntry,
    WeeklyTrends,
    Insight,
    UserProfile,
    CognitiveState,
    TrendDirection
)


class TestDailyInput(unittest.TestCase):
    """Tests for DailyInput model."""
    
    def test_create_valid_input(self):
        """Test creating valid daily input."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        
        self.assertEqual(daily_input.date, "2025-12-13")
        self.assertEqual(daily_input.context_count, 5)
        self.assertIsNone(daily_input.subjective_depletion)
    
    def test_create_input_with_optional(self):
        """Test creating input with optional fields."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5,
            subjective_depletion=7,
            text_note="Busy day with meetings"
        )
        
        self.assertEqual(daily_input.subjective_depletion, 7)
        self.assertEqual(daily_input.text_note, "Busy day with meetings")
    
    def test_validate_valid_input(self):
        """Test validation of valid input."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        
        errors = daily_input.validate()
        
        self.assertEqual(errors, [])
    
    def test_validate_negative_context(self):
        """Test validation rejects negative context count."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=-1,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        
        errors = daily_input.validate()
        
        self.assertTrue(any("negative" in e.lower() for e in errors))
    
    def test_validate_invalid_recovery(self):
        """Test validation rejects out-of-range recovery."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=15  # Invalid: >10
        )
        
        errors = daily_input.validate()
        
        self.assertTrue(any("recovery" in e.lower() for e in errors))
    
    def test_validate_invalid_depletion(self):
        """Test validation rejects out-of-range depletion."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5,
            subjective_depletion=0  # Invalid: <1
        )
        
        errors = daily_input.validate()
        
        self.assertTrue(any("depletion" in e.lower() for e in errors))
    
    def test_to_dict(self):
        """Test conversion to dictionary."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        
        data = daily_input.to_dict()
        
        self.assertEqual(data['date'], "2025-12-13")
        self.assertEqual(data['context_count'], 5)
    
    def test_from_dict(self):
        """Test creation from dictionary."""
        data = {
            'date': "2025-12-13",
            'context_count': 5,
            'decision_count': 8,
            'unresolved_count': 6,
            'recovery_quality': 5,
            'subjective_depletion': None,
            'text_note': None
        }
        
        daily_input = DailyInput.from_dict(data)
        
        self.assertEqual(daily_input.date, "2025-12-13")
        self.assertEqual(daily_input.context_count, 5)


class TestComponentBreakdown(unittest.TestCase):
    """Tests for ComponentBreakdown model."""
    
    def test_create_breakdown(self):
        """Test creating component breakdown."""
        breakdown = ComponentBreakdown(
            context_cost=20.0,
            context_explanation="5 contexts × 2 CU",
            decision_cost=40.0,
            decision_explanation="5 decisions × 8 CU",
            passive_drain=5.0,
            passive_explanation="5 items",
            attention_cost=15.0,
            attention_explanation="Estimated",
            recovery_deposit=40.0,
            recovery_explanation="Quality 5/10"
        )
        
        self.assertEqual(breakdown.context_cost, 20.0)
        self.assertEqual(breakdown.decision_cost, 40.0)
    
    def test_to_dict(self):
        """Test conversion to dictionary."""
        breakdown = ComponentBreakdown(
            context_cost=20.0,
            context_explanation="Test"
        )
        
        data = breakdown.to_dict()
        
        self.assertEqual(data['context_cost'], 20.0)
        self.assertEqual(data['context_explanation'], "Test")
    
    def test_from_dict(self):
        """Test creation from dictionary."""
        data = {
            'context_cost': 20.0,
            'context_explanation': "Test",
            'decision_cost': 40.0,
            'decision_explanation': "Test",
            'passive_drain': 5.0,
            'passive_explanation': "Test",
            'attention_cost': 15.0,
            'attention_explanation': "Test",
            'recovery_deposit': 40.0,
            'recovery_explanation': "Test"
        }
        
        breakdown = ComponentBreakdown.from_dict(data)
        
        self.assertEqual(breakdown.context_cost, 20.0)
    
    def test_to_json(self):
        """Test JSON serialization."""
        breakdown = ComponentBreakdown(context_cost=20.0)
        
        json_str = breakdown.to_json()
        
        self.assertIsInstance(json_str, str)
        data = json.loads(json_str)
        self.assertEqual(data['context_cost'], 20.0)
    
    def test_from_json(self):
        """Test JSON deserialization."""
        json_str = '{"context_cost": 20.0, "context_explanation": "", "decision_cost": 0, "decision_explanation": "", "passive_drain": 0, "passive_explanation": "", "attention_cost": 0, "attention_explanation": "", "recovery_deposit": 0, "recovery_explanation": ""}'
        
        breakdown = ComponentBreakdown.from_json(json_str)
        
        self.assertEqual(breakdown.context_cost, 20.0)


class TestDailyLedgerEntry(unittest.TestCase):
    """Tests for DailyLedgerEntry model."""
    
    def test_create_entry(self):
        """Test creating ledger entry."""
        components = ComponentBreakdown()
        entry = DailyLedgerEntry(
            date="2025-12-13",
            opening_balance=100.0,
            closing_balance=50.0,
            total_withdrawals=80.0,
            total_deposits=30.0,
            net_change=-50.0,
            cognitive_state=CognitiveState.MODERATE,
            components=components,
            confidence=85
        )
        
        self.assertEqual(entry.date, "2025-12-13")
        self.assertEqual(entry.closing_balance, 50.0)
        self.assertEqual(entry.cognitive_state, CognitiveState.MODERATE)
    
    def test_to_dict(self):
        """Test conversion to dictionary."""
        components = ComponentBreakdown()
        entry = DailyLedgerEntry(
            date="2025-12-13",
            opening_balance=100.0,
            closing_balance=50.0,
            total_withdrawals=80.0,
            total_deposits=30.0,
            net_change=-50.0,
            cognitive_state=CognitiveState.MODERATE,
            components=components,
            confidence=85
        )
        
        data = entry.to_dict()
        
        self.assertEqual(data['date'], "2025-12-13")
        self.assertEqual(data['cognitive_state'], "MODERATE")
        self.assertIsInstance(data['components'], dict)
    
    def test_from_dict(self):
        """Test creation from dictionary."""
        data = {
            'date': "2025-12-13",
            'opening_balance': 100.0,
            'closing_balance': 50.0,
            'total_withdrawals': 80.0,
            'total_deposits': 30.0,
            'net_change': -50.0,
            'cognitive_state': "MODERATE",
            'components': {
                'context_cost': 0,
                'context_explanation': '',
                'decision_cost': 0,
                'decision_explanation': '',
                'passive_drain': 0,
                'passive_explanation': '',
                'attention_cost': 0,
                'attention_explanation': '',
                'recovery_deposit': 0,
                'recovery_explanation': ''
            },
            'confidence': 85,
            'created_at': "2025-12-13T10:00:00"
        }
        
        entry = DailyLedgerEntry.from_dict(data)
        
        self.assertEqual(entry.date, "2025-12-13")
        self.assertEqual(entry.cognitive_state, CognitiveState.MODERATE)


class TestWeeklyTrends(unittest.TestCase):
    """Tests for WeeklyTrends model."""
    
    def test_create_trends(self):
        """Test creating weekly trends."""
        trends = WeeklyTrends(
            avg_opening_balance=100.0,
            avg_closing_balance=45.0,
            avg_withdrawals=85.0,
            avg_deposits=30.0,
            deficit_days=2,
            recovery_ratio=0.35,
            trend_direction=TrendDirection.DECLINING,
            balance_slope=-3.5,
            volatility=25.0,
            days_analyzed=7,
            start_date="2025-12-07",
            end_date="2025-12-13"
        )
        
        self.assertEqual(trends.days_analyzed, 7)
        self.assertEqual(trends.deficit_days, 2)
        self.assertEqual(trends.trend_direction, TrendDirection.DECLINING)
    
    def test_to_dict(self):
        """Test conversion to dictionary."""
        trends = WeeklyTrends(
            avg_opening_balance=100.0,
            avg_closing_balance=45.0,
            avg_withdrawals=85.0,
            avg_deposits=30.0,
            deficit_days=2,
            recovery_ratio=0.35,
            trend_direction=TrendDirection.STABLE,
            balance_slope=0.0,
            volatility=10.0,
            days_analyzed=7,
            start_date="2025-12-07",
            end_date="2025-12-13"
        )
        
        data = trends.to_dict()
        
        self.assertEqual(data['days_analyzed'], 7)
        self.assertEqual(data['trend_direction'], "STABLE")


class TestInsight(unittest.TestCase):
    """Tests for Insight model."""
    
    def test_create_insight(self):
        """Test creating insight."""
        insight = Insight(
            date="2025-12-13",
            rule_id=3,
            rule_name="DEFICIT_DETECTED",
            message="Your balance closed at -30 CU.",
            confidence=90
        )
        
        self.assertEqual(insight.rule_id, 3)
        self.assertEqual(insight.rule_name, "DEFICIT_DETECTED")
    
    def test_to_dict(self):
        """Test conversion to dictionary."""
        insight = Insight(
            date="2025-12-13",
            rule_id=3,
            rule_name="DEFICIT_DETECTED",
            message="Test message",
            confidence=90,
            data_points={'balance': -30}
        )
        
        data = insight.to_dict()
        
        self.assertEqual(data['rule_id'], 3)
        self.assertEqual(data['data_points']['balance'], -30)


class TestUserProfile(unittest.TestCase):
    """Tests for UserProfile model."""
    
    def test_create_profile(self):
        """Test creating user profile."""
        profile = UserProfile(
            user_id="user123",
            created_at="2025-12-01T10:00:00"
        )
        
        self.assertEqual(profile.user_id, "user123")
        self.assertFalse(profile.is_calibrated)
        self.assertEqual(profile.days_logged, 0)
    
    def test_profile_defaults(self):
        """Test profile default values."""
        profile = UserProfile(
            user_id="user123",
            created_at="2025-12-01T10:00:00"
        )
        
        self.assertEqual(profile.context_base_cost, 2.0)
        self.assertEqual(profile.decision_base_cost, 8.0)
        self.assertEqual(profile.recovery_base, 40.0)
    
    def test_to_dict(self):
        """Test conversion to dictionary."""
        profile = UserProfile(
            user_id="user123",
            created_at="2025-12-01T10:00:00",
            is_calibrated=True,
            days_logged=30
        )
        
        data = profile.to_dict()
        
        self.assertEqual(data['user_id'], "user123")
        self.assertTrue(data['is_calibrated'])
    
    def test_from_dict(self):
        """Test creation from dictionary."""
        data = {
            'user_id': "user123",
            'created_at': "2025-12-01T10:00:00",
            'is_calibrated': False,
            'calibration_date': None,
            'days_logged': 0,
            'context_base_cost': 2.0,
            'context_switch_cost': 1.5,
            'decision_base_cost': 8.0,
            'passive_base_cost': 0.75,
            'recovery_base': 40.0,
            'disclaimer_accepted': False,
            'disclaimer_accepted_date': None
        }
        
        profile = UserProfile.from_dict(data)
        
        self.assertEqual(profile.user_id, "user123")


class TestEnums(unittest.TestCase):
    """Tests for enum types."""
    
    def test_cognitive_state_values(self):
        """Test CognitiveState enum values."""
        self.assertEqual(CognitiveState.WELL_RESTED.value, "WELL_RESTED")
        self.assertEqual(CognitiveState.MODERATE.value, "MODERATE")
        self.assertEqual(CognitiveState.DEPLETED.value, "DEPLETED")
        self.assertEqual(CognitiveState.DEFICIT.value, "DEFICIT")
        self.assertEqual(CognitiveState.SEVERE_DEFICIT.value, "SEVERE_DEFICIT")
    
    def test_trend_direction_values(self):
        """Test TrendDirection enum values."""
        self.assertEqual(TrendDirection.DETERIORATING.value, "DETERIORATING")
        self.assertEqual(TrendDirection.STABLE.value, "STABLE")
        self.assertEqual(TrendDirection.IMPROVING.value, "IMPROVING")


if __name__ == '__main__':
    unittest.main()
