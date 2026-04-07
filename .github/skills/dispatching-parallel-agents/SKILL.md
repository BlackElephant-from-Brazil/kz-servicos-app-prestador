---
name: dispatching-parallel-agents
description: "Use quando enfrentar 2+ tarefas independentes que podem ser trabalhadas sem estado compartilhado ou dependências sequenciais"
---

# Despachando Agentes Paralelos

## Visão Geral

Delegue tarefas a agentes especializados com contexto isolado. Construa precisamente suas instruções e contexto para que fiquem focados e tenham sucesso. Eles nunca devem herdar o contexto da sua sessão — você constrói exatamente o que precisam.

**Princípio central:** Despache um agente por domínio de problema independente. Deixe trabalhar concorrentemente.

## Quando Usar

- 3+ arquivos de teste falhando com causas raiz diferentes
- Múltiplos subsistemas quebrados independentemente
- Cada problema pode ser entendido sem contexto dos outros
- Sem estado compartilhado entre investigações

## O Padrão

### 1. Identifique Domínios Independentes
Agrupe falhas pelo que está quebrado. Cada domínio é independente.

### 2. Crie Tarefas Focadas para Agentes
Cada agente recebe:
- **Escopo específico:** Um arquivo de teste ou subsistema
- **Objetivo claro:** O que corrigir/implementar
- **Restrições:** O que NÃO mudar
- **Output esperado:** Resumo do que encontrou e corrigiu

### 3. Despache em Paralelo
Todos rodam concorrentemente.

### 4. Revise e Integre
- Leia cada resumo
- Verifique que correções não conflitam
- Rode suite de testes completa
- Integre todas as mudanças

## Erros Comuns

**❌ Muito amplo:** "Corrija todos os testes" - agente se perde
**✅ Específico:** "Corrija test_login.dart" - escopo focado

**❌ Sem contexto:** "Corrija o race condition" - agente não sabe onde
**✅ Com contexto:** Cole as mensagens de erro e nomes dos testes

**❌ Sem restrições:** Agente pode refatorar tudo
**✅ Com restrições:** "NÃO mude código de produção" ou "Corrija apenas testes"
