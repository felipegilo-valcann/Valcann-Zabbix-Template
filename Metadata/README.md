# AWS EC2 Metadata — Zabbix Agent 2

Configuração para coleta de metadata das instâncias AWS EC2 através do **IMDSv2** utilizando o Zabbix Agent 2.

## Arquivos

```text
ec2_metadata_windows.conf
ec2_metadata_linux.conf
ec2_tags.ps1
ec2_tags.sh
```

Utilize os arquivos correspondentes ao sistema operacional da instância.

---

# Windows

## 1. Arquivo de configuração

O arquivo deve ser armazenado em:

```text
C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\
```

### Download via PowerShell

Executar o PowerShell como **Administrador**:

```powershell
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/felipegilo-valcann/Valcann-Zabbix-Template/main/Metadata/ec2_metadata_windows.conf" `
  -OutFile "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\ec2_metadata_windows.conf"
```

### Ou utilizando curl

```powershell
curl.exe -L `
  -o "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\ec2_metadata_windows.conf" `
  "https://raw.githubusercontent.com/felipegilo-valcann/Valcann-Zabbix-Template/main/Metadata/ec2_metadata_windows.conf"
```

### Validar arquivo

```powershell
Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\ec2_metadata_windows.conf"
```

---

## 2. Script ec2_tags.ps1

O item `ec2.tags` utiliza um script PowerShell para consultar dinamicamente as tags da instância através do IMDSv2.

### Criar pasta scripts

```powershell
New-Item `
  -ItemType Directory `
  -Path "C:\Program Files\Zabbix Agent 2\scripts" `
  -Force
```

### Download via PowerShell

```powershell
Invoke-WebRequest `
  -Uri "https://raw.githubusercontent.com/felipegilo-valcann/Valcann-Zabbix-Template/main/Metadata/ec2_tags.ps1" `
  -OutFile "C:\Program Files\Zabbix Agent 2\scripts\ec2_tags.ps1"
```

### Ou utilizando curl

```powershell
curl.exe -L `
  -o "C:\Program Files\Zabbix Agent 2\scripts\ec2_tags.ps1" `
  "https://raw.githubusercontent.com/felipegilo-valcann/Valcann-Zabbix-Template/main/Metadata/ec2_tags.ps1"
```

### Validar script

```powershell
Get-Item "C:\Program Files\Zabbix Agent 2\scripts\ec2_tags.ps1"
```

---

## 3. Reiniciar o Zabbix Agent 2

```powershell
Restart-Service "Zabbix Agent 2"
```

---

## 4. Testar

```powershell
& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t ec2.instance.id

& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t ec2.region

& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t ec2.account.id

& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t ec2.tags
```

O `ec2.tags` deve retornar um JSON contendo as tags da instância.

Exemplo:

```json
{"Update":"MENSAL","Name":"ABCDIS-VM-WINTHOR-TST","Backup":"True","ResourceGroup":"TESTE","PATCH":"SCAN","QSConfigName-bel35":"patch-manager-abcdis-v2"}
```

---

# Linux

## 1. Arquivo de configuração

O arquivo deve ser armazenado em:

```text
/etc/zabbix/zabbix_agent2.d/
```

### Download via curl

```bash
sudo curl -L \
  -o /etc/zabbix/zabbix_agent2.d/ec2_metadata_linux.conf \
  "https://raw.githubusercontent.com/felipegilo-valcann/Valcann-Zabbix-Template/main/Metadata/ec2_metadata_linux.conf"
```

### Ou utilizando wget

```bash
sudo wget \
  -O /etc/zabbix/zabbix_agent2.d/ec2_metadata_linux.conf \
  "https://raw.githubusercontent.com/felipegilo-valcann/Valcann-Zabbix-Template/main/Metadata/ec2_metadata_linux.conf"
```

### Validar arquivo

```bash
sudo cat /etc/zabbix/zabbix_agent2.d/ec2_metadata_linux.conf
```

---

## 2. Script ec2_tags.sh

O item `ec2.tags` utiliza um script Bash para consultar dinamicamente as tags da instância através do IMDSv2.

### Criar pasta scripts

```bash
sudo mkdir -p /etc/zabbix/scripts
```

### Download via curl

```bash
sudo curl -L \
  -o /etc/zabbix/scripts/ec2_tags.sh \
  "https://raw.githubusercontent.com/felipegilo-valcann/Valcann-Zabbix-Template/main/Metadata/ec2_tags.sh"
```

### Ou utilizando wget

```bash
sudo wget \
  -O /etc/zabbix/scripts/ec2_tags.sh \
  "https://raw.githubusercontent.com/felipegilo-valcann/Valcann-Zabbix-Template/main/Metadata/ec2_tags.sh"
```

### Dar permissão de execução

```bash
sudo chmod +x /etc/zabbix/scripts/ec2_tags.sh
```

### Validar script

```bash
sudo ls -l /etc/zabbix/scripts/ec2_tags.sh
```

### Testar o script diretamente

```bash
sudo /etc/zabbix/scripts/ec2_tags.sh
```

Exemplo de retorno:

```json
{
  "Backup": "true",
  "Name": "ABCDIS-VM-DOCKER",
  "PATCH": "SCAN",
  "QSConfigName-bel35": "patch-manager-abcdis-v2",
  "ResourceGroup": "ABCDIS",
  "aws-apn-id": "pc:8uwwimsdspjcmv1ce58m5frv2"
}
```

---

## 3. Reiniciar o Zabbix Agent 2

```bash
sudo systemctl restart zabbix-agent2
```

### Verificar serviço

```bash
sudo systemctl status zabbix-agent2
```

---

## 4. Testar

```bash
zabbix_agent2 -t ec2.instance.id

zabbix_agent2 -t ec2.region

zabbix_agent2 -t ec2.account.id

zabbix_agent2 -t ec2.tags
```

---

# Metadata coletados

Os arquivos disponibilizam as seguintes keys no Zabbix:

```text
ec2.instance.id
ec2.region
ec2.account.id
ec2.tags
```

## ec2.tags

A key `ec2.tags` realiza a descoberta dinâmica das tags da instância EC2 através do **IMDSv2**.

Não é necessário definir previamente os nomes das tags.

Por exemplo, uma instância pode possuir:

```text
Name
Backup
PATCH
Environment
Owner
QSConfigName-bel35
```

Todas as tags serão coletadas automaticamente.

Caso uma nova tag seja adicionada posteriormente à instância, ela também será identificada na próxima coleta.

O resultado é retornado em formato JSON.

---

# Pré-requisitos

## Windows

* Zabbix Agent 2 instalado
* PowerShell disponível
* Acesso ao AWS IMDSv2
* **Allow tags in instance metadata** habilitado para utilização do `ec2.tags`
* Script `ec2_tags.ps1` armazenado em `scripts`

## Linux

* Zabbix Agent 2 instalado
* `curl` instalado
* `jq` instalado
* Acesso ao AWS IMDSv2
* **Allow tags in instance metadata** habilitado para utilização do `ec2.tags`
* Script `ec2_tags.sh` armazenado em `scripts`
* Permissão de execução no `ec2_tags.sh`

---

# Estrutura dos arquivos

## Windows

```text
C:\Program Files\Zabbix Agent 2\
│
├── zabbix_agent2.d\
│   └── ec2_metadata_windows.conf
│
└── scripts\
    └── ec2_tags.ps1
```

## Linux

```text
/etc/zabbix/
│
├── zabbix_agent2.d/
│   └── ec2_metadata_linux.conf
│
└── scripts/
    └── ec2_tags.sh
```

---

# Fluxo do ec2.tags

```text
                  AWS EC2
                     │
                     ▼
                   IMDSv2
                     │
                     ▼
          Instance Metadata Tags
                     │
             ┌───────┴───────┐
             │               │
          Windows           Linux
             │               │
       ec2_tags.ps1      ec2_tags.sh
             │               │
             └───────┬───────┘
                     │
                     ▼
                    JSON
                     │
                     ▼
               Zabbix Agent 2
                     │
                     ▼
                  ec2.tags
```
