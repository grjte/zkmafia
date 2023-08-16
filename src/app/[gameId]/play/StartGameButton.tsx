"use client"

import Button from "src/components/Button"


/**
 * TODO: docs
 */
export default function StartGameButton({ gameId, advanceGame }: { gameId: string, advanceGame: () => void }) {
    const handleClick = () => {
        // TODO: enforce game owner permissions for clicking the start button

        // TODO: move the game stage forward (no new players can join)

        // TODO: create the deck

        // advance the game to the next stage
        advanceGame()
    }

    return (
        <Button id={1} label={`start game '${gameId}'`} handleClick={handleClick} />
    )
}