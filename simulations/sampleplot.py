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
from plots import plot_line, plot_bars, set_fonts, dummy_bar

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

def plot_utilization(sim_data, th_data):
    # plot utilization
    NSERIES=2
    fig, ax = plt.subplots()
    ax.set_xticks([x*(NSERIES+1)+((NSERIES-1)/2) for x in range(len(get_fogs(sim_data)))], get_fogs(sim_data))
    ax.set(xlabel='Fog nodes', ylabel='$\\rho$')
    x=[x*(NSERIES+1) for x in range(len(get_fogs(sim_data)))]
    y=get_data_series(sim_data, 'FogRho', get_fogs(sim_data))
    #print(x, y)
    plot_bars(ax, x, y, color='tab:orange', label='Simulation')
    x=[x*(NSERIES+1)+1 for x in range(len(get_fogs(sim_data)))]
    y=get_th_data_series(th_data, 'fog', 'rho', get_fogs(sim_data))
    #print(x, y)
    plot_bars(ax, x, y, color='tab:blue', label='Theoretical')
    plt.legend()
    plt.savefig('analysis/utilization.png')

def plot_times(sim_data, th_data):
    # plot times
    NSERIES=2
    fig, ax = plt.subplots()
    ax.set(xlabel='Service Chains', ylabel='Time [s]')
    ax.set_xticks([x*(NSERIES+1)+((NSERIES-1)/2) for x in range(len(get_chains(sim_data)))], get_chains(sim_data))
    x=[x*(NSERIES+1) for x in range(len(get_chains(sim_data)))]
    #y=get_data_series(df, 'SinkChainTResp', get_chains(df))
    dummy_bar(ax, '$T_{wait}$', color='black', hatch='xxxx')
    dummy_bar(ax, '$T_{serv}$', color='black', hatch='////')
    dummy_bar(ax, '$T_{net}$', color='black', hatch='\\\\\\\\')
    dummy_bar(ax, 'Simulation', color='tab:orange')
    dummy_bar(ax, 'Theoretical', color='tab:blue')
    tnet=get_data_series(sim_data, 'SinkChainTNet', get_chains(sim_data))
    twait=get_data_series(sim_data, 'SinkChainTWait', get_chains(sim_data))
    tsrv=get_data_series(sim_data, 'SinkChainTSrv', get_chains(sim_data))
    y=[tnet[i]+tsrv[i]+twait[i] for i in range(len(get_chains(sim_data)))]
    plot_bars(ax, x, y, color='tab:orange', hatch='xx')
    y=[tnet[i]+tsrv[i] for i in range(len(get_chains(sim_data)))]
    plot_bars(ax, x, y, color='tab:orange', hatch='//')
    y=[tnet[i] for i in range(len(get_chains(sim_data)))]
    plot_bars(ax, x, y, color='tab:orange', hatch='\\\\')
    x=[x*(NSERIES+1)+1 for x in range(len(get_chains(sim_data)))]
    #y=get_th_data_series(th_data, 'servicechain', 'resptime', get_chains(df))
    tnet=get_th_data_series(th_data, 'servicechain', 'networktime', get_chains(sim_data))
    twait=get_th_data_series(th_data, 'servicechain', 'waittime', get_chains(sim_data))
    tsrv=get_th_data_series(th_data, 'servicechain', 'servicetime', get_chains(sim_data))
    y=[tnet[i]+tsrv[i]+twait[i] for i in range(len(get_chains(sim_data)))]
    plot_bars(ax, x, y, color='tab:blue', hatch='xx')
    y=[tnet[i]+tsrv[i] for i in range(len(get_chains(sim_data)))]
    plot_bars(ax, x, y, color='tab:blue', hatch='//')
    y=[tnet[i] for i in range(len(get_chains(sim_data)))]
    plot_bars(ax, x, y, color='tab:blue', hatch='\\\\')
    plt.legend()
    plt.savefig('analysis/tresp.png')

if __name__ == "__main__":
    set_fonts(font_size=12)
    sim_data=parse_data('analysis/fogchain.data')
    th_data=parse_th_data('sample_output_pwr2_sent_to_BO.json')
    plot_utilization(sim_data, th_data)
    plot_times(sim_data, th_data)
    plt.show()

