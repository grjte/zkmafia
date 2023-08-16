import StartGameButton from "./StartGameButton"

export default function StartGame(props: { gameId: string, advanceGame: () => void }) {
    return (
        <>
            <p>
                show game details: how many players have joined, player pub_keys/proofs for shuffle & option to verify each player locally
            </p>
            <p>show the start game button only if the player is the owner; otherwise show text that the game will start soon</p>
            <StartGameButton {...props} />
        </>
    )
}
