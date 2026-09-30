$ErrorActionPreference = "Stop"

$IMDS = "http://169.254.169.254/latest"

try {
    # Obtém token IMDSv2
    $Token = Invoke-RestMethod `
        -Method PUT `
        -Uri "$IMDS/api/token" `
        -Headers @{
            "X-aws-ec2-metadata-token-ttl-seconds" = "21600"
        } `
        -TimeoutSec 5

    $Headers = @{
        "X-aws-ec2-metadata-token" = $Token
    }

    # Obtém a lista de nomes das tags
    $TagKeys = Invoke-RestMethod `
        -Uri "$IMDS/meta-data/tags/instance/" `
        -Headers $Headers `
        -TimeoutSec 5

    $Tags = @{}

    # O endpoint retorna as tags como texto separado por linhas
    foreach ($Key in ($TagKeys -split "`r?`n")) {

        $Key = $Key.Trim()

        if ([string]::IsNullOrWhiteSpace($Key)) {
            continue
        }

        try {
            # Obtém o valor da tag
            $Value = Invoke-RestMethod `
                -Uri "$IMDS/meta-data/tags/instance/$Key" `
                -Headers $Headers `
                -TimeoutSec 5

            $Tags[$Key] = [string]$Value
        }
        catch {
            # Ignora uma tag que não pôde ser consultada
            continue
        }
    }

    # Retorna JSON em uma única linha para o Zabbix
    $Tags | ConvertTo-Json -Compress
}
catch {
    # Em caso de erro, retorna JSON vazio
    "{}"
}
