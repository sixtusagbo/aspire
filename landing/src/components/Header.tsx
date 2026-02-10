"use client";

import { useState } from "react";
import Link from "next/link";
import Image from "next/image";
import { Menu, X, Download, Github, ExternalLink } from "lucide-react";
import {
  APK_DOWNLOAD_URL,
  GITHUB_RELEASE_URL,
  GOOGLE_FORM_URL,
  PLAY_TESTING_URL,
} from "@/lib/links";

export default function Header() {
  const [open, setOpen] = useState(false);

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

          {/* Desktop nav */}
          <div className="hidden md:flex items-center gap-6">
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
            <a
              href={APK_DOWNLOAD_URL}
              className="btn-primary px-4 py-2 rounded-lg text-white text-sm font-medium flex items-center gap-1.5 shadow-sm hover:shadow-md transition-all"
            >
              <Download className="w-4 h-4" />
              Download APK
            </a>
          </div>

          {/* Hamburger */}
          <button
            onClick={() => setOpen(!open)}
            className="md:hidden p-2 -mr-2 text-foreground"
            aria-label={open ? "Close menu" : "Open menu"}
          >
            {open ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
      </nav>

      {/* Mobile menu */}
      {open && (
        <div className="md:hidden border-t border-border bg-background/95 backdrop-blur-md">
          <div className="max-w-6xl mx-auto px-4 py-4 flex flex-col gap-1">
            {/* Download section */}
            <a
              href={APK_DOWNLOAD_URL}
              onClick={() => setOpen(false)}
              className="btn-primary px-4 py-3 rounded-xl text-white font-semibold flex items-center justify-center gap-2 shadow-md mb-2"
            >
              <Download className="w-5 h-5" />
              Download for Android
            </a>
            <a
              href={GITHUB_RELEASE_URL}
              target="_blank"
              rel="noopener noreferrer"
              onClick={() => setOpen(false)}
              className="px-4 py-3 rounded-xl font-medium flex items-center justify-center gap-2 border border-border text-foreground mb-3"
            >
              <Github className="w-5 h-5" />
              GitHub Releases
            </a>

            <div className="border-t border-border my-1" />

            {/* Testing links */}
            <a
              href={GOOGLE_FORM_URL}
              target="_blank"
              rel="noopener noreferrer"
              onClick={() => setOpen(false)}
              className="px-4 py-3 rounded-lg text-sm text-foreground-secondary hover:text-primary flex items-center gap-2 transition-colors"
            >
              <ExternalLink className="w-4 h-4" />
              Request Google Play testing access
            </a>
            <a
              href={PLAY_TESTING_URL}
              target="_blank"
              rel="noopener noreferrer"
              onClick={() => setOpen(false)}
              className="px-4 py-3 rounded-lg text-sm text-foreground-secondary hover:text-primary flex items-center gap-2 transition-colors"
            >
              <ExternalLink className="w-4 h-4" />
              Google Play internal testing
            </a>

            <div className="border-t border-border my-1" />

            {/* Page links */}
            <Link
              href="/privacy"
              onClick={() => setOpen(false)}
              className="px-4 py-3 rounded-lg text-sm text-foreground-secondary hover:text-primary transition-colors"
            >
              Privacy Policy
            </Link>
            <Link
              href="/terms"
              onClick={() => setOpen(false)}
              className="px-4 py-3 rounded-lg text-sm text-foreground-secondary hover:text-primary transition-colors"
            >
              Terms of Service
            </Link>
            <Link
              href="/support"
              onClick={() => setOpen(false)}
              className="px-4 py-3 rounded-lg text-sm text-foreground-secondary hover:text-primary transition-colors"
            >
              Support
            </Link>
          </div>
        </div>
      )}
    </header>
  );
}
