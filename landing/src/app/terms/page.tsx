import { Metadata } from "next";
import Header from "@/components/Header";
import Footer from "@/components/Footer";

export const metadata: Metadata = {
  title: "Terms of Service - Aspire",
  description: "Terms of Service for Aspire - From Dreaming to Doing",
};

export default function TermsOfService() {
  return (
    <div className="min-h-screen bg-background flex flex-col">
      <Header />

      <main className="flex-1 max-w-3xl mx-auto px-4 sm:px-6 py-12 pt-28">
        <h1 className="text-3xl font-bold text-foreground mb-2">
          Terms of Service
        </h1>
        <p className="text-muted mb-10">Last updated: January 25, 2026</p>

        <div className="space-y-8 text-foreground/80">
          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              1. Acceptance of Terms
            </h2>
            <p className="leading-relaxed">
              By accessing or using Aspire (&quot;the App&quot;), you agree to
              be bound by these Terms of Service. If you do not agree to these
              terms, please do not use the App.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              2. Description of Service
            </h2>
            <p className="leading-relaxed">
              Aspire is a mobile application designed to help users turn their
              big dreams into daily micro-actions through goal setting, progress
              tracking, and gamification. The App is provided &quot;as is&quot;
              and we reserve the right to modify or discontinue features at any
              time.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              3. User Accounts
            </h2>
            <p className="leading-relaxed">
              You are responsible for maintaining the confidentiality of your
              account credentials and for all activities that occur under your
              account. You must provide accurate information when creating an
              account and keep it up to date.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              4. Subscription and Payments
            </h2>
            <p className="leading-relaxed">
              Aspire offers free and premium subscription options. Current
              pricing and features are available within the app. Subscriptions
              are managed through Google Play and are subject to their terms and
              conditions. You can cancel your subscription at any time through
              your device&apos;s subscription settings.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              5. Acceptable Use
            </h2>
            <p className="leading-relaxed mb-3">You agree not to:</p>
            <ul className="list-disc list-inside space-y-1 ml-2">
              <li>Use the App for any unlawful purpose</li>
              <li>
                Attempt to gain unauthorized access to the App or its systems
              </li>
              <li>Interfere with or disrupt the App&apos;s functionality</li>
              <li>
                Share your account with others or create multiple accounts
              </li>
              <li>Use the App to transmit harmful or malicious content</li>
            </ul>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              6. Intellectual Property
            </h2>
            <p className="leading-relaxed">
              All content, features, and functionality of the App, including but
              not limited to text, graphics, logos, and software, are owned by
              Aspire and are protected by intellectual property laws.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              7. Disclaimer
            </h2>
            <p className="leading-relaxed">
              Aspire is a goal-tracking and motivation app. We do not guarantee
              any specific results from using the App. Your success depends on
              your own efforts and dedication to achieving your goals.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              8. Limitation of Liability
            </h2>
            <p className="leading-relaxed">
              To the maximum extent permitted by law, Aspire shall not be liable
              for any indirect, incidental, special, consequential, or punitive
              damages resulting from your use of or inability to use the App.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              9. Termination
            </h2>
            <p className="leading-relaxed">
              We reserve the right to suspend or terminate your access to the
              App at any time, with or without cause and without notice. You may
              also delete your account at any time through the App settings.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              10. Changes to Terms
            </h2>
            <p className="leading-relaxed">
              We may update these Terms of Service from time to time. We will
              notify you of significant changes by posting the new terms on this
              page. Your continued use of the App after changes constitutes
              acceptance of the updated terms.
            </p>
          </section>

          <section>
            <h2 className="text-xl font-semibold text-foreground mb-3">
              11. Contact Us
            </h2>
            <p className="leading-relaxed">
              If you have any questions about these Terms of Service, please
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
