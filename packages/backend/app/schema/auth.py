from pydantic import BaseModel


# Modelos Pydantic
class LoginRequest(BaseModel):
    username: str
    password: str


class Token(BaseModel):
    access_token: str
    token_type: str
