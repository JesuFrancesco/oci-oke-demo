import os
from fastapi import FastAPI, HTTPException, Depends
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from jose import jwt
from datetime import datetime, timedelta

env = os.getenv("ENVIRONMENT", "development")

app = FastAPI(title=f"Cliente Manager API ({env})")

# Configurar CORS para permitir conexiones desde Flutter
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Configuración JWT
SECRET_KEY = os.getenv("JWT_SECRET_KEY", "clavesin_bombin")
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

security = HTTPBearer()


# Modelos Pydantic
class LoginRequest(BaseModel):
    username: str
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str


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


# Funciones auxiliares
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt


def verify_token(credentials: HTTPAuthorizationCredentials = Depends(security)):
    try:
        payload = jwt.decode(
            credentials.credentials, SECRET_KEY, algorithms=[ALGORITHM]
        )
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Token inválido")
        return username
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expirado")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Token inválido")


@app.post("/registro")
async def registro(registro_data: RegistroRequest):
    if registro_data.username in usuarios:
        raise HTTPException(status_code=400, detail="El usuario ya existe")

    if len(registro_data.password) < 6:
        raise HTTPException(
            status_code=400, detail="La contraseña debe tener al menos 6 caracteres"
        )

    # Guardar el usuario en la "base de datos"
    usuarios[registro_data.username] = registro_data.password

    # Crear el cliente asociado
    nuevo_cliente = Cliente(
        id=len(clientes_data) + 1,
        nombre=registro_data.nombre,
        email=registro_data.email,
        telefono=registro_data.telefono,
        empresa=registro_data.empresa,
        direccion=registro_data.direccion,
        estado="activo",
    )
    clientes_data.append(nuevo_cliente)

    access_token = create_access_token(data={"sub": registro_data.username})
    return {
        "message": "Usuario registrado exitosamente",
        "access_token": access_token,
        "token_type": "bearer",
    }


@app.post("/login", response_model=Token)
async def login(login_data: LoginRequest):
    if (
        login_data.username not in usuarios
        or usuarios[login_data.username] != login_data.password
    ):
        raise HTTPException(status_code=401, detail="Credenciales incorrectas")

    access_token = create_access_token(data={"sub": login_data.username})
    return {"access_token": access_token, "token_type": "bearer"}


@app.get("/clientes", response_model=List[Cliente])
async def obtener_clientes(username: str = Depends(verify_token)):
    return clientes_data


@app.get("/clientes/{cliente_id}", response_model=Cliente)
async def obtener_cliente(cliente_id: int, username: str = Depends(verify_token)):
    cliente = next((c for c in clientes_data if c.id == cliente_id), None)
    if not cliente:
        raise HTTPException(status_code=404, detail="Cliente no encontrado")
    return cliente


@app.get("/")
async def root():
    return {"message": "API Cliente Manager funcionando correctamente"}


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", "8080"))
    uvicorn.run(app, host="0.0.0.0", port=port)
