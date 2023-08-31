// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";

enum Round {
    Lobby,
    Shuffle,
    Reveal,
    Private,
    Public,
    Announce,
    End
}

struct ValidAction {
    uint256 role;
    uint256 target;
}

enum Status {
    INACTIVE,
    ACTIVE,
    PENDING_ACTION,
    WAITING_REVEAL 
}

struct Game {

    Round round;
    Round previousRound;
    uint256 aggregateKey;
    uint256 numRounds;

    // (this array is overloaded to track shuffles, remasking, actions, and cast of votes)
    // 0 means inactive (or eliminated)
    // 1 means active, ready
    // 2 means active, waiting for action (remask, action, vote)
    // 3 means eliminated, waiting to announce role
    Status[] status;

    // players in the game: pubKey 
    uint256[] players; 
    
    // this should mirror the size of players array
    uint8[] voteTally;

    // roles: ciphertext
    uint256[] roles;

    uint8 mafiaCounter;

    // leaf: poseidon hash of the tuple (pubKey, encryptedRole)
    IncrementalTreeData playerRoles;

    ValidAction[] validActionsTable;
    // leaf: poseidon hash of the tuple (role, target)
    IncrementalTreeData validActions;
}

struct GameInfo {
    Round round;
    Round previousRound;
    uint256 numRounds;
    uint256 aggregateKey;
    uint8 mafiaCounter;
    uint256[] roles;
    uint256[] players;
    Status[] status;
    ValidAction[] validActionsTable;
}

library ZKMafiaInstance {
    using IncrementalBinaryTree for IncrementalTreeData;

    function init(
        Game storage self,
        uint256 gameId
    ) public {
        uint256 zeroValue = uint256(keccak256(abi.encodePacked(gameId))) >> 8;
        self.numRounds = 0; // this is used as externalNullifier

        //initialize merkle trees
        // self.pubKeys.init(8, zeroValue);
        self.playerRoles.init(8, zeroValue);
        self.validActions.init(8, zeroValue);

        self.round = Round.Lobby;
        self.previousRound = Round.Lobby;
    }


    function getIndexForPubKey(Game storage self, uint256 pubKey) public view returns (bool,uint256) {
        for (uint256 i = 0; i < self.players.length; i++) {
            if (self.players[i] == pubKey) {
                return (true, i); // Value found
            }
        }
        return (false, 0); // Value not found
    }


}