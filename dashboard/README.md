# About

This directory contains setup necessary for creating dashboard visualizations of the lightning network

The grpc instructions are here https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md


## Accessing node graph though lightning-grpc

```python
LND_DIR = '/root/.lnd'
```

```python
import sys
sys.path.append('/grpc')
```

```python
import codecs, grpc, os
# Generate the following 2 modules by compiling the lnrpc/lightning.proto with the grpcio-tools.
# See https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md for instructions.
import lightning_pb2 as lnrpc, lightning_pb2_grpc as lightningstub
macaroon = codecs.encode(open(LND_DIR+'/data/chain/bitcoin/signet/admin.macaroon', 'rb').read(), 'hex')
os.environ['GRPC_SSL_CIPHER_SUITES'] = 'HIGH+ECDSA'
cert = open(LND_DIR+'/tls.cert', 'rb').read()
ssl_creds = grpc.ssl_channel_credentials(cert)
channel = grpc.secure_channel('playground-lnd:10009', ssl_creds)
stub = lightningstub.LightningStub(channel)
request = lnrpc.ChannelGraphRequest(include_unannounced=True)
response = stub.DescribeGraph(request, metadata=[('macaroon', macaroon)])
```

```python
response
```

<!-- #region -->
Response is a object containing:
```python
# { 
#     "nodes": <array LightningNode>,
#     "edges": <array ChannelEdge>,
# }
```
<!-- #endregion -->

## Sample data


Use this to test more realistic graph data (offline).

```python
import json

from collections import namedtuple

# set up namedtuples so we can access the sample data in the same manner as grpc response data
Response = namedtuple('Response', ['nodes', 'edges'] )
Node = namedtuple('Node', ['last_update', 'pub_key', 'alias', 'addresses', 'color', 'features'])
Edge = namedtuple('Edge', ['channel_id', 'chan_point', 'last_update', 'node1_pub', 'node2_pub', 'capacity', 'node1_policy', 'node2_policy'])

def get_describegraph_json(filename='describegraph.json'):
    with open(filename) as f:
        dg = json.load(f)
    return Response([Node(**node) for node in dg['nodes']],
                    [Edge(**edge) for edge in dg['edges']])
```

```python
response = get_describegraph_json()
```

## nodes

```python
response.nodes[0]
```

## edges

```python
response.edges[0]
```

## Assembling Graph


Use a MultiDiGraph to represent multiple channels between nodes. After gathering all channel information, we will convert this to an undirected graph with one channel per node pair.

```python
from dashboard import get_node_multigraph, get_directed_nodes, get_path, multipath_layout, get_edge_posns, plot_multipath
```

```python
MG = get_node_multigraph(response)
DG = get_directed_nodes(MG)
```

## Weighted shortest paths
We want to restrict the visualization to just the paths the user is interested for potential payments.
In liue of bos-computed paths, we will generate some candidate paths based on a weighted path analysis. This requires two nodes that are not already connected.

```python
nodes = list(DG.nodes.keys())
node1 = nodes[0]
node2 = nodes[-1]
node3 = '03ffda4c936c0f581c63ed6c29425e69f0df0471eb5adeb34e3b8ea263a48d277d'
node4 = '03ffdfa7856778263cf1bc0e14dde4de5da537c6672eaee014f95da2e62cea0b44'
```

```python
trip = node1, node2
path, path_nodes, path_posns = get_path(DG, trip[0], trip[1], 10)
path_pos = multipath_layout(path, path_nodes, path_posns, iterations=50, seed=1)
path_edge_pos = get_edge_posns(path, path_pos)
print('{} -> {}'.format(path.nodes[trip[0]]['alias'], path.nodes[trip[1]]['alias']))

plot_multipath(path, path_pos, path_edge_pos, [trip[0], trip[1]])
```

```python
node5='030f2c70ce2e9a0aa20457f0e26be4f768f5e0e5b12ae81e5814145f52ecc6d1ec'
```

```python
trip = node1, node5
path, path_nodes, path_posns = get_path(DG, trip[0], trip[1], 10)
path_pos = multipath_layout(path, path_nodes, path_posns, iterations=50, seed=1)
path_edge_pos = get_edge_posns(path, path_pos)
print('{} -> {}'.format(path.nodes[trip[0]]['alias'], path.nodes[trip[1]]['alias']))
plot_multipath(path, path_pos, path_edge_pos, [trip[0], trip[1]])

```

average the x-positions for degree=2. Should be able to linearly interpolate via pandas with gap filling.


# Dashboard

The idea is the user selects an origin node and a downstream node.

```python
from jupyter_dash import JupyterDash
import dash
import dash_core_components as dcc
import dash_html_components as html

from psidash import load_app # for production
from psidash.psidash import get_callbacks, load_conf, load_dash, load_components, assign_callbacks
import flask

from dash.exceptions import PreventUpdate
from networkx import NetworkXNoPath, descendants

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
    options = [{'label': DG.nodes[node]['alias'], 'value': node} for node in DG.nodes]
    return options, options[0]['value']

@callbacks.update_node_2_options
def update_node_select(node_1):
    if node_1 is None:
        raise PreventUpdate
    options = [{'label': DG.nodes[node]['alias'], 'value': node} for node in descendants(DG, node_1)]
    if len(options) > 0:
        return options, options[-1]['value']
    else:
        return options, ''

@callbacks.update_node_graph
def render(node_1, node_2):
    trip = node_1, node_2
    if (node_1 in DG.nodes) & (node_2 in DG.nodes):
        pass
    else:
        raise PreventUpdate
    try:
        path, path_nodes, path_posns = get_path(DG, trip[0], trip[1], 10)
    except NetworkXNoPath:
        raise PreventUpdate
    path_pos = multipath_layout(path, path_nodes, path_posns, iterations=50, seed=1)
    path_edge_pos = get_edge_posns(path, path_pos)
    print('{} -> {}'.format(path.nodes[trip[0]]['alias'], path.nodes[trip[1]]['alias']))
    return plot_multipath(path, path_pos, path_edge_pos, [trip[0], trip[1]])

if __name__ == '__main__':
    app.run_server(host='0.0.0.0', port=8050, mode='external', debug=True)
```

```python
def find_node(G, key, value):
    for node in G.nodes:
        if G.nodes[node][key] == value:
            return node
```

## Minimum Spanning Tree

The MST is a subgraph of the network that allows all nodes to reach each other. This reduces the number of edges in the final visualization. This also allows us to identify important junctions in the network.

```python
def get_node_policies(response):
    npolicies = 0
    policies = set()
    for edge in response.edges:
        if edge.node1_policy is not None:
            policies.add(tuple(sorted((edge.node1_pub, edge.node2_pub))))
        if edge.node2_policy is not None:
            policies.add(tuple(sorted((edge.node1_pub, edge.node2_pub))))
    return policies
```

```python
policies = get_node_policies(response)
len(policies) # may be duplicates since the same pair of nodes may have multiple channels
```

The fraction of channels with node policies to those without.

```python
len(policies)/len(response.edges)
```

Need to weight by fees.

```python
DG.edges['02e02d1e391733f2bd7e13d9cfd47d6d5c71ed65eafaaf801c194f13da227f8b81', '031c7ecff228dfe6054307ee49c8616998af5f8d4436f13c07d211aeb6c0ec87f7']
```

```python
T = nx.minimum_spanning_tree(DG.to_undirected(), weight='avg_fee')
```

```python
initial_posns = get_initial_node_posn(T)
```

```python
pos = get_layout(T, initial_posns, 'spring', iterations=2)
pos
```

```python
edge_pos = get_edge_posns(T, pos)
```

The below graph makes it hard to see the capacity available to bidirectional channels. That's ok, because we don't actually have information on bidirectional channels!

```python
capacity.loc['02001bcff2e27f6aa2aa8e68c7e5944bcbf5daf4954963e5a1ce2ab6f5386d0342']
```

```python
pos['capacity'] = capacity[pos.index]
pos.head()
```

```python
fig
```

# Degree
The degree of a node is the number of connections to that node. This may also be weighted by channel capacity.

```python
import matplotlib.pyplot as plt
```

```python
np.log10(pd.DataFrame(G.degree(), columns=['node', 'degree']).set_index('node').degree).hist()
```

```python
plt.show()
```

```python
np.log10(pd.DataFrame(G.degree(weight='capacity'), columns=['node', 'degree']).set_index('node').degree).hist()
```

```python
plt.show()
```

To examine the effect of attacks on larger nodes, we could prune the graph based on degree and see how that effects the minimum spanning tree and other global metrics (average shortest path, etc).


# K-components

```python
# Petersen graph has 10 nodes and it is triconnected, thus all
# nodes are in a single component on all three connectivity levels
from networkx.algorithms import approximation as apxa
# G = nx.petersen_graph()
k_components = apxa.k_components(G)
k_components
```

```python

```
