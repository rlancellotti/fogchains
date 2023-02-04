<%
import json
import math

if hasattr(conf, 'files'):
    files = conf.files
else:
    files = ['sample_output_0011.json', 'sample_output_0101.json', 'sample_output_0110.json']

# CoV of network delay
delaycv=0.05 

def get_nspc(chain):
    try:
        nspc=-1
        for c in chain.keys():
            nspc = max(len(chain[c]['sources']), nspc)
        return nspc
    except KeyError:
        return 1

def lognorm_mean(mean, cv):
    #print(mean, cv)
    return math.log(mean * 1.0/math.sqrt(1.0+cv**2))

def lognorm_sd(cv):
    return math.sqrt(math.log(1.0+cv**2))

def node_description(nodes):
    if type(nodes) == str:
        return str(foglookup[nodes])
    else:
        #{id: 2, weight: 1}, {id: 3, weight: 1}
        nodeslist='['
        for i, n in enumerate(nodes):
            if type(n) == dict:
                nodeslist += '{id: %s, weight: %f}' %(str(foglookup[str(list(n.keys())[0])]), float(list(n.values())[0]))
            else:
                nodeslist += '{id: %s, weight: %f}' %(str(foglookup[n]), 1.0)
            nodeslist += ', ' if (i<len(nodes)-1) else ']'
        return nodeslist


def chain_description(c):
    chain='['
    for i, m in enumerate(sol['servicechain'][c]['services']):
        meansrv=sol['servicechain'][c]['services'][m]['meanserv']
        cvsrv=sol['servicechain'][c]['services'][m]['stddevserv']/meansrv if 'stddevserv' in sol['servicechain'][c]['services'][m].keys() else None
        exprob=sol['servicechain'][c]['services'][m]['exitprobability'] if 'exitprobability' in sol['servicechain'][c]['services'][m].keys() else 0.0
        if cvsrv is None:
            chain +='{suggestedTime: exponential(%f), node: %s, exitProbability: %f}'%(meansrv, node_description(sol['microservice'][m]), exprob)
        else:
            chain +='{suggestedTime: lognormal(%f, %f), node: %s, exitProbability: %f}'%(lognorm_mean(meansrv, cvsrv), lognorm_sd(cvsrv), node_description(sol['microservice'][m]), exprob)
        chain += ', \n\t' if (i<len(sol['servicechain'][c]['services'])-1) else ']'
        #print(chain)
    return chain


%>\
[General]
network = fog.simulations.FogChain
sim-time-limit = 108000s
cmdenv-config-name = FogChain
qtenv-default-config = FogChain
repeat = 5

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
**.solutionFile="${fname.removesuffix('.json')}"

# Fog nodes
%for i, f in enumerate(sol['fog']):
**.pu[${i}].speedup = ${sol['fog'][f]['capacity']} # fog node ${f}
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
**.source[${ns}].chain = ${chain_description(c)}
%endfor

%endfor
# Network configuration
%if 'network' in sol.keys():
%for s, row in enumerate(sol['network']):
%for d, delay in enumerate(row):
%if delay <=0:
**.delay[${s*nnodes+d}].delay = 0s # delay ${list(sol['fog'].keys())[s]} -> ${list(sol['fog'].keys())[d]}
%else:
**.delay[${s*nnodes+d}].delay = 1s * lognormal(${lognorm_mean(delay, delaycv)}, ${lognorm_sd(delaycv)}) # delay ${list(sol['fog'].keys())[s]} -> ${list(sol['fog'].keys())[d]} (mean: ${delay}, stddev: ${delay * delaycv})
%endif
%endfor
%endfor
%endif

%endfor