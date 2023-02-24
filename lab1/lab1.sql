CREATE TABLE MyTable(id number, val number);

---------------------------------------------------------

BEGIN
    FOR i IN 1..10000
        LOOP
            INSERT INTO MyTable VALUES (i, DBMS_RANDOM.RANDOM());
        END LOOP;
END;


SELECT COUNT(*) FROM MyTable;
SELECT id, val FROM MyTable ORDER BY id FETCH FIRST 10 ROWS ONLY;

-------------------------------------

CREATE FUNCTION func RETURN VARCHAR IS
    even NUMBER := 0;
    odd NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO even FROM MyTable WHERE MOD(ABS(val), 2) = 0;
    SELECT COUNT(*) INTO odd FROM MyTable WHERE MOD(ABS(val), 2) = 1;

    IF even > odd THEN
        RETURN 'TRUE';
    ELSIF even < odd THEN
        RETURN 'FALSE';
    ELSE
        RETURN 'EQUAL';
    END IF;
END;


SELECT COUNT(*) FROM MyTable WHERE MOD(ABS(val), 2) = 0;
SELECT COUNT(*) FROM MyTable WHERE MOD(ABS(val), 2) = 1;
SELECT func FROM DUAL;

--------------------------------------------

CREATE OR REPLACE FUNCTION create_insert(table_name VARCHAR, id NUMBER, val NUMBER) RETURN VARCHAR IS
BEGIN
    RETURN UTL_LMS.FORMAT_MESSAGE('INSERT INTO %s (id, val) VALUES (%d, %d)', table_name, TO_CHAR(id),
        TO_CHAR(val));
END;


SELECT create_insert('MyTable', 10002, 10002) FROM DUAL;

---------------------------------------------------------------

CREATE OR REPLACE PROCEDURE insert_proc(table_name VARCHAR, id NUMBER, val NUMBER) IS
BEGIN
    EXECUTE IMMEDIATE create_insert(table_name,id, val);
END;

BEGIN
    insert_proc('MyTable', 10003, 10003);
END;

SELECT * FROM MyTable WHERE id=10003;


CREATE PROCEDURE update_proc(table_name VARCHAR, id NUMBER, val NUMBER) IS
BEGIN
    EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('UPDATE %s SET val=%d WHERE id=%d', table_name, TO_CHAR(val), TO_CHAR(id));
END;

BEGIN
    update_proc('MyTable', 10003, 123456);
END;

SELECT * FROM MyTable WHERE id=10003;


CREATE OR REPLACE PROCEDURE delete_proc(table_name VARCHAR, id NUMBER) IS
BEGIN
    EXECUTE IMMEDIATE UTL_LMS.FORMAT_MESSAGE('DELETE FROM %s WHERE id=%d', table_name, TO_CHAR(id));
END;

BEGIN
    delete_proc('MyTable',10003);
END;

SELECT * FROM MyTable WHERE id=10003;

-----------------------------------------------------------------------

CREATE OR REPLACE FUNCTION annual_salary(salary NUMBER, bonus NUMBER) RETURN NUMBER IS
    incorrect_value EXCEPTION;
BEGIN
    IF bonus < 0 OR salary < 0 THEN
        RAISE incorrect_value;
    END IF;

    RETURN (1 + bonus / 100) * 12 * salary;

    EXCEPTION
        WHEN incorrect_value THEN
            RETURN NULL;
        WHEN INVALID_NUMBER THEN
            RETURN NULL;
        WHEN VALUE_ERROR THEN
            RETURN NULL;
END;

SELECT annual_salary(10, 10) FROM DUAL;
