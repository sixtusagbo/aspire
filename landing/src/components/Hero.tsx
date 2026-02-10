"use client";

import { useState } from "react";
import {
  Target,
  Zap,
  Trophy,
  Plane,
  Download,
  ChevronDown,
  ExternalLink,
} from "lucide-react";
import {
  APK_DOWNLOAD_URL,
  GITHUB_RELEASE_URL,
  GOOGLE_FORM_URL,
  PLAY_TESTING_URL,
  PLAY_STORE_URL,
} from "@/lib/links";

export default function Hero() {
  const [showTesting, setShowTesting] = useState(false);

  return (
    <section className="min-h-screen flex items-center justify-center pt-20 pb-16 px-4 overflow-hidden relative">
      <div className="max-w-4xl mx-auto w-full relative z-10 text-center">
        {/* Headline */}
        <h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold text-foreground leading-tight mb-6 tracking-tight">
          From Dreaming
          <br />
          <span className="text-primary">to Doing.</span>
        </h1>

        {/* Subheadline */}
        <p className="text-lg sm:text-xl text-muted max-w-2xl mx-auto mb-8">
          Whether it&apos;s traveling the world, landing that six-figure
          salary, or achieving financial freedom — Aspire helps you close the
          gap between inspiration and action.
        </p>

        {/* Primary CTA */}
        <a
          href={APK_DOWNLOAD_URL}
          className="btn-primary px-8 py-4 rounded-xl text-white font-semibold inline-flex items-center gap-2 shadow-lg shadow-primary/25 hover:shadow-xl hover:shadow-primary/30 active:scale-[0.98] transition-all"
        >
          <Download className="w-5 h-5" />
          Download for Android
        </a>

        {/* Secondary link */}
        <div className="mt-3 mb-4">
          <a
            href={GITHUB_RELEASE_URL}
            target="_blank"
            rel="noopener noreferrer"
            className="text-sm text-muted hover:text-primary transition-colors inline-flex items-center gap-1.5"
          >
            or view all releases on GitHub
            <ExternalLink className="w-3.5 h-3.5" />
          </a>
        </div>

        {/* Collapsible Google Play testing */}
        <div className="max-w-md mx-auto mb-14">
          <button
            onClick={() => setShowTesting(!showTesting)}
            className="text-sm text-primary hover:text-primary/80 transition-colors flex items-center gap-1.5 mx-auto"
          >
            Join Google Play Internal Testing
            <ChevronDown
              className={`w-4 h-4 transition-transform ${showTesting ? "rotate-180" : ""}`}
            />
          </button>

          {showTesting && (
            <div className="mt-4 p-5 rounded-xl bg-card border border-border text-left space-y-4">
              <div className="flex gap-3">
                <span className="shrink-0 w-6 h-6 rounded-full bg-primary/10 text-primary text-xs font-bold flex items-center justify-center">
                  1
                </span>
                <p className="text-sm text-foreground/80">
                  <a
                    href={GOOGLE_FORM_URL}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-primary hover:underline font-medium"
                  >
                    Request access
                    <ExternalLink className="w-3 h-3 inline ml-1 -mt-0.5" />
                  </a>{" "}
                  by filling out a quick form with your Google Play email.
                </p>
              </div>

              <div className="flex gap-3">
                <span className="shrink-0 w-6 h-6 rounded-full bg-primary/10 text-primary text-xs font-bold flex items-center justify-center">
                  2
                </span>
                <p className="text-sm text-foreground/80">
                  Your request will be approved within a few hours. Once
                  approved,{" "}
                  <a
                    href={PLAY_TESTING_URL}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-primary hover:underline font-medium"
                  >
                    join the internal test
                    <ExternalLink className="w-3 h-3 inline ml-1 -mt-0.5" />
                  </a>{" "}
                  on Google Play.
                </p>
              </div>

              <div className="flex gap-3">
                <span className="shrink-0 w-6 h-6 rounded-full bg-primary/10 text-primary text-xs font-bold flex items-center justify-center">
                  3
                </span>
                <p className="text-sm text-foreground/80">
                  <a
                    href={PLAY_STORE_URL}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="text-primary hover:underline font-medium"
                  >
                    Download Aspire
                    <ExternalLink className="w-3 h-3 inline ml-1 -mt-0.5" />
                  </a>{" "}
                  from Google Play and start achieving your goals.
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Features */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
          <FeatureCard
            icon={<Target className="w-6 h-6" />}
            title="Set Big Goals"
            description="Dream big and break it down"
          />
          <FeatureCard
            icon={<Zap className="w-6 h-6" />}
            title="Daily Actions"
            description="Small steps, big results"
          />
          <FeatureCard
            icon={<Trophy className="w-6 h-6" />}
            title="Celebrate Wins"
            description="Confetti and rewards await"
          />
          <FeatureCard
            icon={<Plane className="w-6 h-6" />}
            title="Live Your Dream"
            description="Make it happen"
          />
        </div>
      </div>
    </section>
  );
}

function FeatureCard({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode;
  title: string;
  description: string;
}) {
  return (
    <div className="p-6 rounded-2xl bg-card border border-border hover:border-primary/30 transition-colors">
      <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary mb-4 mx-auto">
        {icon}
      </div>
      <h3 className="font-semibold text-foreground mb-1">{title}</h3>
      <p className="text-sm text-muted">{description}</p>
    </div>
  );
}
