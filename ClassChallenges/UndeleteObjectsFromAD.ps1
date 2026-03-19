#Undelete Objects from AD

Get-ADDObject -filter {isDeleted -eq $True} -IncludeDeletedObjects -Properties* | Restore-ADDObject
