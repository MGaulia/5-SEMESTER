PROC IMPORT DATAFILE='/home/u45871880/high_school_modified.csv'
	DBMS=CSV
	OUT=data;
	GETNAMES=YES;
RUN;

PROC PRINT DATA=data;
RUN;

/* Hipotezė apie krypties koeficientų lygybę*/
PROC SORT data=DATA out=_ScatterTaskData;
	BY test_prep_course;
RUN;

PROC SGPLOT data=_ScatterTaskData;
	by test_prep_course;
	SCATTER x=attendance y=result / group=parental_education;
	REG x=attendance y=result / group=parental_education;
	XAXIS grid;
	YAXIS grid;
RUN;

	
PROC SGPLOT data=_ScatterTaskData;
	by test_prep_course;
	SCATTER x=daily_study_hours y=result / group=parental_education;
	REG x=daily_study_hours y=result / group=parental_education;
	XAXIS grid;
	YAXIS grid;
RUN;


PROC GLM DATA=data plots=NONE;
CLASS combined;
MODEL result = combined attendance daily_study_hours combined*attendance combined*daily_study_hours / SS3; 
RUN;


/* Hipotezė apie faktorių sąveikos nebuvimą*/
PROC GLM DATA=data; CLASS parental_education test_prep_course;
MODEL result = parental_education test_prep_course parental_education*test_prep_course daily_study_hours attendance / SS3; 
RUN;



/* Modelio prielaidos */
/* Vidurkių palyginimai */
PROC GLM DATA=data plots=ALL;
CLASS parental_education test_prep_course;
MODEL result = parental_education test_prep_course attendance daily_study_hours / SS3; 
LSMEANS parental_education / stderr pdiff adjust=bon;
OUTPUT out=res residual=liekanos;
RUN;


/* Normalumo testas */
PROC UNIVARIATE data=res normal;
VAR liekanos;
RUN;


/* Dispersijų lygybės testas */
PROC GLM DATA=data plots=none;
CLASS combined;
MODEL result = combined;
MEANS combined / HOVTEST=levene(type=abs);
RUN;

/* Abi kovariantės statistiškai nereikšmingos */
/* Naudojamas modelis be kovariančių */
PROC GLM DATA=data plots=ALL;
CLASS parental_education test_prep_course;
MODEL result = parental_education test_prep_course/ SS3; 
LSMEANS parental_education / stderr pdiff adjust=bon;
OUTPUT out=res residual=liekanos;
RUN;
