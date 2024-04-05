from fastapi.security import OAuth2PasswordBearer
from passlib.context import CryptContext
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from fastapi import HTTPException
from database import SessionLocal
from fastapi import Depends
from typing import Optional
from jose import jwt
import schemas as sc
import models
import json
from config import SECRET_KEY, ALGORITHM

bcrypt_context = CryptContext(schemes=['bcrypt'], deprecated="auto")

outh2_barrer = OAuth2PasswordBearer(tokenUrl="token")

def get_db():
    try:
        db = SessionLocal()
        yield db
    finally:
        db.close()

def hash_password(password):
    return bcrypt_context.hash(password)

def verify_hash_password(plainPasword,hashPassword):
    return bcrypt_context.verify(plainPasword,hashPassword)

def user_authenticate(email:str, password:str, db:Session=Depends(get_db)):
    user = db.query(models.Admin).filter(models.Admin.email == email).first()
    if not user:
        return False
    if not verify_hash_password(password,user.hashpassword):
        return False
    return user

def gen_token(email:str,usrId:int,expire_delta:Optional[timedelta]=None):
    encode = {"email":email, "usrId":usrId}
    if expire_delta:
        expire = datetime.utcnow() + expire_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=60)
    def serialize_datetime(obj):
        if isinstance(obj, datetime):
            return obj.isoformat()
    encode.update({"expire":json.dumps(expire, default=serialize_datetime)})

    return jwt.encode(encode, SECRET_KEY, algorithm=ALGORITHM)

async def get_current_user(db:Session=Depends(get_db),token: str = Depends(outh2_barrer)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=ALGORITHM)
        id = payload.get("usrId")
        user = db.query(models.Admin).get(id)
    except:
        raise HTTPException(
            status_code=401,
            detail="student credentials not found"
        )
    return sc.showAdmin.from_orm(user)