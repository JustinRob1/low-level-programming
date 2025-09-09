# runTest.sh
# Author: Taylor Lloyd
# Date: June 27, 2012
#
# Conversion to RISC-V: Mehrab Mehdi Islam
# Date: June 01, 2019
#
# USAGE: ./runTest.sh LABFILE
#
# Combines the lab, test, and common execution file,
# then runs the resulting creation. All output generated
# is presented on standard output, after discarding the
# standard SPIM start message, which displays version
# info and could otherwise break tests.

rm -f testBuild.s
cat test.s > testBuild.s
cat $1 >> testBuild.s
rars nc testBuild.s me 2< /dev/null
