//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// import "@semaphore/interfaces/ISemaphore.sol";
// import "@zk-kit/incremental-merkle-tree.sol/IncrementalBinaryTree.sol";
import "./ZKMafiaGame.sol";
import "./ZKMafiaInstance.sol";

contract ZKMafia is ZKMafiaGame {
    using ZKMafiaInstance for Game;
    
    constructor(address semaphoreAddress) {
        semaphore = ISemaphore(semaphoreAddress);
    }

    function createGame(uint256 identityCommitment, uint256 pubKey) external returns (uint256) {
        // validate proof they know the secret_key for pub_key 
        // pub_key is added to game array
        bytes32[] memory _publicInputs = new bytes32[](1); 
        _publicInputs[0] = bytes32(pubKey);

        // we'll have a handful of verify contracts, so going to have to keep track of them all somehow
        // require(Verifier.verify(_proof, _publicInputs), "Invalid proof of public key");

        // create new game
        uint256 gameId = _createGame();

        // call joinGame for the player
        _joinGame(gameId, identityCommitment, pubKey);

        return gameId;
    }

    function joinGame(uint256 gameId, uint256 identityCommitment, uint256 pubKey, bytes calldata proof) external {
        Game storage game = games[gameId];
        require(game.round == Round.Lobby);
        (bool exists, uint256 index) = game.getIndexForPubKey(pubKey);
        // TODO: max limit on number of players?
        require(game.players.length < 13);
        require(!exists);

        // validate proof they know the secret_key for pub_key 
        // pub_key is added to game array
        bytes32[] memory _publicInputs = new bytes32[](1); 
        _publicInputs[0] = bytes32(pubKey);

        // we'll have a handful of verify contracts, so going to have to keep track of them all somehow
        // require(Verifier.verify(proof, _publicInputs), "Invalid proof of public key");

        _joinGame(gameId, identityCommitment, pubKey);
    }


    function startGame(uint256 gameId, uint256 aggregateKey, bytes calldata proof) external {
        Game storage game = games[gameId];
        require(game.round == Round.Lobby);
        //TODO: min limit on number of players?
        require(game.players.length > 2);

        // we'll have a handful of verify contracts, so going to have to keep track of them all somehow
        // this proof should both prove the pubKey is theirs (and also prove the aggregate key is correct??)
        bytes32[] memory _publicInputs = new bytes32[](1);  
        _publicInputs[0] = bytes32(game.players[0]); // this is to prove that the known pubKey is the admin key

        // TODO:
        // if we want to prove correct aggregate key, we'll need to limit the number of public inputs to a set game size
        // instead we can just pretend there is the ability to "challenge" the aggregate key or something...
        // or figure out a good way for the contract to compute it

        // require(Verifier.verify(proof, _publicInputs), "Invalid proof of public key");

        // update the game state
        _startGame(gameId);
    }

    function publishShuffle(uint256 gameId, uint256 pubKey, bytes calldata proof, bytes32[12] calldata newEncryptedRoles) external {
        Game storage game = games[gameId];
        require(game.round == Round.Shuffle);

        // if every player has done the shuffle, we update the state of the game to now allow decryption tokens
        // here we don't care about anonyminity, so we can don't need to mess with semaphore and nullifier hashes
        (bool found, uint256 index) = game.getIndexForPubKey(pubKey);
        require(found);
        require(game.status[index] == Status.PENDING_ACTION);

        // receives proof of correct mask/remask and Semaphore signal and validates it
        // this proof should also validate the ownership of a certain pubKey
        // to prevent a single person from uploading all the shuffles themselves
        bytes32[] memory _publicInputs = new bytes32[](26);  
        _publicInputs[0] = bytes32(pubKey); // this is their pubKey
        _publicInputs[1] = bytes32(game.aggregateKey);
        // we fix the top size of the game to 12, and if there are less than 12 players, we will pad the inputs
        for (uint256 i = 2; i < 14; i++) {
            if (i > game.players.length - 1) {
                _publicInputs[i] = bytes32(0);
            } else {
                _publicInputs[i] = bytes32(game.roles[i-2]);
            }
        }
        for (uint256 i = 14; i < 26; i++) {
            _publicInputs[i] = newEncryptedRoles[i-14];
        }
        // require(Verifier.verify(_proof, _publicInputs), "Invalid proof of public key");
        // receives the updated encrypted deck
        uint256 numberPending = game.players.length;
        for (uint256 i = 0; i < game.players.length; i++) {
            // we expect that the pads will be appended to the shuffled deck
            // and we can just ignore them
            game.roles[i] = uint256(newEncryptedRoles[i]);
            if (game.status[i] == Status.ACTIVE) {
                numberPending = numberPending - 1;
            }
        }

        // if every player has done the shuffle, we update the state of the game to now allow decryption tokens
        // here we don't care about anonyminity, so we can don't need to mess with semaphore and nullifier hashes
        game.status[index] = Status.ACTIVE;

        // Move to the next round
        if (numberPending == 1) {
            game.round = Round.Reveal;
            _refreshPlayerStatus(gameId);
        }
    }

    function revealRoles(uint256 gameId, uint256 pubKey, bytes calldata proof, bytes32[12] calldata newDecryptedRoles) external {
        Game storage game = games[gameId];
        require(game.round == Round.Reveal);
        // we receive a proof and public input list of roles selected revealed, along with public index of player role 
        // they should also prove that they own the private key for pubKey
        // make sure that the index is indeed that player
        (bool found, uint256 index) = game.getIndexForPubKey(pubKey);
        require(found);
        bytes32[] memory _publicInputs = new bytes32[](26);  
        _publicInputs[0] = bytes32(pubKey); // this is their pubKey
        _publicInputs[1] = bytes32(index);
        for (uint256 i = 2; i < 26; i++) {
            if (i > 13) {
                _publicInputs[i] = newDecryptedRoles[i - 14];
            } else {
                // the default pad value is zero
                if (i > game.players.length - 1){
                    _publicInputs[i] = bytes32(0);
                } else {
                    _publicInputs[i] = bytes32(game.roles[i - 2]);
                }
            }
        }

        // verify the proof
        // require(Verifier.verify(_proof, _publicInputs), "Invalid proof of public key");

        // update the role array
        uint256 numberPending = game.players.length;
        for (uint256 i = 0; i < game.players.length; i++) {
            // we expect that the pads will be appended to the shuffled deck client-side
            // and we can just ignore them
            game.roles[i] = uint256(newDecryptedRoles[i]);
            if (game.status[i] == Status.ACTIVE) {
                numberPending = numberPending - 1;
            }
        }

        require(game.status[index] == Status.PENDING_ACTION);
        game.status[index] = Status.ACTIVE;
        // if every player has published decrypted roles, we update the state of the game to now be the first round

        if (numberPending == 1) {
            // create playerRoles tree
            _initializePlayerRolesTree(gameId);
            _refreshPlayerStatus(gameId);
            // this has the unfortunate consequence where the last person to decrypt pays more gas
            // not sure how to make this more equitable, but I suppose it's an incentive to decrypt first?
            game.round = Round.Private;
        }

    }

    function privateRound(
        uint256 gameId, 
        uint256[8] calldata semaphoreProof, 
        bytes calldata playerProof, 
        uint256 role,
        uint256 signal, 
        uint256 merkleTreeRoot, 
        uint256 nullifierHash,
        uint256 externalNullifier
    ) external {
        Game storage game = games[gameId];
        require(game.round == Round.Private);
        require(externalNullifier == game.numRounds);
        // we receive proof of valid action, action, and semaphore signal
        // 1. verify, they know a private key for pub key in the tree
        // 2. and a ciphertext decrypts to specific card role in the tree
        // 3. that (role, pub_key) is in the validActions tree 
        // 4. the public input should be the action and target
        _privateRoundChecks(
            gameId,
            merkleTreeRoot,
            role,
            signal,
            nullifierHash,
            externalNullifier,
            semaphoreProof,
            playerProof
        );

        // the game updates the state according to the action (for now it will just be kills)
        // the mafia has made a kill
        if (role == 1) {
            // kill player
            // we can overload the voteTally for now to track pending kills
            // add member to remove list

            // NOTE: we will let the mafia choose not to kill anyone ??
            if (signal != 0) {
                (bool found, uint256 index) = game.getIndexForPubKey(signal);
                require(found);
                
                game.voteTally[index] = 1;
            }
        }

        uint256 numberPending = game.players.length;
        uint256 lastPending = 0;
        for (uint256 i = 0; i < game.players.length; i++) {
            // we expect that the pads will be appended to the shuffled deck
            // and we can just ignore them
            if (game.status[i] != Status.PENDING_ACTION) {
                numberPending = numberPending - 1;
            } else {
                lastPending = i;
            }
        }
        // if it equals one this means that this transaction is the last pending transaction 
        if (numberPending != 1) {
            // the status of players is not actually mapped directly for anonymous purposes
            // instead we just scan for the next player which is PENDING_ACTION and use it for accounting
            // the nullifierHash of semaphore will make sure that each player has only voted once
            game.status[lastPending] = Status.ACTIVE;
        } else {
            // once all actions have been cast
            game.previousRound = Round.Private;
            bool foundEliminated = false;
            for (uint256 i = 0; i < game.voteTally.length; i++) {
                if (game.voteTally[i] == 1) {
                    game.status[i] = Status.WAITING_REVEAL;
                    foundEliminated = true;
                }
            }

            game.numRounds++;
            if (!foundEliminated) {
                // reset player status
                _refreshPlayerStatus(gameId);
                game.round = Round.Public;
            } else {
                game.round = Round.Announce;
            }
        }
    }

    function publicRound(
        uint256 gameId,
        uint256 signal, 
        uint256[8] calldata semaphoreProof, 
        uint256 merkleTreeRoot, 
        uint256 nullifierHash,
        uint256 externalNullifier
    ) external {
        Game storage game = games[gameId];
        require(externalNullifier == game.numRounds);
        require(game.round == Round.Public);

        (bool found, uint256 index) = game.getIndexForPubKey(signal);
        require(found);
        // you can't vote against a player who is already eliminated
        require(game.status[index] != Status.INACTIVE);

        semaphore.verifyProof(gameId, merkleTreeRoot, signal, nullifierHash, externalNullifier, semaphoreProof);
        game.voteTally[index] = game.voteTally[index] + 1;
        // we receive votes with semaphore signal — signal is pubKey to vote off
        // we tally the votes until all players cast vote
        // once all votes are cast we choose the person with the most votes to deactivate
        uint256 numberPending = game.players.length;
        uint256 lastPending = 0;
        for (uint256 i = 0; i < game.players.length; i++) {
            // we expect that the pads will be appended to the shuffled deck
            // and we can just ignore them
            if (game.status[i] != Status.PENDING_ACTION) {
                numberPending = numberPending - 1;
            } else {
                lastPending = i;
            }
        }

        if (numberPending != 1) {
            // the status of players is not actually mapped directly for anonymous purposes
            // instead we just scan for the next player which is PENDING_ACTION and use it for accounting
            // the nullifierHash of semaphore will make sure that each player has only voted once
            game.status[lastPending] = Status.ACTIVE;
        } else {
            // tally the votes
            uint256 maxVoteIndex = 0;
            uint256 maxVote = 0;
            game.numRounds++;

            //TODO: what to do if there is a tie?
            for (uint256 i = 0; i < game.players.length; i++) {
                if (game.voteTally[i] > maxVote) {
                    maxVoteIndex = i;
                    maxVote = game.voteTally[i];
                }
            }

            game.status[maxVoteIndex] = Status.WAITING_REVEAL;
            game.previousRound = Round.Public;
            game.round = Round.Announce;
        }

    }

    function announceRole(
        uint256 gameId,
        bool isMafia,
        uint256 pubKey,
        uint256 identityCommitment,
        uint256[] calldata semaphoreProofSiblings,
        uint8[] calldata semaphorePathIndices,
        bytes calldata proof
    ) external {
        Game storage game = games[gameId]; 
        require(game.round == Round.Announce);

        (bool found, uint256 index) = game.getIndexForPubKey(pubKey);
        require(found);
        // we receive a proof of knowledge of preimage for role which corresponds to a pub_key 
        // and it checks to make sure this pub_key is in the remove list 
        // and it checks the corresponding ciphertext decryptes to mafia
        // we feed in the ciphertext manually

        bytes32[] memory _publicInputs = new bytes32[](2);  
        _publicInputs[0] = bytes32(pubKey);
        _publicInputs[1] = bytes32(game.roles[index]);
        if (isMafia) {
            // require(Verifier.verify(_proof, _publicInputs), "Invalid proof of public key");
            game.mafiaCounter = game.mafiaCounter - 1;
        } else {
            // require(Verifier.verify(_proof, _publicInputs), "Invalid proof of public key");
        }
        _removePlayerWithPubKey(
            gameId, 
            pubKey,
            identityCommitment,
            semaphoreProofSiblings,
            semaphorePathIndices
        );
        
        // once everyone has announced their role we check endgame conditions
        if (game.mafiaCounter == 0) {
            // end game condition, the villagers win
            game.round = Round.End;
            return;
        }

        _announceRoleCheckPending(gameId);
    }

    function _announceRoleCheckPending(uint256 gameId) internal virtual {
        Game storage game = games[gameId];
        uint256 remainingPlayers = game.players.length;
        bool stillPendingAnnouncements = false;
        for (uint256 i = 0; i < game.players.length; i++) {
            if (game.status[i] == Status.INACTIVE) {
                remainingPlayers = remainingPlayers - 1;
            }
            if (game.status[i] == Status.WAITING_REVEAL) {
                stillPendingAnnouncements = true;
            }
        }

        if (remainingPlayers == game.mafiaCounter) {
            game.round = Round.End;
            return;
        } 

        if (!stillPendingAnnouncements) {
            // update player status
            _refreshPlayerStatus(gameId);
            // update valid action table
            _refreshValidActionsTable(gameId);

            if (game.previousRound == Round.Private) {
                game.round = Round.Public;
            } else {
                _resetVoteTally(gameId);
                game.round = Round.Private;
            }
        }
    }

    function endGame() external {
        // purely an "ideological victory"
        // the winner will be villagers if mafiaCounter is 0
        //for now we can just emit an event
    }
    
}
