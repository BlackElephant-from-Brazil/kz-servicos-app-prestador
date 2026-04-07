---
name: verification-before-completion
description: "Use quando estiver prestes a afirmar que trabalho está completo, corrigido ou passando - requer rodar comandos de verificação e confirmar output antes de fazer qualquer afirmação de sucesso; evidência antes de afirmações sempre"
---

# Verificação Antes de Completar

## Visão Geral

Afirmar que trabalho está completo sem verificação é desonestidade, não eficiência.

**Princípio central:** Evidência antes de afirmações, sempre.

## A Lei de Ferro

```
NENHUMA AFIRMAÇÃO DE CONCLUSÃO SEM EVIDÊNCIA DE VERIFICAÇÃO FRESCA
```

Se não rodou o comando de verificação nesta mensagem, não pode afirmar que passa.

## A Função Gate

```
ANTES de afirmar qualquer status ou expressar satisfação:

1. IDENTIFIQUE: Qual comando prova esta afirmação?
2. RODE: Execute o comando COMPLETO (fresco, completo)
3. LEIA: Output completo, verifique exit code, conte falhas
4. VERIFIQUE: Output confirma a afirmação?
   - Se NÃO: Declare status real com evidência
   - Se SIM: Declare afirmação COM evidência
5. SÓ ENTÃO: Faça a afirmação

Pular qualquer passo = mentir, não verificar
```

## Falhas Comuns

| Afirmação | Requer | Não é Suficiente |
|-----------|--------|------------------|
| Testes passam | Output do comando: 0 falhas | Execução anterior, "deve passar" |
| Build sucede | Comando build: exit 0 | Linter passando |
| Bug corrigido | Teste sintoma original: passa | Código mudou, assumiu corrigido |
| Requisitos atendidos | Checklist linha-por-linha | Testes passando |

## Red Flags - PARE

- Usando "deve", "provavelmente", "parece que"
- Expressando satisfação antes da verificação ("Ótimo!", "Perfeito!", "Pronto!")
- Prestes a commitar/push/PR sem verificação
- Confiando em relatórios de sucesso de agente
- Pensando "só dessa vez"

## Padrões-Chave

**Testes:**
```
✅ [Rodar flutter test] [Ver: 34/34 pass] "Todos os testes passam"
❌ "Deve passar agora" / "Parece correto"
```

**Build:**
```
✅ [Rodar flutter build] [Ver: exit 0] "Build passa"
❌ "Lint passou" (lint não verifica compilação)
```

## A Linha Final

**Sem atalhos para verificação.**

Rode o comando. Leia o output. ENTÃO afirme o resultado.

Isso não é negociável.
