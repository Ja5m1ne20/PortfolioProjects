-- Data cleaning using sql queries

select *
From NashvilleHousing

-- Satandardize date Format

select saleDate
from
NashvilleHousing

-- if we have date associated withtime stamp and we only want it in date we can use folowing code

select saleDate, convert(Date, saleDate) as ConvertedDate
from NashvilleHousing

-- replacing null values with data 
select a.[UniqueID], a.ParcelID, a.PropertyAddress , isnull(a.PropertyAddress,b.PropertyAddress) as correcedAddress
From NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID]<> b.[UniqueID]
where a.PropertyAddress is null


-- updating table where property address is null
Update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress) 
From NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID]<> b.[UniqueID]
where a.PropertyAddress is null



-- Breaking address into individual colums


Select PropertyAddress ,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)) as NewAddress
from 
NashvilleHousing

-- removing comma

Select PropertyAddress ,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as NewAddress,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
from 
NashvilleHousing


Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

select PropertySplitAddress
from NashvilleHousing

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


Alter Table NashvilleHousing
Add PropertySplitcity nvarchar(255)


update NashvilleHousing
SET PropertySplitcity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))


select PropertyAddress, PropertySplitAddress, PropertySplitcity
from NashvilleHousing



-- playing with ownerAddress

select OwnerAddress from
NashvilleHousing


-- Parsename is only works with period not comma(so we need to replace the comma with period)
select PARSENAME(ownerAddress,1)
from NashvilleHousing

select PARSENAME(replace(OwnerAddress,',','.'),3) as ownerSplitAddress,
PARSENAME(replace(OwnerAddress,',','.'),2) as ownerSplitCity,
PARSENAME(replace(OwnerAddress,',','.'),1) as ownerSplitState
from NashvilleHousing


Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

select OwnerSplitAddress
from NashvilleHousing

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)


Alter Table NashvilleHousing
Add OwnerSplitcity nvarchar(255)


update NashvilleHousing
SET OwnerSplitcity = PARSENAME(replace(OwnerAddress,',','.'),2)

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255)


update NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)

Select OwnerAddress,OwnerSplitAddress, OwnerSplitcity, OwnerSplitState
From NashvilleHousing


-- Changing 0/1 to yes/no
select soldasvacant
from NashvilleHousing

select Distinct SoldAsVacant
from NashvilleHousing

select soldasvacant 
, case when soldasvacant ='0' then 'NO'
	   when soldasvacant ='1'	then 'YES'
	   else soldasvacant
	   end
from NashvilleHousing

update NashvilleHousing
Set SoldAsVacant = case when soldasvacant ='0' then 'NO'
	   when soldasvacant ='1'	then 'YES'
	   else soldasvacant
	   end


--Removing Duplicate rows

WITH RowNumCTE AS(
select * , 
		ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
					 PropertyAddress,
					 salePrice,
					 saleDate,
					 LegalReference
					 ORDER By UniqueID
					 ) as row_num
from NashvilleHousing
)
SELECT * From RowNumCTE
where row_num >1

--Delete from
--RowNumCTE where row_num>2


-- Deleting unusable columns

Alter table NashvilleHousing
Drop column ownerAddress, PropertyAddress