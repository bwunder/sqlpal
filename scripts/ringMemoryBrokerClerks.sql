WITH MemoryBrokerClerksCte
AS (
           -- select & run this query for a list of records in the queue
    SELECT ROW_NUMBER() OVER (ORDER BY Buffer.Record.value( '@time', 'BIGINT' )
                                     , Buffer.Record.value( '@id', 'INT' ) ) AS [RowNumber]
         , Data.ring_buffer_type AS [Type]
         , Buffer.Record.value( '(MemoryBrokerClerk/Name)[1]', 'NVARCHAR(128)' ) AS Name
         , Buffer.Record.value( '(MemoryBrokerClerk/TotalPages)[1]', 'INT' ) AS TotalPages
         , Buffer.Record.value( '@time', 'BIGINT' ) AS [time]
         , Buffer.Record.value( '@id', 'INT' ) AS [Id]
         , Data.EventXML
    FROM (SELECT CAST(Record AS XML) AS EventXML
               , ring_buffer_type
          FROM sys.dm_os_ring_buffers
          WHERE ring_buffer_type = 'RING_BUFFER_MEMORY_BROKER_CLERKS' ) AS Data
    CROSS APPLY EventXML.nodes('//Record') AS Buffer(Record)
   )
SELECT first.[Type]
     , summary.[Name]
     , summary.[TotalPages]
     , summary.[count]
     , DATEADD( second
               , first.[Time] - info.ms_ticks / 1000
               , CURRENT_TIMESTAMP ) AS [FirstTime]
     , DATEADD( second
               , last.[Time] - info.ms_ticks / 1000
               , CURRENT_TIMESTAMP ) AS [LastTime]
--     , first.EventXML AS [FirstRecord]
--     , last.EventXML AS [LastRecord]
FROM (SELECT [Name]
           , [TotalPages]
           , COUNT(*) AS [count]
           , MIN(RowNumber) AS [FirstRow]
           , MAX(RowNumber) AS [LastRow]
      FROM MemoryBrokerClerksCte
      GROUP BY [Type]
             , [Name]
             , [TotalPages] ) AS summary
JOIN MemoryBrokerClerksCte AS first
ON first.RowNumber = summary.[FirstRow]
JOIN MemoryBrokerClerksCte AS last
ON last.RowNumber = summary.[LastRow]
CROSS JOIN sys.dm_os_sys_info AS info
ORDER BY [Type], [Name];
