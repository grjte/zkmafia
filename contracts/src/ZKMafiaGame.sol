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

    uint256 internal _gameCounter;

    // A new semaphore group is created each game 
    // this defacto serves as the player status. If the player
    // is not present in this group they cannot play.
    ISemaphore semaphore;     

    // gameId => Game
    mapping(uint256 => Game) internal games;

    function _createGame() internal virtual returns (uint256) {

        uint256 gameId = _gameCounter;
        _gameCounter++;
        semaphore.createGroup(gameId, 20, address(this));
        games[gameId].init(gameId);

        emit GameCreated(gameId);
        return gameId;
    }

    function _joinGame(uint256 gameId, uint256 identityCommitment, uint256 pubKey) internal virtual {
        Game storage game = games[gameId];
        game.players.push(pubKey);
        semaphore.addMember(gameId, identityCommitment);
    }

    function _startGame(uint256 gameId) internal virtual {
        Game storage game = games[gameId];

        uint256 numPlayers = game.players.length;

        // set the mafia counter
        game.mafiaCounter = uint8((numPlayers * 3)/10);
        if (game.mafiaCounter == 0) {
            game.mafiaCounter = 1;
        }
        uint256 villager = 0;
        uint256 mafia = 1;
        uint256 actionHash = 0;

        // insert all pubKeys into the tree
        // update the status of players now that game has started
        // initialize arrays
        for (uint256 i = 0; i < game.players.length; i++) {
            // uint256 playerKey = game.players[i];

            game.status.push(Status.PENDING_ACTION);
            // game.pubKeys.insert(playerKey);
            game.voteTally.push(0);

            if (i < game.mafiaCounter) {
                game.roles.push(mafia);
            } else {
                game.roles.push(villager);
            }
            // add the validActions to the tree
            actionHash = uint256(keccak256(abi.encodePacked(mafia, game.players[i]))) >> 8;
            game.validActions.insert(
                actionHash
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
        actionHash = uint256(keccak256(abi.encodePacked(villager, villager))) >> 8;
        game.validActions.insert(
            actionHash
        );

        game.round = Round.Shuffle;
    }

    function _initializePlayerRolesTree(uint256 gameId) internal virtual {
        Game storage game = games[gameId];
        for (uint256 i = 0; i < game.roles.length; i++) {
            uint256 roleHash = uint256(keccak256(abi.encodePacked(game.players[i], game.roles[i]))) >> 8;
            game.playerRoles.insert(roleHash);
        }
    }


    function _refreshPlayerStatus(uint256 gameId) internal virtual {
        Game storage game = games[gameId];
        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.status[i] == Status.ACTIVE) {
                game.status[i] = Status.PENDING_ACTION;
            }
        }
    } 

    function _refreshValidActionsTable(uint256 gameId) internal virtual {
        Game storage game = games[gameId];
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
        uint256 gameId, 
        uint256 pubKey, 
        uint256 identityCommitment,
        uint256[] calldata semaphoreProofSiblings,
        uint8[] calldata semaphorePathIndices
    ) internal virtual {
        Game storage game = games[gameId];
        (bool found, uint256 index) = game.getIndexForPubKey(pubKey);
        require(found);
        require(game.status[index] == Status.WAITING_REVEAL);

        semaphore.removeMember(
            gameId,
            identityCommitment,
            semaphoreProofSiblings,
            semaphorePathIndices
        );

        game.status[index] = Status.INACTIVE;
    }

    function _updateValidActionsTree(
        uint256 gameId
    ) internal virtual {
        Game storage game = games[gameId];
        uint256 mafia = 1;
        uint256 villager = 0;

        //we will completely reset, because we are not incrementally updating it and the call would require too many merkle proofs
        delete game.validActions;
        delete game.validActionsTable;

        uint256 zeroValue = uint256(keccak256(abi.encodePacked(gameId))) >> 8;
        uint256 actionHash = 0;
        game.validActions.init(8, zeroValue);

        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.status[i] != Status.INACTIVE) {
                actionHash = uint256(keccak256(abi.encodePacked(mafia, game.players[i]))) >> 8;
                game.validActions.insert(actionHash);
                game.validActionsTable.push(ValidAction({
                    role: mafia,
                    target: game.players[i]
                }));
            }
        }

        // fill out validActionsTable
        game.validActionsTable.push(
            ValidAction({
                role: 0,
                target: 0 
            })
        );
        // add the validActions to the tree
        actionHash = uint256(keccak256(abi.encodePacked(villager, villager))) >> 8;
        game.validActions.insert(
            actionHash
        );
    }

    function _privateRoundChecks(
        uint256 gameId,
        uint256 merkleTreeRoot,
        uint256 role,
        uint256 signal,
        uint256 nullifierHash,
        uint256 externalNullifier,
        uint256 [8] calldata semaphoreProof,
        bytes calldata playerProof
    ) internal virtual {
        Game storage game = games[gameId];
        require(game.round == Round.Private);

        bytes32[] memory _publicInputs = new bytes32[](4);  
        _publicInputs[0] = bytes32(role);
        _publicInputs[1] = bytes32(signal);
        _publicInputs[2] = bytes32(game.playerRoles.root);
        _publicInputs[3] = bytes32(game.validActions.root);

        // require(Verifier.verify(playerProof, _publicInputs), "Invalid proof of public key");
        // how do we make sure the proof is good? I guess the transaction is just reverted if it fails.

        semaphore.verifyProof(gameId, merkleTreeRoot, signal, nullifierHash, externalNullifier, semaphoreProof);
    }

    function _resetVoteTally(uint256 gameId) internal virtual {
        Game storage game = games[gameId];
        for (uint256 i = 0; i < game.players.length; i++) {
            game.voteTally[i] = 0;
        }
    }


    function getGameInfoForGameId(uint256 gameId) external view returns (GameInfo memory) {
        Game storage game = games[gameId];
        GameInfo memory gameInfo = GameInfo({
            round: game.round,
            previousRound: game.previousRound,
            numRounds: game.numRounds,
            aggregateKey: game.aggregateKey,
            mafiaCounter: game.mafiaCounter,
            roles: game.roles,
            players: game.players,
            status: game.status,
            validActionsTable: game.validActionsTable
        });

        return gameInfo;
    }
}