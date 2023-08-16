import VoteButton from "./VoteButton"

export default function TakeAction(props: { gameId: string, advanceGame: () => void }) {
    return (
        <>
            <p>
                send the player's vote of who to remove (contract interaction). Check game state first - if the game is over, send to end page.
            </p>
            <VoteButton {...props} />
        </>
    )
}