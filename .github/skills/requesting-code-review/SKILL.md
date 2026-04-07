---
name: requesting-code-review
description: "Use ao completar tarefas, implementar features maiores, ou antes de merge para verificar que o trabalho atende requisitos"
---

# Solicitando Code Review

Despache subagente revisor para pegar problemas antes que se acumulem. O revisor recebe contexto precisamente preparado — nunca o histórico da sua sessão.

**Princípio central:** Review cedo, review frequente.

## Quando Solicitar Review

**Obrigatório:**
- Após cada tarefa em subagent-driven development
- Após completar feature maior
- Antes de merge para main

**Opcional mas valioso:**
- Quando travado (perspectiva fresca)
- Antes de refatorar (check de baseline)
- Após corrigir bug complexo

## Como Solicitar

1. **Pegue git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)
HEAD_SHA=$(git rev-parse HEAD)
```

2. **Despache subagente revisor** com:
- O que foi implementado
- Plano ou requisitos
- SHAs base e head
- Descrição breve

3. **Aja sobre feedback:**
- Corrija issues Critical imediatamente
- Corrija issues Important antes de prosseguir
- Anote issues Minor para depois
- Conteste se revisor estiver errado (com raciocínio)

## Red Flags

**Nunca:**
- Pule review porque "é simples"
- Ignore issues Critical
- Prossiga com issues Important não corrigidos
- Argumente com feedback técnico válido

**Se revisor estiver errado:**
- Conteste com raciocínio técnico
- Mostre código/testes que provem que funciona
