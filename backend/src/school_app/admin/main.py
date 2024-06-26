from fastapi.security import OAuth2PasswordRequestForm
from fastapi import FastAPI, Depends, HTTPException, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta
from school_app.admin.database import engine
import school_app.admin.services as sv
import school_app.admin.schemas as sc
from jose import jwt
import uvicorn
import school_app.admin.models as models
from fastapi.openapi.docs import get_swagger_ui_html

app = FastAPI()

login_router = APIRouter()
admin_router = APIRouter()
health_router = APIRouter()

origins = [
    "https://app.kennweb.tech"
]
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

models.Base.metadata.create_all(bind=engine)

@login_router.post('/token')
def login_form(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(sv.get_db)):
    user = sv.user_authenticate(form_data.username, form_data.password, db=db)
    if not user:
        raise HTTPException(
            status_code=404,
            detail='user not found'
        )
    token_expire = timedelta(minutes=60)
    token = sv.gen_token(user.email, user.id, expire_delta=token_expire)
    return {
        "access_token": token,
        "token_type": "bearer"
    }

@login_router.post('/token/decoder')
async def get_current_user(db: Session = Depends(sv.get_db), token: str = Depends(sv.outh2_barrer)):
    try:
        payload = jwt.decode(token, sv.SECRET_KEY, algorithms=sv.ALGORITHAM)
        id = payload.get("usrId")
        user = db.query(models.Admin).get(id)
    except:
        raise HTTPException(
            status_code=401,
            detail="admin credentials not found"
        )
    return sc.admin_schema.from_orm(user)


@admin_router.get('/', response_model=sc.showAdmin)
def get_admin(u: sc.showAdmin = Depends(sv.get_current_user)):
    return u

@admin_router.post('/create')
def create_Admin(s: sc.admin_schema, db: Session = Depends(sv.get_db)):
    hashed_password = sv.hash_password(s.hashpassword)
    cs = models.Admin(firstname=s.firstname, lastname=s.lastname, email=s.email, hashpassword=hashed_password,
                      sex=s.sex, phone=s.phone, appointed=s.appointed)
    db.add(cs)
    db.commit()
    db.refresh(cs)
    user = db.query(models.Admin).filter(models.Admin.email == s.email).first()
    token = sv.gen_token(email=user.email, usrId=user.id)
    return {
        "access_token": token,
        "token_type": "bearer"
    }
    
@admin_router.put('/update/{id}')
def update_Admin(id: int, s: sc.admin_schema, db: Session = Depends(sv.get_db)):
    hashed_password = sv.hash_password(s.hashpassword)
    db.query(models.Admin).filter(models.Admin.id == id)\
    .update({'firstname': s.firstname, 'lastname': s.lastname, 'email': s.email,
             'hashpassword': hashed_password, 'sex': s.sex, 'phone': s.phone, 'appointed': s.appointed},
            synchronize_session=False)
    db.commit()
    return {
        'status': 'admin updated successfully'
    }
    
@admin_router.delete('/delete/{id}')
def delete_Admin(id: int, db: Session = Depends(sv.get_db)):
    db.query(models.Admin).filter(models.Admin.id == id).delete(synchronize_session=False)
    db.commit()
    return {
        'status': 'admin deleted successfully'
    }

@admin_router.get('/health')
def app_health():
    return "Application is healthy"

@app.get("/admin/docs", include_in_schema=False)
async def get_swagger_ui():
    return get_swagger_ui_html(openapi_url="/admin/openapi.json", title="Admin API Docs")

@app.get("/admin/openapi.json", include_in_schema=False)
async def get_admin_openapi():
    return app.openapi()

app.include_router(admin_router, tags=["Admin"], prefix="/admin") 
app.include_router(login_router, tags=['Login Form'])
app.include_router(health_router, tags=['Health'], prefix="/admin")

if __name__ == "__main__":
    uvicorn.run("school_app.admin.main:app", host="0.0.0.0", port=9001, reload=True)