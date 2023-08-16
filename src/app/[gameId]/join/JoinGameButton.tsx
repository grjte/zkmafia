"use client"

import { useRouter } from "next/navigation"
import { Identity } from "@semaphore-protocol/identity"
import Button from "src/components/Button"


/**
 * Creates a Semaphore id, generates a keypair for use in the shuffle, and proves that the player
 * owns the secret_key corresponding to the shuffle pub_key. Then sends the Semaphore id commitment 
 * and the public key to the contract so the player can be added to the game, and publishes the
 * shuffle pub_key and ownership proof. Finally, private data associated with the Semaphore identity 
 * (nullifier and trapdoor) and the shuffle keypair (the secret key) is stored locally.
 */
export default function JoinGameButton({ gameId }: { gameId: string }) {
    const router = useRouter()

    const handleClick = () => {
        // TODO: retrieve the Semaphore groupId associated with this game

        // create a new Semaphore identity
        const { trapdoor, nullifier, commitment } = new Identity()
        console.log("trapdoor (private)", trapdoor.toString())
        console.log("nullifier (private)", nullifier.toString())
        console.log("commitment (public)", commitment.toString())

        // TODO: store player's Semaphore identity (e.g. in local storage or using WebAuthn)

        // TODO: create a new keypair for use in the shuffle

        // TODO: prove player owns corresponding secret_key for pub_key

        // TODO: publish pub_key and proof (we can provide these on the start game or join pages and let other players verify locally instead of putting the burden on the contract)

        // TODO: send commitment and public key to the contract

        // TODO in contract: add the identity to the group & save the pub_key

        router.push(`/${gameId}/play`)
    }

    return (
        <Button id={1} label={`join game: '${gameId}'`} handleClick={handleClick} />
    )
}