WITH ConnectivityCte
AS (
    SELECT ROW_NUMBER() OVER (ORDER BY Buffer.Record.value( '@time', 'BIGINT' )
                                     , Buffer.Record.value( '@id', 'INT' ) ) AS [RowNumber]
         , Data.ring_buffer_type AS [Type]
         , Buffer.Record.value( '(ConnectivityTraceRecord/RecordSource)[1]'
                              , 'NVARCHAR(128)') as [RecordSource]
         , Buffer.Record.value( '(ConnectivityTraceRecord/RecordType)[1]'
                              , 'NVARCHAR(128)') as [RecordType]
         , Buffer.Record.value( '@time', 'BIGINT' ) AS [time]
         , Buffer.Record.value( '@id', 'INT') AS [Id]
         , Data.EventXML
    FROM ( SELECT CAST(Record AS XML) AS EventXML
               , ring_buffer_type
           FROM sys.dm_os_ring_buffers
           WHERE ring_buffer_type = 'RING_BUFFER_CONNECTIVITY' ) AS Data
    CROSS APPLY EventXML.nodes('//Record') AS Buffer(Record)
   )
SELECT first.[Type]
     , summary.[RecordSource]
     , summary.[RecordType]
     , summary.[count]
     , DATEADD( second
               , first.[Time] - info.ms_ticks / 1000
               , CURRENT_TIMESTAMP ) AS [FirstTime]
     , DATEADD( second
               , last.[Time] - info.ms_ticks / 1000
               , CURRENT_TIMESTAMP ) AS [LastTime]
--     , first.EventXML AS [FirstRecord]
     , last.EventXML AS [LastRecord]
FROM (SELECT [RecordSource]
           , [RecordType]
           , COUNT(*) AS [count]
           , MIN(RowNumber) AS [FirstRow]
           , MAX(RowNumber) AS [LastRow]
                     FROM ConnectivityCte
      GROUP BY [RecordSource], [RecordType] ) AS summary
JOIN ConnectivityCte AS first
ON first.RowNumber = summary.[FirstRow]
JOIN ConnectivityCte AS last
ON last.RowNumber = summary.[LastRow]
CROSS JOIN sys.dm_os_sys_info AS info
ORDER BY summary.[FirstRow];