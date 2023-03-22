# Oto Brglez - <otobrglez@gmail.com>
Function ReadEnv {
    [CmdletBinding()]
    param([Parameter(Mandatory)] [string] $Name)
    $Value = [Environment]::GetEnvironmentVariable($Name)
    if ([string]::IsNullOrEmpty($Value)) {
        Write-Error "Variable $Name is not set."; exit(1)
    }
    else { $Value }
}

Function GetPodcastStats {
    $AnchorCollectorPath = ReadEnv("ANCHOR_COLLECTOR_PATH"); $AnchorCollectorEmail = ReadEnv("ANCHOR_COLLECTOR_EMAIL"); $AnchorCollectorPassword = ReadEnv("ANCHOR_COLLECTOR_PASSWORD")
    Invoke-Expression "$AnchorCollectorPath --email '$AnchorCollectorEmail' --password '$AnchorCollectorPassword' --format json" | ConvertFrom-Json  -Depth 20
}

Function GetYouTubeStats {
    $YTCollectorPath = ReadEnv("YT_COLLECTOR_PATH"); $YTCollectorKey = ReadEnv("YT_KEY"); $YTCollectorChannel = ReadEnv("YT_CHANNEL")
    Invoke-Expression "$YTCollectorPath --yt-key $YTCollectorKey --yt-channel $YTCollectorChannel --format json" | ConvertFrom-Json  -Depth 20
}

Function ViaCache {
    Param([Parameter(Mandatory = $true)] [string] $FunctionName,
          [Parameter(Mandatory = $true)] [string] $CacheFile)
    Try { Get-Content -Path $CacheFile -raw -ErrorAction Stop | ConvertFrom-Json -Depth 20 }
    Catch {
        Write-Host "Fetching data via $FunctionName to $CacheFile"
        $Stats = Invoke-Expression "$FunctionName"
        $Stats | ConvertTo-Json -Depth 20 -Compress | Out-File $CacheFile
        $Stats
    }
}

# Get all podcast episodes from Spotify/Anchor
$PodcastStats = ViaCache -FunctionName "GetPodcastStats" -CacheFile "podcast-stats.json" 
    | Select-Object -ExpandProperty "episodes"
    | Select-Object title, totalPlays

# Get all video statistics from YouTube
$YTStats = ViaCache -FunctionName "GetYouTubeStats" -CacheFile "youtube-stats.json" 
    | Select-Object -ExpandProperty "videos" 
    | Select-Object @{n="Title"; e={$_.snippet.title}}, @{n="ViewCount"; e={$_.statistics.viewCount}}, @{n="LikeCount"; e={$_.statistics.likeCount}}, @{n="CommentCount"; e={$_.statistics.commentCount}}

# Append YouTube stats with podcast stats
Foreach ($Episode in $YTStats) {
    Add-Member -InputObject $Episode -Name "TotalPlays" -MemberType NoteProperty -Value $PodcastStats[$YTStats.IndexOf($Episode)].totalPlays
}

# Dump everything into videos.html file
$YTStats | ConvertTo-Html -Title "Ogrodje Report" | Out-File "report.html"
