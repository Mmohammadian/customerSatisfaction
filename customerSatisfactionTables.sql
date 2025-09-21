  CREATE TABLE TB_FEEDBACK_QUESTION 
   (	ID NUMBER, 
	FK_FLK_FQS_TYPE NUMBER CONSTRAINT FQS_FK_FLK_FQS_TYPE_NN NOT NULL ENABLE, 
	FK_RTP NUMBER CONSTRAINT FQS_FK_RTP_NN NOT NULL ENABLE, 
	QUESTION VARCHAR2(200 CHAR) CONSTRAINT FQS_DESCRIPTION_NN NOT NULL ENABLE, 
	IS_ACTIVE NUMBER DEFAULT 1 CONSTRAINT FQS_IS_ACTIVE_NN NOT NULL ENABLE, 
	DEACTIVE_DATE DATE, 
	CREATED_BY VARCHAR2(70) CONSTRAINT FQS_CREATED_BY_NN NOT NULL ENABLE, 
	CREATED_DATE DATE CONSTRAINT FQS_CREATED_DATE_NN NOT NULL ENABLE, 
	UPDATED_BY VARCHAR2(70), 
	UPDATED_DATE DATE, 
	APP_ID NUMBER, 
	 CONSTRAINT PK_FQS PRIMARY KEY (ID)
  USING INDEX  ENABLE
   ) ;

  ALTER TABLE TB_FEEDBACK_QUESTION ADD CONSTRAINT FK_FQS_FK_RTP FOREIGN KEY (FK_RTP)
	  REFERENCES TB_RELEASE_TYPE (ID) ENABLE;

  CREATE INDEX IX_FQS_APP_ID ON TB_FEEDBACK_QUESTION (IS_ACTIVE, FK_FLK_FQS_TYPE, APP_ID, DEACTIVE_DATE) 
  ;

  CREATE INDEX IX_FQS_RTP ON TB_FEEDBACK_QUESTION (FK_RTP) 
  ;

   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.ID IS 'Primary key';
   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.FK_FLK_FQS_TYPE IS 'نوع سوال چیست (نظر سنجی 1/ رضایت مشتری 2)';
   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.FK_RTP IS 'نوع سوال tb_release_type';
   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.QUESTION IS 'متن سوال';
   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.IS_ACTIVE IS 'فعال (بله 1 / خیر 0)';
   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.CREATED_BY IS 'ایجاد کننده';
   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.CREATED_DATE IS 'تاریخ ایجاد';
   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.UPDATED_BY IS 'آخرین ویرایش کننده';
   COMMENT ON COLUMN TB_FEEDBACK_QUESTION.UPDATED_DATE IS 'تاریخ آخرین ویرایش';
   COMMENT ON TABLE TB_FEEDBACK_QUESTION  IS 'جدول سوالات از پیش تعیین شده fqs';

create sequence sq_feedback_question start with 1 nocycle nocache order;

CREATE OR REPLACE EDITIONABLE TRIGGER TRG_FEEDBACK_QUESTION 
before insert or update 
on tb_feedback_question
for each row 

begin
    if inserting then 
        if :new.id is null then 
           :new.id := sq_feedback_question.nextval;
        end if;
        :new.created_by := nvl(v('APP_USER'),user);
        :new.created_date := sysdate;
    end if;
    
    if updating then 
        :new.updated_by := nvl(v('APP_USER'),user);
        :new.updated_date := sysdate;
    end if;
    
    if :new.is_active = 0 then 
        :new.deactive_date := sysdate;
    elsif :new.is_active = 1 then 
        :new.deactive_date := null;
    end if;
    :new.deactive_date := trunc(:new.deactive_date);
end;
/
ALTER TRIGGER TRG_FEEDBACK_QUESTION ENABLE;


  CREATE TABLE TB_FEEDBACK_OPTIONS 
   (	ID NUMBER, 
	FK_FQS NUMBER CONSTRAINT FK_OPT_FK_FQS_NN NOT NULL ENABLE, 
	ANSWER VARCHAR2(200 CHAR) CONSTRAINT OPT_ANSWER_NN NOT NULL ENABLE, 
	VOID_DATE DATE, 
	HAVE_FILE NUMBER(1,0) DEFAULT 0 CONSTRAINT ANS_HAVE_FILE_NN NOT NULL ENABLE, 
	HAVE_DESCRIPTION NUMBER(1,0) DEFAULT 0 CONSTRAINT ANS_HAVE_DESCRIPTION_NN NOT NULL ENABLE, 
	CREATED_BY VARCHAR2(70) CONSTRAINT A2Q_CREATED_BY_NN NOT NULL ENABLE, 
	CREATED_DATE DATE CONSTRAINT A2Q_CREATED_DATE_NN NOT NULL ENABLE, 
	UPDATED_BY VARCHAR2(70), 
	UPDATED_DATE DATE, 
	 CONSTRAINT PK_OPT PRIMARY KEY (ID)
  USING INDEX  ENABLE
   ) ;

  ALTER TABLE TB_FEEDBACK_OPTIONS ADD CONSTRAINT FK_OPT_FK_FQS FOREIGN KEY (FK_FQS)
	  REFERENCES TB_FEEDBACK_QUESTION (ID) ENABLE;

  CREATE INDEX IX_OPT_FK_FQS ON TB_FEEDBACK_OPTIONS (FK_FQS, VOID_DATE) 
  ;

   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.ID IS 'Primary key';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.FK_FQS IS 'سوال مربوط به منو tb_feedback_question';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.ANSWER IS 'پاسخ به سوال (گزینه پاسخ)';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.VOID_DATE IS 'تاریخ غیر فعال شدن منو';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.HAVE_FILE IS 'آیا نیاز به فایل دارد؟';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.HAVE_DESCRIPTION IS 'آیا نیاز به توضیحات دارد؟';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.CREATED_BY IS 'ایجاد کننده';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.CREATED_DATE IS 'تاریخ ایجاد';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.UPDATED_BY IS 'آخرین ویرایش کننده';
   COMMENT ON COLUMN TB_FEEDBACK_OPTIONS.UPDATED_DATE IS 'تاریخ آخرین ویرایش';
   COMMENT ON TABLE TB_FEEDBACK_OPTIONS  IS 'جدول گزینه های هر سوال';

create sequence sq_feedback_options start with 1 nocycle nocache order;

CREATE OR REPLACE EDITIONABLE TRIGGER TRG_FEEDBACK_OPTIONS 
before insert or update 
on tb_feedback_options
for each row 

begin
    if inserting then 
        if :new.id is null then  
            :new.id := sq_feedback_options.nextval;
        end if;
        
        :new.created_by := nvl(v('APP_USER'),user);
        :new.created_date := sysdate;
    end if;
    
    if updating then 
        :new.updated_by := nvl(v('APP_USER'),user);
        :new.updated_date := sysdate;
    end if;
end;
/
ALTER TRIGGER TRG_FEEDBACK_OPTIONS ENABLE;


  CREATE TABLE TB_FEEDBACK 
   (	ID NUMBER, 
	FK_F2U NUMBER, 
	FK_FQS NUMBER, 
	APP_ID NUMBER CONSTRAINT C_FED_APP_ID_NN NOT NULL ENABLE, 
	PAGE_ID NUMBER CONSTRAINT C_FED_PAGE_ID_NN NOT NULL ENABLE, 
	DESCRIPTION VARCHAR2(1000 CHAR), 
	RATING NUMBER, 
	STATUS NUMBER DEFAULT 0 CONSTRAINT C_FED_FEEDBACK_STATUS_NN NOT NULL ENABLE, 
	FEEDBACK_DATE DATE DEFAULT sysdate CONSTRAINT FED_FEEDBACK_DATE_NN NOT NULL ENABLE, 
	HTTP_USER_AGENT VARCHAR2(200 CHAR) CONSTRAINT FED_HTTP_USER_AGENT_NN NOT NULL ENABLE, 
	HTTP_HOST VARCHAR2(100) CONSTRAINT FED_HTTP_HOST_NN NOT NULL ENABLE, 
	IP_ADDRESS VARCHAR2(20), 
	FK_USER_FED NUMBER CONSTRAINT FED_FK_FEEDBACK_USER_NN NOT NULL ENABLE, 
	 CONSTRAINT C_FED_FQS_OR_F2U CHECK ((fk_f2u is not null and fk_fqs is null) or (fk_f2u is null and fk_fqs is not null)) ENABLE, 
	 CONSTRAINT C_FEEDBACK_RATING_NN CHECK (FK_FQS IS NOT NULL AND RATING IS NOT NULL) ENABLE, 
	 CONSTRAINT PK_FED PRIMARY KEY (ID)
  USING INDEX  ENABLE
   ) ;

  ALTER TABLE TB_FEEDBACK ADD CONSTRAINT FK_FED_FK_F2U FOREIGN KEY (FK_F2U)
	  REFERENCES TB_FEEDBACK_QUESTION2USECASE (ID) ENABLE;
  ALTER TABLE TB_FEEDBACK ADD CONSTRAINT FK_FED_FK_FQS FOREIGN KEY (FK_FQS)
	  REFERENCES TB_FEEDBACK_QUESTION (ID) ENABLE;
  ALTER TABLE TB_FEEDBACK ADD CONSTRAINT FK_FED_FK_FEEDBACK_USER FOREIGN KEY (FK_USER_FED)
	  REFERENCES TB_USER (ID) ENABLE;

  CREATE INDEX IX_FED_APP_PAGE ON TB_FEEDBACK (FK_FQS, APP_ID, PAGE_ID) 
  ;

  CREATE INDEX IX_FED_FEEDBACK_RATING ON TB_FEEDBACK (FK_FQS, RATING, FK_USER_FED) 
  ;

  CREATE INDEX IX_FED_FEEDBACK_USER ON TB_FEEDBACK (FK_USER_FED) 
  ;

   COMMENT ON COLUMN TB_FEEDBACK.ID IS 'Primary key';
   COMMENT ON COLUMN TB_FEEDBACK.FK_F2U IS 'سوال از جدول سوالات فرم برای واحد همکار tb_feedback_question2usecase';
   COMMENT ON COLUMN TB_FEEDBACK.FK_FQS IS 'پاسخ به نظرسنجی';
   COMMENT ON COLUMN TB_FEEDBACK.APP_ID IS 'شماره اپلیکیشن';
   COMMENT ON COLUMN TB_FEEDBACK.PAGE_ID IS 'شماره صفحه ';
   COMMENT ON COLUMN TB_FEEDBACK.DESCRIPTION IS 'نظر کاربر';
   COMMENT ON COLUMN TB_FEEDBACK.RATING IS 'امتیاز';
   COMMENT ON COLUMN TB_FEEDBACK.STATUS IS 'وضعیت';
   COMMENT ON COLUMN TB_FEEDBACK.FEEDBACK_DATE IS 'تاریخ اعلام بازخورد';
   COMMENT ON COLUMN TB_FEEDBACK.HTTP_USER_AGENT IS 'مرورگر';
   COMMENT ON COLUMN TB_FEEDBACK.HTTP_HOST IS 'آدرس سامانه';
   COMMENT ON COLUMN TB_FEEDBACK.IP_ADDRESS IS 'آدرس ip کاربر';
   COMMENT ON TABLE TB_FEEDBACK  IS 'جدول بازخورد واحد های همکار نسبت به منو fed';


create sequence sq_feedback start with 1 nocycle nocache order;

CREATE OR REPLACE EDITIONABLE TRIGGER TRG_FEEDBACK 
before insert or update 
on tb_feedback
for each row 

begin
    if inserting then 
        if :new.id is null then 
           :new.id := sq_feedback.nextval;
        end if;
        :new.http_host := apex_util.host_url('SCRIPT');
        :new.http_user_agent := owa_util.get_cgi_env('HTTP_USER_AGENT');
        :new.ip_address := nvl(owa_util.get_cgi_env('X-FORWARDED-FOR'),owa_util.get_cgi_env('REMOTE_ADDR'));
    end if;
    
    /* if updating and :new.is_approved is not null then  
        :new.approved_http_host := apex_util.host_url('SCRIPT');
        :new.approved_http_user_agent := owa_util.get_cgi_env('HTTP_USER_AGENT');
        :new.approved_ip_address := nvl(owa_util.get_cgi_env('X-FORWARDED-FOR'),owa_util.get_cgi_env('REMOTE_ADDR'));
    end if; */
end;
/
ALTER TRIGGER TRG_FEEDBACK ENABLE;


  CREATE TABLE TB_FEEDBACK_DETAIL 
   (	ID NUMBER, 
	FK_FED NUMBER CONSTRAINT C_FDD_FK_FED_NN NOT NULL ENABLE, 
	FK_OPT NUMBER CONSTRAINT C_FDD_FK_OPT_NN NOT NULL ENABLE, 
	REGISTER_DATE DATE DEFAULT sysdate CONSTRAINT FDD_FEEDBACK_DATE_NN NOT NULL ENABLE, 
	 CONSTRAINT PK_FDD PRIMARY KEY (ID)
  USING INDEX  ENABLE
   ) ;

  ALTER TABLE TB_FEEDBACK_DETAIL ADD CONSTRAINT FK_FDD_FK_FED FOREIGN KEY (FK_FED)
	  REFERENCES TB_FEEDBACK (ID) ENABLE;
  ALTER TABLE TB_FEEDBACK_DETAIL ADD CONSTRAINT FK_FDD_FK_OPT FOREIGN KEY (FK_OPT)
	  REFERENCES TB_FEEDBACK_OPTIONS (ID) ENABLE;

  CREATE INDEX IX_FDD_FED ON TB_FEEDBACK_DETAIL (FK_FED, FK_OPT) 
  ;

   COMMENT ON COLUMN TB_FEEDBACK_DETAIL.ID IS 'Primary key';
   COMMENT ON COLUMN TB_FEEDBACK_DETAIL.FK_FED IS 'نظر سنجی';
   COMMENT ON COLUMN TB_FEEDBACK_DETAIL.FK_OPT IS 'گزینه انتخاب شده';
   COMMENT ON COLUMN TB_FEEDBACK_DETAIL.REGISTER_DATE IS 'تاریخ انتخاب گزینه';
   COMMENT ON TABLE TB_FEEDBACK_DETAIL  IS 'جدول لیست گزینه های انتخاب شده جهت نظر سنجی fdd';

create sequence sq_feedback_detail start with 1 nocycle nocache order; 

CREATE OR REPLACE EDITIONABLE TRIGGER TRG_FEEDBACK_DETAIL 
before insert or update 
on tb_feedback_detail
for each row 

begin
    if inserting then 
        if :new.id is null then 
           :new.id := sq_feedback_detail.nextval;
           :new.REGISTER_DATE := sysdate;
        end if;
    end if;
end;
/
ALTER TRIGGER TRG_FEEDBACK_DETAIL ENABLE;