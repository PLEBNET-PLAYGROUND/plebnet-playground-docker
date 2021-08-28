
# About

This directory contains setup necessary for creating dashboard visualizations of the lightning network

The grpc instructions are here https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md


## Accessing node graph though lightning-grpc

```python
import numpy as np
```

```python
LND_DIR = '../volumes/lnd_datadir'
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
channel = grpc.secure_channel('localhost:10009', ssl_creds)
stub = lightningstub.LightningStub(channel)
request = lnrpc.ChannelGraphRequest(include_unannounced=True)
response = stub.DescribeGraph(request, metadata=[('macaroon', macaroon)])
# { 
#     "nodes": <array LightningNode>,
#     "edges": <array ChannelEdge>,
# }
```

## Sample data


Use this to test more realistic graph data.

```python
import json

from collections import namedtuple
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
edge
```

```python
G.nodes['02ad6fb8d693dc1e4569bcedefadf5f72a931ae027dc0f0c544b34c1c6f3b9a02b']
```

```python
G.nodes['03fab7f8655169ea77d9691d4bd359e97782cb6177a6f76383994ed9c262af97a5']
```

```python
npolicies = 0
for edge in response.edges:
    if edge.node1_policy is not None:
        npolicies += 1
```

```python
npolicies
```

```python
len(response.edges) - npolicies
```

```python
edge
```

## Assembling Graph

```python
import networkx as nx
```

Use a MultiDiGraph to represent multiple channels between nodes. After gathering all channel information, we will convert this to an undirected graph with one channel per node pair.

```python
MG = nx.MultiDiGraph()
```

add nodes

```python
MG.add_nodes_from(((node.pub_key, dict(alias=node.alias, color=node.color, last_update=node.last_update)) for node in response.nodes))
MG.number_of_nodes()
```

Add edges. Use `channel_id` as edge keys to so future updates don't duplicate edges.

```python
edge_iterable = [(edge.node1_pub, edge.node2_pub, edge.channel_id, dict(capacity=edge.capacity)) for edge in response.edges]
```

```python
channel_ids = MG.add_edges_from(edge_iterable)
MG.number_of_edges()
```

Create a fresh undirected graph

```python
G = nx.Graph()
```

Insert all node information from multi grid graph

```python
G.add_nodes_from(MG.nodes(data=True))
```

Accumulate capacity for all edges

```python
for node, neighbors in MG.adjacency():
#     print(node, MG.nodes[node]['alias'])
    for neighbor, v in neighbors.items():
#         print('\t{}:'.format(neighbor))
        capacity = 0
        for k_, v_ in v.items():
            capacity += int(v_['capacity'])
#             print('\t\t{}: {}'.format(k_, v_))
        G.add_edge(node, neighbor, capacity = capacity)
    
```

## Total node capacity
This is the sum of channel capacities available to a given node.

```python
def get_initial_node_posn(G):
    """get initial positions for each node based on last update and total capacity"""
    initial_node_pos = dict()
    for _, cap in G.degree(weight='capacity'):
        initial_node_pos[_] = float(G.nodes[_]['last_update']), float(cap)
    return initial_node_pos
```

## Weighted shortest paths
We want to restrict the visualization to just the paths the user is interested for potential payments.
In liue of bos-computed paths, we will generate some candidate paths based on a weighted path analysis.

```python
# nx.shortest_simple_paths(G, node1, node2)
```

```python
# next(nx.shortest_simple_paths(G, node1, node2))
```

## Minimum Spanning Tree

This reduces the number of edges in the final visualization.

```python
T = nx.minimum_spanning_tree(G)
```

```python
T
```

## Layout

```python
from plotly.offline import iplot, init_notebook_mode
import plotly.graph_objs as go
```

```python
init_notebook_mode(connected=True)
```

```python
import pandas as pd
import scipy
```

```python
initial_posns = get_initial_node_posn(T)
```

```python
pos = pd.DataFrame.from_dict(nx.spring_layout(T,
                                              pos=initial_posns,
                                              iterations=20,
                                             ),
                             orient='index', columns = ['x', 'y'])
pos
```

```python
pos['alias'] = [T.nodes[_]['alias'] for _ in pos.index]
pos['color'] = [T.nodes[_]['color'] for _ in pos.index]
pos
```

```python
from collections import defaultdict
```

```python
def get_edge_posns(G):
    """For each position"""
    edge_pos = defaultdict(list)
    for edge in G.edges:
        edge_pos[(edge[0], edge[1])].append(G.edges[edge]['capacity'])

    edge_cap = defaultdict(list)
    for edge in edge_pos:
        edge_cap['node1'].append(edge[0])
        edge_cap['node2'].append(edge[1])
        edge_cap['capacity'].append(sum(edge_pos[edge]))
    return edge_cap

edge_pos = pd.DataFrame(get_edge_posns(T))
edge_pos['x1'] = pos.loc[edge_pos.node1.values]['x'].values
edge_pos['y1'] = pos.loc[edge_pos.node1.values]['y'].values
edge_pos['x2'] = pos.loc[edge_pos.node2.values]['x'].values
edge_pos['y2'] = pos.loc[edge_pos.node2.values]['y'].values
edge_pos['empty'] = np.nan
edge_pos['x_avg'] = edge_pos[['x1', 'x2']].mean(axis=1)
edge_pos['y_avg'] = edge_pos[['y1', 'y2']].mean(axis=1)
edge_pos
```

```python
import numpy as np
```

```python
edge_x = edge_pos[['x1','x2', 'empty']].values.ravel()
```

```python
edge_y = edge_pos[['y1', 'y2', 'empty']].values.ravel()
```

The below graph makes it hard to see the capacity available to bidirectional channels. That's ok, because we don't actually have information on bidirectional channels!

```python
fig = go.Figure(data=[
    go.Scattergl(x=pos.x, y=pos.y, text=pos.alias, hoverinfo='text', marker=dict(color=pos.color), mode='markers'),
    go.Scattergl(x=edge_x, y=edge_y, hoverinfo='text', mode='lines'),
    go.Scattergl(x=edge_pos.x_avg, y=edge_pos.y_avg, text=edge_pos.capacity, hoverinfo='text', mode='markers'),
])

fig
```

```python

```
