"use client"

import Button from "src/components/Button"


/**
 * TODO: docs
 */
export default function VoteButton({ gameId, advanceGame }: { gameId: string, advanceGame: () => void }) {
    const handleClick = () => {
        // TODO: player votes on another player to remove from the game. the player should still be 
        // an active member of the game. this vote does not need to be obfuscated.

        // TODO: send vote to contract, which will determine the player with the most votes and 
        // remove that member from the Semaphore group. This can be done using Semaphore voting so
        // that players can't vote twice and so that this vote is only executed once per round.

        // TODO: the game stage should not actually advance until all players have voted. This is 
        // just a placeholder
        advanceGame()
    }

    return (
        <Button id={1} label={`vote in game '${gameId}'`} handleClick={handleClick} />
    )
}