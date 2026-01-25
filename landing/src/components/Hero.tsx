"use client";

import { Target, Zap, Trophy, Plane } from "lucide-react";

export default function Hero() {
  return (
    <section className="min-h-screen flex items-center justify-center pt-20 pb-16 px-4 overflow-hidden relative">
      <div className="max-w-4xl mx-auto w-full relative z-10 text-center">
        {/* Badge */}
        <div className="inline-flex items-center gap-2 px-4 py-2 rounded-full bg-primary/10 border border-primary/20 mb-8">
          <span className="text-sm font-medium text-primary">
            For ambitious women who want it all
          </span>
        </div>

        {/* Headline */}
        <h1 className="text-5xl sm:text-6xl lg:text-7xl font-bold text-foreground leading-tight mb-6 tracking-tight">
          From Dreaming
          <br />
          <span className="text-primary">to Doing.</span>
        </h1>

        {/* Subheadline */}
        <p className="text-lg sm:text-xl text-muted max-w-2xl mx-auto mb-12">
          Turn your big dreams into daily micro-actions. Whether it&apos;s
          traveling the world, landing that six-figure salary, or achieving
          financial freedom — Aspire helps you close the gap between inspiration
          and action.
        </p>

        {/* Features */}
        <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
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

        {/* CTA */}
        <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
          <a
            href="#"
            className="btn-primary px-8 py-4 rounded-xl text-white font-semibold flex items-center justify-center gap-2 min-w-[200px] shadow-lg shadow-primary/25 hover:shadow-xl hover:shadow-primary/30 active:scale-[0.98] transition-all">
            Coming Soon to Android
          </a>
        </div>

        <p className="text-muted text-sm mt-4">
          Built for the RevenueCat Shipyard 2026 Hackathon
        </p>
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
