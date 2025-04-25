$person = [PSCustomObject]@{
    Name = 'Alice'
    Alter = 30
    Abteilung = 'IT'
}

# New-Object
$person1 = New-Object psobject -Property @{
    Name = 'Bob'
    Alter = 45
    Abteilung = 'HR'
}

# Beispiel
$server = @(
    @{ ComputerName = 'srv01'; Role = 'Web'; Location = 'Berlin'}
    @{ ComputerName = 'srv02'; Role = 'DB'; Location = 'Hamburg'}
)

$requiredKB = 'KB5001330', 'KB5006670'

$result = @()

foreach ($s in $server) {
    $installed = 'KB5001330'
    
    foreach($kb in $requiredKB) {
        $result += [PSCustomObject]@{
            ComputerName = $s.ComputerName
            Role = $s.Role
            Location = $s.Location
            KB = $kb 
            Installed = ($kb -contains $installed)
        }
    }
}

$result | ft