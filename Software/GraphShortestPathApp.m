function GraphShortestPathApp()
    % Main figure
    fig = uifigure('Name', 'Graph Shortest Path App', 'Position', [100, 100, 1000, 700]);
    
    % UI Components
    % File selection
    lblFile = uilabel(fig, 'Text', 'Selected File:', 'Position', [20, 650, 100, 22]);
    filePath = uilabel(fig, 'Text', '', 'Position', [120, 650, 300, 22], 'HorizontalAlignment', 'left');
    btnLoadFile = uibutton(fig, 'Text', 'Load CSV File', 'Position', [20, 620, 100, 30], ...
                           'ButtonPushedFcn', @(btn, event) loadFileCallback());

    % Source and target input
    lblSource = uilabel(fig, 'Text', 'Source Node:', 'Position', [450, 650, 80, 22]);
    inputSource = uieditfield(fig, 'numeric', 'Position', [540, 650, 60, 22]);
    lblTarget = uilabel(fig, 'Text', 'Target Node:', 'Position', [620, 650, 80, 22]);
    inputTarget = uieditfield(fig, 'numeric', 'Position', [710, 650, 60, 22]);

    % Run button
    btnRun = uibutton(fig, 'Text', 'Run Algorithm', 'Position', [800, 650, 100, 30], ...
                      'ButtonPushedFcn', @(btn, event) runAlgorithmsCallback());

    % Graph visualization axes
    axGraph = uiaxes(fig, 'Position', [20, 300, 450, 300]);
    title(axGraph, 'Graph Visualization');
    
    % Execution time axes
    axTime = uiaxes(fig, 'Position', [500, 500, 450, 120]);
    title(axTime, 'Execution Times');
    
    % Throughput axes
    axThroughput = uiaxes(fig, 'Position', [500, 350, 450, 120]);
    title(axThroughput, 'Throughputs');

    % Complexity axes
    axComplexity = uiaxes(fig, 'Position', [500, 200, 450, 120]);
    title(axComplexity, 'Computational Complexities');
    
    % Metrics display
    txtMetrics = uitextarea(fig, 'Position', [20, 20, 930, 150], 'Editable', 'off');

    % Variables to store loaded data
    graphData = [];
    adjList = {};

    %% Callback Functions
    function loadFileCallback()
        % Load graph data from a CSV file
        [file, path] = uigetfile('*.*', 'Select Graph Data File');
        if isequal(file, 0)
            return; % User canceled
        end
        fullPath = fullfile(path, file);
        filePath.Text = fullPath;
        graphData = readtable(fullPath);
        
        % Create adjacency list
        source = graphData.Source;
        target = graphData.Target;
        weight = graphData.Weight;
        numNodes = max(max(source), max(target));
        adjList = cell(numNodes, 1);
        for i = 1:height(graphData)
            adjList{source(i)} = [adjList{source(i)}; target(i), weight(i)];
        end
        uialert(fig, 'File loaded successfully!', 'Success');
    end

    function runAlgorithmsCallback()
        % Run Dijkstra algorithms and display results
        if isempty(graphData)
            uialert(fig, 'Please load a graph dataset first!', 'Error');
            return;
        end

        sourceNode = inputSource.Value;
        targetNode = inputTarget.Value;

        if isnan(sourceNode) || isnan(targetNode)
            uialert(fig, 'Please enter valid source and target nodes!', 'Error');
            return;
        end

        % Show a loading dialog
        dlg = uiprogressdlg(fig, 'Title', 'Processing', ...
                            'Message', 'Running algorithms...', ...
                            'Indeterminate', 'on');

        %try
            % Create graph object for visualization
            G = digraph(graphData.Source, graphData.Target, graphData.Weight);

            % Run Dijkstra algorithms
            binaryHeap = BinaryHeapDijkstra(adjList);
            [distBinary, prevBinary] = binaryHeap.run(sourceNode);

            fibonacciHeap = FibonacciHeapDijkstra(adjList);
            [distFibonacci, prevFibonacci] = fibonacciHeap.run(sourceNode);

            binomialHeap = BinomialHeapDijkstra(adjList);
            [distBinomial, prevBinomial] = binomialHeap.run(sourceNode);

            % Reconstruct shortest paths
            pathBinary = reconstructPath(prevBinary, targetNode);
            pathFibonacci = reconstructPath(prevFibonacci, targetNode);
            pathBinomial = reconstructPath(prevBinomial, targetNode);

            if isempty(pathBinary) || isempty(pathFibonacci) || isempty(pathBinomial)
                uialert(fig, 'No path found between the source and target nodes!', 'Error');
                return;
            end

            % Highlight Binary Heap shortest path on the graph
            cla(axGraph);
            h = plot(G, 'Parent', axGraph, 'Layout', 'force', 'EdgeLabel', G.Edges.Weight, ...
                     'NodeColor', 'cyan', 'EdgeColor', 'black', ...
                     'LineWidth', 1.5, 'MarkerSize', 6);
            for i = 1:length(pathBinary) - 1
                highlight(h, pathBinary(i), pathBinary(i + 1), 'EdgeColor', 'red', 'LineWidth', 2.5);
            end
            highlight(h, sourceNode, 'NodeColor', 'green', 'MarkerSize', 8);
            highlight(h, targetNode, 'NodeColor', 'blue', 'MarkerSize', 8);

            % Convert paths to string format
            pathStrBinary = strjoin(string(pathBinary), ' -> ');
            pathStrFibonacci = strjoin(string(pathFibonacci), ' -> ');
            pathStrBinomial = strjoin(string(pathBinomial), ' -> ');

            % Display metrics
            binaryMetrics = binaryHeap.getPerformanceMetrics();
            fibonacciMetrics = fibonacciHeap.getPerformanceMetrics();
            binomialMetrics = binomialHeap.getPerformanceMetrics();

            metricsText = sprintf(['Binary Heap:\nExecution Time: %.4f s\nThroughput: %.4f\nComplexity: %s\nShortest Path: %s\nTotal Distance: %.4f\n\n', ...
                                   'Fibonacci Heap:\nExecution Time: %.4f s\nThroughput: %.4f\nComplexity: %s\nShortest Path: %s\nTotal Distance: %.4f\n\n', ...
                                   'Binomial Heap:\nExecution Time: %.4f s\nThroughput: %.4f\nComplexity: %s\nShortest Path: %s\nTotal Distance: %.4f'], ...
                                   binaryMetrics.ExecutionTime, binaryMetrics.Throughput, strcat("O((V + E) * log(V)) = ", num2str (binaryMetrics.Value) ) , pathStrBinary, distBinary(targetNode), ...
                                   fibonacciMetrics.ExecutionTime, fibonacciMetrics.Throughput,strcat ( "O(V + E + V * log(V)) = ", num2str (fibonacciMetrics.Value)) , pathStrBinary, distBinary(targetNode), ...
                                   binomialMetrics.ExecutionTime, binomialMetrics.Throughput,strcat("O(V * log(V) + E * log(V)) = ", num2str (binomialMetrics.Value)) , pathStrBinary, distBinary(targetNode));
            txtMetrics.Value = metricsText;

            % Plot Execution Times
            cla(axTime);
            bar(axTime, [binaryMetrics.ExecutionTime, fibonacciMetrics.ExecutionTime, binomialMetrics.ExecutionTime]);
            xticks(axTime, 1:3);
            xticklabels(axTime, {'Binary Heap', 'Fibonacci Heap', 'Binomial Heap'}); 
            ylabel(axTime, 'Time (seconds)');

            % Plot Throughputs
            cla(axThroughput);
            bar(axThroughput, [binaryMetrics.Throughput, fibonacciMetrics.Throughput, binomialMetrics.Throughput]);
            xticks(axThroughput, 1:3);
            xticklabels(axThroughput, {'Binary Heap', 'Fibonacci Heap', 'Binomial Heap'}); 
            ylabel(axThroughput, 'Throughput');

            % Plot Complexities
            cla(axComplexity);
            bar(axComplexity, [binaryMetrics.Value, fibonacciMetrics.Value, binomialMetrics.Value]);
            xticks(axComplexity, 1:3);
            xticklabels(axComplexity, {'Binary Heap', 'Fibonacci Heap', 'Binomial Heap'}); 
            ylabel(axComplexity, 'Complexity');

        %catch ME
         %   uialert(fig, ['An error occurred: ', ME.message], 'Error');
        %end

        % Close the loading dialog
        close(dlg);
    end

   function path = reconstructPath(prev, destination)
    % Reconstruct the shortest path from the source to the destination
    path = [];
    
    % Check if destination is valid
    while destination > 0 && ~isnan(destination)
        path = [destination, path];
        destination = prev(destination);
        
        % If we reach a point where no valid previous node exists, stop
        if destination == 0 || isnan(destination)
            break;
        end
    end
    
    % If the path is still empty, that means no valid path exists
    if isempty(path)
        path = NaN; % Return NaN if no path is found
    end
end
end
