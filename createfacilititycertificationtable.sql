DROP TABLE cse532.facilitycertification;

CREATE TABLE cse532.facilitycertification(
FacilityID VARCHAR(16) NOT NULL,
FacilityName VARCHAR(128),
Description VARCHAR(256),
AttributeType VARCHAR(32),
AttributeValue VARCHAR(128),
MeasureValue INTEGER,
County VARCHAR(16)
);

load from "Health_Facility_Certification_Information.csv" of del MESSAGES load.msg 
INSERT INTO cse532.facilitycertification NONRECOVERABLE;