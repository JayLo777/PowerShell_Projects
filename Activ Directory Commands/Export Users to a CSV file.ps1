#Exports the user accounts in the San Diego OU to a CSV file named SanDiegoUsers.csv on the desktop>
Get-ADUser -Filter * -Properties DisplayName,EmailAddress,UserPrincipalName,Enabled,Department |
Select Name,DisplayName,SamAccountName,UserPrincipalName,EmailAddress,Enabled,Department |
Export-Csv -Path "$env:USERPROFILE\Desktop\SanDiegoUsers.csv" -NoTypeInformation #Change the path and file name as needed. 
