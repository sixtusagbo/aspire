"use client";

import { motion } from "framer-motion";
import { Users, CheckCircle, Download } from "lucide-react";
import { GOOGLE_FORM_URL, APK_DOWNLOAD_URL, PLAY_TESTING_URL } from "@/lib/links";

const steps = [
  {
    icon: <Users className="w-6 h-6" />,
    title: "Join the Testers Group",
    description: "Your gateway to early access. Join our Google Group to get approved.",
    action: "Join Group",
    href: GOOGLE_FORM_URL,
  },
  {
    icon: <CheckCircle className="w-6 h-6" />,
    title: "Opt-in to Testing",
    description: "Once joined, become a tester on the web to unlock the app.",
    action: "Become a Tester",
    href: PLAY_TESTING_URL,
  },
  {
    icon: <Download className="w-6 h-6" />,
    title: "Download App",
    description: "Get the app from the Play Store and start your journey.",
    action: "Download Details",
    href: APK_DOWNLOAD_URL,
  },
];

export default function HowItWorks() {
  return (
    <section id="join-internal-testing" className="py-24 relative overflow-hidden scroll-mt-20">
      {/* Background Decor */}
      <div className="absolute inset-0 z-0">
        <div className="absolute top-1/2 left-1/4 w-96 h-96 bg-primary/10 rounded-full blur-[128px]" />
      </div>

      <div className="container relative z-10 mx-auto px-4">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl md:text-5xl font-bold mb-4">
            How to Join <span className="text-gradient">Internal Testing</span>
          </h2>
          <p className="text-muted-foreground text-lg max-w-2xl mx-auto">
            Three simple steps to start your journey with Aspire.
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-5xl mx-auto">
          {steps.map((step, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.2 }}
              className="relative"
            >
              {/* Connector Line (Desktop) */}
              {index < steps.length - 1 && (
                <div className="hidden md:block absolute top-12 left-1/2 w-full h-0.5 bg-gradient-to-r from-primary/50 to-primary/0 z-0" />
              )}

              <div className="relative z-10 flex flex-col items-center text-center p-8 rounded-3xl glass-card border border-white/5 hover:border-primary/20 transition-all group">
                <div className="w-16 h-16 rounded-2xl bg-primary/20 flex items-center justify-center text-primary mb-6 group-hover:scale-110 transition-transform duration-300 shadow-[0_0_20px_rgba(219,66,145,0.3)]">
                  {step.icon}
                </div>
                <h3 className="text-xl font-bold mb-3">{step.title}</h3>
                <p className="text-muted-foreground mb-6 text-sm">
                  {step.description}
                </p>
                <a
                  href={step.href}
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-sm font-semibold text-primary hover:text-primary/80 transition-colors flex items-center gap-1"
                >
                  {step.action} &rarr;
                </a>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
