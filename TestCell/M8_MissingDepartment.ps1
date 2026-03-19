# Find user accounts with missing department information and export to CSV file
Get-ADUser -Filter 'Department -notlike "*"' -Properties Department |
Select-Object Name,SamAccountName,Department |
Export-Csv -Path "C:\GitHub\MissingDepartmentUsers.csv" -NoType


Get-ADUser -Filter 'Department -notlike "*"' -Properties Department |
Where-Object { -not $_.Department } |
Select-Object Name, SamAccountName | format-table -AutoSize
Export-Csv "C:\Temp\UsersMissingDepartment.csv" -NoTypeInformation