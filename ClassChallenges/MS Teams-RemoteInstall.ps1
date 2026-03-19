#<Install MS Teams>

Install-Module -Name MicrosoftTeams -Force -AllowClobber

Connect-MicrosoftTeams #This will prompt for credentials PS will flash on TaskBar

Get-Team #This will list all teams in the tenant

New-Team -DisplayName "Sales Team" -MailNickName "SalesTeam"  #Creates a new team

$team = Get-Team -DisplayName "Sales Team" #Get the team we just created

$team | FL

$Verifieddomain ={LODSA494469.onmicrosoft.com}

$verifiedDomain = (Get-MgOrganization).VerifiedDomains[0].Name

#Get the verified domain for the tenant

LODSA494469.onmicrosoft.com = (Get-MgOrganization).VerifiedDomains{LODSA494469.onmicrosoft.com}.Name

Add-TeamUser -GroupId $team.GroupId -User Allan@$verifiedDomain -Role Member #Add a user to the team

Get-TeamUser -GroupId $team.GroupId #List all users in the team