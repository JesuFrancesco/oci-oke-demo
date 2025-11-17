import os
from fastapi import HTTPException, APIRouter
from app.util.crypto import create_access_token
from app.schema.auth import LoginRequest, Token

env = os.getenv("ENVIRONMENT", "development")

router = APIRouter()

# Datos en memoria (simulando DB)
usuarios = {"admin": "password123", "usuario": "123456"}


@router.post("/login", response_model=Token)
async def login(login_data: LoginRequest):
    if (
        login_data.username not in usuarios
        or usuarios[login_data.username] != login_data.password
    ):
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

    access_token = create_access_token(data={"sub": login_data.username})
    return {"access_token": access_token, "token_type": "bearer"}
