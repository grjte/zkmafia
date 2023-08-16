import { Account } from '../components/Account'
import { Connect } from '../components/Connect'
import { Connected } from '../components/Connected'
import { Counter } from '../components/Counter'
import { NetworkSwitcher } from '../components/NetworkSwitcher'
import StyledLink from 'src/components/StyledLink'

export function Page() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1>zkMafia</h1>
      {/* TODO: connect wallet when it is needed instead of here (creating or joining a game) */}
      <Connect />

      <Connected>
        <Account />
        <hr />
        <Counter />
        <hr />
        <NetworkSwitcher />
      </Connected>

      <div className="mb-32 grid text-center lg:max-w-5xl lg:mb-0">
        <StyledLink href="/new" label="start a new game" />
        <StyledLink href="/search" label="join an existing game" />
      </div>
    </main>
  )
}

export default Page
