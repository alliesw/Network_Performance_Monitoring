Buffer-Cache-Hit-Ratio
REM Filename      : full_table_details.sql
REM Description   : Full description of your table - all constraints, indexes, comments & more 
REM Author        : Alex Shields-Weber      

-- You can use the sample_table.sql file to test out this procedure. 
-- Once the table is created, replace 'table_name' with 'test_table' in the code below. 

SET ECHO OFF 
SET TERM ON

ACCEPT table_name PROMPT "Enter table name: "
ACCEPT tab_owner PROMPT "Enter user name: "

SET HEADING ON 
SET NEWPAGE 0

TTITLE 'Table Description - Space Definition'

SPOOL tab_desc.log

BTITLE off
COLUMN nline newline

SET PAGESIZE 54
SET LINESIZE 78
SET HEADING OFF 
SET EMBEDDED OFF 
SET VERIFY OFF

ACCEPT report_comment char PROMPT 'Enter a comment to identify the system: '
SET TERMOUT OFF
SELECT 'Date - '||TO_CHAR(sysdate,'Day Ddth Month YYYY HH24:MI:SS'),
       'At   - '||'&&report_comment' nline,
       'Username - '||User nline
FROM sys.dual
/ -- (COMMIT)
PROMPT

SET EMBEDDED ON 
SET HEADING ON

COLUMN Ts FORMAT a30
COLUMN Ta FORMAT a30
COLUMN Clu FORMAT a30
COLUMN Pcf FORMAT 99999999999990
COLUMN Pcu FORMAT 99999999999990
COLUMN Int FORMAT 99,999,999,990
COLUMN Mat FORMAT 99,999,999,990
COLUMN Inx FORMAT 99,999,999,990
COLUMN Nxt FORMAT 99,999,999,990
COLUMN Mix FORMAT 99,999,999,990
COLUMN Max FORMAT 99,999,999,990
COLUMN Pci FORMAT 99999999999990
COLUMN Num FORMAT 99,999,999,990
COLUMN Blo FORMAT 99,999,999,990
COLUMN Emp FORMAT 99,999,999,990
COLUMN Avg FORMAT 99,999,999,990
COLUMN Cha FORMAT 99,999,999,990
COLUMN Rln FORMAT 99,999,999,990
COLUMN Hdg FORMAT a30 newline
SET HEADING OFF

SELECT 'Table Name' Hdg, table_name Ta,
       'Tablespace_name' Hdg, tablespace_name Ts,
       'Cluster Name' Hdg, cluster_name Clu,
       '% Free' Hdg, Pct_Free Pcf,
       '% Used' Hdg, Pct_Used Pcu,
       'Ini Trans' Hdg, Ini_Trans Int,
       'Max Trans' Hdg, Max_Trans Mat,
       'Initial Extent (K)' Hdg, Initial_Extent/1024 Inx,
       'Next Extent (K)' Hdg, Next_extent/1024 Nxt,
       'Min Extents' Hdg, Min_extents Mix,
       'Max Extents' Hdg, Max_extents Max,
       '% Increase' Hdg, Pct_Increase Pci,
       'Number of Rows' Hdg, Num_Rows Num,
       'Number of Blocks' Hdg, Blocks Blo,
       'Number of Empty Blocks' Hdg, Empty_Blocks Emp,
       'Average Space' Hdg, Avg_Space Avg,
       'Chain Count' Hdg, Chain_Cnt Cha,
       'Average Row Length' Hdg, Avg_Row_len Rln
FROM dba_tables
WHERE table_name = UPPER('&&table_name')
AND owner=UPPER('&&tab_owner')
/ -- (COMMIT)

SET HEADING ON

PROMPT
PROMPT Comments on the Table
PROMPT

SELECT COMMENTS FROM dba_tab_comments 
WHERE table_name = UPPER('&&table_name')
AND owner=UPPER('&&tab_owner')
/ -- (COMMIT)

SET HEADING ON
SET EMBEDDED OFF

COLUMN Cn FORMAT A30 HEADING 'Column Name'
COLUMN Fo FORMAT A15 HEADING 'Type'
COLUMN Nu FORMAT A8 HEADING 'Null'
COLUMN Nds FORMAT 99,999,999 HEADING 'No Distinct'
COLUMN Dfl FORMAT 9999 HEADING  'Dflt Len'
COLUMN Dfv FORMAT A40 HEADING 'Default Value'

TTITLE 'Table Description - Column Definition'

SELECT Column_name Cn, data_type ||
DECODE(Data_type,'NUMBER','('||TO_CHAR(data_precision)||DECODE(data_scale,0,'',','||TO_CHAR(data_scale))||')','VARCHAR2',
'('||TO_CHAR(Data_Length)||')','CHAR',
'('||TO_CHAR(Data_Length)||')','DATE','','LONG','','Error') Fo,
DECODE(NUllable,'Y','','NOT NULL') Nu,
Num_Distinct Nds,
Default_length Dfl,
Data_Default Dfv
FROM dba_tab_columns
WHERE table_name = UPPER('&&table_name')
AND owner=UPPER('&&tab_owner')
ORDER BY COLUMN_ID
/ -- (COMMIT)

TTITLE off

PROMPT
PROMPT TABLE CONSTRAINTS
PROMPT

SET HEADING ON

COLUMN Cn FORMAT a30 HEADING 'Primary Constraint'
COLUMN Cln FORMAT a45 HEADING 'Table.Column Name'
COLUMN Ct FORMAT a7 HEADING 'Type'
COLUMN St FORMAT a7 HEADING 'Status'
COLUMN Ro FORMAT a30 HEADING 'Ref Owner| Constraint Name'
COLUMN Se FORMAT a70 HEADING 'Criteria ' newline

BREAK ON Cn ON St

SET EMBEDDED ON

PROMPT Primary Key
PROMPT

SELECT CNS.Constraint_name Cn,
CNS.Table_name||'.'||CLS.Column_Name Cln,INITCAP(CNS.Status) St
FROM dba_constraints CNS, DBA_CONS_COLUMNS CLS
WHERE CNS.Table_name=UPPER('&&table_name')
AND CNS.Owner=UPPER('&&tab_owner')
AND CNS.Constraint_Type='P'
AND CNS.Constraint_Name=CLS.Constraint_name
ORDER BY CLS.Position
/ -- (COMMIT)

PROMPT Unique Key
PROMPT

COLUMN Cn FORMAT a30 HEADING 'Unique Key'

SELECT CNS.Constraint_name Cn,
CNS.Table_name||'.'||CLS.Column_Name Cln,
INITCAP(CNS.Status) St
FROM dba_constraints CNS, DBA_CONS_COLUMNS CLS
WHERE cns.Table_name=UPPER('&&table_name')
AND CNS.Owner=UPPER('&&tab_owner')
AND CNS.Constraint_Type='U'
AND CNS.Constraint_name=CLS.Constraint_name
ORDER BY CLS.Position
/ -- (COMMIT)

PROMPT Foreign Keys
PROMPT

COLUMN Cln FORMAT a38 HEADING 'Foreign Key' newline
COLUMN Clfn FORMAT a38 HEADING 'Parent Key'
COLUMN Cn FORMAT a40 HEADING 'Foreign Constraint'

BREAK ON Cn ON St SKIP 1

SELECT cns.constraint_name Cn,
INITCAP(CNS.Status) St,
CLS.Table_name||'.'||cls.COLUMN_name Cln,
CLF.Owner||'.'||CLf.Table_name||'.'||clf.COLUMN_name Clfn
FROM dba_constraints cns, dba_cons_COLUMNs clf, dba_cons_COLUMNs cls
WHERE cns.table_name=UPPER('&&table_name')
AND CNS.Owner=UPPER('&&tab_owner')
AND CNS.Constraint_Type='R'
AND cns.constraint_name=cls.constraint_name
AND clf.constraint_name = cns.r_constraint_name
AND clf.owner = cns.owner
AND clf.position = cls.position
ORDER BY cns.constraint_name, cls.position
/ -- (COMMIT)

PROMPT Check Constraints
PROMPT

COLUMN Cn FORMAT a40 HEADING 'Check Constraint'
COLUMN Se FORMAT a75 HEADING 'Criteria ' 

SET ARRAYSIZE 1
SET LONG 32000

SELECT constraint_name Cn,INITCAP(Status) St,
Search_Condition Se
FROM DBA_CONSTRAINTS
WHERE table_name=UPPER('&&table_name')
AND owner=UPPER('&&tab_owner')
AND Constraint_Type='C'
/ -- (COMMIT)

PROMPT View Constraints
PROMPT

COLUMN Cn FORMAT a40 HEADING 'View Constraint'
SELECT Constraint_Name Cn,
INITCAP(Status) St,
Search_Condition Se
FROM DBA_CONSTRAINTS
WHERE table_name=UPPER('&&table_name')
AND owner=UPPER('&&tab_owner')
AND Constraint_Type='V'
/ -- (COMMIT)

SPOOL OFF

SET ARRAYSIZE 30
SET NEWPAGE 1 VERIFY ON FEEDBACK 6 PAGESIZE 24 LINESIZE 80
SET HEADING ON EMBEDDED OFF TERMOUT ON ARRAYSIZE 15 LONG 80

UNDEFINE table_name
UNDEFINE tab_owner
UNDEFINE report_comment

TTITLE OFF
BTITLE OFF 
CLEAR COLUMNS

-- COMMIT 
REM End of Script
