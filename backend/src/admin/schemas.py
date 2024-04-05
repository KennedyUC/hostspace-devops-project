from pydantic import BaseModel, PositiveInt
from datetime import date
from typing import Any

class admin_schema(BaseModel):
    id : int
    firstname : str
    lastname : str
    email : str
    hashpassword : str
    sex : str
    phone : PositiveInt
    appointed : date
    
    class Config():
        orm_mode = True

class showAdmin(BaseModel):
    id : int
    firstname : str
    email : str
    appointed : date
    
    class Config():
        orm_mode = True