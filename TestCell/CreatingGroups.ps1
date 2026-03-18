#Creating Groups | Adding Users to Groups | Removing Users from Groups

#Get all OUs and display Name and DistinguishedName
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName  #(add to see location)

New-ADGroup -Name "San Diego Admins" -GroupScope Global -Path "OU=San Diego,DC=Adatum,DC=com"  #<creates a global group named San Diego Admins in the San Diego OU>

#Verify the group was created
Get-ADGroup -Filter 'Name -eq "San Diego Admins"'  #<filters the groups to find the one named San Diego Admins>
