---- Data Cleaning Using SQL ---

create database NationalHousing ;

-- After the database has been loaded. CHecking the rows in the database to get an overview ---

select *
from NationalHousing.dbo.Sheet;


---- Saledate has timestamp attached. So removing it --

select SaleDate , convert(date,SaleDate)
from NationalHousing.dbo.Sheet ;

alter table NationalHousing.dbo.Sheet
add SaleDateNew date;

update NationalHousing.dbo.Sheet
set Saledatenew = convert(date,SaleDate);

----- We can see that under PropertyAddress column some rows have null values.
-- The address are updated with the same parcelID in another record so we will now copy the address and will paste it to remove null fields--


select *
from NationalHousing.dbo.Sheet;

-- Write a query to first find the rows that have unique UniqueID but has null values on address---

select a.ParcelID , a.PropertyAddress , b.ParcelID , b.PropertyAddress
from NationalHousing.dbo.Sheet a
inner join 
NationalHousing.dbo.Sheet b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null ;

-- We need to copy Address from b to a ---

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NationalHousing.dbo.Sheet a
inner join 
NationalHousing.dbo.Sheet b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null ;     --- This would update the address with null values ---


--- Separating Address and City ---

select PropertyAddress
from NationalHousing.dbo.Sheet ;   -- We can see that address and city are joined together ---

select  substring(PropertyAddress,1,charindex(',',PropertyAddress)-1) as AddressName, 
substring(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress)) as CityName
from NationalHousing.dbo.Sheet ;

-- Note
--- substring(Columnname,Position,uptoCharacter)   Charindex(character,Columnname)

--Adding the above results in the table ---

Alter table NationalHousing.dbo.Sheet
add UpdatedAddress nvarchar(300)

update NationalHousing.dbo.Sheet
set UpdatedAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

Alter table NationalHousing.dbo.Sheet
add City nvarchar(300)

update NationalHousing.dbo.Sheet
set City = substring(PropertyAddress,charindex(',',PropertyAddress)+1,LEN(PropertyAddress))

select *
from NationalHousing.dbo.Sheet ;


------------- Another method to do the same is using Parsename() functionality ----
------------- Parsename looks for '.' and not ','. We need to update those ---
-- Using Parsename functionality to break city name and state in OwnerAddress col ---

select parsename(replace(OwnerAddress,',','.'),3) as OwnerState ,
parsename(replace(OwnerAddress,',','.'),2) as OwnerCity , 
parsename(replace(OwnerAddress,',','.'),1) as OwnerAddress
from NationalHousing.dbo.Sheet ;

Alter table NationalHousing.dbo.Sheet
add OwnerState nvarchar(300)

update NationalHousing.dbo.Sheet
set OwnerState = parsename(replace(OwnerAddress,',','.'),3)

Alter table NationalHousing.dbo.Sheet
add OwnerCity nvarchar(300)

update NationalHousing.dbo.Sheet
set OwnerCity = parsename(replace(OwnerAddress,',','.'),2)

Alter table NationalHousing.dbo.Sheet
add OwnerAddressNew nvarchar(300)

update NationalHousing.dbo.Sheet
set OwnerAddressNew = parsename(replace(OwnerAddress,',','.'),1)


---- Updating Y to Yes and N to No ---

select SoldAsVacant , count(SoldAsVacant)
from NationalHousing.dbo.Sheet 
group by SoldAsVacant;


select SoldAsVacant , 
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from NationalHousing.dbo.Sheet ;


---- Removing Duplicates ---

-- Using CTE and Window functions to remove duplicate entries ---

select *
from NationalHousing.dbo.Sheet ;


WITH CTE as (
select * , 
row_number() over (
PARTITION BY ParcelID,
             PropertyAddress,
			 SaleDate,
			 LegalReference
			 order by
			 UniqueID) as Row_Num
from NationalHousing.dbo.Sheet )
delete 
from CTE
where Row_Num = 2;


--- Delete Unused Items ---

select *
from NationalHousing.dbo.Sheet;


 alter table NationalHousing.dbo.Sheet
 drop column PropertyAddress , SaleDate , OwnerAddress