function Meine-Funktion {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, HelpMessage = "Gib deinen Namen ein: ")]
        [string]$Name,

        [Parameter(Mandatory = $false, HelpMessage = "Gib deinen Alter ein:")]
        [int]$Alter = 30,

        [Parameter()]
        [switch]$VerboseMode
    )

    # Funktionslogik
    if($VerboseMode) {
        Write-Host "Starte Funktion mit Parametern: " -ForegroundColor Cyan
        Write-Host "Name: $Name"; Write-Host "Alter: $Alter"
    }
    Write-Host "Hallo, mein Name ist $Name und ich bin $Alter Jahre alt."
}

# Erstelle neue Datei

# Definiere im oberen Bereich ein param-Block mit folgenden Parametern: 
# [string]$DateiPfad (Mandatory): PFad zu einer Datei
# int $MaxZeilen = 100 (optional): Maximale Anzahl Zeilen, die eingelesen werden
# switch $NurKopf (optional): Wenn gesetzt, nur die ersten $maxZeilen Zeilen anzeigen

# Implementiere im Skript folgende Logik:
# Prüfe ob die Datei unter $DateiPfad existiert. Gib im Fehlerfall eine Fehlermeldung aus
# Lies die Datei mit Get-Content ein
# Wenn $NurKopf gesetzt ist, gib nur die ersten $maxZeilen (100) Zeilen aus, andernfalls gib die gesamte Datei aus

# Optional:
# Füge eine Hilfefunktion "HelpMessage" soll eine hilfestellung für jeden Parameter hinzufügen

function Read-File {
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true, HelpMessage = "Gib den Pfad zur einzulesenden Datei an.")]
    [string]$DateiPfad,

    [Parameter(Mandatory = $false, HelpMessage = "Maximale Anzahl Zeilen, die ausgegeben werden.")]
    [int]$MaxZeilen = 100,

    [Parameter(Mandatory = $false, HelpMessage = "Nur die ersten MaxZeilen ausgeben.")]
    [switch]$NurKopf
)

# --- Schritt 1: Existenzprüfung der Datei ---
if (-not (Test-Path -Path $DateiPfad -PathType Leaf)) {
    # Datei existiert nicht → Abbruch mit roter Fehlermeldung
    Write-Host "FEHLER: Datei '$DateiPfad' wurde nicht gefunden." -ForegroundColor Red
    exit 1
}
# Datei vorhanden
Write-Host "Datei gefunden: $DateiPfad"

# --- Schritt 2: Einlesen der Datei ---
$inhalt = Get-Content -Path $DateiPfad
Write-Host "Datei eingelesen: $($inhalt.Count) Zeilen wurden geladen."

# --- Schritt 3: Ausgabe steuern ---
if ($NurKopf) {
    Write-Host "Gebe die ersten $MaxZeilen Zeilen aus:" -ForegroundColor Cyan
    # Berechne, wie viele Zeilen tatsächlich existieren
    $ende = [Math]::Min($MaxZeilen - 1, $inhalt.Count - 1)
    # Ausgabe der Zeilen 0 bis $ende
    for ($i = 0; $i -le $ende; $i++) {
        Write-Host $inhalt[$i]
    }
}
else {
    Write-Host "Gebe die gesamte Datei aus:" -ForegroundColor Cyan
    foreach ($zeile in $inhalt) {
        Write-Host $zeile
    }
}
}