import RevealRoleButton from "./RevealRoleButton";

export default function RevealRole(props: { gameId: string, advanceGame: () => void }) {
    return (
        <>
            <p>
                the player peeks at their role. optionally the player can also verify the reveal proofs for their card (otherwise the contract has to do it during the deal)
            </p>
            <RevealRoleButton {...props} />
        </>
    )
}