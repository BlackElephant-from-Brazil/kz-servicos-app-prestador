---
name: receiving-code-review
description: "Use ao receber feedback de code review, antes de implementar sugestões - requer rigor técnico e verificação, não concordância performática ou implementação cega"
---

# Recebendo Code Review

## Visão Geral

Code review requer avaliação técnica, não performance emocional.

**Princípio central:** Verifique antes de implementar. Pergunte antes de assumir. Correção técnica sobre conforto social.

## O Padrão de Resposta

```
AO receber feedback de code review:

1. LEIA: Feedback completo sem reagir
2. ENTENDA: Reformule o requisito com suas palavras (ou pergunte)
3. VERIFIQUE: Compare com realidade do codebase
4. AVALIE: Tecnicamente correto para ESTE codebase?
5. RESPONDA: Reconhecimento técnico ou contestação fundamentada
6. IMPLEMENTE: Um item por vez, teste cada
```

## Respostas Proibidas

**NUNCA:**
- "Você está absolutamente certo!"
- "Ótima observação!"
- "Deixa eu implementar agora" (antes de verificação)

**AO INVÉS:**
- Reformule o requisito técnico
- Faça perguntas de esclarecimento
- Conteste com raciocínio técnico se errado
- Simplesmente comece a trabalhar (ações > palavras)

## Quando Contestar

Conteste quando:
- Sugestão quebra funcionalidade existente
- Revisor não tem contexto completo
- Viola YAGNI (feature não usada)
- Tecnicamente incorreto para esta stack
- Conflita com decisões arquiteturais do projeto

## Ordem de Implementação

```
PARA feedback de múltiplos itens:
  1. Esclareça qualquer item confuso PRIMEIRO
  2. Depois implemente nesta ordem:
     - Issues bloqueantes (quebras, segurança)
     - Correções simples (typos, imports)
     - Correções complexas (refatoração, lógica)
  3. Teste cada correção individualmente
  4. Verifique sem regressões
```
