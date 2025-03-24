import networkx as nx
import plotly.graph_objects as go


def draw(dotfilename):
    graph = nx.DiGraph(nx.nx_pydot.read_dot(dotfilename))
    # Визуализация графа
    pos = nx.spring_layout(graph)
    edge_x, edge_y = [], []
    for edge in graph.edges():
        x0, y0 = pos[edge[0]]
        x1, y1 = pos[edge[1]]
        edge_x.extend([x0, x1, None])
        edge_y.extend([y0, y1, None])

    edge_trace = go.Scatter(
        x=edge_x, y=edge_y,
        line=dict(width=0.5, color='#888'),
        hoverinfo='none',
        mode='lines')

    node_x, node_y  = [], []
    for node in graph.nodes():
        x, y = pos[node]
        node_x.append(x)
        node_y.append(y)

    node_trace = go.Scatter(
        x=node_x, y=node_y, mode='markers', hoverinfo='text',
        marker=dict(showscale=True,
            colorscale='YlGnBu', reversescale=True, color=[], size=10,
            colorbar=dict(
                thickness=15,
                title='Node Connections',
                xanchor='left',
                titleside='right'
            ), line_width=2))

    node_adjacencies = []
    node_text = []
    for node, adjacencies in enumerate(graph.adjacency()):
        node_adjacencies.append(len(adjacencies[1]))
        node_text.append(str(adjacencies[0]))

    node_trace.marker.color = node_adjacencies
    node_trace.text = node_text


    fig = go.Figure(data=[edge_trace, node_trace],
                layout=go.Layout(
                    title='<br>Dependency graph', titlefont_size=16, showlegend=False,
                    # hovermode='closest',
                    margin=dict(b=20,l=5,r=5,t=40),
                    annotations=[ dict(
                        showarrow=False,
                        xref="paper", yref="paper",
                        x=0.005, y=-0.002 ) ],
                    xaxis=dict(showgrid=False, zeroline=False, showticklabels=False),
                    yaxis=dict(showgrid=False, zeroline=False, showticklabels=False))
                    )
    fig.show()
