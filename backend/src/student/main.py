from fastapi.security import OAuth2PasswordRequestForm
from fastapi import FastAPI,Depends,HTTPException,APIRouter
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
from datetime import timedelta
from src.student.database import engine
import src.student.services as sv
import src.student.schemas as sc
from jose import jwt
import uvicorn
import src.student.models as models
from fastapi.openapi.docs import get_swagger_ui_html

app = FastAPI()

login_router = APIRouter()
student_router = APIRouter()
attendance_router = APIRouter()
issues_router = APIRouter()
results_router = APIRouter()
leaves_router = APIRouter()
fees_router = APIRouter()
courses_router = APIRouter()
health_router = APIRouter()

origins = [
           "http://127.0.0.1:3000",
           "http://127.0.0.1:3000/register",
           "http://127.0.0.1:8000/student/issues",
           "http://127.0.0.1:8000",
           "http://127.0.0.1:8001",
           "http://127.0.0.1:8002",
           "http://127.0.0.1:8000/",
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
        user = db.query(models.Student).get(id)
    except:
        raise HTTPException(
            status_code=401,
            detail="student credentials not found"
        )
    return sc.showAllDataOfUser.from_orm(user)

@student_router.get('/', response_model=sc.showUser)
def get_student(u:sc.showUser=Depends(sv.get_current_user)):
    return u

@student_router.get("/allstudents")
def all_students(db:Session=Depends(sv.get_db)):
    return db.query(models.Student).all()

@student_router.post('/create')
def create_student(s:sc.student_schema, db:Session=Depends(sv.get_db)):
    hashed_password = sv.hash_password(s.hashpassword)
    cs = models.Student(firstname = s.firstname, lastname = s.lastname, email = s.email, hashpassword = hashed_password,
                        sex = s.sex, address = s.address, phone = s.phone, parentname = s.parentname,
                        date_of_birth = s.date_of_birth, date_joined = s.date_joined)
    db.add(cs)
    db.commit()
    db.refresh(cs)
    user = db.query(models.Student).filter(models.Student.email==s.email).first()
    token=sv.gen_token(email=user.email,usrId=user.id)
    return {
       "access_token":token,
       "token_type":"bearer"
    }
    
@student_router.put('/update/{id}')
def update_student(id:int,s:sc.student_schema, db:Session=Depends(sv.get_db)):
    hashed_password = sv.hash_password(s.hashpassword)
    db.query(models.Student).filter(models.Student.id == id)\
    .update({'firstname':s.firstname, 'lastname':s.lastname, 'email':s.email,
             'hashpassword':hashed_password, 'sex' : s.sex, 'address' : s.address,
             'phone' : s.phone, 'parentname' : s.parentname, 'date_of_birth' : s.date_of_birth, 'date_joined' : s.date_joined },
            synchronize_session=False)
    db.commit()
    return {
        'status' : 'student updated successfully'
    }
    
@student_router.delete('/delete/{id}')
def delete_student(id:int, db:Session=Depends(sv.get_db)):
    db.query(models.Student).filter(models.Student.id == id).delete(synchronize_session=False)
    db.commit()
    return {
        'status' : 'student deleted successfully'
    }

@attendance_router.get('/student/attendance', response_model=sc.studentattendance_schema)
def get_studentAttendance(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.StudentAttendence).filter(models.StudentAttendence.student_id == u.id).first()
    return sim

@attendance_router.post('/student/attendance')
def create_info(s:sc.studentattendance_schema,db:Session=Depends(sv.get_db)):
    cim = models.StudentAttendence(standard=s.standard, section=s.section,
                                   ondate=s.ondate, present=s.present,
                                   student_id=s.student_id, )
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'student attendence created successfully'
    }

@issues_router.get('/student/issues', response_model=sc.studentissues_schema)
def get_studentIssues(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.StudentIssues).filter(models.StudentIssues.student_id == u.id).first()
    return sim

@issues_router.post('/student/issues')
def create_info(s:sc.studentissues_schema,db:Session=Depends(sv.get_db)):
    cim = models.StudentIssues( issue_id=s.issue_id, issue=s.issue, type=s.type,
                                   student_id=s.student_id)
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'student issue created successfully'
    }

@results_router.get('/student/results', response_model=sc.studentresults_schema)
def get_studentResults(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.StudentResults).filter(models.StudentResults.student_id == u.id).first()
    return sim

@results_router.post('/student/results')
def create_results(s:sc.studentresults_schema,db:Session=Depends(sv.get_db)):
    cim = models.StudentResults( results_id=s.results_id, grade=s.grade,marks=s.marks, student_id=s.student_id)
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'student result created successfully'
    }

@leaves_router.get('/student/leaves', response_model=sc.studentleaves_schema)
def get_studentLeaves(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.StudentLeaves).filter(models.StudentLeaves.student_id == u.id).first()
    return sim

@leaves_router.post('/student/leaves')
def create_results(s:sc.studentleaves_schema,db:Session=Depends(sv.get_db)):
    cim = models.StudentLeaves( leave_id=s.leave_id, reason=s.reason, 
                               no_of_days=s.no_of_days,student_id=s.student_id)
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'student leave created successfully'
    }

@fees_router.get('/student/fees', response_model=sc.studentfees_schema)
def get_studentFees(u:dict=Depends(sv.get_current_user), db:Session=Depends(sv.get_db)):
    sim = db.query(models.StudentFees).filter(models.StudentFees.student_id == u.id).first()
    return sim

@fees_router.post('/student/fees')
def create_Fees(s:sc.studentfees_schema,db:Session=Depends(sv.get_db)):
    cim = models.StudentFees( fee_id=s.fee_id, total_fee=s.total_fee, 
                               fee_due=s.fee_due,student_id=s.student_id)
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'student fee created successfully'
    }

@courses_router.get('/student/courses')
def get_allstudentFees(db:Session=Depends(sv.get_db)):
    sim = db.query(models.StudentCourses).all()
    return sim

@courses_router.post('/student/courses')
def create_Courses(s:sc.studentcourses_schema,db:Session=Depends(sv.get_db)):
    cim = models.StudentCourses( courseid=s.courseid, coursename=s.coursename, 
                               subject=s.subject,totalhours=s.totalhours, available=s.available)
    db.add(cim)
    db.commit()
    db.refresh(cim)
    return {
        'status' : 'student courses created successfully'
    }

@health_router.get('/health')
def app_health():
    return "Application is healthy"

@app.get("/student/docs", include_in_schema=False)
async def get_swagger_ui():
    return get_swagger_ui_html(openapi_url="/student/openapi.json", title="Student API Docs")

@app.get("/student/openapi.json", include_in_schema=False)
async def get_openapi():
    return app.openapi()

app.include_router(student_router, tags=["Student"], prefix="/student")
app.include_router(login_router, tags=['Login Form'])
app.include_router(attendance_router, tags=['Student Attendance'], prefix="/student_attendance")
app.include_router(leaves_router, tags=['Student Leaves'], prefix="/student_leave")
app.include_router(issues_router, tags=['Student Issues'], prefix="/student_issue")
app.include_router(results_router, tags=['Student Results'], prefix="/student_result")
app.include_router(fees_router, tags=["Student Fees"], prefix="/student_fee")
app.include_router(health_router, tags=['Health'], prefix="/student")

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=9002, reload=True)