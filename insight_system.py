"""
PCLL Insight Generation System
===============================

A rule-based system for generating daily insights about cognitive load patterns.

Design Principles:
- OBSERVATIONAL: Describe what happened, not what to do
- CAUSAL: Explain *why* the balance changed
- SINGLE: One insight per day maximum
- NEUTRAL: No motivational or prescriptive language

Constraints:
- No advice overload (max 1 insight/day)
- No motivational language ("You can do it!", "Great job!")
- No clinical terms (burnout, anxiety, depression)
- No prescriptive statements ("You should...", "Try to...")
- Must cite specific data points
"""

from dataclasses import dataclass, field
from typing import List, Optional, Dict, Any, Callable
from enum import Enum
import re


# =============================================================================
# SECTION 1: DATA STRUCTURES
# =============================================================================

class InsightPriority(Enum):
    """Priority levels for insight selection when multiple rules match."""
    CRITICAL = 1    # Severe deficit, consecutive deficit
    HIGH = 2        # Deficit detected, high withdrawal
    MEDIUM = 3      # Pattern detected (context overload, low recovery)
    LOW = 4         # Positive observations (recovery success, stable)
    INFO = 5        # General information


class InsightCategory(Enum):
    """Categories for insight classification."""
    OBSERVATION = "OBSERVATION"   # What happened today
    PATTERN = "PATTERN"           # Multi-day pattern detected
    TREND = "TREND"               # Direction of change over time
    COMPONENT = "COMPONENT"       # Specific cost component analysis


@dataclass
class InsightContext:
    """
    All data available for insight generation.
    The insight engine uses this to evaluate rules.
    """
    # Current day data
    date: str
    opening_balance: float
    closing_balance: float
    total_withdrawals: float
    total_deposits: float
    net_change: float
    
    # Component breakdown
    context_cost: float
    decision_cost: float
    passive_drain: float
    recovery_deposit: float
    
    # Derived metrics
    cognitive_state: str
    withdrawal_to_deposit_ratio: float
    
    # Historical context (last 7 days)
    recent_balances: List[float] = field(default_factory=list)
    recent_states: List[str] = field(default_factory=list)
    avg_balance_7d: Optional[float] = None
    deficit_days_7d: int = 0
    trend_slope: float = 0.0  # Positive = improving, negative = declining


@dataclass
class Insight:
    """A generated insight with metadata."""
    rule_id: int
    rule_name: str
    category: InsightCategory
    priority: InsightPriority
    message: str
    data_points: Dict[str, Any]  # Evidence supporting the insight
    confidence: int  # 0-100 confidence score


@dataclass
class InsightRule:
    """
    A single rule in the insight system.
    
    Each rule has:
    - Condition: When does this rule fire?
    - Template: What message to generate?
    - Data extractor: What evidence to cite?
    """
    id: int
    name: str
    category: InsightCategory
    priority: InsightPriority
    condition: Callable[[InsightContext], bool]
    template: str
    data_extractor: Callable[[InsightContext], Dict[str, Any]]
    confidence_calculator: Callable[[InsightContext], int]


# =============================================================================
# SECTION 2: GUARDRAILS
# =============================================================================

class InsightGuardrails:
    """
    Safety checks to prevent overinterpretation and harmful outputs.
    All insights must pass these guardrails before being shown.
    """
    
    # Terms that should NEVER appear in insights
    CLINICAL_BLACKLIST = [
        "burnout", "depression", "anxiety", "mental health",
        "therapy", "therapist", "psychiatrist", "diagnosis",
        "disorder", "syndrome", "condition", "treatment"
    ]
    
    MOTIVATIONAL_BLACKLIST = [
        "great job", "well done", "keep it up", "you can do it",
        "proud of you", "amazing", "fantastic", "wonderful",
        "believe in yourself", "stay positive", "don't give up"
    ]
    
    PRESCRIPTIVE_PATTERNS = [
        r"\byou should\b",
        r"\btry to\b",
        r"\byou need to\b",
        r"\byou must\b",
        r"\bmake sure to\b",
        r"\bdon't forget to\b",
        r"\bconsider\b",
        r"\bi recommend\b",
        r"\bi suggest\b",
    ]
    
    # Minimum data requirements
    MIN_CONFIDENCE_THRESHOLD = 60
    MIN_DAYS_FOR_PATTERN = 3
    MIN_DAYS_FOR_TREND = 5
    
    @classmethod
    def validate_message(cls, message: str) -> tuple[bool, Optional[str]]:
        """
        Validate an insight message against all guardrails.
        
        Returns:
            (is_valid, rejection_reason)
        """
        message_lower = message.lower()
        
        # Check clinical terms
        for term in cls.CLINICAL_BLACKLIST:
            if term in message_lower:
                return False, f"Contains clinical term: '{term}'"
        
        # Check motivational language
        for term in cls.MOTIVATIONAL_BLACKLIST:
            if term in message_lower:
                return False, f"Contains motivational language: '{term}'"
        
        # Check prescriptive patterns
        for pattern in cls.PRESCRIPTIVE_PATTERNS:
            if re.search(pattern, message_lower):
                return False, f"Contains prescriptive pattern: '{pattern}'"
        
        return True, None
    
    @classmethod
    def validate_context(cls, ctx: InsightContext, rule: InsightRule) -> tuple[bool, Optional[str]]:
        """
        Validate that we have enough data to generate this insight.
        """
        # Pattern insights need multiple days
        if rule.category == InsightCategory.PATTERN:
            if len(ctx.recent_balances) < cls.MIN_DAYS_FOR_PATTERN:
                return False, f"Insufficient data for pattern (need {cls.MIN_DAYS_FOR_PATTERN} days)"
        
        # Trend insights need even more data
        if rule.category == InsightCategory.TREND:
            if len(ctx.recent_balances) < cls.MIN_DAYS_FOR_TREND:
                return False, f"Insufficient data for trend (need {cls.MIN_DAYS_FOR_TREND} days)"
        
        return True, None


# =============================================================================
# SECTION 3: THE 10 INSIGHT RULES
# =============================================================================

def create_insight_rules() -> List[InsightRule]:
    """
    Define the 10 core insight rules.
    
    Each rule follows the pattern:
    1. WHEN: Specific condition based on data
    2. THEN: Observational statement citing evidence
    3. WHY: Causal explanation of the balance change
    """
    
    rules = []
    
    # -------------------------------------------------------------------------
    # RULE 1: HIGH WITHDRAWAL DAY
    # -------------------------------------------------------------------------
    # Fires when total withdrawals exceed 120 CU (above full capacity)
    rules.append(InsightRule(
        id=1,
        name="HIGH_WITHDRAWAL_DAY",
        category=InsightCategory.OBSERVATION,
        priority=InsightPriority.HIGH,
        condition=lambda ctx: ctx.total_withdrawals > 120,
        template=(
            "Today's withdrawals ({withdrawals:.0f} CU) exceeded a full day's capacity. "
            "The largest contributor was {largest_component} at {largest_cost:.0f} CU."
        ),
        data_extractor=lambda ctx: {
            "withdrawals": ctx.total_withdrawals,
            "largest_component": max(
                [("decision-making", ctx.decision_cost),
                 ("context-switching", ctx.context_cost),
                 ("passive drain", ctx.passive_drain)],
                key=lambda x: x[1]
            )[0],
            "largest_cost": max(ctx.decision_cost, ctx.context_cost, ctx.passive_drain)
        },
        confidence_calculator=lambda ctx: min(95, 70 + int((ctx.total_withdrawals - 120) / 2))
    ))
    
    # -------------------------------------------------------------------------
    # RULE 2: LOW RECOVERY RATIO
    # -------------------------------------------------------------------------
    # Fires when deposits are less than 30% of withdrawals
    rules.append(InsightRule(
        id=2,
        name="LOW_RECOVERY_RATIO",
        category=InsightCategory.OBSERVATION,
        priority=InsightPriority.MEDIUM,
        condition=lambda ctx: (
            ctx.total_withdrawals > 0 and 
            ctx.withdrawal_to_deposit_ratio < 0.30
        ),
        template=(
            "Recovery ({deposits:.0f} CU) covered only {ratio:.0%} of today's withdrawals ({withdrawals:.0f} CU). "
            "The balance dropped by {net_change:.0f} CU as a result."
        ),
        data_extractor=lambda ctx: {
            "deposits": ctx.total_deposits,
            "withdrawals": ctx.total_withdrawals,
            "ratio": ctx.withdrawal_to_deposit_ratio,
            "net_change": abs(ctx.net_change)
        },
        confidence_calculator=lambda ctx: 85
    ))
    
    # -------------------------------------------------------------------------
    # RULE 3: DEFICIT DETECTED
    # -------------------------------------------------------------------------
    # Fires when closing balance goes negative
    rules.append(InsightRule(
        id=3,
        name="DEFICIT_DETECTED",
        category=InsightCategory.OBSERVATION,
        priority=InsightPriority.HIGH,
        condition=lambda ctx: ctx.closing_balance < 0 and ctx.opening_balance >= 0,
        template=(
            "Today's ledger closed at {balance:.0f} CU, entering deficit territory. "
            "This occurred because withdrawals ({withdrawals:.0f} CU) exceeded the opening balance "
            "({opening:.0f} CU) plus recovery ({deposits:.0f} CU)."
        ),
        data_extractor=lambda ctx: {
            "balance": ctx.closing_balance,
            "withdrawals": ctx.total_withdrawals,
            "opening": ctx.opening_balance,
            "deposits": ctx.total_deposits
        },
        confidence_calculator=lambda ctx: 95
    ))
    
    # -------------------------------------------------------------------------
    # RULE 4: CONSECUTIVE DEFICIT DAYS
    # -------------------------------------------------------------------------
    # Fires when in deficit for 2+ consecutive days
    rules.append(InsightRule(
        id=4,
        name="CONSECUTIVE_DEFICIT",
        category=InsightCategory.PATTERN,
        priority=InsightPriority.CRITICAL,
        condition=lambda ctx: (
            ctx.closing_balance < 0 and
            len(ctx.recent_states) >= 2 and
            ctx.recent_states[-1] in ["DEFICIT", "SEVERE_DEFICIT"]
        ),
        template=(
            "This is day {streak} of consecutive deficit. "
            "The cumulative effect is visible in today's reduced opening balance ({opening:.0f} CU) "
            "due to the 20% carryover from yesterday's {prev_balance:.0f} CU deficit."
        ),
        data_extractor=lambda ctx: {
            "streak": sum(1 for s in reversed(ctx.recent_states) 
                        if s in ["DEFICIT", "SEVERE_DEFICIT"]) + 1,
            "opening": ctx.opening_balance,
            "prev_balance": ctx.recent_balances[-1] if ctx.recent_balances else 0
        },
        confidence_calculator=lambda ctx: 90
    ))
    
    # -------------------------------------------------------------------------
    # RULE 5: CONTEXT OVERLOAD
    # -------------------------------------------------------------------------
    # Fires when context-switching costs exceed 40% of total withdrawals
    rules.append(InsightRule(
        id=5,
        name="CONTEXT_OVERLOAD",
        category=InsightCategory.COMPONENT,
        priority=InsightPriority.MEDIUM,
        condition=lambda ctx: (
            ctx.total_withdrawals > 0 and
            (ctx.context_cost / ctx.total_withdrawals) > 0.40
        ),
        template=(
            "Context-switching accounted for {percentage:.0%} of today's cognitive costs ({context:.0f} of {total:.0f} CU). "
            "Each context switch adds incremental load beyond the base cost of each task."
        ),
        data_extractor=lambda ctx: {
            "percentage": ctx.context_cost / ctx.total_withdrawals,
            "context": ctx.context_cost,
            "total": ctx.total_withdrawals
        },
        confidence_calculator=lambda ctx: 80
    ))
    
    # -------------------------------------------------------------------------
    # RULE 6: DECISION FATIGUE
    # -------------------------------------------------------------------------
    # Fires when decision costs exceed 60% of total withdrawals
    rules.append(InsightRule(
        id=6,
        name="DECISION_FATIGUE",
        category=InsightCategory.COMPONENT,
        priority=InsightPriority.MEDIUM,
        condition=lambda ctx: (
            ctx.total_withdrawals > 0 and
            (ctx.decision_cost / ctx.total_withdrawals) > 0.60
        ),
        template=(
            "Decision-making consumed {percentage:.0%} of today's withdrawals ({decision:.0f} of {total:.0f} CU). "
            "High decision volume incurs compounding costs due to the fatigue multiplier."
        ),
        data_extractor=lambda ctx: {
            "percentage": ctx.decision_cost / ctx.total_withdrawals,
            "decision": ctx.decision_cost,
            "total": ctx.total_withdrawals
        },
        confidence_calculator=lambda ctx: 80
    ))
    
    # -------------------------------------------------------------------------
    # RULE 7: PASSIVE DRAIN WARNING
    # -------------------------------------------------------------------------
    # Fires when passive drain exceeds 15 CU (20+ unresolved items)
    rules.append(InsightRule(
        id=7,
        name="PASSIVE_DRAIN_WARNING",
        category=InsightCategory.COMPONENT,
        priority=InsightPriority.MEDIUM,
        condition=lambda ctx: ctx.passive_drain > 15,
        template=(
            "Background cognitive load from unresolved items added {drain:.0f} CU to today's withdrawals. "
            "This passive drain occurs regardless of active work."
        ),
        data_extractor=lambda ctx: {
            "drain": ctx.passive_drain,
            "estimated_items": int(ctx.passive_drain / 0.75)
        },
        confidence_calculator=lambda ctx: 75
    ))
    
    # -------------------------------------------------------------------------
    # RULE 8: RECOVERY SUCCESS
    # -------------------------------------------------------------------------
    # Fires when balance improves after a deficit day
    rules.append(InsightRule(
        id=8,
        name="RECOVERY_SUCCESS",
        category=InsightCategory.PATTERN,
        priority=InsightPriority.LOW,
        condition=lambda ctx: (
            ctx.closing_balance > 0 and
            len(ctx.recent_balances) >= 1 and
            ctx.recent_balances[-1] < 0
        ),
        template=(
            "Today's balance ({balance:.0f} CU) returned to positive after yesterday's deficit ({prev:.0f} CU). "
            "The recovery deposit of {recovery:.0f} CU combined with lower withdrawals ({withdrawals:.0f} CU) "
            "produced a net gain of {net:.0f} CU."
        ),
        data_extractor=lambda ctx: {
            "balance": ctx.closing_balance,
            "prev": ctx.recent_balances[-1],
            "recovery": ctx.total_deposits,
            "withdrawals": ctx.total_withdrawals,
            "net": ctx.net_change
        },
        confidence_calculator=lambda ctx: 85
    ))
    
    # -------------------------------------------------------------------------
    # RULE 9: DECLINING TREND
    # -------------------------------------------------------------------------
    # Fires when 5-day trend shows consistent decline
    rules.append(InsightRule(
        id=9,
        name="DECLINING_TREND",
        category=InsightCategory.TREND,
        priority=InsightPriority.HIGH,
        condition=lambda ctx: (
            len(ctx.recent_balances) >= 5 and
            ctx.trend_slope < -5  # Losing more than 5 CU/day on average
        ),
        template=(
            "The 5-day trend shows an average daily decline of {slope:.1f} CU. "
            "Balances moved from {first:.0f} CU to {last:.0f} CU over this period."
        ),
        data_extractor=lambda ctx: {
            "slope": ctx.trend_slope,
            "first": ctx.recent_balances[0] if ctx.recent_balances else 0,
            "last": ctx.closing_balance
        },
        confidence_calculator=lambda ctx: min(90, 60 + int(abs(ctx.trend_slope) * 2))
    ))
    
    # -------------------------------------------------------------------------
    # RULE 10: STABLE BALANCE
    # -------------------------------------------------------------------------
    # Fires when balance stays within ±10 CU for 3+ days
    rules.append(InsightRule(
        id=10,
        name="STABLE_BALANCE",
        category=InsightCategory.PATTERN,
        priority=InsightPriority.INFO,
        condition=lambda ctx: (
            len(ctx.recent_balances) >= 3 and
            ctx.avg_balance_7d is not None and
            all(abs(b - ctx.avg_balance_7d) < 15 for b in ctx.recent_balances[-3:]) and
            abs(ctx.closing_balance - ctx.avg_balance_7d) < 15
        ),
        template=(
            "Balance has remained stable around {avg:.0f} CU for the past {days} days. "
            "Withdrawals and deposits are approximately matched."
        ),
        data_extractor=lambda ctx: {
            "avg": ctx.avg_balance_7d,
            "days": min(len(ctx.recent_balances), 7) + 1
        },
        confidence_calculator=lambda ctx: 70
    ))
    
    return rules


# =============================================================================
# SECTION 4: INSIGHT ENGINE
# =============================================================================

class InsightEngine:
    """
    The main insight generation engine.
    
    Responsibilities:
    1. Evaluate all rules against current context
    2. Select highest-priority matching rule
    3. Generate insight from template
    4. Validate against guardrails
    5. Return single insight (or None)
    """
    
    def __init__(self):
        self.rules = create_insight_rules()
        self.guardrails = InsightGuardrails()
    
    def generate_insight(self, context: InsightContext) -> Optional[Insight]:
        """
        Generate at most ONE insight for the given context.
        
        Process:
        1. Find all rules whose conditions match
        2. Sort by priority (critical first)
        3. Validate top match against guardrails
        4. Generate and return insight
        """
        # Find matching rules
        matching_rules = []
        for rule in self.rules:
            try:
                if rule.condition(context):
                    # Validate we have enough data
                    is_valid, reason = self.guardrails.validate_context(context, rule)
                    if is_valid:
                        matching_rules.append(rule)
            except Exception:
                # Skip rules that error (defensive)
                continue
        
        if not matching_rules:
            return None
        
        # Sort by priority (lower number = higher priority)
        matching_rules.sort(key=lambda r: r.priority.value)
        
        # Try to generate insight from highest priority rule
        for rule in matching_rules:
            insight = self._generate_from_rule(rule, context)
            if insight:
                return insight
        
        return None
    
    def _generate_from_rule(self, rule: InsightRule, context: InsightContext) -> Optional[Insight]:
        """Generate an insight from a specific rule."""
        try:
            # Extract data points
            data_points = rule.data_extractor(context)
            
            # Format message
            message = rule.template.format(**data_points)
            
            # Validate message against guardrails
            is_valid, reason = self.guardrails.validate_message(message)
            if not is_valid:
                return None
            
            # Calculate confidence
            confidence = rule.confidence_calculator(context)
            if confidence < self.guardrails.MIN_CONFIDENCE_THRESHOLD:
                return None
            
            return Insight(
                rule_id=rule.id,
                rule_name=rule.name,
                category=rule.category,
                priority=rule.priority,
                message=message,
                data_points=data_points,
                confidence=confidence
            )
        except Exception:
            return None
    
    def explain_rules(self) -> str:
        """Return documentation of all rules."""
        lines = ["PCLL Insight Rules", "=" * 50, ""]
        
        for rule in self.rules:
            lines.append(f"Rule {rule.id}: {rule.name}")
            lines.append(f"  Category: {rule.category.value}")
            lines.append(f"  Priority: {rule.priority.name}")
            lines.append(f"  Template: {rule.template[:80]}...")
            lines.append("")
        
        return "\n".join(lines)


# =============================================================================
# SECTION 5: EXAMPLE OUTPUTS
# =============================================================================

def generate_example_outputs():
    """
    Generate example outputs for each of the 10 rules.
    """
    
    examples = [
        # Example 1: HIGH_WITHDRAWAL_DAY
        {
            "rule": "HIGH_WITHDRAWAL_DAY",
            "scenario": "Heavy meeting day with 15 decisions",
            "context": InsightContext(
                date="2025-12-10",
                opening_balance=100,
                closing_balance=15,
                total_withdrawals=145,
                total_deposits=60,
                net_change=-85,
                context_cost=35,
                decision_cost=100,
                passive_drain=10,
                recovery_deposit=60,
                cognitive_state="DEPLETED",
                withdrawal_to_deposit_ratio=0.41,
                recent_balances=[70, 55, 40],
                recent_states=["MODERATE", "MODERATE", "MODERATE"]
            ),
            "expected_output": (
                "Today's withdrawals (145 CU) exceeded a full day's capacity. "
                "The largest contributor was decision-making at 100 CU."
            )
        },
        
        # Example 2: LOW_RECOVERY_RATIO
        {
            "rule": "LOW_RECOVERY_RATIO",
            "scenario": "Poor sleep, minimal recovery",
            "context": InsightContext(
                date="2025-12-11",
                opening_balance=100,
                closing_balance=30,
                total_withdrawals=90,
                total_deposits=20,
                net_change=-70,
                context_cost=25,
                decision_cost=55,
                passive_drain=10,
                recovery_deposit=20,
                cognitive_state="DEPLETED",
                withdrawal_to_deposit_ratio=0.22,
                recent_balances=[80, 60],
                recent_states=["WELL_RESTED", "MODERATE"]
            ),
            "expected_output": (
                "Recovery (20 CU) covered only 22% of today's withdrawals (90 CU). "
                "The balance dropped by 70 CU as a result."
            )
        },
        
        # Example 3: DEFICIT_DETECTED
        {
            "rule": "DEFICIT_DETECTED",
            "scenario": "First day entering deficit",
            "context": InsightContext(
                date="2025-12-12",
                opening_balance=100,
                closing_balance=-25,
                total_withdrawals=160,
                total_deposits=35,
                net_change=-125,
                context_cost=50,
                decision_cost=95,
                passive_drain=15,
                recovery_deposit=35,
                cognitive_state="DEFICIT",
                withdrawal_to_deposit_ratio=0.22,
                recent_balances=[80, 50, 30],
                recent_states=["WELL_RESTED", "MODERATE", "DEPLETED"]
            ),
            "expected_output": (
                "Today's ledger closed at -25 CU, entering deficit territory. "
                "This occurred because withdrawals (160 CU) exceeded the opening balance "
                "(100 CU) plus recovery (35 CU)."
            )
        },
        
        # Example 4: CONSECUTIVE_DEFICIT
        {
            "rule": "CONSECUTIVE_DEFICIT",
            "scenario": "Third day in deficit",
            "context": InsightContext(
                date="2025-12-14",
                opening_balance=88,
                closing_balance=-45,
                total_withdrawals=155,
                total_deposits=22,
                net_change=-133,
                context_cost=45,
                decision_cost=95,
                passive_drain=15,
                recovery_deposit=22,
                cognitive_state="DEFICIT",
                withdrawal_to_deposit_ratio=0.14,
                recent_balances=[30, -20, -60],
                recent_states=["DEPLETED", "DEFICIT", "SEVERE_DEFICIT"]
            ),
            "expected_output": (
                "This is day 3 of consecutive deficit. "
                "The cumulative effect is visible in today's reduced opening balance (88 CU) "
                "due to the 20% carryover from yesterday's -60 CU deficit."
            )
        },
        
        # Example 5: CONTEXT_OVERLOAD
        {
            "rule": "CONTEXT_OVERLOAD",
            "scenario": "Juggling 12 different projects",
            "context": InsightContext(
                date="2025-12-15",
                opening_balance=100,
                closing_balance=40,
                total_withdrawals=100,
                total_deposits=40,
                net_change=-60,
                context_cost=52,  # 52% of withdrawals
                decision_cost=38,
                passive_drain=10,
                recovery_deposit=40,
                cognitive_state="MODERATE",
                withdrawal_to_deposit_ratio=0.40,
                recent_balances=[65, 55, 50],
                recent_states=["MODERATE", "MODERATE", "MODERATE"]
            ),
            "expected_output": (
                "Context-switching accounted for 52% of today's cognitive costs (52 of 100 CU). "
                "Each context switch adds incremental load beyond the base cost of each task."
            )
        },
        
        # Example 6: DECISION_FATIGUE
        {
            "rule": "DECISION_FATIGUE",
            "scenario": "25 decisions in a single day",
            "context": InsightContext(
                date="2025-12-16",
                opening_balance=100,
                closing_balance=10,
                total_withdrawals=130,
                total_deposits=40,
                net_change=-90,
                context_cost=20,
                decision_cost=100,  # 77% of withdrawals
                passive_drain=10,
                recovery_deposit=40,
                cognitive_state="DEPLETED",
                withdrawal_to_deposit_ratio=0.31,
                recent_balances=[80, 60, 40],
                recent_states=["WELL_RESTED", "MODERATE", "MODERATE"]
            ),
            "expected_output": (
                "Decision-making consumed 77% of today's withdrawals (100 of 130 CU). "
                "High decision volume incurs compounding costs due to the fatigue multiplier."
            )
        },
        
        # Example 7: PASSIVE_DRAIN_WARNING
        {
            "rule": "PASSIVE_DRAIN_WARNING",
            "scenario": "30 unresolved items lingering",
            "context": InsightContext(
                date="2025-12-17",
                opening_balance=100,
                closing_balance=50,
                total_withdrawals=90,
                total_deposits=40,
                net_change=-50,
                context_cost=25,
                decision_cost=42,
                passive_drain=23,  # ~30 items × 0.75
                recovery_deposit=40,
                cognitive_state="MODERATE",
                withdrawal_to_deposit_ratio=0.44,
                recent_balances=[70, 60, 55],
                recent_states=["WELL_RESTED", "MODERATE", "MODERATE"]
            ),
            "expected_output": (
                "Background cognitive load from unresolved items added 23 CU to today's withdrawals. "
                "This passive drain occurs regardless of active work."
            )
        },
        
        # Example 8: RECOVERY_SUCCESS
        {
            "rule": "RECOVERY_SUCCESS",
            "scenario": "Weekend recovery after deficit",
            "context": InsightContext(
                date="2025-12-18",
                opening_balance=94,  # Carryover from -30
                closing_balance=72,
                total_withdrawals=70,
                total_deposits=48,
                net_change=-22,
                context_cost=15,
                decision_cost=45,
                passive_drain=10,
                recovery_deposit=48,
                cognitive_state="WELL_RESTED",
                withdrawal_to_deposit_ratio=0.69,
                recent_balances=[40, 10, -30],
                recent_states=["MODERATE", "DEPLETED", "DEFICIT"]
            ),
            "expected_output": (
                "Today's balance (72 CU) returned to positive after yesterday's deficit (-30 CU). "
                "The recovery deposit of 48 CU combined with lower withdrawals (70 CU) "
                "produced a net gain of -22 CU."
            )
        },
        
        # Example 9: DECLINING_TREND
        {
            "rule": "DECLINING_TREND",
            "scenario": "Week of accumulating load",
            "context": InsightContext(
                date="2025-12-19",
                opening_balance=85,
                closing_balance=20,
                total_withdrawals=105,
                total_deposits=40,
                net_change=-65,
                context_cost=30,
                decision_cost=60,
                passive_drain=15,
                recovery_deposit=40,
                cognitive_state="DEPLETED",
                withdrawal_to_deposit_ratio=0.38,
                recent_balances=[90, 75, 55, 40, 25],
                recent_states=["WELL_RESTED", "WELL_RESTED", "MODERATE", "MODERATE", "DEPLETED"],
                trend_slope=-14.0
            ),
            "expected_output": (
                "The 5-day trend shows an average daily decline of -14.0 CU. "
                "Balances moved from 90 CU to 20 CU over this period."
            )
        },
        
        # Example 10: STABLE_BALANCE
        {
            "rule": "STABLE_BALANCE",
            "scenario": "Consistent moderate days",
            "context": InsightContext(
                date="2025-12-20",
                opening_balance=100,
                closing_balance=55,
                total_withdrawals=85,
                total_deposits=40,
                net_change=-45,
                context_cost=25,
                decision_cost=50,
                passive_drain=10,
                recovery_deposit=40,
                cognitive_state="MODERATE",
                withdrawal_to_deposit_ratio=0.47,
                recent_balances=[60, 55, 50, 52, 58],
                recent_states=["MODERATE", "MODERATE", "MODERATE", "MODERATE", "MODERATE"],
                avg_balance_7d=55.0,
                trend_slope=-1.0
            ),
            "expected_output": (
                "Balance has remained stable around 55 CU for the past 6 days. "
                "Withdrawals and deposits are approximately matched."
            )
        }
    ]
    
    return examples


def demonstrate_system():
    """Run a full demonstration of the insight system."""
    
    print("=" * 70)
    print("  PCLL INSIGHT GENERATION SYSTEM - Demonstration")
    print("=" * 70)
    print()
    
    engine = InsightEngine()
    examples = generate_example_outputs()
    
    print("SECTION 1: THE 10 INSIGHT RULES")
    print("-" * 70)
    print()
    
    rules_summary = [
        ("1. HIGH_WITHDRAWAL_DAY", "Withdrawals > 120 CU", "OBSERVATION", "HIGH"),
        ("2. LOW_RECOVERY_RATIO", "Deposits < 30% of withdrawals", "OBSERVATION", "MEDIUM"),
        ("3. DEFICIT_DETECTED", "Balance goes negative", "OBSERVATION", "HIGH"),
        ("4. CONSECUTIVE_DEFICIT", "2+ days in deficit", "PATTERN", "CRITICAL"),
        ("5. CONTEXT_OVERLOAD", "Context costs > 40% total", "COMPONENT", "MEDIUM"),
        ("6. DECISION_FATIGUE", "Decision costs > 60% total", "COMPONENT", "MEDIUM"),
        ("7. PASSIVE_DRAIN_WARNING", "Passive drain > 15 CU", "COMPONENT", "MEDIUM"),
        ("8. RECOVERY_SUCCESS", "Positive after deficit", "PATTERN", "LOW"),
        ("9. DECLINING_TREND", "5-day decline > 5 CU/day", "TREND", "HIGH"),
        ("10. STABLE_BALANCE", "±15 CU for 3+ days", "PATTERN", "INFO"),
    ]
    
    print(f"{'Rule':<30} {'Condition':<30} {'Category':<12} {'Priority':<10}")
    print("-" * 82)
    for rule, condition, category, priority in rules_summary:
        print(f"{rule:<30} {condition:<30} {category:<12} {priority:<10}")
    
    print()
    print()
    print("SECTION 2: EXAMPLE OUTPUTS")
    print("-" * 70)
    print()
    
    for i, example in enumerate(examples, 1):
        print(f"Example {i}: {example['rule']}")
        print(f"  Scenario: {example['scenario']}")
        print()
        
        # Generate actual insight
        insight = engine.generate_insight(example['context'])
        
        if insight:
            print(f"  📊 Generated Insight:")
            print(f"     {insight.message}")
            print(f"     [Confidence: {insight.confidence}%]")
        else:
            print(f"  ⚠️  No insight generated (guardrails blocked or conditions not met)")
        
        print()
        print("  " + "-" * 60)
        print()
    
    print()
    print("SECTION 3: GUARDRAILS")
    print("-" * 70)
    print()
    print("The following safeguards prevent overinterpretation:")
    print()
    
    print("  1. CLINICAL TERM BLACKLIST")
    print("     Blocked terms:", ", ".join(InsightGuardrails.CLINICAL_BLACKLIST[:6]), "...")
    print()
    
    print("  2. MOTIVATIONAL LANGUAGE BLACKLIST")
    print("     Blocked terms:", ", ".join(InsightGuardrails.MOTIVATIONAL_BLACKLIST[:5]), "...")
    print()
    
    print("  3. PRESCRIPTIVE PATTERN DETECTION")
    print("     Blocked patterns: 'you should', 'try to', 'you need to', 'consider'...")
    print()
    
    print("  4. DATA REQUIREMENTS")
    print(f"     - Minimum confidence: {InsightGuardrails.MIN_CONFIDENCE_THRESHOLD}%")
    print(f"     - Pattern insights need: {InsightGuardrails.MIN_DAYS_FOR_PATTERN}+ days of data")
    print(f"     - Trend insights need: {InsightGuardrails.MIN_DAYS_FOR_TREND}+ days of data")
    print()
    
    print("  5. ONE INSIGHT PER DAY")
    print("     Only the highest-priority matching rule generates output.")
    print()
    
    # Test guardrails
    print()
    print("SECTION 4: GUARDRAIL VALIDATION EXAMPLES")
    print("-" * 70)
    print()
    
    test_messages = [
        ("You're experiencing burnout symptoms.", False, "clinical term"),
        ("Great job managing your load today!", False, "motivational"),
        ("You should take a break tomorrow.", False, "prescriptive"),
        ("Today's balance closed at 45 CU.", True, "valid observation"),
        ("Withdrawals exceeded deposits by 30 CU.", True, "valid observation"),
    ]
    
    for message, expected_valid, reason in test_messages:
        is_valid, rejection = InsightGuardrails.validate_message(message)
        status = "✅ PASS" if is_valid else "❌ BLOCKED"
        print(f"  {status}: \"{message[:50]}...\"")
        if not is_valid:
            print(f"           Reason: {rejection}")
        print()
    
    print("=" * 70)
    print("  Demonstration complete.")
    print("=" * 70)


# =============================================================================
# SECTION 6: MAIN
# =============================================================================

if __name__ == "__main__":
    demonstrate_system()
