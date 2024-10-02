use EmployeesDB;
----------------------------------------------------------------------------------------------------------------------------
-- Problem 1: Get all employees that have manager along with Manager's name.
select E.Name as EmploayName,E.ManagerID,E.Salary as salary,M.Name as ManageName
from Employees E inner join  Employees M on E.ManagerID = M.EmployeeID
----------------------------------------------------------------------------------------------------------------------------
-- Problem 2: Get all employees that have manager or does not have manager along with Manager's name, incase no manager name show null
select E.EmployeeID,E.Name as EmployeeName,E.Salary as EmployeeSalary,M.Name as ManagerName
from Employees E left join Employees M on E.ManagerID = M.EmployeeID
-----------------------------------------------------------------------------------------------------------------------------
