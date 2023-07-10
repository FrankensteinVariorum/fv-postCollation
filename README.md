# fv-postCollation
This repository is part of the [Frankenstein Variorum project](https://github.com/PghFrankenstein) It contains a workspace for post-processing finalized collation files to prepare the Variorum edition. For more on the Frankenstein Variorum project underway, see <https://pghfrankenstein.github.io/Pittsburgh_Frankenstein/>.

The workspace in this repo houses a transformation pipeline. Here is a summary of the files to run in order, which an explanation of each process. We plan to bundle these stages into one or two automated processes when the Variorum development is stable. Before we do that, we need to carefully review each stage described below and remove anything dependent on human intervention between pipeline stages. 

## Phase 1: Convert collation data to TEI
### Run `P1-bridgeEditionConstructor.xsl`
* **Input:** `collated-data` directory
* **Output:** `P1-output` directory
* 2018-06-21 ebb: Bridge Edition Constructor Part 1: This first phase up-converts collation data files to TEI and adds `@xml:ids` to each `<app>` element in the output collation. In the event that the collation process broke apart the self-closed elements into two tags, this stylesheet catches these and restores them to single tags.

## Phase 2: Generate distinct edition files
### Run `P2-bridgeEditionConstructor.xsl`
* **Input:** `P1-output` directory
* **Output:** `P2-output` directory
* 2018-06-21 ebb updated 2018-08-01: Bridge Edition Constructor Part 2: This second phase begins building the output Bridge editions by consuming the `<app>` and `<rdg>` elements to replace them with `<seg>` elements that hold the identifiers of their apps and indication of whether they are portions.
* This stylesheet does NOT YET generate the spine file. We're deferring that to a later stage when we know where the `<seg>` elements appear in relation to the hierarchy of the edition elements. 
* We will generate the spine file following the edition files constructed in bridge P5, so that we have the benefit of seeing the `<seg>` elements and where pointers to the editions will need to be multiplied (e.g. converted to a start pointer and an end pointer around a paragraph break). We can then generate pointers to more precise locations. 

## Phase 3: 
* ### Begin reconstructing elements from text-converted tags 
* ### Reassemble subdivided collation units  
### Run `P3-bridgeEditionConstructor.xsl`
* **Input:** `P2-output` directory
* **Output:** `P3-output` directory
* In Bridge Construction Phase 3, we are up-transforming the text-converted tags in the edition files into self-closed elements. We add the `th:` namespace prefix to "trojan horse" attributes used for markers.


### ~~Run `P3.5-bridgeEditionConstructor.xsl`~~
#### THIS STAGE SHOULD BE UNNECESSARY IN 2023 
* ~~**Input:** `P3-output` directory~~
* ~~**Output:** `P3.5-output` directory~~ 
* ~~2018-10-10 ebb: For stage 3.5 we need to reconstruct full collation chunks that have been subdivided into parts. For example, C08 was divided into parts C08a through C08j, often breaking up element tag pairs. Here we reunite the pieces so we can move on to up-raising the flattened elements in the editions.~~

## Phase 4: Raise the “trojan elements” holding edition markup 
### Option 1: Run `P4-raiseBridgeElems.xsl`
* **Input:** `P3.5-output` directory 
* **Output:** `P4-output` directory 
* 2018-07-07 ebb: This stylesheet works to raise "trojan elements" from the inside out, this time over a collection of Frankenstein files output from collation. It also adapts djb's function to process an element node rather than a document node in memory to perform its recursive processing. 

### Option 2: Run `P4Sax-raiseBridgeElems.xsl`
* This is an alternative version of the P4 transformation designed to run in the shell rather than in oXygen. We may wish to use this when working with the full scope of edition files representing the novel from start to end, where oXygen processing may be bogged down.   
*  2018-10-11 ebb: This version of the P4 stylesheet is designed to run at command line (so references to specific file collections are commented out). Run this in the terminal or command line by navigating to the directory holding this XSLT (and the saxon files necessary) and entering
``
       java -jar saxon.jar -s:P3.5-output -xsl:P4Sax-raiseBridgeElems.xsl -o:P4-output
``  
* After running this, be sure to rename the output files to begin with `P4_`
* 2018-07-15 ebb: Bridge Phase 4 raises the hierarchy of elements from the source documents, leaving the seg elements unraised. This stylesheet uses an "inside-out" function to raise the elements from the deepest levels (those with only text nodes between their start and end markers) first. This and other methods to "raise" flattened or "Trojan" elements are documented in https://github.com/djbpitt/raising with thanks to David J. Birnbaum and Michael Sperberg-McQueen for their helpful experiments. 
* 2023-05-21 ebb: UPDATE SAXON AND RECONSIDER FILE NOMENCLATURE

## Phase 5: Prepare and raise `<seg>` elements for variant passages in each edition
### Run `P5-Pt1-SegTrojans.xsl`
* **Input:** `P4-output` directory 
* **Output:** `preP5a-output` directory
* 2018-07-29: Bridge Construction Phase 5: What we need to do:     
    * where the end markers of seg elements are marked we reconstruct them in pieces. 
    * raise the `<seg>` marker elements marking hotspots
    * deliver seg identifying locations to the Spine file.
* In this first stage of Part 5, we are converting the seg elements into Trojan markers using the `th:` namespace, and explicitly designating those that are fragments (that will break hierarchy if raised) as parts by adding a `@part` attribute. 
    * In the next stage, we will need to add additional seg elements to handle fragmented hotspots that break across the edition element hierarchy.
    * In the last stage of this process, we adapt CMSpMq's left-to-right sibling traversal for raising flattened elements.  
    * segs with START IDs 
       * for simple segs with START IDS that have following-sibling ends 
       * for fragmented segs with START IDs. 
       * for segs with END IDs 
     * **2023-05-21 ebb: Are the next two processing stages necessary?** 
       * for simple segs where end IDS have a preceding-sibling start ID. 
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

### Run `P5-Pt5raiseSegElems.xsl`
* 2018-07-30 ebb: Run this with Saxon at command line to raise paired seg markers, using:
  ``
    java -jar saxon.jar -s:preP5d-output/ -xsl:P5-Pt5raiseSegElems.xsl -o:P5-output 
  ``    
  
* We should probably rewrite this so we don't require the lib file dependency on marker types. 
* 2023-05-31: Fixing xsl file add capacity to process a collection with xsl:result-document. Adding this stage to latest edition to add spaces around consecutive space markers in the output editions.  
	
## Phase 6

### Run `P6-Pt1-combine.xsl` 
* Combines all XSLT edition files for each edition into a single XML file. This results in 5 edition files for each version.

* **Input** `P5-output/?select=*.xml`
* **Output:** `P6-Pt1/`
* **Current output is not in correct order, only for Manuscript.**

### Run `P6-Pt2-simplify-chapAnchors.xsl`
* 2023-6-14: Cleans up elements removing unnecessary spaces and punctuation. Flattens all of collation nodes into radically simplified structures to make it possible to 'cut' the files.
* Introduces anchor elements to indicate when each chapter starts (line 157).
* **Output:** `P6-Pt2/VERSION_$file_id.xml`

### Run `P6-Pt3-chapChunking.xsl`
* 2023-6-14: Cleans up namespaces.
* This XSLT should output seperate chapter files. It is not doing that yet. We have only tried it for the fMS so far, and it is outputting nly one file, named with the correct text node, but otherwise systematically excluding the contents of the first processed group.

### Run `P6_SpineGenerator.xsl`
* Run with saxon command line over the `P1-output` directory and output to  `subchunked_standoff_Spine` directory, using:
``      
java -jar saxon.jar -s:P1-output/ -xsl:P6_SpineGenerator.xsl -o:subchunked_standoff_Spine 
``
* Begun 2018-10-17 updated 2019-03-16, 2023-05-21, 2023-07-03 
* This XSLT generates the “spine” files for the Variorum. It used to be run at the end of Phase 5 when we were working with edition files saved as collation units, but we are now (as of 2023-07-03) running it at the end of P6 to read from our edition chapter files. 
* The “spine” contains URI pointers to specific locations marked by `<seg>` elements in the edition files made in bridge-P5, and is based on information from the collation process stored in TEI in the `P1-output` directory. 
* Here we change the output filenames from starting with `P1_` to `spine_`.
* These files differ from those output in the P1 stage because the P1 form contains the complete texts of all edition files, mapping them to critical apparatus markup with variant `<app>` elements (containing multiple `<rdgGrp>` elements or divergent forms) as well as invariant `<app>` elements (containing only one `<rdgGrp>` where all editions run in unison). For the purposes of the Variorum encoding, our “spine” needs only to work with the variant passages, because those are the passages we will highlight and interlink in the Variorum interface. So, in this stage of processing we remove the invariant apps from P1 in generating the Variorum “spines”. 
* Looking ahead, following this stage we will: 
  
    * Calculate Levenshtein edit distances working in the edit-distance directory.
    * When edit distances are calculated and stored, we will add Levenshtein values and generate the finished `standoff_Spine` directory files.


## Phase 7: Prepare the “spine” of the variorum
### Run `spineAdjustor.xsl` 
* **Input:** `subchunked_standoff_Spine` directory
* **Output:** `preLev_standoff_Spine` directory
* 2018-10-23 ebb: In this stage, we "sew up" the lettered spine sub-chunk files into complete chunks to match their counterpart edition files. 2018-10-25: Also, we're adding hashtags if they're missing in the @wit on rdg.
* 2023-05-21: THE FIRST PART ISN"T NECESSRY BUT **DO NEED TO CHECK/ADD MISSING HASTHAGS**

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

### Inside the edit-distance directory, run at shell `python LevenCalc_toXML.py`
* **Input:** `spineData-ascii.txt`
* **Output:** `FV_LevDists-weighted.xml`
* This Python script uses the numpy library to calculate Levenshtein edit distances between each available rdgGrp cluster of witnesses at each variant location. It outputs a single XML file in the critical apparatus format of our spines, holding the calculated values. 
* 2023-05-21 ebb: UPDATE THE NUMPY LIBRARY

### ~~Maybe (or maybe not)~~ Definitely run `edit-distance/LevWeight-Simplification.xsl`
* ~~*_CAUTION_* *We may not wish to run this transformation. Please read this documentation before deciding.*~~ 
* **Input:** `FV_LevDists-weighted.xml`
* **Output:** `FV_LevDists-simplified.xml`
* 2018-10-24 updated 2019-03-16 ebb: This identity transformation stylesheet removes comparisons to absent witnesses (indicated as NoRG) in the feature structures file holding weighted Levenshtein data for our collated Variorum.
* ISSUE: *Why we may NOT wish to run this*: Running this stylesheet will affect our readout of collation variance. Consider the case of variant passages where one or more witnesses are not present and have no material to compare. This may be because, in the case of the ms notebooks, we simply do not have any material, or it may be because, in the case of the 1831 edition, a passage was heavily altered and cut, and there isn't any material present. High Levenshtein values are produced in each case. 
* ~~As of 2019-03-16 (ebb), I'm deciding NOT to run this stylesheet so that the team can evaluate the Levenshtein results to represent comparisons with omitted/missing material.~~
* REVISED (ebb): Revisiting on 3 July 2019 and May 2023: I think we DO want to run this because we're getting spurious high results for passages of really low variance.
* Confirmed (ebb and yxj 26 June 2023: Yes, we do want to run this because it yields accurate maximum Levenshtein distance calculations for text-bearing passages demonstrating variation. A question may be how to handle passsages 

### Run `spine_addLevWeights.xsl`
* **Input:** `preLev_standoff_Spine` directory
* **Output:** `standoff_Spine` directory
* This stage prepares the standoff “spine” files containing pointers to edition files and edit-distance data on which the Variorum reading interface depends. 
* 2018-10-24 updated 2019-03-16 ebb: This stylesheet maps the maximum Levenshtein distance value for each app onto the spine files. Run this over `FV_LevDists-weighted.xml` (the XML generated by the Python script that calculates Levenshtein distances at each app location and stores them in feature structures.) 

## ~~Run spineEmptyWitnessPatch.xsl~~ 
2023-07-10 This was intended to solve an OLD problem from the Time Before (2019). We don't need it now!
* ~~**Input:** `standoff_Spine` directory~~
* ~~**Output:** `fv-data/standoff_Spine` directory~~
* ~~This XSLT finds `<app>` elements with only two variations that amount to only a single 4-character token, which can only ever be `n=['']`. The XSLT ensures that these are output with a Levenshtein distance of 0. WAIT, this may NOT be what we want now!~~

<del>```xml
<app>
   <rdgGrp n="['']">
      <rdg wit="f1831"/>
   </rdgGrp>
   <rdgGrp>
      <rdg wit="fThomas">I have all kinds of content that is just plain missing in 1831</rdg>
   </rdgGrp>

</app>
```
</del>

~~Consider that we are also now outputting null tokens like this:~~
<del>
```
<app>
   <rdgGrp n="∅">
      <rdg wit="f1831"/>
   </rdgGrp>
   <rdgGrp>
      <rdg wit="fThomas">I have all kinds of content that is just plain missing in 1831</rdg>
   </rdgGrp>

</app>
```
</del>

~~This XSLT won't process the null-token because it's too short. BUT, do we really want this behavior this kind of witness?~~
<del>`n="['']"`</del>



## ~~Trimming White Space:~~ 
### ~~2023-05-21: Unnecessary now?~~
### ~~Run `java -jar saxon.jar -s:P5-output/ -xsl:whiteSpaceReducer.xsl -o:P5-trimmedWS~~
## ~~Packaging collated edition files~~
### ~~Run `./migrateP5msColl.sh`~~
~~* **Input:** `P5-output`~~

* ~~**Outputs:** separate `P5-MS` and `P5-print` directories, copied to `fv-data/variorum-chunks` and `fv-data/reseqMS-chunks`~~
~~This stage removes MS edition files to a separate directory, since these will not be used in the Variorum interface development, but may be useful for further processing and analysis of collation data.~~
~~For the white-space-trimmed files:~~
### ~~Run `./migrateP5msColl-tws.sh`~~
* ~~**Input:** `P5-trimmedWS`~~
* ~~**Outputs:** separate `P5-MS-tws` and `P5-print-tws` directories, copied to `fv-data/variorum-chunks-tws` and `fv-data/reseqMS-chunks-tws`~~

