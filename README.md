My goal was to make a function which produced JSON from a given table and would grab surrounding tables using the foreign key constraints. It also takes a multiline string and will convert it into a string array. 

The output can seen from this example:

<pre>
SET SERVEROUTPUT ON
BEGIN
  DBMS_OUTPUT.PUT_LINE(PKG_JSON.GET_JSON(1, 'COMMENT'));
END;
</pre>

<pre>
{
    "COMMENT": [{
        "REPORT_TYPE": [{
            "REPORT_TYPE_CK": "21",
            "REPORT_NAME": "Debit Transaction"
        }],
        "RECORD_CK": "285",
        "COMMENT_CK": "23",
        "CONTENT": "This is a test comment for Debit Transaction record.",
        "CREATE_DATE": "22/02/2016 13:54:27",
        "CREATED_BY": "user1"
    }, {
        "REPORT_TYPE": [{
            "REPORT_TYPE_CK": "21",
            "REPORT_NAME": "Debit Transaction"
        }],
        "RECORD_CK": "285",
        "COMMENT_CK": "41",
        "CONTENT": "Test Comment #2",
        "CREATE_DATE": "23/02/2016 14:12:02",
        "CREATED_BY": "user1"
    }, {
        "REPORT_TYPE": [{
            "REPORT_TYPE_CK": "21",
            "REPORT_NAME": "Debit Transaction"
        }],
        "RECORD_CK": "285",
        "COMMENT_CK": "42",
        "CONTENT": ["1234567890", "1234567890", "1234567890"],
        "CREATE_DATE": "23/02/2016 14:13:35",
        "CREATED_BY": "user1"
    }]
}
</pre>

The COMMENT table has a foreign key of REPORT_TYPE_CK from the REPORT_TYPE table. This table has two columns, REPORT_TYPE_CK and REPORT_NAME.

If that table also had foreign keys, the function would keep drilling down until it had resolved all foreign keys it could detect. 
It makes a couple of simple assumptions. The column names of the source table and the constraint table match. It also assumes you want the entire contents of the constraint table. 
