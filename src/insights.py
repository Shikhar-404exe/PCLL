"""
Insight Generation System for PCLL
====================================

Rule-based insight generation with safety guardrails.
Implements Section 10 of PCLL_System_Definition.md.

Design Philosophy:
- Descriptive, not prescriptive
- Pattern observation, not health assessment
- Neutral language, no motivational content
- Full transparency about limitations
"""

from dataclasses import dataclass
from typing import List, Optional, Callable, Dict, Any
from datetime import datetime

from .models import (
    DailyLedgerEntry,
    WeeklyTrends,
    Insight,
    CognitiveState,
    TrendDirection
)
from .config import SafetyGuardrails, CUConstants, AppSettings


# =============================================================================
# INSIGHT RULE DEFINITIONS
# =============================================================================

@dataclass
class InsightRule:
    """Definition of an insight generation rule."""
    rule_id: int
    name: str
    description: str
    check_function: Callable
    priority: int = 5  # 1=highest, 10=lowest
    min_confidence: int = 70


class InsightGenerator:
    """
    Generates insights from ledger data using rule-based analysis.
    
    All insights are:
    - Descriptive (what patterns exist)
    - Not prescriptive (no "you should" language)
    - Not diagnostic (no health claims)
    - Safety-validated before output
    """
    
    def __init__(self):
        """Initialize with all insight rules."""
        self.rules = self._define_rules()
    
    def _define_rules(self) -> List[InsightRule]:
        """Define all insight generation rules."""
        return [
            InsightRule(
                rule_id=1,
                name="HIGH_WITHDRAWAL_DAY",
                description="Detects days with unusually high cognitive withdrawals",
                check_function=self._check_high_withdrawal,
                priority=2
            ),
            InsightRule(
                rule_id=2,
                name="LOW_RECOVERY_PATTERN",
                description="Detects insufficient recovery relative to withdrawals",
                check_function=self._check_low_recovery,
                priority=1
            ),
            InsightRule(
                rule_id=3,
                name="DEFICIT_DETECTED",
                description="Detects when closing balance is negative",
                check_function=self._check_deficit,
                priority=1
            ),
            InsightRule(
                rule_id=4,
                name="CONSECUTIVE_DEFICIT",
                description="Detects multiple days ending in deficit",
                check_function=self._check_consecutive_deficit,
                priority=1
            ),
            InsightRule(
                rule_id=5,
                name="CONTEXT_OVERLOAD",
                description="Detects high context switching patterns",
                check_function=self._check_context_overload,
                priority=3
            ),
            InsightRule(
                rule_id=6,
                name="DECISION_FATIGUE",
                description="Detects high decision volume",
                check_function=self._check_decision_fatigue,
                priority=3
            ),
            InsightRule(
                rule_id=7,
                name="OPEN_LOOP_ACCUMULATION",
                description="Detects high unresolved task count",
                check_function=self._check_open_loops,
                priority=4
            ),
            InsightRule(
                rule_id=8,
                name="RECOVERY_SUCCESS",
                description="Detects successful recovery from deficit",
                check_function=self._check_recovery_success,
                priority=5
            ),
            InsightRule(
                rule_id=9,
                name="STABLE_PATTERN",
                description="Detects consistent balanced patterns",
                check_function=self._check_stable_pattern,
                priority=6
            ),
            InsightRule(
                rule_id=10,
                name="TREND_CHANGE",
                description="Detects significant changes in balance trends",
                check_function=self._check_trend_change,
                priority=4
            ),
        ]
    
    def generate_daily_insight(
        self,
        entry: DailyLedgerEntry,
        recent_entries: Optional[List[DailyLedgerEntry]] = None,
        trends: Optional[WeeklyTrends] = None
    ) -> Optional[Insight]:
        """
        Generate insight for a single day.
        Returns at most one insight (highest priority match).
        
        Args:
            entry: Today's ledger entry
            recent_entries: Optional list of recent entries for context
            trends: Optional weekly trends for pattern analysis
            
        Returns:
            Single Insight or None if no patterns detected
        """
        if recent_entries is None:
            recent_entries = []
        
        context = InsightContext(
            current_entry=entry,
            recent_entries=recent_entries,
            trends=trends
        )
        
        # Check all rules and collect matches
        matches: List[tuple[InsightRule, Insight]] = []
        
        for rule in self.rules:
            insight = rule.check_function(self, context)
            if insight is not None:
                # Validate against safety guardrails
                if self._validate_insight(insight):
                    matches.append((rule, insight))
        
        if not matches:
            return None
        
        # Return highest priority (lowest number) insight
        matches.sort(key=lambda x: x[0].priority)
        return matches[0][1]
    
    def generate_weekly_insights(
        self,
        entries: List[DailyLedgerEntry],
        trends: WeeklyTrends
    ) -> List[Insight]:
        """
        Generate insights for a week of data.
        
        Args:
            entries: List of daily entries for the week
            trends: Calculated weekly trends
            
        Returns:
            List of insights (max 3)
        """
        if not entries:
            return []
        
        insights: List[Insight] = []
        
        # Generate insight for most recent day with full context
        daily_insight = self.generate_daily_insight(
            entry=entries[-1],
            recent_entries=entries[:-1],
            trends=trends
        )
        if daily_insight:
            insights.append(daily_insight)
        
        # Add trend-based insights
        trend_insights = self._generate_trend_insights(trends, entries[-1].date)
        insights.extend(trend_insights)
        
        # Limit to max 3 insights
        return insights[:3]
    
    def _validate_insight(self, insight: Insight) -> bool:
        """
        Validate insight against safety guardrails.
        
        Args:
            insight: The insight to validate
            
        Returns:
            True if insight passes all safety checks
        """
        is_valid, violations = SafetyGuardrails.validate_text(insight.message)
        
        if not is_valid:
            # Log violations (in production, this would go to monitoring)
            print(f"Insight validation failed: {violations}")
            return False
        
        return True
    
    # =========================================================================
    # RULE CHECK FUNCTIONS
    # =========================================================================
    
    def _check_high_withdrawal(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 1: Detect unusually high withdrawal days."""
        entry = context.current_entry
        
        # High withdrawal threshold: >120 CU (above baseline capacity)
        if entry.total_withdrawals > 120:
            return Insight(
                date=entry.date,
                rule_id=1,
                rule_name="HIGH_WITHDRAWAL_DAY",
                message=(
                    f"Today's logged activities totaled {entry.total_withdrawals:.0f} CU "
                    f"in estimated cognitive demand, which exceeds the typical daily "
                    f"capacity of 100 CU."
                ),
                confidence=85,
                data_points={
                    'total_withdrawals': entry.total_withdrawals,
                    'threshold': 120
                }
            )
        return None
    
    def _check_low_recovery(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 2: Detect insufficient recovery patterns."""
        entry = context.current_entry
        
        # Low recovery: deposits < 25% of withdrawals
        if entry.total_withdrawals > 0:
            ratio = entry.total_deposits / entry.total_withdrawals
            if ratio < 0.25:
                return Insight(
                    date=entry.date,
                    rule_id=2,
                    rule_name="LOW_RECOVERY_PATTERN",
                    message=(
                        f"Recovery activities ({entry.total_deposits:.0f} CU) "
                        f"were {ratio:.0%} of withdrawal activities "
                        f"({entry.total_withdrawals:.0f} CU) today."
                    ),
                    confidence=80,
                    data_points={
                        'deposits': entry.total_deposits,
                        'withdrawals': entry.total_withdrawals,
                        'ratio': ratio
                    }
                )
        return None
    
    def _check_deficit(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 3: Detect negative closing balance."""
        entry = context.current_entry
        
        if entry.closing_balance < 0:
            severity = "significantly " if entry.closing_balance < -50 else ""
            return Insight(
                date=entry.date,
                rule_id=3,
                rule_name="DEFICIT_DETECTED",
                message=(
                    f"Today's ledger closed at {entry.closing_balance:.0f} CU, "
                    f"indicating logged withdrawals {severity}exceeded "
                    f"available capacity plus recovery."
                ),
                confidence=90,
                data_points={
                    'closing_balance': entry.closing_balance,
                    'opening_balance': entry.opening_balance
                }
            )
        return None
    
    def _check_consecutive_deficit(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 4: Detect multiple consecutive deficit days."""
        if not context.recent_entries:
            return None
        
        # Count recent deficit days
        deficit_days = sum(
            1 for e in context.recent_entries 
            if e.closing_balance < 0
        )
        
        # Also check current day
        if context.current_entry.closing_balance < 0:
            deficit_days += 1
        
        if deficit_days >= 3:
            return Insight(
                date=context.current_entry.date,
                rule_id=4,
                rule_name="CONSECUTIVE_DEFICIT",
                message=(
                    f"The ledger shows {deficit_days} days ending in deficit "
                    f"within the recent tracking period. This pattern indicates "
                    f"logged withdrawals have consistently exceeded recovery."
                ),
                confidence=85,
                data_points={
                    'deficit_days': deficit_days,
                    'period_days': len(context.recent_entries) + 1
                }
            )
        return None
    
    def _check_context_overload(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 5: Detect high context switching."""
        entry = context.current_entry
        
        # Check if context cost is a major contributor (>40% of withdrawals)
        if entry.total_withdrawals > 0:
            context_ratio = entry.components.context_cost / entry.total_withdrawals
            if context_ratio > 0.4 and entry.components.context_cost > 30:
                return Insight(
                    date=entry.date,
                    rule_id=5,
                    rule_name="CONTEXT_OVERLOAD",
                    message=(
                        f"Context switching accounted for {context_ratio:.0%} "
                        f"of today's logged cognitive demand "
                        f"({entry.components.context_cost:.0f} CU)."
                    ),
                    confidence=75,
                    data_points={
                        'context_cost': entry.components.context_cost,
                        'ratio': context_ratio
                    }
                )
        return None
    
    def _check_decision_fatigue(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 6: Detect high decision volume."""
        entry = context.current_entry
        
        # High decision cost: >60 CU from decisions alone
        if entry.components.decision_cost > 60:
            return Insight(
                date=entry.date,
                rule_id=6,
                rule_name="DECISION_FATIGUE",
                message=(
                    f"Decision-making activities contributed "
                    f"{entry.components.decision_cost:.0f} CU to today's ledger, "
                    f"indicating a high volume of deliberative choices were logged."
                ),
                confidence=75,
                data_points={
                    'decision_cost': entry.components.decision_cost
                }
            )
        return None
    
    def _check_open_loops(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 7: Detect high passive drain from unresolved items."""
        entry = context.current_entry
        
        # High passive drain: >20 CU
        if entry.components.passive_drain > 20:
            return Insight(
                date=entry.date,
                rule_id=7,
                rule_name="OPEN_LOOP_ACCUMULATION",
                message=(
                    f"Unresolved items contributed {entry.components.passive_drain:.0f} CU "
                    f"of passive drain to today's ledger balance."
                ),
                confidence=70,
                data_points={
                    'passive_drain': entry.components.passive_drain
                }
            )
        return None
    
    def _check_recovery_success(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 8: Detect successful recovery from deficit."""
        if not context.recent_entries:
            return None
        
        entry = context.current_entry
        
        # Check if previous day was deficit and today is positive
        if len(context.recent_entries) >= 1:
            prev_entry = context.recent_entries[-1]
            if prev_entry.closing_balance < 0 and entry.closing_balance >= 30:
                return Insight(
                    date=entry.date,
                    rule_id=8,
                    rule_name="RECOVERY_SUCCESS",
                    message=(
                        f"Today's balance ({entry.closing_balance:.0f} CU) shows recovery "
                        f"from yesterday's deficit ({prev_entry.closing_balance:.0f} CU)."
                    ),
                    confidence=85,
                    data_points={
                        'today_balance': entry.closing_balance,
                        'yesterday_balance': prev_entry.closing_balance
                    }
                )
        return None
    
    def _check_stable_pattern(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 9: Detect consistent balanced patterns."""
        if context.trends is None:
            return None
        
        trends = context.trends
        
        # Stable: low volatility, no deficit days, positive average
        if (trends.volatility < 20 and 
            trends.deficit_days == 0 and 
            trends.avg_closing_balance >= 40):
            return Insight(
                date=context.current_entry.date,
                rule_id=9,
                rule_name="STABLE_PATTERN",
                message=(
                    f"The past {trends.days_analyzed} days show a consistent pattern "
                    f"with average closing balance of {trends.avg_closing_balance:.0f} CU "
                    f"and low variability."
                ),
                confidence=80,
                data_points={
                    'avg_balance': trends.avg_closing_balance,
                    'volatility': trends.volatility,
                    'days': trends.days_analyzed
                }
            )
        return None
    
    def _check_trend_change(self, context: 'InsightContext') -> Optional[Insight]:
        """Rule 10: Detect significant trend changes."""
        if context.trends is None:
            return None
        
        trends = context.trends
        
        # Significant improving trend
        if trends.trend_direction == TrendDirection.RAPIDLY_IMPROVING:
            return Insight(
                date=context.current_entry.date,
                rule_id=10,
                rule_name="TREND_CHANGE",
                message=(
                    f"Balance trend over {trends.days_analyzed} days shows "
                    f"improvement (slope: +{trends.balance_slope:.1f} CU/day)."
                ),
                confidence=75,
                data_points={
                    'slope': trends.balance_slope,
                    'trend': trends.trend_direction.value
                }
            )
        
        # Significant deteriorating trend
        if trends.trend_direction == TrendDirection.DETERIORATING:
            return Insight(
                date=context.current_entry.date,
                rule_id=10,
                rule_name="TREND_CHANGE",
                message=(
                    f"Balance trend over {trends.days_analyzed} days shows "
                    f"decline (slope: {trends.balance_slope:.1f} CU/day)."
                ),
                confidence=75,
                data_points={
                    'slope': trends.balance_slope,
                    'trend': trends.trend_direction.value
                }
            )
        
        return None
    
    def _generate_trend_insights(
        self, 
        trends: WeeklyTrends,
        date: str
    ) -> List[Insight]:
        """Generate insights from weekly trends."""
        insights = []
        
        # Low recovery ratio insight
        if trends.recovery_ratio < 0.3:
            insight = Insight(
                date=date,
                rule_id=2,
                rule_name="WEEKLY_LOW_RECOVERY",
                message=(
                    f"Over {trends.days_analyzed} days, recovery activities "
                    f"({trends.avg_deposits:.0f} CU/day avg) were {trends.recovery_ratio:.0%} "
                    f"of withdrawal activities ({trends.avg_withdrawals:.0f} CU/day avg)."
                ),
                confidence=80,
                data_points={
                    'recovery_ratio': trends.recovery_ratio,
                    'avg_deposits': trends.avg_deposits,
                    'avg_withdrawals': trends.avg_withdrawals
                }
            )
            if self._validate_insight(insight):
                insights.append(insight)
        
        # High volatility insight
        if trends.volatility > 40:
            insight = Insight(
                date=date,
                rule_id=10,
                rule_name="HIGH_VOLATILITY",
                message=(
                    f"Daily closing balances varied significantly "
                    f"(volatility: {trends.volatility:.0f}) over the past "
                    f"{trends.days_analyzed} days."
                ),
                confidence=70,
                data_points={
                    'volatility': trends.volatility
                }
            )
            if self._validate_insight(insight):
                insights.append(insight)
        
        return insights


@dataclass
class InsightContext:
    """Context data passed to rule check functions."""
    current_entry: DailyLedgerEntry
    recent_entries: List[DailyLedgerEntry]
    trends: Optional[WeeklyTrends] = None


# =============================================================================
# HELPER FUNCTIONS
# =============================================================================

def format_insight_display(insight: Insight) -> str:
    """
    Format an insight for display.
    
    Args:
        insight: Insight to format
        
    Returns:
        Formatted string
    """
    # Icon based on rule type
    icons = {
        "HIGH_WITHDRAWAL_DAY": "📊",
        "LOW_RECOVERY_PATTERN": "⚖️",
        "DEFICIT_DETECTED": "📉",
        "CONSECUTIVE_DEFICIT": "⚠️",
        "CONTEXT_OVERLOAD": "🔀",
        "DECISION_FATIGUE": "🤔",
        "OPEN_LOOP_ACCUMULATION": "📋",
        "RECOVERY_SUCCESS": "✅",
        "STABLE_PATTERN": "📈",
        "TREND_CHANGE": "📊",
        "WEEKLY_LOW_RECOVERY": "⚖️",
        "HIGH_VOLATILITY": "📊"
    }
    
    icon = icons.get(insight.rule_name, "ℹ️")
    
    return f"{icon} {insight.message}"


def get_insight_category(insight: Insight) -> str:
    """
    Categorize insight for grouping.
    
    Args:
        insight: Insight to categorize
        
    Returns:
        Category string
    """
    warning_rules = {1, 2, 3, 4, 5, 6, 7}
    positive_rules = {8, 9}
    
    if insight.rule_id in warning_rules:
        return "OBSERVATION"
    elif insight.rule_id in positive_rules:
        return "PATTERN"
    else:
        return "TREND"
