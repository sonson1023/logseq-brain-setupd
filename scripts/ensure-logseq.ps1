# Claude Code SessionStart hook (Windows)
# Logseq 실행 확인 + 미실행 시 자동 시작

$port = 12315

$listening = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue

if (-not $listening) {
    $logseqExe = "$env:LOCALAPPDATA\Programs\Logseq\Logseq.exe"
    if (Test-Path $logseqExe) {
        Start-Process $logseqExe -WindowStyle Minimized
    } else {
        # winget으로 설치된 경우
        Start-Process "Logseq" -ErrorAction SilentlyContinue
    }

    # API 서버 준비 대기 (최대 10초)
    for ($i = 0; $i -lt 10; $i++) {
        $listening = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue
        if ($listening) { break }
        Start-Sleep -Seconds 1
    }
}

if (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue) {
    Write-Output "Logseq API: Connected (port $port)"
} else {
    Write-Output "Logseq API: Not ready"
}
