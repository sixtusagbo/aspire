import Link from "next/link";
import { Sparkles } from "lucide-react";

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-border py-12 px-4">
      <div className="max-w-6xl mx-auto">
        <div className="flex flex-col md:flex-row justify-between items-center gap-6">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-primary flex items-center justify-center">
              <Sparkles className="w-5 h-5 text-white" />
            </div>
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
