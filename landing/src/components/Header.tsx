"use client";

import Link from "next/link";
import Image from "next/image";

export default function Header() {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-background/80 backdrop-blur-md border-b border-border">
      <nav className="max-w-6xl mx-auto px-4 sm:px-6 py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <Image
              src="/icon-512.png"
              alt="Aspire"
              width={32}
              height={32}
              className="rounded-lg"
            />
            <span className="text-xl font-bold text-foreground">Aspire</span>
          </Link>

          {/* Nav links */}
          <div className="flex items-center gap-6">
            <Link
              href="/privacy"
              className="text-muted hover:text-foreground transition-colors text-sm"
            >
              Privacy
            </Link>
            <Link
              href="/terms"
              className="text-muted hover:text-foreground transition-colors text-sm"
            >
              Terms
            </Link>
            <Link
              href="/support"
              className="text-muted hover:text-foreground transition-colors text-sm"
            >
              Support
            </Link>
          </div>
        </div>
      </nav>
    </header>
  );
}
