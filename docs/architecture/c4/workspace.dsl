workspace "BiblioUNSA" "Modelo C4 de la plataforma de préstamo y reserva de libros de las bibliotecas de la UNSA" {

    !identifiers hierarchical
    !impliedRelationships false

    model {
        estudiante = person "Estudiante" "Busca libros, los reserva y consulta sus préstamos y multas."
        bibliotecario = person "Bibliotecario" "Registra préstamos y devoluciones con el carné QR y gestiona el inventario."

        biblio = softwareSystem "BiblioUNSA" "Permite consultar el catálogo, reservar libros, prestarlos con carné QR y controlar multas." {
            pwa = container "Aplicación web (PWA)" "Interfaz para estudiantes y bibliotecarios desde celular o PC." "HTML, JavaScript y Service Worker" "Web Browser"
            api = container "API BiblioUNSA" "Monolito modular que implementa los casos de uso mediante una API REST (ADR-001)." "Python / Django" {
                autenticacion = component "Módulo Autenticación" "Identifica a la persona y valida su matrícula mediante puertos." "Django app"
                catalogo = component "Módulo Catálogo" "Libros, ejemplares y disponibilidad." "Django app"
                reservas = component "Módulo Reservas" "Crea reservas de ejemplares disponibles para estudiantes con matrícula vigente." "Django app"
                prestamos = component "Módulo Préstamos" "Convierte reservas en préstamos y registra devoluciones." "Django app"
                multas = component "Módulo Multas" "Calcula y controla multas por retraso." "Django app"
                notificaciones = component "Módulo Notificaciones" "Genera avisos de reserva, vencimiento y multa." "Django app"
                adaptadorAcademico = component "Adaptador Sistema académico" "Implementa el puerto de matrícula consultando la API académica." "Adaptador (puertos y adaptadores)"
                adaptadorIdentidad = component "Adaptador Identidad" "Implementa el puerto de identidad con el correo institucional." "Adaptador (puertos y adaptadores)"
                adaptadorCorreo = component "Adaptador Correo" "Implementa el puerto de correo electrónico." "Adaptador (puertos y adaptadores)"
            }
            worker = container "Worker de tareas" "Ejecuta avisos, reintentos de validación de matrícula (ADR-003) y tareas programadas de vencimientos y multas." "Celery"
            db = container "Base de datos" "Usuarios, libros, ejemplares, reservas, préstamos y multas (un esquema por módulo)." "PostgreSQL" "Database"
            cola = container "Cola y caché" "Cola de tareas y caché corta de la matrícula (ADR-003)." "Redis" "Queue"
        }

        academico = softwareSystem "Sistema Académico UNSA" "Informa si el estudiante tiene matrícula vigente." "Externo"
        identidad = softwareSystem "Proveedor de identidad institucional" "Autentica con el correo institucional de la UNSA." "Externo"
        correo = softwareSystem "Servicio de correo" "Entrega los correos electrónicos a los usuarios." "Externo"

        # Nivel 1: contexto
        estudiante -> biblio "Consulta el catálogo, reserva libros y revisa sus multas"
        bibliotecario -> biblio "Registra préstamos y devoluciones y gestiona el inventario"
        biblio -> academico "Consulta la matrícula vigente" "HTTPS/JSON (API)"
        biblio -> identidad "Delega el inicio de sesión" "HTTPS/OIDC"
        biblio -> correo "Envía avisos por correo" "SMTP"

        # Nivel 2: contenedores
        estudiante -> biblio.pwa "Usa" "HTTPS"
        bibliotecario -> biblio.pwa "Usa" "HTTPS"
        biblio.pwa -> biblio.api "Llama a" "HTTPS/JSON (REST)"
        biblio.api -> biblio.db "Lee y escribe" "SQL/TCP"
        biblio.api -> biblio.cola "Encola tareas y lee la caché" "Redis protocol"
        biblio.worker -> biblio.cola "Consume tareas" "Redis protocol"
        biblio.worker -> biblio.db "Lee préstamos vencidos y registra multas" "SQL/TCP"
        biblio.api -> academico "Consulta la matrícula vigente" "HTTPS/JSON (API)"
        biblio.api -> identidad "Delega el inicio de sesión" "HTTPS/OIDC"
        biblio.worker -> academico "Reintenta validaciones pendientes" "HTTPS/JSON (API)"
        biblio.worker -> correo "Envía avisos por correo" "SMTP"

        # Nivel 3: componentes (las flechas son llamadas en ejecución; ver consistencia con paquetes.puml)
        biblio.pwa -> biblio.api.autenticacion "Inicia sesión" "HTTPS/JSON"
        biblio.pwa -> biblio.api.catalogo "Consulta libros" "HTTPS/JSON"
        biblio.pwa -> biblio.api.reservas "Reserva libros" "HTTPS/JSON"
        biblio.pwa -> biblio.api.prestamos "Registra préstamos y devoluciones" "HTTPS/JSON"
        biblio.pwa -> biblio.api.multas "Consulta multas" "HTTPS/JSON"
        biblio.api.reservas -> biblio.api.autenticacion "Identifica al estudiante"
        biblio.api.reservas -> biblio.api.catalogo "Verifica ejemplar disponible"
        biblio.api.reservas -> biblio.api.notificaciones "Confirma la reserva"
        biblio.api.prestamos -> biblio.api.reservas "Convierte la reserva en préstamo"
        biblio.api.prestamos -> biblio.api.catalogo "Marca ejemplar prestado o libre"
        biblio.api.prestamos -> biblio.api.autenticacion "Identifica al estudiante"
        biblio.api.multas -> biblio.api.prestamos "Consulta préstamos vencidos"
        biblio.api.multas -> biblio.api.notificaciones "Avisa la multa"
        biblio.api.autenticacion -> biblio.api.adaptadorAcademico "Consulta la matrícula (puerto)"
        biblio.api.autenticacion -> biblio.api.adaptadorIdentidad "Delega la identidad (puerto)"
        biblio.api.notificaciones -> biblio.api.adaptadorCorreo "Envía el correo (puerto)"
        biblio.api.adaptadorAcademico -> academico "Consulta la matrícula vigente" "HTTPS/JSON (API)"
        biblio.api.adaptadorIdentidad -> identidad "Autentica con el correo institucional" "HTTPS/OIDC"
        biblio.api.adaptadorCorreo -> correo "Entrega el correo" "SMTP"
        biblio.api.notificaciones -> biblio.cola "Encola avisos" "Redis protocol"
        biblio.api.autenticacion -> biblio.db "Lee y escribe usuarios" "SQL"
        biblio.api.catalogo -> biblio.db "Lee y escribe libros y ejemplares" "SQL"
        biblio.api.reservas -> biblio.db "Guarda la reserva" "SQL"
        biblio.api.prestamos -> biblio.db "Lee y escribe préstamos" "SQL"
        biblio.api.multas -> biblio.db "Lee y escribe multas" "SQL"

        # Despliegue
        produccion = deploymentEnvironment "Producción" {
            dispositivo = deploymentNode "Celular o PC del usuario" "" "Android, iOS o Windows; navegador web" {
                pwaInst = containerInstance biblio.pwa
            }
            vps = deploymentNode "VPS en la nube" "Un único servidor de bajo costo (R-03)" "Ubuntu Server 24.04, 2 vCPU, 4 GB RAM" {
                nginx = infrastructureNode "Nginx" "Proxy inverso con HTTPS" "Nginx"
                monolito = deploymentNode "Monolito modular" "" "Python 3 / Django" {
                    apiInst = containerInstance biblio.api
                    containerInstance biblio.worker
                }
                deploymentNode "Datos" "" "Servicios locales del VPS" {
                    containerInstance biblio.db
                    containerInstance biblio.cola
                }
            }
            dispositivo.pwaInst -> vps.nginx "Llama a" "HTTPS"
            vps.nginx -> vps.monolito.apiInst "Reenvía las peticiones" "HTTP"
        }
    }

    views {
        systemContext biblio "Contexto" "Nivel 1: BiblioUNSA y su entorno." {
            include *
            autolayout lr
        }
        container biblio "Contenedores" "Nivel 2: contenedores de BiblioUNSA." {
            include *
            autolayout lr
        }
        component biblio.api "Componentes" "Nivel 3: módulos de la API." {
            include *
            autolayout lr
        }
        dynamic biblio.api "ReservarLibro" "Dinámico: reservar un libro (equivale a la secuencia del Laboratorio 05)." {
            estudiante -> biblio.pwa "Pulsa «Reservar libro»"
            biblio.pwa -> biblio.api.reservas "POST /reservas"
            biblio.api.reservas -> biblio.api.autenticacion "Identifica al estudiante"
            biblio.api.autenticacion -> biblio.api.adaptadorAcademico "Consulta la matrícula (puerto)"
            biblio.api.adaptadorAcademico -> academico "Consulta la matrícula vigente"
            biblio.api.reservas -> biblio.api.catalogo "Verifica ejemplar disponible"
            biblio.api.reservas -> biblio.db "Guarda la reserva"
            biblio.api.reservas -> biblio.api.notificaciones "Confirma la reserva (asíncrono)"
            biblio.api.notificaciones -> biblio.cola "Encola el aviso"
            autolayout lr
        }
        deployment biblio produccion "Despliegue" "Despliegue en producción (MVP)." {
            include *
            autolayout lr
        }
        styles {
            element "Person" {
                shape person
                background #08427B
                color #ffffff
            }
            element "Software System" {
                background #1168BD
                color #ffffff
            }
            element "Externo" {
                background #999999
            }
            element "Container" {
                background #438DD5
                color #ffffff
            }
            element "Component" {
                background #85BBF0
                color #000000
            }
            element "Database" {
                shape cylinder
            }
            element "Queue" {
                shape pipe
            }
            element "Web Browser" {
                shape WebBrowser
            }
        }
    }
}
