"use client"
import Link from 'next/link'

export default function StyledLink({ label, href }: {
    label: string,
    href: string
}) {
    return (
        <Link href={href} className="m-2 group rounded-lg border border-black px-5 py-4 hover:bg-black hover:text-white">
            <h2 className={`m-2 text-2xl font-semibold capitalize`}>
                {`${label} `}
                <span className="inline-block transition-transform group-hover:translate-x-1 motion-reduce:transform-none">
                    -&gt;
                </span>
            </h2>
        </Link>
    )
}