import Footer from "@/components/Footer";
import FeaturesSection from "@/components/FeaturesSection";
import HeroSection from "@/components/HeroSection";
import PrivacySection from "@/components/PrivacySection";

export default function Home() {
  return (
    <div className="min-h-screen bg-surface text-on-surface flex flex-col">
      <main className="flex-1">
        <HeroSection />
        <FeaturesSection />
        <PrivacySection />
      </main>
      <Footer />
    </div>
  );
}
