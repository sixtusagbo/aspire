"use client";

import { motion } from "framer-motion";
import { Target, Zap, Trophy, Plane, Map, BarChart3, Heart } from "lucide-react";

const features = [
  {
    title: "Dream Big",
    description: "Clarify your vision with AI-assisted goal setting.",
    icon: <Target className="w-6 h-6" />,
    className: "md:col-span-2",
  },
  {
    title: "Daily Focus",
    description: "Break down big goals into manageable daily actions.",
    icon: <Zap className="w-6 h-6" />,
    className: "md:col-span-1",
  },
  {
    title: "Track Progress",
    description: "Visual streaks and analytics to keep you motivated.",
    icon: <BarChart3 className="w-6 h-6" />,
    className: "md:col-span-1",
  },
  {
    title: "Celebrate Wins",
    description: "Get rewarded for every milestone you reach.",
    icon: <Trophy className="w-6 h-6" />,
    className: "md:col-span-2",
  },
  {
    title: "Global Community",
    description: "Connect with ambitious women worldwide.",
    icon: <Map className="w-6 h-6" />,
    className: "md:col-span-1",
  },
];

export default function Features() {
  return (
    <section className="py-24 relative overflow-hidden">
      <div className="container mx-auto px-4">
        <div className="text-center max-w-2xl mx-auto mb-16">
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.5 }}
          >
            <h2 className="text-3xl md:text-5xl font-bold mb-6">
              Empower Your <span className="text-gradient">Journey</span>
            </h2>
            <p className="text-muted-foreground text-lg">
              Everything you need to turn your aspirations into achievements.
            </p>
          </motion.div>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-6 max-w-5xl mx-auto">
          {features.map((feature, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.5, delay: index * 0.1 }}
              whileHover={{ y: -5 }}
              className={`relative p-8 rounded-3xl glass-card border border-white/10 hover:border-primary/50 transition-all group overflow-hidden ${feature.className}`}
            >
              {/* Glow effect */}
              <div className="absolute inset-0 bg-gradient-to-br from-primary/5 to-transparent opacity-0 group-hover:opacity-100 transition-opacity" />
              
              <div className="relative z-10 flex flex-col h-full">
                <div className="w-12 h-12 rounded-xl bg-primary/20 flex items-center justify-center text-primary mb-6 group-hover:scale-110 transition-transform duration-300 shadow-[0_0_15px_rgba(157,78,221,0.3)]">
                  {feature.icon}
                </div>
                <h3 className="text-2xl font-bold mb-2">{feature.title}</h3>
                <p className="text-muted-foreground leading-relaxed">
                  {feature.description}
                </p>
              </div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
