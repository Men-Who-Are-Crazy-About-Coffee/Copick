import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

def posgreSQL_connection(): # postgreSQL 세션메이커 생성
    try:
        DB_URL = "postgresql://"+os.environ["POSTGRESQL_USERNAME"]+":"+os.environ["POSTGRESQL_PASSWORD"]+"@"+os.environ["POSTGRESQL_HOST_URL"]+"/"+os.environ["POSTGRESQL_DB_NAME"]
        engine = create_engine(DB_URL)
        postgreSQL = sessionmaker(autocommit=False, autoflush=False, bind=engine)
        print("postgreSQL connected!")
        return postgreSQL
    except Exception as e:
        print("Error:",e)