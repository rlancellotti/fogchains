<%
import json
#fname = 'sample_output_0101.json'
fname = conf.files[0]
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
        "solutionFile": {"pattern": "**.solutionFile", "type": "varchar(30)"}
    },
    "metrics": {
%for sc, scname in enumerate(sol['servicechain']):
%for s in range(get_nspc(sol['servicechain'])):
        "SrcSent-${scname}-${s}": {"module": "**.source[${sc*get_nspc(sol['servicechain'])+s}]", "scalar_name": "sentJob:count" ,"aggr": ["none"]},
%endfor
        "SinkChainTResp-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "responseTime:stats/mean", "aggr": ["none"]},
        "SinkChainStdTResp-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "responseTime:stats/stddev", "aggr": ["none"]},
        "SinkChainTWait-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "totalQueueingTime:stats/mean", "aggr": ["none"]},
        "SinkChainStdTWait-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "totalQueueingTime:stats/stddev", "aggr": ["none"]},
        "SinkChainTSrv-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "totalServiceTime:stats/mean", "aggr": ["none"]},
        "SinkChainStdTSrv-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "totalServiceTime:stats/stddev", "aggr": ["none"]},
        "SinkChainTNet-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "totalDelayTime:stats/mean", "aggr": ["none"]},
        "SinkChainStdTNet-${scname}": {"module": "**.sink[${sc}]", "scalar_name": "totalDelayTime:stats/stddev", "aggr": ["none"]},
%endfor
%for fog, fogname in enumerate(sol['fog']):
        "FogRho-${fogname}": {"module": "**.pu[${fog}]", "scalar_name": "busy:timeavg", "aggr": ["none"]},
        "FogTSrv-${fogname}": {"module": "**.pu[${fog}]", "scalar_name": "serviceTime:stats/mean", "aggr": ["none"]},
        "FogStdTSrv-${fogname}": {"module": "**.pu[${fog}]", "scalar_name": "serviceTime:stats/stddev", "aggr": ["none"]},
        "FogTWait-${fogname}": {"module": "**.pu[${fog}]", "scalar_name": "queueingTime:stats/mean", "aggr": ["none"]},
        "FogStdTWait-${fogname}": {"module": "**.pu[${fog}]", "scalar_name": "queueingTime:stats/stddev", "aggr": ["none"]},
        "FogTIArr-${fogname}": {"module": "**.pu[${fog}]", "scalar_name": "interarrivalTime:stats/mean", "aggr": ["none"]},
        "FogStdTIArr-${fogname}": {"module": "**.pu[${fog}]", "scalar_name": "interarrivalTime:stats/stddev", "aggr": ["none"]}\
%if fog != len(sol['fog'])-1:
,
%endif
%endfor

    },
    "analyses": {
        "All": {
            "outfile": "analysis/fogchain.data",
            "scenarios": {
                "fixed": {},
                "range": ["solutionFile"]
            },
            "metrics": [
%for sc, scname in enumerate(sol['servicechain']):
%for s in range(get_nspc(sol['servicechain'])):
                {"metric": "SrcSent-${scname}-${s}", "aggr": "none"},
%endfor
                {"metric": "SinkChainTResp-${scname}", "aggr": "none"},
                {"metric": "SinkChainStdTResp-${scname}", "aggr": "none"},
                {"metric": "SinkChainTWait-${scname}", "aggr": "none"},
                {"metric": "SinkChainStdTWait-${scname}", "aggr": "none"},
                {"metric": "SinkChainTSrv-${scname}", "aggr": "none"},
                {"metric": "SinkChainStdTSrv-${scname}", "aggr": "none"},
                {"metric": "SinkChainTNet-${scname}", "aggr": "none"},
                {"metric": "SinkChainStdTNet-${scname}", "aggr": "none"},
%endfor
%for fog, fogname in enumerate(sol['fog']):
                {"metric": "FogRho-${fogname}", "aggr": "none"},
                {"metric": "FogTSrv-${fogname}", "aggr": "none"},
                {"metric": "FogStdTSrv-${fogname}", "aggr": "none"},
                {"metric": "FogTWait-${fogname}", "aggr": "none"},
                {"metric": "FogStdTWait-${fogname}", "aggr": "none"},
                {"metric": "FogTIArr-${fogname}", "aggr": "none"},
                {"metric": "FogStdTIArr-${fogname}", "aggr": "none"}\
%if fog != len(sol['fog'])-1:
,
%endif
%endfor

          ]
       }
    }
}