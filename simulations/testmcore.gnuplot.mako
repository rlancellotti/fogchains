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

p [0:0.95][0:1.8] \\

%for (nc, c) in [(1, 1), (2, 2), (4, 3), (8, 4)]:
mmc(x, ${nc}) title "M/M/${nc}" w l lc 7, \
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($5) title "${nc} core${'s' if nc>1 else ''}" w lp lc ${c} pt ${3+c}, \
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($5):($6) notitle w errorbars lc ${c} pt ${3+c}, \\

%endfor
0.1 t "1/{/Symbol m}" w l lc 7

set output "testmcore_rho.png"

set key top left
set xlabel "{/symbol r}"
set ylabel "PU {/symbol r}"

p [0:0.9][0:0.9]\\

%for (nc, c) in [(1, 1), (2, 2), (4, 3), (8, 4)]:
"<(grep ^${nc} analysis/testmcore.data)" u ($2):($11/${nc}) title "${nc} core${'s' if nc>1 else ''}" w lp lc ${c} pt ${3+c}, \\

"<(grep ^${nc} analysis/testmcore.data)" u ($2):($11/${nc}):($12/${nc}) notitle w errorbars lc ${c} pt ${3+c}, \\

%endfor
