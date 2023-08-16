import CreateGameButton from "./CreateGameButton"
import StyledLink from "src/components/StyledLink"

export default function New() {

    return (
        <main className="flex min-h-screen flex-col items-center justify-center p-24">
            <div className="mb-32 grid text-center lg:max-w-5xl lg:mb-0">
                <p>
                    form to determine settings, game id, etc
                </p>
                {/* TODO: get a game id from the user or generate a unique id */}
                <CreateGameButton gameId="example" />
            </div>
        </main>
    )
}
