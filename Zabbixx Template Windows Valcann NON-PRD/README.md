# Valcann Zabbix Templates

Este repositório contém os templates Zabbix customizados pela **Valcann**, utilizados para monitoramento de servidores Windows.

## Zabbix Template Windows Valcann Non-Production

O **`Zabbix Template Windows Valcann Non-Production`** contém **9 templates**, que são associados ao template principal **`Windows - Monitoring By Valcann Non-Production.yaml`**.

### Templates disponíveis

1. `Windows - Antivirus By Valcann Non-Production.yaml`
2. `Windows - CPU Zabbix agent By Valcann Non-Production.yaml`
3. `Windows - Filesystems Zabbix agent By Valcann Non-Production.yaml`
4. `Windows - Generic Zabbix agent By Valcann Non-Production.yaml`
5. `Windows - Memory Zabbix agent By Valcann Non-Production.yaml`
6. `Windows - Metadata By Valcann Non-Production.yaml`
7. `Windows - Network by Zabbix agent By Valcann Non-Production.yaml`
8. `Windows - Number of logged in users By Valcann Non-Production.yaml`
9. `Windows - Zabbix agent By Valcann Non-Production.yaml`

Esses templates possuem associação com o template principal:

`Windows - Monitoring By Valcann Non-Production.yaml`

## Macro Global `{$CLIENT}`

Os templates utilizam a macro global:

```text
{$CLIENT}
```

Essa macro é utilizada para identificar o cliente nos nomes das triggers e demais configurações que necessitem da identificação do ambiente.

### Importante

Ao importar os templates para um novo cliente, a macro global **`{$CLIENT}` deve ser criada ou ajustada** no Zabbix de acordo com o nome do cliente.

Exemplo:

```text
{$CLIENT} = ABCDIS
```

Caso o nome do cliente seja alterado, a macro também deverá ser atualizada.

## Macro do Template Principal **`Windows - Monitoring By Valcann Non-Production`** `{$AMBIENTE}`

Os templates utilizam a macro do template Principal:

```text
{$AMBIENTE}
```

Essa macro é utilizada para identificar o ambiente nos nomes das triggers.

Exemplo:

```text
{$AMBIENT} = NON-PRD
```
Exemplo na prática utilizando a macro global {$CLIENT} = ABCDIS e a macro do template para ambiente {$AMBIENTE} = NON-PRD

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION IS HIGH (used > 90%)
[P3] ABCDIS | EC2 | {HOST.NAME} | NON-PRD | CPU UTILIZATION IS HIGH (used > 90%)
```

## Criticidade dos Alertas

As triggers dos templates seguem um padrão de criticidade baseado em três níveis:

| Criticidade | Prioridade | Descrição                                                                                                                                                 |
| ----------- | ---------- | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **P1**      | Crítica    | Situação crítica que pode causar indisponibilidade ou impacto significativo no ambiente. Requer atuação imediata.                                         |
| **P2**      | Alta       | Situação de alta severidade que pode evoluir para um incidente crítico caso não seja tratada. Requer atenção e atuação prioritária.                       |
| **P3**      | Média      | Situação que indica degradação ou condição de atenção no ambiente. Deve ser acompanhada e tratada antes que evolua para uma condição de maior severidade. |

### Exemplo de criticidade para utilização de CPU

Como exemplo, as triggers de CPU podem utilizar diferentes níveis de criticidade conforme o percentual de utilização e o tempo de permanência da condição:

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION IS HIGH (used > 90%)
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION IS HIGH (used > 95%)
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION IS CRITICALLY HIGH (used > 99%)
```

Nesse modelo:

* **P3** → CPU acima de 90%;
* **P2** → CPU acima de 95%;
* **P1** → CPU acima de 99%.

As condições podem ser combinadas com um período de permanência, por exemplo, para evitar alertas causados por picos momentâneos de utilização.

### Exemplo de criticidade para espaço em disco

Para filesystem, pode ser utilizado o seguinte padrão:

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | {#FSNAME} DISK SPACE IS LOW (used > 90%)
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | {#FSNAME} DISK SPACE IS VERY LOW (used > 95%)
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | {#FSNAME} DISK SPACE IS CRITICALLY LOW (used > 99%)
```

Onde:

* **P3** → utilização superior a 90%;
* **P2** → utilização superior a 95%;
* **P1** → utilização superior a 99%.

### Evolução da criticidade

Um mesmo host pode apresentar mais de um nível de criticidade para o mesmo recurso, dependendo da condição identificada.

Por exemplo, considerando CPU:

```text
90%  → P3
95%  → P2
99%  → P1
```

Dessa forma, um problema pode inicialmente gerar um alerta **P3** e, caso a condição se agrave, evoluir para **P2** e posteriormente para **P1**.

A lógica das triggers foram configurada de forma que os níveis de maior criticidade tenham prioridade sobre os níveis inferiores quando aplicável, evitando alertas redundantes ou desnecessários.

### Padrão de nomenclatura

Todas as triggers estão usando o padrão:

```text
[P#] {$CLIENT} | <ORIGEM> | {HOST.NAME} | {$AMBIENTE} | <DESCRIÇÃO>
```

Exemplo:

```text
[P1] {$CLIENT} | EC2 | {HOST.NAME} | NON-PRD | {#FSNAME} DISK SPACE IS CRITICALLY LOW (used > 99%)
```

Onde:

* `[P#]` → criticidade do alerta;
* `{$CLIENT}` → identificação do cliente;
* `<ORIGEM>` → origem ou tipo do recurso;
* `{HOST.NAME}` → nome do host;
* `{$AMBIENTE}` → ambiente monitorado;
* `<DESCRIÇÃO>` → condição responsável pelo alerta.

> **Importante:** os valores de percentual e tempo utilizados para determinar P1, P2 e P3 devem seguir a configuração definida para cada recurso/template e não devem ser alterados sem validação prévia.

## Windows — CPU

**Template:** `Windows - CPU Zabbix agent By Valcann Non-Production`

## Visão geral

O monitoramento de CPU utiliza **três níveis de severidade**, definidos através de macros.

O alerta é disparado quando a **utilização mínima de CPU, calculada durante uma janela de 15 minutos**, permanece acima do threshold configurado. 

`Lembrando que a Trigger P1 de CPU não faz parte do padrão da Valcann. Por padrão, ela permanece desabilitada, sendo habilitada somente em casos excepcionais, conforme a necessidade do cliente, como no caso do ABCDIS.`

| Severidade       | Macro                 | Threshold | Condição           |
| ---------------- | --------------------- | --------: | ------------------ |
| **P3 — Warning** | `{$CPU.UTIL.CRIT.P3}` |   **90%** | `>= 90%` e `< 95%` |
| **P2 — Average** | `{$CPU.UTIL.CRIT.P2}` |   **95%** | `>= 95%` e `< 99%` |
| **P1 — High**    | `{$CPU.UTIL.CRIT.P1}` |   **99%** | `>= 99%`           |

---

## Triggers

### P3 — Warning

**Nome:**

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION (over {$CPU.UTIL.CRIT.P3}% for 15m)
```

**Expressão:**

```text
min(/Windows - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m) >= {$CPU.UTIL.CRIT.P3}
and
min(/Windows - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m) < {$CPU.UTIL.CRIT.P2}
```

**Severidade:** `Warning`

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `Indicators` | `Performance` |
| `Name`       | `{HOST.NAME}` |

**Objetivo:**

Indicar que a utilização de CPU está acima do limite de atenção, mas ainda abaixo do nível considerado crítico.

---

### P2 — Average

**Nome:**

```text
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION (over {$CPU.UTIL.CRIT.P2}% for 15m)
```

**Expressão:**

```text
min(/Windows - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m) >= {$CPU.UTIL.CRIT.P2}
and
min(/Windows - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m) < {$CPU.UTIL.CRIT.P1}
```

**Severidade:** `Average`

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `Indicators` | `Performance` |
| `Name`       | `{HOST.NAME}` |

**Objetivo:**

Indicar uma utilização elevada de CPU que pode representar degradação de performance e requer atenção operacional.

---

### P1 — High

**Nome:**

```text
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION (over {$CPU.UTIL.CRIT.P1}% for 15m)
```

**Expressão:**

```text
min(/Windows - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m) >= {$CPU.UTIL.CRIT.P1}
```

**Severidade:** `High`

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `Indicators` | `Performance` |
| `Name`       | `{HOST.NAME}` |

**Objetivo:**

Identificar utilização crítica de CPU, indicando uma possível saturação do recurso e necessidade de atuação operacional.

---

## Resumo dos níveis

| Nível  | Severidade | Threshold |     Janela | Objetivo           |
| ------ | ---------- | --------: | ---------: | ------------------ |
| **P3** | Warning    |   **90%** | 15 minutos | Atenção            |
| **P2** | Average    |   **95%** | 15 minutos | Alta utilização    |
| **P1** | High       |   **99%** | 15 minutos | Possível saturação |

> **Nota:** As condições das triggers são mutuamente exclusivas, garantindo que apenas o nível correspondente à faixa de utilização seja acionado.

## Windows — Filesystems

**Template:** `Windows - Filesystems Zabbix agent By Valcann Non-Production`

## Visão geral

O monitoramento de filesystem utiliza **Low-Level Discovery (LLD)** para identificar automaticamente os volumes/discos presentes no host Windows.

As triggers são criadas como **Trigger Prototypes** e aplicadas automaticamente para cada filesystem descoberto através da macro:

```text
{#FSNAME}
```

O monitoramento utiliza **três níveis de severidade**, definidos através de macros.

| Severidade       | Macro                 | Threshold | Condição           |
| ---------------- | --------------------- | --------: | ------------------ |
| **P3 — Warning** | `{$FS.PUSED.CRIT.P3}` |   **90%** | `>= 90%` e `< 95%` |
| **P2 — Average** | `{$FS.PUSED.CRIT.P2}` |   **95%** | `>= 95%` e `< 99%` |
| **P1 — High**    | `{$FS.PUSED.CRIT.P1}` |   **99%** | `>= 99%`           |

---

## Discovery

As triggers deste template são criadas através do **Filesystem Discovery**.

O filesystem descoberto é representado pela macro:

```text
{#FSNAME}
```

Essa macro é utilizada nas expressões para consultar o percentual de utilização, espaço total e espaço utilizado de cada filesystem.

O item principal utilizado pelas triggers é:

```text
vfs.fs.size[{#FSNAME},pused]
```

---

## Triggers

## P3 — Warning

### P3 — Utilização entre 90% e 95%

**Nome:**

```text id="q7p4m2"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | DISK {#FSNAME} USED 90%)
```

**Expressão:**

```text id="w8k3n6"
last(/Windows - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused]) >= {$FS.PUSED.CRIT.P3}
and
last(/Windows - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused]) < {$FS.PUSED.CRIT.P2}
```

**Severidade:** `Warning`

**Operational data:**

```text id="m5r9x1"
Space used: {ITEM.LASTVALUE3} of {ITEM.LASTVALUE2} ({ITEM.LASTVALUE1})
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `customer`   | `{$CLIENT}`   |
| `Indicators` | `Operational` |

**Objetivo:**

Identificar que o filesystem está apresentando **alta utilização de espaço**, acima do limite de atenção definido para P3.

O alerta é acionado quando o percentual de utilização está entre **90% e 95%**.

---

## P2 — Average

### P2 — Utilização entre 95% e 99%

**Nome:**

```text id="k4v9p2"
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | DISK {#FSNAME} USED 95%)
```

**Expressão:**

```text id="c8m2x5"
last(/Windows - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused]) >= {$FS.PUSED.CRIT.P2}
and
last(/Windows - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused]) < {$FS.PUSED.CRIT.P1}
```

**Severidade:** `Average`

**Operational data:**

```text id="n7f3q1"
Space used: {ITEM.LASTVALUE3} of {ITEM.LASTVALUE2} ({ITEM.LASTVALUE1})
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `customer`   | `{$CLIENT}`   |
| `Indicators` | `Operational` |

**Objetivo:**

Identificar uma utilização crítica de espaço em disco, indicando que o filesystem está próximo da sua capacidade máxima.

O alerta é acionado quando o percentual de utilização está entre **95% e 99%**.

---

## P1 — High

### P1 — Utilização igual ou superior a 99%

**Nome:**

```text id="v3n8q5"
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | DISK {#FSNAME} USED 99%)
```

**Expressão:**

```text id="a6m1r7"
last(/Windows - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused]) >= {$FS.PUSED.CRIT.P1}
```

**Severidade:** `High`

**Operational data:**

```text id="d9k4w2"
Space used: {ITEM.LASTVALUE3} of {ITEM.LASTVALUE2} ({ITEM.LASTVALUE1})
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `customer`   | `{$CLIENT}`   |
| `Indicators` | `Operational` |

**Objetivo:**

Identificar utilização crítica do filesystem, indicando **possível esgotamento imediato do espaço disponível**.

O alerta é acionado quando a utilização do filesystem atinge ou ultrapassa **99%**.

---

## Resumo dos níveis

| Nível  | Severidade | Threshold | Condição principal | Objetivo          |
| ------ | ---------- | --------: | ------------------ | ----------------- |
| **P3** | Warning    |   **90%** | `>= 90%` e `< 95%` | Atenção           |
| **P2** | Average    |   **95%** | `>= 95%` e `< 99%` | Alta utilização   |
| **P1** | High       |   **99%** | `>= 99%`           | Saturação crítica |

## Windows — Generic

**Template:** `Windows - Generic Zabbix agent By Valcann Non-Production`

## Visão geral

O template possui triggers destinadas ao monitoramento de condições gerais do sistema operacional Windows, como reinicializações recentes do host.

---

## Triggers

### P2 — Average

**Nome:**

```text
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | Host "{HOST.NAME}" has been restarted (uptime < 10m)
```

**Expressão:**

```text
last(/Windows - Generic Zabbix agent By Valcann Non-Production/system.uptime) < 10m
```

**Severidade:** `Average`

**Operational data:**

```text
Current uptime: {ITEM.LASTVALUE1}
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `Indicators` | `Operational` |
| `Name`       | `{HOST.NAME}` |

**Objetivo:**

Identificar quando o host Windows foi reiniciado recentemente, considerando como condição de alerta um **uptime inferior a 10 minutos**.

Essa trigger permite identificar reinicializações recentes do servidor, podendo auxiliar na investigação de:

* Reinicializações planejadas ou não planejadas;
* Aplicação de atualizações do sistema operacional;
* Manutenções realizadas no servidor;
* Falhas ou indisponibilidade do sistema operacional;
* Reinicializações decorrentes de incidentes ou intervenções operacionais.

---

## Resumo

| Trigger            | Severidade       | Condição       | Objetivo                                    |
| ------------------ | ---------------- | -------------- | ------------------------------------------- |
| **Host Restarted** | **P2 — Average** | `uptime < 10m` | Identificar reinicialização recente do host |

> **Nota:** A trigger permanece em estado de problema enquanto o uptime do host for inferior a 10 minutos. Após esse período, a condição deixa de ser atendida e o alerta é automaticamente encerrado.

## Windows — Memory

**Template:** `Windows - Memory Zabbix agent By Valcann Non-Production`

## Visão geral

O monitoramento de memória utiliza **três níveis de severidade**, definidos através de macros.

O alerta é disparado quando a **utilização mínima de memória, calculada durante uma janela de 15 minutos**, permanece acima do threshold configurado.

`Lembrando que a Trigger P1 de MEMORIA não faz parte do padrão da Valcann. Por padrão, ela permanece desabilitada, sendo habilitada somente em casos excepcionais, conforme a necessidade do cliente, como no caso do ABCDIS.`

| Severidade       | Macro                   | Threshold | Condição           |
| ---------------- | ----------------------- | --------: | ------------------ |
| **P3 — Warning** | `{$MEMORY.UTIL.MAX.P3}` |   **90%** | `>= 90%` e `< 95%` |
| **P2 — Average** | `{$MEMORY.UTIL.MAX.P2}` |   **95%** | `>= 95%` e `< 99%` |
| **P1 — High**    | `{$MEMORY.UTIL.MAX.P1}` |   **99%** | `>= 99%`           |

---

## Triggers

### P3 — Warning

**Nome:**

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | MEMORY UTILIZATION (> {$MEMORY.UTIL.MAX.P3}% for 15m)
```

**Expressão:**

```text
min(/Windows - Memory Zabbix agent By Valcann Non-Production/vm.memory.util,15m) >= {$MEMORY.UTIL.MAX.P3}
and
min(/Windows - Memory Zabbix agent By Valcann Non-Production/vm.memory.util,15m) < {$MEMORY.UTIL.MAX.P2}
```

**Severidade:** `Warning`

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `Indicators` | `Performance` |
| `Name`       | `{HOST.NAME}` |

**Objetivo:**

Indicar que a utilização de memória está acima do limite de atenção, mas ainda abaixo do nível considerado crítico.

O alerta é acionado quando a utilização mínima de memória permanece **igual ou superior a 90% e inferior a 95% durante 15 minutos**.

---

### P2 — Average

**Nome:**

```text
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | MEMORY UTILIZATION (> {$MEMORY.UTIL.MAX.P2}% for 15m)
```

**Expressão:**

```text
min(/Windows - Memory Zabbix agent By Valcann Non-Production/vm.memory.util,15m) >= {$MEMORY.UTIL.MAX.P2}
and
min(/Windows - Memory Zabbix agent By Valcann Non-Production/vm.memory.util,15m) < {$MEMORY.UTIL.MAX.P1}
```

**Severidade:** `Average`

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `Indicators` | `Performance` |
| `Name`       | `{HOST.NAME}` |

**Objetivo:**

Indicar uma utilização elevada de memória que pode representar degradação de performance e requer atenção operacional.

O alerta é acionado quando a utilização mínima de memória permanece **igual ou superior a 95% e inferior a 99% durante 15 minutos**.

---

### P1 — High

**Nome:**

```text
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | MEMORY UTILIZATION (> {$MEMORY.UTIL.MAX.P1}% for 15m)
```

**Expressão:**

```text
min(/Windows - Memory Zabbix agent By Valcann Non-Production/vm.memory.util,15m) >= {$MEMORY.UTIL.MAX.P1}
```

**Severidade:** `High`

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `Indicators` | `Performance` |
| `Name`       | `{HOST.NAME}` |

**Objetivo:**

Identificar utilização crítica de memória, indicando uma possível saturação do recurso e necessidade de atuação operacional.

O alerta é acionado quando a utilização mínima de memória permanece **igual ou superior a 99% durante 15 minutos**.

---

## Resumo dos níveis

| Nível  | Severidade | Threshold |     Janela | Condição           | Objetivo           |
| ------ | ---------- | --------: | ---------: | ------------------ | ------------------ |
| **P3** | Warning    |   **90%** | 15 minutos | `>= 90%` e `< 95%` | Atenção            |
| **P2** | Average    |   **95%** | 15 minutos | `>= 95%` e `< 99%` | Alta utilização    |
| **P1** | High       |   **99%** | 15 minutos | `>= 99%`           | Possível saturação |

> **Nota:** As condições das triggers são mutuamente exclusivas, garantindo que cada faixa de utilização seja associada ao respectivo nível de severidade.

## Windows — Network

**Template:** `Windows - Network by Zabbix agent By Valcann Non-Production`

## Visão geral

O monitoramento de rede utiliza **Low-Level Discovery (LLD)** para identificar automaticamente as interfaces de rede presentes no host Windows.

As triggers são criadas como **Trigger Prototypes** e aplicadas automaticamente para cada interface descoberta através das macros:

```text id="m3k8q1"
{#IFNAME}
{#IFALIAS}
```

O monitoramento contempla:

* Estado do link;
* Redução inesperada da velocidade da interface;
* Alta utilização de banda;
* Alta taxa de erros de entrada e saída.

As triggers utilizam macros contextuais para permitir configurações específicas por interface.

---

## Discovery

As interfaces descobertas são identificadas principalmente pelas macros:

| Macro        | Descrição                    |
| ------------ | ---------------------------- |
| `{#IFNAME}`  | Nome da interface de rede    |
| `{#IFALIAS}` | Alias/descrição da interface |

Os principais itens utilizados pelas triggers são:

```text id="f8w2p5"
net.if.status["{#IFNAME}"]
net.if.speed["{#IFNAME}"]
net.if.in["{#IFNAME}"]
net.if.out["{#IFNAME}"]
net.if.in["{#IFNAME}",errors]
net.if.out["{#IFNAME}",errors]
```

---

## Triggers

## P3 — Link Down

### Interface indisponível

**Nome:**

```text id="q4n7x2"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | INTERFACE {#IFNAME}({#IFALIAS}): Link down
```

**Severidade:** `Average`

**Expressão — Problem:**

```text id="w6m2r9"
{$IFCONTROL:"{#IFNAME}"}=1
and
(
    last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.status["{#IFNAME}"])<>2
    and
    (
        last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.status["{#IFNAME}"],#1)
        <>
        last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.status["{#IFNAME}"],#2)
    )
)=1
```

**Expressão — Recovery:**

```text id="k9p3v7"
last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.status["{#IFNAME}"]) = 2
or
{$IFCONTROL:"{#IFNAME}"}=0
```

**Operational data:**

```text id="t5r8m1"
Current state: {ITEM.LASTVALUE1}
```

**Tags:**

| Tag          | Valor         |
| ------------ | ------------- |
| `Indicators` | `Operational` |
| `Name`       | `{HOST.NAME}` |

**Objetivo:**

Identificar quando uma interface de rede monitorada apresenta estado diferente de **Up**, indicando uma possível indisponibilidade do link.

O monitoramento pode ser habilitado ou desabilitado individualmente por interface através da macro:

```text id="e2c6y4"
{$IFCONTROL:"{#IFNAME}"}
```

Quando configurada como `1`, a interface é monitorada. Quando configurada como `0`, o monitoramento da interface é desabilitado.

---

## P3 — Redução de velocidade

### Interface mudou para uma velocidade inferior

**Nome:**

```text id="v7m4q2"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | INTERFACE {#IFNAME}({#IFALIAS}): Ethernet has changed to lower speed than it was before
```

**Severidade:** `Information`

**Expressão:**

```text id="n8x3p6"
change(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.speed["{#IFNAME}"]) < 0
and
last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.speed["{#IFNAME}"]) > 0
and
last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.status["{#IFNAME}"]) = 2
```

**Operational data:**

```text id="r5k9w3"
Current reported speed: {ITEM.LASTVALUE1}
```

**Dependência:**

Esta trigger possui dependência da trigger:

```text id="d3f7m8"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | INTERFACE {#IFNAME}({#IFALIAS}): Link down
```

**Objetivo:**

Identificar quando uma interface de rede apresenta uma **redução na velocidade reportada**, comparada ao valor anterior.

A condição também garante que a interface esteja atualmente com o link ativo (`status = 2`).

A dependência da trigger de **Link Down** evita que o evento de redução de velocidade seja tratado separadamente quando a interface já estiver indisponível.

---

## P3 — Alta utilização de banda

### High bandwidth usage

**Nome:**

```text id="c6p2v8"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | INTERFACE {#IFNAME}({#IFALIAS}): High bandwidth usage (> {$IF.UTIL.MAX:"{#IFNAME}"}%)
```

**Severidade:** `Warning`

**Expressão — Problem:**

```text id="s4m7k1"
(
    avg(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.in["{#IFNAME}"],15m)
    >
    ({$IF.UTIL.MAX:"{#IFNAME}"}/100)
    *
    last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.speed["{#IFNAME}"])
)
or
(
    avg(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.out["{#IFNAME}"],15m)
    >
    ({$IF.UTIL.MAX:"{#IFNAME}"}/100)
    *
    last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.speed["{#IFNAME}"])
)
and
last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.speed["{#IFNAME}"]) > 0
```

**Expressão — Recovery:**

```text id="p8n3w6"
avg(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.in["{#IFNAME}"],15m)
<
(({$IF.UTIL.MAX:"{#IFNAME}"}-3)/100)
*
last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.speed["{#IFNAME}"])
and
avg(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.out["{#IFNAME}"],15m)
<
(({$IF.UTIL.MAX:"{#IFNAME}"}-3)/100)
*
last(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.speed["{#IFNAME}"])
```

**Operational data:**

```text id="m2v7q4"
In: {ITEM.LASTVALUE1}, out: {ITEM.LASTVALUE3}, speed: {ITEM.LASTVALUE2}
```

**Dependência:**

Esta trigger possui dependência da trigger:

```text id="z9c5r1"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | INTERFACE {#IFNAME}({#IFALIAS}): Link down
```

**Objetivo:**

Identificar utilização elevada da capacidade da interface de rede, considerando o tráfego de **entrada (IN)** e **saída (OUT)**.

O alerta é acionado quando a média de utilização durante **15 minutos** ultrapassa o percentual definido na macro:

```text id="f4k8x2"
{$IF.UTIL.MAX:"{#IFNAME}"}
```

A trigger considera tanto o tráfego de entrada quanto o tráfego de saída.

### Recovery

A recuperação utiliza uma margem de **3 pontos percentuais abaixo do threshold configurado**, reduzindo oscilações e evitando que o alerta fique alternando constantemente entre problema e recuperação próximo ao limite.

---

## P3 — Alta taxa de erros

### High error rate

**Nome:**

```text id="h6q2m9"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | INTERFACE {#IFNAME}({#IFALIAS}): High error rate (> {$IF.ERRORS.WARN:"{#IFNAME}"} for 5m)
```

**Severidade:** `Warning`

**Expressão — Problem:**

```text id="y3r7p1"
min(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.in["{#IFNAME}",errors],5m)
>
{$IF.ERRORS.WARN:"{#IFNAME}"}
or
min(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.out["{#IFNAME}",errors],5m)
>
{$IF.ERRORS.WARN:"{#IFNAME}"}
```

**Expressão — Recovery:**

```text id="b8w4k6"
max(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.in["{#IFNAME}",errors],5m)
<
{$IF.ERRORS.WARN:"{#IFNAME}"} * 0.8
and
max(/Windows - Network by Zabbix agent By Valcann Non-Production/net.if.out["{#IFNAME}",errors],5m)
<
{$IF.ERRORS.WARN:"{#IFNAME}"} * 0.8
```

**Operational data:**

```text id="n5t9v2"
errors in: {ITEM.LASTVALUE1}, errors out: {ITEM.LASTVALUE2}
```

**Dependência:**

Esta trigger possui dependência da trigger:

```text id="u7m3q8"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | INTERFACE {#IFNAME}({#IFALIAS}): Link down
```

**Objetivo:**

Identificar uma taxa elevada de erros de rede na interface, tanto em **entrada (IN)** quanto em **saída (OUT)**.

O alerta é acionado quando a quantidade mínima de erros registrada durante **5 minutos** ultrapassa o limite definido pela macro:

```text id="r2k6x4"
{$IF.ERRORS.WARN:"{#IFNAME}"}
```

### Recovery

A recuperação ocorre quando a quantidade máxima de erros durante os últimos 5 minutos permanece abaixo de **80% do threshold configurado**.

Essa margem de recuperação ajuda a evitar oscilações do alerta quando a quantidade de erros está próxima do limite.

---

## Macros

O template utiliza macros contextuais para permitir configurações específicas para cada interface descoberta.

| Macro                           | Finalidade                                             |
| ------------------------------- | ------------------------------------------------------ |
| `{$IFCONTROL:"{#IFNAME}"}`      | Habilitar ou desabilitar o monitoramento da interface  |
| `{$IF.UTIL.MAX:"{#IFNAME}"}`    | Definir o percentual máximo de utilização da interface |
| `{$IF.ERRORS.WARN:"{#IFNAME}"}` | Definir o limite de erros de rede                      |

### Exemplo

```text id="x4p7n2"
{$IFCONTROL:"Ethernet"}
{$IF.UTIL.MAX:"Ethernet"}
{$IF.ERRORS.WARN:"Ethernet"}
```

O uso de macros contextuais permite aplicar thresholds diferentes para cada interface, sem necessidade de criar triggers específicas manualmente.

> **Nota:** Todas as triggers são **Trigger Prototypes** originadas pelo Network Discovery. Portanto, as condições são aplicadas automaticamente para cada interface encontrada pelo mecanismo de descoberta.

> **Nota:** O comportamento das triggers pode variar por interface de acordo com as macros contextuais configuradas para `{#IFNAME}`.

## Windows — Zabbix Agent

**Template:** `Windows - Zabbix agent By Valcann Non-Production`

## Visão geral

O template **Windows - Zabbix agent By Valcann Non-Production** contém triggers relacionadas à disponibilidade e comunicação do **Zabbix Agent**, permitindo identificar quando o agente deixa de responder ao servidor Zabbix dentro do período definido pela macro `{$AGENT.TIMEOUT}`.

## Triggers

## P2 — Status Check do Zabbix Agent

**Nome:**

```text
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | STATUS-CHECK (FOR {$AGENT.TIMEOUT})
```

**Severidade:** Average (P2)

**Operational data:**

```text
Current status: {ITEM.LASTVALUE1}
```

**Expressão:**

```text
max(/Windows - Zabbix agent By Valcann Non-Production/zabbix[host,agent,available],{$AGENT.TIMEOUT})=0
```

**Status:** Enabled

**Tags:**

```text
Host: {HOST.NAME}
Indicators: Operational
```

### Objetivo

Identificar quando o **Zabbix Agent** de um host Windows permanece indisponível durante todo o período definido pela macro `{$AGENT.TIMEOUT}`.

## Windows — Monitoring

**Template:** `Windows - Monitoring By Valcann Non-Production`

## Visão geral

O template **Windows - Monitoring By Valcann Non-Production** possui triggers destinadas a validar a **disponibilidade do monitoramento do host**, verificando se o agente está respondendo às requisições do Zabbix.

## Triggers

## P2 — Disponibilidade

**Nome:**

```text
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | DISPONIBILIDADE
```

**Severidade:** Average (P2)

**Expressão:**

```text
max(/Windows - Monitoring By Valcann Non-Production/agent.ping,5m)=0
```

**Status:** Enabled

### Objetivo

Identificar quando o host Windows deixa de responder ao monitoramento durante um período contínuo de **5 minutos**.

A trigger utiliza o item:

```text
agent.ping
```

que verifica a capacidade de comunicação com o agente monitorado.

A função `max()` avalia os valores coletados durante os últimos **5 minutos**. Quando o maior valor registrado nesse período é `0`, significa que não houve nenhuma resposta do agente durante todo o intervalo, fazendo com que a trigger entre em estado de problema.

### Funcionamento

| Condição                           | Resultado            |
| ---------------------------------- | -------------------- |
| `agent.ping` responde normalmente  | Trigger permanece OK |
| Agente deixa de responder          | Inicia a avaliação   |
| Nenhuma resposta durante 5 minutos | **P2 — Average**        |
| Agente volta a responder           | Trigger é recuperada |

### Lógica da expressão

```text
max(/Windows - Monitoring By Valcann Non-Production/agent.ping,5m)=0
```

A expressão pode ser interpretada da seguinte maneira:

* `agent.ping` → verifica a resposta do agente.
* `5m` → considera os últimos 5 minutos.
* `max()` → obtém o maior valor registrado no período.
* `=0` → indica que não houve nenhuma resposta durante o intervalo avaliado.

## Resumo das Triggers

| Severidade    | Trigger           | Expressão              | Objetivo                                                           |
| ------------- | ----------------- | ---------------------- | ------------------------------------------------------------------ |
| **P2 — Average** | `DISPONIBILIDADE` | `max(agent.ping,5m)=0` | Identificar indisponibilidade do monitoramento/agent por 5 minutos |

## Observações

* A trigger possui severidade **P2 — Average**, indicando uma indisponibilidade de atenção para o monitoramento do host.
* O período de avaliação é fixo em **5 minutos**.
* A trigger não depende de macros de threshold para determinar sua condição.
* A utilização de `max()` evita que uma única resposta isolada seja suficiente para caracterizar indisponibilidade: o problema ocorre somente quando **nenhum valor diferente de `0` foi registrado durante os 5 minutos**.
* O retorno do `agent.ping` à condição normal provoca a recuperação da trigger.


## Ordem de Importação

**Não existe uma ordem específica para a importação dos templates individuais.**

Entretanto, existe uma exceção importante:

> O template **`Windows - Monitoring By Valcann Non-Production.yaml` deve ser importado por último.**

Isso ocorre porque o template `Windows - Monitoring By Valcann Non-Production.yaml` possui diversos outros templates associados/dependentes.

### Ordem recomendada

Importe primeiro os templates:

```text
1. `Windows - Antivirus By Valcann Non-Production.yaml`
2. `Windows - CPU Zabbix agent By Valcann Non-Production.yaml`
3. `Windows - Filesystems Zabbix agent By Valcann Non-Production.yaml`
4. `Windows - Generic Zabbix agent By Valcann Non-Production.yaml`
5. `Windows - Memory Zabbix agent By Valcann Non-Production.yaml`
6. `Windows - Metadata By Valcann Non-Production.yaml`
7. `Windows - Network by Zabbix agent By Valcann Non-Production.yaml`
8. `Windows - Number of logged in users By Valcann Non-Production.yaml`
9. `Windows - Zabbix agent By Valcann Non-Production.yaml`
```

E **por último**:

```text
10. Windows - Monitoring By Valcann Non-Production.yaml
```

Caso o template principal seja importado antes dos templates dos quais ele depende, o Zabbix poderá apresentar **erro durante a importação devido às associações/dependências existentes**.

## Versão do Zabbix

Todos os templates deste repositório foram **customizados utilizando o Zabbix Server 7.4**.

```text
Zabbix Server: 7.4
```

Portanto, recomenda-se utilizar o **Zabbix 7.4** para garantir compatibilidade com a estrutura e os recursos utilizados nos templates.

> **Atenção:** templates desenvolvidos para versões diferentes do Zabbix podem exigir ajustes na estrutura do YAML antes da importação.

## Estrutura

A estrutura esperada do repositório é:

```text
Valcann Template Zabbix/
│
├── Zabbix Template Windows Valcann Non-Production/
│   ├── Windows - Antivirus By Valcann Non-Production.yaml
│   ├── Windows - CPU Zabbix agent By Valcann Non-Production.yaml
│   ├── Windows - Filesystems Zabbix agent By Valcann Non-Production.yaml
│   ├── Windows - Generic Zabbix agent By Valcann Non-Production.yaml
│   ├── Windows - Memory Zabbix agent By Valcann Non-Production.yaml
│   ├── Windows - Metadata By Valcann Non-Production.yaml
│   ├── Windows - Monitoring By Valcann Non-Production.yaml
│   ├── Windows - Network by Zabbix agent By Valcann Non-Production.yaml
│   ├── Windows - Number of logged in users By Valcann Non-Production.yaml
│   └── Windows - Zabbix agent By Valcann Non-Production.yaml
│
└── README.md
```

## Resumo

* **9 templates** de suporte/complementares;
* **1 template principal:** `Windows - Monitoring By Valcann Non-Production.yaml`;
* Os templates possuem associações entre si;
* A macro global **`{$CLIENT}`** deve ser ajustada para cada cliente;
* As triggers seguem uma **padronização de nomenclatura**;
* O template **`Windows - Monitoring By Valcann Non-Production.yaml` deve ser importado por último**;
* Os templates foram customizados para **Zabbix Server 7.4**.
