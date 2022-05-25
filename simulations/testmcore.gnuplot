set terminal pngcairo enhanced font "Helvetica,12"
set output "testmcore_tresp.png"

set key top left
set xlabel "{/symbol r}"
set ylabel "Time [s]"

fac(n)=gamma(n+1)
pi0(rho, c)=1.0/((sum [k=0:c-1] (rho*c)**k/(fac(k)))+(((rho*c)**c)/fac(c))*(1.0/(1.0-rho)))
st=0.1
mmc(rho, c)=(st*c)*(1.0+pi0(rho, c)*((c*rho)**c)/(fac(c)*(1.0-rho)**2))


#mmc(x, nc) title"M/M/nc" w l lc 7, 

p [0:0.95][0:1.8] \
mmc(x, 1) title "M/M/1" w l lc 7, "<(grep ^1 analysis/testmcore.data)" u ($2):($5) title "1 core" w lp lc 1 pt 4, "<(grep ^1 analysis/testmcore.data)" u ($2):($5):($6) notitle w errorbars lc 1 pt 4, \
mmc(x, 2) title "M/M/2" w l lc 7, "<(grep ^2 analysis/testmcore.data)" u ($2):($5) title "2 cores" w lp lc 2 pt 5, "<(grep ^2 analysis/testmcore.data)" u ($2):($5):($6) notitle w errorbars lc 2 pt 5, \
mmc(x, 4) title "M/M/4" w l lc 7, "<(grep ^4 analysis/testmcore.data)" u ($2):($5) title "4 cores" w lp lc 3 pt 6, "<(grep ^4 analysis/testmcore.data)" u ($2):($5):($6) notitle w errorbars lc 3 pt 6, \
mmc(x, 8) title "M/M/8" w l lc 7, "<(grep ^8 analysis/testmcore.data)" u ($2):($5) title "8 cores" w lp lc 4 pt 7, "<(grep ^8 analysis/testmcore.data)" u ($2):($5):($6) notitle w errorbars lc 4 pt 7, \
0.1 t "1/{/Symbol m}" w l lc 7

set output "testmcore_rho.png"

set key top left
set xlabel "{/symbol r}"
set ylabel "PU {/symbol r}"

p [0:0.9][0:0.9]\
"<(grep ^1 analysis/testmcore.data)" u ($2):($11/1) title "1 core" w lp lc 1 pt 4, \
"<(grep ^1 analysis/testmcore.data)" u ($2):($11/1):($12/1) notitle w errorbars lc 1 pt 4, \
"<(grep ^2 analysis/testmcore.data)" u ($2):($11/2) title "2 cores" w lp lc 2 pt 5, \
"<(grep ^2 analysis/testmcore.data)" u ($2):($11/2):($12/2) notitle w errorbars lc 2 pt 5, \
"<(grep ^4 analysis/testmcore.data)" u ($2):($11/4) title "4 cores" w lp lc 3 pt 6, \
"<(grep ^4 analysis/testmcore.data)" u ($2):($11/4):($12/4) notitle w errorbars lc 3 pt 6, \
"<(grep ^8 analysis/testmcore.data)" u ($2):($11/8) title "8 cores" w lp lc 4 pt 7, \
"<(grep ^8 analysis/testmcore.data)" u ($2):($11/8):($12/8) notitle w errorbars lc 4 pt 7, \
