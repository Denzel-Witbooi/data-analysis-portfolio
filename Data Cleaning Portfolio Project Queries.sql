/*

Cleaning Data in SQL Queries

*/


select * 
from PortfolioProject.dbo.NashvilleHousing
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(date,SaleDate) 

-- If it doesn't Update properly

Alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(date,SaleDate) 

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, 
b.ParcelID, b.PropertyAddress, 
isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing

select 
SUBSTRING(PropertyAddress, 1,
CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,
CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress) -1) 


Alter table NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select PropertySplitAddress, PropertySplitCity  
from PortfolioProject..NashvilleHousing



select OwnerAddress
from PortfolioProject..NashvilleHousing


select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select Distinct(SoldAsVacant), Count(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing

update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
	   When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH RowNumCTE AS (
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueId
					) row_num
from PortfolioProject..NashvilleHousing
-- order by ParcelID
)
DELETE 
from RowNumCTE
where row_num > 1 
-- select * 
--from RowNumCTE
--where row_num > 1
--order by PropertyAddress


---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from PortfolioProject..NashvilleHousing

ALTER TABLE	PortfolioProject..NashvilleHousing
DROP COLUMN	OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE	PortfolioProject..NashvilleHousing
DROP COLUMN	SaleDate




-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------



