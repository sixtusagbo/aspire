import { Download } from "lucide-react";
import { APK_DOWNLOAD_URL } from "@/lib/links";

export default function CallToAction() {
  return (
    <section className="py-24 relative overflow-hidden">
      {/* Background Glow */}
      <div className="absolute inset-0 z-0">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px] bg-primary/20 rounded-full blur-[128px] opacity-50" />
      </div>

      <div className="container relative z-10 mx-auto px-4">
        <div className="max-w-4xl mx-auto text-center space-y-8">
          <h2 className="text-4xl md:text-6xl font-bold tracking-tight">
            Ready to Start <span className="text-gradient">Doing?</span>
          </h2>

          <p className="text-xl text-muted-foreground max-w-2xl mx-auto">
            Join thousands of ambitious women who are turning their dreams into reality with Aspire.
          </p>

          <div className="pt-4">
            <a
              href={APK_DOWNLOAD_URL}
              className="btn-primary inline-flex items-center gap-2 px-8 py-4 rounded-xl text-white font-bold text-lg shadow-xl shadow-primary/20 hover:shadow-primary/40 hover:scale-105 transition-all"
            >
              <Download className="w-5 h-5" />
              Download Now
            </a>
          </div>
        </div>
      </div>
    </section>
  );
}
