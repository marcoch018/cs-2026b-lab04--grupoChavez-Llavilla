# HU-04: Reservar un libro con matrícula vigente

Como estudiante de la UNSA, quiero reservar un libro desde la web de BiblioUNSA
para recogerlo en la biblioteca sin hacer cola.

## Criterios de aceptación

1. Dado un estudiante con matrícula vigente y un libro con al menos un ejemplar
   disponible, cuando reserva el libro, entonces el préstamo queda en estado
   RESERVADO, el ejemplar queda reservado y el estudiante recibe una
   confirmación por correo.
2. Dado un estudiante sin matrícula vigente, cuando intenta reservar un libro,
   entonces el sistema rechaza la reserva y no se reserva ningún ejemplar.
3. Dado un préstamo en estado RESERVADO, cuando pasan 48 horas sin que el
   estudiante recoja el libro, entonces el préstamo queda CANCELADO y el
   ejemplar vuelve a estar disponible.