<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"  xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:mith="http://mith.umd.edu/sc/ns1#" xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    exclude-result-prefixes="xs th pitt mith tei" version="3.0">

    <!--2018-10-17 updated 2019-03-16 ebb: This XSLT generates the “spine” files for the Variorum. These files differ from the P1 stage of processing because the P1 form contains the complete texts of all edition files, mapping them to critical apparatus markup with variant apps (containing multiple rdgGrps or divergent forms) as well as invariant apps (containing only one rdgGrp where all editions run in unison). For the purposes of the Variorum encoding, our “spine” needs only to work with the variant passages, because those are the passages we will highlight and interlink in the Variorum interface. So, in this stage of processing we remove the invariant apps from P1 in generating the Variorum “spines”.  
        Note: we are processing rdgGrps in this XSLT. (In earlier stages of the project we had to generate rdgGrps at a later stage, but our current collation data file structure gives us rdgGrps to start with, so we preserve these in our output.)
        Run with saxon command line over P1-output directory and output to subchunked_standoff_Spine directory, using:
        
        java -jar saxon.jar -s:P1-output/ -xsl:P5_SpineGenerator.xsl -o:subchunked_standoff_Spine/ 
Change the output filenames from starting with P1_ to spine_.

        Following this, we: 
    * Run spineAdjustor.xsl to stitch up the multi-part spine sections into larger units and send that output to preLev_standoff_Spine. 
    * Calculate Levenshtein edit distances working in the edit-distance directory. Run extractCollationData.xsl and work with spineData.txt TSV files with Python, to generate FV_LevDists.xml. 
    * When edit distances are calculated and stored, run spine_addLevWeights.xsl to add Levenshtein values and generate the finished standoff_Spine directory files.
    --> 
    <!--2018-07-30 updated 2018-08-01 ebb: This file is now designed to generate the first incarnation of the standoff spine of the Frankenstein Variorum. The spine contains URI pointers to specific locations marked by <seg> elements in the edition files made in bridge-P5, and is based on information from the collation process stored in TEI in bridge P1. -->
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
        An alternative thought: Perhaps these file copies could echo each other so the fv-data repo can be a fallback in case something goes wrong w/ S-GA repo, and vice versa. 
    -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:param name="sga_loc" select="'https://raw.githubusercontent.com/PghFrankenstein/fv-data/master/variorum-chunks/'"/>  
   <!-- ebb: Keep for pointing to original SGA file location: <xsl:param name="sga_loc" select="'https://raw.githubusercontent.com/umd-mith/sga/6b935237972957b28b843f8d6d9f939b9a95dcb5/data/tei/ox/'"/>-->
    <xsl:variable name="P5_coll" as="document-node()+" select="collection('P5-output')"/>
    
    <xsl:function name="pitt:getLbPointer" as="item()*">
        <xsl:param name="str"/>
        <xsl:analyze-string select="$str" regex="^=&quot;([^&quot;]+?)&quot;\s*?/&gt;">
            <xsl:matching-substring>
                <xsl:variable name="ms-rest" select="tokenize(regex-group(1), '-')"/>                
                <xsl:variable name="ms" select="$ms-rest[1]"/>
                <xsl:variable name="parts" select="tokenize(replace($ms-rest[2], '__Pt\d+', ''), '__')"/>
                <xsl:variable name="surface" select="$parts[1]"/>
                <xsl:variable name="zone" select="$parts[2]"/>
                <xsl:variable name="line" select="$parts[3]"/>
        <!--ebb: Keep for pointing to original SGA file location: <xsl:value-of select="concat($sga_loc, 'ox-ms_abinger_', $ms, '/ox-ms_abinger_', $ms, '-', $surface, '.xml', '#')"/>-->
                <xsl:text>string-range(//tei:surface[@xml:id='ox-ms_abinger_</xsl:text>
                <xsl:value-of select="concat($ms, '-', $surface)"></xsl:value-of>
                <xsl:text>']/tei:zone[@type='</xsl:text>
                <xsl:value-of select="$zone"/>
                <xsl:text>']//tei:line[</xsl:text>
                <xsl:value-of select="$line"/>
                <xsl:text>]</xsl:text>
            </xsl:matching-substring>
        </xsl:analyze-string>        
    </xsl:function>
    
    <xsl:function name="pitt:resolvePointer">
        <!-- This function is here only for testing purposes. Please keep -->
        <xsl:param name="pointer"/>
        <xsl:variable name="filename" select="substring-before($pointer, '#')"/>
        <xsl:variable name="string_range" select="tokenize(tokenize($pointer, 'string-range\(')[2],',')"/>
        <xsl:variable name="xpath" select="concat('doc(&quot;', $filename,'&quot;)', $string_range[1])"/>
        <xsl:variable name="line">
            <xsl:evaluate xpath="$xpath"/>
        </xsl:variable>
        <xsl:variable name="text" select="substring-before(substring(normalize-space($line), number($string_range[2])), 
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
    
    <xsl:template name="lookback">
        <xsl:param name="rdg" select="."/>
        <xsl:param name="wholeChunkID"/>
        <xsl:variable name="str" select="tokenize(normalize-space(string-join($rdg/preceding::tei:rdg[ends-with(@wit, 'fMS')])), '&lt;lb\s+n')[last()]"/>
        <xsl:variable name="pointer">
            <!--ebb: REMOVE this line if returning to point at S-GA files directly. --><xsl:value-of select="concat($sga_loc, 'fMS_', $wholeChunkID, '.xml', '#')"/>
            <xsl:value-of select="pitt:getLbPointer(normalize-space(tokenize($rdg/preceding::tei:rdg[ends-with(@wit, 'fMS')][contains(normalize-space(.), 'lb n=&quot;')][1], '&lt;lb\s+n')[last()]))"/>
        </xsl:variable>
        <xsl:if test="not($pointer = '')">
            <xsl:variable name="pre_text" select="replace(replace($str, '&lt;.*?&gt;', ''), '^=&quot;[^&quot;]+?&quot;\s*?/&gt;', '')"/>
            <xsl:variable name="cur_text" select="replace(normalize-space(.), '&lt;.*?&gt;', '')"/>
            <xsl:variable name="full_pointer" select="concat($pointer,',',string-length($pre_text)+1,',',string-length($pre_text)+string-length($cur_text)+2, ')')"/> <!-- "2" accounts for needed extra space and index number -->
            <ptr target="{$full_pointer}" xmlns="http://www.tei-c.org/ns/1.0"/>
            <!-- Un-comment these for testing pointer resolution --> 
            <!--<pitt:line_text>
                <xsl:value-of select="concat('(', $pre_text, ') ', $cur_text)"/>
            </pitt:line_text>
            <pitt:resolved_text>
                <xsl:value-of select="pitt:resolvePointer($full_pointer)"/>
            </pitt:resolved_text>-->
        </xsl:if>      
    </xsl:template>
    
    <xsl:template match="tei:app[count(tei:rdgGrp) gt 1]">
        <app xmlns="http://www.tei-c.org/ns/1.0">
          <xsl:copy-of select="@*"/>
          <xsl:variable name="appID" as="xs:string" select="@xml:id"/>
          <xsl:variable name="wholeChunkID" as="xs:string" select="replace($appID, '[a-z]?_.+?$' , '')"/>
              <xsl:apply-templates select="rdgGrp"><xsl:with-param name="appID" as="xs:string" select="$appID"/><xsl:with-param name="wholeChunkID" select="$wholeChunkID"/></xsl:apply-templates>
        </app>
    </xsl:template>
    <xsl:template match="tei:rdgGrp">
        <xsl:param name="appID"/><xsl:param name="wholeChunkID"/>
        <rdgGrp xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@*"/>  
            <xsl:for-each select="tei:rdg">
            <xsl:choose>
                <xsl:when test="ends-with(@wit, 'fMS')">
                    <rdg wit="#fMS" xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:choose>
                            <!-- When a reading contains one or more LB elements, split the content around LB and determine the pointer based on the LB value -->                        
                            <xsl:when test="contains(normalize-space(.), 'lb n=&quot;')">
                                <xsl:variable name="rdg" select="."/> 
                                <xsl:for-each select="tokenize(normalize-space(.), '&lt;lb\s+n')">
                                    <xsl:choose>
                                        <!-- EDGE CASE: the first token belongs to a previous line, in which case the previous line will need to be located -->
                                        <!-- Each token after an LB will start with '=', so check whether it's missing -->
                                        <xsl:when test="starts-with(normalize-space(.), '=')">
                                            <!-- Only process it if there's content after the lb -->
                                            <xsl:if test="string-length(substring-after(normalize-space(.), '/&gt;')) > 0">
                                                <xsl:variable name="pointer">
                                                    <!--ebb: REMOVE this line if returning to point at S-GA files directly. --><xsl:value-of select="concat($sga_loc, 'fMS_', $wholeChunkID, '.xml', '#')"/>
                                                    <xsl:value-of select="pitt:getLbPointer(normalize-space(current()))"/>                                                
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
                                                        <!--ebb: REMOVE this line if returning to point at S-GA files directly. --><xsl:value-of select="concat($sga_loc, 'fMS_', $wholeChunkID, '.xml', '#')"/>
                                                    <xsl:value-of select="concat(string-join(pitt:getLbPointer(normalize-space(current()))),',0,',string-length($text)+1, ')')"/>
                                                    </xsl:variable>
                                                    <ptr target="{$full_pointer}"/>
                                                    <!-- Un-comment these for testing pointer resolution --> 
                                                    <!--<pitt:line_text>
                                                        <xsl:value-of select="$text"/>                                        
                                                    </pitt:line_text>
                                                    <pitt:resolved_text>
                                                        <xsl:value-of select="pitt:resolvePointer($full_pointer)"/>
                                                    </pitt:resolved_text>-->
                                                </xsl:if> 
                                            </xsl:if>
                                        </xsl:when>
                                        <!-- Skip space-only or empty string nodes -->
                                        <xsl:when test="normalize-space(.) = ' ' or normalize-space(.)  = ''"/>
                                        <xsl:otherwise>
                                            <xsl:call-template name="lookback">
                                                <xsl:with-param name="rdg" select="$rdg"/>
                                                <xsl:with-param name="wholeChunkID" select="$wholeChunkID"/>
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
                    <rdg wit="{@wit}" xmlns="http://www.tei-c.org/ns/1.0">     
                        <xsl:variable name="currWit" as="xs:string" select="@wit"/>
                        <xsl:variable name="currP1filename" as="xs:string" select="tokenize(base-uri(.), '/')[last()]"/>
                        <xsl:variable name="currEdition" as="element()*" select="$P5_coll//tei:TEI[tokenize(base-uri(), '/')[last()] ! substring-before(., '_') ! substring-after(., 'P5-') eq $currWit][tokenize(base-uri(), '/')[last() ] ! substring-after(., '_') ! substring-before(., '.') = tokenize($currP1filename, '[a-z]?\.')[1] ! substring-after(., '_') ]"/>         
                        <xsl:variable name="currEd-Seg" as="element()*" select="$currEdition//tei:seg[substring-before(@xml:id, '-') = $appID]"/>
                        <xsl:variable name="currEd-Chunk" as="xs:string" select="tokenize($currEdition/base-uri(), '/')[last()] ! substring-after(., '_') ! substring-before(., '.')"/> 
                        <xsl:message>Value of $currEd-Chunk is <xsl:value-of select="$currEd-Chunk"/></xsl:message>
                        <xsl:for-each select="$currEd-Seg">
                            <ptr target="https://raw.githubusercontent.com/PghFrankenstein/fv-data/master/variorum-chunks/{$currWit}_{$currEd-Chunk}.xml#{current()/@xml:id}"/>
                        </xsl:for-each>
                    </rdg>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>   
      </rdgGrp>
    </xsl:template>
    
<!--Suppresses invariant apps from the spine. -->
    <xsl:template match="tei:app[count(tei:rdgGrp) eq 1]"/>

</xsl:stylesheet>