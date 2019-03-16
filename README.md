# fv-postCollation
This repository is part of the [Frankenstein Variorum project](https://github.com/PghFrankenstein) It contains a workspace for post-processing finalized collation files to prepare the Variorum edition. For more on the Frankenstein Variorum project underway, see <https://pghfrankenstein.github.io/Pittsburgh_Frankenstein/>.

The workspace in this repo houses a transformation pipeline. Here is a summary of the files to run in order, which an explanation of each process. We plan to bundle these stages into one or two automated processes when the Variorum development is stable. 

### Run `P1-bridgeEditionConstructor.xsl`
* **Input:** `collated-data` directory
* **Output:** `P1-output` directory
* 2018-06-21 ebb: Bridge Edition Constructor Part 1: This first phase up-converts collation data files to TEI and adds `@xml:ids` to each `<app>` element in the output collation. In the event that the collation process broke apart the self-closed elements into two tags, this stylesheet catches these and restores them to single tags.

### Run `P2-bridgeEditionConstructor.xsl`
* **Input:** `P1-output` directory
* **Output:** `P2-output` directory
* 2018-10-10 ebb: Updated and simplified to process current files that DO have meaningful rdgGrp elements. 
* 2018-06-21 ebb updated 2018-08-01: Bridge Edition Constructor Part 2: This second phase begins building the output Bridge editions by consuming the `<app>` and and `<rdg>` elements to replace them with `<seg>` elements that hold the identifiers of their apps and indication of whether they are portions.
* This stylesheet does NOT YET generate the spine file. We're deferring that to a later stage when we know where the `<seg>` elements turn up in relation to the hierarchy of the edition elements. 
* We are now generating the spine file following the edition files constructed in bridge P5, so that we have the benefit of seeing the `<seg>` elements where they need to be multiplied (e.g. around paragraph breaks). We can then generate pointers to more precise locations. 
    
### Run `P3-bridgeEditionConstructor.xsl`
* **Input:** `P2-output` directory
* **Output:** `P3-output` directory
* In Bridge Construction Phase 3, we are up-converting the text-converted tags in the edition files into self-closed elements. We add the th: namespace prefix to "trojan horse" attributes used for markers.* 2018-06-22: ebb: We can't use `<ab>` for top-level structures once we start regenerating `<p>` elements, since `<ab>` isn't allowed to contain `<p>`. * a start tag of an unflattened element (left as a whole element prior to collation).* an end tag of an unflattened element* matches strings representing flattened element tags marked with sID and eID attributes. * matches text strings representing self-closed elements (the milestone elements and such like). 

### Run `P3.5-bridgeEditionConstructor.xsl`
* **Input:** `P3-output` directory
* **Output:** `P3.5-output` directory 
* 2018-10-10 ebb: For stage 3.5 we need to reconstruct full collation chunks that have been subdivided into parts. For example, C08 was divided into parts C08a through C08j, often breaking up element tag pairs. Here we reunite the pieces so we can move on to up-raising the flattened elements in the editions.

### Run `P4-raiseBridgeElems.xsl`
* **Input:** `P3.5-output` directory 
* **Output:** `P4-output` directory 
* 2018-07-07 ebb: This stylesheet works to raise "trojan elements" from the inside out, this time over a collection of Frankenstein files output from collation. It also adapts djb's function to process an element node rather than a document node in memory to perform its recursive processing. 
* 2018-07-23 ebb: I've updated this stylesheet to work with the th:raise function as expressed in `raise_deep.xsl`.  

### Run `P4Sax-raiseBridgeElems.xsl`
This is an alternative version of the P4 transformation designed to run in the shell rather than in oXygen. We may wish to use this when working with the full scope of edition files representing the novel from start to end, where oXygen processing may be bogged down.   
*  2018-10-11 ebb: UPDATED for new fv-postCollation repo: This version of the stylesheet is designed to run at command line (so references to specific file collections are commented out). Run this in the terminal or command line by navigating to the directory holding this XSLT (and the saxon files necessary) and entering
``
       java -jar saxon.jar -s:P3.5-output -xsl:P4Sax-raiseBridgeElems.xsl -o:P4-output
``       
* 2018-07-15 ebb: Bridge Phase 4 raises the hierarchy of elements from the source documents, leaving the seg elements unraised. This stylesheet uses an "inside-out" function to raise the elements from the deepest levels (those with only text nodes between their start and end markers) first. This and other methods to "raise" flattened or "Trojan" elements are documented in https://github.com/djbpitt/raising with thanks to David J. Birnbaum and Michael Sperberg-McQueen for their helpful experiments. 


### Run `P5-Pt1-SegTrojans.xsl`
* **Input:** `P4-output` directory 
* **Output:** `preP5a-output` directory
* 2018-07-29: Bridge Construction Phase 5: What we need to do:      
       *  where the end markers of seg elements are marked we reconstruct them in pieces. 
        * raise the `<seg>` marker elements marking hotspots
       *  deliver seg identifying locations to the Spinal Column file.
* In this first stage of Part 5, we are converting the seg elements into Trojan markers using the th:namespace, and explicitly designating those that are fragments (that will break hierarchy if raised) as parts by adding a part attribute. 
    * In the next stage, we will need to add additional seg elements to handle fragmented hotspots that break across the edition element hierarchy.
    * In the last stage of this process, we adapt CMSpMq's left-to-right sibling traversal for raising flattened elements.  
    * segs with START IDs 
       * for simple segs with START IDS that have following-sibling ends 
       * for fragmented segs with START IDs. * segs with END IDs * for simple segs where end IDS have a preceding-sibling start ID. 
       * for fragmented end IDs that don't have a preceding-sibling start ID.
      
### Run `P5-Pt2PlantFragSegMarkers.xsl`
* **Input:** `preP5a-output` directory
* **Output:** `preP5b-output` directory
* 2018-10-10 ebb: Bridge Construction Phase 5b: Here we are dealing with "stranded" or fragmented segs that are in between up-raised elements in the edition files. This XSLT plants medial `<seg/>` start or end "marker" tags prior to upraising the seg elements.
* 2018-10-15: We will need to add medial seg elements where there are multiple element nodes in between start-marker and end-marker pairs. We'll do this in the next stylesheet in the series to avoid ambiguous rule matches. 
    * FRAGMENT PART I SEGs w/ (all start markers without following-sibling end markers) 
      * End marker for closing part will always be on the following:: axis. 
      * FRAGMENT PART F (terminal) segs: For all end-markers without preceding-sibling start-markers 
        * Starting-part marker will always be on the preceding:: axis. 
        * We are suppressing duplicates of copied nodes in the above templates 
        * We are suppressing nodes that come after initial start-markers 
        * We are suppressing nodes that come before terminal end-markers

### Run `P5-Pt3MedialSTARTSegMarkers.xsl`
* **Input:** `preP5b-output` directory
* **Output:** `preP5c-output` directory
* 2018-10-16 ebb: This XSLT plants medial seg START markers to surround multiple element nodes in between fragmented seg start-pairs and end-pairs  

### Run `P5-Pt4MedialENDSegMarkers.xsl`
* **Input:** `preP5c-output` directory
* **Output:** `preP5d-output` directory
* 2018-10-15 ebb: This XSLT plants medial seg END markers to surround multiple element nodes in between fragmented seg start-pairs and end-pairs  
    * CHANGE THIS when ready to process full 5d collection

### Run `P5-Pt5raiseSegElems.xsl`
* 2018-07-30 ebb: Run this with Saxon at command line to raise paired seg markers, using:
``
    java -jar saxon.jar -s:preP5d-output/ -xsl:P5-Pt5raiseSegElems.xsl -o:P5-output/ 
``    
    
* We should probably rewrite this so we don't require the lib file dependency on marker types. 
          
### Run `P5_SpineGenerator.xsl`
* Run with saxon command line over the `P1-output` directory and output to  `subchunked_standoff_Spine` directory, using:
``      
java -jar saxon.jar -s:P1-output/ -xsl:P5_SpineGenerator.xsl -o:subchunked_standoff_Spine/ 
``
* Change the output filenames from starting with `P1_` to `spine_`.
* 2018-10-17 updated 2019-03-16 ebb: This XSLT generates the “spine” files for the Variorum. 
* The “spine” contains URI pointers to specific locations marked by `<seg>` elements in the edition files made in bridge-P5, and is based on information from the collation process stored in TEI in the `P1-output` directory. 
* These files differ from those output in the P1 stage because the P1 form contains the complete texts of all edition files, mapping them to critical apparatus markup with variant `<app>` elements (containing multiple `<rdgGrp>` elements or divergent forms) as well as invariant `<app>` elements (containing only one `<rdgGrp>` where all editions run in unison). For the purposes of the Variorum encoding, our “spine” needs only to work with the variant passages, because those are the passages we will highlight and interlink in the Variorum interface. So, in this stage of processing we remove the invariant apps from P1 in generating the Variorum “spines”. 
* Looking ahead, following this stage we will: 
    * Run `spineAdjustor.xsl` to stitch up the multi-part spine sections into larger units and send that output to `preLev_standoff_Spine`. 
    * Calculate Levenshtein edit distances working in the edit-distance directory. Run `edit-distance/extractCollationData.xsl` to prepare the `spineData-ascii.txt` TSV files. Process that with the Python script `LevenCalc_toXML.py` to generate `edit-distance/FV_LevDists.xml`. 
    * When edit distances are calculated and stored, we will run `spine_addLevWeights.xsl` to add Levenshtein values and generate the finished `standoff_Spine` directory files.

### Run `spineAdjustor.xsl`
* **Input:** `subchunked_standoff_Spine` directory
* **Output:** `preLev_standoff_Spine` directory
* 2018-10-23 ebb: In this stage, we "sew up" the lettered spine sub-chunk files into complete chunks to match their counterpart edition files. 2018-10-25: Also, we're adding hashtags if they're missing in the @wit on rdg.

### Run `edit-distance/extractCollationData.xsl`
* **Input:** `preLev_standoff_Spine` directory
* **Output:** `edit-distance/spineData.txt` 
* 2018-10-21 updated 2019-03-16 ebb: This XSLT reads from the spine files as prepped through P5 of the postCollation pipeline, and it outputs a single tab-separated plain text file, named spineData.txt, with normalized data pulled from each rdgGrp (its @n attribute) in the spine files. The output file will need to be converted to ascii for weighted levenshtein calculations. 

### Convert `spineData.txt` to ASCII format 
* This stage is necessary to prepare the variorum data for processing with the numpy library in Python to calculate edit distance values at each variant location. 
* Use iconv in the shell (to change curly quotes and other special characters to ASCII format): For a single file:
``
        iconv -c -f UTF-8 -t ascii//TRANSLIT spineData.txt  > spineData-ascii.txt
``        
* If batch processing a directory of output files to convert to ascii, use something like:
``
        for file in *.txt; do iconv -c -f UTF-8 -t ascii//TRANSLIT "$file" > ../spineDataASCII/"$file"; done
``        
* On using TRANSLIT with iconv, see <https://unix.stackexchange.com/questions/171832/converting-a-utf-8-file-to-ascii-best-effort> 

### Run `edit-distance/LevenCalc_toXML.py`
* **Input:** `spineData-ascii.txt`
* **Output:** `FV_LevDists-weighted.xml`
* This Python script uses the numpy library to calculate Levenshtein edit distances between each available rdgGrp cluster of witnesses at each variant location. It outputs a single XML file in the critical apparatus format of our spines, holding the calculated values. 

### Maybe (or maybe not) run `edit-distance/LevWeight-Simplification.xsl`
* *_CAUTION_* *We may not wish to run this transformation. Please read this documentation before deciding.* 
* **Input:** 
* **Output:** 
* 2018-10-24 updated 2019-03-16 ebb: This identity transformation stylesheet removes comparisons to absent witnesses (indicated as NoRG) in the feature structures file holding weighted Levenshtein data for our collated Variorum.
* ISSUE: *Why we may NOT wish to run this*: Running this stylesheet will affect our readout of collation variance. Consider the case of variant passages where one or more witnesses are not present and have no material to compare. This may be because, in the case of the ms notebooks, we simply do not have any material, or it may be because, in the case of the 1831 edition, a passage was heavily altered and cut, and there isn't any material present. High Levenshtein values are produced in each case. 
* As of 2019-03-16 (ebb), I'm deciding NOT to run this stylesheet so that the team can evaluate the Levenshtein results to represent comparisons with omitted/missing material.

### Run `spine_addLevWeights.xsl`
* **Input:** `preLev_standoff_Spine` directory
* **Output:** `standoff_Spine` directory
* This is the last stage of our pipeline! 
* 2018-10-24 updated 2019-03-16 ebb: This stylesheet maps the maximum Levenshtein distance value for each app onto the spine files. Run this over `FV_LevDists-weighted.xml` (the XML generated by the Python script that calculates Levenshtein distances at each app location and stores them in feature structures.) 
* Note: We may or may not wish to run the `LevWeight-Simplification.xsl` beforehand (which would remove comparisons with "0" at gap or cut locations where one or more witnesses are not present). My current thinking is that we should *not* run this because omissions are an important source of variance.  