"use client"

import Button from "src/components/Button"


/**
 * TODO: docs
 */
export default function DealRolesButton({ gameId, advanceGame }: { gameId: string, advanceGame: () => void }) {
    const handleClick = () => {

        // TODO: for all cards except the one that was dealt to this player, do the following:
        // TODO: compute a reveal token and proof that it is a valid reveal for the specified card
        // TODO: publish the token and proof

        // TODO: send reveal tokens to the contract.
        // The contract uses the list of reveal tokens to create the encrypted card for each player 
        // which is encrypted only by their own masking. It updates (or creates) the mapping of 
        // pub_key to encrypted card in the player roles table.</li>

        // TODO: the game stage should not actually advance until all players have completed the 
        // deal. This is just a placeholder
        advanceGame()
    }

    return (
        <Button id={1} label={`deal roles for game '${gameId}'`} handleClick={handleClick} />
    )
}