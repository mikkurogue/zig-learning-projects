// learn to write a binary tree here
const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

pub fn Tree(comptime T: type) type {
    return struct {
        const Self = @This();

        root: Node,

        pub const Node = struct {
            value: T,
            parent: ?*Node,
            leftmost_child: ?*Node,
            right_sibling: ?*Node,

            fn init(value: T) Node {
                return Node{
                    .value = value,
                    .parent = null,
                    .leftmost_child = null,
                    .right_sibling = null,
                };
            }
        };

        /// init tree
        pub fn init(value: T) Self {
            return Self{
                .root = Node.init(value),
            };
        }

        // TODO: create this function iterator to find the things
        // pub fn containsNode(tree: *Self, node: *Node) bool { }

        /// create new single node in memory
        pub fn allocNode(allocator: *Allocator) !*Node {
            return allocator.create(Node);
        }

        /// destroy a node that was created with `allocator`
        pub fn destroyNode(tree: *Self, node: *Node, allocator: *Allocator) !*Node {
            assert(tree.containsNode(node));
            allocator.destroy(node);
        }

        pub fn createNode(tree: *Self, value: T, allocator: *Allocator) !*Node {
            const node = try tree.allocNode(allocator);
            node.* = Node.init(value);
            return node;
        }

        pub fn insert(node: *Node, parent: *Node) void {
            node.parent = parent;
            node.right_sibling = parent.leftmost_child;
            parent.leftmost_child = node;
        }
        // TODO: create graft method
        // grafting is to add another tree at a specified position of the current tree
        // pub fn graft(tree: *Self, other: *Self, parent: *Node) void { }

        pub fn prune(tree: *Self, node: *Node) !void {
            assert(tree.containsNode(node));
            if (node.parent) |parent| {
                var ptr = &parent.leftmost_child;
                while (ptr.*) |sibling| : (ptr = &sibling.right_sibling) {
                    if (sibling == node) {
                        ptr.* = node.right_sibling;
                        break;
                    }
                }

                node.right_sibling = null;
                node.parent = null;
            }
        }
    };
}
