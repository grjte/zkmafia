import JoinGameButton from "./JoinGameButton"

export default function Join({ params }: { params: { gameId: string } }) {
    return (
        <main className="flex min-h-screen flex-col items-center justify-center p-24">
            <div className="mb-32 grid text-center lg:max-w-5xl lg:mb-0">
                <p>
                    show game details here, like game id, configuration (rules) players who have joined, etc. If game has already been started, disable the "join game" button
                </p>
                <JoinGameButton gameId={params.gameId} />
            </div>
        </main>
    )
}
