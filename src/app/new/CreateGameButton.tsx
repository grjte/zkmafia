"use client"

import { useRouter } from "next/navigation"
import { Group } from "@semaphore-protocol/group"
import { Identity } from "@semaphore-protocol/identity"
import Button from "src/components/Button"

// TODO: this creates an off-chain Semaphore group, but we need to create one on chain
// TODO: we need to associate the on-chain group with our game id so other players can join
export default function StartGameButton({ gameId }: { gameId: string }) {
    const router = useRouter()

    const handleClick = () => {
        const group = new Group(1, 16)
        const { trapdoor, nullifier, commitment } = new Identity()

        console.log("group: ", group.members)
        console.log("trapdoor (private)", trapdoor.toString())
        console.log("nullifier (private)", nullifier.toString())
        console.log("commitment (public)", commitment.toString())

        group.addMember(commitment)
        console.log("group: ", group.members)

        router.push(`/${gameId}/play`)
    }

    return (
        <Button id={1} label={`create game: '${gameId}'`} handleClick={handleClick} />
    )
}