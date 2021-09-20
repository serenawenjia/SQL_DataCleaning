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

---- 4.2 Add PropertySplitAddress and PropertySplitCity columns

-- Address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);
GO
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

-- City
ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255)
GO
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

---- 4.3 Checking new added columns
SELECT TOP 10 PropertyAddress, PropertySplitAddress, PropertySplitCity 
FROM NashvilleHousing


-- 5. Break OwnerAddress into columns (Address, City, State)

---- 5.1 Preview columns
SELECT TOP 10
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM NashvilleHousing

---- 5.2 Adding new columns

---- 5.2.1 Adding 'OwnerSplitAddress' Column
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255)
GO
Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

---- 5.2.2 Adding 'OwnerSplitCity' Column
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255)
GO
Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

---- 5.2.3 Adding 'OwnerSplitState' Column
ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255)
GO
Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


---- 5.3 Checking new added columns
SELECT TOP 10 OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState 
FROM NashvilleHousing

-- 6. Change Y and N to Yes and No in "Sold as Vacant" field

---- 6.1 Display the numbers of SoldAsVacant values
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant

---- 6.2 Preview converting from 'Y' and 'N' to 'Yes' and 'No'
SELECT TOP 10 SoldAsVacant, 
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END
FROM NashvilleHousing
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'

---- 6.3 Converting 'Y' and 'N' to 'Yes' and 'No'
UPDATE NashvilleHousing
SET SoldAsVacant = 
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END

---- 6.4 Checking 'Y' and 'N' have been replaced to 'Yes' and 'No'
SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant


-- 7. Remove Duplicates

---- 7.1 Display duplicate rows with CTE
;WITH RowCntCTE AS( 
    SELECT ROW_NUMBER() OVER (
        PARTITION BY 
            ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY UniqueID
        ) row_cnt, *
    FROM NashvilleHousing
)
SELECT TOP 10 *
FROM RowCntCTE
WHERE row_cnt > 1

---- 7.2 Remove duplicate rows
;WITH RowCntCTE AS(
    SELECT ROW_NUMBER() OVER (
        PARTITION BY 
            ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY UniqueID
        ) row_cnt, *
    FROM NashvilleHousing
)
DELETE
FROM RowCntCTE
WHERE row_cnt > 1

---- 7.3 Checking duplicate rows have been removed
;WITH RowCntCTE AS(
    SELECT ROW_NUMBER() OVER (
        PARTITION BY 
            ParcelID,
            PropertyAddress,
            SalePrice,
            SaleDate,
            LegalReference
            ORDER BY UniqueID
        ) row_cnt, *
    FROM NashvilleHousing
)
SELECT TOP 10 *
FROM RowCntCTE
WHERE row_cnt > 1

-- 8. Delete Unused Columns
---- 8.1 Display table and find unused columns to drop
SELECT TOP 10 * 
FROM NashvilleHousing

---- 8.2 Drop unused columns
ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

---- 8.3 Display final table
SELECT * 
FROM NashvilleHousing