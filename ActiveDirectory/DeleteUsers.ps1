
#Remove user account
Remove-ADUser -Identity "John"  #<removes the user account named John>

#remove All user accounts in the San Diego OU
Get-ADUser -Filter 'Name -like "*"' -SearchBase "OU=San Diego,DC=Adatum,DC=com" | Remove-ADUser  #<filters all user accounts within the San Diego OU and removes them>

#verify all user accounts in the San Diego OU
Get-ADUser -Filter * -SearchBase "OU=San Diego,DC=Adatum,DC=com"  #<filters all user accounts within the San Diego OU>   

