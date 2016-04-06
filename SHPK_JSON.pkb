CREATE OR REPLACE PACKAGE BODY SHPK_JSON as
    FUNCTION SHF_GET_JSON(p_first NUMBER DEFAULT 1, p_table VARCHAR2, p_where VARCHAR2 DEfAULT NULL) RETURN CLOB
    IS result CLOB;
      v_v_val     VARCHAR2(4000);
      v_n_val     NUMBER;
      v_d_val     DATE;
      v_ret       NUMBER;
      c           NUMBER;
      d           NUMBER;
      col_cnt     INTEGER;
      f           BOOLEAN;
      rec_tab     DBMS_SQL.DESC_TAB;
      col_num     NUMBER;
      v_rowcount  NUMBER := 0;
      TYPE foreignkey IS TABLE of VARCHAR2(30) INDEX BY VARCHAR2(30);
      foreignkeys foreignkey;
      foreignColumn  VARCHAR2(30);
      foreignTable  VARCHAR2(30);
      TYPE cur IS REF CURSOR;
      v_cur   cur;    
    BEGIN
-- create a cursor
      c := DBMS_SQL.OPEN_CURSOR;
      -- parse the SQL statement into the cursor
      v_v_val := 'SELECT * FROM ' || p_table;
      -- add optional where clause
      if (p_where IS NOT NULL) THEN
        v_v_val := v_v_val || ' ' || 'WHERE ' || p_where;
      end if;
      DBMS_SQL.PARSE(c, v_v_val, DBMS_SQL.NATIVE);
      -- execute the cursor
      d := DBMS_SQL.EXECUTE(c);
      
      -- if this is the TOP result, we want to place the outer blocks
      if p_first = 1 THEN
        result := result || '{';
        result := result || '"' || p_table || '":[';
      END IF;
      -- Describe the columns returned by the SQL statement
      DBMS_SQL.DESCRIBE_COLUMNS(c, col_cnt, rec_tab);
      --
      -- Bind local return variables to the various columns based on their types
      FOR j in 1..col_cnt
      LOOP
        CASE rec_tab(j).col_type
          WHEN 1 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_v_val,2000); -- Varchar2
          WHEN 2 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_n_val);      -- Number
          WHEN 12 THEN DBMS_SQL.DEFINE_COLUMN(c,j,v_d_val);     -- Date
        ELSE
          DBMS_SQL.DEFINE_COLUMN(c,j,v_v_val,2000);  -- Any other type return as varchar2
        END CASE;
      END LOOP;
      --
     
     -- build a list of foreign key constraints for this table and store them in an array
     OPEN v_cur FOR 'SELECT UCC.TABLE_NAME, UCC.COLUMN_NAME FROM USER_CONSTRAINTS  UC, USER_CONS_COLUMNS UCC WHERE UC.R_CONSTRAINT_NAME = UCC.CONSTRAINT_NAME AND uc.constraint_type = ''R'' AND UC.TABLE_NAME = ''' || p_table || '''';
     LOOP
       FETCH v_cur INTO foreignTable, foreignColumn;
       EXIT WHEN v_cur%NOTFOUND;
       foreignkeys(foreignColumn) := foreignTable;
     END LOOP;
     
     CLOSE v_cur;
      
      v_rowcount := 0;

      LOOP
        -- Fetch a row of data through the cursor
        v_ret := DBMS_SQL.FETCH_ROWS(c);
        -- Exit when no more rows
        EXIT WHEN v_ret = 0;
        v_rowcount := v_rowcount + 1;
        
        IF (v_rowcount > 1) THEN result := result || ',';
        END IF;
  
        result := result || '{';
        
        -- Fetch the value of each column from the row
        FOR j in 1..col_cnt
        LOOP
        
          foreignTable := NULL;
          foreignColumn := foreignkeys.FIRST;
          
          -- check the current column to see if it in the foreignkey array
          WHILE foreignColumn IS NOT NULL LOOP
              if foreignColumn = rec_tab(j).col_name then 
                foreignTable := foreignkeys(foreignColumn);
              end if;
              foreignColumn := foreignkeys.NEXT(foreignColumn);
          END LOOP;
          
          if foreignTable IS NOT NULL THEN
            -- perform the search for the foreign key table to get its values
          
            result := result || chr(11) || '"' || foreignTable || '":[';
            DBMS_SQL.COLUMN_VALUE(c,j,v_n_val);
            result := result || SHPK_JSON.SHF_GET_JSON(0, foreignTable, rec_tab(j).col_name || ' = ' || v_n_val);
            result := result || chr(11) || ']';
          ELSE
              -- Fetch each column into the correct data type based on the description of the column
              CASE rec_tab(j).col_type
                WHEN 1  THEN DBMS_SQL.COLUMN_VALUE(c,j,v_v_val);
                    if INSTR(v_v_val, chr(10)) > 0 OR INSTR(v_v_val, chr(13)) > 0 THEN
                        result := result || chr(11) || '"' || rec_tab(j).col_name || '":' || TO_CHAR(SHPK_JSON.SHF_STRING_ARRAY(v_v_val)) || '';
                    ELSE
                        result := result || chr(11) || '"' || rec_tab(j).col_name || '":"' || v_v_val || '"';
                    END IF;
                WHEN 2  THEN DBMS_SQL.COLUMN_VALUE(c,j,v_n_val);
                             result := result || chr(11) || '"' || rec_tab(j).col_name || '":"' || v_n_val || '"';
                WHEN 12 THEN DBMS_SQL.COLUMN_VALUE(c,j,v_d_val);
                             result := result || chr(11) || '"' || rec_tab(j).col_name || '":"' || to_char(v_d_val,'DD/MM/YYYY HH24:MI:SS') || '"';
              ELSE
                DBMS_SQL.COLUMN_VALUE(c,j,v_v_val);
                result := result || chr(11) || '"' || rec_tab(j).col_name || '":"' || v_v_val || '"';
              END CASE;
          END IF;
          
          IF (j < col_cnt) THEN result := result || ',';
          END IF;
          
        END LOOP;

        result := result || '}';
        
      END LOOP;
      
      if p_first = 1 THEN
          result := result || ']}';
      END IF;      
      
      -- Close the cursor now we have finished with it
      DBMS_SQL.CLOSE_CURSOR(c);
      
      return result;
    END;

    FUNCTION SHF_STRING_ARRAY(p_line VARCHAR2) RETURN CLOB
    IS result CLOB;
    BEGIN
        result := '["' || REPLACE(REPLACE(REPLACE(p_line, chr(13), chr(10)), chr(10) || chr(10), chr(10)), chr(10) , '", "' ) || '"]';           
        return result;
    END;  
END SHPK_JSON;

-- the following code examples contributed to this project
-- https://community.oracle.com/thread/1004502?tstart=0
-- http://www.talkapex.com/2009/06/how-to-quickly-append-varchar2-to-clob.html
-- https://community.oracle.com/thread/870028?tstart=0
-- http://docs.oracle.com/cd/B28359_01/appdev.111/b28370/dynamic.htm#BHCIBJBG
