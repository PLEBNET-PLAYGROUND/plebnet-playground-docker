
# About

This directory contains setup necessary for creating dashboard visualizations of the lightning network

The grpc instructions are here https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md


## Accessing node graph though lightning-grpc

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

## nodes

```python
len(response.nodes)
```

```python
for node in response.nodes:
    print(node.alias)
```

```python
node
```

```python
node.pub_key
```

## edges

```python
for i, edge in enumerate(response.edges):
    print(i, edge.channel_id, edge.node1_pub)
```

```python
edge
```

## Assembling Graph

```python
import networkx as nx
```

Use a MultiDiGraph to represent multiple channels between nodes.

```python
G = nx.MultiDiGraph()
```

add nodes

```python
G.add_nodes_from(((node.pub_key, dict(alias=node.alias, last_update=node.last_update)) for node in response.nodes))
G.number_of_nodes()
```

Add edges. Use `channel_id` as edge keys to so future updates don't duplicate edges.

```python
edge_iterable = [(edge.node1_pub, edge.node2_pub, edge.channel_id, dict(capacity=edge.capacity)) for edge in response.edges]
```

```python
channel_ids = G.add_edges_from(edge_iterable)
G.number_of_edges()
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

## Layout

```python
from plotly.offline import iplot, init_notebook_mode
import plotly.graph_objs as go
```

```python
init_notebook_mode(connected=True)
```

```python
G.nodes['023627c64b010c51ec961a5e2f0a140a4f6f61ccbb008616004ed3a51a143e0a44']['alias']
```

```python
import pandas as pd
```

```python
G.nodes
```

```python
get_initial_node_posn(G)
```

```python
pos = pd.DataFrame.from_dict(nx.spring_layout(G,
#                                               pos=get_initial_node_posn(G),
                                             ),
                             orient='index', columns = ['x', 'y'])
pos
```

```python
pos['alias'] = [G.nodes[_]['alias'] for _ in pos.index]
pos
```

```python
G.edges['023627c64b010c51ec961a5e2f0a140a4f6f61ccbb008616004ed3a51a143e0a44', '03ee9d906caa8e8e66fe97d7a76c2bd9806813b0b0f1cee8b9d03904b538f53c4e', 10580600394153984]
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

edge_pos = pd.DataFrame(get_edge_posns(G))
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

The below graph makes it hard to see the capacity available to bidirectional channels.

```python
fig = go.Figure(data=[
    go.Scatter(x=pos.x, y=pos.y, text=pos.alias, hoverinfo='text', mode='markers'),
    go.Scatter(x=edge_x, y=edge_y, hoverinfo='text', mode='lines'),
    go.Scatter(x=edge_pos.x_avg, y=edge_pos.y_avg, text=edge_pos.capacity, hoverinfo='text', mode='markers'),
])

fig
```

```python

```
