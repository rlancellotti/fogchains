<%
cvs=[0.05, 0.1, 0.4, 0.5, 0.6, 0.7, 0.8]
%>\
########################### 1 SRC ###################################

set terminal pngcairo enhanced font "Helvetica,12"
set output "analysis/test1src_tresp.png"

st=0.1
mg1(rho, cv)=st * (1.0+((1.0+cv**2)/2.0)*(rho/(1.0-rho)))

set key top left
set xlabel "{/symbol r}"
set ylabel "Time [s]"

p [][:1] \\

%for (i, cv) in enumerate(cvs):
mg1(x, ${cv}) t "M/G/1" w l lc 7, \
"<(grep ^${cv} analysis/test1src.data)" u ($2):($6) title "CV=${cv}" w lp lc ${i+1} pt ${4+i}, \
"<(grep ^${cv} analysis/test1src.data)" u ($2):($6):($7) notitle w errorbars lc ${i+1} pt ${4+i} ${'' if i==len(cvs)-1 else ','} \\

%endfor

set output "analysis/test1src_tsrv.png"

st=0.1

set key top left
set xlabel "CoV"
set ylabel "Time [s]"

p [][] \\

%for (i, cv) in enumerate(cvs):
"<(grep ^${cv} analysis/test1src.data)" u ($1):($10) title "CV=${cv}" w lp lc ${i+1} pt ${4+i}, \
"<(grep ^${cv} analysis/test1src.data)" u ($1):($10):($11) notitle w errorbars lc ${i+1} pt ${4+i} ${'' if i==len(cvs)-1 else ','} \\

%endfor

set output "analysis/test1src_rho.png"

set key top left
set xlabel "{/symbol r}"
set ylabel "PU {/symbol r}"

p [][0:]\\

%for (i, cv) in enumerate(cvs):
"<(grep ^${cv} analysis/test1src.data)" u ($2):($12) title "CV=${cv}" w lp lc ${i+1} pt ${4+i}, \\

"<(grep ^${cv} analysis/test1src.data)" u ($2):($12):($12) notitle w errorbars lc ${i+1} pt ${4+i}, \\

%endfor

########################### 2 SRC ###################################

NSAMP=5
M=4
TS1=1.0/10.0
TS2=1.0/20.0
CV1=0.2
CV2=0.2
expLambda(lambda1,lambda2)=lambda1+lambda2
expRho(lambda1,lambda2, TS1, TS2)=(TS1*lambda1+TS2*lambda2)>1?1:(TS1*lambda1+TS2*lambda2)
expTSrv(lambda1,lambda2, TS1, TS2)=TS1*(lambda1/(lambda1+lambda2))+TS2*(lambda2/(lambda1+lambda2))

sigmaComp(w,TS,CV)=w*(TS**2+(TS*CV)**2)
expSigmaSq(lambda1,lambda2,TS1,TS2,CV1,CV2)=sigmaComp(lambda1/(lambda1+lambda2), TS1, CV1)+sigmaComp(lambda2/(lambda1+lambda2), TS2, CV2) - expTSrv(lambda1,lambda2, TS1, TS2)**2
expCVsq(lambda1,lambda2,TS1,TS2,CV1,CV2)=expSigmaSq(lambda1,lambda2,TS1,TS2,CV1,CV2)/(expTSrv(lambda1,lambda2, TS1, TS2)**2)
expTresp(lambda1,lambda2, TS1, TS2, CV1, CV2)=expTSrv(lambda1,lambda2, TS1, TS2)*(1.0+((1.0+expCVsq(lambda1,lambda2,TS1,TS2,CV1,CV2))/2.0)*(expRho(lambda1,lambda2, TS1, TS2)/(1.0-expRho(lambda1,lambda2, TS1, TS2))))

set output "analysis/test2src_rho.png"
set key top left
set dgrid3d NSAMP, NSAMP
set isosamples (NSAMP-1)*M+1, (NSAMP-1)*M+1
set xlabel "{/symbol l}_1"
set ylabel "{/symbol l}_2"
set zlabel "{/symbol r}"

sp \\

"analysis/test2src.data" u ($1):($2):($3) title "Nominal {/symbol r}" w l lc 1, \
"analysis/test2src.data" u ($1):($2):($3) notitle w p lc 1 pt 5, \\

"analysis/test2src.data" u ($1):($2):($12) title "Fog {/symbol r}" w l lc 2, \
"analysis/test2src.data" u ($1):($2):($12):($13) notitle w errorbars lc 2 pt 5, \\

expRho(x, y, TS1, TS2) title "{/symbol l}/{/symbol m}" w l lc 3


set output "analysis/test2src_tresp.png"
set key top left
set dgrid3d NSAMP, NSAMP
set isosamples (NSAMP-1)*M+1, (NSAMP-1)*M+1
set xlabel "{/symbol l}_1"
set ylabel "{/symbol l}_2"
set zlabel "Time [s]" rotate parallel
#set pm3d at b

sp [][][]\\

"analysis/test2src.data" u ($1):($2):($6) title "T_{Resp}" w l lc 1, \
"analysis/test2src.data" u ($1):($2):($6):($7) notitle w errorbars lc 1 pt 4, \\

expTresp(x, y, TS1, TS2, CV1, CV2) title "Model" w l lc 3

#"analysis/test2src.data" u ($1):($2):($10+((($10)**2+($18)**2)/2)*($1+$2)/(1-($10*($1+$2)))) title "Model PK" w l lc 2, \\

#"analysis/test2src.data" u ($1):($2):($10) title "T_{Srv}" w l lc 2, \
"analysis/test2src.data" u ($1):($2):($10):($11) notitle w errorbars lc 2 pt 5, \\

#"analysis/test2src.data" u ($1):($2):($8) title "T_{Queue}" w l lc 3, \
"analysis/test2src.data" u ($1):($2):($8):($9) notitle w errorbars lc 3 pt 6


set output "analysis/test2src_trespstddev.png"
set key top left
set dgrid3d NSAMP, NSAMP
set isosamples (NSAMP-1)*M+1, (NSAMP-1)*M+1
set xlabel "{/symbol l}_1"
set ylabel "{/symbol l}_2"
set zlabel ""
#set pm3d at b

sp [][][]\\

"analysis/test2src.data" u ($1):($2):($18/$10) title "CoV(T_{Srv})" w l lc 1, \
"analysis/test2src.data" u ($1):($2):($18/$10):($19/$10) notitle w errorbars lc 1 pt 4, \\

sqrt(expCVsq(x, y, TS1, TS2, CV1, CV2)) title "Model" w l lc 2


set output "analysis/test2src_tsrv.png"
set key top left
set dgrid3d NSAMP, NSAMP
set isosamples (NSAMP-1)*M+1, (NSAMP-1)*M+1
set xlabel "{/symbol l}_2"
set ylabel "{/symbol l}_1"
set zlabel "Time [s]" rotate parallel
#set pm3d at b


sp [][][]\\

"analysis/test2src.data" u ($2):($1):($10) title "T_{Srv}" w l lc 1, \
"analysis/test2src.data" u ($2):($1):($10):($11) notitle w errorbars lc 1 pt 4, \\

expTSrv(y, x, TS1, TS2) t "1/{/Symbol m}" w l lc 2

#"analysis/test2src.data" u ($2):($1):expTsrv($1, $2, 1.0/10.0, 1.0/20.0)  (1.0/20.0)*($2)/(($2)+($1))+(1.0/10.0)*($1)/(($2)+($1)) t "1/{/Symbol m}" w l lc 2