--View original Data
SELECT *
FROM PP2Nashville.dbo.NashvilleHousing

--Standardizing Date Format
--Testing Date Conversion
SELECT SaleDate, CONVERT(date, SaleDate)
FROM PP2Nashville.dbo.NashvilleHousing

--Add SaleDateConverted Column to Table
ALTER TABLE PP2Nashville.dbo.NashvilleHousing
ADD SaleDateConverted Date

--Executing Date conversion in table
UPDATE PP2Nashville.dbo.NashvilleHousing
SET SaledateConverted = CONVERT(date, SaleDate)

--View update and new column
Select SaleDate, SaleDateConverted
FROM PP2Nashville.dbo.NashvilleHousing


--Viewing Property Address Data
SELECT *
FROM PP2Nashville.dbo.NashvilleHousing
--WHERE PropertyAddress is NULL
ORDER BY ParcelID

--Test Populating Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PP2Nashville.dbo.NashvilleHousing a
JOIN PP2Nashville.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--Populating Property Address Data
UPDATE a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PP2Nashville.dbo.NashvilleHousing a
JOIN PP2Nashville.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--Breaking Addresses out into Address, City and State
SELECT PropertyAddress
FROM PP2Nashville.dbo.NashvilleHousing

--Separate Address
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PP2Nashville.dbo.NashvilleHousing

--Add PropertyStreetAddress Column to Table
ALTER TABLE PP2Nashville.dbo.NashvilleHousing
ADD PropertyStreetAddress NVARCHAR(255)

--Populating PropertyStreetAddress Column in table
UPDATE PP2Nashville.dbo.NashvilleHousing
SET PropertyStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

--Add PropertyCity Column to Table
ALTER TABLE PP2Nashville.dbo.NashvilleHousing
ADD PropertyCity NVARCHAR(255)

--Populating PropertyCity Column in table
UPDATE PP2Nashville.dbo.NashvilleHousing
SET PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

--Testing Results
SELECT PropertyAddress, PropertyStreetAddress, PropertyCity
FROM PP2Nashville.dbo.NashvilleHousing


--Adjusting Property Owner Address
Select OwnerAddress
FROM PP2Nashville.dbo.NashvilleHousing

--Using PARSENAME to Separate Owner Address
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerStreetAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCityAddress,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerStateAddress
FROM PP2Nashville.dbo.NashvilleHousing

--Eliminating Nulls
--Populating Owner Address Data
UPDATE a
Set OwnerAddress = ISNULL(a.OwnerAddress, b.OwnerAddress)
FROM PP2Nashville.dbo.NashvilleHousing a
JOIN PP2Nashville.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.OwnerAddress is NULL

--Add OwnerStreetAddress Column to Table
ALTER TABLE PP2Nashville.dbo.NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255)

--Populating OwnerStreetAddress Column in table
UPDATE PP2Nashville.dbo.NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

--Add OwnerCityAddress Column to Table
ALTER TABLE PP2Nashville.dbo.NashvilleHousing
ADD OwnerCityAddress NVARCHAR(255)

--Populating OwnerCityAddress Column in table
UPDATE PP2Nashville.dbo.NashvilleHousing
SET OwnerCityAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

--Add OwnerStateAddress Column to Table
ALTER TABLE PP2Nashville.dbo.NashvilleHousing
ADD OwnerStateAddress NVARCHAR(255)

--Populating OwnerStateAddress Column in table
UPDATE PP2Nashville.dbo.NashvilleHousing
SET OwnerStateAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--Testing Results
SELECT OwnerAddress, OwnerStreetAddress, OwnerCityAddress, OwnerStateAddress
FROM PP2Nashville.dbo.NashvilleHousing

--Checking Data
SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PP2Nashville.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--Testing Case Statement
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PP2Nashville.dbo.NashvilleHousing

--Executing Case Statement
UPDATE PP2Nashville.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

--Removing Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY UniqueID
				) Row_Num
FROM PP2Nashville.dbo.NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE Row_Num > 1

--Removing unused Columns
ALTER TABLE PP2Nashville.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

