# Shared helper functions for Alteryx Designer and AlteryxEngineCmd.exe discovery

function Add-CandidatePath {
    param(
        [System.Collections.Generic.List[string]] $Paths,
        [string] $Path
    )

    if ([string]::IsNullOrWhiteSpace($Path)) {
        return
    }

    $expanded = [Environment]::ExpandEnvironmentVariables($Path.Trim('"'))
    if (-not $Paths.Contains($expanded)) {
        [void] $Paths.Add($expanded)
    }
}

function Add-CandidateChildPath {
    param(
        [System.Collections.Generic.List[string]] $Paths,
        [string] $BasePath,
        [string] $ChildPath
    )

    if ([string]::IsNullOrWhiteSpace($BasePath)) {
        return
    }

    Add-CandidatePath -Paths $Paths -Path (Join-Path $BasePath $ChildPath)
}

function Get-PropertyString {
    param(
        [object] $Object,
        [string] $Name
    )

    if ($null -eq $Object) {
        return $null
    }
    if ($Object.PSObject.Properties.Name -notcontains $Name) {
        return $null
    }
    return [string] $Object.$Name
}

function Add-UninstallInstallCandidate {
    param(
        [System.Collections.Generic.List[string]] $Roots,
        [object] $Properties
    )

    Add-CandidatePath -Paths $Roots -Path (Get-PropertyString -Object $Properties -Name "InstallLocation")

    $displayIcon = Get-PropertyString -Object $Properties -Name "DisplayIcon"
    if ([string]::IsNullOrWhiteSpace($displayIcon)) {
        return
    }

    $iconPath = $displayIcon.Trim('"')
    if ($iconPath -match "^(.*?\.exe)") {
        $iconPath = $Matches[1]
    }
    if ([string]::IsNullOrWhiteSpace($iconPath)) {
        return
    }

    $parent = Split-Path -Path $iconPath -Parent -ErrorAction SilentlyContinue
    if (-not $parent) {
        return
    }
    if ((Split-Path -Path $parent -Leaf) -ieq "bin") {
        $parent = Split-Path -Path $parent -Parent
    }
    Add-CandidatePath -Paths $Roots -Path $parent
}

function Add-RegistryInstallCandidates {
    param([System.Collections.Generic.List[string]] $Roots)

    $directKeys = @(
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\SRC\Alteryx",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\SRC\Alteryx",
        "Registry::HKEY_CURRENT_USER\SOFTWARE\SRC\Alteryx"
    )
    $valueNames = @("InstallDir", "InstallDir64", "Path", "RootDir", "InstallLocation", "InstallPath", "LastInstallDir")

    foreach ($key in $directKeys) {
        if (-not (Test-Path $key)) {
            continue
        }

        $properties = Get-ItemProperty -Path $key -ErrorAction SilentlyContinue
        foreach ($valueName in $valueNames) {
            Add-CandidatePath -Paths $Roots -Path (Get-PropertyString -Object $properties -Name $valueName)
        }
    }

    $uninstallKeys = @(
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall",
        "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall",
        "Registry::HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
    )

    foreach ($uninstallKey in $uninstallKeys) {
        if (-not (Test-Path $uninstallKey)) {
            continue
        }

        foreach ($child in Get-ChildItem -Path $uninstallKey -ErrorAction SilentlyContinue) {
            $properties = Get-ItemProperty -Path $child.PSPath -ErrorAction SilentlyContinue
            $displayName = Get-PropertyString -Object $properties -Name "DisplayName"
            if ($displayName -notmatch "Alteryx") {
                continue
            }

            Add-UninstallInstallCandidate -Roots $Roots -Properties $properties
        }
    }
}

function Get-InstallDirFromIni {
    $candidates = [System.Collections.Generic.List[string]]::new()

    # 1. User app data (Roaming)
    $userRoaming = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::ApplicationData)
    if ($userRoaming) {
        $userEnginePath = Join-Path $userRoaming "Alteryx\Engine"
        if (Test-Path -Path $userEnginePath -PathType Container) {
            Get-ChildItem -Path $userEnginePath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $ini = Join-Path $_.FullName "InstallInfo.ini"
                $fipsIni = Join-Path $_.FullName "FIPSInstallInfo.ini"
                if (Test-Path -Path $ini -PathType Leaf) { [void]$candidates.Add($ini) }
                if (Test-Path -Path $fipsIni -PathType Leaf) { [void]$candidates.Add($fipsIni) }
            }
        }
    }

    # 2. System common app data (ProgramData)
    $commonAppData = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::CommonApplicationData)
    if ($commonAppData) {
        $commonEnginePath = Join-Path $commonAppData "Alteryx\Engine"
        if (Test-Path -Path $commonEnginePath -PathType Container) {
            Get-ChildItem -Path $commonEnginePath -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                $ini = Join-Path $_.FullName "InstallInfo.ini"
                $fipsIni = Join-Path $_.FullName "FIPSInstallInfo.ini"
                if (Test-Path -Path $ini -PathType Leaf) { [void]$candidates.Add($ini) }
                if (Test-Path -Path $fipsIni -PathType Leaf) { [void]$candidates.Add($fipsIni) }
            }
        }
    }

    # Sort candidates descending by LastWriteTime to get the most recently configured installation
    foreach ($iniPath in ($candidates | Sort-Object { (Get-Item $_).LastWriteTime } -Descending)) {
        if (Test-Path -Path $iniPath -PathType Leaf) {
            $content = Get-Content -Path $iniPath -Raw -ErrorAction SilentlyContinue
            if ($content -match "(?m)^\s*InstallDir64\s*=\s*(.+)$") {
                $path = $Matches[1].Trim()
                if (Test-Path -Path $path -PathType Container) {
                    return $path
                }
            }
        }
    }
    return $null
}

function Get-CandidateDesignerRoots {
    param([string] $ExplicitDesignerRoot)

    $roots = [System.Collections.Generic.List[string]]::new()
    Add-CandidatePath -Paths $roots -Path $ExplicitDesignerRoot

    # Prioritize discovery from official InstallInfo.ini
    $iniRoot = Get-InstallDirFromIni
    if ($iniRoot) {
        Add-CandidatePath -Paths $roots -Path $iniRoot
    }

    Add-CandidatePath -Paths $roots -Path $env:ALTERYX_DESIGNER_ROOT
    Add-CandidatePath -Paths $roots -Path $env:ALTERYX_INSTALL_DIR
    Add-CandidatePath -Paths $roots -Path $env:ALTERYX_HOME
    Add-CandidateChildPath -Paths $roots -BasePath $env:LOCALAPPDATA -ChildPath "Alteryx"
    Add-RegistryInstallCandidates -Roots $roots
    Add-CandidateChildPath -Paths $roots -BasePath $env:ProgramFiles -ChildPath "Alteryx"
    Add-CandidateChildPath -Paths $roots -BasePath ${env:ProgramFiles(x86)} -ChildPath "Alteryx"
    Add-CandidateChildPath -Paths $roots -BasePath $env:ProgramW6432 -ChildPath "Alteryx"
    Add-CandidatePath -Paths $roots -Path "C:\Program Files\Alteryx"
    Add-CandidatePath -Paths $roots -Path "C:\Program Files (x86)\Alteryx"
    return $roots
}
