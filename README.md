My goal was to make a function which produced JSON from a given table and would grab surrounding tables using the foreign key constraints. It also takes a multiline string and will convert it into a string array. 

The COMMENT table has a foreign key of REPORT_TYPE_CK, which two columns, REPORT_TYPE_CK and REPORT_NAME.

{"COMMENT":[{"REPORT_TYPE":[{"REPORT_TYPE_CK":"21","REPORT_NAME":"Debit Transaction"}],"RECORD_CK":"285","COMMENT_CK":"23","CONTENT":"This is a test comment for Debit Transaction record.","CREATE_DATE":"22/02/2016 13:54:27","CREATED_BY":"user1"},{"REPORT_TYPE":[{"REPORT_TYPE_CK":"21","REPORT_NAME":"Debit Transaction"}],"RECORD_CK":"285","COMMENT_CK":"41","CONTENT":"Test Comment #2","CREATE_DATE":"23/02/2016 14:12:02","CREATED_BY":"user1"},{"REPORT_TYPE":[{"REPORT_TYPE_CK":"21","REPORT_NAME":"Debit Transaction"}],"RECORD_CK":"285","COMMENT_CK":"42","CONTENT":[ "1234567890", "1234567890", "1234567890" ],"CREATE_DATE":"23/02/2016 14:13:35","CREATED_BY":"user1"}]}

Which validates and looks like:

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
        "CONTENT": [ "1234567890", "1234567890", "1234567890" ],
        "CREATE_DATE": "23/02/2016 14:13:35",
        "CREATED_BY": "user1"
    }]
}



-- the following code examples contributed to this project
-- https://community.oracle.com/thread/1004502?tstart=0
-- http://www.talkapex.com/2009/06/how-to-quickly-append-varchar2-to-clob.html
-- https://community.oracle.com/thread/870028?tstart=0
-- http://docs.oracle.com/cd/B28359_01/appdev.111/b28370/dynamic.htm#BHCIBJBG
