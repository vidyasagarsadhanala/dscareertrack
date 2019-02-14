/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */

SELECT * FROM `Facilities` Where membercost > 0;

/* Q2: How many facilities do not charge a fee to members? */

SELECT * FROM `Facilities` Where membercost = 0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT name,
       monthlymaintenance,
       membercost,
       facid,
       0.20 * monthlymaintenance     AS pct_maint_cost
  FROM  Facilities
 WHERE membercost > 0 AND membercost < 0.20 * monthlymaintenance;

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */

SELECT *
  FROM Facilities
 WHERE facid IN ('1', '5');


/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */

SELECT CASE
             WHEN monthlymaintenance > 100 THEN 'Expensive'
             WHEN monthlymaintenance < 100 THEN 'Cheap'
             ELSE NULL
         END    AS monthly_maint_type,
         name,
         monthlymaintenance
    FROM  Facilities
   WHERE 1 = 1
ORDER BY 3 DESC;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */

SELECT firstname, surname AS lastname
  FROM Members
 WHERE joindate = (SELECT MAX (joindate) FROM Members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT CONCAT (CONCAT (F.name, " - "),
                 CONCAT (M.firstname, " - "),
                 (M.surname))    AS TENNIS_MEMBER_LIST
    FROM Facilities F, Members M, Bookings B
   WHERE     1 = 1
         AND B.facid = F.facid
         AND B.memid = M.memid
         AND F.name LIKE ('Tennis%Court%')
GROUP BY F.name, M.firstname, M.surname
ORDER BY M.firstname, M.surname;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

   SELECT F.name,
         CASE
             WHEN M.memid = 0 THEN M.firstname
             ELSE CONCAT (CONCAT (M.firstname, " "), M.surname)
         END      AS member_name,
         F.membercost,
         F.guestcost,
         (CASE
              WHEN M.memid = 0 THEN F.guestcost * B.slots
              ELSE F.membercost * B.slots
          END)    AS cost
    FROM Facilities F, Bookings B, Members M
   WHERE     1 = 1
         AND B.facid = F.facid
         AND B.memid = M.memid
         AND STR_TO_DATE (B.starttime, '%Y-%m-%d') = '2012-09-14'
         AND (CASE
                  WHEN M.memid = 0 THEN F.guestcost * B.slots
                  ELSE F.membercost * B.slots
              END) >
             30
	ORDER BY (CASE
              WHEN M.memid = 0 THEN F.guestcost * B.slots
              ELSE membercost * B.slots
          END) DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

  SELECT F.name,
         CASE
             WHEN M.memid = 0 THEN M.firstname
             ELSE CONCAT (CONCAT (M.firstname, " "), M.surname)
         END      AS member_name,
         F.membercost,
         F.guestcost,
         (CASE
              WHEN M.memid = 0 THEN F.guestcost * B2.slots
              ELSE F.membercost * B2.slots
          END)    AS cost
    FROM Facilities F,
         (SELECT B.slots, B.memid, B.facid
            FROM Bookings B
           WHERE STR_TO_DATE (B.starttime, '%Y-%m-%d') = '2012-09-14') B2,
         Members   M
   WHERE     1 = 1
         AND B2.facid = F.facid
         AND B2.memid = M.memid
         AND (CASE
                  WHEN M.memid = 0 THEN F.guestcost * B2.slots
                  ELSE F.membercost * B2.slots
              END) >
             30
ORDER BY (CASE
              WHEN M.memid = 0 THEN F.guestcost * B2.slots
              ELSE membercost * B2.slots
          END) DESC;
		  
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT F.name,
     SUM(CASE
              WHEN M.memid = 0 THEN F.guestcost * B2.slots
              ELSE F.membercost * B2.slots
          END)    AS revenue
    FROM Facilities F,
         Bookings B2,
         Members   M
   WHERE     1 = 1
         AND B2.facid = F.facid
         AND B2.memid = M.memid
GROUP BY F.name HAVING SUM(CASE
              WHEN M.memid = 0 THEN F.guestcost * B2.slots
              ELSE F.membercost * B2.slots
          END) < 1000
ORDER BY 2 DESC;