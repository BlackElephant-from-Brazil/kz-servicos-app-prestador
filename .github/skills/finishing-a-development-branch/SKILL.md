---
name: finishing-a-development-branch
description: "Use quando implementação está completa, todos os testes passam, e você precisa decidir como integrar o trabalho - guia a conclusão apresentando opções estruturadas de merge, PR ou cleanup"
---

# Finalizando uma Branch de Desenvolvimento

## Visão Geral

Guie a conclusão do trabalho apresentando opções claras e executando o fluxo escolhido.

**Princípio central:** Verificar testes → Apresentar opções → Executar escolha → Limpar.

**Anuncie no início:** "Estou usando a skill finishing-a-development-branch para completar este trabalho."

## O Processo

### Passo 1: Verificar Testes

```bash
flutter test
```

**Se testes falham:** Pare. Corrija antes de prosseguir.
**Se testes passam:** Continue ao Passo 2.

### Passo 2: Determinar Branch Base

```bash
git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null
```

### Passo 3: Apresentar Opções

```
Implementação completa. O que você gostaria de fazer?

1. Merge para <branch-base> localmente
2. Push e criar Pull Request
3. Manter a branch como está (vou lidar depois)
4. Descartar este trabalho

Qual opção?
```

### Passo 4: Executar Escolha

#### Opção 1: Merge Local
```bash
git checkout <branch-base>
git pull
git merge <feature-branch>
flutter test
git branch -d <feature-branch>
```

#### Opção 2: Push e Criar PR
```bash
git push -u origin <feature-branch>
gh pr create --title "<título>" --body "<resumo>"
```

#### Opção 3: Manter Como Está
Reporte: "Mantendo branch <nome>."

#### Opção 4: Descartar
**Confirme primeiro** — peça confirmação digitando "descartar".

## Red Flags

**Nunca:**
- Prossiga com testes falhando
- Merge sem verificar testes no resultado
- Delete trabalho sem confirmação
- Force-push sem pedido explícito
