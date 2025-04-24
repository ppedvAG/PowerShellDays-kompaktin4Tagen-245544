# 1. CSV importieren
$inventory = Import-Csv -Path 'inventory.csv'

# 2. Liste für Nachbestellungen vorbereiten
$toReorder = @()

# 3. Schleife: Bestandswarnung und Wertberechnung
foreach ($item in $inventory) {
    # Wenn Stock ≤ ReorderLevel, zur Nachbestellung merken
    if ([int]$item.Stock -le [int]$item.ReorderLevel) {
        $toReorder += @{ 
            ItemID       = $item.ItemID
            Name         = $item.Name
            Stock        = $item.Stock
            ReorderLevel = $item.ReorderLevel
        }
    }
    # Gesamtwert im Lager berechnen
    $item.TotalValue = [int]$item.Stock * [decimal]$item.Price
}

# 4. Sortierung nach TotalValue absteigend
$sorted = $inventory | Sort-Object -Property TotalValue -Descending

# 5. Ausgabe in der Konsole
$sorted | Format-Table ItemID,Name,Stock,TotalValue

if ($toReorder.Count -gt 0) {
    Write-Host 'Nachbestellung nötig für:'
    $toReorder | Format-Table ItemID,Name
} else {
    Write-Host 'Kein Nachbestellbedarf.'
}

# 6. Export der Ergebnisse
$sorted | Export-Csv -Path 'inventory_with_value.csv' -NoTypeInformation -Encoding UTF8
$toReorder | Export-Csv -Path 'to_reorder.csv' -NoTypeInformation -Encoding UTF8

Write-Host 'Exports abgeschlossen: inventory_with_value.csv, to_reorder.csv'
