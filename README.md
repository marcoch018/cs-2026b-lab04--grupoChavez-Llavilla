# BiblioUNSA — Laboratorio 04: Fundamentos de arquitectura de software
Construcción de Software · EPIS-UNSA · 2026-B · Grupo Chavez-Llavilla

## Integrantes
| Nombre | Rol en el laboratorio |
|--------|-----------------------|
| Marco David Chávez Chambi | Redactor de ADR y verificador de IA |
| Frayd Yande Llavilla Machaca | Diagramador (Mermaid, PlantUML y Python Diagrams) y redactor de drivers y matriz de decisión |

## Caso
BiblioUNSA es una plataforma para el préstamo y reserva de libros de las bibliotecas de la UNSA. Los actores son el estudiante, el bibliotecario y el sistema académico. El MVP ofrece catálogo en línea, reserva de libros, préstamo con carné QR, control de multas y validación de matrícula vigente. El acceso es con el correo institucional y el sistema académico se consulta solo por API, sin acceso directo a su base de datos. El **atributo de calidad crítico es la seguridad** (junto con la interoperabilidad); el MVP debe salir en 1 mes con 2 developers y un VPS.

## Arquitectura elegida
Monolito modular con 6 módulos, un esquema de PostgreSQL por módulo e integraciones externas aisladas en adaptadores (ver [matriz de decisión](docs/architecture/matriz-decision.md): 4,15 frente a 3,60 de capas y 2,85 de microservicios).

```mermaid
flowchart TB
    ES["Estudiante"]
    BI["Bibliotecario"]
    subgraph APP["BiblioUNSA — Monolito modular (un solo despliegue)"]
        API["Capa de presentación: API REST + web responsive"]
        M1["Autenticación<br/>y autorización"]
        M2["Catálogo e<br/>inventario"]
        M3["Reservas"]
        M4["Préstamos<br/>(carné QR)"]
        M5["Multas"]
        M6["Notificaciones"]
        INF["Capa de infraestructura: repositorios y adaptadores externos"]
    end
    DB[("PostgreSQL<br/>(un esquema por módulo)")]
    IDP["Proveedor de identidad<br/>del correo institucional (OIDC)"]
    ACA["API del Sistema Académico"]
    SMTP["Servicio de correo (SMTP)"]
    ES & BI --> API
    API --> M1 & M2 & M3 & M4 & M5 & M6
    M3 -->|"consulta disponibilidad"| M2
    M4 -->|"genera multas"| M5
    M3 & M4 & M5 -->|"avisos"| M6
    M1 & M2 & M3 & M4 & M5 & M6 --> INF
    INF --> DB
    INF --> IDP
    INF --> ACA
    INF --> SMTP
    classDef mod fill:#E8F5E9,stroke:#2E7D32,color:#000
    classDef ext fill:#F2F2F2,stroke:#7F7F7F,color:#000,stroke-dasharray: 4 3
    classDef usr fill:#FDEDEC,stroke:#C8310E,color:#000
    class M1,M2,M3,M4,M5,M6 mod
    class IDP,ACA,SMTP ext
    class ES,BI usr
```

## Entregables
- [Drivers y escenarios de calidad (E1)](docs/architecture/drivers.md)
- [Matriz de decisión (E2)](docs/architecture/matriz-decision.md)
- Diagramas (E3, E5, E6): [`arquitectura.mmd`](docs/architecture/diagramas/arquitectura.mmd), [`alternativa.puml`](docs/architecture/diagramas/alternativa.puml), [`despliegue.py`](docs/architecture/diagramas/despliegue.py) e imágenes en [`img/`](docs/architecture/diagramas/img/)
- [Bitácora de uso de IA (E7)](docs/architecture/bitacora-ia.md)
- [Cuestionario resuelto](docs/cuestionario.md)

## Decisiones arquitectónicas
- [ADR-001: Estilo arquitectónico (monolito modular)](docs/architecture/adr/001-estilo-arquitectonico.md)
- [ADR-002: Autenticación con el correo institucional](docs/architecture/adr/002-autenticacion-correo-institucional.md)
- [ADR-003: Integración con el sistema académico](docs/architecture/adr/003-integracion-sistema-academico.md)

## Reflexión sobre el uso de la IA
La IA nos ayudó a generar y comparar alternativas rápidamente, a redactar borradores de ADR y a escribir el código de los diagramas, y su crítica de "abogado del diablo" nos hizo agregar mitigaciones concretas como el adaptador con reintentos y las pruebas de límites entre módulos. También cometió errores: asumió que el correo institucional ofrece inicio de sesión estándar (OIDC) sin que el caso lo diga, y fue necesario corregir la nota de la alternativa descartada para que citara los puntajes reales. Aprendimos a verificar cada afirmación contra los drivers (R-01 a R-06), a recalcular los totales con un script y a marcar como supuesto todo dato que la IA no pueda respaldar. Las decisiones finales las tomó el equipo y todo uso de la IA quedó registrado en la bitácora.

## Diseño UML (Lab 05)

Diseño detallado del módulo Préstamos de BiblioUNSA, con diagramas UML escritos como código (PlantUML y Mermaid).

### Máquina de estados del Préstamo

mermaid
stateDiagram-v2
    [*] --> RESERVADO : crearReserva()
    RESERVADO --> PRESTADO : entregar() [recogido en 48 h]
    RESERVADO --> CANCELADO : cancelar() [no recogido en 48 h]
    PRESTADO --> DEVUELTO : registrarDevolucion() [sin retraso]
    PRESTADO --> VENCIDO : marcarVencido() [fechaLimite superada]
    VENCIDO --> CON_MULTA : registrarDevolucion() [diasRetraso > 0]
    CON_MULTA --> DEVUELTO : pagarMulta() [multa pagada]
    DEVUELTO --> [*]
    CANCELADO --> [*]


### Documentos y diagramas

- [Historia de usuario](docs/design/historia.md)
- [Diagrama de clases](docs/design/clases.puml)
- [Diagrama de secuencia](docs/design/secuencia-reservar-libro.puml)
- [Diagrama de estados](docs/design/estados-prestamo.mmd)
- [Diagrama de actividades](docs/design/actividades-devolucion.puml)
- [Diagrama de paquetes](docs/design/paquetes.puml)
- [Código del dominio](src/prestamos/)
- [Round-trip (pyreverse)](docs/design/round-trip.md)
- [Consistencia C1–C5](docs/design/consistencia.md)
- [Bitácora de IA](docs/design/bitacora-ia.md)

## Arquitectura C4 (Lab 06)

Modelo único en [`workspace.dsl`](docs/architecture/c4/workspace.dsl); todas las vistas se exportan de ahí con Structurizr CLI.

**Nivel 1 — Contexto (exportado a Mermaid):**

```mermaid
graph LR
  linkStyle default fill:#ffffff

  subgraph diagram ["System Context View: BiblioUNSA"]
    style diagram fill:#ffffff,stroke:#ffffff

    1["<div style='font-weight: bold'>Estudiante</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>Busca libros, los reserva y<br />consulta sus préstamos y<br />multas.</div>"]
    style 1 fill:#08427b,stroke:#052e56,color:#ffffff
    18["<div style='font-weight: bold'>Sistema Académico UNSA</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Informa si el estudiante<br />tiene matrícula vigente.</div>"]
    style 18 fill:#999999,stroke:#6b6b6b,color:#ffffff
    19["<div style='font-weight: bold'>Proveedor de identidad institucional</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Autentica con el correo<br />institucional de la UNSA.</div>"]
    style 19 fill:#999999,stroke:#6b6b6b,color:#ffffff
    2["<div style='font-weight: bold'>Bibliotecario</div><div style='font-size: 70%; margin-top: 0px'>[Person]</div><div style='font-size: 80%; margin-top:10px'>Registra préstamos y<br />devoluciones con el carné QR<br />y gestiona el inventario.</div>"]
    style 2 fill:#08427b,stroke:#052e56,color:#ffffff
    20["<div style='font-weight: bold'>Servicio de correo</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Entrega los correos<br />electrónicos a los usuarios.</div>"]
    style 20 fill:#999999,stroke:#6b6b6b,color:#ffffff
    3["<div style='font-weight: bold'>BiblioUNSA</div><div style='font-size: 70%; margin-top: 0px'>[Software System]</div><div style='font-size: 80%; margin-top:10px'>Permite consultar el<br />catálogo, reservar libros,<br />prestarlos con carné QR y<br />controlar multas.</div>"]
    style 3 fill:#1168bd,stroke:#0b4884,color:#ffffff

    1-. "<div>Consulta el catálogo, reserva<br />libros y revisa sus multas</div><div style='font-size: 70%'></div>" .->3
    2-. "<div>Registra préstamos y<br />devoluciones y gestiona el<br />inventario</div><div style='font-size: 70%'></div>" .->3
    3-. "<div>Consulta la matrícula vigente</div><div style='font-size: 70%'>[HTTPS/JSON (API)]</div>" .->18
    3-. "<div>Delega el inicio de sesión</div><div style='font-size: 70%'>[HTTPS/OIDC]</div>" .->19
    3-. "<div>Envía avisos por correo</div><div style='font-size: 70%'>[SMTP]</div>" .->20

  end
```

| Vista | Imagen |
|---|---|
| Nivel 1 — Contexto | [structurizr-Contexto.png](docs/architecture/c4/img/structurizr-Contexto.png) |
| Nivel 2 — Contenedores | [structurizr-Contenedores.png](docs/architecture/c4/img/structurizr-Contenedores.png) |
| Nivel 3 — Componentes | [structurizr-Componentes.png](docs/architecture/c4/img/structurizr-Componentes.png) |
| Dinámica — Reservar libro | [structurizr-ReservarLibro.png](docs/architecture/c4/img/structurizr-ReservarLibro.png) |
| Despliegue — Producción | [structurizr-Despliegue.png](docs/architecture/c4/img/structurizr-Despliegue.png) |

Documentos: [inventario](docs/architecture/c4/inventario.md) · [comparación](docs/architecture/c4/comparacion.md) · [revisión con la lista oficial](docs/architecture/c4/revision-c4.md) · [explicación no técnica](docs/architecture/c4/explicacion.md) · [bitácora de IA](docs/architecture/c4/bitacora-ia.md) · [cuestionario](docs/architecture/c4/cuestionario.md). Etiqueta de entrega: `v0.6-c4`.
