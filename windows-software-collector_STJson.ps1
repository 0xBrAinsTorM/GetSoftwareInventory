function Invoke-GetSoftwareInventory {
<#
.SYNOPSIS
Local Software Collector - SECIANUS 2020

.DESCRIPTION
Gets installed software information from the local host for further use with vulmon.com. 
#>

    Param (
        [string] $InventoryOutFile = "inventory.json",
        [switch] $Help
    )


    function Get-ProductList() {
        $registry_paths = ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall");
   
        $objectArray = @();
    
        foreach ($registry_path in $registry_paths) {
            
            if ([bool](Get-ChildItem -Path $registry_path -ErrorAction SilentlyContinue)) {
            
                $subkeys = Get-ChildItem -Path $registry_path;
    
                ForEach ($key in $subkeys) {
                    $DisplayName = $key.getValue('DisplayName');
    
                    if (!([string]::IsNullOrEmpty($DisplayName))) {
                        $DisplayVersion = $key.GetValue('DisplayVersion');
    
                        $Object = [pscustomobject]@{ 
                            DisplayName     = $DisplayName.Trim();
                            DisplayVersion  = $DisplayVersion;
                            NameVersionPair = $DisplayName.Trim() + $DisplayVersion;
                        };
    
                        $Object.pstypenames.insert(0, 'System.Software.Inventory');
    
                        $objectArray += $Object;
                    }
                }                   
            }               
        }

        $objectArray | sort-object NameVersionPair -unique;
    }  
 
    function ConvertTo-Json20([object] $item){
    add-type -assembly system.web.extensions
    $ps_js=new-object system.web.script.serialization.javascriptSerializer
    return $ps_js.Serialize($item)
    }
    function Get-Inventory{
        if ($ReadInventoryFile) {
            # read from file
            Write-Host "Reading software inventory from $InventoryInFile...";
            $inventory_json = Get-Content -Encoding UTF8 -Path $InventoryInFile | Out-String;
        } else {
            Write-Host "Collecting software inventory...";
            $inventory = Get-ProductList;
            $inventory_json = ConvertTo-STJson $inventory;
        }
        Write-Host 'Software inventory collected';
        return $inventory_json;

    }
    <#-----------------------------------------------------------[Execution]------------------------------------------------------------#>
    Write-Host 'Collection started...';
    $inventory_json = Get-Inventory;
    # Save Inventory to File
    Write-Host "Saving software inventory to $InventoryOutFile... ";
    $inventory_json | Out-File -Encoding UTF8 -FilePath $InventoryOutFile;
    Write-Host 'Done.';
}

Invoke-GetSoftwareInventory;