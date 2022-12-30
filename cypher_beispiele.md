# Cypher Beispiel

## Suche nach PLZ-Bereich
```
MATCH (a:Address)-[lao]-(o:Officer)-[loe]-(e:Entity)
Where (a.country = "Germany" or a.country_code = "DEU" or "DEU" in a.country_codes)
and a.address =~ ".*97\d\d\d.*"
RETURN o,a,e
```
