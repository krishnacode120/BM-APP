param([string]$PostgresBin = 'C:\Program Files\PostgreSQL\17\bin')
$ErrorActionPreference = 'Stop'
$bmRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$bmData = Join-Path $bmRoot 'build\supabase-pg-test'
$bmLog = Join-Path $bmRoot 'build\supabase-pg-test.log'
$bmPort = 55439
$bmPsql = Join-Path $PostgresBin 'psql.exe'
$bmPgCtl = Join-Path $PostgresBin 'pg_ctl.exe'
$bmDatabase = 'bm_foundation_' + [Guid]::NewGuid().ToString('N').Substring(0,12)
function Assert-Command { if ($LASTEXITCODE -ne 0) { throw "Command failed with exit code $LASTEXITCODE" } }
if (-not (Test-Path -LiteralPath $bmData)) {
  & (Join-Path $PostgresBin 'initdb.exe') -D $bmData -U bm_test --auth=trust --encoding=UTF8 --locale-provider=icu --icu-locale=en-US
  Assert-Command
}
& $bmPgCtl -D $bmData status *> $null
$bmStarted = $LASTEXITCODE -ne 0
if ($bmStarted) {
  & $bmPgCtl -D $bmData -l $bmLog -o '-h 127.0.0.1 -p 55439' -t 30 start
  Assert-Command
}
try {
  # Refuse an unrelated PostgreSQL service that happens to use the same port.
  $bmActual = (& $bmPsql -h 127.0.0.1 -p $bmPort -U bm_test -d postgres -Atc 'show data_directory').Trim()
  Assert-Command
  if ([IO.Path]::GetFullPath($bmActual) -ne [IO.Path]::GetFullPath($bmData)) {
    throw 'Test port belongs to a different database cluster'
  }
  & (Join-Path $PostgresBin 'createdb.exe') -h 127.0.0.1 -p $bmPort -U bm_test $bmDatabase
  Assert-Command
  $bmMigrations = Get-ChildItem -LiteralPath (Join-Path $bmRoot 'supabase\migrations') -Filter '*.sql' | Sort-Object Name
  & $bmPsql -h 127.0.0.1 -p $bmPort -U bm_test -d $bmDatabase -v ON_ERROR_STOP=1 -1 -f (Join-Path $PSScriptRoot 'standalone_bootstrap.sql')
  Assert-Command
  foreach ($bmMigration in $bmMigrations) {
    & $bmPsql -h 127.0.0.1 -p $bmPort -U bm_test -d $bmDatabase -v ON_ERROR_STOP=1 -1 -f $bmMigration.FullName
    Assert-Command
  }
  & $bmPsql -h 127.0.0.1 -p $bmPort -U bm_test -d $bmDatabase -v ON_ERROR_STOP=1 -f (Join-Path $PSScriptRoot 'foundation.sql')
  Assert-Command
  Write-Output "Foundation SQL checks passed in $bmDatabase (synthetic fixtures rolled back)."
} finally {
  if ($bmStarted) { & $bmPgCtl -D $bmData -t 30 stop }
}
