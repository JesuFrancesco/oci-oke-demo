from pydantic import BaseModel
from typing import Optional


class Cliente(BaseModel):
    id: int
    nombre: str
    email: str
    telefono: str
    empresa: str
    direccion: str
    estado: str  # "activo", "inactivo"


# Modelo extendido para registro de clientes
class RegistroRequest(BaseModel):
    username: str
    password: str
    email: str
    nombre: str
    telefono: Optional[str] = None
    empresa: Optional[str] = None
    direccion: Optional[str] = None
