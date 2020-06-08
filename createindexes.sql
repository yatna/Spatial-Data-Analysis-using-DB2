drop index cse532.facility_geolocation_idx;
drop index cse532.facility_zip_idx;
drop index cse532.fc_attrval_idx;
drop index cse532.uszip_shape;
drop index cse532.uszip_zip;
drop index cse532.fc_fid_idx;


create index cse532.facility_geolocation_idx on cse532.facility(Geolocation) extend using db2gse.spatial_index(0.05, 0, 0);
create index cse532.facility_zip_idx on cse532.facility(ZipCode);
create index cse532.fc_attrval_idx on cse532.facilitycertification(AttributeValue);
create index cse532.fc_fid_idx on cse532.facilitycertification(FacilityId);
create index cse532.uszip_shape on cse532.uszip(shape) extend using db2gse.spatial_index(0.33, 0.83, 3.7);
create index cse532.uszip_zip on cse532.uszip(ZCTA5CE10);



DESCRIBE INDEXES FOR TABLE cse532.facility;
DESCRIBE INDEXES FOR TABLE cse532.facilitycertification;
DESCRIBE INDEXES FOR TABLE cse532.uszip;
