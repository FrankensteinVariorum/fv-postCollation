## P1-bridgeEditionConstructor.xsl
* 2018-06-21 ebb: Bridge Edition Constructor Part 1: This first phase up-converts to TEI and adds xml:ids to each <app> element in the output collation. In the event that the collation process broke apart the self-closed elements into two tags, this stylesheet catches these and restores them to single tags.  ## P2-bridgeEditionConstructor.xsl
* 2018-10-10 ebb: Updated and simplified to process current files that DO have meaningful rdgGrp elements. * 2018-06-21 ebb updated 2018-08-01: Bridge Edition Constructor Part 2: This second phase begins building the output Bridge editions by consuming the <app> and and <rdg> elements to replace them with <seg> elements that hold the identifiers of their apps and indication of whether they are portions.
   This stylesheet does NOT YET generate the spine file. We're deferring that to a later stage when we know where the <seg> elements turn up in relation to the hierarchy of the edition elements. 
   We are now generating the spine file following the edition files constructed in bridge P5, so that we have the benefit of seeing the <seg> elements where they need to be multiplied (e.g. around paragraph breaks). We can then generate pointers to more precise locations.   
    *  DEFER TO LATER STAGE AFTER P5: <xsl:result-document method="xml" indent="yes" href="standoff_Spine/spine_{$chunk}.xml">
               <TEI xml:id="spine-{$chunk}">
                   <teiHeader>
                       <fileDesc>
                           <titleStmt>
                               <title>Standoff Spine: Collation unit <xsl:value-of select="$chunk"/></title>
                           </titleStmt>
                           <xsl:copy-of select="descendant::publicationStmt"/>
                           <xsl:copy-of select="descendant::sourceDesc"/>
                       </fileDesc>
                   </teiHeader>
                   <text>
                       <body> 
                           <ab type="alignmentChunk" xml:id="spine_{$chunk}">
                               <xsl:apply-templates  select="descendant::app" mode="spinePtrs">
                                   <xsl:with-param name="chunk" select="$chunk" tunnel="yes"></xsl:with-param>
                               </xsl:apply-templates>
                               
                           </ab>
                       </body>
                       
                   </text>
               </TEI> 
           </xsl:result-document>## P3-bridgeEditionConstructor.xsl
* In Bridge Construction Phase 3, we are up-converting the text-converted tags in the edition files into self-closed elements. We add the th: namespace prefix to "trojan horse" attributes used for markers.* 2018-06-22: ebb: We can't use <ab> for top-level structures once we start regenerating <p> elements, since <ab> isn't allowed to contain <p>. * a start tag of an unflattened element (left as a whole element prior to collation).* an end tag of an unflattened element* matches strings representing flattened element tags marked with sID and eID attributes. * matches text strings representing self-closed elements (the milestone elements and such like). ## P3.5-bridgeEditionConstructor.xsl
* 2018-10-10 ebb: For stage 3.5 we need to reconstruct full collation chunks that have been subdivided into parts. For example, C08 was divided into parts C08a through C08j, often breaking up element tag pairs. Here we reunite the pieces so we can move on to up-raising the flattened elements in the editions. ## P4-raiseBridgeElems.xsl
* 2018-07-07 ebb: This stylesheet works to raise "trojan
	elements" from the inside out, this time over a collection
	of Frankenstein files output from collation. It also adapts
	djb's function to process an element node rather than a
	document node in memory to perform its recursive
	processing. * 2018-07-23 ebb: I've updated this stylesheet to work with the th:raise function as expressed in raise_deep.xsl. * * Experimental:  try adding a key ** 2018-07-23 ebb: This isn't working, and I'm not sure why not. This stylesheet has the recursion function run over a container element, rather than an  entire document node, and I think that must be the problem. Commenting it out for now.   <xsl:key name="start-markers" match="$C10-coll//*[@th:sID]" use="@th:sID"/>
    <xsl:key name="end-markers" match="$C10-coll//*[@th:eID]" use="@th:eID"/>* * In all modes, do a shallow copy, suppress namespace nodes,
	* and recur in default (unnamed) mode. ** * th:raise(.):  raise all innermost elements within the container element this time passed as parameter ** * We have no more work to do, return the input unchanged. ** * On the input container element node, call th:raise() ** * Loop mode (applies to container element only). ** * Loop mode for container element:  just apply templates in default unnamed mode. ** suppressing nodes that are being reconstructed, including the old end marker. ## P4Sax-raiseBridgeElems.xsl
*  2018-10-11 ebb: UPDATED for new fv-postCollation repo: This version of the stylesheet is designed to run at command line (so references to specific file collections are commented out). Run this in the terminal or command line by navigating to the directory holding this XSLT (and the saxon files necessary) and entering
       java -jar saxon.jar -s:P3.5-output -xsl:P4Sax-raiseBridgeElems.xsl -o:P4-output
       
       <xsl:variable name="bridge-P3b" as="document-node()+" select="collection('bridge-P3b/')"/>* 2018-07-15 ebb: Bridge Phase 4 raises the hierarchy of elements from the source documents, leaving the seg elements unraised. This stylesheet uses an "inside-out" function to raise the elements from the deepest levels (those with only text nodes between their start and end markers) first. This and other methods to "raise" flattened or "Trojan" elements are documented in https://github.com/djbpitt/raising with thanks to David J. Birnbaum and Michael Sperberg-McQueen for their helpful experiments. *  <xsl:for-each select="$bridge-P3b//TEI">
           <xsl:variable name="currentFile" as="element()" select="current()"/>
                <xsl:variable name="filename">
                    <xsl:text>P4-</xsl:text><xsl:value-of select="tokenize(base-uri(), '/')[last()] ! substring-after(., '-')"/>
                </xsl:variable>
                <xsl:variable name="chunk" as="xs:string" select="tokenize(base-uri(), '/')[last()] ! substring-before(., '.') ! substring-after(., '_')"/>          
                -           <xsl:result-document method="xml" indent="yes" href="bridge-P4/{$filename}">*  </xsl:result-document>* </xsl:for-each>* suppressing nodes that are being reconstructed. ## P5-Pt1-SegTrojans.xsl
* 2018-07-29: Bridge Construction Phase 5: What we need to do:      
       *  where the end markers of seg elements are marked we reconstruct them in pieces. 
        * raise the <seg> marker elements marking hotspots
       *  deliver seg identifying locations to the Spinal Column file.
    In this first stage of Part 5, we are converting the seg elements into Trojan markers using the th:namespace, and explicitly designating those that are fragments (that will break hierarchy if raised) as parts by adding a part attribute. 
    In the next stage, we will need to add additional seg elements to handle fragmented hotspots that break across the edition element hierarchy.
    In the last stage of this process, we adapt CMSpMq's left-to-right sibling traversal for raising flattened elements.  
    * segs with START IDs * for simple segs with START IDS that have following-sibling ends * for fragmented segs with START IDs. * segs with END IDs * for simple segs where end IDS have a preceding-sibling start ID. * for fragmented end IDs that don't have a preceding-sibling start ID. ## P5-Pt2PlantFragSegMarkers.xsl
* 2018-10-10 ebb: Bridge Construction Phase 5b: Here we are dealing with "stranded" or fragmented segs that are in between up-raised elements in the edition files. This XSLT plants medial <seg/> start or end "marker" tags prior to upraising the seg elements.
  2018-10-15: We will need to add medial seg elements where there are multiple element nodes in between start-marker and end-marker pairs. We'll do this in the next stylesheet in the series to avoid ambiguous rule matches. 
    * FRAGMENT PART I SEGs w/ (all start markers without following-sibling end markers) * End marker for closing part will always be on the following:: axis. * FRAGMENT PART F (terminal) segs: All end-markers without preceding-sibling start-markers * Starting-part marker will always be on the preceding:: axis. * Suppressing duplicates of copied nodes in the above templates * Suppresses nodes that come after initial start-markers * Suppresses nodes that come before terminal end-markers ## P5-Pt3MedialSTARTSegMarkers.xsl
* 2018-10-16 ebb: This XSLT plants medial seg START markers to surround multiple element nodes in between fragmented seg start-pairs and end-pairs  
    * CHANGE THIS when ready to process full collection ## P5-Pt4MedialENDSegMarkers.xsl
* 2018-10-15 ebb: This XSLT plants medial seg END markers to surround multiple element nodes in between fragmented seg start-pairs and end-pairs  
    * CHANGE THIS when ready to process full 5d collection ## P5-Pt5raiseSegElems.xsl
* 2018-07-30 ebb: Run this with Saxon at command line to raise paired seg markers, using:
    java -jar saxon.jar -s:preP5d-output/ -xsl:P5-Pt5raiseSegElems.xsl -o:P5-output/ 
    
    We should probably rewrite this so we don't require the lib file dependency on marker types. 
  * * right-sibling/raise.xsl:  translate a document with start-
      * and end-markers into conventional XML
      ** * Revision history:
      * 2018-07-20 : CMSMcQ : add instrument parameter
      * 2018-07-16 : CMSMcQ : accept anaplus value for th-style,
      *    recover better from duplicate IDs      
      * 2018-07-11 : CMSMcQ : copy-namespaces=no, correct end-marker test 
      * 2018-07-10 : CMSMcQ : make this file by stripping down 
      *     uyghur.ittc.ku.edu/lib/shallow-to-deep.xsl.
      *     Use library functions for marker recognition.
      ** *
    * 
    * Input:  XML document.
    * 
    * Parameters:  
    *
    *   debug:  'yes' or 'no'
    * 
    *   th-style: keyword 'th', 'ana', or 'xmlid':
    *         'th' uses @th:sID and @th:eID 
    *         'ana' uses @ana=start and @ana=end
    *         'xmlid' uses @xml:id with values ending _start, _end
    *
    * 
    * Output:  XML document with virtual elements raised (made
    * into content elements).
    ** ****************************************************************
      * 0 Setup (parameters, global variables, ...)
      ***************************************************************** * What kind of Trojan-Horse elements are we merging? ** * Expected values are 'th' for @th:sID and @th:eID,
      * 'ana' for @ana=start|end
      * 'xmlid' for @xml:id matching (_start|_end)$
      ** * debug:  issue debugging messages?  yes or no  ** * instrument:  issue instrumentation messages? yes or no ** * Instrumentation messages include things like monitoring
      * size of various node sets; we turn off for timing, on for
      * diagnostics and sometimes for debugging. ** ****************************************************************
      * 1 Identity transform (default behavior outside the
      * container)
      ***************************************************************** * special rule for root ** * ah.  The standard error.
	 <xsl:apply-templates select="node()" mode="raising"/>
	 ** ****************************************************************
      * 2 Shifting to shallow-to-deep mode / Container element
      ** * When we hit the container element, shift to shallow-to-deep
      * mode.  We know it's the container element, because it has
      * at least one marker element as a child.
      ** ****************************************************************
      * 3 Start-marker:  make an element and carry on
      ** * 1: handle this element ** * 2: continue after this element ** ****************************************************************
      * 4 End-markers
      ** * no action necessary ** * we do NOT recur to our right.  We leave it to our parent to do 
	that. ** ****************************************************************
      * 5 Other elements, in shallow-to-deep mode 
      ** * If these contain Trojan Horse descendants, they need to
      * be processed recursively; otherwise just copy
      * Oddly this is almost identical to what deep-to-shallow does
      ** * and recur to right sibling ** ****************************************************************
      * 6 Other node types, in shallow-to-deep mode 
      ** ****************************************************************
      * 7 Functions
      *## P5_SpineGenerator.xsl
* 2018-10-17 updated 2019-03-16 ebb: This XSLT generates the “spine” files for the Variorum. These files differ from the P1 stage of processing because the P1 form contains the complete texts of all edition files, mapping them to critical apparatus markup with variant apps (containing multiple rdgGrps or divergent forms) as well as invariant apps (containing only one rdgGrp where all editions run in unison). For the purposes of the Variorum encoding, our “spine” needs only to work with the variant passages, because those are the passages we will highlight and interlink in the Variorum interface. So, in this stage of processing we remove the invariant apps from P1 in generating the Variorum “spines”.  
        Note: we are processing rdgGrps in this XSLT. (In earlier stages of the project we had to generate rdgGrps at a later stage, but our current collation data file structure gives us rdgGrps to start with, so we preserve these in our output.)
        Run with saxon command line over P1-output directory and output to  preLev_standoff_Spine directory, using:
        
        java -jar saxon.jar -s:P1-output/ -xsl:P5_SpineGenerator.xsl -o:subchunked_standoff_Spine/ 
Change the output filenames from starting with P1_ to spine_.

        Following this, we: 
    * Run spineAdjustor.xsl to stitch up the multi-part spine sections into larger units and send that output to preLev_standoff_Spine. 
    * Calculate Levenshtein edit distances working in the edit-distance directory. Run extractCollationData.xsl and work with spineData.txt TSV files with Python, to generate FV_LevDists.xml. 
    * When edit distances are calculated and stored, run spine_addLevWeights.xsl to add Levenshtein values and generate the finished standoff_Spine directory files.
    * 2018-07-30 updated 2018-08-01 ebb: This file is now designed to generate the first incarnation of the standoff spine of the Frankenstein Variorum. The spine contains URI pointers to specific locations marked by <seg> elements in the edition files made in bridge-P5, and is based on information from the collation process stored in TEI in bridge P1. * 2018-07-30 rv: Fixed URLs to TEI files * 2018-07-30 rv: Changing rdgGrps back into apps. This eventually should be addressed in previous steps. * 2019-03-16: ebb: Reviewing documentation and outputs, we are outputting apps with rdgGrps inside, each getting an xml:id.  * 2018-10-23 rv: merging with code for generating pointers to SGA *  This function is here only for testing purposes. Please keep *  If there's no match, it means the second substring is empty (end of line) *  "2" accounts for needed extra space and index number *  Un-comment these for testing pointer resolution * <pitt:line_text>
                <xsl:value-of select="concat('(', $pre_text, ') ', $cur_text)"/>
            </pitt:line_text>
            <pitt:resolved_text>
                <xsl:value-of select="pitt:resolvePointer($full_pointer)"/>
            </pitt:resolved_text>*  When a reading contains one or more LB elements, split the content around LB and determine the pointer based on the LB value *  EDGE CASE: the first token belongs to a previous line, in which case the previous line will need to be located *  Each token after an LB will start with '=', so check whether it's missing *  Only process it if there's content after the lb *  Un-comment these for testing pointer resolution * <pitt:line_text>
                                                        <xsl:value-of select="$text"/>                                        
                                                    </pitt:line_text>
                                                    <pitt:resolved_text>
                                                        <xsl:value-of select="pitt:resolvePointer($full_pointer)"/>
                                                    </pitt:resolved_text>*  Skip space-only or empty string nodes * Suppresses invariant apps from the spine. ## edit-distance/LevWeight-Simplification.xsl
* 2018-10-24 updated 2019-03-16 ebb: We may or may not wish to run this XSLT. This identity transformation stylesheet removes comparisons to absent witnesses (indicated as NoRG) in the feature structures file holding weighted Levenshtein data for our collated Variorum.
    ISSUE: (Why we may NOT wish to run this): Running this stylesheet will affect our readout of collation variance. Consider the case of variant passages where one or more witnesses are not present and have no material to compare. This may be because, in the case of the ms notebooks, we simply do not have any material, or it may be because, in the case of the 1831 edition, a passage was heavily altered and cut, and there isn't any material present. High Levenshtein values are produced in each case. 
    As of 2019-03-16 (ebb), I'm deciding NOT to run this stylesheet so that the team can evaluate the Levenshtein results to represent comparisons with omitted/missing material. 
    ## edit-distance/extractCollationData.xsl
* 2018-10-21 updated 2019-03-16 ebb: This XSLT reads from the spine files as prepped through P5 of the postCollation pipeline, and it outputs a single tab-separated plain text file, named spineData.txt, with normalized data pulled from each rdgGrp (its @n attribute) in the spine files. The output file will need to be converted to ascii for weighted levenshtein calculations. 
        Use iconv in the shell (to change curly quotes and other special characters to ASCII format): For a single file:
        iconv -c -f UTF-8 -t ascii//TRANSLIT spineData.txt  > spineData-ascii.txt
        
        If batch processing a directory of output files to convert to ascii, use something like:
        for file in *.txt; do iconv -c -f UTF-8 -t ascii//TRANSLIT "$file" > ../spineDataASCII/"$file"; done
    (On using TRANSLIT with iconv, see https://unix.stackexchange.com/questions/171832/converting-a-utf-8-file-to-ascii-best-effort) 
        *  <xsl:variable name="currentSpineFile" as="element()" select="current()"/>
           <xsl:variable name="filename" as="xs:string" select="$currentSpineFile/base-uri() ! tokenize(., '/')[last()] ! substring-before(., '.')"/>
           <xsl:result-document method="text" href="spineData/{$filename}.txt">* </xsl:result-document>* This is to output blanks (or NoRG) so we always have 5 tab-separated values for the python script to compare for each possible rdgGrp. Blanks are encoded as a single white-space. * output rdgGrp identifiers and normalized tokens. If the MS notebook witness is present, flag it with #fMS appended to the rdgGrp xml:id. * An empty rdgGrp is interpreted as a single white space.  ## raise_frankensteinAll.xsl
* 2018-07-23 ebb: Adapted from the raising repo. Run at command line here specifying Bridge-P3 input and Bridge-P4 output directories with
        
    
    * * Setup ** * Experimental:  try adding a key **     <xsl:variable name="novel"
        as="document-node()+"
        select="collection('../input/frankenstein/novel-coll/')"/>  * * In all modes, do a shallow copy, suppress namespace nodes,
	* and recur in default (unnamed) mode. ** * th:raise(.):  raise all innermost elements within the document
	passed as parameter ** * If we have more work to do, do it ** * We have no more work to do, return the input unchanged. ** * On the input document node, call th:raise() ** * Loop mode (applies to document node only). ** * Loop mode for document node:  just apply templates in
	default unnamed mode. ** * Innermost start-marker **  content of raised element; no foreign end-markers
		 here (but possibly start-markers); just copy the
		 nodes * * v.Prev had:
            <xsl:copy-of
                select="following-sibling::node()[following-sibling::*[@th:eID eq current()/@th:sID]]"
		/>
		but this requires the processor to scan all following
		siblings, not just those up to the end-marker, because
		the processor cannot know that the th:eID value won't
		repeat.
		
		It might do better with
		select="following-sibling::node()[not(preceding-sibling::*[@th:eID eq current()/@th:sID])]"
		but it's simpler to be more obvious:
		**  nodes inside new wrapper:  do nothing *  end-tag for new wrapper ## spineAdjustor.xsl
* 2018-10-23 ebb: In this next-to-last stage, we "sew up" the lettered spine sub-chunk files into complete chunks to match their counterpart edition files. 2018-10-25: Also, we're adding hashtags if they're missing in the @wit on rdg. ## spine_addLevWeights.xsl
* 2018-10-24 updated 2019-03-16 ebb: This stylesheet maps the maximum Levenshtein distance value for each app onto the spine files. Run this over FV_LevDists-weighted.xml (the XML generated by the Python script that calculates Levenshtein distances at each app location and stores them in feature structures.) 
        Note: We may or may not wish to run the LevWeight-Simplification.xsl beforehand (which would remove comparisons with "0" at gap or cut locations where one or more witnesses are not present). My current thinking is that we should *not* run this because omissions are an important source of variance.  