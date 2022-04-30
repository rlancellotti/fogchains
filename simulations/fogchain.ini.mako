<%
import json
files = ['sample_output.json', 'output_nfog3_run0.json']
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
%>\
**.vector-recording = false
**.nChains=${nchains}
**.nNodes=${nnodes}
**.networkDelay=${'true' if 'network' in sol.keys() else 'false'}

# Fog nodes
%for i, f in enumerate(sol['fog']):
**.pu[${i}].speedup = ${sol['fog'][f]['capacity']}
<% foglookup[f]=i %>\
%endfor

%for i, c in enumerate(sol['servicechain']):
# Service chain ${c}
#**.source[${i}].startTime = 10s
#**.source[${i}].stopTime = 100s
**.source[${i}].appId = ${i+1}
**.source[${i}].sendInterval = exponential(1s * ${1.0/sol['servicechain'][c]['lambda']})
**.source[${i}].chainLenght = ${len(sol['servicechain'][c]['services'])}
%for j, m in enumerate(sol['servicechain'][c]['services']):
**.source[${i}].output_${j} = ${foglookup[sol['microservice'][m]]}
**.source[${i}].suggestedTime_${j+1} = 1s * truncnormal(\
${sol['servicechain'][c]['services'][m]['meanserv']}, \
${sol['servicechain'][c]['services'][m]['stddevserv']}) # ${m}
**.source[${i}].exitProbability_${j+1} = 0.0
%endfor
**.source[${i}].output_${len(sol['servicechain'][c]['services'])} = -1

%endfor
%if 'network' in sol.keys():
#**.delay[*].delay = exponential(0.5s)
%for s, row in enumerate(sol['network']):
%for d, delay in enumerate(row):
**.delay[${s*nnodes+d}].delay = 1s * truncnormal(${delay}, ${0.05 * delay}) # delay ${s} -> ${d}
%endfor
%endfor
%endif

%endfor