"use client"

import Button from "src/components/Button"


/**
 * TODO: docs
 */
export default function TakeActionButton({ gameId, advanceGame }: { gameId: string, advanceGame: () => void }) {
    const handleClick = () => {
        // TODO: add todos here

        // TODO: method for player to select a (valid) action, which is a tuple of (role, pub_key), 
        // where role specifies a role that can take a single action (e.g mafia can kill or a doctor
        // can save) and pub_key specifies the target of the action. If the player does not have a 
        // special role, they will select a nonaction (null, null). All actions (including the 
        // nonaction) must exist in the contract’s table of valid actions.

        // TODO: the player creates a proof of valid action, which proves that the player’s action 
        // is a valid action in the game and the player has the correct role to take it.
        // This is a zk proof where the player proves:
        // - They know the private key which corresponds to a specific public key `pub_key`. (This 
        //   is the same proof they did when generating the key during setup)
        // - `ciphertext` decrypts to a specific card`role`.
        // - (`pub_key`, `ciphertext`) is in the "player roles table" in the contract
        // - the action taken is a valid action that matches the card's `role`, by checking that
        //   (`role`, `target_pub_key`) exists in the "valid actions table" in the contract, where 
        //   `role` is the role that the `ciphertext` decrypted to above

        // TODO send (action, proof) to the contract, along with proof of Semaphore group 
        // membership, using a relay to obfuscate the source. The  contract validates Semaphore 
        // group membership, validates the proof of valid action, and updates the game state to 
        // reflect the action taken.

        // TODO: the game stage should not actually advance until all players have completed 
        // their actions. This is just a placeholder
        advanceGame()
    }

    return (
        <Button id={1} label={`take next action in game '${gameId}'`} handleClick={handleClick} />
    )
}