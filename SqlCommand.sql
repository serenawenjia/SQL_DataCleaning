DROP SCHEMA IF EXISTS `housing`;
CREATE SCHEMA `housing`;

DROP TABLE IF EXISTS `housing`.`nashville`;
CREATE TABLE `housing`.`nashville`(
`UniqueID` INT NOT NULL PRIMARY KEY,
`ParcelID` VARCHAR(45) NULL,
`LandUse`  VARCHAR(45) NULL,
`PropertyAddress` VARCHAR(45) NULL,
`SaleDate` VARCHAR(45) NULL,
`SalePrice` VARCHAR(128) NULL,
`LegalReference` VARCHAR(45) NULL,
`SoldAsVacant` VARCHAR(45) NULL,
`OwnerName` VARCHAR(128) NULL,
`OwnerAddress` VARCHAR(128) NULL,
`Acreage` DOUBLE NULL,
`TaxDistrict` VARCHAR(45) NULL,
`LandValue` INT NULL,
`BuildingValue` INT NULL,
`TotalValue` INT NULL,
`YearBuilt` INT NULL,
`Bedrooms` INT NULL,
`FullBath` INT NULL,
`HalfBath` INT NULL
);

DESCRIBE `housing`.`nashville`;

LOAD DATA INFILE '/Users/wenjia/github/SQL_DataCleaning/HousingData.csv' INTO TABLE `housing`.`nashville`
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
;
 SELECT * FROM `housing`.`nashville`
 LIMIT 100;
