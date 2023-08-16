import TakeActionButton from "./TakeActionButton"

export default function TakeAction(props: { gameId: string, advanceGame: () => void }) {
    return (
        <>
            <p>
                handle the player's private action (action selection, proof creation, contract interaction). Check game state first - if the game is over, send to end page.
            </p>
            <TakeActionButton {...props} />
        </>
    )
}