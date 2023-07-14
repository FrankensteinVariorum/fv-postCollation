<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:fv="https://github.com/FrankensteinVariorum"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0"
    exclude-result-prefixes="xs th fv mith cx tei" version="3.0">

    <!--2018-10-17 updated 2019-03-16, 2023-07-04 ebb: This XSLT generates the “spine” files for the Variorum. 
        These files differ from the P1 stage of processing because the P1 form contains the complete texts of all edition files, mapping them to critical apparatus markup with variant apps (containing multiple rdgGrps or divergent forms) as well as invariant apps (containing only one rdgGrp where all editions run in unison). For the purposes of the Variorum encoding, our “spine” needs only to work with the variant passages, because those are the passages we will highlight and interlink in the Variorum interface. So, in this stage of processing we remove the invariant apps from P1 in generating the Variorum “spines”. We are processing rdgGrps in this XSLT.
        
        It runs over the P1-output directory (pulls info from P6Pt3-output) and outputs to subchunked_standoff_Spine directory.

        Following this, we will: 
    * Run spineAdjustor.xsl to stitch up the multi-part spine sections into larger units and send that output to preLev_standoff_Spine. 
    * Calculate Levenshtein edit distances working in the edit-distance directory. Run extractCollationData.xsl and work with spineData.txt TSV files with Python, to generate FV_LevDists.xml. 
    * When edit distances are calculated and stored, run spine_addLevWeights.xsl to add Levenshtein values and generate the finished standoff_Spine directory files.
    -->
    <!--2018-07-30 updated 2023-07-03 ebb: This file is now designed to generate the first incarnation of the standoff spine of the Frankenstein Variorum. The spine contains URI pointers to specific locations marked by <seg> elements in the edition files made in bridge-P6, and is based on information from the collation process stored in TEI in bridge P1. -->
    <!--2018-07-30 rv: Fixed URLs to TEI files -->
    <!--2018-07-30 rv: Changing rdgGrps back into apps. This eventually should be addressed in previous steps. -->
    <!--2019-03-16: ebb: Reviewing documentation and outputs, we are outputting apps with rdgGrps inside, each getting an xml:id.  -->
    <!--2018-10-23 rv: merging with code for generating pointers to SGA -->
    <!-- 2019-06-14 ebb: updating URLs for print editions to renamed variorum-chunks directory. -->
    <!-- 2019-06-19 ebb: updating URLs for SGA to newly included variorum-chunks sga files.
        Keeping the original data on file paths back to S-GA for future use. 
        IF WE RETURN TO POINT TO S-GA FILES, change the following lines as indicated in the stylesheet below:
      Comment out line 35 (defining sga_loc to PghFrankenstein), and lines 86, 132, and 144.
      Uncomment lines 36 and 49 to reinstate S-GA's complex file paths. 
        An alternative thought: Perhaps these file copies could echo each other 
        so the fv-data repo can be a fallback in case something goes wrong w/ S-GA repo, and vice versa.--> 
    
    <!--2023-07-03 ebb: Made the following significant changes:
        * Changed the input of this XSLT to P6-Pt3, which contains the edition files in chapters. 
        * Updated namespaces to drop pitt: in favor of fv:  
        * Ensured output of exactly 5 witnesses for every app, by preparing a <rdgGrp n="∅"> to contain missing witnesses. 
        * Set up explicit file input and output on this stylesheet with xsl:result-document for ease of debugging and consistency with the FV postCollation pipeline. 
        * Created a P6-SpineGenerator-SGALinks.xsl version of this stylesheet to output links to SGA. (These may not work yet.) 
    -->
    
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="P1-spines" as="document-node()+"
        select="collection('P1-output/?select=*.xml')"/>
  <!-- 2023-07-04 ebb: This param location would point into the fv-data repo, if we wanted to point to pre-collated or post-collated edition files for the MS there. For string-pointing purposes, it should probably go to pre-collated full (not flattened) files because the pointers apply XPath expressions involving //surface/zone .
      <xsl:param name="sga_loc"
        select="'https://raw.githubusercontent.com/FrankensteinVariorum/fv-data/master/WHERE?/'"/>-->
    <!-- ebb: Point to original SGA file location: -->
    <xsl:param name="sga_loc" select="'https://raw.githubusercontent.com/umd-mith/sga/6b935237972957b28b843f8d6d9f939b9a95dcb5/data/tei/ox/'"/>
    <xsl:variable name="P6_coll" as="document-node()+" select="collection('P6-Pt3-output/?select=*.xml')"/>
    <!-- 2023-07-03 ebb: This now pulls from the latest stage of the pipeline output: P6-PT3 chapter files. -->

    <xsl:function name="fv:getLbPointer" as="item()*">
        <xsl:param name="str"/>
        <xsl:analyze-string select="$str" regex="^=&quot;([^&quot;]+?)&quot;\s*?/&gt;">
            <xsl:matching-substring>
                <xsl:variable name="ms-rest" select="tokenize(regex-group(1), '-')"/>
                <xsl:variable name="ms" select="$ms-rest[1]"/>
                <xsl:variable name="parts"
                    select="tokenize(replace($ms-rest[2], '__Pt\d+', ''), '__')"/>
                <xsl:variable name="surface" select="$parts[1]"/>
                <xsl:variable name="zone" select="$parts[2]"/>
                <xsl:variable name="line" select="$parts[3]"/>
                <!--ebb: This line is for pointing to original SGA file location: -->
         <xsl:value-of select="concat($sga_loc, 'ox-ms_abinger_', $ms, '/ox-ms_abinger_', $ms, '-', $surface, '.xml', '#')"/>
                <xsl:text>string-range(//tei:surface[@xml:id='ox-ms_abinger_</xsl:text>
                <xsl:value-of select="concat($ms, '-', $surface)"/>
                <xsl:text>']/tei:zone[@type='</xsl:text>
                <xsl:value-of select="$zone"/>
                <xsl:text>']//tei:line[</xsl:text>
                <xsl:value-of select="$line"/>
                <xsl:text>]</xsl:text>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>

    <xsl:function name="fv:resolvePointer">
        <!-- This function is here only for testing purposes. Please keep -->
        <xsl:param name="pointer"/>
        <xsl:variable name="filename" select="substring-before($pointer, '#')"/>
        <xsl:variable name="string_range"
            select="tokenize(tokenize($pointer, 'string-range\(')[2], ',')"/>
        <xsl:variable name="xpath"
            select="concat('doc(&quot;', $filename, '&quot;)', $string_range[1])"/>
        <xsl:variable name="line">
            <xsl:evaluate xpath="$xpath"/>
        </xsl:variable>
        <xsl:variable name="text" select="
                substring-before(substring(normalize-space($line), number($string_range[2])),
                substring(normalize-space($line), number(substring-before($string_range[3], ')'))))"/>
        <xsl:choose>
            <xsl:when test="$text = ''">
                <!-- If there's no match, it means the second substring is empty (end of line) -->
                <xsl:value-of select="substring(normalize-space($line), number($string_range[2]))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- ebb: Launch the spine generator. -->
    <xsl:template match="/">
        <xsl:for-each select="$P1-spines">
            <xsl:variable name="P1-filename" as="xs:string" select="current() ! base-uri() ! tokenize(.,'/')[last()]"/>
            <xsl:variable name="chunk" as="xs:string" select="$P1-filename ! substring-after(., '_') ! substring-before(., '.xml')"/>
            <!-- 2023-07-04 ebb: For testing SGA Link Pointers, let's output to a new temporary directory: subchunked-standoff_Spine_SGA. Let's name the test SGA-linked output directories further along with _SGA at the end
            -->
            <xsl:result-document method="xml" indent="yes"
                href="subchunked_standoff_Spine_SGA/spine_{$chunk}.xml">
                <xsl:apply-templates/>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="lookback">
        <xsl:param name="rdg" select="."/>
        <xsl:param name="wholeChunkID"/>
        <xsl:variable name="str"
            select="tokenize(normalize-space(string-join($rdg/preceding::tei:rdg[ends-with(@wit, 'fMS')])), '&lt;lb\s+n')[last()]"/>
        <xsl:variable name="pointer">
            <!--ebb: REMOVE this line if returning to point at S-GA files directly. NoTE: as of summer 2023, this
            line is out of date because output fv-data edition files are stored as chapters now, not as "chunk files".-->
           <!-- <xsl:value-of select="concat($sga_loc, 'fMS_', $wholeChunkID, '.xml', '#')"/>-->
            <xsl:value-of
                select="fv:getLbPointer(normalize-space(tokenize($rdg/preceding::tei:rdg[ends-with(@wit, 'fMS')][contains(normalize-space(.), 'lb n=&quot;')][1], '&lt;lb\s+n')[last()]))"
            />
        </xsl:variable>
        <xsl:if test="not($pointer = '')">
            <xsl:variable name="pre_text"
                select="replace(replace($str, '&lt;.*?&gt;', ''), '^=&quot;[^&quot;]+?&quot;\s*?/&gt;', '')"/>
            <xsl:variable name="cur_text" select="replace(normalize-space(.), '&lt;.*?&gt;', '')"/>
            <xsl:variable name="full_pointer"
                select="concat($pointer, ',', string-length($pre_text) + 1, ',', string-length($pre_text) + string-length($cur_text) + 2, ')')"/>
            <!-- "2" accounts for needed extra space and index number -->
            <ptr target="{$full_pointer}" xmlns="http://www.tei-c.org/ns/1.0"/>
            <!-- Un-comment these for testing pointer resolution -->
            <fv:line_text>
                <xsl:value-of select="concat('(', $pre_text, ') ', $cur_text)"/>
            </fv:line_text>
            <fv:resolved_text>
                <xsl:value-of select="fv:resolvePointer($full_pointer)"/>
            </fv:resolved_text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="app[count(tei:rdgGrp) gt 1 or count(descendant::tei:rdg) &lt; 5]">
        <xsl:variable name="currApp" as="element()" select="current()"/>
        <app>
            <xsl:copy-of select="@*"/>
            <xsl:variable name="appID" as="xs:string" select="@xml:id"/>
            <xsl:variable name="wholeChunkID" as="xs:string"
                select="substring-before($appID, '_')"/>
            <!-- 2023-07-03 ebb: Let's add the null pointers here for missing witnesses. -->
            <xsl:if test="count(descendant::rdg) &lt; 5">
                <xsl:variable name="allWits" as="xs:string+" select="'f1818', 'fThomas', 'f1823', 'f1831', 'fMS'"/>
                <xsl:variable name="missingWits" as="xs:string+" select="for $i in $allWits return $i[not(. = $currApp//rdg/@wit)]"/>
                <rdgGrp xml:id="{$currApp/@xml:id}_rg_empty">
                    <!-- 2023-07-12 yxj: ∅ charater is not valid JSON 
                2023-07-13 ebb: Let's change the handling here so we simply don't output @n when there is no content.
                Another possibility we could try is n="['∅']", but this might imply that this content is actually present, when 
                we want to signal the emptiness of content at this point. 
                -->
                    <xsl:for-each select="$missingWits">
                        <rdg wit="#{current()}"/>
                    </xsl:for-each>
                </rdgGrp>
            </xsl:if>
            
            <xsl:apply-templates select="rdgGrp">
                <xsl:with-param name="appID" as="xs:string" select="$appID"/>
                <xsl:with-param name="wholeChunkID" select="$wholeChunkID"/>
            </xsl:apply-templates>
        </app>
    </xsl:template>
    <xsl:template match="rdgGrp">
        <xsl:param name="appID"/>
        <xsl:param name="wholeChunkID"/>
        <rdgGrp>
            <xsl:copy-of select="@*"/>
            <xsl:for-each select="rdg">
                <xsl:choose>
                    <xsl:when test="ends-with(@wit, 'fMS')">
                        <rdg wit="#fMS">
                            <xsl:choose>
                                <!-- When a reading contains one or more LB elements, split the content around LB and determine the pointer based on the LB value -->
                                <xsl:when test="contains(normalize-space(.), 'lb n=&quot;')">
                                    <xsl:variable name="currentRdg" select="."/>
                                    <xsl:for-each
                                        select="tokenize(normalize-space(.), '&lt;lb\s+n')">
                                        <xsl:choose>
                                            <!-- EDGE CASE: the first token belongs to a previous line, in which case the previous line will need to be located -->
                                            <!-- Each token after an LB will start with '=', so check whether it's missing -->
                                            <xsl:when test="starts-with(normalize-space(.), '=')">
                                                <!-- Only process it if there's content after the lb -->
                                                <xsl:if
                                                  test="string-length(substring-after(normalize-space(.), '/&gt;')) > 0">
                                                  <xsl:variable name="pointer">
                                                  <xsl:value-of
                                                  select="fv:getLbPointer(normalize-space(current()))"
                                                  />
                                                  </xsl:variable>
                                                  <xsl:if test="not($pointer = '')">
                                                  <xsl:variable name="text" select="
                                                                replace(
                                                                replace(
                                                                normalize-space(current()), '&lt;.*?&gt;', ''
                                                                ),
                                                                '^=&quot;[^&quot;]+?&quot;\s*?/&gt;', ''
                                                                )"/>
                                                  <xsl:variable name="full_pointer">
                                                  <xsl:value-of
                                                  select="concat(string-join(fv:getLbPointer(normalize-space(current()))), ',0,', string-length($text) + 1, ')')"
                                                  />
                                                  </xsl:variable>
                                                  <ptr target="{$full_pointer}"/>
                                                  <!-- Un-comment these for testing pointer resolution -->
                                                  <fv:line_text>
                                                        <xsl:value-of select="$text"/>                                        
                                                    </fv:line_text>
                                                    <fv:resolved_text>
                                                        <xsl:value-of select="fv:resolvePointer($full_pointer)"/>
                                                    </fv:resolved_text>
                                                  </xsl:if>
                                                </xsl:if>
                                            </xsl:when>
                                            <!-- Skip space-only or empty string nodes -->
                                            <xsl:when
                                                test="normalize-space(.) = ' ' or normalize-space(.) = ''"/>
                                            <xsl:otherwise>
                                                <xsl:call-template name="lookback">
                                                  <xsl:with-param name="rdg" select="$currentRdg"/>
                                                  <xsl:with-param name="wholeChunkID"
                                                  select="$wholeChunkID"/>
                                                </xsl:call-template>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:call-template name="lookback">
                                        <xsl:with-param name="wholeChunkID" select="$wholeChunkID"/>
                                    </xsl:call-template>
                                </xsl:otherwise>
                            </xsl:choose>
                        </rdg>
                    </xsl:when>
                    <xsl:otherwise>
                        <rdg wit="#{@wit}">
                            <xsl:variable name="currWit" as="xs:string" select="@wit"/>
                            <xsl:variable name="currP1filename" as="xs:string"
                                select="tokenize(base-uri(.), '/')[last()]"/>
                           <!-- <xsl:variable name="currEdition" as="element()*"
                                select="$P6_coll//TEI[tokenize(base-uri(), '/')[last()] ! tokenize(., '_')[1] eq $currWit][tokenize(base-uri(), '/')[last()] ! substring-after(., '_') ! substring-before(., '.') = tokenize($currP1filename, '[a-z]?\.')[1] ! substring-after(., '_')]"/>-->
                            <!-- 2023-07-03 ebb: ABOVE LINE is just pulling info from the current filename.  -->
                            <xsl:variable name="currEd-Seg" as="element()*"
                                select="$P6_coll//seg[substring-before(@xml:id, '-') = $appID][substring-after(@xml:id, '-') = $currWit]"/>
            <!-- 2023-07-03 ebb: We no longer need to point to chunk edition files, so don't need this variable.
                                <xsl:variable name="currEd-Chunk" as="xs:string"
                                select="substring-before($currEd-Seg, '_')"/>
                            <xsl:message>Value of $currEd-Chunk is <xsl:value-of
                                    select="$currEd-Chunk"/></xsl:message>-->
                            <xsl:variable name ="currEd-FileName" as="xs:string*" select="$currEd-Seg ! base-uri() ! tokenize(., '/')[last()]"/>
                            
                            
                            <xsl:for-each select="$currEd-FileName">
                                <ptr target="https://raw.githubusercontent.com/FrankensteinVariorum/fv-data/master/2023-variorum-chapters/{$currEd-FileName}#{$currEd-Seg/@xml:id}"/>
                            </xsl:for-each>
                        </rdg>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </rdgGrp>
    </xsl:template>

    <!--Suppresses invariant apps from the spine. -->
    <xsl:template match="tei:app[count(tei:rdgGrp) eq 1][count(descendant::rdg) = 5]"/>

</xsl:stylesheet>
