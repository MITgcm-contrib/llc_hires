#! /bin/csh
set filesize=109517930496
set last_pickup=`ls -lt pickup.*.data | awk '$5~/'${filesize}'/{print $NF}'|head -1 `
if (-e ${last_pickup}) then
set last_meta=`echo $last_pickup | sed 's/data/meta/'`
set timestep=`awk '$1~/timeStepNumber/{printf("%010d",$4)}' $last_meta`
\ln -sf ${last_pickup} pickup.${timestep}
set last_pickupmeta=`echo $last_pickup|awk '{split($0,a,".");print a[1]"."a[2]".meta"}'`
\ln -sf ${last_pickupmeta} pickup.${timestep}.meta
endif

set newiter0=`expr $timestep \* 1`
ex - data >> /dev/null <<EOF
/niter0=
c
 niter0=${newiter0},
.
w
q
EOF
endif

\mv STDOUT.0000 stdout.${newiter0}
\rm STD*
