
/* to be used on versions pre JSON function availability */


/* it is recommended to avoid using [ ] as the tag delimiters due to inconsitent handling of [ by PATINDEX */

WITH KeyValuePairs AS (
    SELECT 
        t.OriginalString,
        SUBSTRING(t.OriginalString, ca.StartPos + 1, CHARINDEX(']', t.OriginalString, ca.StartPos) - ca.StartPos - 1) AS KeyValuePair
    FROM YourTable t
    CROSS APPLY (
        SELECT CHARINDEX('<', t.OriginalString, 1) AS StartPos
        UNION ALL
        SELECT CHARINDEX('<', t.OriginalString, StartPos + 1)
        FROM YourTable t2
        CROSS APPLY (SELECT CHARINDEX('<', t2.OriginalString, 1) AS StartPos) AS ca2
        WHERE CHARINDEX('[', t2.OriginalString, StartPos + 1) > 0
    ) ca
)
SELECT 
    OriginalString,
    LEFT(KeyValuePair, CHARINDEX(':', KeyValuePair) - 1) AS KeyName,
    RIGHT(KeyValuePair, LEN(KeyValuePair) - CHARINDEX(':', KeyValuePair) - 1) AS KeyValue
FROM KeyValuePairs;
