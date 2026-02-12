"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import Image from "next/image";
import { Menu, X, Download, ExternalLink } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";
import {
  APK_DOWNLOAD_URL,
  GITHUB_REPO_URL,
} from "@/lib/links";

export default function Header() {
  const [open, setOpen] = useState(false);
  const [scrolled, setScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled || open ? "bg-background/80 backdrop-blur-lg border-b border-white/5" : "bg-transparent border-transparent"
      }`}
    >
      <nav className="max-w-7xl mx-auto px-4 sm:px-6 py-4">
        <div className="flex items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2 group">
            <div className="relative w-8 h-8 rounded-lg overflow-hidden ring-2 ring-white/10 group-hover:ring-primary/50 transition-all">
              <Image
                src="/icon-512.png"
                alt="Aspire"
                fill
                className="object-cover"
              />
            </div>
            <span className="text-xl font-bold tracking-tight">Aspire</span>
          </Link>

          {/* Desktop nav */}
          <div className="hidden md:flex items-center gap-8">
            <Link
              href="/privacy"
              className="text-sm text-muted-foreground hover:text-white transition-colors"
            >
              Privacy
            </Link>
            <Link
              href="/terms"
              className="text-sm text-muted-foreground hover:text-white transition-colors"
            >
              Terms
            </Link>
            <Link
              href="/support"
              className="text-sm text-muted-foreground hover:text-white transition-colors"
            >
              Support
            </Link>
            <a
              href={APK_DOWNLOAD_URL}
              className="btn-primary px-4 py-2 rounded-lg text-white text-sm font-semibold flex items-center gap-1.5 shadow-lg shadow-primary/20 hover:shadow-primary/40 transition-all"
            >
              <Download className="w-4 h-4" />
              Download APK
            </a>
          </div>

          {/* Hamburger */}
          <button
            onClick={() => setOpen(!open)}
            className="md:hidden p-2 -mr-2 text-muted-foreground hover:text-white transition-colors"
            aria-label={open ? "Close menu" : "Open menu"}
          >
            {open ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
          </button>
        </div>
      </nav>

      {/* Mobile menu */}
      <AnimatePresence>
        {open && (
          <motion.div
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: "auto" }}
            exit={{ opacity: 0, height: 0 }}
            className="md:hidden border-t border-white/10 bg-background/95 backdrop-blur-xl overflow-hidden"
          >
            <div className="max-w-7xl mx-auto px-4 py-6 flex flex-col gap-2">
              <a
                href={APK_DOWNLOAD_URL}
                onClick={() => setOpen(false)}
                className="btn-primary w-full py-3 rounded-xl text-white font-semibold flex items-center justify-center gap-2 shadow-lg mb-4"
              >
                <Download className="w-5 h-5" />
                Download for Android
              </a>

              <Link
                href="/privacy"
                onClick={() => setOpen(false)}
                className="px-4 py-3 rounded-lg text-sm text-muted-foreground hover:text-white hover:bg-white/5 transition-colors"
              >
                Privacy Policy
              </Link>
              <Link
                href="/terms"
                onClick={() => setOpen(false)}
                className="px-4 py-3 rounded-lg text-sm text-muted-foreground hover:text-white hover:bg-white/5 transition-colors"
              >
                Terms of Service
              </Link>
              <Link
                href="/support"
                onClick={() => setOpen(false)}
                className="px-4 py-3 rounded-lg text-sm text-muted-foreground hover:text-white hover:bg-white/5 transition-colors"
              >
                Support
              </Link>

              <a
                href="/#join-internal-testing"
                onClick={() => setOpen(false)}
                className="px-4 py-3 rounded-lg text-sm text-muted-foreground hover:text-white hover:bg-white/5 transition-colors"
              >
                Join Internal Testing
              </a>

               <div className="border-t border-white/5 my-2" />

              <a
                href={GITHUB_REPO_URL}
                target="_blank"
                rel="noopener noreferrer"
                onClick={() => setOpen(false)}
                className="px-4 py-3 text-sm text-muted-foreground hover:text-white flex items-center gap-2 hover:bg-white/5 rounded-lg transition-colors"
              >
                 <ExternalLink className="w-4 h-4" />
                View on GitHub
              </a>
            </div>
          </motion.div>
        )}
      </AnimatePresence>
    </header>
  );
}
