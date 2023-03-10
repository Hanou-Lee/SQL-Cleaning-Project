--  Cleaning Data

Select *
From PortfolioCleaningProject..nashvillehousing

-- Converting SaleDate to remove time

Select SaleDateConverted
From PortfolioCleaningProject..nashvillehousing

Update PortfolioCleaningProject..nashvillehousing
Set SaleDate = Convert(date, SaleDate)

Alter Table PortfolioCleaningProject..nashvillehousing
Add SaleDateConverted Date;

Update PortfolioCleaningProject..nashvillehousing
Set SaleDateConverted = Convert(date, SaleDate)


-- Populate Property Address Data
-- Joined table with itself to see nulls
-- replaced nulls with property address based on parcelID

Select *
From PortfolioCleaningProject..nashvillehousing
Order By ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From PortfolioCleaningProject..nashvillehousing a
JOIN PortfolioCleaningProject..nashvillehousing b
 ON a.parcelID = b.parcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From nashvillehousing a
JOIN nashvillehousing b
 ON a.parcelID = b.parcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL


-- Breaking Property Address into separate columns
-- Removing comma in address via charindex
-- Creating new columns with split addresses and city

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
From nashvillehousing

Alter Table nashvillehousing
Add PropertySplitAddress nvarchar(255);

Update nashvillehousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table nashvillehousing
Add PropertySplitCity nvarchar(255);

Update nashvillehousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


-- Using ParseName to split Owner Address
-- Need to replace comma with period to use PARSENAME

Select OwnerAddress
From nashvillehousing

Select 
ParseName(Replace(OwnerAddress, ',','.'), 3),
ParseName(Replace(OwnerAddress, ',','.'), 2),
ParseName(Replace(OwnerAddress, ',','.'), 1)
From nashvillehousing

Alter Table nashvillehousing
Add OwnerSplitAddress nvarchar(255);

Update nashvillehousing
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',','.'), 3)

Alter Table nashvillehousing
Add OwnerSplitCity nvarchar(255);

Update nashvillehousing
Set OwnerSplitCity = ParseName(Replace(OwnerAddress, ',','.'), 2)


Alter Table nashvillehousing
Add OwnerSplitState nvarchar(255);

Update nashvillehousing
Set OwnerSplitState = ParseName(Replace(OwnerAddress, ',','.'), 1)

-- Changing "Y" and "N" to "Yes" and "No" in SoldASVacant column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From nashvillehousing
Group By SoldAsVacant
Order By 2


Select SoldAsVacant,
	CASE When SoldasVacant = 'Y' Then 'Yes'
		 When SoldasVacant = 'N' Then 'No'
		 ELSE SoldasVacant
		 END
From nashvillehousing

UPDATE nashvillehousing
SET SoldAsVacant = CASE When SoldasVacant = 'Y' Then 'Yes'
					When SoldasVacant = 'N' Then 'No'
					ELSE SoldasVacant
					END


-- Removing Duplicates
-- Using CTE to create row_num to find duplicate rows

With RowNumCTE AS (
Select*,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By UniqueID) AS row_num
From nashvillehousing
)
Select *
From RowNumCTE
Where row_num > 1
--Order By PropertyAddress


-- Deleting Unused Columns

Select *
From nashvillehousing

Alter Table nashvillehousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate