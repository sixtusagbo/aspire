"use client";

import { motion } from "framer-motion";
import Image from "next/image";

const testimonials = [
  {
    quote: "Aspire helped me finally launch my travel blog. The daily streaks kept me accountable!",
    author: "Sarah J.",
    role: "Travel Blogger",
    image: "/avatars/sarah.jpg", // Placeholder
  },
  {
    quote: "I love the aesthetic and the gamification. It doesn't feel like work, it feels like leveling up.",
    author: "Michelle K.",
    role: "Entrepreneur",
    image: "/avatars/michelle.jpg", // Placeholder
  },
  {
    quote: "The best goal setting app for visual planners. Highly recommend for anyone with big dreams.",
    author: "Jessica L.",
    role: "Digital Nomad",
    image: "/avatars/jessica.jpg", // Placeholder
  },
];

export default function Testimonials() {
  return (
    <section className="py-24 bg-black/20">
      <div className="container mx-auto px-4">
        <h2 className="text-3xl md:text-5xl font-bold text-center mb-16">
          Loved by <span className="text-gradient">Ambitious Women</span>
        </h2>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8 max-w-6xl mx-auto">
          {testimonials.map((testimonial, index) => (
            <motion.div
              key={index}
              initial={{ opacity: 0, scale: 0.9 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: index * 0.1 }}
              className="p-8 rounded-2xl glass-card border border-white/5 relative"
            >
              <div className="flex items-center gap-4 mb-6">
                <div className="w-12 h-12 rounded-full bg-primary/20 flex items-center justify-center text-primary font-bold text-xl">
                  {testimonial.author[0]}
                </div>
                <div>
                  <h4 className="font-bold">{testimonial.author}</h4>
                  <p className="text-sm text-muted-foreground">{testimonial.role}</p>
                </div>
              </div>
              <p className="text-muted-foreground italic">"{testimonial.quote}"</p>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
