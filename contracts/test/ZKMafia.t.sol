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

    uint256 seed1 = 0x37843a10b6634a04a1d4e69053108ad0541ec5d4abac88c6cdb43497cd98c002;
    uint256 seed2 = 0x85f8933c4df209d44fccf20ba2a4ac9c57518d5c0cde8964aebd8976203e93cf;
    uint256 seed3 = 0x734aa61173b2d8a71cb4c182fac17cdcc075249d523f31a712cc3305adc66aea;

    // These are random 256 bit values from the keccak hash, but they will need to be within 254 bits
    Player player1 = Player({
        identityCommitment: seed1 >> 8,
        pubKey: 0x7257f4c4c7ecebb66545404f8bd8c0d8e85c693edf68b62250ffa904c8cdf125 >> 8,
        privateKey: 0x2b785091d0239fbfcf19fda3f68e7a2ffb09a17f050ed666a2f1292bee28eb6d >> 8,
        gameId: 0
    });

    Player player2 = Player({
        identityCommitment: seed2 >> 8,
        pubKey: 0xc7ad19e8d3418b0443f3f244272d6890392e5902045d0e91b81eaefa6e0eb16f >> 8,
        privateKey: 0xa826d8cc928d21add4d3d5f54a3375f50406acfee1493e514b06c1541e0d255b >> 8,
        gameId: 0
    });

    Player player3 = Player({
        identityCommitment: seed3 >> 8,
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

    uint8[] semaphorePathIndices = [
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0
    ];

    uint256[] semaphoreProofSiblings = [
        236706262172491650346271165978694005230539559653389419608252982367071780499,
        19730886067279757372738207784342742871070109774823536826502955914367285501981,
        1127520796881217343987681885215210990166711812208894874276851058120732281105,
        2711571884751886055531469890957513778707143058393092148099307560576108559244,
        1789388906732912109524066314513258655060081764011840746171519014836876772218,
        582964291693045403936709592343560876020366787402753543236478101614352958252,
        11807717547964046244064709391787792000461338536272439284715955728419525580659,
        2618630034848387376205875317462171941117533864938459881381670827265210678824,
        21788894002785300424317994620212112042063431426028919421405981678525536220148,
        20267468033604064348191693405892554554516887987993735630079373192529765683381,
        21293443394674032174194404458995023860759205298576815130824632401112019426558,
        1596446600402602634917363894010436935282352400144922352882876639641333866108,
        6936350102176258626811821283233242768841799757529748889508302992679059925357,
        18798072398960416633789351877096808918864386833403640230453169121327931578546,
        5346284295180628014688042959644292163328207787600154829977251752708200408371,
        18940072850614243109943038885675314906659100070336172634303614229451343702425,
        15780300262861168060558856835698353723222268065687479197141681695858463599226,
        2217668277589842727243322117061624603092131353058845218921642417787922188024,
        13666232878702307089799293078027105292040095780466265084877807836900202894778,
        10489507655578435438967951959486478747913401831101658574977874696240522651825
    ];

    function setUp() public {
        verifier = new SemaphoreVerifier();
        semaphore = new MockSemaphore(ISemaphoreVerifier(address(verifier)));
        game = new ZKMafia(address(semaphore));
    }

    function testCreateGame() public {
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey, "Roboto", fakeBytes);
        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);
        bool stateLooksOk = gameId == 0 && 
            gameInfo.round == Round.Lobby && 
            gameInfo.players[0] == player1.pubKey;

        assertTrue(stateLooksOk);
    }

    function testJoinGame() public {
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey, "Roboto", fakeBytes);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, "Alice", fakeBytes);
        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);
        bool stateLooksOk = gameId == 0 && 
            gameInfo.round == Round.Lobby && 
            gameInfo.players[1] == player2.pubKey;

        
        assertTrue(stateLooksOk);
    }

    function testStartGame() public {
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey, "Roboto", fakeBytes);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, "Alice", fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, "Bob", fakeBytes);

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
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey, "Roboto", fakeBytes);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, "Alice", fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, "Bob", fakeBytes);

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
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey, "Roboto", fakeBytes);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, "Alice", fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, "Bob", fakeBytes);

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
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey, "Roboto", fakeBytes);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, "Alice", fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, "Bob", fakeBytes);

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
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey, "Roboto", fakeBytes);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, "Alice", fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, "Bob", fakeBytes);

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

    function testAnnounce() public {
        bytes memory fakeBytes = new bytes(32);
        uint256 gameId = game.createGame(player1.identityCommitment, player1.pubKey, "Roboto", fakeBytes);
        game.joinGame(gameId, player2.identityCommitment, player2.pubKey, "Alice", fakeBytes);
        game.joinGame(gameId, player3.identityCommitment, player3.pubKey, "Bob", fakeBytes);

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

        game.announceRole(gameId, true, player1.pubKey, player1.identityCommitment, semaphoreProofSiblings, semaphorePathIndices, fakeBytes);

        GameInfo memory gameInfo = game.getGameInfoForGameId(gameId);

        bool stateLooksOk = gameInfo.round == Round.End;
        assertTrue(stateLooksOk);
    }
}
