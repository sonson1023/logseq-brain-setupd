# Claude Code SessionStart — 세션 컨텍스트 로드 (Windows)

$Graph = "$env:USERPROFILE\logseq-graph"
$Today = Get-Date -Format "yyyy-MM-dd"
$Yesterday = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")

# ── Logseq 실행 확인 ──
$listening = Get-NetTCPConnection -LocalPort 12315 -ErrorAction SilentlyContinue
if (-not $listening) {
    $logseqExe = "$env:LOCALAPPDATA\Programs\Logseq\Logseq.exe"
    if (Test-Path $logseqExe) { Start-Process $logseqExe -WindowStyle Minimized }
    for ($i = 0; $i -lt 10; $i++) {
        if (Get-NetTCPConnection -LocalPort 12315 -ErrorAction SilentlyContinue) { break }
        Start-Sleep -Seconds 1
    }
}

Write-Output "=== LOGSEQ SESSION CONTEXT ==="
Write-Output ""

# ── 1. Polaris ──
$Polaris = "$Graph\pages\polaris___top-of-mind.md"
if (Test-Path $Polaris) {
    Write-Output "## Polaris (Top of Mind)"
    Get-Content $Polaris | Where-Object { $_ -notmatch "^---" } | Select-Object -First 30
    Write-Output ""
}

# ── 2. 오늘 일지 ──
$TodayJournal = "$Graph\journals\$Today.md"
if (Test-Path $TodayJournal) {
    Write-Output "## Today's Journal ($Today)"
    Get-Content $TodayJournal
    Write-Output ""
}

# ── 3. 어제 일지 ──
$YesterdayJournal = "$Graph\journals\$Yesterday.md"
if (Test-Path $YesterdayJournal) {
    Write-Output "## Previous Session ($Yesterday)"
    Get-Content $YesterdayJournal
    Write-Output ""
}

# ── 4. 최근 일지 (오늘/어제 없을 때) ──
if (-not (Test-Path $TodayJournal) -and -not (Test-Path $YesterdayJournal)) {
    $Latest = Get-ChildItem "$Graph\journals\*.md" -ErrorAction SilentlyContinue | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($Latest) {
        Write-Output "## Latest Journal ($($Latest.BaseName))"
        Get-Content $Latest.FullName
        Write-Output ""
    }
}

# ── 5. 미완료 태스크 ──
Write-Output "## Pending Tasks"
Get-ChildItem "$Graph\pages\*.md", "$Graph\journals\*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    Select-String -Path $_.FullName -Pattern "TODO|DOING|WAITING" -ErrorAction SilentlyContinue
} | Select-Object -First 20 | ForEach-Object {
    $rel = $_.Path -replace [regex]::Escape($Graph), ""
    "$rel → $($_.Line.Trim())"
}
Write-Output ""

# ── 6. 프로젝트 감지 ──
$ClaudeMd = ".claude\CLAUDE.md"
if (Test-Path $ClaudeMd) {
    $ns = Select-String -Path $ClaudeMd -Pattern "Logseq namespace: project/(\S+)" -ErrorAction SilentlyContinue
    if ($ns) {
        $ProjectName = $ns.Matches[0].Groups[1].Value
        Write-Output "## Current Project: $ProjectName"
        $ProjectPage = "$Graph\pages\project___$ProjectName.md"
        if (Test-Path $ProjectPage) {
            Get-Content $ProjectPage | Where-Object { $_ -notmatch "^---" } | Select-Object -First 20
        }
        Write-Output ""
    }
}

Write-Output "=== END CONTEXT ==="
Write-Output ""
Write-Output "위 컨텍스트를 바탕으로 이전 세션의 작업을 이어갈 수 있습니다."
