SELECT (SUM(redirected.Call_time)*
          (SELECT MONEY
           FROM rates
           WHERE ID = 3)) AS Total_expenses
FROM
  (SELECT redirected.Call_id,
          redirected.Call_dir,
          redirected.From,
		  redirected.To,
		  redirected.UID,
		  ceiling((redirected.Timestamp_end - redirected.Timestamp_start)/100) AS Call_time
   FROM
     (SELECT call_logs.Call_id,
             call_logs.Call_dir,
             call_logs.From,
             ifnull(call_forwarding.To, call_logs.To) AS 'To',
             call_logs.UID,
             call_logs.Timestamp_start,
             call_logs.Timestamp_end
      FROM call_logs
      LEFT JOIN call_forwarding ON call_logs.To = call_forwarding.From
      WHERE Call_dir = 'out') AS redirected
   LEFT JOIN numbers ON redirected.To = numbers.Phone_Number
   WHERE numbers.UID IS NULL) AS redirected