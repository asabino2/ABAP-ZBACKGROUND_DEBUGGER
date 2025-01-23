# ZCL_BGD_DEBUGGER

A classe `ZCL_BGD_DEBUGGER` é uma ferramenta para facilitar a depuração em segundo plano (background debugging) no SAP. Ela permite criar pontos de controle em processos executados em background e enviar notificações configuráveis aos responsáveis.
Use o ABAPGIT para instalar esse produto
---

## Definição da Classe

```abap
CLASS ZCL_BGD_DEBUGGER DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

PUBLIC SECTION.

  CLASS-METHODS DEBUG
    IMPORTING
      !DESCRIPTION TYPE CLIKE OPTIONAL
      !NOTIFIER TYPE SY-UNAME DEFAULT SY-UNAME
      !TIMEOUT TYPE I DEFAULT 300.
PROTECTED SECTION.
PRIVATE SECTION.
ENDCLASS.
```

---

## Métodos Públicos

### DEBUG

O método `DEBUG` é o principal método da classe e realiza as seguintes tarefas:

- Obtém o call stack atual e identifica o ponto de execução.
- Verifica e registra informações em tabelas customizadas (`ZTBC_BGDEBUG_SP` e `ZTBC_BGDEBUG_SPT`).
- Envia notificações utilizando o sistema de correio interno do SAP (`SO_EXPRESS_FLAG_SET`).
- Implementa lógica de timeout para limitar a duração da execução.

#### Parâmetros de Entrada

| Parâmetro     | Tipo       | Padrão     | Descrição                                                                                     |
|---------------|------------|------------|---------------------------------------------------------------------------------------------|
| `DESCRIPTION` | `CLIKE`    | Opcional   | Texto descritivo associado ao ponto de depuração.                                            |
| `NOTIFIER`    | `SY-UNAME` | `SY-UNAME` | Usuário que receberá a notificação.                                                         |
| `TIMEOUT`     | `I`        | `300`      | Tempo máximo, em segundos, para execução da lógica de depuração.                            |

---

## Lógica Interna

### Fluxo de Execução

1. Obtém informações do call stack com a função `SYSTEM_CALLSTACK`.
2. Determina a linha atual de execução.
3. Registra informações nas tabelas customizadas:
   - `ZTBC_BGDEBUG_SP`: programa principal, include e linha de execução.
   - `ZTBC_BGDEBUG_SPT`: descrição, se fornecida.
4. Envia notificações:
   - Utiliza `SO_EXPRESS_FLAG_SET` para criar uma mensagem expressa.
5. Realiza verificações contínuas até que:
   - O timeout seja atingido, ou
   - Uma condição de saída seja satisfeita.

---

## Dependências Externas

- **Funções de sistema SAP:**
  - `SYSTEM_CALLSTACK`
  - `TH_GET_OWN_WP_NO`
  - `SO_EXPRESS_FLAG_SET`
  - `CCU_TIMESTAMP_DIFFERENCE`
- **Tabelas customizadas:**
  - `ZTBC_BGDEBUG_SP`
  - `ZTBC_BGDEBUG_SPT`

---

## Como Usar

1. Utilize o método estático `DEBUG` da classe `ZCL_BGD_DEBUGGER`.
2. Configure os parâmetros desejados:
   - `DESCRIPTION`: Adicione um texto descritivo.
   - `NOTIFIER`: Defina o destinatário da notificação.
   - `TIMEOUT`: Especifique o tempo máximo de execução.
3. Execute o programa em modo background para capturar o ponto de depuração.

### Exemplo de Uso

```abap
zcl_bgd_debugger=>debug(
  description = 'Ponto de depuração crítico'
  notifier = 'USUARIO_RESPONSAVEL'
  timeout = 600 ).
```

---

## Considerações

- **Manutenção das Tabelas:** Certifique-se de que as tabelas customizadas `ZTBC_BGDEBUG_SP` e `ZTBC_BGDEBUG_SPT` estão configuradas corretamente com os campos necessários.

---

