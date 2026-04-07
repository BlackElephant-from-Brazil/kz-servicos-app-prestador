---
name: systematic-debugging
description: "Use quando encontrar qualquer bug, falha de teste ou comportamento inesperado, antes de propor correções"
---

# Debugging Sistemático

## Visão Geral

Correções aleatórias desperdiçam tempo e criam novos bugs. Patches rápidos mascaram problemas.

**Princípio central:** SEMPRE encontre a causa raiz antes de tentar correções. Correções de sintomas são falha.

## A Lei de Ferro

```
NENHUMA CORREÇÃO SEM INVESTIGAÇÃO DE CAUSA RAIZ PRIMEIRO
```

Se não completou a Fase 1, não pode propor correções.

## As Quatro Fases

### Fase 1: Investigação da Causa Raiz

**ANTES de tentar QUALQUER correção:**

1. **Leia Mensagens de Erro Cuidadosamente**
   - Não pule erros ou warnings
   - Stack traces contêm a solução
   - Note números de linha, caminhos, códigos de erro

2. **Reproduza Consistentemente**
   - Consegue disparar de forma confiável?
   - Quais os passos exatos?

3. **Verifique Mudanças Recentes**
   - O que mudou que poderia causar isso?
   - Git diff, commits recentes, novas dependências

4. **Rastreie Fluxo de Dados**
   - De onde vem o valor ruim?
   - O que chamou isso com valor ruim?
   - Continue rastreando até encontrar a fonte
   - Corrija na fonte, não no sintoma

### Fase 2: Análise de Padrão

1. **Encontre Exemplos Funcionais** — código similar que funciona
2. **Compare com Referências** — leia implementação de referência COMPLETAMENTE
3. **Identifique Diferenças** — liste TODAS, por menores que sejam
4. **Entenda Dependências** — componentes, config, ambiente

### Fase 3: Hipótese e Teste

1. **Forme Hipótese Única** — "Acho que X é a causa raiz porque Y"
2. **Teste Minimamente** — menor mudança possível, uma variável por vez
3. **Verifique Antes de Continuar** — Funcionou? Sim → Fase 4. Não → Nova hipótese
4. **Quando Não Souber** — Diga "Não entendo X". Não finja saber.

### Fase 4: Implementação

1. **Crie Teste Falhando** — Use a skill test-driven-development
2. **Implemente Correção Única** — UMA mudança por vez
3. **Verifique Correção** — Teste passa? Outros testes ok?
4. **Se Correção Não Funcionar** — PARE. Se < 3 tentativas: volte à Fase 1. Se ≥ 3: questione a arquitetura
5. **Se 3+ Correções Falharam** — Discuta com o usuário antes de mais tentativas

## Red Flags - PARE e Siga o Processo

- "Correção rápida por agora, investigo depois"
- "Vou tentar mudar X e ver se funciona"
- "Provavelmente é X, deixa eu corrigir"
- "Não entendo totalmente mas isso pode funcionar"
- Propondo soluções antes de rastrear fluxo de dados
- **"Mais uma tentativa" (quando já tentou 2+)**

**TODOS significam: PARE. Volte à Fase 1.**

## Referência Rápida

| Fase | Atividades | Critério de Sucesso |
|------|-----------|---------------------|
| **1. Causa Raiz** | Leia erros, reproduza, verifique mudanças | Entenda O QUÊ e POR QUÊ |
| **2. Padrão** | Encontre exemplos, compare | Identifique diferenças |
| **3. Hipótese** | Forme teoria, teste minimamente | Confirmada ou nova hipótese |
| **4. Implementação** | Crie teste, corrija, verifique | Bug resolvido, testes passam |
