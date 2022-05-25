### Mandatory - If any attributes added or removed in the plugin, increment the plugin version here to update the plugins template.
$version = 1.69  

### Mandatory - Setting this to true will alert you when there is a communication problem while posting plugin data to server
$heartbeat = "true" 

### OPTIONAL - Display name to be displayed in Site24x7 client
$displayname = "PSite24x7 Client Process Viewer"

### Variable for IP address/hostname of server
$ipAddress = "8.8.4.4"

### The Get-Data method contains Sample data. Replace you code logic to populate the monitoring data
Function Get-Data()  
{
    $name = "Process"
    $CPU = 81
    $Memory = 85
    
    if($Memory -gt 80)
    {
    	### OPTIONAL- Set the message to be displayed in the "Reason" in Log Report
        $msg = "Memory Usage increases to "+$Memory +"%" 
    }
    
    $data = @{}
    $data.Add("CPU", $CPU)
    $data.Add("Memory", $Memory)
    $data.Add("name", $name)
    
    ### Set the message to be displayed in the "Reason" in Log Report
    $data.Add("msg", $msg)
    
    return $data
}

### These units specified will be displayed in the Dashboard
Function Set-Units() 
{
    $units = @{}
    $units.Add("CPU","%")
    $units.Add("Memory", "%")
    $units.Add("Average Ping","milliseconds")
    $units.Add("Average Packet Loss", "%")
    return $units
}

### Get the average ping and packet loss to a server
Function Avg-Ping-PacketLoss($ipToPing)
{
    $pinginfo = @{}
    $bytesToPing = 64
    $pingCount = 10
    $packetLossAvg = 0
    $pingAvg = 0


    for ($i = 0; $i -lt $pingCount; $i += 1){
        $pingData = Test-Connection -ComputerName $ipToPing -Count 1 -BufferSize $bytesToPing
        if ($pingData){
            $pingAvg += [int32]$pingData.ResponseTime
            $packetLossAvg += $bytesToPing - [int32]$pingData.ReplySize
        }
        else {
            $pingAvg += 0
            $packetLossAvg += $bytesToPing
        }
        
    }

    $pingAvg /= $pingCount
    $packetLossAvg = $packetLossAvg / ($bytesToPing * $pingCount)

    $pinginfo.Add("Average Ping", $pingAvg)
    $pinginfo.Add("Average Packet Loss", $packetLossAvg)

    return $pinginfo
}

$mainJson = @{}

### Configuration info for the plugin
$mainJson.Add("plugin_version", $version)
$mainJson.Add("heartbeat_required", $heartbeat)
$mainJson.Add("displayname", $displayname) 

### Populates the monitoring data and its units
$mainJson.Add("data", (Get-Data))
$mainJson.Add("units", (Set-Units)) 
###$mainJson.Add("ping-info", (Avg-Ping-PacketLoss('google.com')))
$mainJson.Add("average-ping/packet-loss", (Avg-Ping-PacketLoss($ipAddress)))

### Returns the monitoring data to Site24x7 servers
return $mainJson | ConvertTo-Json



