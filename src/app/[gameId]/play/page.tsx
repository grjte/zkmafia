"use client"

import { useState } from "react"
import { useRouter } from "next/navigation"
import DealRoles from "./DealRoles"
import RevealRole from "./RevealRole"
import ShuffleRoles from "./ShuffleRoles"
import StartGame from "./StartGame"
import TakeAction from "./TakeAction"
import Vote from "./Vote"

const gameStages = ["join", "shuffle", "deal", "reveal role", "action", "vote", "end"]

// TODO: get the current game status and show the component depending on the status
export default function Play({ params: { gameId } }: { params: { gameId: string } }) {
    const router = useRouter()
    const [gameStage, setGameStage] = useState(0)

    const advanceGame = () => {
        let nextStage = gameStage + 1

        if (gameStages[nextStage] === "end") {
            router.push(`/${gameId}/end`)
        } else {
            setGameStage(nextStage)
        }
    }

    return (
        <main className="flex min-h-screen flex-col items-center justify-center p-24">
            <div className="mb-32 grid text-center lg:max-w-5xl lg:mb-0">
                <p className="p-2 uppercase">Game stage: {gameStages[gameStage]}</p>
                {
                    {
                        "join": <StartGame gameId={gameId} advanceGame={advanceGame} />,
                        "shuffle": <ShuffleRoles gameId={gameId} advanceGame={advanceGame} />,
                        "deal": <DealRoles gameId={gameId} advanceGame={advanceGame} />,
                        "reveal role": <RevealRole gameId={gameId} advanceGame={advanceGame} />,
                        "action": <TakeAction gameId={gameId} advanceGame={advanceGame} />,
                        "vote": <Vote gameId={gameId} advanceGame={advanceGame} />,
                    }[gameStages[gameStage]]
                }
            </div>
        </main >
    )
}
