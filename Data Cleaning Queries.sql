-- Cleaning Data in SQL

use [Nashvile Housing];

select *
from NashvilleHousingData;

-- 1. Standardize date format
select SaleDate, convert(date, SaleDate)
from NashvilleHousingData;


update NashvilleHousingData
set SaleDate = convert(date, SaleDate);

--------------------------------------------------------------------------------------------------------------------------------------------------

-- 2. Populate Property Address
select *
from NashvilleHousingData

-- populating address from same parcel ID using self join
--select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
--from NashvilleHousingData a
--join NashvilleHousingData b on a.ParcelID= b.ParcelID
--and a.UniqueID <> b.UniqueID
--where a.PropertyAddress is null;

-- updating
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousingData a
join NashvilleHousingData b on a.ParcelID= b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null;

--------------------------------------------------------------------------------------------------------------------------------------------------

-- 3. Breaking address into Address,State,City columns
select *
from NashvilleHousingData
order by ParcelID;

-- using substring(targeted column,starting point, ending point) to seperate the data
-- returns the string till the comma from starting excluding comma coz of -1
select SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
-- returns the string from comma excluding comma coz of +1 till the length of PropertyAddress
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress)) as Address
from NashvilleHousingData;

-- Adding 2 columns to Populate the data
ALTER Table NashvilleHousingData
add SplitStreetAddress nvarchar(255);

update NashvilleHousingData
set SplitStreetAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1);


ALTER Table NashvilleHousingData
add SplitCity nvarchar(100);

update NashvilleHousingData
set SplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, len(PropertyAddress));

-- Breaking the owner address
-- using PARSNAME : it only seperates with period'.' so we can replace comma',' with period(.) and it retreives in reverse order
select 
-- this selects the first string from ownerAddress before '.' 3 is used because parsname works in reverse order
PARSENAME(replace(Owneraddress,',','.'),3),
PARSENAME(replace(Owneraddress,',','.'),2),
PARSENAME(replace(Owneraddress,',','.'),1)
from NashvilleHousingData;

-- adding 3 columns and populating the data

ALTER Table NashvilleHousingData
add OwnerSplitStreetAddress nvarchar(255);

update NashvilleHousingData
set OwnerSplitStreetAddress = PARSENAME(replace(Owneraddress,',','.'),3);

ALTER Table NashvilleHousingData
add OwnerSplitCity nvarchar(255);

update NashvilleHousingData
set OwnerSplitCity = PARSENAME(replace(Owneraddress,',','.'),2);

ALTER Table NashvilleHousingData
add OwnerSplitState nvarchar(255);

update NashvilleHousingData
set OwnerSplitState = PARSENAME(replace(Owneraddress,',','.'),1);

select *
from NashvilleHousingData;

--------------------------------------------------------------------------------------------------------------------------------------------------

-- 4. changing 1 and 0 to Yes and No in SoldAsVacant column

--select distinct (SoldAsVacant), count(SoldAsVacant)
--from NashvilleHousingData
--group by SoldAsVacant
--order by 2;

--select SoldAsVacant,
--case when SoldAsVacant = 0 then 'No'
--	when SoldAsVacant = 1 then 'Yes'
--	else SoldAsVacant
--	end
--from NashvilleHousingData; 

--alter table NashvilleHousingData
--alter column SoldAsVacant varchar(3);

-- updating the table
update NashvilleHousingData
set SoldAsVacant = case
when SoldAsVacant = 0 then 'No'
	when SoldAsVacant = 1 then 'Yes'
	else SoldAsVacant
	end;

--------------------------------------------------------------------------------------------------------------------------------------------------

-- 5. Remove Duplicates
with RowNumCTE as(
select *,
ROW_NUMBER() over (partition by
ParcelId,
LandUse,
PropertyAddress,
Saledate,
LegalReference
order by UniqueID) as row_num
from NashvilleHousingData
--order by ParcelID;
)
delete 
from RowNumCTE
where row_num> 1;

--------------------------------------------------------------------------------------------------------------------------------------------------

-- 6. Delete Unused columns
select *
from NashvilleHousingData;

alter table NashvilleHousingData
drop column OwnerAddress, TaxDistrict, PropertyAddress;