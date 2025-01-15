classdef FibonacciHeapDijkstra
    properties
        Graph      % Adjacency list representation of the graph
        Distances  % Array to store shortest distances
        Previous   % Array to store the previous node in the path
        Heap       % Fibonacci Heap structure
    end
    
    methods
        % Constructor
        function obj = FibonacciHeapDijkstra(graph)
            obj.Graph = graph;
        end
        
        % Method to perform Dijkstra's algorithm
        function [dist, prev] = run(obj, source)
            numNodes = length(obj.Graph);
            obj.Distances = inf(1, numNodes); % Initialize distances to infinity
            obj.Previous = NaN(1, numNodes);  % Initialize previous nodes as NaN
            obj.Distances(source) = 0;       % Distance to source is zero
            
            % Initialize Fibonacci Heap
            obj.Heap = FibonacciHeap();
            for i = 1:numNodes
                if i == source
                    obj.Heap.insert(i, 0); % Insert source with distance 0
                else
                    obj.Heap.insert(i, inf); % Insert others with distance infinity
                end
            end
            
            % Dijkstra's algorithm
            while ~obj.Heap.isEmpty()
                % Extract the node with the minimum distance
                [currNode, currDist] = obj.Heap.extractMin();
                
                % Skip if the extracted distance is outdated
                if currDist > obj.Distances(currNode)
                    continue;
                end
                
                % Update distances for adjacent nodes
                for edge = obj.Graph{currNode}'
                    neighbor = edge(1);
                    weight = edge(2);
                    newDist = obj.Distances(currNode) + weight;
                    if newDist < obj.Distances(neighbor)
                        obj.Distances(neighbor) = newDist;
                        obj.Previous(neighbor) = currNode;
                        obj.Heap.decreaseKey(neighbor, newDist); % Decrease key in heap
                    end
                end
            end
            
            dist = obj.Distances;
            prev = obj.Previous;
        end
        
        % Method to compute and return performance metrics
        function metrics = getPerformanceMetrics(obj)
            tic; % Start timing
            [~, ~] = obj.run(1); % Run the algorithm from node 1
            executionTime = toc; % Stop timing
            
            % Computational complexity: O(V + E + V * log(V)) amortized for Fibonacci Heap
            numNodes = length(obj.Graph);
            numEdges = sum(cellfun(@(x) size(x, 1), obj.Graph));
            complexity = sprintf('O(%d + %d + %d * log(%d))', numNodes, numEdges, numNodes, numNodes);

            complexity_value = numNodes + numEdges + numNodes * log(numNodes);
            
            metrics = struct('ExecutionTime', executionTime, ...
                             'Throughput', 1 / executionTime, ...
                             'ComputationalComplexity', complexity, ...
                             'Value', complexity_value);
        end
    end
end
