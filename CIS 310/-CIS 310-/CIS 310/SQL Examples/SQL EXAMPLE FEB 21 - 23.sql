--1
SELECT    C.CUSTOMER_NAME, C.CUSTOMER_NUM, O.CUSTOMER_NUM,
        O.ORDER_NUM, O.ORDER_DATE
FROM    CUSTOMER C INNER JOIN ORDERS O ON C.CUSTOMER_NUM = O.CUSTOMER_NUM
ORDER BY O.ORDER_DATE

--2
SELECT    C.CUSTOMER_NAME, C.CUSTOMER_NUM, O.CUSTOMER_NUM,
        O.ORDER_NUM, O.ORDER_DATE
FROM    CUSTOMER C INNER JOIN ORDERS O
        ON C.CUSTOMER_NUM = O.CUSTOMER_NUM
WHERE    O.ORDER_DATE = '10/20/2003'
ORDER BY O.ORDER_DATE

--3
SELECT    *
FROM    ORDERS O INNER JOIN ORDER_LINE L ON O.ORDER_NUM = L.ORDER_NUM
        INNER JOIN PART P ON L.PART_NUM = P.PART_NUM
        
--4
SELECT    CUSTOMER_NAME, CUSTOMER_NUM
FROM    CUSTOMER
WHERE    CUSTOMER_NUM IN
(
    SELECT    O.CUSTOMER_NUM
    FROM    ORDERS O
    WHERE    O.ORDER_DATE = '10/20/2003'
)

--5
SELECT    C.CUSTOMER_NUM, C.CUSTOMER_NAME
FROM    CUSTOMER C
WHERE    EXISTS
        (SELECT    *
         FROM    ORDERS O
         WHERE    O.CUSTOMER_NUM = C.CUSTOMER_NUM AND
                O.ORDER_DATE = '10/20/2008')

--6
SELECT    C.CUSTOMER_NUM, C.CUSTOMER_NAME
FROM    CUSTOMER C
WHERE    C.CUSTOMER_NUM NOT IN
        (SELECT    O.CUSTOMER_NUM
         FROM    ORDERS O
         WHERE    O.ORDER_DATE = '10/20/2003')


SELECT    C.CUSTOMER_NUM, C.CUSTOMER_NAME
FROM    CUSTOMER C
WHERE    C.CUSTOMER_NUM IN
        (SELECT    O.CUSTOMER_NUM
         FROM    ORDERS O
         WHERE    O.ORDER_DATE <> '10/20/2003')

--7
SELECT    *
FROM    ORDERS O INNER JOIN ORDER_LINE L ON O.ORDER_NUM = L.ORDER_NUM
        INNER JOIN PART P ON L.PART_NUM = P.PART_NUM

--8
SELECT    *
FROM    ORDERS O INNER JOIN ORDER_LINE L ON O.ORDER_NUM = L.ORDER_NUM
        INNER JOIN PART P ON L.PART_NUM = P.PART_NUM
ORDER BY O.ORDER_NUM, P.CLASS

--9
SELECT    REP_NUM, LAST_NAME, FIRST_NAME
FROM    REP
WHERE    REP_NUM IN
        (SELECT    REP_NUM
         FROM    CUSTOMER
         WHERE    CREDIT_LIMIT >= 2000)    
--9.5 REPEAT 9 BUT THIS TIME RETURNS ONLY REPS WHO HAVE AT LEAST 4 CUSTOMERS
--    MEETING THE CREDIT CONDITION
--FIRST STEP, RETURN REP_NUM WHO MEET THE CONDITION, I.E., THE SUBQ
SELECT    REP_NUM, COUNT(*)
         FROM    CUSTOMER
         WHERE    CREDIT_LIMIT >= 2000
GROUP BY REP_NUM
HAVING COUNT(*) > 3



SELECT    REP_NUM, LAST_NAME, FIRST_NAME
FROM    REP
WHERE    REP_NUM IN
(
SELECT    REP_NUM
         FROM    CUSTOMER
         WHERE    CREDIT_LIMIT >= 2000
GROUP BY REP_NUM
HAVING COUNT(*) > 3
)

--10
SELECT    DISTINCT R.REP_NUM, R.LAST_NAME
FROM    REP R INNER JOIN CUSTOMER C ON R.REP_NUM = C.REP_NUM
WHERE    C.CREDIT_LIMIT >= 2000

--11
SELECT    C.CUSTOMER_NAME
FROM    CUSTOMER C INNER JOIN ORDERS O ON C.CUSTOMER_NUM = O.CUSTOMER_NUM
        INNER JOIN ORDER_LINE L ON O.ORDER_NUM = L.ORDER_NUM
        INNER JOIN PART P ON L.PART_NUM = P.PART_NUM
WHERE    P.DESCRIPTION = 'IRON'

--12
SELECT    *
FROM    PART
