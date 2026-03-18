
Import-Module ActiveDirectory

$Password = (ConvertTo-SecureString "P@$$w0rD123!"  -AsPlainText -Force)  #<creates a secure string password from the plain text password P@$$w0rD123!>

#Make multiple user accounts using a variable.
$Users = @(
    @{Name = "Jane Doe"}
    @{Name = "Michael Jordan"}
    @{Name = "Tom Brady"}  
)
foreach ($User in $Users) {
    New-ADUser `
        -Name $User.Name `
        -GivenName ($User.Name.Split(" ")[0]) `
        -Surname ($User.Name.Split(" ")[1]) `
        -SamAccountName ($User.Name.Replace(" ", "")) `
        -UserPrincipalName ($User.Name.Replace(" ", "") + "@Adatum.com") `
        -AccountPassword $Password `
        -Enabled $true `
        -Department "IT" ` #<Change the Department as needed>
        -Path "OU=San Diego,DC=Adatum,DC=com"  #<creates user accounts for Jane Doe, Michael Jordan, and Tom Brady with the password P@$$w0rD123! in the San Diego OU>
}
#Get-ADUser -Filter 'Name -eq "John"'  #<filters the user accounts to find the one named John>
#Get-ADUser -Filter * -SearchBase "OU=San Diego,DC=Adatum,DC=com" 
Get-ADUser -Filter * -SearchBase "OU=San Diego,DC=Adatum,DC=com" | Format-Table Name, UserPrincipalName, Enabled, Department #<filters all user accounts 

#Exports the user accounts in the San Diego OU to a CSV file named SanDiegoUsers.csv on the desktop>
Get-ADUser -Filter * -Properties DisplayName,EmailAddress,UserPrincipalName,Enabled,Department |
Select Name,DisplayName,SamAccountName,UserPrincipalName,EmailAddress,Enabled,Department |
Export-Csv -Path "$env:USERPROFILE\Desktop\SanDiegoUsers.csv" -NoTypeInformation