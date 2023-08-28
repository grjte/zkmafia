//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@semaphore/interfaces/ISemaphore.sol";
import "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import {PoseidonT3} from "poseidon-solidity/PoseidonT3.sol";


import "./IZKMafiaGame.sol";
import "./ZKMafiaInstance.sol";

    // /**
    //  * @notice Verify a Ultra Plonk proof
    //  * @param _proof - The serialized proof
    //  * @param _publicInputs - An array of the public inputs
    //  * @return True if proof is valid, reverts otherwise
    //  */
    // function verify(bytes calldata _proof, bytes32[] calldata _publicInputs) external view returns (bool) {

abstract contract ZKMafiaGame is IZKMafiaGame {
    using IncrementalBinaryTree for IncrementalTreeData;
    using ZKMafiaInstance for Game;

    // ISemaphore public semaphore;
    uint256 internal _gameCounter;

    // A new semaphore group is created each game 
    // this defacto serves as the player status. If the player
    // is not present in this group they cannot play.
    ISemaphore semaphore;     

    // groupId => Game
    mapping(uint256 => Game) internal games;

    function _createGame() internal virtual returns (uint256) {

        uint256 groupId = _gameCounter;
        semaphore.createGroup(groupId, 20, address(this));
        games[groupId].init(groupId);

        return groupId;
    }

    function _joinGame(uint256 groupId, uint256 identityCommitment, uint256 pubKey) internal virtual {
        Game storage game = games[groupId];
        game.players.push(pubKey);
        semaphore.addMember(groupId, identityCommitment);
    }

    function _startGame(uint256 groupId) internal virtual {
        Game storage game = games[groupId];

        uint256 numPlayers = game.players.length;

        // set the mafia counter
        game.mafiaCounter = uint8((numPlayers * 3)/10);
        if (game.mafiaCounter == 0) {
            game.mafiaCounter = 1;
        }
        uint256 villager = 0;
        uint256 mafia = 1;

        // insert all pubKeys into the tree
        // update the status of players now that game has started
        // initialize arrays
        for (uint256 i = 0; i < game.players.length; i++) {
            uint256 playerKey = game.players[i];

            game.status.push(Status.PENDING_ACTION);
            // game.pubKeys.insert(playerKey);
            game.voteTally.push(0);

            if (i < game.mafiaCounter) {
                game.roles.push(mafia);
            } else {
                game.roles.push(villager);
            }
            // add the validActions to the tree
            game.validActions.insert(
                uint256(keccak256(abi.encodePacked(mafia, game.players[i])))
            );
            game.validActionsTable.push(
                ValidAction({
                    role: 1,
                    target: game.players[i]
                })
            );
        }

        // fill out validActionsTable
        game.validActionsTable.push(
            ValidAction({
                role: 0,
                target: 0 
            })
        );
        // add the validActions to the tree
        game.validActions.insert(
            uint256(keccak256(abi.encodePacked(villager, villager)))
        );

        game.round = Round.Shuffle;
    }

    function _initializePlayerRolesTree(uint256 groupId) internal virtual {
        Game storage game = games[groupId];
        for (uint256 i = 0; i < game.roles.length; i++) {
            uint256 leaf = uint256(keccak256(abi.encodePacked(game.players[i], game.roles[i])));
            game.playerRoles.insert(leaf);
        }
    }


    function _refreshSemaphoreGroup(uint256 groupId) internal virtual {
        semaphore.createGroup(groupId, 20, address(this));
    }

    function _refreshPlayerStatus(uint256 groupId) internal virtual {
        Game storage game = games[groupId];
        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.status[i] == Status.ACTIVE) {
                game.status[i] = Status.PENDING_ACTION;
            }
        }
    } 

    function _refreshValidActionsTable(uint256 groupId) internal virtual {
        Game storage game = games[groupId];
        uint256[] storage remainingPlayers;

        delete game.validActionsTable;
        game.validActionsTable.push(
            ValidAction({
                role: 0,
                target: 0 
            })
        );

        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.status[i] != Status.INACTIVE) {
                game.validActionsTable.push(
                    ValidAction({
                        role: 1,
                        target: game.players[i]
                    })
                );
            }
        }
    }


    function _removePlayerWithPubKey(
        uint256 groupId, 
        uint256 pubKey, 
        uint256[] calldata proofSiblings,
        uint8[] calldata proofPathIndices
    ) internal virtual {
        Game storage game = games[groupId];
        (bool found, uint256 index) = game.getIndexForPubKey(pubKey);
        require(found);
        require(game.status[index] == Status.WAITING_REVEAL);

        uint256 mafia = 1;
        uint256 leaf = uint256(keccak256(abi.encodePacked(mafia, pubKey)));
        game.validActions.remove(
            leaf,
            proofSiblings,
            proofPathIndices
        );
        game.status[index] = Status.INACTIVE;
    }

    function _resetVoteTally(uint256 groupId) internal virtual {
        Game storage game = games[groupId];
        for (uint256 i = 0; i < game.players.length; i++) {
            game.voteTally[i] = 0;
        }
    }

    // TODO:
    // we need a function to compute the aggregate public key and also to do the decryption
    // like an "el gamal" contract

    function getRoleForPlayer(uint256 playerPubKey) external view returns (uint256) {

    }


    function getActiveGroupForGame(uint256 gameId) external view returns (uint256) {

    }
}