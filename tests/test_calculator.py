"""
Tests for the Cognitive Load Calculator
========================================

Tests for src/calculator.py
"""

import unittest
import sys
import os

sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from src.calculator import (
    CognitiveLoadCalculator,
    extract_features,
    extract_text_features,
    determine_cognitive_state,
    calculate_confidence_score,
    calculate_carryover,
    calculate_opening_balance,
    linear_trend,
    calculate_volatility
)
from src.models import DailyInput, CognitiveState
from src.config import CUConstants


class TestFeatureExtraction(unittest.TestCase):
    """Tests for feature extraction functions."""
    
    def test_extract_features_basic(self):
        """Test basic feature extraction."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=5,
            decision_count=8,
            unresolved_count=6,
            recovery_quality=5
        )
        
        features = extract_features(daily_input)
        
        self.assertEqual(features.context_count, 5)
        self.assertEqual(features.decision_count, 8)
        self.assertEqual(features.unresolved_count, 6)
        self.assertEqual(features.recovery_quality, 5)
        self.assertFalse(features.high_context_flag)  # <10
        self.assertFalse(features.high_decision_flag)  # <10
    
    def test_extract_features_high_flags(self):
        """Test high load flag detection."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=15,
            decision_count=20,
            unresolved_count=25,
            recovery_quality=2
        )
        
        features = extract_features(daily_input)
        
        self.assertTrue(features.high_context_flag)  # >=10
        self.assertTrue(features.high_decision_flag)  # >=10
        self.assertTrue(features.high_unresolved_flag)  # >=10
        self.assertTrue(features.poor_recovery_flag)  # <=3
    
    def test_extract_text_features_empty(self):
        """Test text feature extraction with no text."""
        features = extract_text_features(None)
        
        self.assertEqual(features['urgency'], 0.0)
        self.assertEqual(features['complexity'], 0.0)
        self.assertEqual(features['fatigue'], 0.0)
    
    def test_extract_text_features_urgency(self):
        """Test urgency detection in text."""
        features = extract_text_features("Had an urgent deadline, critical issue came up")
        
        self.assertGreater(features['urgency'], 0.0)
    
    def test_extract_text_features_fatigue(self):
        """Test fatigue detection in text."""
        features = extract_text_features("Felt exhausted and drained all day")
        
        self.assertGreater(features['fatigue'], 0.0)


class TestCognitiveLoadCalculator(unittest.TestCase):
    """Tests for CognitiveLoadCalculator class."""
    
    def setUp(self):
        """Set up calculator for tests."""
        self.calculator = CognitiveLoadCalculator()
    
    def test_calculate_context_cost_basic(self):
        """Test basic context cost calculation."""
        cost, explanation = self.calculator.calculate_context_cost(5)
        
        # 5 contexts × 2 = 10, 4 switches × 1.5 = 6, total = 16
        expected = (5 * 2) + (4 * 1.5)
        self.assertEqual(cost, expected)
        self.assertIn("5 contexts", explanation)
    
    def test_calculate_context_cost_zero(self):
        """Test context cost with zero contexts."""
        cost, explanation = self.calculator.calculate_context_cost(0)
        
        self.assertEqual(cost, 0.0)
    
    def test_calculate_context_cost_high_load(self):
        """Test context cost with high load penalty."""
        cost, explanation = self.calculator.calculate_context_cost(12)
        
        # High load penalty should apply (>=10 contexts)
        base = (12 * 2) + (11 * 1.5)
        expected = base * CUConstants.CONTEXT_HIGH_LOAD_PENALTY
        self.assertEqual(cost, expected)
        self.assertIn("penalty", explanation.lower())
    
    def test_calculate_decision_cost_basic(self):
        """Test basic decision cost calculation."""
        cost, explanation = self.calculator.calculate_decision_cost(5)
        
        expected = 5 * 8  # 5 decisions × 8 CU
        self.assertEqual(cost, expected)
    
    def test_calculate_decision_cost_fatigue(self):
        """Test decision cost with fatigue multiplier."""
        cost, explanation = self.calculator.calculate_decision_cost(12)
        
        # 12 decisions triggers first fatigue threshold
        base = 12 * 8
        expected = base * CUConstants.DECISION_FATIGUE_MULTIPLIER_1
        self.assertEqual(cost, expected)
        self.assertIn("fatigue", explanation.lower())
    
    def test_calculate_passive_drain_basic(self):
        """Test basic passive drain calculation."""
        cost, explanation = self.calculator.calculate_passive_drain(8)
        
        expected = 8 * 0.75
        self.assertEqual(cost, expected)
    
    def test_calculate_passive_drain_accumulation(self):
        """Test passive drain with accumulation penalty."""
        cost, explanation = self.calculator.calculate_passive_drain(15)
        
        # 15 items triggers first accumulation penalty
        base = 15 * 0.75
        expected = base * CUConstants.PASSIVE_MULTIPLIER_1
        self.assertEqual(cost, expected)
    
    def test_calculate_recovery_deposit_baseline(self):
        """Test recovery deposit at baseline quality."""
        deposit, explanation = self.calculator.calculate_recovery_deposit(5)
        
        # Quality 5 = factor of 1.0, so base 40 CU
        expected = 40.0
        self.assertEqual(deposit, expected)
    
    def test_calculate_recovery_deposit_high_quality(self):
        """Test recovery deposit with high quality."""
        deposit, explanation = self.calculator.calculate_recovery_deposit(10)
        
        # Quality 10 = factor of 2.0, so 80 CU
        expected = 80.0
        self.assertEqual(deposit, expected)
    
    def test_calculate_recovery_deposit_low_quality(self):
        """Test recovery deposit with low quality."""
        deposit, explanation = self.calculator.calculate_recovery_deposit(2)
        
        # Quality 2 = factor of 0.4, so 16 CU
        expected = 40.0 * 0.4
        self.assertEqual(deposit, expected)
    
    def test_calculate_daily_balance_positive(self):
        """Test daily balance calculation ending positive."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=3,
            decision_count=4,
            unresolved_count=3,
            recovery_quality=7
        )
        
        entry = self.calculator.calculate_daily_balance(daily_input, opening_balance=100)
        
        self.assertIsNotNone(entry)
        self.assertEqual(entry.date, "2025-12-13")
        self.assertEqual(entry.opening_balance, 100)
        self.assertGreater(entry.total_withdrawals, 0)
        self.assertGreater(entry.total_deposits, 0)
        # Light day should end positive
        self.assertGreater(entry.closing_balance, 0)
    
    def test_calculate_daily_balance_deficit(self):
        """Test daily balance calculation ending in deficit."""
        daily_input = DailyInput(
            date="2025-12-13",
            context_count=15,
            decision_count=20,
            unresolved_count=25,
            recovery_quality=2
        )
        
        entry = self.calculator.calculate_daily_balance(daily_input, opening_balance=100)
        
        # Heavy day should end in deficit
        self.assertLess(entry.closing_balance, 0)
        self.assertEqual(entry.cognitive_state, CognitiveState.DEFICIT)


class TestHelperFunctions(unittest.TestCase):
    """Tests for calculator helper functions."""
    
    def test_determine_cognitive_state_well_rested(self):
        """Test state determination for well-rested."""
        state = determine_cognitive_state(80)
        self.assertEqual(state, CognitiveState.WELL_RESTED)
    
    def test_determine_cognitive_state_moderate(self):
        """Test state determination for moderate."""
        state = determine_cognitive_state(50)
        self.assertEqual(state, CognitiveState.MODERATE)
    
    def test_determine_cognitive_state_depleted(self):
        """Test state determination for depleted."""
        state = determine_cognitive_state(20)
        self.assertEqual(state, CognitiveState.DEPLETED)
    
    def test_determine_cognitive_state_deficit(self):
        """Test state determination for deficit."""
        state = determine_cognitive_state(-10)
        self.assertEqual(state, CognitiveState.DEFICIT)
    
    def test_determine_cognitive_state_severe_deficit(self):
        """Test state determination for severe deficit."""
        state = determine_cognitive_state(-60)
        self.assertEqual(state, CognitiveState.SEVERE_DEFICIT)
    
    def test_calculate_carryover_positive(self):
        """Test carryover with positive balance."""
        carryover = calculate_carryover(50)
        self.assertEqual(carryover, 0.0)  # No carryover for positive
    
    def test_calculate_carryover_negative(self):
        """Test carryover with negative balance."""
        carryover = calculate_carryover(-50)
        expected = -50 * 0.2  # 20% carryover
        self.assertEqual(carryover, expected)
    
    def test_calculate_opening_balance_first_day(self):
        """Test opening balance for first day."""
        opening = calculate_opening_balance(None)
        self.assertEqual(opening, 100.0)
    
    def test_calculate_opening_balance_after_positive(self):
        """Test opening balance after positive closing."""
        opening = calculate_opening_balance(70)
        self.assertEqual(opening, 100.0)  # Full reset
    
    def test_calculate_opening_balance_after_deficit(self):
        """Test opening balance after deficit closing."""
        opening = calculate_opening_balance(-50)
        expected = 100 + (-50 * 0.2)  # 100 - 10 = 90
        self.assertEqual(opening, expected)
    
    def test_linear_trend_increasing(self):
        """Test linear trend with increasing values."""
        values = [10, 20, 30, 40, 50]
        slope = linear_trend(values)
        self.assertGreater(slope, 0)
    
    def test_linear_trend_decreasing(self):
        """Test linear trend with decreasing values."""
        values = [50, 40, 30, 20, 10]
        slope = linear_trend(values)
        self.assertLess(slope, 0)
    
    def test_linear_trend_flat(self):
        """Test linear trend with flat values."""
        values = [30, 30, 30, 30, 30]
        slope = linear_trend(values)
        self.assertEqual(slope, 0.0)
    
    def test_calculate_volatility(self):
        """Test volatility calculation."""
        # High variance
        high_var = calculate_volatility([10, 50, 20, 80, 30])
        # Low variance
        low_var = calculate_volatility([48, 50, 52, 49, 51])
        
        self.assertGreater(high_var, low_var)


if __name__ == '__main__':
    unittest.main()
