import Link from "next/link";
import Image from "next/image";
import { Download, Github, ExternalLink } from "lucide-react";
import {
  APK_DOWNLOAD_URL,
  GITHUB_RELEASE_URL,
  GOOGLE_FORM_URL,
  PLAY_TESTING_URL,
} from "@/lib/links";

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-border pt-12 pb-8 px-4">
      <div className="max-w-6xl mx-auto">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-10 mb-10">
          {/* Brand */}
          <div className="sm:col-span-2 lg:col-span-1">
            <Link href="/" className="flex items-center gap-2 mb-3">
              <Image
                src="/icon-512.png"
                alt="Aspire"
                width={28}
                height={28}
                className="rounded-lg"
              />
              <span className="text-lg font-bold text-foreground">Aspire</span>
            </Link>
            <p className="text-sm text-muted leading-relaxed">
              From dreaming to doing. AI-powered goal planning with streaks
              and celebrations for ambitious women ready to take action.
            </p>
          </div>

          {/* Download */}
          <div>
            <h4 className="text-sm font-semibold text-foreground mb-3">
              Get the App
            </h4>
            <div className="flex flex-col gap-2">
              <a
                href={APK_DOWNLOAD_URL}
                className="text-sm text-muted hover:text-primary transition-colors flex items-center gap-1.5"
              >
                <Download className="w-3.5 h-3.5" />
                Download APK
              </a>
              <a
                href={GITHUB_RELEASE_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-muted hover:text-primary transition-colors flex items-center gap-1.5"
              >
                <Github className="w-3.5 h-3.5" />
                GitHub Releases
              </a>
              <a
                href={GOOGLE_FORM_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-muted hover:text-primary transition-colors flex items-center gap-1.5"
              >
                <ExternalLink className="w-3.5 h-3.5" />
                Google Play testing
              </a>
              <a
                href={PLAY_TESTING_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="text-sm text-muted hover:text-primary transition-colors flex items-center gap-1.5"
              >
                <ExternalLink className="w-3.5 h-3.5" />
                Internal testing
              </a>
            </div>
          </div>

          {/* Links */}
          <div>
            <h4 className="text-sm font-semibold text-foreground mb-3">
              Legal
            </h4>
            <div className="flex flex-col gap-2">
              <Link
                href="/privacy"
                className="text-sm text-muted hover:text-primary transition-colors"
              >
                Privacy Policy
              </Link>
              <Link
                href="/terms"
                className="text-sm text-muted hover:text-primary transition-colors"
              >
                Terms of Service
              </Link>
              <Link
                href="/support"
                className="text-sm text-muted hover:text-primary transition-colors"
              >
                Support
              </Link>
            </div>
          </div>

          {/* Hackathon */}
          <div>
            <h4 className="text-sm font-semibold text-foreground mb-3">
              About
            </h4>
            <p className="text-sm text-muted leading-relaxed">
              Built for the RevenueCat Shipyard 2026 Hackathon. Designed for
              Gabby Beckford&apos;s audience at{" "}
              <a
                href="https://packslight.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary hover:underline"
              >
                PacksLight
              </a>
              .
            </p>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="border-t border-border pt-6 flex flex-col sm:flex-row justify-between items-center gap-4">
          <p className="text-muted text-xs">
            &copy; {currentYear} Aspire. All rights reserved.
          </p>
          <a
            href={GITHUB_RELEASE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="text-muted text-xs hover:text-primary transition-colors flex items-center gap-1"
          >
            <Github className="w-3 h-3" />
            View on GitHub
          </a>
        </div>
      </div>
    </footer>
  );
}
