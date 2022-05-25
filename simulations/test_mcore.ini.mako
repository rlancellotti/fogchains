<%
rhos=[0.1, 0.5, 0.7, 0.8, 0.85, 0.9]
ncores=[1, 2, 4, 8]
mu=10
%>
[General]
network = TestMCore
sim-time-limit = 10800s
cmdenv-config-name = TestMCore
qtenv-default-config = TestMCore
repeat = 5

%for ncore in ncores:
%for rho in rhos:
<%
lam=mu*rho
#lam=mu*rho*ncore
%>\
[Config ${'MMn-n%d-rho%03d'%(ncore,int(rho*100))}]
**.vector-recording = false
**.rho=${rho}
**.nCores=${ncore}
**.source.appId = 1
**.source.output_0 = 0
**.source.output_1 = -1
**.source.sendInterval = 1s * exponential(${1.0/lam})
**.source.chainLenght = 1
**.source.suggestedTime_1 = 1s * exponential(${1.0/mu})

%endfor
%endfor