import DealRolesButton from "./DealRolesButton"

export default function DealRoles(props: { gameId: string, advanceGame: () => void }) {
    return (
        <>
            <p>
                when the shuffle is complete, each player needs to help deal the deck. each player gets a masked card. each player must unmask the other cards. show current status of the deal.
            </p>
            <DealRolesButton {...props} />
        </>
    )
}