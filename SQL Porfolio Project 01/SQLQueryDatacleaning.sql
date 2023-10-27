/* cleaning data in SQL queries
*/



-------------------------------------------------------------------
--1/Format date

select SaleDate, convert(date, SaleDate) -- convert sang kiểu date
 from PorfolioProject..NashvilleHousing
 
--thêm colum 
alter table NashvilleHousing
add SaleDateconvert Date;
--cập nhật colum vào bảng
 update NashvilleHousing
 set SaleDateconvert = convert(date, SaleDate)
 --xuất ra colum đã convert
 select SaleDateconvert  
 from
 NashvilleHousing

 -- xóa colum date Saledate cũ
 alter table NashvilleHousing
 drop column SaleDate;

 select * from
 NashvilleHousing
 

 -----------------------------------------------------------
 --Populate Property Addres data
  select * from
 NashvilleHousing
 where PropertyAddress is null

 --Check với mối ParcellID sẽ tương ứng đúng với Propertyaddress hay k? và nếu các propertyaddress is null thì tìm cách điền nó vào đúng với ParcellID


 --query này sẽ cho ta tháy được rõ ràng các giá trị null sẽ trùng với ParcellID và có địa chỉ
  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , isnull(a.PropertyAddress,b.PropertyAddress)
  from
      NashvilleHousing as a
 join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null

 --update value Propertyaddress từ b vào a để k còn value null
 update a
 set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
 from
      NashvilleHousing as a
 join NashvilleHousing as b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ]<>b.[UniqueID ]
 where a.PropertyAddress is null



 --------------------------------------
 --Breaking out Address into individual Columns (Address, City, State)
 --Tách các địa chỉ và thành phố 
  select 
  SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address, -- k láy ra dấu ,
  SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1, len(PropertyAddress)) --láy từ dấu , trở đi 

  from NashvilleHousing
 
--cập nhật thêm colum addres mới
alter table NashvilleHousing
add PropertySplitAddres nvarchar(255);
--cập nhật colum vào bảng
 update NashvilleHousing
 set PropertySplitAddres = SUBSTRING (PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

alter table NashvilleHousing
add PropertySplitCity nvarchar(255);
--cập nhật colum vào bảng
 update NashvilleHousing
 set PropertySplitCity = SUBSTRING (PropertyAddress,CHARINDEX(',',PropertyAddress)+ 1, len(PropertyAddress))

 ---xuất ra sẽ ra 3 colum và PropertyAddress đã được tách ra
 select PropertyAddress, PropertySplitAddres, PropertySplitCity
 from
 PorfolioProject..NashvilleHousing




 -------------xử lý colum owerAddress-----------------------
 
select OwnerAddress
from
PorfolioProject..NashvilleHousing

--Tách thành 3 colum khác nhau
select PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)

from PorfolioProject..NashvilleHousing

 
 --cập nhật thêm colum addres mới
alter table NashvilleHousing
add OwnerSplitAddres nvarchar(255);
--cập nhật colum vào bảng
 update NashvilleHousing
 set OwnerSplitAddres = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

 alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);
--cập nhật colum vào bảng
 update NashvilleHousing
 set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

 alter table NashvilleHousing
add OwnerSplitStates nvarchar(255);
--cập nhật colum vào bảng
 update NashvilleHousing
 set OwnerSplitStates = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

 --xuất ra các colum vừa tạo mới
 select OwnerAddress,OwnerSplitAddres, OwnerSplitCity, OwnerSplitStates
 from
 PorfolioProject..NashvilleHousing



 -----------------------
 --chane Y and N to yes and No in " sold as vacant"
 select distinct(SoldAsVacant)
 from
  PorfolioProject..NashvilleHousing

  --check xem số lượng theo từng value
 select distinct(SoldAsVacant), count(SoldAsVacant)
 from
 PorfolioProject..NashvilleHousing
 group by SoldAsVacant
 order by 2 asc

 --viết câu truy vấn để thay đổi nếu value là Y thành yes và N thành No
 select SoldAsVacant,
	 case when SoldAsVacant ='Y' then 'Yes'
	      when SoldAsVacant ='N' then 'No'
	      else SoldAsVacant
	      end
 from
 PorfolioProject..NashvilleHousing

 --phải update vào thì nó mới thành công
 update NashvilleHousing
 set SoldAsVacant = case when SoldAsVacant ='Y' then 'Yes'
	      when SoldAsVacant ='N' then 'No'
	      else SoldAsVacant
	      end



-----------------------------
--Remote Duplicates

--------------
--delete unused Columns

alter table PorfolioProject..NashvilleHousing
drop column 
