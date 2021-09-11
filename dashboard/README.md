# About

This directory contains setup necessary for creating dashboard visualizations of the lightning network

The grpc instructions are here https://github.com/lightningnetwork/lnd/blob/master/docs/grpc/python.md


## Accessing node graph data


Dashboard dependencies

```python
from dashboard import response
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
from dashboard import get_node_multigraph, get_directed_nodes, assign_capacity, get_path, multipath_layout, get_edge_posns, plot_multipath
```

```python
MG = get_node_multigraph(response)
DG = assign_capacity(get_directed_nodes(MG))
```

## Weighted shortest paths
We want to restrict the visualization to just the paths the user is interested for potential payments.
In liue of bos-computed paths, we will generate some candidate paths based on a weighted path analysis. This requires two nodes that are not already connected.

```python
nodes = list(DG.nodes.keys())
node1 = nodes[0]
node2 = list(descendants(DG, node1))[-1]
```

```python
trip = node1, node2
path, path_nodes, path_posns = get_path(DG, trip[0], trip[1], 10)
path_pos = multipath_layout(path, path_nodes, path_posns, iterations=50, seed=1)
path_edge_pos = get_edge_posns(path, path_pos)
logging.info('{} -> {}'.format(path.nodes[trip[0]]['alias'], path.nodes[trip[1]]['alias']))

plot_multipath(path, path_pos, path_edge_pos, [trip[0], trip[1]])
```

# Dashboard

The idea is the user selects an origin node and a downstream node.

```python
from dashboard import app
```

```python
if __name__ == '__main__':
    app.run_server(host='0.0.0.0', port=8050, mode='inline', debug=True)
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
%load_ext autoreload
%autoreload 2
```

```python

```
