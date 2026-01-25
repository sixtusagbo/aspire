import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import { ThemeProvider } from "@/components/ThemeProvider";

const inter = Inter({
  variable: "--font-inter",
  subsets: ["latin"],
  display: "swap",
});

export const metadata: Metadata = {
  title: "Aspire - From Dreaming to Doing",
  description:
    "Turn your big dreams into daily micro-actions. The app for ambitious women who want to travel, build careers, and achieve financial freedom.",
  keywords: [
    "goal setting",
    "micro-actions",
    "women empowerment",
    "travel goals",
    "career goals",
    "financial freedom",
    "habit tracking",
    "aspire app",
  ],
  authors: [{ name: "Aspire" }],
  creator: "Aspire",
  publisher: "Aspire",
  robots: "index, follow",
  openGraph: {
    type: "website",
    locale: "en_US",
    url: "https://aspire-app.vercel.app",
    siteName: "Aspire",
    title: "Aspire - From Dreaming to Doing",
    description:
      "Turn your big dreams into daily micro-actions. For ambitious women who want it all.",
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
      "Turn your big dreams into daily micro-actions. For ambitious women who want it all.",
    images: ["/og-image.png"],
  },
  icons: [
    { url: "/favicon.ico", sizes: "16x16 32x32", type: "image/x-icon" },
    { url: "/apple-touch-icon.png", rel: "apple-touch-icon" },
  ],
  metadataBase: new URL("https://aspire-app.vercel.app"),
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
    applicationCategory: "LifestyleApplication",
    operatingSystem: "Android",
    description:
      "Turn your big dreams into daily micro-actions with gamified tracking and celebration.",
    offers: {
      "@type": "Offer",
      price: "0",
      priceCurrency: "USD",
    },
  };

  return (
    <html lang="en" suppressHydrationWarning>
      <head>
        <link rel="canonical" href="https://aspire-app.vercel.app" />
        <script
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
        />
      </head>
      <body className={`${inter.variable} antialiased`}>
        <ThemeProvider
          attribute="data-theme"
          defaultTheme="light"
          enableSystem={false}
        >
          {children}
        </ThemeProvider>
      </body>
    </html>
  );
}
