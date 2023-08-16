import StyledLink from "src/components/StyledLink"

export default function New() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <div className="mb-32 grid text-center lg:max-w-5xl lg:mb-0">
        <p>
          searchbar to find a game by owner (whoever started it) or id
        </p>
        <StyledLink href="/example/join" label="join 'example'" />
      </div>
    </main>
  )
}
