import ShuffleRolesButton from "./ShuffleRolesButton"

export default function ShuffleRoles(props: { gameId: string, advanceGame: () => void }) {
    return (
        <>
            <p>
                show shuffle details: current status and proofs of correct shuffle; add a button so players can verify the previous shuffle proofs (local verification will be cheaper than in the contract)
            </p>
            <p>control shuffle ordering if necessary</p>
            <ShuffleRolesButton {...props} />
        </>
    )
}
