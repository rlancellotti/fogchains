<%
# import solution file
import json
with open('sample_output.json') as f:
    sol=json.load(f)
foglookup={}
%>\
[General]
network = FogChain
sim-time-limit = 10800s
cmdenv-config-name = FogChain
qtenv-default-config = FogChain
repeat = 1

[Config FogChainTest1]
**.vector-recording = false
**.sink.responseTime.result-recording-modes = +histogram
**.sink.earlyExit.result-recording-modes = +histogram
**.nChains=${len(sol['servicechain'])}
**.nNodes=${len(sol['fog'])}

# Fog nodes
%for i, f in enumerate(sol['fog']):
**.pu[${i}].speedup = ${sol['fog'][f]['capacity']}
<% foglookup[f]=i %>\
%endfor

%for i, c in enumerate(sol['servicechain']):
# Service chain ${c}
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
#**.delay.delay = exponential(0.5s)
