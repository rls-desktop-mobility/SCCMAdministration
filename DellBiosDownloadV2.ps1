$durl = "Http://downloads.dell.com/published/Pages/"
$dresp = Invoke-WebRequest -Uri $durl
#'^(?!.*chrome|.*aio|.*ultra)(Latitude.*(5414|5490|5580|5590|7212|7280|7290|7390|7480|7490|5\d{1}00|7\d{1}00|E5470|E5540|E5550|E5570|E6440|E7240|E7250|E7270|E7440|E7450|E7470).*\.html)|^(?!.*chrome|.*aio|.*ultra)(OptiPlex.*(3020M|3040|3050|5040|5050|7010|7020|7040|7050|7060|7070|9010|9020|990).*\.html)|^(?!.*chrome|.*aio|.*ultra|.*r7910)(Precision.*(3520|3541|3620|3630|5520|5530|5540|5810|7510|7540|7710|7720|7730|7740|7820|7910).*\.html)'
$models =  $dresp.Links | Where-Object { $_.href -match '^(?!.*chrome|.*aio|.*ultra)(Latitude.*(5410).*\.html)|^(?!.*chrome|.*aio|.*ultra)(OptiPlex.*(7080).*\.html)|^(?!.*chrome|.*aio|.*ultra|.*r7910)(Precision.*(3640|7750|5550|3551).*\.html)'}
$dlarr = @()
foreach ($html in $models) {
    $foldername = $html.innerhtml
    $driverpage = "Http://downloads.dell.com/published/Pages/$($html.href)"
    $href = ((Invoke-WebRequest -Uri $driverpage).links.where({$_ -like "*bios*"}) | Select-Object -first 1).href
    if ($null -ne $href){
        $dllink = "http://downloads.dell.com"+$href
        $hash = [PSCustomObject]@{
            'Name' = $foldername
            'DLPage' = $dllink
        }
        $dlarr += $hash
    }
}

foreach ($href in $dlarr) {
    $folderobj = (New-Item -Path C:\DellBiosDownloads -Name $href.Name -ItemType Directory -Force)
    $foldername = $folderobj.name
    $exename = $href.DLPage.split('/')[-1]
    $outfilepath = "C:\$foldername\$exename"
    Invoke-WebRequest -Uri $href.DLPage -OutFile $outfilepath -Verbose
}