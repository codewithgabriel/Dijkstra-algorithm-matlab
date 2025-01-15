classdef BinomialHeap
    properties
        MinNode   % Node with the minimum key
        Trees     % Array of binomial trees
    end
    
    methods
        % Constructor
        function obj = BinomialHeap()
            obj.MinNode = [];
            obj.Trees = {};
        end
        
        % Insert a node into the heap
        function insert(obj, node, key)
            newNode = struct('Node', node, 'Key', key, 'Child', [], 'Sibling', [], 'Degree', 0);
            obj.Trees{end+1} = newNode; % Add the new node as a tree
            if isempty(obj.MinNode) || key < obj.MinNode.Key
                obj.MinNode = newNode;
            end
        end
        
        % Merge two binomial heaps
        function obj = merge(obj, otherHeap)
            % Merge trees from both heaps
            mergedTrees = obj.Trees;
            for i = 1:length(otherHeap.Trees)
                mergedTrees{end+1} = otherHeap.Trees{i};
            end
            
            % Consolidate trees
            obj.Trees = {};
            obj.MinNode = [];
            for i = 1:length(mergedTrees)
                tree = mergedTrees{i};
                if isempty(obj.Trees{i})
                    obj.Trees{i} = tree;
                else
                    obj.Trees{i} = obj.mergeTrees(obj.Trees{i}, tree);
                end
            end
        end
        
        % Helper method to merge two trees of the same degree
        function [resultTree] = mergeTrees(obj, tree1, tree2)
            if tree1.Key < tree2.Key
                tree1.Sibling = tree2;
                resultTree = tree1;
            else
                tree2.Sibling = tree1;
                resultTree = tree2;
            end
        end
        
        % Extract the node with the minimum key
        function [node, key] = extractMin(obj)
            if isempty(obj.Trees)
                node = [];
                key = [];
                return;
            end
            [key, idx] = min([obj.Trees{:}.Key]);
            node = obj.Trees{idx}.Node;
            obj.Trees(idx) = []; % Remove the tree with the min node
            
            % Rebuild the heap by merging the trees
            obj = obj.merge(obj);
        end
        
        % Decrease the key of a node
        function decreaseKey(obj, node, newKey)
            for i = 1:length(obj.Trees)
                if obj.Trees{i}.Node == node
                    obj.Trees{i}.Key = newKey;
                    break;
                end
            end
            % Update minNode if necessary
            obj.MinNode = obj.getMinNode();
        end
        
        % Get the minimum node in the heap
        function minNode = getMinNode(obj)
            minNode = [];
            minKey = inf;
            for i = 1:length(obj.Trees)
                if obj.Trees{i}.Key < minKey
                    minKey = obj.Trees{i}.Key;
                    minNode = obj.Trees{i};
                end
            end
        end
        
        % Check if the heap is empty
        function isEmpty = isEmpty(obj)
            isEmpty = isempty(obj.Trees);
        end
    end
end
