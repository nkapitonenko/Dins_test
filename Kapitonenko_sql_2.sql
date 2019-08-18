SELECT active_users.UID,
       active_users.Name,
       SUM(active_users.Call_time) AS Call_time
FROM
  (SELECT users_call_logs.UID,
          accounts.Name,
          users_call_logs.Call_time
   FROM
     (SELECT numbers.UID,
             numbers.Phone_Number,
             call_logs_sum.Call_time
      FROM numbers
      INNER JOIN
        (SELECT call_logs_sum.
         FROM AS Number, ceiling((call_logs_sum.Timestamp_end - call_logs_sum.Timestamp_start)/100) AS Call_time
         FROM
           (SELECT call_logs.Call_id,
                   call_logs.Call_dir,
                   call_logs.FROM,
                   ifnull(call_forwarding.To, call_logs.To) AS 'To',
                   call_logs.UID,
                   call_logs.Timestamp_start,
                   call_logs.Timestamp_end
            FROM call_logs
            LEFT JOIN call_forwarding ON call_logs.To = call_forwarding.FROM) AS call_logs_sum) AS call_logs_sum ON numbers.Phone_Number = call_logs_sum.Number) AS users_call_logs
   INNER JOIN accounts ON users_call_logs.UID = accounts.UID) AS active_users
GROUP BY active_users.UID
ORDER BY Call_time DESC
LIMIT 10