---
name: subagent-driven-development
description: "Use quando executar planos de implementação com tarefas independentes na sessão atual"
---

# Subagent-Driven Development

Execute o plano despachando subagente fresco por tarefa, com revisão em duas etapas após cada: revisão de conformidade com spec primeiro, depois qualidade de código.

**Princípio central:** Subagente fresco por tarefa + revisão em duas etapas (spec depois qualidade) = alta qualidade, iteração rápida

## Quando Usar

- Tem plano de implementação
- Tarefas são majoritariamente independentes
- Quer manter na mesma sessão

## O Processo

Para cada tarefa:
1. **Despache subagente implementador** com texto completo da tarefa + contexto
2. **Se subagente fizer perguntas** — responda antes de prosseguir
3. **Subagente implementa, testa, commita, auto-revisa**
4. **Despache revisor de spec** — confirma que código atende à spec
5. **Se revisor encontrar problemas** — implementador corrige → re-review
6. **Despache revisor de qualidade** — review de código
7. **Se revisor encontrar problemas** — implementador corrige → re-review
8. **Marque tarefa como completa**

## Seleção de Modelo

Use o modelo menos potente que pode lidar com cada papel:

- **Tarefas mecânicas** (funções isoladas, specs claras): modelo rápido
- **Integração e julgamento** (multi-arquivo, pattern matching): modelo padrão
- **Arquitetura, design e revisão**: modelo mais capaz

## Handling de Status do Implementador

- **DONE:** Prossiga para review de spec
- **DONE_WITH_CONCERNS:** Leia preocupações antes de prosseguir
- **NEEDS_CONTEXT:** Forneça contexto faltante e re-despache
- **BLOCKED:** Avalie o bloqueio e ajuste abordagem

## Red Flags

**Nunca:**
- Comece implementação na branch main/master sem consentimento
- Pule reviews (spec OU qualidade)
- Prossiga com issues não corrigidos
- Despache múltiplos subagentes de implementação em paralelo
- Ignore perguntas de subagente
- **Inicie code quality review antes de spec compliance estar ✅**

**Se subagente perguntar:** Responda clara e completamente
**Se revisor encontrar issues:** Implementador corrige → Revisor revisa novamente → Repita até aprovado
