## Zabbix Template Windows Valcann PRD

O Repositório **`Zabbix Template Windows Valcann PRD - Github`** contém **9 templates**, que são associados ao template principal **`Windows Zabbix agent By Valcann.yaml`**.

### Templates disponíveis

1. `Number of logged in users Windows By Valcann.yaml`
2. `Windows Antivirus By Valcann.yaml`
3. `Windows CPU Zabbix agent By Valcann.yaml`
4. `Windows filesystems Zabbix agent By Valcann.yaml`
5. `Windows generic Zabbix agent By Valcann.yaml`
6. `Windows memory Zabbix agent By Valcann.yaml`
7. `Windows Metadata By Valcann.yaml`
8. `Windows network by Zabbix agent By Valcann.yaml`
9. `Zabbix agent By Valcann.yaml`

Esses templates possuem associação com o template principal:

`Windows Zabbix agent By Valcann.yaml`

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

## Padronização das Triggers

As triggers foram padronizadas seguindo uma nomenclatura que facilita a identificação do:

* Nível de prioridade;
* Cliente;
* Ambiente;
* Host;
* Recurso monitorado;
* Condição do alerta.

Exemplo:

```text
[P1] {$CLIENT} | EC2 | {HOST.NAME} | PRD | {#FSNAME} DISK SPACE IS CRITICALLY LOW (used > 99%)
```

Onde:

| Campo         | Descrição                             |
| ------------- | ------------------------------------- |
| `[P1]`        | Prioridade do alerta                  |
| `{$CLIENT}`   | Macro global que identifica o cliente |
| `EC2`         | Tipo/origem do recurso monitorado     |
| `{HOST.NAME}` | Nome do host                          |
| `PRD`         | Ambiente de produção                  |
| `{#FSNAME}`   | Nome do filesystem                    |
| `used > 99%`  | Condição que dispara o alerta         |

Essa padronização deve ser mantida durante futuras customizações dos templates.

## Ordem de Importação

**Não existe uma ordem específica para a importação dos templates individuais.**

Entretanto, existe uma exceção importante:

> O template **`Windows Zabbix agent By Valcann.yaml` deve ser importado por último.**

Isso ocorre porque o template `Windows Zabbix agent By Valcann.yaml` possui diversos outros templates associados/dependentes.

### Ordem recomendada

Importe primeiro os templates:

```text
1. Number of logged in users Windows By Valcann.yaml
2. Windows Antivirus By Valcann.yaml
3. Windows CPU Zabbix agent By Valcann.yaml
4. Windows filesystems Zabbix agent By Valcann.yaml
5. Windows generic Zabbix agent By Valcann.yaml
6. Windows memory Zabbix agent By Valcann.yaml
7. Windows Metadata By Valcann.yaml
8. Windows network by Zabbix agent By Valcann.yaml
9. Zabbix agent By Valcann.yaml
```

E **por último**:

```text
10. Windows Zabbix agent By Valcann.yaml
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
├── Zabbix Template Windows Valcann PRD - Github/
│   ├── Number of logged in users Windows By Valcann.yaml
│   ├── Windows Antivirus By Valcann.yaml
│   ├── Windows CPU Zabbix agent By Valcann.yaml
│   ├── Windows filesystems Zabbix agent By Valcann.yaml
│   ├── Windows generic Zabbix agent By Valcann.yaml
│   ├── Windows memory Zabbix agent By Valcann.yaml
│   ├── Windows Metadata By Valcann.yaml
│   ├── Windows network by Zabbix agent By Valcann.yaml
│   ├── Zabbix agent By Valcann.yaml
│   └── Windows Zabbix agent By Valcann.yaml
│
└── README.md
```

## Resumo

* **9 templates** de suporte/complementares;
* **1 template principal:** `Windows Zabbix agent By Valcann.yaml`;
* Os templates possuem associações entre si;
* A macro global **`{$CLIENT}`** deve ser ajustada para cada cliente;
* As triggers seguem uma **padronização de nomenclatura**;
* O template **`Windows Zabbix agent By Valcann.yaml` deve ser importado por último**;
* Os templates foram customizados para **Zabbix Server 7.4**.
