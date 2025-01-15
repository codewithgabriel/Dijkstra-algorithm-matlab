classdef BinaryHeap
    properties
        Heap  % Array of structs with fields 'Node' and 'Key'
        PositionMap  % Map from node to position in the heap
    end

    methods
        % Constructor
        function obj = BinaryHeap()
            obj.Heap = [];
            obj.PositionMap = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
        end

        % Insert a node into the heap
        function insert(obj, node, key)
            if isKey(obj.PositionMap, node)
                error('Node already exists in the heap.');
            end
            newNode = struct('Node', node, 'Key', key);
            obj.Heap = [obj.Heap; newNode];
            position = length(obj.Heap);
            obj.PositionMap(node) = position;
            obj.bubbleUp(position);
        end

        % Extract the node with the minimum key
        function [node, key] = extractMin(obj)
            if isempty(obj.Heap)
                error('Heap is empty.');
            end

            minNode = obj.Heap(1);
            node = minNode.Node;
            key = minNode.Key;

            % Move the last element to the root and bubble down
            obj.Heap(1) = obj.Heap(end);
            obj.PositionMap(obj.Heap(1).Node) = 1;
            obj.Heap(end) = [];
            remove(obj.PositionMap, node);
            obj.bubbleDown(1);
        end

        % Decrease the key of a node
        function decreaseKey(obj, node, newKey)
            if ~isKey(obj.PositionMap, node)
                error('Node not found in the heap.');
            end

            position = obj.PositionMap(node);
            if newKey >= obj.Heap(position).Key
                error('New key must be smaller than the current key.');
            end

            obj.Heap(position).Key = newKey;
            obj.bubbleUp(position);
        end

        % Check if the heap is empty
        function isEmpty = isEmpty(obj)
            isEmpty = isempty(obj.Heap);
        end

        % Helper: Bubble up
        function bubbleUp(obj, position)
            while position > 1
                parent = floor(position / 2);
                if obj.Heap(position).Key < obj.Heap(parent).Key
                    obj.swap(position, parent);
                    position = parent;
                else
                    break;
                end
            end
        end

        % Helper: Bubble down
        function bubbleDown(obj, position)
            n = length(obj.Heap);
            while true
                leftChild = 2 * position;
                rightChild = leftChild + 1;
                smallest = position;

                if leftChild <= n && obj.Heap(leftChild).Key < obj.Heap(smallest).Key
                    smallest = leftChild;
                end
                if rightChild <= n && obj.Heap(rightChild).Key < obj.Heap(smallest).Key
                    smallest = rightChild;
                end

                if smallest ~= position
                    obj.swap(position, smallest);
                    position = smallest;
                else
                    break;
                end
            end
        end

        % Helper: Swap two nodes in the heap
        function swap(obj, pos1, pos2)
            temp = obj.Heap(pos1);
            obj.Heap(pos1) = obj.Heap(pos2);
            obj.Heap(pos2) = temp;

            obj.PositionMap(obj.Heap(pos1).Node) = pos1;
            obj.PositionMap(obj.Heap(pos2).Node) = pos2;
        end
    end
end
