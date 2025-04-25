# -----------------------------
# 1. Konfigurations-Variablen
# -----------------------------
$ServersFile       = 'servers.csv'
$PatchStatusCsv    = 'patch_status.csv'
$CriticalEventsCsv = 'critical_events.csv'
$AuditReportTxt    = 'audit_report.txt'
$EventHoursBack    = 24
$RequiredKB        = @('KB5001330','KB5006670','KB5016616')

# Arrays für Ergebnisse
$Servers         = @()
$Reachable       = @()
$Unreachable     = @()
$PatchStatus     = @()
$CriticalEvents  = @()

# -----------------------------
# 2. Einlesen der Serverliste
# -----------------------------
$Servers = Import-Csv -Path $ServersFile

# -----------------------------
# 3. Erreichbarkeits-Check
# -----------------------------
foreach ($srv in $Servers) {
    if (Test-Connection -ComputerName $srv.ComputerName -Quiet -Count 1 -TimeoutSeconds 2) {
        $Reachable += $srv
    } else {
        $Unreachable += $srv
    }
}

# -----------------------------
# 4. Patch-Compliance prüfen
# -----------------------------
foreach ($srv in $Reachable) {
    $installed = Get-CimInstance -ClassName Win32_QuickFixEngineering -ComputerName $srv.ComputerName |
                 Select-Object -ExpandProperty HotFixID
    foreach ($kb in $RequiredKB) {
        $isInstalled = $installed -contains $kb
        $PatchStatus += @{ 
            ComputerName = $srv.ComputerName
            Role         = $srv.Role
            Location     = $srv.Location
            KB           = $kb
            Installed    = $isInstalled
        }
    }
}

# -----------------------------
# 5. Event-Log-Audit
# -----------------------------
$timeFilter = (Get-Date).AddHours(-$EventHoursBack).ToString('s')
foreach ($srv in $Reachable) {
    $events = Get-CimInstance -ClassName Win32_NTLogEvent -ComputerName $srv.ComputerName 
               -Filter "Logfile='System' AND TimeWritten >= '$timeFilter'"
    foreach ($e in $events) {
        # EventType 1=Error, 2=Warning, 3=Information
        if ($e.EventType -le 2) {
            $CriticalEvents += @{ 
                ComputerName = $srv.ComputerName
                TimeWritten  = $e.TimeWritten
                EventType    = $e.EventType
                SourceName   = $e.SourceName
                Message      = $e.Message
            }
        }
    }
}

# -----------------------------
# 6. Exporte
# -----------------------------
$PatchStatus    | Export-Csv -Path $PatchStatusCsv    -NoTypeInformation -Encoding UTF8
$CriticalEvents | Export-Csv -Path $CriticalEventsCsv -NoTypeInformation -Encoding UTF8

# -----------------------------
# 7. Konsolen-Report
# -----------------------------
Write-Host "Erreichbare Server  : $($Reachable.Count)"
Write-Host "Nicht erreichbar     : $($Unreachable.Count)"

# Fehlende KBs pro Server
Write-Host "`nFehlende KBs pro Server:" 
$PatchStatus | Where-Object { -not $_.Installed } | 
    Group-Object ComputerName |
    Select-Object Name, @{Name='MissingCount';Expression={$_.Count}} |
    Format-Table -AutoSize

# Top 3 nach kritischen Events
Write-Host "`nTop 3 Server nach kritischen Events:" 
$CriticalEvents |
    Group-Object ComputerName |
    Select-Object Name, @{Name='EventCount';Expression={$_.Count}} |
    Sort-Object EventCount -Descending |
    Select-Object -First 3 |
    Format-Table -AutoSize

# -----------------------------
# 8. Zusammenfassungs-Report
# -----------------------------
$summary = @"
Patch-Audit Report für $(Get-Date -Format 'u')

Unerreichbare Server: $($Unreachable.Count)

Fehlende Updates pro Server:
$($(
    $PatchStatus | Where-Object { -not $_.Installed } |
    Group-Object ComputerName |
    ForEach-Object { "$_ : $($_.Count) fehlend" }
) -join "`n") )

Top 3 Server nach kritischen Events (letzte $EventHoursBack h):
$($( 
    $CriticalEvents |
    Group-Object ComputerName |
    Sort-Object Count -Descending |
    Select-Object -First 3 |
    ForEach-Object { "{0} – {1} Events" -f $_.Name, $_.Count }
) -join "`n") )
"@
$summary | Out-File -FilePath $AuditReportTxt -Encoding UTF8

Write-Host "`nDateien erstellt: $PatchStatusCsv, $CriticalEventsCsv, $AuditReportTxt"