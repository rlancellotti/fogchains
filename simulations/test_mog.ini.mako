<%
import math
mu1=10
cv1=0.1
rhos=[0.1, 0.5, 0.7, 0.8, 0.85, 0.9]
cvs=[0.05, 0.1, 0.4, 0.5, 0.6, 0.7, 0.8]
lambda1s=[1, 2, 3, 4, 5, 6, 7, 8]
lambda2s=[2, 4, 6, 8, 10, 12, 14, 16]
%>
[General]
network = TestMoG
sim-time-limit = 10800s
cmdenv-config-name = TestMoG
qtenv-default-config = TestMoG
repeat = 5



%for cv in cvs:
%for rho in rhos:
<%
lambda1=0.000001
mu1=10
mu2=10
cv1=0.1
cv2=cv
lambda2=mu2*rho
%>\
<%doc>
## doc tag to comment out
[Config ${'MoG-1src-rho%03d-cv%03d'%(int(rho*100), int(cv*100))}]
**.vector-recording = false
**.rho=${rho}
**.cv1=${cv1}
**.cv2=${cv2}
**.lambda1=${lambda1}
**.lambda2=${lambda2}
**.mu1=${mu1}
**.mu2=${mu2}
**.source[*].appId = 1
**.source[*].output_0 = 0
**.source[*].output_1 = -1
**.source[*].chainLenght = 1
**.source[0].sendInterval = 1s * exponential(${1.0/lambda1})
**.source[1].sendInterval = 1s * exponential(${1.0/lambda2})
#**.source[0].suggestedTime_1 = 1s * truncnormal(${1.0/mu1}, ${cv1/mu1})
#**.source[1].suggestedTime_1 = 1s * truncnormal(${1.0/mu2}, ${cv2/mu2})
**.source[0].suggestedTime_1 = 1s * lognormal(${math.log((1.0/mu1) * 1.0/math.sqrt(1+cv1**2))}, ${math.sqrt(math.log(1+cv1**2))})
**.source[1].suggestedTime_1 = 1s * lognormal(${math.log((1.0/mu2) * 1.0/math.sqrt(1+cv2**2))}, ${math.sqrt(math.log(1+cv2**2))})
</%doc>
%endfor
%endfor

<%
mu1=10.0
mu2=20.0
cv1=0.2
cv2=0.2

def get_rho(lambda1, lambda2):
    lam=lambda1+lambda2
    mu=lam/(lambda1/mu1+lambda2/mu2)
    #print('get_rho(%.1f, %.1f): mu=%f, rho=%f'%(lambda1, lambda2, mu, lam/mu))
    return lam/mu

def get_available_lambdas(lambda1, lambdas):
    rv=[]
    for l in lambdas:
        if get_rho(lambda1, l)<0.95:
            rv.append(l)
    return rv
%>

%for lambda1 in lambda1s:
%for lambda2 in get_available_lambdas(lambda1, lambda2s):
[Config ${'MoG-2src-lambda1_%02d-lambda2_%02d'%(int(lambda1), int(lambda2))}]
**.vector-recording = false
**.rho=${get_rho(lambda1, lambda2)}
**.cv1=${cv1}
**.cv2=${cv2}
**.lambda1=${lambda1}
**.lambda2=${lambda2}
**.mu1=${mu1}
**.mu2=${mu2}
**.source[*].appId = 1
**.source[*].output_0 = 0
**.source[*].output_1 = -1
**.source[*].chainLenght = 1
**.source[0].sendInterval = 1s * exponential(${1.0/lambda1})
**.source[1].sendInterval = 1s * exponential(${1.0/lambda2})
**.source[0].suggestedTime_1 = 1s * lognormal(${math.log((1.0/mu1) * 1.0/math.sqrt(1.0+cv1**2))}, ${math.sqrt(math.log(1.0+cv1**2))})
**.source[1].suggestedTime_1 = 1s * lognormal(${math.log((1.0/mu2) * 1.0/math.sqrt(1.0+cv2**2))}, ${math.sqrt(math.log(1.0+cv2**2))})

%endfor
%endfor