import Link from "next/link";
import Image from "next/image";

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-border py-12 px-4">
      <div className="max-w-6xl mx-auto">
        <div className="flex flex-col md:flex-row justify-between items-center gap-6">
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

          {/* Links */}
          <div className="flex items-center gap-6">
            <Link
              href="/privacy"
              className="text-muted hover:text-foreground transition-colors text-sm"
            >
              Privacy Policy
            </Link>
            <Link
              href="/terms"
              className="text-muted hover:text-foreground transition-colors text-sm"
            >
              Terms of Service
            </Link>
            <Link
              href="/support"
              className="text-muted hover:text-foreground transition-colors text-sm"
            >
              Support
            </Link>
          </div>

          {/* Copyright */}
          <p className="text-muted text-sm">
            &copy; {currentYear} Aspire. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
