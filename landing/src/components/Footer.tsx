import Link from "next/link";
import Image from "next/image";
import { Download, Github, ExternalLink, Heart } from "lucide-react";
import {
  APK_DOWNLOAD_URL,
  GITHUB_RELEASE_URL,
  GOOGLE_FORM_URL,
  PLAY_TESTING_URL,
} from "@/lib/links";

export default function Footer() {
  const currentYear = new Date().getFullYear();

  return (
    <footer className="border-t border-white/5 bg-black/40 backdrop-blur-xl pt-16 pb-8">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-16">
          {/* Brand */}
          <div className="space-y-4">
            <Link href="/" className="flex items-center gap-2">
              <div className="relative w-8 h-8 rounded-lg overflow-hidden ring-1 ring-white/10">
                <Image
                  src="/icon-512.png"
                  alt="Aspire"
                  fill
                  className="object-cover"
                />
              </div>
              <span className="text-xl font-bold tracking-tight">Aspire</span>
            </Link>
            <p className="text-sm text-muted-foreground leading-relaxed max-w-xs">
              From dreaming to doing. AI-powered goal planning for ambitious women ready to take action.
            </p>
          </div>

          {/* Product */}
          <div>
            <h4 className="font-semibold text-foreground mb-6">Product</h4>
            <ul className="space-y-3 text-sm text-muted-foreground">
              <li>
                <a href={APK_DOWNLOAD_URL} className="hover:text-primary transition-colors flex items-center gap-2">
                  <Download className="w-4 h-4" /> Download APK
                </a>
              </li>
              <li>
                <a href={GITHUB_RELEASE_URL} target="_blank" rel="noopener noreferrer" className="hover:text-primary transition-colors flex items-center gap-2">
                  <Github className="w-4 h-4" /> GitHub Releases
                </a>
              </li>
              <li>
                <a href={GOOGLE_FORM_URL} target="_blank" rel="noopener noreferrer" className="hover:text-primary transition-colors flex items-center gap-2">
                   Request Access
                </a>
              </li>
               <li>
                <a href={PLAY_TESTING_URL} target="_blank" rel="noopener noreferrer" className="hover:text-primary transition-colors flex items-center gap-2">
                   Internal Testing
                </a>
              </li>
            </ul>
          </div>

          {/* Legal */}
          <div>
            <h4 className="font-semibold text-foreground mb-6">Legal</h4>
            <ul className="space-y-3 text-sm text-muted-foreground">
              <li>
                <Link href="/privacy" className="hover:text-primary transition-colors">
                  Privacy Policy
                </Link>
              </li>
              <li>
                <Link href="/terms" className="hover:text-primary transition-colors">
                  Terms of Service
                </Link>
              </li>
              <li>
                <Link href="/support" className="hover:text-primary transition-colors">
                  Support
                </Link>
              </li>
            </ul>
          </div>

          {/* Attribution */}
          <div>
            <h4 className="font-semibold text-foreground mb-6">About</h4>
            <p className="text-sm text-muted-foreground leading-relaxed mb-4">
              Built for the RevenueCat Shipyard 2026 Hackathon.
            </p>
            <p className="text-sm text-muted-foreground">
              Designed for audience at{" "}
              <a
                href="https://packslight.com"
                target="_blank"
                rel="noopener noreferrer"
                className="text-primary hover:text-primary-light transition-colors"
              >
                PacksLight
              </a>
            </p>
          </div>
        </div>

        {/* Bottom bar */}
        <div className="border-t border-white/5 pt-8 flex flex-col md:flex-row justify-between items-center gap-4 text-xs text-muted-foreground">
          <p>&copy; {currentYear} Aspire. All rights reserved.</p>
          <div className="flex items-center gap-1">
             Made with <Heart className="w-3 h-3 text-red-500 fill-red-500" /> by Sixtus Agbo
          </div>
        </div>
      </div>
    </footer>
  );
}
