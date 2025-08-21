									  CREATE EVENT SESSION DeadlockSession ON SERVE            R
ADD EVENT sqlserver.xml_deadlock_report
ADD TARGET package0.event_file (SET filename = 'C:\_SQLBACKUP\Deadlocks.xel')
WITH (STARTUP_STATE = ON);
GO
ALTER EVENT SESSION DeadlockSession ON SERVER STATE = START;
				                                                