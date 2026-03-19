#Exports the user accounts in the San Diego OU to a CSV file named SanDiegoUsers.csv on the c: drive>
Get-ADUser -Filter * -SearchBase "DC=domain,DC=com" -Properties DisplayName,EmailAddress,UserPrincipalName,Enabled,Department |
Select-Object Name,DisplayName,SamAccountName,UserPrincipalName,EmailAddress,Enabled,Department |
Export-Csv -Path "C:\GitHub\SanDiegoUsers.csv" -NoTypeInformation #Change the path and file name as needed
Get-ADUser -Filter * -Properties DisplayName,EmailAddress,UserPrincipalName,Enabled,Department |