"use client"

import Button from "src/components/Button"


/**
 * TODO: docs
 */
export default function ShuffleRolesButton({ gameId, advanceGame }: { gameId: string, advanceGame: () => void }) {
    const handleClick = () => {
        // TODO: the player shuffles the deck

        // TODO: the player remasks of the deck

        // TODO: the player publishes a proof of correct shuffle & remask

        // TODO: the game stage should not actually advance until all players have completed the 
        // shuffle. This is just a placeholder
        advanceGame()
    }

    return (
        <Button id={1} label={`shuffle roles for game '${gameId}'`} handleClick={handleClick} />
    )
}