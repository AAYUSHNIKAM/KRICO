import os
import pypdfium2 as pdfium

def main():
    pdf_dir = "certificates_showcase/pdfs"
    out_dir = "certificates_showcase/pdf_snapshots"
    os.makedirs(out_dir, exist_ok=True)

    pdf_files = sorted([f for f in os.listdir(pdf_dir) if f.endswith(".pdf")])
    print(f"Found {len(pdf_files)} PDF files to rasterize...")

    for fname in pdf_files:
        pdf_path = os.path.join(pdf_dir, fname)
        pdf = pdfium.PdfDocument(pdf_path)
        page = pdf[0]
        # Render at 2.5x resolution for ultra-sharp snapshot (approx 2100x1485)
        bitmap = page.render(scale=2.5)
        pil_image = bitmap.to_pil()
        
        base_name = os.path.splitext(fname)[0]
        out_path = os.path.join(out_dir, f"{base_name}.png")
        pil_image.save(out_path, format="PNG")
        print(f"Rasterized: {out_path} ({pil_image.width}x{pil_image.height})")

    print("All 15 PDF snapshots generated successfully!")

if __name__ == "__main__":
    main()
