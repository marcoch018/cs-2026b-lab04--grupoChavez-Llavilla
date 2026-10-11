from __future__ import annotations

from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta
from decimal import Decimal
from enum import Enum
from uuid import UUID, uuid4

PLAZO_PRESTAMO_DIAS = 7
TARIFA_DIARIA = Decimal("0.50")


class EstadoPrestamo(Enum):
    RESERVADO = "RESERVADO"
    PRESTADO = "PRESTADO"
    VENCIDO = "VENCIDO"
    CON_MULTA = "CON_MULTA"
    DEVUELTO = "DEVUELTO"
    CANCELADO = "CANCELADO"


@dataclass
class Ejemplar:
    codigo_barras: str
    disponible: bool = True

    def esta_disponible(self) -> bool:
        return self.disponible

    def reservar(self) -> None:
        if not self.disponible:
            raise ValueError("El ejemplar no está disponible")
        self.disponible = False

    def liberar(self) -> None:
        self.disponible = True


@dataclass
class Libro:
    isbn: str
    titulo: str
    autor: str
    ejemplares: list[Ejemplar] = field(default_factory=list)

    def buscar_ejemplar_disponible(self) -> Ejemplar | None:
        for ejemplar in self.ejemplares:
            if ejemplar.esta_disponible():
                return ejemplar
        return None


@dataclass
class Multa:
    monto: Decimal
    dias_retraso: int
    pagada: bool = False


@dataclass
class Estudiante:
    cui: str
    nombres: str
    correo: str
    matricula_vigente: bool = False
    id: UUID = field(default_factory=uuid4)

    def tiene_matricula_vigente(self) -> bool:
        return self.matricula_vigente

    def crear_reserva(self, ejemplar: Ejemplar) -> Prestamo:
        return Prestamo(estudiante=self, ejemplar=ejemplar)


@dataclass
class Prestamo:
    estudiante: Estudiante
    ejemplar: Ejemplar
    fecha_reserva: datetime = field(default_factory=datetime.now)
    fecha_limite: date | None = None
    fecha_devolucion: date | None = None
    estado: EstadoPrestamo = EstadoPrestamo.RESERVADO
    multa: Multa | None = None
    id: UUID = field(default_factory=uuid4)

    def entregar(self) -> None:
        if self.estado != EstadoPrestamo.RESERVADO:
            raise ValueError("Solo se entrega un préstamo RESERVADO")
        self.estado = EstadoPrestamo.PRESTADO
        self.fecha_limite = date.today() + timedelta(days=PLAZO_PRESTAMO_DIAS)

    def marcar_vencido(self) -> None:
        if self.estado == EstadoPrestamo.PRESTADO and date.today() > self.fecha_limite:
            self.estado = EstadoPrestamo.VENCIDO

    def calcular_multa(self, fecha: date) -> Decimal:
        dias = (fecha - self.fecha_limite).days
        return TARIFA_DIARIA * max(dias, 0)

    def registrar_devolucion(self, fecha: date) -> None:
        self.fecha_devolucion = fecha
        dias = (fecha - self.fecha_limite).days
        self.ejemplar.liberar()
        if dias > 0:
            self.multa = Multa(monto=self.calcular_multa(fecha), dias_retraso=dias)
            self.estado = EstadoPrestamo.CON_MULTA
        else:
            self.estado = EstadoPrestamo.DEVUELTO

    def pagar_multa(self) -> None:
        if self.estado != EstadoPrestamo.CON_MULTA:
            raise ValueError("El préstamo no tiene multa pendiente")
        self.multa.pagada = True
        self.estado = EstadoPrestamo.DEVUELTO

    def cancelar(self, motivo: str) -> None:
        if self.estado != EstadoPrestamo.RESERVADO:
            raise ValueError("Solo se cancela un préstamo RESERVADO")
        self.estado = EstadoPrestamo.CANCELADO
        self.ejemplar.liberar()


class VerificadorMatricula(ABC):
    @abstractmethod
    def consultar_matricula(self, cui: str) -> Estudiante: ...


class Notificador(ABC):
    @abstractmethod
    def notificar_reserva(self, p: Prestamo) -> None: ...


class RepositorioPrestamos(ABC):
    @abstractmethod
    def buscar(self, id: UUID) -> Prestamo: ...

    @abstractmethod
    def guardar(self, p: Prestamo) -> None: ...


class CatalogoLibros(ABC):
    @abstractmethod
    def buscar_por_isbn(self, isbn: str) -> Libro: ...


class MatriculaUnsaAdapter(VerificadorMatricula):
    def consultar_matricula(self, cui: str) -> Estudiante:
        raise NotImplementedError("Integrar con el sistema de matrícula")


class CorreoAdapter(Notificador):
    def notificar_reserva(self, p: Prestamo) -> None:
        raise NotImplementedError("Integrar con el servicio de correo")


class ServicioPrestamos:
    def __init__(self, verificador: VerificadorMatricula, catalogo: CatalogoLibros,
                 repositorio: RepositorioPrestamos, notificador: Notificador):
        self.verificador = verificador
        self.catalogo = catalogo
        self.repositorio = repositorio
        self.notificador = notificador

    def reservar_libro(self, cui: str, isbn: str) -> Prestamo:
        estudiante = self.verificador.consultar_matricula(cui)
        if not estudiante.tiene_matricula_vigente():
            raise PermissionError("Matrícula no vigente")
        libro = self.catalogo.buscar_por_isbn(isbn)
        ejemplar = libro.buscar_ejemplar_disponible()
        if ejemplar is None:
            raise ValueError("Sin ejemplares disponibles")
        ejemplar.reservar()
        prestamo = estudiante.crear_reserva(ejemplar)
        self.repositorio.guardar(prestamo)
        self.notificador.notificar_reserva(prestamo)
        return prestamo

    def registrar_devolucion(self, prestamo_id: UUID) -> Prestamo:
        prestamo = self.repositorio.buscar(prestamo_id)
        prestamo.registrar_devolucion(date.today())
        self.repositorio.guardar(prestamo)
        return prestamo