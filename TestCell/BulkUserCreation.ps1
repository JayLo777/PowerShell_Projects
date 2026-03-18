#This will creat Bulk Users in Active Directory using a CSV file. 
#[columns: FirstName, LastName, UserName, Password, OU.]

$Users = Import-Csv -Path "C:\PowerShell_Projects\TestCell\BulkUsers.csv"  #<imports the CSV file and stores it in the $users variable>

foreach ($User in $Users) {  #<loops through each user in the $users variable>
        if (Get-ADUser -Filter "SamAccountName -eq '$($User.SamAccountName)'") {  
        Write-Host "User $($User.UserName) already exists. Skipping creation." 
        
}   else {
        New-ADUser `
        -Name $User.Name `
        -GivenName ($User.Name.Split(" ")[0]) `
        -Surname ($User.Name.Split(" ")[1]) `
        -SamAccountName ($User.Name.Replace(" ", "")) `
        -UserPrincipalName ($User.Name.Replace(" ", "") + "@domain.com") `
        -AccountPassword (ConvertTo-SecureString -AsPlainText $User.Password -Force) `
        -Enabled $true `
        -Department $User.Department ` #<Change the Department as needed>
        -Path "OU=San Diego,DC=domain,DC=com"  
  }

    #$FirstName = $User.FirstName  #<stores the FirstName column value in the $FirstName variable>
    #$LastName = $User.LastName  #<stores the LastName column value in the $LastName variable>
    #$UserName = $User.UserName  #<stores the UserName column value in the $UserName variable>
    #$Password = $User.Password  #<stores the Password column value in the $Password variable>
    #$OU = $User.OU  #<stores the OU column value in the $OU variable>

    #New-ADUser -Name "$FirstName $LastName" -GivenName $FirstName -Surname $LastName -SamAccountName $UserName -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force) -Enabled $true -Path "OU=$OU,DC=Adatum,DC=com"  #<creates a new AD user with the specified properties and adds it to the specified OU>
}   