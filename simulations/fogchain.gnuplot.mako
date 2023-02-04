<%
import json
#files = ['sample_output_0011.json', 'sample_output_0101.json', 'sample_output_0110.json']
files = conf.files
datafile = 'analysis/fogchain.data'
#	1: solutionFile
#	2: SrcSent-SC1-0
#	3: sigma(SrcSent-SC1-0)
#	4: SinkChainTResp-SC1
#	5: sigma(SinkChainTResp-SC1)
#	6: SinkChainStdTResp-SC1
#	7: sigma(SinkChainStdTResp-SC1)
sc_params={'tresp': 3, 'twait': 7, 'tsrv': 11, 'tnet': 15}
fog_params={'rho': 0, 'tsrv': 2, 'tsrvsd': 4, 'twait': 6, 'twaitsd': 8, 'tia': 10, 'tiasd': 12}

def get_sc_col(param, nchain):
    return 1+sc_params[param]+nchain*18

def get_fog_col(param, nfog, nchains):
    return 2+fog_params[param]+nchains*18+nfog*14

%>\


set terminal pngcairo enhanced font "Helvetica,12"
set boxwidth 0.8 absolute

%for fname in files:
set output "analysis/chain_${fname.replace('.json', '')}_SC.png"
<%
# import solution file
with open(fname) as f:
    sol=json.load(f)
# nchains=len(sol['servicechain'])
%>\

set ylabel "Time [s]"

set xtics (\
%for nchain, chain in enumerate(sol['servicechain']):
"${chain}" ${nchain*3+0.5}\
%if nchain != len(sol['servicechain'])-1:
, \
%endif
%endfor
)

# for each service chain
# extract Tresp, TWait, TSrv, TNet from f
# plot histogram of model expectations
# plot results from file
p \\

"${datafile}" u (0):(0) t "T_{Wait}" with boxes lc 0 fs pattern 1, \\

"${datafile}" u (0):(0) t "T_{Srv}" with boxes lc 0 fs pattern 2, \\

"${datafile}" u (0):(0) t "T_{Net}" with boxes lc 0 fs pattern 4, \\

"${datafile}" u (0):(0) t "Model" with boxes lc 1 fs solid, \\

"${datafile}" u (0):(0) t "Sim" with boxes lc 2 fs solid, \\

%for nchain, chain in enumerate(sol['servicechain']):
<%
tresp=sol['servicechain'][chain]['resptime']
twait=sol['servicechain'][chain]['waittime']
tsrv=sol['servicechain'][chain]['servicetime']
tnet=sol['servicechain'][chain]['networktime']
fcmd='<(cat %s | grep %s)' % (datafile, fname.replace('.json', ''))
%>\
"${fcmd}" u (${nchain*3}):(${twait}+${tsrv}+${tnet})  notitle with boxes lc 1 fs pattern 1, \\

"${fcmd}" u (${nchain*3}):(${tsrv}+${tnet})  notitle with boxes lc 1 fs pattern 2, \\

"${fcmd}" u (${nchain*3}):(${tnet})  notitle with boxes lc 1 fs pattern 4, \\

"${fcmd}" u (${nchain*3+1}):($${get_sc_col('twait', nchain)} + $${get_sc_col('tsrv', nchain)} + $${get_sc_col('tnet', nchain)})  notitle with boxes lc 2 fs pattern 1, \\

"${fcmd}" u (${nchain*3+1}):($${get_sc_col('tsrv', nchain)} + $${get_sc_col('tnet', nchain)})  notitle with boxes lc 2 fs pattern 2, \\

"${fcmd}" u (${nchain*3+1}):($${get_sc_col('tnet', nchain)})  notitle with boxes lc 2 fs pattern 4, \\

%endfor

set output "analysis/chain_${fname.replace('.json', '')}_F.png"

set ylabel "Time [s]"
set y2label "{/Symbol r}"
set ytics nomirror
set y2tics nomirror
set y2range [0:1.0]
set yrange [0:]

set xtics (\
%for nfog, fog in enumerate(sol['fog']):
"${fog}" ${nfog*7+1.5}\
%if nfog != len(sol['fog'])-1:
, \
%endif
%endfor
)

p \\

"${datafile}" u (0):(0) t "T_{Wait}" with boxes lc 0 fs pattern 1, \\

"${datafile}" u (0):(0) t "T_{Srv}" with boxes lc 0 fs pattern 2, \\

"${datafile}" u (0):(0) t "T_{IntArr}" with boxes lc 0 fs pattern 4, \\

"${datafile}" u (0):(0) t "{/Symbol r}" with boxes lc 0 fs pattern 5, \\

"${datafile}" u (0):(0) t "Model" with boxes lc 1 fs solid, \\

"${datafile}" u (0):(0) t "Sim" with boxes lc 2 fs solid, \\

%for nfog, fog in enumerate(sol['fog']):
<%
rho=sol['fog'][fog]['rho']
tserv=sol['fog'][fog]['tserv']
tservsd=sol['fog'][fog]['stddev']
twait=sol['fog'][fog]['twait']
tia=1.0/sol['fog'][fog]['lambda']
sclen=len(sol['servicechain'])
fcmd='<(cat %s | grep %s)' % (datafile, fname.replace('.json', ''))
%>\
"${fcmd}" u (${nfog*7}):(${tserv}+${twait}) axes x1y1 notitle with boxes lc 1 fs pattern 1, \\

"${fcmd}" u (${nfog*7}):(${tserv}) axes x1y1 notitle with boxes lc 1 fs pattern 2, \\

"${fcmd}" u (${nfog*7}):(${tserv}):(${tservsd}) axes x1y1 notitle with errorbars pt 5 ps 0 lc 1, \\

"${fcmd}" u (${nfog*7+1}):($${get_fog_col('tsrv', nfog, sclen)} + $${get_fog_col('twait', nfog, sclen)}) axes x1y1  notitle with boxes lc 2 fs pattern 1, \\

"${fcmd}" u (${nfog*7+1}):($${get_fog_col('tsrv', nfog, sclen)}) axes x1y1 notitle with boxes lc 2 fs pattern 2, \\

"${fcmd}" u (${nfog*7+1}):($${get_fog_col('tsrv', nfog, sclen)}):($${get_fog_col('tsrvsd', nfog, sclen)}) axes x1y1  notitle with errorbars  pt 5 ps 0 lc 2, \\

"${fcmd}" u (${nfog*7+2}):(${tia}) axes x1y1 notitle with boxes lc 1 fs pattern 4, \\

"${fcmd}" u (${nfog*7+2}):(${tia}):(${tia}) axes x1y1 notitle with errorbars  pt 5 ps 0 lc 1, \\

"${fcmd}" u (${nfog*7+3}):($${get_fog_col('tia', nfog, sclen)}) axes x1y1 notitle with boxes lc 2 fs pattern 4, \\

"${fcmd}" u (${nfog*7+3}):($${get_fog_col('tia', nfog, sclen)}):($${get_fog_col('tiasd', nfog, sclen)}) axes x1y1  notitle with errorbars pt 5 ps 0  lc 2, \\

"${fcmd}" u (${nfog*7+4}):(${rho}) axes x1y2 notitle with boxes lc 1 fs pattern 5, \\

"${fcmd}" u (${nfog*7+5}):($${get_fog_col('rho', nfog, sclen)}) axes x1y2  notitle with boxes lc 2 fs pattern 5, \\

%endfor

unset y2label
set ytics mirror auto
#unset y2range

%endfor
