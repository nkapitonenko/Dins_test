SELECT numbers_call_time.UID,
       numbers_call_time.Phone_Number,
       accounts.Name,
       numbers_call_time.Call_charges
FROM
  (SELECT numbers.Phone_Number,
          numbers.UID,
          users_call_time.Call_charges
   FROM
     (SELECT call_logs_out.From,
            (ceiling((call_logs_out.Timestamp_end - call_logs_out.Timestamp_start)/100)) *
        (SELECT MONEY
         FROM rates
         WHERE ID = 3) AS Call_charges
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
         WHERE Call_dir = 'out') AS call_logs_out
      LEFT JOIN numbers ON call_logs_out.To = numbers.Phone_Number
      WHERE numbers.UID IS NULL) AS users_call_time
   INNER JOIN numbers ON users_call_time.From = numbers.Phone_Number) AS numbers_call_time
INNER JOIN accounts ON numbers_call_time.UID = accounts.UID
GROUP BY UID
ORDER BY Call_charges DESC
LIMIT 10