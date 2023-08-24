//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@semaphore/interfaces/ISemaphore.sol";

contract ZKMafia {
    ISemaphore public semaphore;

    uint256 public groupId;

    constructor(address semaphoreAddress, uint256 _groupId) {
        semaphore = ISemaphore(semaphoreAddress);
        groupId = _groupId;

        semaphore.createGroup(groupId, 20, address(this));
    }

    function joinGroup(uint256 identityCommitment) external {
        semaphore.addMember(groupId, identityCommitment);
    }

    function sendSignal(
        uint256 signal,
        uint256 merkleTreeRoot,
        uint256 nullifierHash,
        uint256[8] calldata proof
    ) external {
        semaphore.verifyProof(groupId, merkleTreeRoot, signal, nullifierHash, groupId, proof);
    }
}
