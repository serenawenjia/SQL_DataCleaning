-- 1. Load data
USE master 
GO

IF NOT EXISTS (
    SELECT *
        FROM sys.databases
        WHERE name = 'HousingProject'
)
CREATE DATABASE HousingProject
USE HousingProject
GO

---- Create table
DROP TABLE IF EXISTS NashvilleHousing;
CREATE TABLE NashvilleHousing (
    UniqueID INT PRIMARY KEY,
    ParcelID VARCHAR(255),
    LandUse VARCHAR(255),
    PropertyAddress VARCHAR(255),
    SaleDate VARCHAR(255),
    SalePrice VARCHAR(255),
    LegalReference VARCHAR(255),
    SoldAsVacant VARCHAR(255),
    OwnerName VARCHAR(255),
    OwnerAddress VARCHAR(255),
    Acreage DECIMAL,
    TaxDistrict VARCHAR(255),
    LandValue INT,
    BuildingValue INT,
    TotalValue INT,
    YearBuilt INT,
    Bedrooms INT,
    FullBath INT,
    HalfBath INT
)
GO
---- Read CSV
BULK INSERT NashvilleHousing FROM '/data.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,               -- Skip CSV header row
    -- FIELDTERMINATOR = ',',   -- Redundant
    -- ROWTERMINATOR = '\n',    -- Redundant
    -- TABLOCK,                 -- Redundant
    KEEPNULLS                   -- Treat empty fields as NULLs
)

-- 2. Convert SaleDate form to DATE
---- 2.1 Preview Initial Table 
SELECT TOP 10 * 
FROM NashvilleHousing

---- 2.2 Standardize Date Format

---- 2.2.1 Preview Converting SaleDate to DATE
SELECT TOP 10 SaleDate, CONVERT(DATE, SaleDate)
FROM NashvilleHousing

---- 2.2.2 Convert SaleDate form to DATE
UPDATE NashvilleHousing 
SET SaleDate = CONVERT(DATE, SaleDate)

---- 2.2.3 Confirm SaleDate has already converted to DATE 
SELECT TOP 10 UniqueID, SaleDate 
FROM NashvilleHousing


-- 3. Populate Property Address Data

---- 3.1 Preview rows without PropertyAddress
SELECT TOP 10 ParcelID, PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

---- 3.2 Preview converting a's PropertyAddress to b's
SELECT TOP 10 a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  
FROM NashvilleHousing a
JOIN NashvilleHousing b
    ON a.ParcelID = b.ParcelID
WHERE a.PropertyAddress IS NULL
    AND b.PropertyAddress IS NOT NULL

---- 3.3 Converting a's PropertyAddress to b's
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
        ON a.ParcelID = b.ParcelID
        AND a.[UniqueID] <> b.[UniqueID]
WHERE a.PropertyAddress IS NULL

---- 3.4 Checking rows with new PropertyAddress
SELECT TOP 10 ParcelID, PropertyAddress
FROM NashvilleHousing
WHERE PropertyAddress IS NULL

-- 4. Break PropertyAddress into columns (Address, City)

---- 4.1 Preview current columns before adding new columns
SELECT TOP 10 PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM NashvilleHousing

---- Add PropertySplitAddress and PropertySplitCity columns
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);
GO

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255)
GO

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

