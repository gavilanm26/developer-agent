---
description: Operaciones con Azure DevOps utilizando Azure CLI y jq
---

# Azure DevOps Operations

Este flujo de trabajo define cómo interactuar con Azure DevOps de forma eficiente mediante la CLI de Azure.

## Requisitos
- Tener instalada la `azure-devops` extension en la CLI de Azure.
- Las credenciales se cargan desde `.agent/rules/.env` (no incluido en git).

## Operaciones Comunes

### Listar Historias de Usuario por Sprint
// turbo
```bash
az boards query --wiql "SELECT [System.Id], [System.Title], [System.State], [System.AssignedTo], [Microsoft.VSTS.Scheduling.StoryPoints] FROM WorkItems WHERE [System.TeamProject] = 'Tarjeta Crédito Digital' AND [System.WorkItemType] = 'User Story' AND [System.IterationPath] UNDER 'Tarjeta Crédito Digital\sprint 1'" -o json | jq -r '.[] | [.id, .fields["System.Title"], .fields["System.State"], (.fields["System.AssignedTo"].displayName // ""), (.fields["Microsoft.VSTS.Scheduling.StoryPoints"] // "")] | @tsv'
```

### Buscar Path de Iteración
// turbo
```bash
az boards iteration project list --project "Tarjeta Crédito Digital" -o json | jq -r '.. | objects | select(.name=="sprint 1") | .path'
```

## Buenas Prácticas
1. **Cachear Iteraciones**: Obtener los paths una vez y reutilizarlos.
2. **Tablas Markdown**: Presentar siempre los resultados en tablas para facilitar la lectura.
3. **Organización**: El slug de la organización es `EquipoInnovacionDigital`.
