# Cuestionario — Laboratorio 06 (BiblioUNSA)

**1. Problema de las «cajas y flechas» que resuelve C4.** Que no se sabe qué es cada caja (servidor, aplicación o módulo) ni qué significa cada flecha o color. En nuestro caso evita confundir «Autenticación» (un módulo dentro de la API) con el «Proveedor de identidad institucional» (un sistema externo) y «Sistema Académico» con un contenedor propio.

**2. Contenedor C4 frente a contenedor Docker.** Un contenedor C4 es una unidad que se ejecuta o despliega por separado (aplicación, base de datos, cola). No depende de Docker. En nuestro caso, la PWA es un contenedor que se ejecuta en el navegador del usuario, no en Docker.

**3. Público y detalle de los 4 niveles.** Nivel 1 (contexto): todos, incluso no técnicos. Nivel 2 (contenedores): equipo técnico. Nivel 3 (componentes): arquitectos y developers. Nivel 4 (código): developers. Rara vez se dibuja a mano porque se puede generar desde el código y se desactualiza rápido; aquí se enlaza `docs/design/clases.puml`.

**4. Vista dinámica frente a secuencia UML.** La dinámica muestra 9 pasos entre contenedores y componentes y sirve para explicar el flujo a un público técnico general; la secuencia UML muestra clases, métodos, bucles y ramas, y sirve para implementar. Usaría la dinámica en una revisión de arquitectura y la secuencia al programar el caso de uso.

**5. Ventaja de Structurizr DSL.** Un solo modelo del que se derivan todas las vistas: si cambia el nombre o la tecnología de un contenedor, se edita una vez y las 5 vistas se actualizan al exportar; además `validate` detecta identificadores inexistentes.

**6. Elementos justificados por el ADR-001.** El contenedor único «API BiblioUNSA» (monolito modular en Django) y su división en 6 módulos como componentes; la base de datos PostgreSQL con un esquema por módulo; y los adaptadores como componentes (puertos y adaptadores). El ADR-003 justifica el worker Celery y Redis.

**7. Error de la IA y cómo se detectó.** La IA propuso modelar «Docker Compose» y «Nginx» como contenedores dentro de BiblioUNSA y, en el despliegue, dejó Nginx sin relaciones. Con la lista de revisión (¿cada elemento tiene tipo?, ¿las flechas tienen etiqueta?) se corrigió: son infraestructura y solo van como nodos de despliegue, con sus conexiones etiquetadas.

**8. Adaptar la explicación.** Docente evaluador: mostrar los 5 niveles y las decisiones (ADR) que los justifican, con la lista de revisión. Inversionista: solo el contexto, qué problema resuelve, de qué servicios depende y el costo (un VPS, 1 mes). Nuevo developer: contenedores y componentes con la vista dinámica y el diagrama de clases, y cómo levantar el modelo con `structurizr.sh`.
