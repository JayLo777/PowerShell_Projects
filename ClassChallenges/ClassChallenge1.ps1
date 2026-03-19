#1. Creates an Organizational Unit (OU) named "London" if it does not exist. If it does exist  
# HINT: Use IF ELSE logic 
# HINT: Use IF ELSE logic  
#$DomainDN = "DC=Adatum,DC=com" 
#$OUPath = "OU=$OUName,$DomainDN" 

Get-ADOrganizationalUnit -Filter "name -eq  'OU-London,DC=Adatum,DC=com'" 

#Make a Varable
$OUName = "London"
$DomainDN = "DC=Adatum,DC=com"
$OUPath = "OU=$OUName,$DomainDN"

Get-ADOrganizationalUnit -Filter "Name -eq '$OUName'" -SearchBase $DomainDN 
   
#Create the OU with if #<# Action to perform if the condition is true #>

if ($null -eq $OUName ){
    New-ADOrganizationalUnit -Name $OUName -Path $DomainDN
    Write-Host " OU $OUName does not exist"}
    else { Write-Host "OU $OUName already exist" 
    }

#Part 2 Inside the new "London" OU create a global security group named "London Users" ( Adding Sales & Users)

$OUName = "London"
$DomainDN = "DC=Adatum,DC=com"
$OUPath = "OU=$OUName,$DomainDN"
$GroupName = "London Users"
$OUSale = "OU=Sales,DC=Adatum,DC=com"
$LondonCity = "London"

New-ADGroup -Name "London Users" -GroupScope Global -GroupCategory Security -path $OUPath -whatif

#Part 3 Locate all users int the Sales OU that have an address in the city of London and move them into the London OU. 

$users = Get-ADUser -SearchBase "$OUSales" -filter {l -eq "London"} -properties l

foreach ($user in $users) {
    Move-ADObject -Identity $user.DistinguishedName -TargetPath $OULondon
    Write-Host "Moved: $($user.Name) to $OULondon"
}

Get-ADUser -SearchBase $OUPath -Filter * | Select Name, SamAccountName

#$Part 4 Add the London OU user into "London Users" securtity group

$OULondon = "London Users" 
$DomainDN = "DC=Adatum,DC=com"
$PathLondon = "OU=$($OULondon),$($DomainDN)"

$users = Get-ADUser -SearchBase $PathLondon -Filter*

Foreach ($user in $users) {
    Add-ADGroupmember -Identity "London Users" -Members $user
 } Write-Host "Users sucessfully moved."  

 #<# Action when all if and elseif conditions are false #>
Get-ADGroupMember "London Users"


