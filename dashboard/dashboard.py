# ---
# jupyter:
#   jupytext:
#     text_representation:
#       extension: .py
#       format_name: percent
#       format_version: '1.3'
#       jupytext_version: 1.11.5
#   kernelspec:
#     display_name: Python 3
#     language: python
#     name: python3
# ---

# %%
import sys, os
import json

# %%
from plotly.offline import iplot, init_notebook_mode
import plotly.graph_objs as go

init_notebook_mode(connected=True)

import pandas as pd
import scipy

import numpy as np
import pandas as pd

from collections import defaultdict

from collections.abc import Iterable
import numpy as np

import sys

# %%
from jupyter_dash import JupyterDash
import dash
import dash_core_components as dcc
import dash_html_components as html

from psidash import load_app # for production
from psidash.psidash import get_callbacks, load_conf, load_dash, load_components, assign_callbacks
import flask

from dash.exceptions import PreventUpdate
import networkx as nx
from networkx import NetworkXNoPath, descendants

import logging

LND_DIR = os.environ.get('LND_DATADIR', '/root/.lnd')

use_test_data = 'true' in os.environ.get('USE_TEST_DATA', 'False').lower()


from collections import namedtuple
# Compiled grpc modules are located in `/grpc`
sys.path.append('/grpc')
import codecs, grpc
# See https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md for instructions.
import lightning_pb2 as lnrpc, lightning_pb2_grpc as lightningstub

# %%
Response = namedtuple('Response', ['nodes', 'edges'] )
Node = namedtuple('Node', ['last_update', 'pub_key', 'alias', 'addresses', 'color', 'features'])
Edge = namedtuple('Edge', ['channel_id', 'chan_point', 'last_update', 'node1_pub', 'node2_pub', 'capacity', 'node1_policy', 'node2_policy'])
RoutingPolicy = namedtuple('RoutingPolicy', ['time_lock_delta', 'min_htlc', 'fee_base_msat', 'fee_rate_milli_msat', 'max_htlc_msat', 'last_update', 'disabled'])


# %%
def get_describegraph_json(filename):
        # set up namedtuples so we can access the sample data in the same manner as grpc response data
        with open(filename) as f:
            dg = json.load(f)
        nodes = [Node(**node) for node in dg['nodes']]
        edges = []
        for edge in dg['edges']:
            for policy in 'node1_policy', 'node2_policy':
                if edge[policy] is not None:
                    try:
                        edge[policy] = RoutingPolicy(**edge[policy])
                    except:
                        print(edge[policy])
                        raise
            edges.append(Edge(**edge))
        return Response(nodes, edges)

if use_test_data:
    describe_graph_fname = os.environ.get('GRAPH_TEST_DATA', 'describegraph.json')
    if os.path.exists(describe_graph_fname):
        print('found graph data: {}'.format(describe_graph_fname))
        response = get_describegraph_json(describe_graph_fname)
    else:
        raise IOError("{} does not exist".format(describe_graph_fname))
else:
    macaroon = codecs.encode(open(LND_DIR+'/data/chain/bitcoin/signet/admin.macaroon', 'rb').read(), 'hex')
    os.environ['GRPC_SSL_CIPHER_SUITES'] = 'HIGH+ECDSA'
    cert = open(LND_DIR+'/tls.cert', 'rb').read()
    ssl_creds = grpc.ssl_channel_credentials(cert)
    channel = grpc.secure_channel('playground-lnd:10009', ssl_creds)
    stub = lightningstub.LightningStub(channel)
    request = lnrpc.ChannelGraphRequest(include_unannounced=True)
    response = stub.DescribeGraph(request, metadata=[('macaroon', macaroon)])


# %%
def get_node_multigraph(response):
    MG = nx.MultiDiGraph()

    MG.add_nodes_from(((node.pub_key, dict(alias=node.alias, color=node.color, last_update=node.last_update)) for node in response.nodes))
    # MG.number_of_nodes()

#     Add edges. Use `channel_id` as edge keys to so future updates don't duplicate edges.

    edge_iterable = [(edge.node1_pub,
                      edge.node2_pub,
                      edge.channel_id,
                      dict(capacity=edge.capacity,
                           node1_policy=edge.node1_policy,
                           node2_policy=edge.node2_policy)) for edge in response.edges]

    channel_ids = MG.add_edges_from(edge_iterable)
    MG.number_of_edges()
    return MG


def assign_capacity(G):
    """This is the sum of channel capacities available to a given node.
    This will be used to compute initial positions in the layout."""
    G.add_nodes_from(((k, dict(capacity=v)) for k,v in G.degree(weight='capacity')))
    return G 

def get_directed_nodes(MG):
    DG = nx.DiGraph()

    # Insert all node information from multi grid graph

    DG.add_nodes_from(MG.nodes(data=True))

    # Accumulate capacity for all duplicate edges.

    for node, neighbors in MG.adjacency():
    #     print(node, MG.nodes[node]['alias'])
        for neighbor, v in neighbors.items():
    #         print('\t{}:'.format(neighbor))
            capacity = 0
            avg_fee = 0
            avg_N = 1
            for k_, v_ in v.items():
                capacity += int(v_['capacity'])
                # running average
                if v_['node1_policy'] is not None:
                    avg_fee += (int(v_['node1_policy'].fee_rate_milli_msat) + avg_fee)/(avg_N+1)
                    avg_N += 1
                if v_['node2_policy'] is not None:
                    avg_fee += (int(v_['node2_policy'].fee_rate_milli_msat) + avg_fee)/(avg_N+1)
                    avg_N += 1
    #             print('\t\t{}: {}'.format(k_, v_))
            DG.add_edge(node,
                       neighbor,
                       capacity=capacity,
                       avg_fee=avg_fee,
                      )
    return DG

# def get_directed_nodes(MG):
#     DG = nx.DiGraph()

#     # Insert all node information from multi grid graph

#     DG.add_nodes_from(MG.nodes(data=True))

#     # Accumulate capacity for all duplicate edges.

#     for node, neighbors in MG.adjacency():
#     #     print(node, MG.nodes[node]['alias'])
#         for neighbor, v in neighbors.items():
#     #         print('\t{}:'.format(neighbor))
#             capacity = 0
#             avg_fee = 0
#             avg_N = 1
#             for k_, v_ in v.items():
#                 capacity += int(v_['capacity'])
#                 # running average
#                 if v_['node1_policy'] is not None:
#                     avg_fee += (int(v_['node1_policy']['fee_rate_milli_msat']) + avg_fee)/(avg_N+1)
#                     avg_N += 1
#                 if v_['node2_policy'] is not None:
#                     avg_fee += (int(v_['node2_policy']['fee_rate_milli_msat']) + avg_fee)/(avg_N+1)
#                     avg_N += 1
#     #             print('\t\t{}: {}'.format(k_, v_))
#             DG.add_edge(node,
#                        neighbor,
#                        capacity=capacity,
#                        avg_fee=avg_fee,
#                       )
#     return assign_capacity(DG)


# %% [markdown]
# # Layout

# %%
def get_initial_node_posn(G):
    """get initial positions for each node based on last update (x) and total capacity (y)"""
    initial_node_pos = dict()
    for _, cap in G.degree(weight='capacity'):
        initial_node_pos[_] = float(G.nodes[_]['last_update']), float(cap)
    return initial_node_pos

def get_layout(G, pos=None, layout_type = 'spring', fixed = None, weight=None, iterations=2, seed=0):
    if layout_type == 'spring':
        layout = nx.spring_layout(
                    G,
                    pos=pos,
                    fixed=fixed,
                    weight=weight,
                    iterations=iterations,
                    seed=seed)
    elif layout_type == 'kamada_kawai_layout':
        layout = nx.kamada_kawai_layout(G, pos=pos)
    pos = pd.DataFrame.from_dict(
        layout,
        orient='index', columns = ['x', 'y'])
    pos['alias'] = [G.nodes[_]['alias'] for _ in pos.index]
    pos['color'] = [G.nodes[_]['color'] for _ in pos.index]
    pos['capacity'] = [G.nodes[_]['capacity'] for _ in pos.index]
    return pos

def get_edge_posns(G, pos):
    """For each position"""
    edge_pos = defaultdict(list)
    for edge in G.edges:
        edge_pos[(edge[0], edge[1])].append(G.edges[edge]['capacity'])
    edge_cap = defaultdict(list)
    for edge in edge_pos:
        edge_cap['node1'].append(edge[0])
        edge_cap['node2'].append(edge[1])
        edge_cap['capacity'].append(sum(edge_pos[edge]))
    
    edge_pos = pd.DataFrame(edge_cap)
    edge_pos['x1'] = pos.loc[edge_pos.node1.values]['x'].values
    edge_pos['y1'] = pos.loc[edge_pos.node1.values]['y'].values
    edge_pos['x2'] = pos.loc[edge_pos.node2.values]['x'].values
    edge_pos['y2'] = pos.loc[edge_pos.node2.values]['y'].values
    edge_pos['empty'] = np.nan
    edge_pos['x_avg'] = edge_pos[['x1', 'x2']].mean(axis=1)
    edge_pos['y_avg'] = edge_pos[['y1', 'y2']].mean(axis=1)
    edge_pos['color1'] = pos.loc[edge_pos.node1.values]['color'].values
    edge_pos['color2'] = pos.loc[edge_pos.node2.values]['color'].values
    return edge_pos

def plot_graph(pos, edge_pos, highlight=None):
    edge_x = edge_pos[['x1','x2', 'empty']].values.ravel()
    edge_y = edge_pos[['y1', 'y2', 'empty']].values.ravel()
    edge_color = edge_pos[['color1', 'color2', 'empty']].values.ravel()
    
    node_trace = go.Scattergl(
                     x=pos.x,
                     y=pos.y,
                     text=pos.alias,
                     hoverinfo='text',
                     name='nodes',
                     marker=dict(size=2*np.log10(pos.capacity),
                                 color=pos.color),
                     mode='markers')
    edge_trace = go.Scattergl(
                     x=edge_x,
                     y=edge_y,
                     marker=dict(color='rgba(0, 0, 0, 0.1)'),
                     hoverinfo='text',
                     mode='lines')
    traces = [node_trace, edge_trace]
    if isinstance(highlight, Iterable):
        highlighted = pos.loc[highlight]
        highlighted_trace = go.Scattergl(
                     x=highlighted.x,
                     y=highlighted.y,
                     text=highlighted.alias,
                     marker_symbol='circle-open',
                     hoverinfo='text',
                     name='nodes',
                     marker=dict(size=4*np.log10(pos.capacity),
                                 color=pos.color),
                     marker_line_width=2,
                     mode='markers')
        traces.append(highlighted_trace)
        
    fig = go.Figure(layout=dict(# xaxis=dict(visible=False, showgrid=False),
                                # yaxis=dict(visible=False, showgrid=False),
                                plot_bgcolor='white'),
                    data=traces)
    return fig

def get_path(G, node1, node2, max_paths=5):
    "Get a path graph from node1 to node2"
    p = nx.MultiDiGraph()
    i, j = 0, 0
    path_nodes = defaultdict(list)
    path_posns = defaultdict(list)
    
    paths = nx.shortest_simple_paths(G, node1, node2, weight='avg_fee')
    
    for path in paths:
        if i >= max_paths:
            break
        if i == 0:
            pos_df = pd.DataFrame(
                dict(x=np.linspace(0, 1, len(path)),
                     y=0),
                index=path)
        else:
            df = pos_df.reindex(path)
            new_nodes = df[df.x.isna()].copy()
            new_nodes.x = df.x.interpolate().loc[new_nodes.index]
            new_nodes.y = i
            pos_df = pos_df.append(new_nodes)
            
        for j, node in enumerate(path):
            if node not in p:
                path_nodes[i].append(node)
            p.add_node(node, **G.nodes[node])
        for edge in zip(path[:-1], path[1:]):
            p.add_edge(*edge, key=i, **G.edges[edge])
        i += 1
    return p, path_nodes, pos_df

def multipath_layout(path, path_nodes, path_posns, weight=None, iterations=10, seed=0):
    """ Layout for multiple paths
    ToDo: iteratively build up position graph as routes are added.
    
    Layout paths iteratively, fixing shortest routes first
    path: network containing nodes and edges describing the multipath
    path_nodes: {path_number: new_nodes} nodes introduced for each new path
    """
    pos = path_posns
    pos['alias'] = [path.nodes[_]['alias'] for _ in pos.index]
    pos['color'] = [path.nodes[_]['color'] for _ in pos.index]
    pos['capacity'] = [path.nodes[_]['capacity'] for _ in pos.index]
    return pos

def plot_multipath(path, pos, edge_pos, highlight):
    """Given a multidigraph path, plot separate edge traces"""
    node_trace = go.Scattergl(
                     x=pos.x,
                     y=pos.y,
                     text=pos.alias,
                     hoverinfo='text',
                     name='nodes',
                     marker=dict(size=2*np.log10(pos.capacity),
                                 color=pos.color),
                     mode='markers')
    traces = [node_trace]
    
    path_edges = defaultdict(set)
    for n1, n2, pathid in path.edges:
        path_edges[pathid].add((n1, n2))
        
    for pathid, path_ in path_edges.items():
        path_df = pd.DataFrame(path_, columns = ['node1', 'node2'])
        path_df = pd.DataFrame(path_, columns = ['node1', 'node2'])
        path_df['empty'] = np.nan
        
        path_df['x1'] = pos.x.loc[path_df.node1].values
        path_df['x2'] = pos.x.loc[path_df.node2].values
        path_df['y1'] = pos.y.loc[path_df.node1].values
        path_df['y2'] = pos.y.loc[path_df.node2].values

        edge_x = path_df[['x1','x2', 'empty']].values.ravel()
        edge_y = path_df[['y1', 'y2', 'empty']].values.ravel()
#         edge_color = edge_pos[['color1', 'color2', 'empty']].values.ravel()
        edge_trace = go.Scattergl(
                         x=edge_x.copy(),
                         y=edge_y.copy(),
                         marker=dict(color='rgba(0, 0, 0, 0.1)'),
                         hoverinfo='text',
                         name='path {}'.format(pathid),
                         mode='lines')
        
        traces.append(edge_trace)
    
    if isinstance(highlight, Iterable):
        highlighted = pos.loc[highlight]
        highlighted_trace = go.Scattergl(
                     x=highlighted.x,
                     y=highlighted.y,
                     text=highlighted.alias,
                     marker_symbol='circle-open',
                     hoverinfo='text',
                     name='start/end',
                     marker=dict(size=4*np.log10(pos.capacity),
                                 color=pos.color),
                     marker_line_width=2,
                     mode='markers')
        traces.append(highlighted_trace)
        
    fig = go.Figure(layout=dict(xaxis=dict(visible=False, showgrid=False),
                                yaxis=dict(visible=False, showgrid=False),
                                plot_bgcolor='white'),
                    data=traces)
    return fig


# %%
def find_node(G, key, value):
    for node in G.nodes:
        if G.nodes[node][key] == value:
            return node


# %%
MG = get_node_multigraph(response)
DG = assign_capacity(get_directed_nodes(MG))
G = DG.to_undirected()

# %%
# hello_jessica = find_node(G, 'alias', 'HelloJessica')

# %%
conf = load_conf('dashboard.yaml')

# app = dash.Dash(__name__, server=server) # call flask server

server = flask.Flask(__name__) # define flask app.server

conf['app']['server'] = server

app = load_dash(__name__, conf['app'], conf.get('import'))

app.layout = load_components(conf['layout'], conf.get('import'))

if 'callbacks' in conf:
    callbacks = get_callbacks(app, conf['callbacks'])
    assign_callbacks(callbacks, conf['callbacks'])

# {'label': 'Hello Jessica', 'value': 'id'},

@callbacks.update_node_1_options
def update_node_select(url):
    options = [{'label': G.nodes[node]['alias'], 'value': node} for node in G.nodes]
    return options, options[0]['value']

@callbacks.update_node_2_options
def update_node_select(node_1):
    logging.info('update_node_select for {}'.format(node_1))
    if node_1 is None:
        raise PreventUpdate
    options = [{'label': G.nodes[node]['alias'], 'value': node} for node in descendants(G, node_1)]
    if len(options) > 0:
        return options, options[-1]['value']
    else:
        return options, ''

@callbacks.update_node_graph
def render(node_1, node_2):
    trip = node_1, node_2
    if (node_1 in G.nodes) & (node_2 in G.nodes):
        pass
    else:
        raise PreventUpdate
    try:
        path, path_nodes, path_posns = get_path(G, trip[0], trip[1], 10)
    except NetworkXNoPath:
        raise PreventUpdate
    path_pos = multipath_layout(path, path_nodes, path_posns, iterations=50, seed=1)
    path_edge_pos = get_edge_posns(path, path_pos)
    logging.info('{} -> {}'.format(path.nodes[trip[0]]['alias'], path.nodes[trip[1]]['alias']))
    return plot_multipath(path, path_pos, path_edge_pos, [trip[0], trip[1]])

if __name__ == '__main__':
    app.run_server(host='0.0.0.0', port=8050, mode='external', debug=True)

# %%
