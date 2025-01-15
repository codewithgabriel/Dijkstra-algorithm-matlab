classdef FibonacciHeap
    properties
        MinNode   % Node with the minimum key
        Nodes     % Array of Fibonacci tree nodes
        NumNodes  % Number of nodes in the heap
    end
    
    methods
        % Constructor
        function obj = FibonacciHeap()
            obj.MinNode = [];
            obj.Nodes = {};
            obj.NumNodes = 0;
        end
        
        % Insert a node into the heap
        function insert(obj, node, key)
            newNode = struct('Node', node, 'Key', key, 'Child', [], 'Degree', 0, 'Marked', false, 'Next', []);
            if isempty(obj.MinNode) || key < obj.MinNode.Key
                obj.MinNode = newNode;
            end
            obj.Nodes{end+1} = newNode;
            obj.NumNodes = obj.NumNodes + 1;
        end
        
        % Extract the node with the minimum key
        function [node, key] = extractMin(obj)
            if isempty(obj.MinNode)
                node = [];
                key = [];
                return;
            end
            
            node = obj.MinNode.Node;
            key = obj.MinNode.Key;
            
            % Merge children of the min node into the root list
            if ~isempty(obj.MinNode.Child)
                obj.Nodes = [obj.Nodes, obj.MinNode.Child]; % Add children to root list
            end
            
            % Remove the MinNode
            obj.MinNode = obj.MinNode.Next;
            obj.NumNodes = obj.NumNodes - 1;
            
            % Consolidate the heap
            obj = obj.consolidate();
        end
        
        % Consolidate the heap by merging trees of the same degree
        function obj = consolidate(obj)
            if isempty(obj.Nodes)
                return;
            end
            
            maxDegree = floor(log2(obj.NumNodes));
            buckets = cell(1, maxDegree + 1);
            
            % Traverse root list and consolidate trees of same degree
            current = obj.MinNode;
            while ~isempty(current)
                degree = current.Degree;
                while ~isempty(buckets{degree})
                    other = buckets{degree};
                    % Merge the two trees
                    current = obj.mergeTrees(current, other);
                    buckets{degree} = [];
                    degree = degree + 1;
                end
                buckets{degree} = current;
                current = current.Next;
            end
            
            % Rebuild the root list from the buckets
            obj.MinNode = [];
            for i = 1:maxDegree
                if ~isempty(buckets{i})
                    if isempty(obj.MinNode) || buckets{i}.Key < obj.MinNode.Key
                        obj.MinNode = buckets{i};
                    end
                end
            end
        end
        
        % Helper method to merge two Fibonacci trees of the same degree
        function [result] = mergeTrees(obj, tree1, tree2)
            if tree1.Key > tree2.Key
                temp = tree1;
                tree1 = tree2;
                tree2 = temp;
            end
            % Make tree2 a child of tree1
            tree2.Next = tree1.Child;
            tree1.Child = tree2;
            tree1.Degree = tree1.Degree + 1;
            tree2.Marked = false;
            result = tree1;
        end
        
        % Decrease the key of a node
        function decreaseKey(obj, node, newKey)
            % Find the node and decrease the key
            for i = 1:length(obj.Nodes)
                if obj.Nodes{i}.Node == node
                    obj.Nodes{i}.Key = newKey;
                    break;
                end
            end
            
            % Check if the key violation occurs and cascade cut if necessary
            obj.MinNode = obj.getMinNode();
        end
        
        % Get the minimum node in the heap
        function minNode = getMinNode(obj)
            minNode = [];
            minKey = inf;
            for i = 1:length(obj.Nodes)
                if obj.Nodes{i}.Key < minKey
                    minKey = obj.Nodes{i}.Key;
                    minNode = obj.Nodes{i};
                end
            end
        end
        
        % Check if the heap is empty
        function isEmpty = isEmpty(obj)
            isEmpty = obj.NumNodes == 0;
        end
    end
end
