Write-Host 'Haloo Maseeehh... Apakah kita akan bermain?' -ForegroundColor Red
Write-Host 'Semoga harimu menyenangkan 😈' -ForegroundColor Red
Write-Host ' 
   ___   ___  _____ ____
  / _ \ ( _ )| ____|  _ \
 | | | |/ _ \|  _| | | | |
 | |_| | (_) | |___| |_| |
  \___/ \___/|_____|____/
  ' -ForegroundColor Green

Write-Host "`n" ; Start-Sleep -Second 1.1 ; Clear-Host

#Terminal-Icons
Import-Module -Name Terminal-Icons

#PSReadLine
Import-Module -Name PSReadLine

#PsFzf
Import-Module -Name PSFzf

#FastFetch
fastfetch

###### Simulate ENTER Push Button #####
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait('{RIGHT}')
##### End Of ENTER Button #####

#Oh-My-Posh
oh-my-posh init pwsh -c 'C:\Users\ASUS\Documents\PowerShell\Oh-My-Posh\iterm2.omp.json' | Invoke-Expression

####### ~PSReadLine~ #######
# Enhanced PSReadLine Configuration
$PSReadLineOptions = @{
  EditMode = 'Windows'
  HistoryNoDuplicates = $true
  HistorySearchCursorMovesToEnd = $true
  Colors = @{
    Command = '#87CEEB'  # SkyBlue (pastel)
    Parameter = '#98FB98'  # PaleGreen (pastel)
    Operator = '#FFB6C1'  # LightPink (pastel)
    Variable = '#DDA0DD'  # Plum (pastel)
    String = '#FFDAB9'  # PeachPuff (pastel)
    Number = '#B0E0E6'  # PowderBlue (pastel)
    Type = '#F0E68C'  # Khaki (pastel)
    Comment = '#D3D3D3'  # LightGray (pastel)
    Keyword = '#8367c7'  # Violet (pastel)
    Error = '#FF6347'  # Tomato (keeping it close to red for visibility)
  }
  PredictionSource = 'HistoryAndPlugin'
  PredictionViewStyle = 'ListView'
  BellStyle = 'None'
}
#PSReadLine
Set-PSReadLineOption @PSReadLineOptions
Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
#Delete a History
Set-PSReadLineKeyHandler -Key Shift+Delete `
  -BriefDescription RemoveFromHistory `
  -LongDescription "Removes the content of the current line from history" `
  -ScriptBlock {
  param($key, $arg)

  $line = $null
  $cursor = $null
  [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)

  $toRemove = [Regex]::Escape(($line -replace "\n", "```n"))
  $history = Get-Content (Get-PSReadLineOption).HistorySavePath -Raw
  $history = $history -replace "(?m)^$toRemove\r\n", ""
  Set-Content (Get-PSReadLineOption).HistorySavePath $history
}
## End Of Delete History
####### ~END OF PSReadLine~ #######

#Fuction Reload Profile
function reload-profile
{
  & $profile
}
#Function which
function which ($command)
{
  Get-Command -Name $command -ErrorAction SilentlyContinue |
    Select-Object -ExpandProperty Path -ErrorAction SilentlyContinue
}
#Fuction pgrep
function pgrep($name)
{
  Get-Process $name
}
#Function pkill
function pkill
{
  param (
    [string]$name
  )
  process
  {
    if ($name)
    {
      Get-Process $name -ErrorAction SilentlyContinue | Stop-Process
    } else
    {
      $input | ForEach-Object { Get-Process $_ -ErrorAction SilentlyContinue | Stop-Process }
    }
  }
}

###### Function Hash Check #####
function Compute-Hash
{
  param (
    [string]$Value,
    [string]$Algorithm
  )

  if (Test-Path $Value -PathType Leaf)
  {
    Get-FileHash -Path $Value -Algorithm $Algorithm
  } else
  {
    $StringStream = [IO.MemoryStream]::new([byte[]][char[]]$Value)
    Get-FileHash -InputStream $StringStream -Algorithm $Algorithm
  }
}
function md5($value)
{ Compute-Hash $value MD5 
}
function sha1($value)
{ Compute-Hash $value SHA1 
}
function sha256($value)
{ Compute-Hash $value SHA256 
}
##### END OF HASH CHECK ######

#Aliases
Set-Alias tt tree
Set-Alias ll ls
Set-Alias npp "C:\Program Files\Notepad++\notepad++.exe"

#gSudo
Import-Module "gsudoModule"

# Zoixide 
Invoke-Expression (& { (zoxide init powershell | Out-String) })
# =============================================================================
#
# Utility functions for zoxide.
#

# Call zoxide binary, returning the output as UTF-8.
function global:__zoxide_bin
{
  $encoding = [Console]::OutputEncoding
  try
  {
    [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
    $result = zoxide @args
    return $result
  } finally
  {
    [Console]::OutputEncoding = $encoding
  }
}

# pwd based on zoxide's format.
function global:__zoxide_pwd
{
  $cwd = Get-Location
  if ($cwd.Provider.Name -eq "FileSystem")
  {
    $cwd.ProviderPath
  }
}

# cd + custom logic based on the value of _ZO_ECHO.
function global:__zoxide_cd($dir, $literal)
{
  $dir = if ($literal)
  {
    Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
  } else
  {
    if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1))
    {
      Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
    } elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2))
    {
      Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
    } else
    {
      Set-Location -Path $dir -Passthru -ErrorAction Stop
    }
  }
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
$global:__zoxide_oldpwd = __zoxide_pwd
function global:__zoxide_hook
{
  $result = __zoxide_pwd
  if ($result -ne $global:__zoxide_oldpwd)
  {
    if ($null -ne $result)
    {
      zoxide add "--" $result
    }
    $global:__zoxide_oldpwd = $result
  }
}

# Initialize hook.
$global:__zoxide_hooked = (Get-Variable __zoxide_hooked -ErrorAction Ignore -ValueOnly)
if ($global:__zoxide_hooked -ne 1)
{
  $global:__zoxide_hooked = 1
  $global:__zoxide_prompt_old = $function:prompt

  function global:prompt
  {
    if ($null -ne $__zoxide_prompt_old)
    {
      & $__zoxide_prompt_old
    }
    $null = __zoxide_hook
  }
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function global:__zoxide_z
{
  if ($args.Length -eq 0)
  {
    __zoxide_cd ~ $true
  } elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+'))
  {
    __zoxide_cd $args[0] $false
  } elseif ($args.Length -eq 1 -and (Test-Path -PathType Container -LiteralPath $args[0]))
  {
    __zoxide_cd $args[0] $true
  } elseif ($args.Length -eq 1 -and (Test-Path -PathType Container -Path $args[0] ))
  {
    __zoxide_cd $args[0] $false
  } else
  {
    $result = __zoxide_pwd
    if ($null -ne $result)
    {
      $result = __zoxide_bin query --exclude $result "--" @args
    } else
    {
      $result = __zoxide_bin query "--" @args
    }
    if ($LASTEXITCODE -eq 0)
    {
      __zoxide_cd $result $true
    }
  }
}

# Jump to a directory using interactive search.
function global:__zoxide_zi
{
  $result = __zoxide_bin query -i "--" @args
  if ($LASTEXITCODE -eq 0)
  {
    __zoxide_cd $result $true
  }
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

#Z alias
Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

# =============================================================================
#
# To initialize zoxide, add this to your configuration (find it by running
# `echo $profile` in PowerShell):
#
# Invoke-Expression (& { (zoxide init powershell | Out-String) })

#Yazi
function y
{
  $tmp = (New-TemporaryFile).FullName
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp -Encoding UTF8
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
  {
    Set-Location -LiteralPath (Resolve-Path -LiteralPath $cwd).Path
  }
  Remove-Item -Path $tmp
}
