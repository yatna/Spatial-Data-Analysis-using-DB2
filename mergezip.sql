with distinct_zip(zip, pop) as 
(
	select distinct zip, zpop from cse532.zippop where zpop>0
),
zip_with_shapes(zip, pop) as
(
	select t2.zip, t2.pop from cse532.uszip as t1, distinct_zip as t2 where t1.ZCTA5CE10=t2.zip 
)
select avg(pop) as average_population from zip_with_shapes;

-- Create new table for operation

DROP TABLE cse532.my_dup;
CREATE TABLE cse532.my_dup(zip VARCHAR(5), pop DECFLOAT,  shape db2gse.st_geometry, m_zip VARCHAR(32000), is_m INTEGER);

!db2se register_spatial_column testdb
-tableSchema      cse532
-tableName        my_dup
-columnName       shape
-srsName          nad83_srs_1
;
-- m here means merged
INSERT INTO cse532.my_dup(zip, pop, shape, m_zip, is_m) (select ZCTA5CE10, zpop, shape, ZCTA5CE10,1 from 
	cse532.uszip as t, (select distinct zip, zpop from cse532.zippop where zpop > 0) as distinct_zip 
	where t.ZCTA5CE10 = distinct_zip.zip);

-- create indexes fro new table

create index cse532.my_dup_shape on cse532.my_dup(shape) extend using db2gse.spatial_index(0.34, 0.85, 3.8);
create index cse532.my_dup_zip on cse532.my_dup(zip);
create index cse532.my_dup_pop on cse532.my_dup(pop);
create index cse532.my_dup_merged_zip on cse532.my_dup(is_m);

DESCRIBE INDEXES FOR TABLE cse532.my_dup;


-- Should be 30425
select count(*) from cse532.my_dup;
