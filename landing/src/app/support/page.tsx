import { Metadata } from "next";
import Header from "@/components/Header";
import Footer from "@/components/Footer";
import { Mail, MessageCircle } from "lucide-react";

export const metadata: Metadata = {
  title: "Support - Aspire",
  description: "Get help with Aspire - From Dreaming to Doing",
};

export default function Support() {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Header />

      <main className="flex-1 max-w-3xl mx-auto px-4 sm:px-6 py-12 pt-28">
        <h1 className="text-3xl font-bold text-foreground mb-2">Support</h1>
        <p className="text-muted mb-10">
          We&apos;re here to help you achieve your dreams.
        </p>

        <div className="space-y-8">
          <section className="p-6 rounded-2xl bg-card border border-border">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary flex-shrink-0">
                <Mail className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-xl font-semibold text-foreground mb-2">
                  Email Support
                </h2>
                <p className="text-foreground/80 mb-4">
                  Have a question or need help? Send us an email and we&apos;ll
                  get back to you as soon as possible.
                </p>
                <a
                  href="mailto:sixtusagbo@gmail.com"
                  className="inline-flex items-center gap-2 text-primary hover:underline font-medium"
                >
                  sixtusagbo@gmail.com
                </a>
              </div>
            </div>
          </section>

          <section className="p-6 rounded-2xl bg-card border border-border">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary flex-shrink-0">
                <MessageCircle className="w-6 h-6" />
              </div>
              <div>
                <h2 className="text-xl font-semibold text-foreground mb-2">
                  Frequently Asked Questions
                </h2>
                <div className="space-y-4 mt-4">
                  <div>
                    <h3 className="font-medium text-foreground">
                      How do I create a goal?
                    </h3>
                    <p className="text-foreground/80 text-sm mt-1">
                      Tap the &quot;+&quot; button on the home screen, enter
                      your dream or goal, set a target date, and we&apos;ll help
                      you break it down into daily micro-actions.
                    </p>
                  </div>
                  <div>
                    <h3 className="font-medium text-foreground">
                      What&apos;s the difference between free and premium?
                    </h3>
                    <p className="text-foreground/80 text-sm mt-1">
                      Free users can have 1 active goal. Premium users get
                      unlimited goals, detailed analytics, and custom reminder
                      times.
                    </p>
                  </div>
                  <div>
                    <h3 className="font-medium text-foreground">
                      How do I delete my account?
                    </h3>
                    <p className="text-foreground/80 text-sm mt-1">
                      Go to Settings &gt; Delete Account. This will permanently
                      remove all your data including goals, progress, and
                      achievements.
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </section>
        </div>
      </main>

      <Footer />
    </div>
  );
}
