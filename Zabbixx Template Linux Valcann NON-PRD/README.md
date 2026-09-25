# Valcann Zabbix Templates

Este repositório contém os templates Zabbix customizados pela **Valcann**, utilizados para monitoramento de servidores Linux.

## Zabbix Template Linux Valcann Non-Production

O **`Zabbix Template Linux Valcann Non-Production`** contém **9 templates**, que são associados ao template principal **`Linux - Monitoring By Valcann Non-Production.yaml`**.

### Templates disponíveis

1. `Linux - Antivirus By Valcann Non-Production.yaml`
2. `Linux - Block devices Zabbix agent By Valcann Non-Production.yaml`
3. `Linux - CPU Zabbix agent By Valcann Non-Production.yaml`
4. `Linux - Filesystems Zabbix agent By Valcann Non-Production.yaml`
5. `Linux - Generic Zabbix agent By Valcann Non-Production.yaml`
6. `Linux - Memory Zabbix agent By Valcann Non-Production.yaml`
7. `Linux - Metadata by Valcann Non-Production.yaml`
8. `Linux - Network interfaces Zabbix agent By Valcann Non-Production.yaml`
9. `Linux - Zabbix agent By Valcann Non-Production.yaml`

Esses templates possuem associação com o template principal:

`Linux - Monitoring By Valcann Non-Production.yaml`

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

## Macro do Template Principal **`Linux - Monitoring By Valcann Non-Production`** `{$AMBIENTE}`

Os templates utilizam a macro do template Principal:

```text
{$AMBIENTE}
```

Essa macro é utilizada para identificar o ambiente nos nomes das triggers.

Exemplo:

```text
{$AMBIENTE} = NON-PRD
```
Exemplo na pratica utilizando a macro global {$CLIENT} = ABCDIS e a macro do template para ambiente {$AMBIENTE} = NON-PRD

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
[P#] {$CLIENT} | <ORIGEM> | {HOST.NAME} | <AMBIENTE> | <DESCRIÇÃO>
```

Exemplo:

```text
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | DISK {#FSNAME} USED 99%)
```

Onde:

* `[P#]` → criticidade do alerta;
* `{$CLIENT}` → identificação do cliente;
* `<ORIGEM>` → origem ou tipo do recurso;
* `{HOST.NAME}` → nome do host;
* `<AMBIENTE>` → ambiente monitorado, por exemplo `NON-PRD` ou `PRD`;
* `<DESCRIÇÃO>` → condição responsável pelo alerta.

> **Importante:** os valores de percentual e tempo utilizados para determinar P1, P2 e P3 devem seguir a configuração definida para cada recurso/template e não devem ser alterados sem validação prévia.

## **Template:** `Linux - Block devices Zabbix agent By Valcann Non-Production`

**Tipo:** Trigger Prototype — Low-Level Discovery (LLD)

**Severidade:** `P3`

**Objetivo:**
Identificar dispositivos de bloco (`{#DEVNAME}`) que estejam apresentando tempo elevado de resposta nas operações de leitura ou escrita em disco.

A trigger é criada dinamicamente pelo **Discovery**, sendo aplicada individualmente para cada dispositivo de bloco encontrado no host.

#### Expressão

```text
min(/Linux - Block devices Zabbix agent By Valcann Non-Production/vfs.dev.read.await[{#DEVNAME}],15m) > {$VFS.DEV.READ.AWAIT.WARN:"{#DEVNAME}"}
or
min(/Linux - Block devices Zabbix agent By Valcann Non-Production/vfs.dev.write.await[{#DEVNAME}],15m) > {$VFS.DEV.WRITE.AWAIT.WARN:"{#DEVNAME}"}
```

#### Como funciona

A trigger monitora duas métricas para cada dispositivo descoberto:

* `vfs.dev.read.await[{#DEVNAME}]` — tempo médio de espera das requisições de **leitura**.
* `vfs.dev.write.await[{#DEVNAME}]` — tempo médio de espera das requisições de **escrita**.

O operador `min(...,15m)` verifica o **menor valor registrado nos últimos 15 minutos**.

A trigger será acionada quando **uma das duas condições** for verdadeira:

1. O tempo de resposta de leitura permanecer acima do limite definido em:

   ```text
   {$VFS.DEV.READ.AWAIT.WARN:"{#DEVNAME}"}
   ```

2. O tempo de resposta de escrita permanecer acima do limite definido em:

   ```text
   {$VFS.DEV.WRITE.AWAIT.WARN:"{#DEVNAME}"}
   ```

O uso do `or` significa que **não é necessário que leitura e escrita ultrapassem os limites simultaneamente**. A ocorrência de qualquer uma das condições é suficiente para gerar o alerta.

#### Macros

| Macro                                      | Descrição                                                                                                             |
| ------------------------------------------ | --------------------------------------------------------------------------------------------------------------------- |
| `{$VFS.DEV.READ.AWAIT.WARN:"{#DEVNAME}"}`  | Limite máximo de tempo de resposta para operações de leitura, em ms.                                                  |
| `{$VFS.DEV.WRITE.AWAIT.WARN:"{#DEVNAME}"}` | Limite máximo de tempo de resposta para operações de escrita, em ms.                                                  |
| `{#DEVNAME}`                               | Macro de Low-Level Discovery que representa o dispositivo de bloco descoberto, por exemplo `sda`, `sdb` ou `nvme0n1`. |

#### Comportamento do Discovery

Como se trata de um **Trigger Prototype**, o Zabbix utiliza o `{#DEVNAME}` retornado pelo Discovery para gerar automaticamente uma trigger específica para cada dispositivo.

Por exemplo:

```text
sda  → Disk read/write request responses are too high
sdb  → Disk read/write request responses are too high
sdc  → Disk read/write request responses are too high
```

Dessa forma, um problema identificado em `/dev/sdb`, por exemplo, será apresentado especificamente para esse dispositivo, facilitando a identificação do recurso que apresenta degradação.

#### Severidade

| Severidade | Critério                                                                                                   |
| ---------- | ---------------------------------------------------------------------------------------------------------- |
| **P3**     | Tempo mínimo de resposta de leitura ou escrita acima do limite configurado durante a janela de 15 minutos. |

> **Observação:** Os valores dos limites não devem ser definidos diretamente na expressão. Eles devem ser configurados por meio das macros `{$VFS.DEV.READ.AWAIT.WARN:"{#DEVNAME}"}` e `{$VFS.DEV.WRITE.AWAIT.WARN:"{#DEVNAME}"}`, permitindo ajustar os thresholds de acordo com o ambiente e o dispositivo monitorado.

## Linux - CPU Zabbix agent By Valcann Non-Production

Template utilizado para monitoramento da **utilização de CPU** dos servidores Linux.

### Triggers

As triggers de CPU utilizam a média mínima de utilização (`min`) durante **15 minutos**, reduzindo a possibilidade de alertas provocados por picos momentâneos de utilização.

`Lembrando que a Trigger P1 de CPU não faz parte do padrão da Valcann. Por padrão, ela permanece desabilitada, sendo habilitada somente em casos excepcionais, conforme a necessidade do cliente, como no caso do ABCDIS.`

A classificação dos alertas é baseada nas macros:

| Macro                 | Valor | Severidade   |
| --------------------- | ----: | ------------ |
| `{$CPU.UTIL.CRIT.P3}` |   90% | P3 - Warning |
| `{$CPU.UTIL.CRIT.P2}` |   95% | P2 - Average |
| `{$CPU.UTIL.CRIT.P1}` |   99% | P1 - High    |

### P3 - Warning

**CPU acima de 90% e abaixo de 95% durante 15 minutos.**

```text
min(/Linux - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m)>={$CPU.UTIL.CRIT.P3}
and
min(/Linux - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m)<{$CPU.UTIL.CRIT.P2}
```

**Nome da trigger:**

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION (over {$CPU.UTIL.CRIT.P3}% for 15m)
```

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Objetivo:** identificar utilização elevada de CPU de forma persistente, mas ainda abaixo do nível crítico P2.

---

### P2 - Average

**CPU acima de 95% e abaixo de 99% durante 15 minutos.**

```text
min(/Linux - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m)>={$CPU.UTIL.CRIT.P2}
and
min(/Linux - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m)<{$CPU.UTIL.CRIT.P1}
```

**Nome da trigger:**

```text
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION (over {$CPU.UTIL.CRIT.P2}% for 15m)
```

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Objetivo:** indicar uma condição de alta utilização de CPU que pode representar degradação de desempenho ou falta de capacidade.

---

### P1 - High

**CPU igual ou superior a 99% durante 15 minutos.**

```text
min(/Linux - CPU Zabbix agent By Valcann Non-Production/system.cpu.util,15m)>={$CPU.UTIL.CRIT.P1}
```

**Nome da trigger:**

```text
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | CPU UTILIZATION (over {$CPU.UTIL.CRIT.P1}% for 15m)
```

**Operational data:**

```text
Current utilization: {ITEM.LASTVALUE1}
```

**Objetivo:** identificar utilização crítica e persistente da CPU, indicando possível saturação do recurso.

---

## Linux - Filesystems Zabbix agent By Valcann Non-Production

Template utilizado para monitoramento da **utilização dos sistemas de arquivos (filesystems)** dos servidores Linux.

O template utiliza **Low-level Discovery (LLD)** para identificar automaticamente os filesystems disponíveis no host através da macro `{#FSNAME}`.

As triggers avaliam o percentual de espaço utilizado (`pused`) e também podem considerar a quantidade de espaço livre e a tendência de crescimento da utilização.

---

### Triggers

O template possui triggers para os níveis **P3, P2 e P1**, além de regras específicas por filesystem utilizando macros do tipo `{$VFS.FS.PUSED.MAX.*:"{#FSNAME}"}`.

### Macros globais

| Macro                 | Valor | Severidade   |
| --------------------- | ----: | ------------ |
| `{$FS.PUSED.CRIT.P3}` |   90% | P3 - Warning |
| `{$FS.PUSED.CRIT.P2}` |   95% | P2 - Average |
| `{$FS.PUSED.CRIT.P1}` |   99% | P1 - High    |

Essas macros definem os limites padrão de utilização dos filesystems.

---

### P3 - Warning

**Filesystem com utilização igual ou superior a 90% e inferior a 95%.**

```text
last(/Linux - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused])>={$FS.PUSED.CRIT.P3}
and
last(/Linux - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused])<{$FS.PUSED.CRIT.P2}
```

**Nome da trigger:**

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | DISK {#FSNAME} USED 90%)
```

**Operational data:**

```text
Space used: {ITEM.LASTVALUE3} of {ITEM.LASTVALUE2} ({ITEM.LASTVALUE1})
```

**Objetivo:** identificar filesystems com utilização elevada, permitindo atuação preventiva antes que o espaço disponível se torne crítico.

---

### P2 - Average

**Filesystem com utilização igual ou superior a 95% e inferior a 99%.**

```text
last(/Linux - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused])>={$FS.PUSED.CRIT.P2}
and
last(/Linux - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused])<{$FS.PUSED.CRIT.P1}
```

**Nome da trigger:**

```text
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | DISK {#FSNAME} USED 95%)
```

**Operational data:**

```text
Space used: {ITEM.LASTVALUE3} of {ITEM.LASTVALUE2} ({ITEM.LASTVALUE1})
```

**Objetivo:** indicar que o filesystem está próximo da saturação e requer intervenção.

---

### P1 - High

**Filesystem com utilização igual ou superior a 99%.**

```text
last(/Linux - Filesystems Zabbix agent By Valcann Non-Production/vfs.fs.size[{#FSNAME},pused])>={$FS.PUSED.CRIT.P1}
```

**Nome da trigger:**

```text
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | DISK {#FSNAME} USED 99%)
```

**Operational data:**

```text
Space used: {ITEM.LASTVALUE3} of {ITEM.LASTVALUE2} ({ITEM.LASTVALUE1})
```

**Objetivo:** identificar um filesystem praticamente saturado, com alto risco de indisponibilidade de aplicações, falha de gravação de arquivos ou degradação do serviço.

## Resumo das triggers

| Severidade                  | Condição principal                         | Macro                                  |
| --------------------------- | ------------------------------------------ | -------------------------------------- |
| **P3 - Warning**            | Utilização >= 90% e < 95%                  | `{$FS.PUSED.CRIT.P3}`                  |
| **P2 - Average**            | Utilização >= 95% e < 99%                  | `{$FS.PUSED.CRIT.P2}`                  |
| **P1 - High**               | Utilização >= 99%                          | `{$FS.PUSED.CRIT.P1}`                  |

## Linux - Generic Zabbix agent By Valcann Non-Production

Template utilizado para monitoramento de **informações gerais e integridade do sistema operacional Linux**.

O template monitora alterações em informações básicas do sistema, reinicializações do servidor e alterações no arquivo `/etc/passwd`.

As triggers possuem severidade **P3**, sendo utilizadas principalmente para gerar indicadores operacionais e identificar alterações que podem exigir investigação.

---

## Triggers

### P3 - System name has changed

Detecta alteração no **hostname/nome do sistema operacional**.

**Expressão:**

```text
last(/Linux - Generic Zabbix agent By Valcann Non-Production/system.hostname,#1)
<>
last(/Linux - Generic Zabbix agent By Valcann Non-Production/system.hostname,#2)
= 1
and
length(last(/Linux - Generic Zabbix agent By Valcann Non-Production/system.hostname)) > 0
```

**Nome da trigger:**

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | System name has changed (new name: {ITEM.VALUE})
```

**Item monitorado:**

```text
system.hostname
```

### Lógica

A expressão compara os **dois últimos valores** registrados pelo item:

```text
last(...,#1) <> last(...,#2)
```

Se os valores forem diferentes, significa que o hostname foi alterado.

A segunda condição:

```text
length(last(...)) > 0
```

garante que o novo valor não esteja vazio.

### Exemplo

Antes:

```text
web-server-01
```

Depois:

```text
web-server-02
```

A diferença entre os dois últimos valores fará a trigger entrar em estado **PROBLEM**.

O nome da trigger utiliza:

```text
{ITEM.VALUE}
```

para apresentar o novo hostname identificado.

---

## P3 - Operating system description has changed

Detecta alteração na **descrição do sistema operacional**.

**Expressão:**

```text
last(/Linux - Generic Zabbix agent By Valcann Non-Production/system.sw.os,#1)
<>
last(/Linux - Generic Zabbix agent By Valcann Non-Production/system.sw.os,#2)
= 1
and
length(last(/Linux - Generic Zabbix agent By Valcann Non-Production/system.sw.os)) > 0
```

**Nome da trigger:**

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | Operating system description has changed
```

**Item monitorado:**

```text
system.sw.os
```

### Lógica

A trigger compara os dois últimos valores registrados:

```text
last(...,#1) <> last(...,#2)
```

Se houver diferença entre eles, a trigger identifica que a descrição do sistema operacional foi alterada.

A condição:

```text
length(last(...)) > 0
```

evita considerar como alteração válida um valor vazio.

### Exemplos de alterações

Uma alteração pode ocorrer, por exemplo, após:

* atualização do sistema operacional;
* alteração de distribuição ou versão;
* alteração das informações reportadas pelo sistema;
* mudanças decorrentes de upgrade ou configuração.

### Dependência

Essa trigger possui dependência da trigger:

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | System name has changed (new name: {ITEM.VALUE})
```

A dependência evita a geração de eventos adicionais quando a alteração estiver relacionada a uma mudança mais ampla de identidade do sistema.

---

## P3 - Server has been restarted

Detecta quando o servidor Linux foi **reinicializado recentemente**.

**Expressão:**

```text
last(/Linux - Generic Zabbix agent By Valcann Non-Production/system.uptime)<10m
```

**Nome da trigger:**

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | has been restarted (uptime < 10m)
```

**Item monitorado:**

```text
system.uptime
```

### Lógica

A expressão verifica o tempo de atividade atual do servidor:

```text
last(.../system.uptime)<10m
```

Quando o uptime é inferior a **10 minutos**, o Zabbix considera que o servidor foi reiniciado recentemente.

### Exemplo

Após um reboot:

```text
Uptime = 2 minutos
```

Resultado:

```text
2m < 10m
```

Trigger:

```text
PROBLEM
```

Após o servidor permanecer ligado por mais de 10 minutos, a condição deixa de ser verdadeira e o evento é recuperado.

### Objetivo

Essa trigger permite identificar e registrar:

* reboot planejado;
* reboot não planejado;
* reinicialização após atualização;
* reinicialização após aplicação de patch;
* reinicialização causada por falha ou intervenção operacional.

A trigger está associada ao indicador:

```text
Indicators: Operational
```

---

## P3 - /etc/passwd has been changed

Monitora alterações no arquivo:

```text
/etc/passwd
```

utilizando seu **checksum**.

**Expressão:**

```text
last(/Linux - Generic Zabbix agent By Valcann Non-Production/vfs.file.cksum[/etc/passwd],#1)
<>
last(/Linux - Generic Zabbix agent By Valcann Non-Production/vfs.file.cksum[/etc/passwd],#2)
> 0
```

**Nome da trigger:**

```text
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | /etc/passwd has been changed
```

**Item monitorado:**

```text
vfs.file.cksum[/etc/passwd]
```

### Lógica

O Zabbix calcula um checksum do arquivo `/etc/passwd`.

A expressão compara o checksum atual com o anterior:

```text
last(...,#1) <> last(...,#2)
```

Se os valores forem diferentes, significa que o conteúdo do arquivo foi alterado.

### Possíveis alterações detectadas

A trigger pode ser acionada quando ocorrerem operações como:

* criação de usuário;
* remoção de usuário;
* alteração de informações de usuário;
* alteração de UID/GID;
* alteração de shell;
* alterações administrativas no arquivo.

## Resumo das triggers

| Severidade | Trigger                                  | Item monitorado               | Objetivo                                     |
| ---------- | ---------------------------------------- | ----------------------------- | -------------------------------------------- |
| **P3**     | System name has changed                  | `system.hostname`             | Detectar alteração do hostname               |
| **P3**     | Operating system description has changed | `system.sw.os`                | Detectar alteração na descrição do SO        |
| **P3**     | Server has been restarted                | `system.uptime`               | Detectar reboot recente                      |
| **P3**     | `/etc/passwd` has been changed           | `vfs.file.cksum[/etc/passwd]` | Detectar alteração na base local de usuários |

---

## Linux - Memory Zabbix agent By Valcann Non-Production

Template utilizado para monitoramento da **utilização de memória RAM** dos servidores Linux.

As triggers avaliam a utilização de memória durante **15 minutos**, utilizando o menor valor (`min`) registrado nesse período. Essa abordagem garante que o nível de utilização configurado permaneça sustentado durante todo o intervalo de avaliação, reduzindo alertas causados por picos momentâneos.

---

## Triggers

O template possui três níveis de severidade:

* **P3 - Warning:** utilização de memória >= 90% e < 95%
* **P2 - Average:** utilização de memória >= 95% e < 99%
* **P1 - High:** utilização de memória >= 99%

  `Lembrando que a Trigger P1 de MEMÓRIA não faz parte do padrão da Valcann. Por padrão, ela permanece desabilitada, sendo habilitada somente em casos excepcionais, conforme a necessidade do cliente, como no caso do ABCDIS.`

Os limites são definidos através das macros:

```text id="7c8f4c"
{$MEMORY.UTIL.CRIT.P3} = 90%
{$MEMORY.UTIL.CRIT.P2} = 95%
{$MEMORY.UTIL.CRIT.P1} = 99%
```

---

### P3 - Warning

**Memória utilizada igual ou superior a 90% e inferior a 95% durante 15 minutos.**

**Expressão:**

```text id="0m1g5j"
min(/Linux - Memory Zabbix agent By Valcann Non-Production/vm.memory.utilization,15m)>={$MEMORY.UTIL.CRIT.P3}
and
min(/Linux - Memory Zabbix agent By Valcann Non-Production/vm.memory.utilization,15m)<{$MEMORY.UTIL.CRIT.P2}
```

**Nome da trigger:**

```text id="q7zj85"
[P3] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | MEMORY UTILIZATION (>90% for 15m)
```

O valor exibido no nome é determinado pela macro utilizada na trigger:

```text id="0qf1o5"
{$MEMORY.UTIL.CRIT.P3}
```

### Objetivo

Identificar uma utilização elevada de memória que permanece sustentada durante 15 minutos, permitindo uma atuação preventiva antes que o servidor atinja níveis mais críticos.

---

### P2 - Average

**Memória utilizada igual ou superior a 95% e inferior a 99% durante 15 minutos.**

**Expressão:**

```text id="z8y9cp"
min(/Linux - Memory Zabbix agent By Valcann Non-Production/vm.memory.utilization,15m)>={$MEMORY.UTIL.CRIT.P2}
and
min(/Linux - Memory Zabbix agent By Valcann Non-Production/vm.memory.utilization,15m)<{$MEMORY.UTIL.CRIT.P1}
```

**Nome da trigger:**

```text id="tq30k4"
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | MEMORY UTILIZATION (>95% for 15m)
```

O valor do limite é determinado pela macro:

```text id="um3c5j"
{$MEMORY.UTIL.CRIT.P2}
```

### Objetivo

Identificar uma condição de alta utilização de memória que pode indicar pressão sobre a RAM disponível e risco de degradação do desempenho das aplicações.

---

### P1 - High

**Memória utilizada igual ou superior a 99% durante 15 minutos.**

**Expressão:**

```text id="s0omw4"
min(/Linux - Memory Zabbix agent By Valcann Non-Production/vm.memory.utilization,15m)>={$MEMORY.UTIL.CRIT.P1}
```

**Nome da trigger:**

```text id="h1z7xm"
[P1] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | MEMORY UTILIZATION (>99% for 15m)
```

O limite é determinado pela macro:

```text id="4i5yqa"
{$MEMORY.UTIL.CRIT.P1}
```

**Objetivo:** identificar uma condição crítica de utilização de memória, indicando possível esgotamento da RAM disponível e risco de impacto nas aplicações e no sistema operacional.

## Objetivo operacional

O conjunto de triggers tem como objetivo identificar **pressão crescente de memória** antes que o servidor atinja uma condição de esgotamento do recurso.

A classificação segue uma escala progressiva:

```text id="5gj4ty"
P3 → Utilização elevada
P2 → Utilização muito elevada
P1 → Utilização crítica
```

Essa abordagem permite priorizar os eventos de acordo com a severidade e direcionar a atuação operacional conforme o nível de utilização identificado.

## Linux - Zabbix agent By Valcann Non-Production

Template utilizado para monitoramento do **status e disponibilidade do Zabbix Agent** nos servidores Linux.

O template possui uma trigger destinada a identificar quando o Zabbix Server/Proxy não consegue obter informações do agente dentro do período definido pela macro `{$AGENT.TIMEOUT}`.

---

## Trigger

### P2 - Average — Status Check

Detecta quando o **Zabbix Agent está indisponível** durante o período configurado em `{$AGENT.TIMEOUT}`.

**Expressão:**

```text id="x2p7kq"
max(/Linux - Zabbix agent By Valcann Non-Production/zabbix[host,agent,available],{$AGENT.TIMEOUT})=0
```

**Nome da trigger:**

```text id="6m1v3n"
[P2] {$CLIENT} | EC2 | {HOST.NAME} | {$AMBIENTE} | STATUS-CHECK (FOR {$AGENT.TIMEOUT})
```

**Operational data:**

```text id="4j8c2w"
Host: {HOST.NAME}
```

**Indicador:**

```text id="7q5x1a"
Indicators: Operational
```

---

## Item monitorado

A trigger utiliza o item:

```text id="9n4k6p"
zabbix[host,agent,available]
```

Esse item informa a **disponibilidade do Zabbix Agent** para comunicação com o Zabbix Server ou Proxy.

Os valores retornados representam o estado de disponibilidade do agente:

```text id="3w7h9m"
1 = Agent disponível

0 = Agent indisponível
```

---

## Lógica da expressão

A expressão utilizada é:

```text id="c6t2yr"
max(/Linux - Zabbix agent By Valcann Non-Production/zabbix[host,agent,available],{$AGENT.TIMEOUT})=0
```

A função `max()` verifica o **maior valor registrado durante o período definido por `{$AGENT.TIMEOUT}`**.

Para que a trigger seja acionada:

```text id="m8r4dz"
max(...) = 0
```

Isso significa que **não houve nenhum valor `1` (Agent disponível) durante todo o período avaliado**.

Portanto, a condição representa uma indisponibilidade persistente do agente, e não apenas uma falha momentânea de comunicação.

---

## Exemplo

Considerando:

```text id="a5p8kc"
{$AGENT.TIMEOUT} = 3m
```

e os valores coletados durante o período:

```text id="6h2s1d"
0
0
0
```

O maior valor será:

```text id="q9v3xe"
max(3m) = 0
```

Consequentemente:

```text id="r5n8wb"
Trigger = PROBLEM
```

Se houver pelo menos uma coleta indicando que o agente está disponível:

```text id="z7c4mp"
0
0
1
0
```

o resultado será:

```text id="e2k6qa"
max(3m) = 1
```

Nesse cenário, a condição da trigger será falsa.

---

## Macro utilizada

| Macro              | Finalidade                                                                |
| ------------------ | ------------------------------------------------------------------------- |
| `{$AGENT.TIMEOUT}` | Define o período utilizado para validar a disponibilidade do Zabbix Agent |

O valor dessa macro determina quanto tempo o agente precisa permanecer indisponível antes que o evento seja considerado crítico.

### Exemplo

```text id="d5x9kn"
{$AGENT.TIMEOUT} = 3m
```

Significa que a trigger avaliará a disponibilidade do agente durante os últimos **3 minutos**.

---

## Severidade

| Severidade    | Condição                                      | Objetivo                                            |
| ------------- | --------------------------------------------- | --------------------------------------------------- |
| **P2 - Average** | Agent indisponível durante `{$AGENT.TIMEOUT}` | Identificar perda de comunicação com o Zabbix Agent |

A severidade **P2 - Average** é utilizada porque a indisponibilidade do agente interrompe a coleta das métricas do host, comprometendo a capacidade de monitoramento.

---

## Possíveis causas

A trigger pode ser acionada por diferentes situações, incluindo:

* Zabbix Agent parado;
* processo do agente encerrado;
* servidor indisponível;
* falha de rede entre Zabbix Server/Proxy e o host;
* firewall bloqueando a comunicação;
* porta do Zabbix Agent indisponível;
* problemas de DNS ou conectividade;
* timeout de comunicação;
* problemas no próprio Zabbix Agent.

Por isso, o disparo da trigger indica **perda de disponibilidade do agente**, mas não necessariamente que o processo `zabbix-agent` esteja parado.

---
O objetivo principal dessa trigger é garantir que o **canal de monitoramento do host esteja disponível**. Quando o agente deixa de responder pelo período definido em `{$AGENT.TIMEOUT}`, o evento é classificado como **P1 - High**, pois a coleta das demais métricas do servidor fica comprometida.

## Ordem de Importação

**Não existe uma ordem específica para a importação dos templates individuais.**

Entretanto, existe uma exceção importante:

> O template **`Linux - Monitoring By Valcann Non-Production.yaml` deve ser importado por último.**

Isso ocorre porque o template `Linux - Monitoring By Valcann Non-Production.yaml` possui diversos outros templates associados/dependentes.

### Ordem recomendada

Importe primeiro os templates:

```text
1. Linux - Antivirus By Valcann Non-Production.yaml
2. Linux - Block devices Zabbix agent By Valcann Non-Production.yaml
3. Linux - CPU Zabbix agent By Valcann Non-Production.yaml
4. Linux - Filesystems Zabbix agent By Valcann Non-Production.yaml
5. Linux - Generic Zabbix agent By Valcann Non-Production.yaml
6. Linux - Memory Zabbix agent By Valcann Non-Production.yaml
7. Linux - Metadata by Valcann Non-Production.yaml
8. Linux - Network interfaces Zabbix agent By Valcann Non-Production.yaml
9. Linux - Zabbix agent By Valcann Non-Production.yaml
```

E **por último**:

```text
10. Linux - Monitoring By Valcann Non-Production.yaml
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
├── Zabbix Template Linux Valcann Non-Production/
│   ├── Linux - Antivirus By Valcann Non-Production.yaml
│   ├── Linux - Block devices Zabbix agent By Valcann Non-Production.yaml
│   ├── Linux - CPU Zabbix agent By Valcann Non-Production.yaml
│   ├── Linux - Filesystems Zabbix agent By Valcann Non-Production.yaml
│   ├── Linux - Generic Zabbix agent By Valcann Non-Production.yaml
│   ├── Linux - Memory Zabbix agent By Valcann Non-Production.yaml
│   ├── Linux - Metadata by Valcann Non-Production.yaml
│   ├── Linux - Monitoring By Valcann Non-Production.yaml
│   ├── Linux - Network interfaces Zabbix agent By Valcann Non-Production.yaml
│   └── Linux - Zabbix agent By Valcann Non-Production.yaml
│
└── README.md
```

## Resumo

* **9 templates** de suporte/complementares;
* **1 template principal:** `Linux - Monitoring By Valcann Non-Production.yaml`;
* Os templates possuem associações entre si;
* A macro global **`{$CLIENT}`** deve ser ajustada para cada cliente;
* As triggers seguem uma **padronização de nomenclatura**;
* O template **`Linux - Monitoring By Valcann Non-Production.yaml` deve ser importado por último**;
* Os templates foram customizados para **Zabbix Server 7.4**.
