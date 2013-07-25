#!/bin/bash

WRKDIR=$(pwd)
CLASSPATH=$CLASSPATH:${WRKDIR}
PKGDIR=${WRKDIR}/nl/gridpoint/test/gameoflife
MFTFILE=${WRKDIR}/manifest.txt
JARFILE=${WRKDIR}/gameoflife.jar
BKPDIR=${WRKDIR}/backup/$(date '+%Y%m%d%H%M%S')

mkdir -p ${PKGDIR} 1>/dev/null 2>&1
if [ ! $? -eq 0 ]
then
echo $(date '+%Y-%m-%d %H:%M:%S') ERROR: An error occurred while creating directory: \'${PKGDIR}\'. Exiting!
exit $?
fi
javac -cp ${CLASSPATH} Cell.java
if [ ! $? -eq 0 ]
then
echo $(date '+%Y-%m-%d %H:%M:%S') ERROR: An error occurred while compiling Cell.java. Exiting!
exit $?
fi
mv Cell.class ${PKGDIR}
javac -cp ${CLASSPATH} Space.java
if [ ! $? -eq 0 ]
then
echo $(date '+%Y-%m-%d %H:%M:%S') ERROR: An error occurred while compiling Space.java. Exiting!
exit $?
fi
mv Space.class ${PKGDIR}
javac -cp ${CLASSPATH} Game.java
if [ ! $? -eq 0 ]
then
echo $(date '+%Y-%m-%d %H:%M:%S') ERROR: An error occurred while compiling Game.java. Exiting!
exit $?
fi
mv Game.class ${PKGDIR}
javac -cp ${CLASSPATH} Main.java
if [ ! $? -eq 0 ]
then
echo $(date '+%Y-%m-%d %H:%M:%S') ERROR: An error occurred while compiling Main.java. Exiting!
exit $?
fi
mv Main.class ${PKGDIR}
echo "Manifest-Version: 1.0" >${MFTFILE}
echo "Created-By: 1.6.0 (Sun Microsystems Inc.)" >>${MFTFILE}
echo "Main-Class: nl.gridpoint.test.gameoflife.Main" >>${MFTFILE}
jar -cfm ${JARFILE} ${MFTFILE} nl *.java
if [ ! $? -eq 0 ]
then
echo $(date '+%Y-%m-%d %H:%M:%S') ERROR: An error occurred while creating jar-file: \'${JARFILE}\'. Exiting!
exit $?
fi
rm ${MFTFILE}
rm -rf nl
if [ ! $? -eq 0 ]
then
echo $(date '+%Y-%m-%d %H:%M:%S') ERROR: An error occurred while running jar-file: \'${JARFILE}\'. Exiting!
exit $?
fi
mkdir -p ${BKPDIR} 1>/dev/null 2>&1
if [ ! $? -eq 0 ]
then
echo $(date '+%Y-%m-%d %H:%M:%S') ERROR: An error occurred while creating directory: \'${BKPDIR}\'. Exiting!
exit $?
fi
cp -p *.java *.sh ${BKPDIR}/
