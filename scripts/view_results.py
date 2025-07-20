#!/usr/bin/env python3
"""
Fooocus Batch Results Viewer
Helps analyze and compare generated images
"""

import os
import json
import argparse
from pathlib import Path
from datetime import datetime
import shutil
from typing import List, Dict, Optional


class ResultsViewer:
    def __init__(self, results_dir: str):
        self.results_dir = Path(results_dir)
        self.results = []
        
    def load_results(self):
        """Load all results from batch outputs"""
        for batch_dir in self.results_dir.iterdir():
            if batch_dir.is_dir():
                summary_file = batch_dir / 'batch_summary.json'
                if summary_file.exists():
                    with open(summary_file, 'r') as f:
                        data = json.load(f)
                        for result in data['results']:
                            result['batch_dir'] = batch_dir.name
                            result['full_path'] = batch_dir / result['filename']
                            self.results.append(result)
        
        print(f"Loaded {len(self.results)} results from {len(set(r['batch_dir'] for r in self.results))} batches")
    
    def filter_results(self, 
                      base_model: Optional[str] = None,
                      has_refiner: Optional[bool] = None,
                      has_loras: Optional[bool] = None,
                      prompt_contains: Optional[str] = None) -> List[Dict]:
        """Filter results based on criteria"""
        filtered = self.results
        
        if base_model:
            filtered = [r for r in filtered if base_model in r['base_model']]
        
        if has_refiner is not None:
            if has_refiner:
                filtered = [r for r in filtered if r['refiner_model'] != 'None']
            else:
                filtered = [r for r in filtered if r['refiner_model'] == 'None']
        
        if has_loras is not None:
            if has_loras:
                filtered = [r for r in filtered if len(r['loras']) > 0]
            else:
                filtered = [r for r in filtered if len(r['loras']) == 0]
        
        if prompt_contains:
            filtered = [r for r in filtered if prompt_contains.lower() in r['prompt'].lower()]
        
        return filtered
    
    def show_statistics(self):
        """Display statistics about results"""
        print("\n=== Batch Results Statistics ===")
        print(f"Total images: {len(self.results)}")
        
        # Model statistics
        base_models = {}
        refiner_models = {}
        lora_models = {}
        
        for result in self.results:
            # Base models
            base = result['base_model']
            base_models[base] = base_models.get(base, 0) + 1
            
            # Refiners
            refiner = result['refiner_model']
            refiner_models[refiner] = refiner_models.get(refiner, 0) + 1
            
            # LoRAs
            for lora in result['loras']:
                lora_name = lora['name']
                lora_models[lora_name] = lora_models.get(lora_name, 0) + 1
        
        print("\nBase Models Used:")
        for model, count in sorted(base_models.items(), key=lambda x: x[1], reverse=True):
            print(f"  {model}: {count} images")
        
        print("\nRefiner Models Used:")
        for model, count in sorted(refiner_models.items(), key=lambda x: x[1], reverse=True):
            print(f"  {model}: {count} images")
        
        if lora_models:
            print("\nLoRA Models Used:")
            for model, count in sorted(lora_models.items(), key=lambda x: x[1], reverse=True)[:10]:
                print(f"  {model}: {count} images")
    
    def copy_best_results(self, indices: List[int], output_dir: str):
        """Copy selected results to a new directory"""
        output_path = Path(output_dir)
        output_path.mkdir(parents=True, exist_ok=True)
        
        for idx in indices:
            if 0 <= idx < len(self.results):
                result = self.results[idx]
                src_image = result['full_path']
                src_metadata = src_image.with_suffix('.json')
                
                if src_image.exists():
                    # Copy image
                    dst_image = output_path / f"best_{idx:04d}_{src_image.name}"
                    shutil.copy2(src_image, dst_image)
                    
                    # Copy metadata if exists
                    if src_metadata.exists():
                        dst_metadata = dst_image.with_suffix('.json')
                        shutil.copy2(src_metadata, dst_metadata)
                    
                    print(f"Copied: {dst_image.name}")
    
    def create_comparison_html(self, output_file: str = "comparison.html"):
        """Create an HTML file for easy comparison"""
        html_content = """
<!DOCTYPE html>
<html>
<head>
    <title>Fooocus Batch Results</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .gallery { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 20px; }
        .image-card { border: 1px solid #ddd; padding: 10px; border-radius: 5px; }
        .image-card img { width: 100%; height: auto; cursor: pointer; }
        .metadata { font-size: 12px; margin-top: 10px; }
        .filters { margin-bottom: 20px; padding: 20px; background: #f5f5f5; border-radius: 5px; }
        .filter-group { margin-bottom: 10px; }
        .highlight { background-color: yellow; }
    </style>
</head>
<body>
    <h1>Fooocus Batch Results</h1>
    
    <div class="filters">
        <h3>Filters</h3>
        <div class="filter-group">
            <input type="text" id="searchBox" placeholder="Search prompts..." onkeyup="filterImages()">
        </div>
        <div class="filter-group">
            <label><input type="checkbox" id="showRefiner" checked onchange="filterImages()"> Show with refiner</label>
            <label><input type="checkbox" id="showNoRefiner" checked onchange="filterImages()"> Show without refiner</label>
        </div>
        <div class="filter-group">
            <label><input type="checkbox" id="showLoras" checked onchange="filterImages()"> Show with LoRAs</label>
            <label><input type="checkbox" id="showNoLoras" checked onchange="filterImages()"> Show without LoRAs</label>
        </div>
    </div>
    
    <div class="gallery" id="gallery">
"""
        
        for idx, result in enumerate(self.results):
            image_path = result['full_path']
            if image_path.exists():
                # Create relative path for HTML
                rel_path = os.path.relpath(image_path, self.results_dir.parent)
                
                # Prepare metadata
                has_refiner = result['refiner_model'] != 'None'
                has_loras = len(result['loras']) > 0
                lora_names = ', '.join([l['name'] for l in result['loras']])
                
                html_content += f"""
        <div class="image-card" data-index="{idx}" 
             data-prompt="{result['prompt'].lower()}"
             data-has-refiner="{has_refiner}"
             data-has-loras="{has_loras}">
            <img src="{rel_path}" onclick="window.open(this.src)" alt="Result {idx}">
            <div class="metadata">
                <strong>Index:</strong> {idx}<br>
                <strong>Base:</strong> {result['base_model']}<br>
                <strong>Refiner:</strong> {result['refiner_model']}<br>
                <strong>LoRAs:</strong> {lora_names or 'None'}<br>
                <strong>Steps:</strong> {result['settings']['steps']}<br>
                <strong>CFG:</strong> {result['settings']['cfg_scale']}<br>
                <details>
                    <summary>Prompt</summary>
                    <p>{result['prompt']}</p>
                </details>
            </div>
        </div>
"""
        
        html_content += """
    </div>
    
    <script>
    function filterImages() {
        const searchTerm = document.getElementById('searchBox').value.toLowerCase();
        const showRefiner = document.getElementById('showRefiner').checked;
        const showNoRefiner = document.getElementById('showNoRefiner').checked;
        const showLoras = document.getElementById('showLoras').checked;
        const showNoLoras = document.getElementById('showNoLoras').checked;
        
        const cards = document.querySelectorAll('.image-card');
        
        cards.forEach(card => {
            const prompt = card.getAttribute('data-prompt');
            const hasRefiner = card.getAttribute('data-has-refiner') === 'True';
            const hasLoras = card.getAttribute('data-has-loras') === 'True';
            
            let show = true;
            
            // Search filter
            if (searchTerm && !prompt.includes(searchTerm)) {
                show = false;
            }
            
            // Refiner filter
            if (hasRefiner && !showRefiner) show = false;
            if (!hasRefiner && !showNoRefiner) show = false;
            
            // LoRA filter  
            if (hasLoras && !showLoras) show = false;
            if (!hasLoras && !showNoLoras) show = false;
            
            card.style.display = show ? 'block' : 'none';
        });
    }
    </script>
</body>
</html>
"""
        
        output_path = self.results_dir.parent / output_file
        with open(output_path, 'w') as f:
            f.write(html_content)
        
        print(f"\nComparison HTML created: {output_path}")
        print(f"Open in browser to view and compare all results")


def main():
    parser = argparse.ArgumentParser(description='View and analyze Fooocus batch results')
    parser.add_argument('--dir', type=str, default='batch_outputs', help='Results directory')
    parser.add_argument('--stats', action='store_true', help='Show statistics')
    parser.add_argument('--filter-base', type=str, help='Filter by base model name')
    parser.add_argument('--filter-refiner', action='store_true', help='Show only results with refiner')
    parser.add_argument('--filter-no-refiner', action='store_true', help='Show only results without refiner')
    parser.add_argument('--filter-loras', action='store_true', help='Show only results with LoRAs')
    parser.add_argument('--filter-no-loras', action='store_true', help='Show only results without LoRAs')
    parser.add_argument('--copy-best', nargs='+', type=int, help='Copy best results by index')
    parser.add_argument('--copy-to', type=str, default='best_results', help='Directory for best results')
    parser.add_argument('--html', action='store_true', help='Create HTML comparison page')
    
    args = parser.parse_args()
    
    viewer = ResultsViewer(args.dir)
    viewer.load_results()
    
    if args.stats:
        viewer.show_statistics()
    
    # Apply filters
    filtered = viewer.results
    if args.filter_base:
        filtered = viewer.filter_results(base_model=args.filter_base)
    if args.filter_refiner:
        filtered = viewer.filter_results(has_refiner=True)
    if args.filter_no_refiner:
        filtered = viewer.filter_results(has_refiner=False)
    if args.filter_loras:
        filtered = viewer.filter_results(has_loras=True)
    if args.filter_no_loras:
        filtered = viewer.filter_results(has_loras=False)
    
    # Show filtered results
    if filtered != viewer.results:
        print(f"\nFiltered to {len(filtered)} results:")
        for idx, result in enumerate(filtered[:20]):  # Show first 20
            print(f"{idx}: {result['filename']} - Base: {result['base_model'][:30]}")
    
    # Copy best results
    if args.copy_best:
        viewer.copy_best_results(args.copy_best, args.copy_to)
    
    # Create HTML
    if args.html:
        viewer.create_comparison_html()


if __name__ == '__main__':
    main()