"use client"

import Button from "src/components/Button"


/**
 * TODO: docs
 */
export default function RevealRoleButton({ gameId, advanceGame }: { gameId: string, advanceGame: () => void }) {
    const handleClick = () => {
        // TODO: use the reveal tokens for the player's card and their own secret key to reveal their role

        // TODO: the game stage should not actually advance until all players have completed the 
        // deal. This is just a placeholder
        advanceGame()
    }

    return (
        <Button id={1} label={`reveal role for game '${gameId}'`} handleClick={handleClick} />
    )
}