--*************************************************************************--
-- Title: Assignment06
-- Author: Doug Neri
-- Desc: This file demonstrates how to use Views
-- Change Log: Who,Who,What
-- 2021-02-22, Doug Neri,Created File, worked through problems 1 and 2
-- 2021-02-22, Doug Neri, Completed remaining problems, additional notes on a per problem basis are located below each solution, the majority were completed through a copy/paste
-- from the question above with minor alterations needed to each to complete the question.  
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_DougNeri')
	 Begin 
	  Alter Database [Assignment06DB_DougNeri] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_DougNeri;
	 End
	Create Database Assignment06DB_DougNeri;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_DougNeri;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BASIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
--
Drop View If Exists dbo.vCategories;
go
Create View vCategories
With Schemabinding
As
	Select TOP 10000000
		CategoryID, CategoryName
		From dbo.Categories;
go

Drop View If Exists dbo.vEmployees;
go
Create View vEmployees
With Schemabinding
As
	Select TOP 10000000
		EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID
		From dbo.Employees;
go

Drop View If Exists dbo.vProducts;
go
Create View vProducts
With Schemabinding
As
	Select TOP 10000000
		ProductID, ProductName, CategoryID, UnitPrice
		From dbo.Products;
go

Drop View If Exists dbo.vInventories;
go
Create View vInventories
With Schemabinding
As
	Select TOP 10000000
		InventoryID, InventoryDate, EmployeeID, ProductID, Count
		From dbo.Inventories;
go


-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Use Assignment06DB_DougNeri;
Deny Select On Categories to Public;
Grant Select On vCategories to Public;

Deny Select On Products to Public;
Grant Select On vProducts to Public;

Deny Select On Employees to Public;
Grant Select On dbo.vEmployees to Public;

Deny Select On Inventories to Public;
Grant Select On vInventories to Public;



-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

Drop View If Exists dbo.vProductsByCategories;
go
Create View vProductsByCategories
With Schemabinding
As
	Select TOP 10000000
		CategoryName, ProductName, UnitPrice
		From dbo.Categories
		Join dbo.Products
			On Categories.CategoryID = Products.CategoryID
		Order By 1,2
go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

Drop View If Exists dbo.vInventoriesByProductsByDates;
go
Create View vInventoriesByProductsByDates
With Schemabinding
As
	Select TOP 10000000
		ProductName, Count, InventoryDate 
		From dbo.Products
		Join dbo.Inventories
			On Inventories.ProductID = Products.ProductID
		Order By 1,3,2
go


-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83



-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

Drop View If Exists dbo.vInventoriesByEmployeesByDates;
go

-- In hindsight I realize I could have used Distinct here
Create View vInventoriesByEmployeesByDates
With Schemabinding
As
	Select TOP 10000000
		InventoryDate,[EmployeeName] = (EmployeeFirstName + ' ' + EmployeeLastName) 
		From dbo.Employees
		Inner Join dbo.Inventories
			On Inventories.EmployeeID = Employees.EmployeeID
		Group By InventoryDate, EmployeeFirstName, EmployeeLastName
		Order By 1,2
go

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth


-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

Drop View If Exists dbo.vInventoriesByProductsByCategories;
go

Create View vInventoriesByProductsByCategories
With Schemabinding
As
	Select TOP 10000000
		CategoryName, ProductName, InventoryDate, Count
		From dbo.Products
		Inner Join dbo.Inventories
			On Products.ProductID = Inventories.ProductID
		Inner Join dbo.Categories
			On Categories.CategoryID = Products.CategoryID
		Order By 1,2,3,4
go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

Drop View If Exists dbo.vInventoriesByProductsByEmployees;
go

Create View vInventoriesByProductsByEmployees
With Schemabinding
As
	Select TOP 10000000
		CategoryName, ProductName, InventoryDate, Count, [EmployeeName] = (EmployeeFirstName + ' ' + EmployeeLastName)
		From dbo.Products
		Inner Join dbo.Inventories
			On Products.ProductID = Inventories.ProductID
		Inner Join dbo.Categories
			On Categories.CategoryID = Products.CategoryID
		Inner Join dbo.Employees
			On Employees.EmployeeID = Inventories.EmployeeID
		Order By 3,1,2,5
go


-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

Drop View If Exists dbo.vInventoriesForChaiAndChangByEmployees;
go

Create View vInventoriesForChaiAndChangByEmployees
With Schemabinding
As
	Select TOP 10000000
		CategoryName, ProductName, InventoryDate, Count, [EmployeeName] = (EmployeeFirstName + ' ' + EmployeeLastName)
		From dbo.Products
		Inner Join dbo.Inventories
			On Products.ProductID = Inventories.ProductID
		Inner Join dbo.Categories
			On Categories.CategoryID = Products.CategoryID
		Inner Join dbo.Employees
			On Employees.EmployeeID = Inventories.EmployeeID
		Where ProductName = 'Chai' or ProductName = 'Chang'
		Order By 3,1,2,5
go

Select * From vInventoriesForChaiAndChangByEmployees

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

Drop View If Exists dbo.vEmployeesByManager;
go

Create View vEmployeesByManager
As
	Select TOP 10000000
		M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager,
		E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee
	From Employees as E
	Inner Join Employees as M
		On E.ManagerID = M.EmployeeID
	Order By 1,2
go

-- SchemaBinding not allowed



-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan


-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

Drop View If Exists dbo.vInventoriesByProductsByCategoriesByEmployees;
go
Create View vInventoriesByProductsByCategoriesByEmployees
As
	Select
		vCategories.CategoryID,
		vCategories.CategoryName,
		vProducts.ProductID,
		vProducts.ProductName,
		vProducts.UnitPrice,
		vInventories.InventoryID,
		vInventories.InventoryDate,
		vInventories.Count,
		vEmployees.EmployeeID,
		E.EmployeeFirstName + ' ' + E.EmployeeLastName as Employee,
		M.EmployeeFirstName + ' ' + M.EmployeeLastName as Manager
		
		From dbo.vInventories
		Join dbo.vProducts
			On vInventories.ProductID = vProducts.ProductID
		Join dbo.vCategories
			On vCategories.CategoryID = vProducts.CategoryID
		Join dbo.vEmployees
			On vEmployees.EmployeeID = vInventories.EmployeeID
		Join vEmployees as E
			On E.EmployeeID = vEmployees.EmployeeID
		Join vEmployees as M
			On M.ManagerID = vEmployees.ManagerID
go

Select * From vInventoriesByProductsByCategoriesByEmployees


--Attempts: Join on all - received an error, Full Outer Join on all - recieved an error, Successfully used a select all on the two largest
--non overlapping tables, but realized that it was in the wrong order.


-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/