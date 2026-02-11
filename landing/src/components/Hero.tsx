"use client";

import { motion } from "framer-motion";
import { Download, ExternalLink, Play } from "lucide-react";
import { APK_DOWNLOAD_URL, GITHUB_RELEASE_URL } from "@/lib/links";

export default function Hero() {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden pt-20 pb-16">
      {/* Background Elements */}
      <div className="absolute inset-0 z-0 select-none pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-primary/20 rounded-full blur-[128px] animate-pulse" />
        <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-secondary/20 rounded-full blur-[128px] animate-pulse delay-1000" />
      </div>

      <div className="container relative z-10 px-4 mx-auto text-center">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="max-w-4xl mx-auto space-y-8"
        >
          {/* Badge */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2 }}
            className="inline-flex items-center gap-2 px-4 py-2 rounded-full glass border border-primary/20 bg-primary/5 hover:bg-primary/10 transition-colors cursor-pointer"
          >
            <span className="relative flex h-2 w-2">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-primary opacity-75"></span>
              <span className="relative inline-flex rounded-full h-2 w-2 bg-primary"></span>
            </span>
            <span className="text-sm font-medium text-primary">v1.2 Now Available</span>
          </motion.div>

          {/* Headline */}
          <h1 className="text-5xl md:text-7xl font-bold tracking-tight">
            Turn Ambition <br />
            <span className="text-gradient">Into Action</span>
          </h1>

          {/* Subheadline */}
          <p className="text-lg md:text-xl text-muted-foreground max-w-2xl mx-auto leading-relaxed">
            Close the gap between dreaming and doing. AI-powered goal planning designed for ambitious women who want it all.
          </p>

          {/* CTA Buttons */}
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4 pt-4">
            <motion.a
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              href={APK_DOWNLOAD_URL}
              className="btn-primary px-8 py-4 rounded-xl text-white font-semibold flex items-center gap-2 shadow-lg shadow-primary/25 hover:shadow-primary/40 transition-all w-full sm:w-auto justify-center"
            >
              <Download className="w-5 h-5" />
              Download APK
            </motion.a>
            <motion.a
              whileHover={{ scale: 1.05 }}
              whileTap={{ scale: 0.95 }}
              href="#join-internal-testing"
              className="px-8 py-4 rounded-xl glass border border-white/10 hover:bg-white/5 transition-all w-full sm:w-auto flex items-center justify-center gap-2 font-medium"
            >
              <Play className="w-5 h-5 fill-current" />
              Join Internal Testing
            </motion.a>
          </div>

          {/* Secondary Links */}
          <div className="pt-8 flex items-center justify-center gap-6 text-sm text-muted-foreground">
            <a href={GITHUB_RELEASE_URL} target="_blank" rel="noopener noreferrer" className="hover:text-primary transition-colors flex items-center gap-1">
              View on GitHub <ExternalLink className="w-3 h-3" />
            </a>
            <span>•</span>
            <span>Free & Open Source</span>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
