USE HousingProject
GO

SELECT TOP (1000) [UniqueID]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [HousingProject].[dbo].[NashvilleHousing]

  -- Cleaning Data in SQL Queries 
  Select *
  From HousingProject.dbo.NashvilleHousing

  -- Standardize Date Format (Convert SaleDate from VARCHAR(255) to DATE)
  UPDATE HousingProject.dbo.NashvilleHousing 
  SET SaleDate = CONVERT(DATE, SaleDate)


  -- Populate Property Address data ??
  SELECT PropertyAddress
  FROM HousingProject.dbo.NashvilleHousing
  WHERE PropertyAddress IS NULL

  Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
    From HousingProject.dbo.NashvilleHousing a 
    JOIN HousingProject.dbo.NashvilleHousing b 
      on a.ParcelID = b.ParcelID
      AND a.UniqueID <> b.UniqueID
    WHERE a.PropertyAddress is null 

    Update a 
    SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
    From HousingProject.dbo.NashvilleHousing a 
    JOIN HousingProject.dbo.NashvilleHousing b 
      on a.ParcelID = b.ParcelID
      AND a.UniqueID <> b.UniqueID
    WHERE a.PropertyAddress is null 

  -- Breaking out Address into Individual Columns (Address, City, State)

-- Preview initial columns before adding new columns
SELECT TOP 10
PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM HousingProject.dbo.NashvilleHousing

---- Add PropertySplitAddress and PropertySplitCity columns
ALTER TABLE HousingProject.dbo.NashvilleHousing
ADD PropertySplitAddress VARCHAR(255);
GO

UPDATE HousingProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE HousingProject.dbo.NashvilleHousing
ADD PropertySplitCity VARCHAR(255)
GO

UPDATE HousingProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

---- Confirm columns are added
SELECT TOP 10 PropertyAddress, PropertySplitAddress, PropertySplitCity 
FROM HousingProject.dbo.NashvilleHousing

---- Preview columns to add
SELECT TOP 10
OwnerAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM HousingProject.dbo.NashvilleHousing

---- Add OwnerSplitAddress, OwnerSplitCity, and OwnerSplitState columns
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255)
GO

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)

ALTER TABLE HousingProject.dbo.NashvilleHousing
ADD OwnerSplitCity VARCHAR(255)
GO

Update HousingProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE HousingProject.dbo.NashvilleHousing
ADD OwnerSplitState VARCHAR(255)
GO

Update HousingProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

---- Confirm columns are added
SELECT TOP 10 OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState 
FROM HousingProject.dbo.NashvilleHousing


/*
  -- Change Y and N to Yes and No in "Sold as Vacant" field
  Select SoldAsVacant
  , CASE When SoldAsVacant = 'Y' THEN 'Yes'
      When SoldAsVacant = 'N' THEN 'No'
      ELSE SoldAsVacant
      END
  From HousingProject.dbo.NashvilleHousing;

  -- Update 'Y' and 'N' to 'Yes' and 'No''
  UPDATE HousingProject.dbo.NashvilleHousing
  SET SoldAsVacant = 
      CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
          WHEN SoldAsVacant = 'N' THEN 'No'
          ELSE SoldAsVacant
      END

  -- Confirm 'Y' and 'N' have been replaced
  SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
  FROM HousingProject.dbo.NashvilleHousing
  GROUP BY SoldAsVacant

  -- Remove Duplicates
  WITH RowNumCTE AS(
  Select *,
    ROW_NUMBER() OVER (
    PARTITION BY ParcelID,
          PropertyAddress,
          SalePrice,
          SaleDate,
          LegalReference
          ORDER BY
            UniqueID
            ) row_num

  From HousingProject.dbo.NashvilleHousing
  --order by ParcelID
  )
  Select *
  From RowNumCTE
  Where row_num > 1
  Order by PropertyAddress
*/
/*
  -- Delete Unused Columns
  Select *
  From HousingProject.dbo.NashvilleHousing

  ALTER TABLE HousingProject.dbo.NashvilleHousing
  DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
*/






