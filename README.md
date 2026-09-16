# projeto-mysql-isp
Modelagem de dados relacional e automação de carga com Stored Procedures no MySQL.

Este repositório contém a arquitetura de banco de dados e rotinas de automação em MySQL desenvolvidas para simular a operação de atendimento e infraestrutura de um Provedor de Internet.

## Objetivos do Projeto
- Estruturar um modelo de dados relacional em estrela (*Star Schema*).
- Automatizar a geração de dados sintéticos coerentes para simulação de cenários reais.
- Permitir análises operacionais de SLA, TMA e impacto de incidentes de rede.

## Tecnologias e Conceitos Aplicados
- **Banco de Dados:** MySQL / MySQL Workbench
- **Modelagem:** Tabela Fato (`fato_chamado`, `fato_incidente_rede`) e Tabelas Dimensão (`dim_cliente`, `dim_atendente`, `dim_localidade`).
- **Automação:** *Stored Procedures*, *Cursors*, *Handlers* de erro e tratamento de variáveis.
- **Regras de Negócio:** Simulação de horários comerciais, sorteio proporcional por níveis de atendimento e cálculo de janelas de SLA.

## 📂 Estrutura do Repositório

- `criacao_tabelas.sql`: DDL do schema (chaves primárias, estrangeiras e restrições).
- `/inserts/`: DML com a carga inicial das tabelas Dimensão (clientes, atendentes, localidades, etc).
- `/procedures/`: Stored Procedures em MySQL para geração da massa de dados simulada das tabelas Fato.
- `/views/`: Consultas consolidadas para alimentar o painel analítico.

## 🚧 Status do Projeto
Em andamento — Próxima etapa: Consolidação de Views SQL analíticas e criação de Dashboard executivo.
