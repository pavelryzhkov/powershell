function Shorten-URL {
[CmdletBinding()]
Param (
    [Parameter( Mandatory,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
    [string[]]$URL
)
Process{
    foreach ($u in $URL) {
        (Invoke-WebRequest -Uri https://clck.ru/--?url="$u").content
        }
        }
}
