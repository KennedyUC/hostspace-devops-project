from fastapi.security import OAuth2PasswordRequestForm
from fastapi import FastAPI, Depends, HTTPException, APIRouter
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta
from school_app.teacher.database import engine
import school_app.teacher.services as sv
import school_app.teacher.schemas as sc
from jose import jwt
import uvicorn
import requests
import school_app.teacher.models as models
from fastapi.openapi.docs import get_swagger_ui_html

app = FastAPI()

login_router = APIRouter()
teacher_router = APIRouter()
attendance_router = APIRouter()
issues_router = APIRouter()
results_router = APIRouter()
leaves_router = APIRouter()
salary_router = APIRouter()
courses_router = APIRouter()
health_router = APIRouter()

app = FastAPI()

origins = [
           "http://127.0.0.1:3000",
           "http://127.0.0.1:3000/register",
           "http://127.0.0.1:8001",
           "http://127.0.0.1:8000",
           "http://127.0.0.1:8002",
           "http://127.0.0.1:8002/",
           "http://localhost:3000",
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
def login_form(form_data:OAuth2PasswordRequestForm=Depends(),db:Session=Depends(sv.get_db)):
    user = sv.user_authenticate(form_data.username,form_data.password,db=db)
    if not user:
        raise HTTPException(
            status_code=404,
            detail='user not found'
        )
    token_expire = timedelta(minutes=60)
    token = sv.gen_token(user.email,user.id,expire_delta=token_expire)
    return {
       "access_token":token,
       "token_type":"bearer"
    }

@login_router.post('/token/decoder')
async def get_current_user(db:Session=Depends(sv.get_db),token: str = Depends(sv.outh2_barrer)):
    try:
        payload = jwt.decode(token, sv.SECRET_KEY, algorithms=sv.ALGORITHAM)
        id = payload.get("usrId")
        user = db.query(models.Teacher).get(id)
    except:
        raise HTTPException(
            status_code=401,
            detail="teacher credentials not found"
        )
    return sc.showAllDataOfTeacher.from_orm(user)

@teacher_router.get('/', response_model=sc.showTeacher)
def get_teacher(u:sc.showTeacher=Depends(sv.get_current_user)):
    return u

@teacher_router.get('/allinstructers')
def get_allinstructers(db:Session=Depends(sv.get_db)):
    aim = db.query(models.Teacher).all()
    return aim

@teacher_router.post('/create')
def create_teacher(s:sc.teacher_schema, db:Session=Depends(sv.get_db)):
    hashed_password = sv.hash_password(s.hashpassword)
    cs = models.Teacher(firstname = s.firstname, lastname = s.lastname, email = s.email, hashpassword = hashed_password,
                        sex = s.sex, address = s.address, phone = s.phone, department = s.department,
                        date_of_birth = s.date_of_birth, appointed = s.appointed)
    db.add(cs)
    db.commit()
    db.refresh(cs)
    user = db.query(models.Teacher).filter(models.Teacher.email==s.email).first()
    token=sv.gen_token(email=user.email,usrId=user.id)
    return {
       "access_token":token,
       "token_type":"bearer"
    }
    
@teacher_router.put('/update/{id}')
def update_teacher(id:int,s:sc.teacher_schema, db:Session=Depends(sv.get_db)):
    hashed_password = sv.hash_password(s.hashpassword)
    db.query(models.Teacher).filter(models.Teacher.id == id)\
    .update({'firstname':s.firstname, 'lastname':s.lastname, 'email':s.email,
             'hashpassword':hashed_password, 'sex' : s.sex, 'address' : s.address,
             'phone' : s.phone, 'department' : s.department, 'date_of_birth' : s.date_of_birth, 'appointed' : s.appointed },
            synchronize_session=False)
    db.commit()
    return {
        'status' : 'Teacher updated successfully'
    }
    
@teacher_router.delete('/delete/{id}')
def delete_teacher(id:int, db:Session=Depends(sv.get_db)):
    db.query(models.Teacher).filter(models.Teacher.id == id).delete(synchronize_session=False)
    db.commit()
    return {
        'status' : 'Teacher deleted successfully'
    }
    
@teacher_router.get('/teacher/allstudents')
async def get_all_students():
    req = requests.get("http://127.0.0.1:9002/student/allstudents")
    return req.json()

@attendance_router.get('/teacher/attendance', response_model=sc.teacherattendance_schema)
def get_TeacherAttendance(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.TeacherAttendence).filter(models.TeacherAttendence.teacher_id == u.id).first()
    return sim

@attendance_router.post('/teacher/attendance')
def create_info(s:sc.teacherattendance_schema,db:Session=Depends(sv.get_db)):
    cim = models.TeacherAttendence(regno=s.regno,department=s.department,
                                   ondate=s.ondate, present=s.present,
                                   teacher_id=s.teacher_id, )
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'Teacher attendence created successfully'
    }

@issues_router.get('/teacher/issues', response_model=sc.teacherissues_schema)
def get_TeacherIssues(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.TeacherIssues).filter(models.TeacherIssues.teacher_id == u.id).first()
    return sim

@issues_router.post('/teacher/issues')
def create_tinfo(s:sc.teacherissues_schema,db:Session=Depends(sv.get_db)):
    cim = models.TeacherIssues( issue_id=s.issue_id, issue=s.issue, type=s.type,
                                   teacher_id=s.teacher_id)
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'Teacher issue created successfully'
    }

@leaves_router.get('/teacher/leaves', response_model=sc.teacherleaves_schema)
def get_TeacherLeaves(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.TeacherLeaves).filter(models.TeacherLeaves.teacher_id == u.id).first()
    return sim

@leaves_router.post('/teacher/leaves')
def create_results(s:sc.teacherleaves_schema,db:Session=Depends(sv.get_db)):
    cim = models.TeacherLeaves( leave_id=s.leave_id, reason=s.reason, 
                               no_of_days=s.no_of_days,teacher_id=s.teacher_id)
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'Teacher leave created successfully'
    }

@salary_router.get('/teacher/fees', response_model=sc.teachersalary_schema)
def get_TeacherFees(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.TeacherSalary).filter(models.TeacherSalary.teacher_id == u.id).first()
    return sim

@salary_router.post('/teacher/fees')
def create_Fees(s:sc.teachersalary_schema,db:Session=Depends(sv.get_db)):
    cim = models.TeacherSalary( salary_id=s.salary_id, total_salary=s.total_salary, 
                               PF=s.PF,paid=s.paid,teacher_id=s.teacher_id)
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'Teacher salary created successfully'
    }

@health_router.get('/health')
def app_health():
    return "teacher_api endpoint is healthy"

@app.get("/teacher/docs", include_in_schema=False)
async def get_swagger_ui():
    return get_swagger_ui_html(openapi_url="/teacher/openapi.json", title="Teacher API Docs")

@app.get("/teacher/openapi.json", include_in_schema=False)
async def get_openapi():
    return app.openapi()

app.include_router(teacher_router, tags=["Teacher"], prefix="/teacher")
app.include_router(login_router, tags=['Login Form'], prefix="/teacher")
app.include_router(attendance_router, tags=['Teacher Attendance'], prefix="/teacher")
app.include_router(leaves_router, tags=['Teacher Leaves'], prefix="/teacher")
app.include_router(issues_router, tags=['Teacher Issues'], prefix="/teacher")
app.include_router(salary_router, tags=['Teacher Salary'], prefix="/teacher")
app.include_router(health_router, tags=['Health'], prefix="/teacher")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=9003, reload=True)