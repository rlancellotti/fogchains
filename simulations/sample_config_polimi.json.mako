<%
import json
fname = 'fog_polimi.json'
with open(fname) as f:
    sol=json.load(f)
def get_nspc(chain):
    try:
        nspc=-1
        for c in chain.keys():
            nspc = max(len(chain[c]['sources']), nspc)
        return nspc
    except KeyError:
        return 1
%>\
{
    "scenario_schema": {
    },
    "metrics": {
%for sc, scname in enumerate(sol['servicechain']):
%for s in range(get_nspc(sol['servicechain'])):
        "SrcSent-${scname}-${s}": {"module": "**.source[${sc*get_nspc(sol['servicechain'])+s}]", "scalar_name": "sentJob:count" ,"aggr": ["none"]},
%endfor
        "SinkChainTResp-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "responseTime:stats/mean", "aggr": ["none"]},
        "SinkChainStdTResp-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "responseTime:stats/stddev", "aggr": ["none"]},
%endfor
        "FogRho": {"module": "**.pu[*]", "scalar_name": "busy:timeavg", "aggr": ["avg", "std"]}
    },
    "analyses": {
        "All": {
            "outfile": "analysis/fog_polimi.data",
            "scenarios": {
                "fixed": {},
                "range": []
            },
            "metrics": [
%for sc, scname in enumerate(sol['servicechain']):
%for s in range(get_nspc(sol['servicechain'])):
                {"metric": "SrcSent-${scname}-${s}", "aggr": "none"},
%endfor
                {"metric": "SinkChainTResp-${scname}", "aggr": "none"},
                {"metric": "SinkChainStdTResp-${scname}", "aggr": "none"},
%endfor
                {"metric": "FogRho", "aggr": "avg"},
                {"metric": "FogRho", "aggr": "std"}
            ]
       }
    }
}