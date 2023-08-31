// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/ZKMafia.sol";
import "../src/ZKMafiaGame.sol";
import "../mocks/MockSemaphore.sol";
import "@semaphore/base/SemaphoreVerifier.sol";
import "@semaphore/interfaces/ISemaphoreVerifier.sol";

contract ZKMafiaTest is Test {
    ZKMafia public game;
    MockSemaphore private semaphore;
    SemaphoreVerifier private verifier;

    struct Player {
        uint256 identityCommitment;
        uint256 pubKey;
        uint256 privateKey;
        uint256 gameId;
    }

    // These are random 256 bit values from the keccak hash, but they will need to be within 254 bits
    Player player1 = Player({
        identityCommitment: 0x37843a10b6634a04a1d4e69053108ad0541ec5d4abac88c6cdb43497cd98c002 >> 8,
        pubKey: 0x7257f4c4c7ecebb66545404f8bd8c0d8e85c693edf68b62250ffa904c8cdf125 >> 8,
        privateKey: 0x2b785091d0239fbfcf19fda3f68e7a2ffb09a17f050ed666a2f1292bee28eb6d >> 8,
        gameId: 0
    });

    Player player2 = Player({
        identityCommitment: 0x85f8933c4df209d44fccf20ba2a4ac9c57518d5c0cde8964aebd8976203e93cf >> 8,
        pubKey: 0xc7ad19e8d3418b0443f3f244272d6890392e5902045d0e91b81eaefa6e0eb16f >> 8,
        privateKey: 0xa826d8cc928d21add4d3d5f54a3375f50406acfee1493e514b06c1541e0d255b >> 8,
        gameId: 0
    });

    Player player3 = Player({
        identityCommitment: 0x734aa61173b2d8a71cb4c182fac17cdcc075249d523f31a712cc3305adc66aea >> 8,
        pubKey: 0x5d1a15a9b7ca630923f465c993fdb7b3863d7a507d625e4245a74e11f03ec005 >> 8,
        privateKey: 0xf8dddae423ecd9052ccd774aea9458c4f48de670fcd2a83d717b0c466b6739c5 >> 8,
        gameId: 0
    });

    uint256 fakeAggregate = 0x3d1a15a9b7ca630923f465c993fdb7b3863d7a507d625e4245a74e11f03ac005 >> 8;

    bytes32[12] fakeEncryptedRoles = [
        bytes32(0x483a15a9b7ca630923f465c993fdb7b3863d7a507d625e4245a74e11f03ac00a),
        bytes32(0x483a15a9b7ca630923f465c993fdb7b3863d7a507d625e4245a74e11f03ac00a),
        bytes32(0x483a15a9b7ca630923f465c993fdb7b3863d7a507d625e4245a74e11f03ac00a),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0)
    ];

    bytes32[12] fakeDecryptedRoles = [
        bytes32(0x1b3a15a9b7ca430923f465c993fdb7b3863d7a507d625e4245a74e11f03ac00a),
        bytes32(0x1b3a15a9b7ca430923f465c993fdb7b3863d7a507d625e4245a74e11f03ac00a),
        bytes32(0x1b3a15a9b7ca430923f465c993fdb7b3863d7a507d625e4245a74e11f03ac00a),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0),
        bytes32(0)
    ];

    uint256[8] fakeSemaphoreProof = [
        0, 0, 0, 0, 0, 0, 0, 0
    ];

    // uint256 private constant commitment = 10827589014984258664065791453253930677820727364648385545462185556001224312446;
    // uint256 private constant merkleTreeRoot = 21249674136182111737379812179154148619659789436767535803372297253084007911240;
    // uint256 private constant nullifierHash = 17988428423475410174608143211754818143012248673943010715276137360531960932469;
    // uint256[8] private proof = [
    //     11386447326860257852744746048573712534911986991425405139066987905470159514416,
    //     5247944513357510708493857531762777724694350481598373491829873272703969937688,
    //     291265507786439091371967457522517867475640813525583811792984627160191762689,
    //     20487614291577831940250156044486170727933164649931351776153802615553653645724,
    //     5350494494388100188574870776784588784049999983398411830826133095196145930687,
    //     1072862535041703850157348127339044973485918449293408932991067100632056045130,
    //     12290527546078623953745695242580238069276128709068639464621819256296034253917,
    //     18234678008773360068350307515041260948251348122473293250452004098463746204799
    // ];

    function setUp() public {
        verifier = new SemaphoreVerifier();
        semaphore = new MockSemaphore(ISemaphoreVerifier(address(verifier)));
        game = new ZKMafia(address(semaphore));
    }

    function testCreateGame() public {
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey);
        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);
        bool stateLooksOk = gameId == 0 && 
            gameInfo.round == Round.Lobby && 
            gameInfo.players[0] == player1.pubKey;

        assertTrue(stateLooksOk);
    }

    function testJoinGame() public {
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, fakeBytes);
        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);
        bool stateLooksOk = gameId == 0 && 
            gameInfo.round == Round.Lobby && 
            gameInfo.players[1] == player2.pubKey;

        
        assertTrue(stateLooksOk);
    }

    function testStartGame() public {
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey);
        bytes memory fakeBytes = new bytes(32);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, fakeBytes);

        game.startGame(gameId, fakeAggregate, fakeBytes);

        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);
        bool stateLooksOk = gameId == 0 &&
            gameInfo.round == Round.Shuffle &&
            gameInfo.players.length == 3 &&
            gameInfo.mafiaCounter == 1 &&
            gameInfo.roles[0] == 1 &&
            gameInfo.validActionsTable[0].target == player1.pubKey;
        
        assertTrue(stateLooksOk);
    }

    function testPublishShuffleSingleIteration() public {
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey);
        bytes memory fakeBytes = new bytes(32);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, fakeBytes);

        game.startGame(gameId, fakeAggregate, fakeBytes);

        game.publishShuffle(gameId, player1.pubKey, fakeBytes, fakeEncryptedRoles);
        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);

        bool stateLooksOk = gameInfo.round == Round.Shuffle &&
            gameInfo.roles[0] == uint256(fakeEncryptedRoles[0]) &&
            gameInfo.roles.length == 3 &&
            gameInfo.status[0] == Status.ACTIVE &&
            gameInfo.status[1] == Status.PENDING_ACTION;
        
        assertTrue(stateLooksOk);
    }

    function testRevealRolesSingleIteration() public {
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey);
        bytes memory fakeBytes = new bytes(32);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, fakeBytes);

        game.startGame(gameId, fakeAggregate, fakeBytes);

        game.publishShuffle(gameId, player1.pubKey, fakeBytes, fakeEncryptedRoles);
        game.publishShuffle(gameId, player2.pubKey, fakeBytes, fakeEncryptedRoles);
        game.publishShuffle(gameId, player3.pubKey, fakeBytes, fakeEncryptedRoles);

        game.revealRoles(gameId, player1.pubKey, fakeBytes, fakeDecryptedRoles);

        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);

        bool stateLooksOk = gameInfo.round == Round.Reveal &&
            gameInfo.roles[0] == uint256(fakeDecryptedRoles[0]) &&
            gameInfo.roles.length == 3 &&
            gameInfo.status[0] == Status.ACTIVE &&
            gameInfo.status[1] == Status.PENDING_ACTION;
        

        assertTrue(stateLooksOk);
    }

    function testPrivateRound() public {
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey);
        bytes memory fakeBytes = new bytes(32);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, fakeBytes);

        game.startGame(gameId, fakeAggregate, fakeBytes);

        game.publishShuffle(gameId, player1.pubKey, fakeBytes, fakeEncryptedRoles);
        game.publishShuffle(gameId, player2.pubKey, fakeBytes, fakeEncryptedRoles);
        game.publishShuffle(gameId, player3.pubKey, fakeBytes, fakeEncryptedRoles);

        game.revealRoles(gameId, player1.pubKey, fakeBytes, fakeDecryptedRoles);
        game.revealRoles(gameId, player2.pubKey, fakeBytes, fakeDecryptedRoles);
        game.revealRoles(gameId, player3.pubKey, fakeBytes, fakeDecryptedRoles);

        // GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);
        // console.logBool(gameInfo.round == Round.Private);

        game.privateRound(
            gameId,
            fakeSemaphoreProof,
            fakeBytes,
            1,
            player2.pubKey,
            // all the merkle stuff is mocked
            0, 
            0, 
            0
        );

        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);

        bool stateLooksOk = gameInfo.round == Round.Private &&
            gameInfo.status[2] == Status.ACTIVE &&
            gameInfo.status[1] == Status.PENDING_ACTION;

        assertTrue(stateLooksOk);
    }


    function testPublicRound() public {
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey);
        bytes memory fakeBytes = new bytes(32);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, fakeBytes);

        game.startGame(gameId, fakeAggregate, fakeBytes);

        game.publishShuffle(gameId, player1.pubKey, fakeBytes, fakeEncryptedRoles);
        game.publishShuffle(gameId, player2.pubKey, fakeBytes, fakeEncryptedRoles);
        game.publishShuffle(gameId, player3.pubKey, fakeBytes, fakeEncryptedRoles);

        game.revealRoles(gameId, player1.pubKey, fakeBytes, fakeDecryptedRoles);
        game.revealRoles(gameId, player2.pubKey, fakeBytes, fakeDecryptedRoles);
        game.revealRoles(gameId, player3.pubKey, fakeBytes, fakeDecryptedRoles);

        game.privateRound(gameId, fakeSemaphoreProof, fakeBytes, 1, 0, 0, 0, 0);
        game.privateRound(gameId, fakeSemaphoreProof, fakeBytes, 0, 0, 0, 1, 0);
        game.privateRound(gameId, fakeSemaphoreProof, fakeBytes, 0, 0, 0, 2, 0);

        game.publicRound(gameId, player1.pubKey, fakeSemaphoreProof, 0, 3, 1);
        game.publicRound(gameId, player1.pubKey, fakeSemaphoreProof, 0, 4, 1);
        game.publicRound(gameId, player2.pubKey, fakeSemaphoreProof, 0, 5, 1);

        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);

        bool stateLooksOk = gameInfo.round == Round.Announce &&
            gameInfo.status[0] == Status.WAITING_REVEAL && 
            gameInfo.status[1] == Status.ACTIVE &&
            gameInfo.previousRound == Round.Public;


        assertTrue(stateLooksOk);
    }

    // function testAnnounce() public {
    //     uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey);
    //     bytes memory fakeBytes = new bytes(32);
    //     game.joinGame(gameId, player2.identityCommitment, player2.pubKey, fakeBytes);
    //     game.joinGame(gameId, player3.identityCommitment, player3.pubKey, fakeBytes);

    //     game.startGame(gameId, fakeAggregate, fakeBytes);

    //     game.publishShuffle(gameId, player1.pubKey, fakeBytes, fakeEncryptedRoles);
    //     game.publishShuffle(gameId, player2.pubKey, fakeBytes, fakeEncryptedRoles);
    //     game.publishShuffle(gameId, player3.pubKey, fakeBytes, fakeEncryptedRoles);

    //     game.revealRoles(gameId, player1.pubKey, fakeBytes, fakeDecryptedRoles);
    //     game.revealRoles(gameId, player2.pubKey, fakeBytes, fakeDecryptedRoles);
    //     game.revealRoles(gameId, player3.pubKey, fakeBytes, fakeDecryptedRoles);

    //     game.privateRound(gameId, fakeSemaphoreProof, fakeBytes, 1, 0, 0, 0, 0);
    //     game.privateRound(gameId, fakeSemaphoreProof, fakeBytes, 0, 0, 0, 1, 0);
    //     game.privateRound(gameId, fakeSemaphoreProof, fakeBytes, 0, 0, 0, 2, 0);

    //     game.publicRound(gameId, player1.pubKey, fakeSemaphoreProof, 0, 3, 1);
    //     game.publicRound(gameId, player1.pubKey, fakeSemaphoreProof, 0, 4, 1);
    //     game.publicRound(gameId, player2.pubKey, fakeSemaphoreProof, 0, 5, 1);

    //     // game.announceRole(gameId, true, player1.pubKey, validActionProofSiblings, validActionPathIndices, proof);

    //     GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);

    //     bool stateLooksOk = gameInfo.round == Round.Announce &&
    //         gameInfo.status[0] == Status.WAITING_REVEAL && 
    //         gameInfo.status[1] == Status.ACTIVE &&
    //         gameInfo.previousRound == Round.Public;


    //     assertTrue(stateLooksOk);
    // }
}
