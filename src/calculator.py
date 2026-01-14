"""
Cognitive Load Estimation Engine
=================================

Hybrid rule-based + lightweight ML approach for calculating cognitive load.
Implements Section 9 of PCLL_System_Definition.md.

Design Philosophy:
- Explainability over raw accuracy
- CPU-only execution (<100ms per calculation)
- Offline-capable (no cloud dependencies)
"""

from dataclasses import dataclass
from typing import Dict, List, Optional, Any
from datetime import datetime
import re

from .models import (
    DailyInput, 
    ComponentBreakdown, 
    DailyLedgerEntry,
    CognitiveState,
    UserProfile
)
from .config import CUConstants


# =============================================================================
# LEXICONS FOR TEXT ANALYSIS
# =============================================================================

URGENCY_LEXICON = {
    'urgent', 'critical', 'emergency', 'asap', 'rush', 'immediate',
    'deadline', 'overdue', 'late', 'pressing', 'priority', 'escalation'
}

COMPLEXITY_LEXICON = {
    'complex', 'complicated', 'difficult', 'challenging', 'hard',
    'confusing', 'intricate', 'technical', 'advanced', 'unclear'
}

FATIGUE_LEXICON = {
    'tired', 'exhausted', 'drained', 'burned', 'depleted', 'overwhelmed',
    'swamped', 'buried', 'drowning', 'struggled', 'fatigued'
}

CONFLICT_LEXICON = {
    'conflict', 'disagreement', 'argument', 'tension', 'difficult',
    'pushback', 'resistance', 'debate', 'frustrating'
}

RECOVERY_LEXICON = {
    'break', 'rest', 'walk', 'lunch', 'exercise', 'relaxed',
    'refreshed', 'recharged', 'peaceful', 'calm'
}


# =============================================================================
# FEATURE EXTRACTION
# =============================================================================

@dataclass
class ExtractedFeatures:
    """All features extracted from daily input."""
    # Direct numeric features
    context_count: int
    decision_count: int
    unresolved_count: int
    recovery_quality: int
    subjective_depletion: Optional[int]
    
    # Derived features
    high_context_flag: bool
    high_decision_flag: bool
    high_unresolved_flag: bool
    poor_recovery_flag: bool
    
    # Text features (optional)
    urgency_score: float = 0.0
    complexity_score: float = 0.0
    fatigue_score: float = 0.0
    conflict_score: float = 0.0
    recovery_mention_score: float = 0.0
    
    # Temporal features
    is_monday: bool = False
    is_friday: bool = False
    day_of_week: int = 0


def extract_features(daily_input: DailyInput, timestamp: Optional[datetime] = None) -> ExtractedFeatures:
    """
    Extract all features from daily input for scoring.
    
    Args:
        daily_input: User's daily input responses
        timestamp: Optional timestamp for temporal features
        
    Returns:
        ExtractedFeatures with all computed features
    """
    # Use current time if not provided
    if timestamp is None:
        timestamp = datetime.now()
    
    # Direct features
    context_count = daily_input.context_count
    decision_count = daily_input.decision_count
    unresolved_count = daily_input.unresolved_count
    recovery_quality = daily_input.recovery_quality
    
    # Derived flags
    high_context_flag = context_count >= CUConstants.CONTEXT_HIGH_LOAD_THRESHOLD
    high_decision_flag = decision_count >= CUConstants.DECISION_FATIGUE_THRESHOLD_1
    high_unresolved_flag = unresolved_count >= CUConstants.PASSIVE_THRESHOLD_1
    poor_recovery_flag = recovery_quality <= 3
    
    # Extract text features if note provided
    text_features = extract_text_features(daily_input.text_note)
    
    # Temporal features
    day_of_week = timestamp.weekday()
    is_monday = day_of_week == 0
    is_friday = day_of_week == 4
    
    return ExtractedFeatures(
        context_count=context_count,
        decision_count=decision_count,
        unresolved_count=unresolved_count,
        recovery_quality=recovery_quality,
        subjective_depletion=daily_input.subjective_depletion,
        high_context_flag=high_context_flag,
        high_decision_flag=high_decision_flag,
        high_unresolved_flag=high_unresolved_flag,
        poor_recovery_flag=poor_recovery_flag,
        urgency_score=text_features.get('urgency', 0.0),
        complexity_score=text_features.get('complexity', 0.0),
        fatigue_score=text_features.get('fatigue', 0.0),
        conflict_score=text_features.get('conflict', 0.0),
        recovery_mention_score=text_features.get('recovery', 0.0),
        is_monday=is_monday,
        is_friday=is_friday,
        day_of_week=day_of_week
    )


def extract_text_features(text_note: Optional[str]) -> Dict[str, float]:
    """
    Extract cognitive load signals from free-text notes.
    Uses lightweight lexicon matching (no ML required).
    
    Args:
        text_note: Optional free-text description of the day
        
    Returns:
        Dictionary of text-derived feature scores
    """
    if not text_note or not text_note.strip():
        return {
            'urgency': 0.0,
            'complexity': 0.0,
            'fatigue': 0.0,
            'conflict': 0.0,
            'recovery': 0.0
        }
    
    # Tokenize: lowercase, split on non-alphanumeric
    tokens = set(re.findall(r'\b[a-z]+\b', text_note.lower()))
    
    # Count matches for each lexicon
    urgency_count = len(tokens & URGENCY_LEXICON)
    complexity_count = len(tokens & COMPLEXITY_LEXICON)
    fatigue_count = len(tokens & FATIGUE_LEXICON)
    conflict_count = len(tokens & CONFLICT_LEXICON)
    recovery_count = len(tokens & RECOVERY_LEXICON)
    
    # Normalize to 0-1 scale (cap at 3 matches = 1.0)
    def normalize(count: int, max_count: int = 3) -> float:
        return min(count / max_count, 1.0)
    
    return {
        'urgency': normalize(urgency_count),
        'complexity': normalize(complexity_count),
        'fatigue': normalize(fatigue_count),
        'conflict': normalize(conflict_count),
        'recovery': normalize(recovery_count)
    }


# =============================================================================
# COGNITIVE LOAD CALCULATOR
# =============================================================================

class CognitiveLoadCalculator:
    """
    Main calculator for cognitive load estimation.
    Implements Section 9.3 of the system definition.
    """
    
    def __init__(self, profile: Optional[UserProfile] = None):
        """
        Initialize calculator with optional user profile for calibration.
        
        Args:
            profile: Optional user profile with personalized coefficients
        """
        # Use profile coefficients or defaults
        if profile and profile.is_calibrated:
            self.context_base_cost = profile.context_base_cost
            self.context_switch_cost = profile.context_switch_cost
            self.decision_base_cost = profile.decision_base_cost
            self.passive_base_cost = profile.passive_base_cost
            self.recovery_base = profile.recovery_base
        else:
            self.context_base_cost = CUConstants.CONTEXT_BASE_COST
            self.context_switch_cost = CUConstants.CONTEXT_SWITCH_COST
            self.decision_base_cost = CUConstants.DECISION_BASE_COST
            self.passive_base_cost = CUConstants.PASSIVE_BASE_COST
            self.recovery_base = CUConstants.RECOVERY_BASE_POTENTIAL
    
    def calculate_context_cost(self, context_count: int) -> tuple[float, str]:
        """
        Calculate cognitive cost from context switching.
        Based on Section 5.2: Context Multiplicity.
        
        Formula:
            Base_cost = context_count × 2 CU
            Switch_cost = (context_count - 1) × 1.5 CU
            Total = (Base + Switch) × high_load_penalty
        
        Args:
            context_count: Number of distinct contexts worked on
            
        Returns:
            Tuple of (cost_in_CU, explanation_string)
        """
        if context_count <= 0:
            return 0.0, "No context switching"
        
        # Base maintenance cost
        base_cost = context_count * self.context_base_cost
        
        # Switching cost (n contexts = n-1 switches)
        switch_count = max(0, context_count - 1)
        switch_cost = switch_count * self.context_switch_cost
        
        # High load penalty
        if context_count >= CUConstants.CONTEXT_HIGH_LOAD_THRESHOLD:
            multiplier = CUConstants.CONTEXT_HIGH_LOAD_PENALTY
            penalty_note = f" (×{multiplier} high-load penalty)"
        else:
            multiplier = 1.0
            penalty_note = ""
        
        total_cost = (base_cost + switch_cost) * multiplier
        
        explanation = (
            f"{context_count} contexts × {self.context_base_cost} CU = {base_cost:.1f} CU base, "
            f"{switch_count} switches × {self.context_switch_cost} CU = {switch_cost:.1f} CU"
            f"{penalty_note}"
        )
        
        return total_cost, explanation
    
    def calculate_decision_cost(self, decision_count: int) -> tuple[float, str]:
        """
        Calculate cognitive cost from decision making.
        Based on Section 5.3: Decision Volume.
        
        Formula:
            Base_cost = decision_count × 8 CU
            With fatigue multipliers for high counts
        
        Args:
            decision_count: Number of significant decisions made
            
        Returns:
            Tuple of (cost_in_CU, explanation_string)
        """
        if decision_count <= 0:
            return 0.0, "No significant decisions"
        
        # Base cost per decision
        base_cost = decision_count * self.decision_base_cost
        
        # Decision fatigue multipliers
        if decision_count >= CUConstants.DECISION_FATIGUE_THRESHOLD_2:
            multiplier = CUConstants.DECISION_FATIGUE_MULTIPLIER_2
            fatigue_note = f" (×{multiplier} severe fatigue)"
        elif decision_count >= CUConstants.DECISION_FATIGUE_THRESHOLD_1:
            multiplier = CUConstants.DECISION_FATIGUE_MULTIPLIER_1
            fatigue_note = f" (×{multiplier} fatigue penalty)"
        else:
            multiplier = 1.0
            fatigue_note = ""
        
        total_cost = base_cost * multiplier
        
        explanation = (
            f"{decision_count} decisions × {self.decision_base_cost} CU = {base_cost:.1f} CU"
            f"{fatigue_note}"
        )
        
        return total_cost, explanation
    
    def calculate_passive_drain(self, unresolved_count: int) -> tuple[float, str]:
        """
        Calculate passive cognitive drain from open loops.
        Based on Section 5 - Open Loops / Unresolved Tasks.
        
        Formula:
            Base_drain = unresolved_count × 0.75 CU
            With accumulation multipliers for high counts
        
        Args:
            unresolved_count: Number of unresolved tasks/commitments
            
        Returns:
            Tuple of (cost_in_CU, explanation_string)
        """
        if unresolved_count <= 0:
            return 0.0, "No unresolved items"
        
        # Base passive cost
        base_drain = unresolved_count * self.passive_base_cost
        
        # Accumulation penalty
        if unresolved_count >= CUConstants.PASSIVE_THRESHOLD_2:
            multiplier = CUConstants.PASSIVE_MULTIPLIER_2
            accumulation_note = f" (×{multiplier} overload penalty)"
        elif unresolved_count >= CUConstants.PASSIVE_THRESHOLD_1:
            multiplier = CUConstants.PASSIVE_MULTIPLIER_1
            accumulation_note = f" (×{multiplier} accumulation penalty)"
        else:
            multiplier = 1.0
            accumulation_note = ""
        
        total_drain = base_drain * multiplier
        
        explanation = (
            f"{unresolved_count} items × {self.passive_base_cost} CU = {base_drain:.1f} CU"
            f"{accumulation_note}"
        )
        
        return total_drain, explanation
    
    def calculate_attention_cost(self, features: ExtractedFeatures) -> tuple[float, str]:
        """
        Estimate attention density cost from available proxies.
        Based on Section 5.1: Attention Density.
        
        Since we don't track hours directly, we estimate from
        context count + decision count as proxy for intensity.
        
        Args:
            features: Extracted features from daily input
            
        Returns:
            Tuple of (cost_in_CU, explanation_string)
        """
        # Use context + decision as proxy for attention intensity
        intensity_proxy = features.context_count + features.decision_count
        
        # Estimate: each unit of intensity = 0.5 CU attention cost
        # This models sustained focus requirements
        base_attention = intensity_proxy * CUConstants.ATTENTION_INTENSITY_FACTOR
        
        # Adjust for text-derived complexity
        if features.complexity_score > 0:
            complexity_boost = 1.0 + (features.complexity_score * 0.2)
            base_attention *= complexity_boost
        
        explanation = (
            f"Estimated from activity intensity: "
            f"({features.context_count} + {features.decision_count}) × 0.5 = {base_attention:.1f} CU"
        )
        
        return base_attention, explanation
    
    def calculate_recovery_deposit(
        self, 
        recovery_quality: int,
        subjective_depletion: Optional[int] = None
    ) -> tuple[float, str]:
        """
        Calculate cognitive recovery deposit from break quality.
        Based on Section 6.2: Recovery Activities.
        
        Formula:
            Base_deposit = 40 CU (typical day potential)
            Actual = Base × (quality_rating / 5.0)
            
        With bonus for high depletion (body compensates more).
        
        Args:
            recovery_quality: 1-10 rating of break quality
            subjective_depletion: Optional 1-10 depletion rating
            
        Returns:
            Tuple of (deposit_in_CU, explanation_string)
        """
        # Normalize quality to factor (5 = 1.0 baseline)
        quality_factor = recovery_quality / 5.0
        
        # Base recovery potential
        base_deposit = self.recovery_base * quality_factor
        
        # Depletion bonus (higher depletion = more effective recovery)
        bonus_note = ""
        if subjective_depletion is not None:
            if subjective_depletion >= CUConstants.DEPLETION_BONUS_THRESHOLD_2:
                bonus_multiplier = CUConstants.DEPLETION_BONUS_MULTIPLIER_2
                bonus_note = f" (×{bonus_multiplier} depletion recovery bonus)"
            elif subjective_depletion >= CUConstants.DEPLETION_BONUS_THRESHOLD_1:
                bonus_multiplier = CUConstants.DEPLETION_BONUS_MULTIPLIER_1
                bonus_note = f" (×{bonus_multiplier} mild recovery bonus)"
            else:
                bonus_multiplier = 1.0
            base_deposit *= bonus_multiplier
        
        explanation = (
            f"Recovery quality {recovery_quality}/10: "
            f"{self.recovery_base} CU × {quality_factor:.1f} = {base_deposit:.1f} CU"
            f"{bonus_note}"
        )
        
        return base_deposit, explanation
    
    def apply_text_modifiers(
        self, 
        base_withdrawals: float, 
        features: ExtractedFeatures
    ) -> tuple[float, str]:
        """
        Apply text-derived modifiers to base withdrawal score.
        Based on Section 9.4: Text Input Modifiers.
        
        Args:
            base_withdrawals: Total withdrawals before text adjustment
            features: Extracted features including text scores
            
        Returns:
            Tuple of (adjusted_withdrawals, modifier_explanation)
        """
        modifiers = []
        total_adjustment = 0.0
        
        # Urgency penalty: +10% max
        if features.urgency_score > 0:
            urgency_penalty = base_withdrawals * 0.10 * features.urgency_score
            total_adjustment += urgency_penalty
            modifiers.append(f"urgency +{urgency_penalty:.1f} CU")
        
        # Complexity penalty: +8% max
        if features.complexity_score > 0:
            complexity_penalty = base_withdrawals * 0.08 * features.complexity_score
            total_adjustment += complexity_penalty
            modifiers.append(f"complexity +{complexity_penalty:.1f} CU")
        
        # Conflict penalty: +12% max
        if features.conflict_score > 0:
            conflict_penalty = base_withdrawals * 0.12 * features.conflict_score
            total_adjustment += conflict_penalty
            modifiers.append(f"conflict +{conflict_penalty:.1f} CU")
        
        # Fatigue validation (confirms high load, +5% max)
        if features.fatigue_score > 0:
            fatigue_penalty = base_withdrawals * 0.05 * features.fatigue_score
            total_adjustment += fatigue_penalty
            modifiers.append(f"fatigue validation +{fatigue_penalty:.1f} CU")
        
        adjusted = base_withdrawals + total_adjustment
        
        if modifiers:
            explanation = "Text modifiers: " + ", ".join(modifiers)
        else:
            explanation = "No text modifiers applied"
        
        return adjusted, explanation
    
    def calculate_daily_balance(
        self, 
        daily_input: DailyInput,
        opening_balance: float = 100.0,
        timestamp: Optional[datetime] = None
    ) -> DailyLedgerEntry:
        """
        Calculate complete daily cognitive balance.
        Main entry point for daily calculation.
        
        Args:
            daily_input: User's daily input responses
            opening_balance: Starting balance for the day
            timestamp: Optional timestamp for the entry
            
        Returns:
            Complete DailyLedgerEntry with all calculations
        """
        if timestamp is None:
            timestamp = datetime.now()
        
        # Extract features
        features = extract_features(daily_input, timestamp)
        
        # Calculate each component
        context_cost, context_exp = self.calculate_context_cost(features.context_count)
        decision_cost, decision_exp = self.calculate_decision_cost(features.decision_count)
        passive_drain, passive_exp = self.calculate_passive_drain(features.unresolved_count)
        attention_cost, attention_exp = self.calculate_attention_cost(features)
        recovery_deposit, recovery_exp = self.calculate_recovery_deposit(
            features.recovery_quality,
            features.subjective_depletion
        )
        
        # Sum base withdrawals
        base_withdrawals = context_cost + decision_cost + passive_drain + attention_cost
        
        # Apply text modifiers
        adjusted_withdrawals, text_mod_exp = self.apply_text_modifiers(base_withdrawals, features)
        
        # Calculate totals
        total_withdrawals = adjusted_withdrawals
        total_deposits = recovery_deposit
        net_change = total_deposits - total_withdrawals
        closing_balance = opening_balance + net_change
        
        # Determine cognitive state
        cognitive_state = determine_cognitive_state(closing_balance)
        
        # Build component breakdown
        components = ComponentBreakdown(
            context_cost=context_cost,
            context_explanation=context_exp,
            decision_cost=decision_cost,
            decision_explanation=decision_exp,
            passive_drain=passive_drain,
            passive_explanation=passive_exp,
            attention_cost=attention_cost,
            attention_explanation=attention_exp,
            recovery_deposit=recovery_deposit,
            recovery_explanation=recovery_exp
        )
        
        # Calculate confidence
        confidence = calculate_confidence_score(features, daily_input)
        
        # Build ledger entry
        entry = DailyLedgerEntry(
            date=daily_input.date,
            opening_balance=opening_balance,
            closing_balance=closing_balance,
            total_withdrawals=total_withdrawals,
            total_deposits=total_deposits,
            net_change=net_change,
            cognitive_state=cognitive_state,
            components=components,
            confidence=confidence
        )
        
        return entry


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def determine_cognitive_state(balance: float) -> CognitiveState:
    """
    Map balance to cognitive state classification.
    Based on Section 6: CU thresholds.
    
    Args:
        balance: Current cognitive balance in CU
        
    Returns:
        CognitiveState enum value
    """
    if balance < CUConstants.STATE_SEVERE_DEFICIT_THRESHOLD:
        return CognitiveState.SEVERE_DEFICIT
    elif balance < CUConstants.STATE_DEFICIT_THRESHOLD:
        return CognitiveState.DEFICIT
    elif balance < CUConstants.STATE_DEPLETED_THRESHOLD:
        return CognitiveState.DEPLETED
    elif balance < CUConstants.STATE_MODERATE_THRESHOLD:
        return CognitiveState.MODERATE
    else:
        return CognitiveState.WELL_RESTED


def calculate_confidence_score(features: ExtractedFeatures, daily_input: DailyInput) -> int:
    """
    Calculate confidence score for the estimation.
    Higher confidence when more data is available and consistent.
    
    Args:
        features: Extracted features
        daily_input: Original daily input
        
    Returns:
        Confidence score 0-100
    """
    confidence = 70  # Base confidence
    
    # Boost for optional calibration input
    if features.subjective_depletion is not None:
        confidence += 10
    
    # Boost for text note (more context)
    if daily_input.text_note and len(daily_input.text_note) > 20:
        confidence += 5
    
    # Penalty for extreme values (may indicate estimation errors)
    if features.context_count > 20:
        confidence -= 10
    if features.decision_count > 30:
        confidence -= 10
    if features.unresolved_count > 40:
        confidence -= 5
    
    # Ensure bounds
    return max(0, min(100, confidence))


def calculate_carryover(closing_balance: float) -> float:
    """
    Calculate deficit carryover for next day's opening.
    Based on Section 7.1: Carryover mechanics.
    
    Only deficits carry over (20% rate). Positive balances reset.
    
    Args:
        closing_balance: Today's closing balance
        
    Returns:
        Carryover modifier for next day (negative or zero)
    """
    if closing_balance >= 0:
        return 0.0
    else:
        return closing_balance * CUConstants.DEFICIT_CARRYOVER_RATE


def calculate_opening_balance(previous_closing: Optional[float] = None) -> float:
    """
    Calculate opening balance for a new day.
    
    Args:
        previous_closing: Previous day's closing balance (None for first day)
        
    Returns:
        Opening balance in CU
    """
    if previous_closing is None:
        return CUConstants.BASELINE_CAPACITY
    
    carryover = calculate_carryover(previous_closing)
    opening = CUConstants.BASELINE_CAPACITY + carryover
    
    # Clamp to valid range
    return max(0, min(CUConstants.MAX_CAPACITY, opening))


# =============================================================================
# TREND CALCULATION UTILITIES
# =============================================================================

def linear_trend(values: List[float]) -> float:
    """
    Calculate linear regression slope over a time series.
    Used for trend detection in weekly metrics.
    
    Args:
        values: List of values in chronological order
        
    Returns:
        Slope of linear trend (positive = improving)
    """
    n = len(values)
    if n < 2:
        return 0.0
    
    # Simple linear regression
    x_mean = (n - 1) / 2.0
    y_mean = sum(values) / n
    
    numerator = sum((i - x_mean) * (values[i] - y_mean) for i in range(n))
    denominator = sum((i - x_mean) ** 2 for i in range(n))
    
    if denominator == 0:
        return 0.0
    
    return numerator / denominator


def calculate_volatility(values: List[float]) -> float:
    """
    Calculate standard deviation of values.
    Higher volatility = less consistent patterns.
    
    Args:
        values: List of balance values
        
    Returns:
        Standard deviation
    """
    n = len(values)
    if n < 2:
        return 0.0
    
    mean = sum(values) / n
    variance = sum((v - mean) ** 2 for v in values) / n
    
    return variance ** 0.5
