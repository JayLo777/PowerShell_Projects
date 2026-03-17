#Creating Groups | Adding Users to Groups | Removing Users from Groups

#Verify the OU was created
Get-ADOrganizationalUnit -Filter * | Select Name, #DistinguishedName (add to see location)  #<filters all OUs and displays their names>

#Creates a global group named San Diego Admins in the San Diego OU
New-ADGroup -Name "San Diego Admins" -GroupScope Global -Path "OU=San Diego,DC=Adatum,DC=com"  #<creates a global group named San Diego Admins in the San Diego OU>

#Verify the group was created
Get-ADGroup -Filter 'Name -eq "San Diego Admins"'  #<filters the groups to find the one named San Diego Admins>
