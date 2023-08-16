import StyledLink from "src/components/StyledLink";

export default function End({ params }: { params: { gameId: string } }) {
    return (
        <main className="flex min-h-screen flex-col items-center justify-center p-24">
            <div className="mb-32 grid text-center lg:max-w-5xl lg:mb-0">
                <p>
                    game over; show results here
                </p>
                <StyledLink href="/new" label="start a new game" />
            </div>
        </main>
    )
}
