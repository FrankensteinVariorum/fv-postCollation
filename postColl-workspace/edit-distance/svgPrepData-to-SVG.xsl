<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fv="https://github.com/FrankensteinVariorum"
    xmlns:ebb="https://ebeshero.github.io"
    exclude-result-prefixes="xs fv ebb tei"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>    
    <!-- 2024-07-21 This XSLT should generate 5 long side-by-side rectangles for each of the 5 versions. 
        The MS will have gaps where it's missing in comparison to the others. Colors will output in varying intensity,
        so we may want to use RGB values instead of the hex values. -->
       
    <xsl:variable name="wits" as="xs:string+" select="'fMS', 'f1818', 'f1823', 'fThomas', 'f1831'"/>
    
    <!-- This document stores witness variation data in XML. -->
    <xsl:variable name="witLevData" as="document-node()" select="doc('svgPrep-witLevData.xml')"/>
    
    <xsl:variable name="spine" as="document-node()+" select="collection('../standoff_Spine/?select=*.xml')"/>
   
    
    <!-- Color values for the heatmap need to be on an integer range from 0 to 255, but the max fVal is 4221. So we need to convert from a scale from 0 to 4221 to 0 to 255. Divide 255 by the max lev to get a factor for conversion. -->
    <xsl:variable name="maxLevDistance" select="$witLevData//@fVal[not(. = 'null')] => max()"/>
    
    <xsl:template match="/">
        <svg xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 1000 7500">
            <xsl:comment>SPINE TEST: <xsl:value-of select="$spine//tei:ptr/@target[contains(., 'f1823_vol_1_letter_iii')]"/></xsl:comment>
            <g class="outer" transform="translate(50, 50)">        
                <xsl:apply-templates select="$witLevData//xml/fs[descendant::f/@fVal[not(. = 'null')] ! number() &gt;= 50]"/>
                <!-- ebb: This uses general comparison to ensure that the whole series of @fVal values must meet the requirement of being greater than or equal to 50. 
                    We found that often edits are just 1 to 3 characters of difference, but this visualization is designed to concentrate on lengthier revisions. 
                    NOTE: The yPos variable defined below MUST MATCH the xsl:apply-templates selection here, if we wish to change the values displayed in the heatmap. 
                -->
            </g>
        </svg>
    </xsl:template>
    <xsl:template match="xml/fs">
        <xsl:variable name="currentApp" as="element()" select="current()"/>
        <xsl:variable name="yPos" select="(count($currentApp/preceding-sibling::fs[descendant::f/@fVal[not(. = 'null')] ! number() &gt;= 50]) + 1) * 30"/>
        <!-- ebb: IMPORTANT: The yPos variable MUST MATCH xsl:apply-templates in the previous template. 
            These are both currently set to plot only passages where the edit distance is higher than 50 in order to keep the heatmap concise. -->

        <g id="{@feats}">
        <xsl:for-each select="$wits">  
            <xsl:variable name="currentWit" as="xs:string" select="current()"/>
            <xsl:variable name="heatMapVal"  select="(($currentApp/f[@name=current()]/fs[@feats='witData']/f[not(@name='fMS_empty')]/@fVal[not(. = 'null')] ! number() => avg()) * (127 div $maxLevDistance)) ! ceiling(.)"/>
            <!-- This takes the average of the lev distance values given for comparisons with a given witness, and maps it to a scale of 255 for rgb plotting. 
                Changes to try: Try making it the max() instead of the avg() distance value. Is that more interesting? Or less accurate? I preferred the average of all the values for displaying a single value
                representing a witnesses difference from all the others.
                2024-07-30 ebb: I'm redoing this to start from a base grey value of rgb(128,128,128). So I'm scaling the heatmap values on a basis of 55 instead of 255. We'll add this heatmap value to a base 
                of 200 in the Red category, and leave Blue and Green at 200.  (55 + 200 = 255, or the max possible red, which will be for our max edit distance value.)
            -->
            <xsl:variable name="editionRegex" as="xs:string" select="'::.*?#'||current()"/>
            <xsl:comment>Edition Regex: <xsl:value-of select="$editionRegex"/></xsl:comment>
            <xsl:variable name="linkInfo" as="xs:string?" select="($currentApp/f[@name=current()][.//f[@name[contains(., '::')]]]//f/@name ! tokenize(., $editionRegex) ! tokenize(., '::')[starts-with(., 'C')])[last()]"/>
         <xsl:comment>LinkInfo VALUE: <xsl:value-of select="$linkInfo"/></xsl:comment> 
            
            <xsl:variable name="chapterLocation" select="($spine//tei:rdgGrp[@xml:id=$linkInfo and descendant::tei:ptr]//tei:ptr/@target)[not(contains(., 'sga'))][1] ! tokenize(., '2023-variorum-chapters/')[last()] ! substring-before(., '#') ! substring-before(., '.xml')"/>   
            <!-- 2024-07-23 ebb: The above code for retrieving chapterLocation info isn't matching properly in the spine files. 
                It is reaching into the correct rdGrp, but I cannot create a filter to pull ptr/@target att values for the specific witness for some reason: possibly a namespace issue. XPath predicates are failing to retrieve anything when 
                seeking the current witness within the given rdgGrp. Instead, just to retrieve a link to the correct location in ANY of the editions, I reached successfully for the FIRST available link that doesn't contain sga. 
                So we're taking the first available ptr/@target : 
                ($spine//tei:rdgGrp[@xml:id=$linkInfo and descendant::tei:ptr]//tei:ptr/@target)[not(contains(., 'sga'))][1] 
                
                The [not(contains, 'sga')] filter just eliminates ptr elements nested deep in the rdgGrp that point into the Shelley-Godwin Archive.  
                
                Some XPath filters we want to retrieve the correct witness, but that don't work:
                $spin/tei:rdgGrp[@xml:id=$linkInfo/tei:rdg[substring-after(@wit, '#') = current()]/tei:ptr/@target ! tokenize(., '2023-variorum-chapters/')[last()] ! substring-before(., '#') ! substring-before(., '.xml') -->
            
            <xsl:comment><xsl:value-of select="$currentWit"/> SPINE CHAPTER LOCATION: <xsl:value-of select="$chapterLocation"/></xsl:comment>
            
            
            <xsl:variable name="linkConstructor" as="xs:string" select="'https://frankensteinvariorum.org/viewer/'||$chapterLocation ! tokenize(., '_') ! substring-after(., 'f')||'/'||$chapterLocation ! substring-after(., '_')||'/#'||$linkInfo ! substring-before(., '_rg')"/>
            <!-- SAMPLE LINK TO FV: https://frankensteinvariorum.org/viewer/1818/vol_3_chapter_i/#C24_app15 -->
              
            <g class="{current()}">
           <xsl:choose> 
               <xsl:when test="current() = 'fMS' and $currentApp/f[@name='fMS'][descendant::f/@fVal => distinct-values() = 'null']">
                   <!-- Output nothing for fMS here because it's missing at this point: This will allow us to see the gap. -->
               </xsl:when>
             
              <xsl:otherwise> 
                 
                  <a xlink:href="{$linkConstructor}">
                      <line x1="{position() * 150}" x2="{position() * 150}" y1="{$yPos}" y2="{$yPos + 30}" stroke-width="100" stroke="rgb({200 + $heatMapVal}, {200 - $heatMapVal}, {200 - $heatMapVal})">
                      <title><xsl:value-of select="translate($currentApp/@feats, '_', ' ')"/></title>            
                  </line>
               <!--   <text x="{position() * 150}" y="{$yPos + 15}" text-anchor="middle"><xsl:value-of select="translate($currentApp/@feats, '_', ' ')"/></text> --></a>
              </xsl:otherwise>
           </xsl:choose>
            </g>
        </xsl:for-each>
        </g>
    </xsl:template>
    
    
    
</xsl:stylesheet>