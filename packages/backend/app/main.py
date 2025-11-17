import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.controller.auth import router as auth_router
from app.controller.clientes import router as client_router

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

app.include_router(auth_router, prefix="/auth", tags=["Autenticación"])
app.include_router(client_router, prefix="/clientes", tags=["Clientes"])


@app.get("/")
async def root():
    return {"message": "API Cliente Manager funcionando correctamente"}


if __name__ == "__main__":
    import uvicorn

    port = int(os.getenv("PORT", "8080"))
    uvicorn.run(app, host="0.0.0.0", port=port)
