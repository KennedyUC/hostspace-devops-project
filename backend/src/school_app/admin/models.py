from sqlalchemy import Column, Integer, String, BigInteger, DateTime
from sqlalchemy.ext.declarative import declarative_base
import datetime

Base = declarative_base()

class Admin(Base):
    __tablename__ = "admin"
    
    id = Column(Integer, primary_key=True, index=True)
    firstname = Column(String(300))
    lastname = Column(String(300))
    email = Column(String(300))
    hashpassword = Column(String(300))
    sex = Column(String(300))
    phone = Column(BigInteger)
    appointed = Column(DateTime, default=datetime.datetime.now)