import os
from sqlalchemy import create_engine, text
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

def posgreSQL_save_sequence(result_index, file_name,result_normal,result_flaw, db_session):
    try:
        file_path = os.environ["AWS_S3_URL"]+"/result/"+result_index+"/sequence/"+file_name
        db_session.execute(text("INSERT INTO sequence(result_index,sequence_image,result_normal,result_flaw) VALUES(%s,\'%s\',%d,%d)"
            %(result_index,file_path,result_normal,result_flaw)))
    except Exception as e:
        print("Error(posgreSQL_save_sequence):",e)
        
def posgreSQL_save_flaw(result_index, file_name, db_session):
    try:
        file_path = os.environ["AWS_S3_URL"]+"/result/"+result_index+"/flaw/"+file_name
        db_session.execute(text("INSERT INTO flaw(result_index,flaw_image,is_deleted,reg_date) VALUES(%s,\'%s\',%s,%s)"
            %(result_index,file_path,"false","now()")))
    except Exception as e:
        print("Error(posgreSQL_save_flaw):",e)