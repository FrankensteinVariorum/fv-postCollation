# About the edit-distance directory 

This directory stores scripts used to calculate Levenshtein edit-distances used in the postCollation pipeline for the Frankenstein Variorum project. For an explanation of the files involved here, 
see [the edit-distance stage](https://github.com/FrankensteinVariorum/fv-postCollation?tab=readme-ov-file#inside-the-edit-distance-directory-run-at-shell-python-levencalc_toxmlpy) of the pipeline documentation on the main README file. 

The directory also includes files for generating [an interactive SVG heatmap visualization](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/editionHeatMap-with-Guide.svg) based on locations of high-intensity revision (with edit-distance calculations of 50 or more) 
found throughout the Frankenstein Variorum. The heatmap visualization is developed in two stages, with these files / dependencies all found in this repository:

1. [editionHeatMap-to-SVG.xsl](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/editionHeatMap-to-SVG.xsl) develops the heatmap lines and colors from the
   five documents, based on calculated data in the postCollation pipeline. **It will output [editionHeatMap.svg](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/editionHeatMap.svg)**.
   The editionHeatMap-to-SVG.xsl file pulls data from: 
     * a file specially prepared for processing the heatmap: [svgPrep-witLevData.xml](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/svgPrep-witLevData.xml)
     If updating the edition files in a way that updates the spine and hotspots, this source file will need to be updated before generating the heatmap. It depends on:
          * [FV_LevDists-simplified.xml](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/FV_LevDists-simplified.xml)
          * [svgPrep-refactor.xsl](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/svgPrep-refactor.xsl): Run this over FV_LevDists-simplified.xml and output svgPrep-witLeveData.xml.
     * The [standoff_Spine directory](https://github.com/FrankensteinVariorum/fv-postCollation/tree/master/postColl-workspace/standoff_Spine), which contains the fully constructed "spine" files constructed during the postCollation pipeline.

2. To add lines and text labels showing the chapter boundaries of 1818 and 1831 editions on the heatmap, run [guideMarks-to-SVG.xsl](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/guideMarks-to-SVG.xsl).
   This pulls data from the [editionHeatMap.svg](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/editionHeatMap.svg)** generated in the previous stage, and also the
   [standoff_Spine directory](https://github.com/FrankensteinVariorum/fv-postCollation/tree/master/postColl-workspace/standoff_Spine) again. It will output the complete heatmap with guidemarks as [editionHeatMap-with-Guide.svg](https://github.com/FrankensteinVariorum/fv-postCollation/blob/master/postColl-workspace/edit-distance/editionHeatMap-with-Guide.svg).

   After generating a new heatmap, it should be incorporated with the edition files in the fv-web repo. The SVG code should be included directly in pages in the Astro site for the links to work. 
