-- without 2020-04-05-22.49.56.618967		2020-04-05-22.49.56.294112 ~ .61-.29 = .32
-- with 2020-04-05-22.51.38.765688			2020-04-05-22.51.38.664838 ~ .76 - .66 = .10
SELECT CURRENT TIMESTAMP FROM SYSIBM.SYSDUMMY1;

set current function path = current function path, db2gse;
WITH filtered_table AS (
	select * from cse532.facility as T1 where T1.FacilityID in (
		select FacilityID from cse532.facilitycertification where AttributeValue='Emergency Department'
	)
)
select FacilityID, FacilityName ,decimal(ST_DISTANCE(GeoLocation, st_point( -72.9939831,40.824369,1), 'STATUTE MILE'),8,4) as dist
from filtered_table
where ST_WITHIN(GeoLocation, ST_BUFFER(st_point( -72.9939831, 40.824369,1), 30.0, 'STATUTE MILE'))=1 
order by dist
fetch first 1 row only;

SELECT CURRENT TIMESTAMP FROM SYSIBM.SYSDUMMY1;
