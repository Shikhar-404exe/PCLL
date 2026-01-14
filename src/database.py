"""
SQLite Persistence Layer for PCLL
===================================

Local database storage for ledger entries, user profiles, and insights.
Uses Python's built-in sqlite3 module (no external dependencies).

Features:
- Persistent storage of daily ledger entries
- User profile management with calibration data
- Insight history tracking
- Data export capabilities
"""

import sqlite3
import json
from datetime import datetime
from pathlib import Path
from typing import List, Optional, Dict, Any
from contextlib import contextmanager

from .models import (
    DailyInput,
    DailyLedgerEntry,
    ComponentBreakdown,
    CognitiveState,
    UserProfile,
    Insight
)
from .config import AppSettings


class PCLLDatabase:
    """
    SQLite database manager for PCLL.
    Handles all persistence operations for the ledger system.
    """
    
    def __init__(self, db_path: Optional[str] = None):
        """
        Initialize database connection.
        
        Args:
            db_path: Path to SQLite database file.
                     If None, uses default from AppSettings.
                     Use ":memory:" for in-memory database.
        """
        if db_path is None:
            db_path = AppSettings.DEFAULT_DB_PATH
        
        self.db_path = db_path
        
        # Create directory if needed (unless in-memory)
        if db_path != ":memory:":
            Path(db_path).parent.mkdir(parents=True, exist_ok=True)
        
        # Initialize schema
        self._init_schema()
    
    @contextmanager
    def _get_connection(self):
        """
        Context manager for database connections.
        Ensures proper connection handling and commits.
        """
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row  # Enable column access by name
        try:
            yield conn
            conn.commit()
        except Exception:
            conn.rollback()
            raise
        finally:
            conn.close()
    
    def _init_schema(self) -> None:
        """Create database tables if they don't exist."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            # Daily ledger entries table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS ledger_entries (
                    date TEXT PRIMARY KEY,
                    opening_balance REAL NOT NULL,
                    closing_balance REAL NOT NULL,
                    total_withdrawals REAL NOT NULL,
                    total_deposits REAL NOT NULL,
                    net_change REAL NOT NULL,
                    cognitive_state TEXT NOT NULL,
                    components_json TEXT NOT NULL,
                    confidence INTEGER NOT NULL,
                    created_at TEXT NOT NULL
                )
            ''')
            
            # Daily inputs table (raw user input)
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS daily_inputs (
                    date TEXT PRIMARY KEY,
                    context_count INTEGER NOT NULL,
                    decision_count INTEGER NOT NULL,
                    unresolved_count INTEGER NOT NULL,
                    recovery_quality INTEGER NOT NULL,
                    subjective_depletion INTEGER,
                    text_note TEXT,
                    created_at TEXT NOT NULL
                )
            ''')
            
            # User profiles table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS user_profiles (
                    user_id TEXT PRIMARY KEY,
                    created_at TEXT NOT NULL,
                    is_calibrated INTEGER NOT NULL DEFAULT 0,
                    calibration_date TEXT,
                    days_logged INTEGER NOT NULL DEFAULT 0,
                    context_base_cost REAL NOT NULL DEFAULT 2.0,
                    context_switch_cost REAL NOT NULL DEFAULT 1.5,
                    decision_base_cost REAL NOT NULL DEFAULT 8.0,
                    passive_base_cost REAL NOT NULL DEFAULT 0.75,
                    recovery_base REAL NOT NULL DEFAULT 40.0,
                    disclaimer_accepted INTEGER NOT NULL DEFAULT 0,
                    disclaimer_accepted_date TEXT
                )
            ''')
            
            # Insights table
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS insights (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    rule_id INTEGER NOT NULL,
                    rule_name TEXT NOT NULL,
                    message TEXT NOT NULL,
                    confidence INTEGER NOT NULL,
                    data_points_json TEXT,
                    created_at TEXT NOT NULL
                )
            ''')
            
            # Create indexes for common queries
            cursor.execute('''
                CREATE INDEX IF NOT EXISTS idx_entries_date 
                ON ledger_entries(date)
            ''')
            cursor.execute('''
                CREATE INDEX IF NOT EXISTS idx_insights_date 
                ON insights(date)
            ''')
    
    # =========================================================================
    # LEDGER ENTRY OPERATIONS
    # =========================================================================
    
    def save_entry(self, entry: DailyLedgerEntry) -> None:
        """
        Save or update a daily ledger entry.
        
        Args:
            entry: DailyLedgerEntry to save
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO ledger_entries 
                (date, opening_balance, closing_balance, total_withdrawals,
                 total_deposits, net_change, cognitive_state, components_json,
                 confidence, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                entry.date,
                entry.opening_balance,
                entry.closing_balance,
                entry.total_withdrawals,
                entry.total_deposits,
                entry.net_change,
                entry.cognitive_state.value,
                json.dumps(entry.components.to_dict()),
                entry.confidence,
                entry.created_at
            ))
    
    def get_entry(self, date: str) -> Optional[DailyLedgerEntry]:
        """
        Retrieve a ledger entry by date.
        
        Args:
            date: Date string (YYYY-MM-DD)
            
        Returns:
            DailyLedgerEntry if found, None otherwise
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute(
                'SELECT * FROM ledger_entries WHERE date = ?',
                (date,)
            )
            row = cursor.fetchone()
            
            if row is None:
                return None
            
            return self._row_to_entry(row)
    
    def get_entries_range(
        self, 
        start_date: str, 
        end_date: str
    ) -> List[DailyLedgerEntry]:
        """
        Get entries within a date range.
        
        Args:
            start_date: Start date (inclusive)
            end_date: End date (inclusive)
            
        Returns:
            List of entries sorted by date
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM ledger_entries 
                WHERE date >= ? AND date <= ?
                ORDER BY date ASC
            ''', (start_date, end_date))
            
            return [self._row_to_entry(row) for row in cursor.fetchall()]
    
    def get_recent_entries(self, days: int = 7) -> List[DailyLedgerEntry]:
        """
        Get the most recent N entries.
        
        Args:
            days: Maximum number of entries to retrieve
            
        Returns:
            List of entries sorted by date (oldest first)
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM ledger_entries 
                ORDER BY date DESC
                LIMIT ?
            ''', (days,))
            
            entries = [self._row_to_entry(row) for row in cursor.fetchall()]
            return list(reversed(entries))  # Return oldest first
    
    def get_all_entries(self) -> List[DailyLedgerEntry]:
        """Get all ledger entries."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('SELECT * FROM ledger_entries ORDER BY date ASC')
            return [self._row_to_entry(row) for row in cursor.fetchall()]
    
    def delete_entry(self, date: str) -> bool:
        """
        Delete an entry by date.
        
        Args:
            date: Date string
            
        Returns:
            True if entry was deleted, False if not found
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('DELETE FROM ledger_entries WHERE date = ?', (date,))
            return cursor.rowcount > 0
    
    def _row_to_entry(self, row: sqlite3.Row) -> DailyLedgerEntry:
        """Convert a database row to DailyLedgerEntry."""
        components_dict = json.loads(row['components_json'])
        
        return DailyLedgerEntry(
            date=row['date'],
            opening_balance=row['opening_balance'],
            closing_balance=row['closing_balance'],
            total_withdrawals=row['total_withdrawals'],
            total_deposits=row['total_deposits'],
            net_change=row['net_change'],
            cognitive_state=CognitiveState(row['cognitive_state']),
            components=ComponentBreakdown.from_dict(components_dict),
            confidence=row['confidence'],
            created_at=row['created_at']
        )
    
    # =========================================================================
    # DAILY INPUT OPERATIONS
    # =========================================================================
    
    def save_daily_input(self, daily_input: DailyInput) -> None:
        """
        Save raw daily input for reference.
        
        Args:
            daily_input: User's daily input
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO daily_inputs
                (date, context_count, decision_count, unresolved_count,
                 recovery_quality, subjective_depletion, text_note, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                daily_input.date,
                daily_input.context_count,
                daily_input.decision_count,
                daily_input.unresolved_count,
                daily_input.recovery_quality,
                daily_input.subjective_depletion,
                daily_input.text_note,
                datetime.now().isoformat()
            ))
    
    def get_daily_input(self, date: str) -> Optional[DailyInput]:
        """
        Retrieve raw daily input by date.
        
        Args:
            date: Date string
            
        Returns:
            DailyInput if found, None otherwise
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute(
                'SELECT * FROM daily_inputs WHERE date = ?',
                (date,)
            )
            row = cursor.fetchone()
            
            if row is None:
                return None
            
            return DailyInput(
                date=row['date'],
                context_count=row['context_count'],
                decision_count=row['decision_count'],
                unresolved_count=row['unresolved_count'],
                recovery_quality=row['recovery_quality'],
                subjective_depletion=row['subjective_depletion'],
                text_note=row['text_note']
            )
    
    # =========================================================================
    # USER PROFILE OPERATIONS
    # =========================================================================
    
    def save_profile(self, profile: UserProfile) -> None:
        """
        Save or update user profile.
        
        Args:
            profile: UserProfile to save
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT OR REPLACE INTO user_profiles
                (user_id, created_at, is_calibrated, calibration_date,
                 days_logged, context_base_cost, context_switch_cost,
                 decision_base_cost, passive_base_cost, recovery_base,
                 disclaimer_accepted, disclaimer_accepted_date)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                profile.user_id,
                profile.created_at,
                1 if profile.is_calibrated else 0,
                profile.calibration_date,
                profile.days_logged,
                profile.context_base_cost,
                profile.context_switch_cost,
                profile.decision_base_cost,
                profile.passive_base_cost,
                profile.recovery_base,
                1 if profile.disclaimer_accepted else 0,
                profile.disclaimer_accepted_date
            ))
    
    def get_profile(self, user_id: str) -> Optional[UserProfile]:
        """
        Retrieve user profile.
        
        Args:
            user_id: User identifier
            
        Returns:
            UserProfile if found, None otherwise
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute(
                'SELECT * FROM user_profiles WHERE user_id = ?',
                (user_id,)
            )
            row = cursor.fetchone()
            
            if row is None:
                return None
            
            return UserProfile(
                user_id=row['user_id'],
                created_at=row['created_at'],
                is_calibrated=bool(row['is_calibrated']),
                calibration_date=row['calibration_date'],
                days_logged=row['days_logged'],
                context_base_cost=row['context_base_cost'],
                context_switch_cost=row['context_switch_cost'],
                decision_base_cost=row['decision_base_cost'],
                passive_base_cost=row['passive_base_cost'],
                recovery_base=row['recovery_base'],
                disclaimer_accepted=bool(row['disclaimer_accepted']),
                disclaimer_accepted_date=row['disclaimer_accepted_date']
            )
    
    def get_or_create_profile(self, user_id: str) -> UserProfile:
        """
        Get existing profile or create new one with defaults.
        
        Args:
            user_id: User identifier
            
        Returns:
            UserProfile (existing or newly created)
        """
        profile = self.get_profile(user_id)
        if profile is None:
            profile = UserProfile(
                user_id=user_id,
                created_at=datetime.now().isoformat()
            )
            self.save_profile(profile)
        return profile
    
    def increment_days_logged(self, user_id: str) -> None:
        """Increment the days_logged counter for a user."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                UPDATE user_profiles 
                SET days_logged = days_logged + 1
                WHERE user_id = ?
            ''', (user_id,))
    
    # =========================================================================
    # INSIGHT OPERATIONS
    # =========================================================================
    
    def save_insight(self, insight: Insight) -> int:
        """
        Save an insight.
        
        Args:
            insight: Insight to save
            
        Returns:
            Inserted row ID
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute('''
                INSERT INTO insights
                (date, rule_id, rule_name, message, confidence, 
                 data_points_json, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ''', (
                insight.date,
                insight.rule_id,
                insight.rule_name,
                insight.message,
                insight.confidence,
                json.dumps(insight.data_points),
                datetime.now().isoformat()
            ))
            
            return cursor.lastrowid
    
    def get_insights_for_date(self, date: str) -> List[Insight]:
        """
        Get all insights for a specific date.
        
        Args:
            date: Date string
            
        Returns:
            List of Insight objects
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute(
                'SELECT * FROM insights WHERE date = ? ORDER BY id',
                (date,)
            )
            
            return [self._row_to_insight(row) for row in cursor.fetchall()]
    
    def get_recent_insights(self, limit: int = 10) -> List[Insight]:
        """
        Get most recent insights.
        
        Args:
            limit: Maximum number to retrieve
            
        Returns:
            List of Insight objects
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT * FROM insights 
                ORDER BY date DESC, id DESC
                LIMIT ?
            ''', (limit,))
            
            return [self._row_to_insight(row) for row in cursor.fetchall()]
    
    def _row_to_insight(self, row: sqlite3.Row) -> Insight:
        """Convert database row to Insight."""
        data_points = {}
        if row['data_points_json']:
            data_points = json.loads(row['data_points_json'])
        
        return Insight(
            date=row['date'],
            rule_id=row['rule_id'],
            rule_name=row['rule_name'],
            message=row['message'],
            confidence=row['confidence'],
            data_points=data_points
        )
    
    # =========================================================================
    # UTILITY OPERATIONS
    # =========================================================================
    
    def clear_all(self) -> None:
        """Clear all data from all tables. Use with caution!"""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('DELETE FROM ledger_entries')
            cursor.execute('DELETE FROM daily_inputs')
            cursor.execute('DELETE FROM insights')
            # Note: Don't delete user_profiles by default
    
    def get_entry_count(self) -> int:
        """Get total number of ledger entries."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('SELECT COUNT(*) FROM ledger_entries')
            return cursor.fetchone()[0]
    
    def get_date_range(self) -> Optional[tuple[str, str]]:
        """
        Get the date range of stored entries.
        
        Returns:
            Tuple of (earliest_date, latest_date) or None if empty
        """
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute('''
                SELECT MIN(date), MAX(date) FROM ledger_entries
            ''')
            row = cursor.fetchone()
            if row[0] is None:
                return None
            return (row[0], row[1])
    
    def export_all_data(self) -> Dict[str, Any]:
        """
        Export all data for backup.
        
        Returns:
            Dictionary with all tables' data
        """
        entries = self.get_all_entries()
        
        with self._get_connection() as conn:
            cursor = conn.cursor()
            
            # Get all daily inputs
            cursor.execute('SELECT * FROM daily_inputs ORDER BY date')
            inputs = [dict(row) for row in cursor.fetchall()]
            
            # Get all insights
            cursor.execute('SELECT * FROM insights ORDER BY date, id')
            insights = [dict(row) for row in cursor.fetchall()]
            
            # Get all profiles
            cursor.execute('SELECT * FROM user_profiles')
            profiles = [dict(row) for row in cursor.fetchall()]
        
        return {
            'exported_at': datetime.now().isoformat(),
            'ledger_entries': [e.to_dict() for e in entries],
            'daily_inputs': inputs,
            'insights': insights,
            'user_profiles': profiles
        }
    
    def vacuum(self) -> None:
        """Optimize database file size."""
        with self._get_connection() as conn:
            conn.execute('VACUUM')


# =============================================================================
# FACTORY FUNCTION
# =============================================================================

def create_database(db_path: Optional[str] = None) -> PCLLDatabase:
    """
    Create a database instance.
    
    Args:
        db_path: Path to database file (None for default, ":memory:" for in-memory)
        
    Returns:
        Initialized PCLLDatabase
    """
    return PCLLDatabase(db_path)


def create_memory_database() -> PCLLDatabase:
    """Create an in-memory database (useful for testing)."""
    return PCLLDatabase(":memory:")
