#!/usr/bin/env python3
"""
Convert PNG images to WebP format for Flutter app size optimization.
Creates backup, converts with 90% quality, and provides verification.
"""

import os
import shutil
import sys
from pathlib import Path
from PIL import Image


def main():
    # Configuration
    source_dir = Path("icon/main_icon")
    backup_dir = Path("icon/main_icon_backup")
    quality = 90  # Good balance for icons

    # Verify source directory exists
    if not source_dir.exists():
        print(f"Error: Source directory {source_dir} does not exist")
        sys.exit(1)

    # Find all PNG files
    png_files = list(source_dir.glob("*.png"))
    if not png_files:
        print("No PNG files found in source directory")
        sys.exit(0)

    print(f"Found {len(png_files)} PNG files to convert")

    # Create backup directory
    if backup_dir.exists():
        print(f"Backup directory {backup_dir} already exists, removing...")
        shutil.rmtree(backup_dir)

    backup_dir.mkdir(parents=True)
    print(f"Created backup directory: {backup_dir}")

    # Backup PNG files
    print("\n=== Backing up PNG files ===")
    for png_file in png_files:
        backup_path = backup_dir / png_file.name
        shutil.copy2(png_file, backup_path)
        print(f"  Backed up: {png_file.name}")

    # Convert PNG to WebP
    print(f"\n=== Converting PNG to WebP (quality={quality}) ===")
    converted = []
    failed = []

    for png_file in png_files:
        webp_file = png_file.with_suffix(".webp")
        try:
            # Open and convert
            img = Image.open(png_file)

            # Handle transparency for WebP
            if img.mode in ("RGBA", "LA"):
                # WebP supports transparency
                pass
            elif img.mode != "RGB":
                img = img.convert("RGB")

            # Save as WebP
            img.save(webp_file, "WEBP", quality=quality)

            # Verify file was created
            if webp_file.exists():
                converted.append((png_file, webp_file))
                print(f"  Converted: {png_file.name} -> {webp_file.name}")
            else:
                failed.append((png_file, "WebP file not created"))

        except Exception as e:
            failed.append((png_file, str(e)))
            print(f"  Failed: {png_file.name} - {e}")

    # Summary
    print(f"\n=== Conversion Summary ===")
    print(f"Successfully converted: {len(converted)} files")
    print(f"Failed conversions: {len(failed)} files")

    if failed:
        print("\nFailed files:")
        for png_file, error in failed:
            print(f"  {png_file.name}: {error}")

    # Size comparison
    print(f"\n=== Size Comparison ===")
    total_png_size = 0
    total_webp_size = 0

    for png_file, webp_file in converted:
        png_size = png_file.stat().st_size
        webp_size = webp_file.stat().st_size
        reduction = ((png_size - webp_size) / png_size) * 100 if png_size > 0 else 0

        total_png_size += png_size
        total_webp_size += webp_size

        print(f"  {png_file.name}:")
        print(f"    PNG: {png_size:,} bytes")
        print(f"    WebP: {webp_size:,} bytes")
        print(f"    Reduction: {reduction:.1f}%")

    if converted:
        total_reduction = ((total_png_size - total_webp_size) / total_png_size) * 100
        print(f"\nTotal:")
        print(f"  PNG: {total_png_size:,} bytes")
        print(f"  WebP: {total_webp_size:,} bytes")
        print(f"  Reduction: {total_reduction:.1f}%")
        print(f"  Saved: {total_png_size - total_webp_size:,} bytes")

    # Verification
    print(f"\n=== Verification ===")
    all_webp_exist = all(webp_file.exists() for _, webp_file in converted)
    print(f"All WebP files exist: {all_webp_exist}")

    if all_webp_exist and not failed:
        print("\n✅ Conversion completed successfully!")
        print(f"\nNext steps:")
        print(f"1. Update lib/main.dart references from .png to .webp")
        print(f"2. Run 'flutter clean' to clear build cache")
        print(f"3. Test the app")
        print(f"4. Delete PNG files (or keep in backup)")
        print(f"\nBackup location: {backup_dir}")
    else:
        print("\n⚠️  Conversion completed with issues")
        sys.exit(1)


if __name__ == "__main__":
    main()
