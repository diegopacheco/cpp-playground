#include <iostream>
#include <vector>
#include <queue>

class Graph {
public:
    Graph(int numVertices) : numVertices(numVertices), adjList(numVertices) {}

    void addEdge(int u, int v) {
        adjList[u].push_back(v);
        adjList[v].push_back(u);
    }

    void printGraph() const {
        for (int v = 0; v < numVertices; ++v) {
            std::cout << "Vertex " << v << ": ";
            for (int neighbor : adjList[v]) {
                std::cout << neighbor << " ";
            }
            std::cout << std::endl;
        }
    }

    void bfs(int startVertex) const {
        std::vector<bool> visited(numVertices, false);
        std::queue<int> queue;

        visited[startVertex] = true;
        queue.push(startVertex);

        std::cout << "BFS starting from vertex " << startVertex << ": ";

        while (!queue.empty()) {
            int currentVertex = queue.front();
            queue.pop();
            std::cout << currentVertex << " ";

            for (int neighbor : adjList[currentVertex]) {
                if (!visited[neighbor]) {
                    visited[neighbor] = true;
                    queue.push(neighbor);
                }
            }
        }
        std::cout << std::endl;
    }

private:
    int numVertices;
    std::vector<std::vector<int>> adjList;
};

int main() {
    Graph g(6);

    g.addEdge(0, 1);
    g.addEdge(0, 2);
    g.addEdge(1, 3);
    g.addEdge(2, 4);
    g.addEdge(3, 5);
    g.addEdge(4, 5);

    std::cout << "Graph representation:\n";
    g.printGraph();

    g.bfs(0); // Breadth-first search starting from vertex 0

    return 0;
}