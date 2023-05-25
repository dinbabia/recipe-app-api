"""
Test custom Django management commands.
"""
from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase


@patch("core.management.commands.wait_for_db.Command.check")
class CommandTest(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for database if database ready."""
        # When Command.check is called, just return True
        patched_check.return_value = True

        call_command('wait_for_db')

        # Making sure we are calling the correct DB
        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_delay(self, patched_sleep, patched_check):
        """Test waiting for database when getting OperationError."""

        # 2 and 3 are just random number of Errors
        # The 6th(1-5 calls are from *2 + *3 Errors) time you call it,
        # return True
        patched_check.side_effect = [Psycopg2Error] * 2 \
            + [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        # Total of 6 calls. 2 Psycpg2 Error, 3 OperationErrors and 1 True
        self.assertEqual(patched_check.call_count, 6)

        # Making sure we are calling the correct DB
        patched_check.assert_called_with(databases=['default'])
