export default function DemoVideo() {
  return (
    <section className="py-16 px-4">
      <div className="container mx-auto max-w-3xl">
        <h2 className="text-3xl md:text-4xl font-bold text-center mb-8">
          See It in Action
        </h2>
        <div className="relative w-full aspect-[9/16] max-w-sm mx-auto rounded-2xl overflow-hidden shadow-2xl shadow-primary/20">
          <iframe
            src="https://www.youtube.com/embed/KMDidpoWimY"
            title="Aspire - From Dreaming to Doing | App Demo"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowFullScreen
            className="absolute inset-0 w-full h-full"
          />
        </div>
      </div>
    </section>
  );
}
