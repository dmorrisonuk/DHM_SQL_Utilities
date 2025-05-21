
/* to be used on versions pre JSON function availability */


WITH KeyValuePairs AS (
    SELECT 
        t.OriginalString,
        SUBSTRING(t.OriginalString, p.Pos + 1, CHARINDEX(']', t.OriginalString, p.Pos) - p.Pos - 1) AS KeyValuePair
    FROM YourTable t
    CROSS APPLY (
        SELECT CHARINDEX('[', t.OriginalString, 1) AS Pos
        UNION ALL
        SELECT CHARINDEX('[', t.OriginalString, Pos + 1)
        FROM YourTable
        WHERE CHARINDEX('[', t.OriginalString, Pos + 1) > 0
    ) p
)
SELECT 
    OriginalString,
    PARSENAME(REPLACE(KeyValuePair, ': ', '.'), 2) AS KeyName,
    PARSENAME(REPLACE(KeyValuePair, ': ', '.'), 1) AS KeyValue
FROM KeyValuePairs;