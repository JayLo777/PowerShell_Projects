#<<<Ceate a user account in the OU>>> Using Sand Diego OU as an example

#$password = (ConvertTo-Securestring "P@$$w0rd2!" -AsPlainText -Force)  #<creates a secure string password from the plain text password P@$$w0rd2!>
Import-Module ActiveDirectory

$Password = (ConvertTo-SecureString "P@$$w0rD123!"  -AsPlainText -Force)  #<creates a secure string password from the plain text password P@$$w0rD123!>
#Single user account creation
New-ADUser `
    -Name "John Smith" `
    -GivenName "John" `
    -Surname "Smith" `
    -SamAccountName "JohnSmith" `
    -UserPrincipalName "JohnSmith@Adatum.com" `
    -AccountPassword $Password `
    -Enabled $true `
    -Path "OU=San Diego,DC=Adatum,DC=com"  #<creates a user account named John Smith with the password P@$$w0rD123! in the San Diego OU>


Get-ADUser -Filter 'Name -eq "John"'  #<filters the user accounts to find the one named John>
Get-ADUser -Filter * -SearchBase "OU=San Diego,DC=Adatum,DC=com" | #<filters all user accounts within the San Diego OU>
Format-Table Name, UserPrincipalName, Enabled, Department

#Remove user account
Remove-ADUser -Identity "John"  #<removes the user account named John>




#Creating Groups
New-ADGroup -Name "San Diego Admins" -GroupScope Global -Path "OU=San Diego,DC=Adatum,DC=com"  #<creates a global group named San Diego Admins in the San Diego OU>
#Verify the group was created
Get-ADGroup -Filter 'Name -eq "San Diego Admins"'  #<filters the groups to find the one named San Diego Admins>

