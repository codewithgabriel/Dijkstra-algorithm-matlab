classdef BinaryHeapDijkstra
    properties
        Graph      % Adjacency list representation of the graph
        Distances  % Array to store shortest distances
        Previous   % Array to store the previous node in the path
    end
    
    methods
        % Constructor
        function obj = BinaryHeapDijkstra(graph)
            obj.Graph = graph;
        end
        
        % Method to perform Dijkstra's algorithm
        function [dist, prev] = run(obj, source)
            numNodes = length(obj.Graph);
            obj.Distances = inf(1, numNodes); % Initialize distances to infinity
            obj.Previous = NaN(1, numNodes);  % Initialize previous nodes as NaN
            obj.Distances(source) = 0;       % Distance to source is zero
            
            % Initialize binary heap as a MATLAB array
            heap = [source, 0]; % Each row is [node, distance]
            
            while ~isempty(heap)
                % Extract the node with the minimum distance
                [~, idx] = min(heap(:, 2)); % Find index of smallest distance
                currNodeInfo = heap(idx, :);
                heap(idx, :) = [];          % Remove the processed node
                currNode = currNodeInfo(1);
                currDist = currNodeInfo(2);
                
                % Skip if the distance is outdated
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
                        
                        % Update or add to the heap
                        idx = find(heap(:, 1) == neighbor, 1);
                        if ~isempty(idx)
                            heap(idx, 2) = newDist; % Update distance
                        else
                            heap = [heap; neighbor, newDist]; % Add new node
                        end
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
            
            % Computational complexity: O((V + E) * log(V)) for Binary Heap
            numNodes = length(obj.Graph);
            numEdges = sum(cellfun(@(x) size(x, 1), obj.Graph));
            complexity = sprintf('O((%d + %d) * log(%d))', numNodes, numEdges, numNodes);

            complexity_value = (numNodes + numEdges) * log(numNodes);
            
            metrics = struct('ExecutionTime', executionTime, ...
                             'Throughput', 1 / executionTime, ...
                             'ComputationalComplexity', complexity, ...
                             'Value' , complexity_value);
        end
    end
end
