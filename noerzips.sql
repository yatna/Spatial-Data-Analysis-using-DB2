-- With Index    2020-04-05-19.16.12.433251 - 2020-04-05-19.16.05.662286 ~ 7 sec
-- Without Index 2020-04-05-19.09.27.304521 - 2020-04-05-19.08.44.205969 ~ 43 sec
set current function path = current function path, db2gse;
SELECT CURRENT TIMESTAMP FROM SYSIBM.SYSDUMMY1;

with zip_er(zip) as(
		select distinct ZipCode from cse532.facility as t1 where t1.FacilityID in (
		select FacilityID from cse532.facilitycertification where AttributeValue = 'Emergency Department')
),
zip_no_er(zip) as(
	select distinct zipcode from cse532.facility as t1
		where t1.FacilityId in (select FacilityID from cse532.facilitycertification) and 
		t1.zipcode not in (select * from zip_er)
),
er_with_shape(zip,shape) as(
	select ZCTA5CE10, shape from cse532.uszip as t1, zip_er as t2 
		where t1.ZCTA5CE10=substr(t2.zip,1,5) 
),
no_er_with_shape(zip,shape) as(
	select ZCTA5CE10, shape from cse532.uszip as t1, zip_no_er as t2 
		where t1.ZCTA5CE10=substr(t2.zip,1,5) 
)
select distinct zip from no_er_with_shape as t1 where not exists 
	(select zip from er_with_shape as t2 where st_intersects(t2.shape,t1.shape)=1); 



SELECT CURRENT TIMESTAMP FROM SYSIBM.SYSDUMMY1;


-- with zipcodes_with_er(zipCode) as (
-- 	select distinct ZipCode from cse532.facility as t1 where t1.FacilityID in (
-- 		select FacilityID from cse532.facilitycertification where AttributeValue = 'Emergency Department'
-- 	)
-- ),
-- all_facility_zipcode(zipcode) as (
-- 	select distinct Zipcode from cse532.facility
-- ),
-- zipcode_without_er(zipcode) as (
-- 	select Zipcode from all_facility_zipcode where ZipCode not in (select * from zipcodes_with_er)
-- ),
-- all_facility_zipcode_with_is_er_column as (
-- 	select ZipCode, 
-- 	case 
-- 		when Zipcode in (select * from zipcodes_with_er) then 1
-- 		else 0
-- 	end as is_er
-- 	from all_facility_zipcode
-- ),
-- zipcodes_without_er_in_uszip as (
-- 	select ZCTA5CE10 as zip, shape  from cse532.uszip as t1 where t1.ZCTA5CE10 in (select * from zipcode_without_er) 
-- ),
-- all_facility_zipcode_with_shapes as (
-- 	select ZCTA5CE10 as zip_all, shape  from cse532.uszip as t2 where t2.ZCTA5CE10 in (select * from all_facility_zipcode)
-- ),
-- uszip_er_zipcodes_with_their_neighbours as (
-- 	select zipcodes_without_er_in_uszip.zip as z1, zip_all as z2 ,
-- 	(select is_er from all_facility_zipcode_with_is_er_column where ZipCode=t2.zip_all) as er 
-- 	from zipcodes_without_er_in_uszip, all_facility_zipcode_with_shapes as t2 
-- 	where st_intersects(zipcodes_without_er_in_uszip.shape, t2.shape)=1
-- )
-- select distinct z1 from uszip_er_zipcodes_with_their_neighbours as q1 
-- 	where 0 = all (select er from uszip_er_zipcodes_with_their_neighbours where z1=q1.z1) ;