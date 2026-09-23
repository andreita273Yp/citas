# Orquestación cross-repo — Sistema ficticio de Citas FCV

## Alcance del workspace

Este directorio orquesta exactamente dos repositorios Git independientes:

- `citas-api`: backend Java 21, Spring Boot 3.5.x, Maven, arquitectura hexagonal, MySQL/Flyway.
- `citas-web`: frontend TypeScript React o Angular, que consume `citas-api` directamente por REST.

La raíz no es un repositorio Git y no debe inicializarse como tal.

## Lectura obligatoria

Antes de cambios funcionales, leer en este orden:

1. `README.md`
2. `PRD.md`
3. `RESTRICCIONES_TECNICAS.md`
4. `database/REQUISITOS_NORMALIZACION_3FN.md`
5. `citas-api/README.md`
6. `citas-web/README.md`
7. Los `AGENTS.md` existentes de cada repositorio
8. `citas-api/docs/wiki/llm-wiki/wiki/index.md`, cuando exista

## Enrutamiento de responsabilidades

- Dominio, aplicación, persistencia, seguridad, REST, Flyway y n8n viven en `citas-api`.
- Componentes, rutas, estado de UI, accesibilidad y pruebas frontend viven en `citas-web`.
- No implementar Express, BFF ni lógica de negocio en frontend.
- El frontend consume Spring Boot directamente mediante REST.
- No inventar requisitos fuera del PRD, HU aprobadas o decisiones registradas.

## Cambios cross-repo y contratos REST

Antes de modificar un contrato REST:

1. Declarar el plan y los archivos de ambos repositorios afectados.
2. Registrar o actualizar el contrato en la LLM Wiki.
3. Implementar backend y frontend de forma coordinada.
4. Aportar evidencia en ambos repositorios: prueba REST/backend y build, typecheck o prueba frontend aplicable.
5. No considerar terminado un contrato si solo un repositorio está actualizado.

## Git y seguridad

- `main` representa estado estable; `develop` es la rama de trabajo.
- No reescribir historial para ocultar progreso.
- Preservar cambios ajenos existentes en el worktree.
- Nunca abrir, imprimir, copiar ni versionar secretos de `.env`.
- Usar datos sintéticos; no introducir datos privados o clínicos reales de FCV.
- Los workflows n8n se guardan solo como JSON en `citas-api/automations/n8n/`, sin credenciales embebidas.

## LLM Wiki global

La única wiki global vive en `citas-api/docs/wiki/llm-wiki/`.

- `raw/`: fuentes curadas e inmutables; se leen, no se reescriben durante INGEST.
- `wiki/`: conocimiento mantenido, trazable y resumido.
- `schema/`: convenciones y workflows.
- Leer siempre `wiki/index.md` antes de consultar o actualizar páginas.
- Mantener `wiki/log.md` append-only.
- Persistir únicamente conocimiento durable clasificado como HECHO, DECISIÓN, PREFERENCIA o PREGUNTA ABIERTA.
- No convertir la wiki en transcript ni almacenar secretos, tokens o PII.

## Límites de Skills

- `scrum-spec-orchestrator` solo escribe en `citas-api/docs/wiki/scrum/`; no implementa código.
- `stitch-design-to-frontend` gobierna diseño, aprobación y reconciliación visual; no define backend ni contratos REST por sí sola.
