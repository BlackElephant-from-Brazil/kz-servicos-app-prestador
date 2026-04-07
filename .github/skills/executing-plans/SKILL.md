---
name: executing-plans
description: "Use quando tiver um plano de implementação escrito para executar com checkpoints de revisão"
---

# Executando Planos

## Visão Geral

Carregue o plano, revise criticamente, execute todas as tarefas, reporte quando completo.

**Anuncie no início:** "Estou usando a skill executing-plans para implementar este plano."

## O Processo

### Passo 1: Carregar e Revisar Plano

1. Leia o arquivo do plano
2. Revise criticamente - identifique questões ou preocupações
3. Se houver preocupações: Levante com o usuário antes de começar
4. Se sem preocupações: Crie TodoList e prossiga

### Passo 2: Executar Tarefas

Para cada tarefa:
1. Marque como em progresso
2. Siga cada passo exatamente (plano tem passos pequenos)
3. Rode verificações conforme especificado
4. Marque como completo

### Passo 3: Completar Desenvolvimento

Após todas as tarefas completas e verificadas:
- Anuncie: "Estou usando a skill finishing-a-development-branch para completar este trabalho."
- Siga a skill para verificar testes, apresentar opções, executar escolha

## Quando Parar e Pedir Ajuda

**PARE de executar imediatamente quando:**
- Encontrar bloqueio (dependência faltando, teste falha, instrução confusa)
- Plano tem gaps críticos
- Não entende uma instrução
- Verificação falha repetidamente

**Peça esclarecimento ao invés de adivinhar.**

## Lembre-se

- Revise plano criticamente primeiro
- Siga passos do plano exatamente
- Não pule verificações
- Referencie skills quando o plano indicar
- Pare quando bloqueado, não adivinhe
- Nunca comece implementação na branch main/master sem consentimento explícito
