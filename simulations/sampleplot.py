#!/usr/bin/python3
import sys
import json
import re
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.patches import Patch
import matplotlib as mpl
import matplotlib.colors as mc
from plots import plot_line, plot_bars, set_fonts

def parse_data(fname):
    return pd.read_csv(fname, sep='\s+', header=0)

def get_fogs(df):
    return [re.sub('FogRho-', '', k) for k in list(df.head()) if k.startswith('FogRho-')]

def get_chains(df):
    return [re.sub('SinkChainTResp-', '', k) for k in list(df.head()) if k.startswith('SinkChainTResp-')]

def get_data_series(df, prefix, iter):
    columns=[f'{prefix}-{i}' for i in iter]
    return [df[c][0] for c in columns]

def parse_th_data(fname):
    with open(fname) as f:
        return json.load(f)

def get_th_data_series(df, dict, param, keys):
    return [df[dict][k][param] for k in keys]



NSERIES=2

if __name__ == "__main__":
    set_fonts()
    df=parse_data('analysis/fogchain.data')
    th_data=parse_th_data('sample_output_pwr2_sent_to_BO.json')
    # plot utilization
    fig, ax = plt.subplots()
    ax.set_xticks([x*(NSERIES+1)+((NSERIES-1)/2) for x in range(len(get_fogs(df)))], get_fogs(df))
    ax.set(xlabel='Fogs', ylabel='$\\rho$')
    x=[x*(NSERIES+1) for x in range(len(get_fogs(df)))]
    y=get_data_series(df, 'FogRho', get_fogs(df))
    #print(x, y)
    plot_bars(ax, x, y, color='tab:orange', label='Simulation')
    x=[x*(NSERIES+1)+1 for x in range(len(get_fogs(df)))]
    y=get_th_data_series(th_data, 'fog', 'rho', get_fogs(df))
    #print(x, y)
    plot_bars(ax, x, y, color='tab:blue', label='Theoretical')
    plt.legend()
    plt.savefig('utilization.png')
    # plot times
    fig, ax = plt.subplots()
    ax.set(xlabel='Chains', ylabel='Time [s]')
    ax.set_xticks([x*(NSERIES+1)+((NSERIES-1)/2) for x in range(len(get_chains(df)))], get_chains(df))
    x=[x*(NSERIES+1) for x in range(len(get_chains(df)))]
    #y=get_data_series(df, 'SinkChainTResp', get_chains(df))
    tnet=get_data_series(df, 'SinkChainTNet', get_chains(df))
    twait=get_data_series(df, 'SinkChainTWait', get_chains(df))
    tsrv=get_data_series(df, 'SinkChainTSrv', get_chains(df))
    y=[tnet[i]+tsrv[i]+twait[i] for i in range(len(get_chains(df)))]
    plot_bars(ax, x, y, color='tab:orange', hatch='xx', label='$T_{wait}$ (Sim)')
    y=[tnet[i]+tsrv[i] for i in range(len(get_chains(df)))]
    plot_bars(ax, x, y, color='tab:orange', hatch='//', label='$T_{serv}$ (Sim)')
    y=[tnet[i] for i in range(len(get_chains(df)))]
    plot_bars(ax, x, y, color='tab:orange', hatch='\\\\', label='$T_{net}$ (Sim)')
    x=[x*(NSERIES+1)+1 for x in range(len(get_chains(df)))]
    #y=get_th_data_series(th_data, 'servicechain', 'resptime', get_chains(df))
    tnet=get_th_data_series(th_data, 'servicechain', 'networktime', get_chains(df))
    twait=get_th_data_series(th_data, 'servicechain', 'waittime', get_chains(df))
    tsrv=get_th_data_series(th_data, 'servicechain', 'servicetime', get_chains(df))
    y=[tnet[i]+tsrv[i]+twait[i] for i in range(len(get_chains(df)))]
    plot_bars(ax, x, y, color='tab:blue', hatch='xx', label='$T_{wait}$ (Theo)')
    y=[tnet[i]+tsrv[i] for i in range(len(get_chains(df)))]
    plot_bars(ax, x, y, color='tab:blue', hatch='//', label='$T_{serv}$ (Theo)')
    y=[tnet[i] for i in range(len(get_chains(df)))]
    plot_bars(ax, x, y, color='tab:blue', hatch='\\\\', label='$T_{net}$ (Theo)')
    plt.legend()
    plt.savefig('tresp.png')
    plt.show()

