REM File Name     : sample_table.sql
REM Description   : Creates a test table and inserts 1000 rows of data 

-- Use this sample table to test out the full_table_description.sql procedure 

CREATE OR REPLACE PROCEDURE test_table
AS

-- Variable Declaration

lv_count NUMBER;
lv_one   VARCHAR2(30) :='TEST ONE';
lv_two   VARCHAR2(30) :='TEST TWO';
lv_three VARCHAR2(30) :='TEST THREE';
lv_four  VARCHAR2(30) :='TEST FOUR';

BEGIN
  EXECUTE IMMEDIATE('drop table test');
  EXECUTE IMMEDIATE('Create table test(test1 varchar2(30), test2 varchar2(30), test3 varchar2(30), test4 varchar2(30)) tablespace tools');
  FOR i in 1..1000 LOOP
    insert into test (test1,test2,test3,test4) values (lv_one,lv_two,lv_three,lv_four);
  END LOOP;
END;
/ -- COMMIT 
