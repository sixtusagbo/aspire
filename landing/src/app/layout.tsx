import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  metadataBase: new URL("https://aspire.sixtusagbo.dev"),
  title: {
    default: "Aspire - From Dreaming to Doing",
    template: "%s | Aspire",
  },
  description:
    "Close the gap between inspiration and action. AI-powered goal planning with streaks and celebrations for ambitious women.",
  keywords: [
    "goal setting app",
    "action planning",
    "women empowerment",
    "travel goals",
    "career goals",
    "financial freedom",
    "habit tracking",
    "goal tracker",
    "aspire app",
    "AI goal planning",
    "daily streaks",
  ],
  authors: [{ name: "Sixtus Agbo" }],
  creator: "Sixtus Agbo",
  publisher: "Aspire",
  robots: {
    index: true,
    follow: true,
    googleBot: {
      index: true,
      follow: true,
      "max-video-preview": -1,
      "max-image-preview": "large",
      "max-snippet": -1,
    },
  },
  alternates: {
    canonical: "/",
  },
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://aspire.sixtusagbo.dev",
    siteName: "Aspire",
    title: "Aspire - From Dreaming to Doing",
    description:
      "Close the gap between inspiration and action. AI-powered goal planning with streaks and celebrations for ambitious women.",
    images: [
      {
        url: "/og-image.png",
        width: 1200,
        height: 630,
        alt: "Aspire - From Dreaming to Doing",
      },
    ],
  },
  twitter: {
    card: "summary_large_image",
    title: "Aspire - From Dreaming to Doing",
    description:
      "Close the gap between inspiration and action. AI-powered goal planning with streaks and celebrations for ambitious women.",
    images: ["/og-image.png"],
  },
  icons: [
    { url: "/favicon.ico", sizes: "16x16 32x32", type: "image/x-icon" },
    { url: "/apple-touch-icon.png", rel: "apple-touch-icon" },
  ],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "SoftwareApplication",
    name: "Aspire",
    url: "https://aspire.sixtusagbo.dev",
    applicationCategory: "LifestyleApplication",
    operatingSystem: "Android",
    description:
      "AI-powered goal planning with gamified tracking and celebrations for ambitious women.",
    author: {
      "@type": "Person",
      name: "Sixtus Agbo",
    },
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "USD",
    },
    downloadUrl:
      "https://play.google.com/store/apps/details?id=dev.sixtusagbo.aspire",
    screenshot: "https://aspire.sixtusagbo.dev/og-image.png",
  };

  return (
    <html lang="en" className="dark">
      <head>
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body className={`${inter.variable} antialiased`}>
        {children}
      </body>
    </html>
  );
}
