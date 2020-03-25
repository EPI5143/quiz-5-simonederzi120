
Libname quiz5 "c:\sas\epi 5143";


********************HINT 1************************************************;

*SPINE DATASET with unique admissions between Jan 1 2003 and December 31 2004. Formating  
"hraadmdtm" variable (new variable called "date" with only the date part, time part to be removed) ;
data unique;
set quiz5.nhrabstracts;
date=datepart(hraadmdtm);
format date date9.;
keep hraencwid hraadmdtm date;
if '01jan2003'd <= date <= '31dec2004'd then output;
run;

*Checking the dataset with admissions from Jan 1 2003 and December 31 2004 and date formatted (only date, no hours);
Proc print data=unique;
run;

*Proc sort to delete duplications: 2230 observations (no duplications found);
proc sort data=unique nodupkey;
by hraEncWID;
run;





********************HINT 2************************************************;
data diabetes;
set quiz5.nhrdiagnosis;
if hdgcd in: ('250' 'E11' 'E10') then dm=1;
else dm=0;
run;

proc print data=diabetes;/*113083 observations in this dataset, diabetes coding was checked and it was correct*/
run;

proc freq data=diabetes;
table dm;
run;



********************HINT 3************************************************;
*Flattening;
proc sort data=quiz5.nhrdiagnosis out=diag;
by hdghraencwid;
run;


data diabetes;
set diag;
by hdghraencwid;
if first.hdghraencwid then do;
dm=0; 
count=0;
end;
if hdgcd in: ('250' 'E11' 'E10') then do;
dm=1;count=count+1;end;
if last.hdghraencwid then output;
retain dm count;
run;

proc freq data=diabetes;
table dm count;
run;

********************HINT 4************************************************;


proc sort data=unique;
by hraencwid;
run; 


proc sort data=diabetes;
by hdghraencwid;
run;


*Left join. DM or COUNT coded as "missing" will be counted as 0 to be added in the denominator;
data merging;
merge unique (in=a) diabetes (in=b rename = (hdghraencwid = hraencwid ));
by hraencwid;
if a;
if dm = . then dm = 0; 
if count =. then count=0; 
run;

proc freq data=merging;
table dm;
run;


*Proportion of admissions which recorded a diagnosis of diabetes between 
Jan 1, 2003 and Dec 31 2004: 83/2,230=3.72%

dm    Frequency    Percent    Cumulative Frequency    Cumulative Percent 
0         2147       96.28          2147                      96.28 
1          83         3.72          2230                     100.00 ;


proc freq data=merging;
table dm;
run;














