from sqlalchemy import Column,Integer,VARCHAR,ForeignKey,BigInteger,Date,Boolean,Float
from sqlalchemy.orm import relationship
from database import Base
import datetime 
from uuid import uuid4


class Teacher(Base):
    __tablename__ = "teacher"
    
    id = Column(Integer(), primary_key=True, index=True)
    firstname = Column(VARCHAR(300))
    lastname = Column(VARCHAR(300))
    email = Column(VARCHAR(300))
    hashpassword = Column(VARCHAR(300))
    department = Column(VARCHAR(300))
    sex = Column(VARCHAR(300))
    phone = Column(BigInteger())
    address = Column(VARCHAR(300))
    date_of_birth = Column(Date, default=datetime.datetime.now())
    appointed = Column(Date, default=datetime.datetime.now())
    
    teachattendence = relationship('TeacherAttendence',back_populates='teach')
    teachissues = relationship('TeacherIssues',back_populates='teach')
    teachleaves = relationship('TeacherLeaves',back_populates='teach')
    teachsalary = relationship('TeacherSalary',back_populates='teach')
    
    
class TeacherAttendence(Base):
    __tablename__ = "teacher_attendance"
    
    regno = Column(Integer,primary_key=True,index=True)
    department = Column(VARCHAR(300))
    ondate = Column(Date, default=datetime.datetime.now())
    present = Column(Boolean(), default=True)
    teacher_id = Column(Integer, ForeignKey('teacher.id'))
    
    
    teach = relationship('Teacher', back_populates='teachattendence')
    
    
class TeacherIssues(Base):
    __tablename__ = "teacher_issues"
    
    issue_id = Column(VARCHAR(36),primary_key=True, default=uuid4,index=True)
    issue = Column(VARCHAR(300))
    type = Column(VARCHAR(100))
    teacher_id = Column(Integer, ForeignKey('teacher.id'))
    
    teach = relationship('Teacher', back_populates='teachissues') 
    
    
class TeacherLeaves(Base):
    __tablename__ = "teacher_leaves"
    
    leave_id = Column(VARCHAR(36),primary_key=True, default=uuid4, index=True)
    reason = Column(VARCHAR(300))
    no_of_days = Column(Integer(), default=1)
    teacher_id = Column(Integer, ForeignKey('teacher.id'))
    
    teach = relationship('Teacher', back_populates='teachleaves')
    
class TeacherSalary(Base):
    __tablename__ = "teacher_salary"
    
    salary_id = Column(VARCHAR(100),primary_key=True,index=True)
    total_salary = Column(Float(50), default=50000)
    PF = Column(Float(50))
    paid = Column(Boolean(), default=False)
    teacher_id = Column(Integer, ForeignKey('teacher.id'))
    
    teach = relationship('Teacher', back_populates='teachsalary')