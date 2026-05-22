# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# build-installer.ps1 — PowerShell script to cross-compile Gossamer for Windows
# and assemble a WiX 4 MSI installer.
#
# Prerequisites:
#   - Zig 0.14+ on PATH (or via asdf if running in WSL)
#   - WiX Toolset v4+ on PATH (`wix` command)
#   - Run from the repository root
#
# Usage:
#   powershell -File packaging/windows/build-installer.ps1
#
# Output:
#   dist/windows/gossamer-0.3.0-x64.msi

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Configuration ──────────────────────────────────────────────────────────────

$PackageName = 'gossamer'
$Version     = '0.3.0'
$Target      = 'x86_64-windows'
$DistDir     = 'dist\windows'
$MsiOutput   = "$DistDir\$PackageName-$Version-x64.msi"
$WxsFile     = 'packaging\windows\gossamer.wxs'

# ── Helpers ────────────────────────────────────────────────────────────────────

function Write-Step {
    param([string]$Message)
    Write-Host "[build-installer] $Message" -ForegroundColor Cyan
}

function Require-Command {
    param([string]$Name)
    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        Write-Error "Required command not found: $Name. Install it and add to PATH."
        exit 1
    }
}

# ── Preflight ──────────────────────────────────────────────────────────────────

Write-Step "Gossamer Windows installer build — v$Version"

Require-Command zig
Require-Command wix

# Confirm we are running from the repository root.
if (-not (Test-Path 'Justfile')) {
    Write-Error "This script must be run from the Gossamer repository root."
    exit 1
}

# ── Step 1: Cross-compile FFI library for Windows x64 ─────────────────────────

Write-Step "Compiling Zig FFI library for $Target..."
Push-Location 'src\interface\ffi'
try {
    & zig build `
        -Dtarget=$Target `
        -Doptimize=ReleaseSafe
    if ($LASTEXITCODE -ne 0) {
        Write-Error "FFI build failed (exit code $LASTEXITCODE)"
        exit 1
    }
} finally {
    Pop-Location
}

# ── Step 2: Cross-compile CLI for Windows x64 ─────────────────────────────────

Write-Step "Compiling Gossamer CLI for $Target..."
Push-Location 'cli'
try {
    & zig build `
        -Dtarget=$Target `
        -Doptimize=ReleaseSafe
    if ($LASTEXITCODE -ne 0) {
        Write-Error "CLI build failed (exit code $LASTEXITCODE)"
        exit 1
    }
} finally {
    Pop-Location
}

# ── Step 3: Verify expected artefacts exist ────────────────────────────────────

Write-Step "Verifying build artefacts..."

$RequiredFiles = @(
    'src\interface\ffi\zig-out\lib\libgossamer.dll',
    'src\interface\ffi\zig-out\lib\libgossamer.lib',
    'cli\zig-out\bin\gossamer.exe',
    'generated\abi\gossamer.h'
)

foreach ($File in $RequiredFiles) {
    if (-not (Test-Path $File)) {
        Write-Error "Expected build artefact not found: $File"
        exit 1
    }
    Write-Host "  [ok] $File"
}

# ── Step 4: Run WiX to build the MSI ──────────────────────────────────────────

Write-Step "Building MSI installer → $MsiOutput"

if (-not (Test-Path $DistDir)) {
    New-Item -ItemType Directory -Path $DistDir | Out-Null
}

& wix build $WxsFile -o $MsiOutput

if ($LASTEXITCODE -ne 0) {
    Write-Error "WiX build failed (exit code $LASTEXITCODE)"
    exit 1
}

# ── Done ───────────────────────────────────────────────────────────────────────

Write-Step "MSI installer created successfully:"
Get-Item $MsiOutput | Select-Object FullName, Length, LastWriteTime | Format-List
