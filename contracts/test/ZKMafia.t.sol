// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../src/ZKMafia.sol";
import "../mocks/MockSemaphore.sol";
import "@semaphore/base/SemaphoreVerifier.sol";
import "@semaphore/interfaces/ISemaphoreVerifier.sol";

contract ZKMafiaTest is Test {
    ZKMafia public game;
    MockSemaphore private semaphore;
    SemaphoreVerifier private verifier;

    uint256 private constant commitment = 10827589014984258664065791453253930677820727364648385545462185556001224312446;
    uint256 private constant merkleTreeRoot = 21249674136182111737379812179154148619659789436767535803372297253084007911240;
    uint256 private constant nullifierHash = 17988428423475410174608143211754818143012248673943010715276137360531960932469;
    uint256[8] private proof = [
        11386447326860257852744746048573712534911986991425405139066987905470159514416,
        5247944513357510708493857531762777724694350481598373491829873272703969937688,
        291265507786439091371967457522517867475640813525583811792984627160191762689,
        20487614291577831940250156044486170727933164649931351776153802615553653645724,
        5350494494388100188574870776784588784049999983398411830826133095196145930687,
        1072862535041703850157348127339044973485918449293408932991067100632056045130,
        12290527546078623953745695242580238069276128709068639464621819256296034253917,
        18234678008773360068350307515041260948251348122473293250452004098463746204799
    ];

    function setUp() public {
        verifier = new SemaphoreVerifier();
        semaphore = new MockSemaphore(ISemaphoreVerifier(address(verifier)));
        game = new ZKMafia(address(semaphore), 1);
    }

    function joinGroup() public {
        game.joinGroup(commitment);
    }

    function testSendSignal() public {
        game.sendSignal(
            1,
            merkleTreeRoot,
            nullifierHash,
            proof
        );
    }
}
