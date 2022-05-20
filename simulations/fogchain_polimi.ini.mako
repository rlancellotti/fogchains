<%
import json
files = ['fog_polimi.json']
def get_nspc(chain):
    try:
        nspc=-1
        for c in chain.keys():
            nspc = max(len(chain[c]['sources']), nspc)
        return nspc
    except KeyError:
        return 1
%>\
[General]
network = FogChain
sim-time-limit = 10800s
cmdenv-config-name = FogChain
qtenv-default-config = FogChain
repeat = 1

%for fname in files:
[Config ${fname.removesuffix('.json')}]
<%
# import solution file
with open(fname) as f:
    sol=json.load(f)
foglookup={}
nnodes=len(sol['fog'])
nchains=len(sol['servicechain'])
nspc=get_nspc(sol['servicechain'])
%>\
**.vector-recording = false
**.nChains=${nchains}
**.nNodes=${nnodes}
**.networkDelay=${'true' if 'network' in sol.keys() else 'false'}
**.nSrcPerChain=${nspc}

# Fog nodes
%for i, f in enumerate(sol['fog']):
**.pu[${i}].speedup = ${sol['fog'][f]['capacity']}
<% foglookup[f]=i %>\
%endfor

%for i, c in enumerate(sol['servicechain']):
# Service chain ${c}
%for j, s in enumerate(sol['servicechain'][c]['sources']):
# Source ${c}-${j}
<% ns=i*nspc+j %>\
%if 'startTime' in s:
**.source[${ns}].startTime = ${s['startTime']}s
%endif
%if 'stopTime' in s:
**.source[${ns}].stopTime = ${s['stopTime']}s
%endif
**.source[${ns}].appId = ${i+1}
**.source[${ns}].sendInterval = exponential(1s * ${1.0/s['lambda']})
**.source[${ns}].chainLenght = ${len(sol['servicechain'][c]['services'])}
%for k, m in enumerate(sol['servicechain'][c]['services']):
**.source[${ns}].output_${k} = ${foglookup[sol['microservice'][m]]}
**.source[${ns}].suggestedTime_${k+1} = 1s * exponential(${sol['servicechain'][c]['services'][m]['meanserv']}) # ${m}
<% 
    if 'exitprobability' in sol['servicechain'][c]['services'][m].keys(): 
        exprob = sol['servicechain'][c]['services'][m]['exitprobability']
    else:
        exprob=0
%>\
**.source[${ns}].exitProbability_${k+1} = ${exprob}
%endfor
**.source[${ns}].output_${len(sol['servicechain'][c]['services'])} = -1
%endfor

%endfor
%if 'network' in sol.keys():
%for s, row in enumerate(sol['network']):
%for d, delay in enumerate(row):
**.delay[${s*nnodes+d}].delay = 1s * truncnormal(${delay}, ${0.05 * delay}) # delay ${s} -> ${d}
%endfor
%endfor
%endif

%endfor