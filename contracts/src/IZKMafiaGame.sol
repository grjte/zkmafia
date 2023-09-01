//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IZKMafiaGame {
    /// @dev Emitted when a new group is created.
    /// @param gameId: Id of the group.
    event GameCreated(uint256 indexed gameId);
    /// @dev Emitted when a new role pair is added.
    /// @param gameId: id of the semaphore group.
    /// @param index: Identity commitment index.
    /// @param roleHash: New role hash.
    /// @param merkleTreeRoot: New root hash of the tree.
    event PlayerRoleAdded(uint256 indexed gameId, uint256 index, uint256 roleHash, uint256 merkleTreeRoot);
}
