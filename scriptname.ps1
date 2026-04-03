# Prompt user for password (hidden input)
$password = Read-Host "Enter a password" -AsSecureString

# Ask for confirmation
$confirm = Read-Host "Re-enter password to confirm" -AsSecureString

# Convert both to plain text for comparison
$plain1 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)
)
$plain2 = [Runtime.InteropServices.Marshal]::PtrToStringAuto(
    [Runtime.InteropServices.Marshal]::SecureStringToBSTR($confirm)
)

# Check match
if ($plain1 -ne $plain2) {
    Write-Host "`nPasswords do NOT match. Exiting." -ForegroundColor Red
    return
}

$plain = $plain1  # Use the confirmed password

$score = 0
$reasons = @()

# Length scoring
switch ($plain.Length) {
    {$_ -ge 16} { $score += 3; $reasons += "Very long length (16+)" ; break }
    {$_ -ge 12} { $score += 2; $reasons += "Good length (12+)" ; break }
    {$_ -ge 8}  { $score += 1; $reasons += "Minimum recommended length (8+)" ; break }
    default     { $reasons += "Too short (under 8 characters)" }
}

# Character variety
if ($plain -match "[A-Z]") { $score += 1; $reasons += "Contains uppercase letters" }
if ($plain -match "[a-z]") { $score += 1; $reasons += "Contains lowercase letters" }
if ($plain -match "\d")    { $score += 1; $reasons += "Contains numbers" }
if ($plain -match "[^a-zA-Z0-9]") { $score += 1; $reasons += "Contains symbols" }

# Determine strength
if ($score -le 3) {
    $strength = "Weak"
    $color = "Red"
}
elseif ($score -le 6) {
    $strength = "Medium"
    $color = "Yellow"
}
else {
    $strength = "Strong"
    $color = "Green"
}

Write-Host "`nPassword strength: $strength" -ForegroundColor $color
Write-Host "Reasons:"
$reasons | ForEach-Object { Write-Host " - $_" }