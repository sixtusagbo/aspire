import { Metadata } from "next";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  title: "Privacy Policy - Aspire",
  description: "Privacy Policy for Aspire - From Dreaming to Doing",
};

export default function PrivacyPolicy() {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Header />

      <main className="flex-1 max-w-3xl mx-auto px-4 sm:px-6 py-12 pt-28">
        <h1 className="text-3xl font-bold text-foreground mb-2">
          Privacy Policy
        </h1>
        <p className="text-muted-foreground mb-10">Last updated: January 25, 2026</p>

        <div className="space-y-8 text-foreground/80">
          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              1. Introduction
            </h2>
            <p className="leading-relaxed">
              Aspire (&quot;we,&quot; &quot;our,&quot; or &quot;us&quot;) is
              committed to protecting your privacy. This Privacy Policy explains
              how we collect, use, and safeguard your information when you use
              our mobile application.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              2. Information We Collect
            </h2>
            <p className="leading-relaxed mb-3">
              We collect information you provide directly to us, including:
            </p>
            <ul className="list-disc list-inside space-y-1 ml-2">
              <li>Account information (name, email address)</li>
              <li>Goals and dreams you create</li>
              <li>Micro-actions and progress data</li>
              <li>Notification preferences</li>
              <li>Usage data and app interactions</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              3. How We Use Your Information
            </h2>
            <p className="leading-relaxed mb-3">
              We use the information we collect to:
            </p>
            <ul className="list-disc list-inside space-y-1 ml-2">
              <li>Provide and maintain our service</li>
              <li>Track your progress toward goals</li>
              <li>Send you daily reminders and notifications</li>
              <li>Display your streaks and achievements</li>
              <li>Improve and optimize our app</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              4. Data Storage and Security
            </h2>
            <p className="leading-relaxed">
              Your data is stored securely using Firebase services. We implement
              appropriate security measures to protect your personal information
              against unauthorized access, alteration, disclosure, or
              destruction.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              5. Third-Party Services
            </h2>
            <p className="leading-relaxed mb-3">
              We use the following third-party services:
            </p>
            <ul className="list-disc list-inside space-y-1 ml-2">
              <li>Firebase (authentication and data storage)</li>
              <li>Google Sign-In (authentication)</li>
              <li>RevenueCat (subscription management)</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              6. Your Rights
            </h2>
            <p className="leading-relaxed">
              You have the right to access, update, or delete your personal
              information at any time. To delete your account, go to Settings in
              the app and tap &quot;Delete Account&quot;. This will immediately
              and permanently remove all your data, including your profile,
              goals, micro-actions, and progress history.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              7. Children&apos;s Privacy
            </h2>
            <p className="leading-relaxed">
              Our service is not intended for children under 13 years of age. We
              do not knowingly collect personal information from children under
              13.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              8. Changes to This Policy
            </h2>
            <p className="leading-relaxed">
              We may update this Privacy Policy from time to time. We will
              notify you of any changes by posting the new Privacy Policy on
              this page and updating the &quot;Last updated&quot; date.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              9. Contact Us
            </h2>
            <p className="leading-relaxed">
              If you have any questions about this Privacy Policy, please
              contact us at:{" "}
              <a
                href="mailto:miracleagbosixtus@gmail.com"
                className="text-primary hover:underline"
              >
                miracleagbosixtus@gmail.com
              </a>
            </p>
          </section>
        </div>
      </main>

      <Footer />
    </div>
  );
}
