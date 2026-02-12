import Header from "@/components/Header";
import Hero from "@/components/Hero";
import DemoVideo from "@/components/DemoVideo";
import Features from "@/components/Features";
import HowItWorks from "@/components/HowItWorks";
import CallToAction from "@/components/CallToAction";
import Footer from "@/components/Footer";

export default function Home() {
  return (
    <>
      <Header />
      <main className="flex flex-col min-h-screen">
        <Hero />
        <DemoVideo />
        <Features />
        <HowItWorks />
        <CallToAction />
      </main>
      <Footer />
    </>
  );
}
