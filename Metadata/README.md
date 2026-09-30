# AWS EC2 Metadata — Zabbix Agent 2

Configuração para coleta de metadata das instâncias AWS EC2 através do **IMDSv2** utilizando o Zabbix Agent 2.

## Arquivos

```text
ec2_metadata_windows.conf
ec2_metadata_linux.conf
```

Utilize o arquivo correspondente ao sistema operacional.

---

## Windows

### Download via PowerShell

Executar o PowerShell como **Administrador**:

```powershell
Invoke-WebRequest `
  -Uri "<URL_DO_ARQUIVO>/ec2_metadata_windows.conf" `
  -OutFile "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\ec2_metadata_windows.conf"
```

Ou utilizando `curl`:

```powershell
curl.exe -L `
  -o "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\ec2_metadata_windows.conf" `
  "<URL_DO_ARQUIVO>/ec2_metadata_windows.conf"
```

> Substitua `<URL_DO_ARQUIVO>` pela URL do repositório onde os arquivos estão armazenados.

### Validar arquivo

```powershell
Get-Content "C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\ec2_metadata_windows.conf"
```

### Reiniciar o Agent 2

```powershell
Restart-Service "Zabbix Agent 2"
```

### Testar

```powershell
& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t ec2.instance.id
& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t ec2.region
& "C:\Program Files\Zabbix Agent 2\zabbix_agent2.exe" -t ec2.account.id
```

---

## Linux

### Download via terminal

Executar:

```bash
sudo curl -L \
  -o /etc/zabbix/zabbix_agent2.d/ec2_metadata_linux.conf \
  "<URL_DO_ARQUIVO>/ec2_metadata_linux.conf"
```

Alternativamente, utilizando `wget`:

```bash
sudo wget \
  -O /etc/zabbix/zabbix_agent2.d/ec2_metadata_linux.conf \
  "<URL_DO_ARQUIVO>/ec2_metadata_linux.conf"
```

> Substitua `<URL_DO_ARQUIVO>` pela URL do repositório onde os arquivos estão armazenados.

### Validar arquivo

```bash
sudo cat /etc/zabbix/zabbix_agent2.d/ec2_metadata_linux.conf
```

### Reiniciar o Agent 2

```bash
sudo systemctl restart zabbix-agent2
```

### Verificar serviço

```bash
sudo systemctl status zabbix-agent2
```

### Testar

```bash
zabbix_agent2 -t ec2.instance.id
zabbix_agent2 -t ec2.region
zabbix_agent2 -t ec2.account.id
```

---

## Metadata coletados

Os arquivos disponibilizam as seguintes keys no Zabbix:

```text
ec2.instance.id
ec2.region
ec2.account.id
```

## Pré-requisitos

### Windows

* Zabbix Agent 2 instalado
* PowerShell disponível
* Acesso ao AWS IMDSv2

### Linux

* Zabbix Agent 2 instalado
* `curl` ou `wget` instalado
* Acesso ao AWS IMDSv2

## Estrutura dos arquivos

```text
AWS EC2 Metadata
│
├── ec2_metadata_windows.conf
│   └── Windows
│       └── C:\Program Files\Zabbix Agent 2\zabbix_agent2.d\
│
└── ec2_metadata_linux.conf
    └── Linux
        └── /etc/zabbix/zabbix_agent2.d/
```
