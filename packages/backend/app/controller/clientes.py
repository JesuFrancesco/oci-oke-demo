from app.schema.clientes import Cliente
from app.util.crypto import verify_token

from fastapi import HTTPException, Depends, APIRouter
from typing import List

router = APIRouter()

# Datos en memoria (simulando DB)
usuarios = {"admin": "password123", "usuario": "123456"}

clientes_data = [
    Cliente(
        id=1,
        nombre="Juan Pérez",
        email="juan@email.com",
        telefono="+51987654321",
        empresa="Tech Solutions",
        direccion="Av. Lima 123",
        estado="activo",
    ),
    Cliente(
        id=5,
        nombre="Roberto Mendoza",
        email="roberto@email.com",
        telefono="+51987654325",
        empresa="Importaciones",
        direccion="Av. Colonial 202",
        estado="activo",
    ),
]


@router.get("/", response_model=List[Cliente])
async def obtener_clientes(_: str = Depends(verify_token)):
    return clientes_data


@router.get("/{cliente_id}", response_model=Cliente)
async def obtener_cliente(cliente_id: int, _: str = Depends(verify_token)):
    cliente = next((c for c in clientes_data if c.id == cliente_id), None)
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    return cliente
