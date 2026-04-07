---
name: using-superpowers
description: "Use ao iniciar qualquer conversa - estabelece como encontrar e usar skills, requerendo invocação de skill ANTES de qualquer resposta incluindo perguntas de esclarecimento"
---

<SUBAGENT-STOP>
Se você foi despachado como subagente para executar uma tarefa específica, pule esta skill.
</SUBAGENT-STOP>

# Usando Skills

## A Regra

**Invoque skills relevantes ou solicitadas ANTES de qualquer resposta ou ação.** Mesmo 1% de chance de uma skill se aplicar significa que você deve invocá-la para verificar. Se uma skill invocada não for adequada, você não precisa usá-la.

## Prioridade de Instruções

1. **Instruções explícitas do usuário** — prioridade máxima
2. **Skills do projeto** — sobrescrevem comportamento padrão
3. **System prompt padrão** — prioridade mínima

## Red Flags

| Pensamento | Realidade |
|------------|-----------|
| "É só uma pergunta simples" | Perguntas são tarefas. Verifique skills. |
| "Preciso de mais contexto primeiro" | Verificar skills vem ANTES de perguntas. |
| "Deixa eu explorar o codebase primeiro" | Skills dizem COMO explorar. |
| "Não precisa de uma skill formal" | Se uma skill existe, use-a. |
| "A skill é exagero" | Coisas simples ficam complexas. Use-a. |
| "Vou só fazer essa coisinha primeiro" | Verifique ANTES de fazer qualquer coisa. |

## Prioridade de Skills

1. **Skills de processo primeiro** (brainstorming, debugging) - determinam COMO abordar
2. **Skills de implementação depois** - guiam a execução

"Vamos construir X" → brainstorming primeiro, depois skills de implementação.
"Corrija esse bug" → debugging primeiro, depois skills específicas.

## Tipos de Skills

**Rígidas** (TDD, debugging): Siga exatamente. Não adapte para longe da disciplina.
**Flexíveis** (padrões): Adapte princípios ao contexto.

A skill diz qual tipo é.

## Instruções do Usuário

Instruções dizem O QUÊ, não COMO. "Adicione X" ou "Corrija Y" não significa pular workflows.
