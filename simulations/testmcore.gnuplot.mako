<%
cores=[1, 2, 4, 8]
%>\
set terminal pngcairo enhanced font "Helvetica,12"
set output "analysis/testmcore_tresp.png"

set key top left
set xlabel "{/symbol r}"
set ylabel "Time [s]"

fac(n)=gamma(n+1)
st=0.1
CC(c, rho)=1.0/(1.0+(1.0-rho)*(fac(c)/((c*rho)**c))*(sum [k=0:c-1] (((rho*c)**k))/fac(k)))

mmc(rho, c)=st*(c+(CC(c, rho)/(1-rho)))


p [0:0.95][0:1.8] \\

%for (c, nc) in enumerate(cores):
mmc(x, ${nc}) title "M/M/${nc}" w l lc 7, \
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($5) title "${nc} core${'s' if nc>1 else ''}" w lp lc ${c+1} pt ${4+c}, \
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($5):($6) notitle w errorbars lc ${c+1} pt ${4+c} ${'' if c==len(cores)-1 else ','} \\

%endfor

set output "analysis/testmcore_rho.png"

set key top left
set xlabel "{/symbol r}"
set ylabel "PU {/symbol r}"

p [0:0.9][0:0.9]\\

%for (c, nc) in enumerate(cores):
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($11/${nc}) title "${nc} core${'s' if nc>1 else ''}" w lp lc ${c+1} pt ${4+c}, \\

"<(grep ^${nc} analysis/testmcore.data)" u ($2):($11/${nc}):($12/${nc}) notitle w errorbars lc ${c+1} pt ${4+c}, \\

%endfor

%for nc in cores:
set output "analysis/testmcore_timeBD_${nc}.png"
set key top left
set xlabel "{/symbol r}"
set ylabel "Time [s]"
set y2label "Drop rate [%]"
set ytics nomirror
set y2tics nomirror

p [0:0.95][0:1.8]\\

mmc(x, ${nc}) axes x1y1 title "M/M/${nc}" w l lc 7, \\

"<(grep ^${nc} analysis/testmcore.data)" u ($2):($5) axes x1y1 title "T_{Resp}" w lp lc 1 pt 4, \
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($5):($6) axes x1y1 notitle w errorbars lc 1 pt 4, \\

"<(grep ^${nc} analysis/testmcore.data)" u ($2):($7) axes x1y1 title "T_{Queue}" w lp lc 2 pt 5, \
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($7):($8) axes x1y1 notitle w errorbars lc 2 pt 5, \\

"<(grep ^${nc} analysis/testmcore.data)" u ($2):($9) axes x1y1 title "T_{Srv}" w lp lc 3 pt 6, \
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($9):($10) axes x1y1 notitle w errorbars lc 3 pt 6, \\

"<(grep ^${nc} analysis/testmcore.data)" u ($2):(($3-$13)/$3) axes x1y1 title "Drop" w lp lc 4 pt 7, \\

"<(grep ^${nc} analysis/testmcore.data)" u ($2):($15/$3) axes x1y1 title "Drop (alt)" w lp lc 5 pt 8 \\


%endfor
