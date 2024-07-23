<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fv="https://github.com/FrankensteinVariorum"
    xmlns:ebb="https://ebeshero.github.io"
    exclude-result-prefixes="xs"
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

    
    <!-- EDITION WITNESS BASE COLORS IN RGB-
        Question: HOW am I going to meaningfully introduce variance for comparison? Maybe I should pick one of these colors and run with varying intensity of one or two values. 
        -->
    <xsl:variable name="color_MS" as="xs:string" select="'rgb(133, 126, 230)'"/> <!-- purple -->
    <xsl:variable name="color_1818" as="xs:string" select="'rgb(254, 178, 122)'"/> <!-- orange -->
    <xsl:variable name="color_Thom" as="xs:string" select="'rgb(226, 121, 189)'"/>  <!-- pink -->
    <xsl:variable name="color_1823" as="xs:string" select="'rgb(114, 187, 194)'"/>  <!-- green -->
    <xsl:variable name="color_1831" as="xs:string" select="'rgb(219, 82, 107)'"/>  <!-- red  -->
    <xsl:variable name="colorArray" as="xs:string+" select="($color_MS, $color_1818, $color_Thom, $color_1823,$color_1831)"/>
    
    <xsl:template match="/">
        <svg xmlns:xlink="http://www.w3.org/1999/xlink" width="100%" height="100%" viewBox="0 0 1000 53000">
            <xsl:comment>SPINE TEST: <xsl:value-of select="$spine//tei:ptr/@target[contains(., 'f1823_vol_1_letter_iii')]"/></xsl:comment>
            <g class="outer" transform="translate(50, 50)">        
                <xsl:apply-templates select="$witLevData//xml/fs[descendant::f/@fVal[not(. = 'null')] ! number() &gt;= 10]"/>
                <!-- ebb: This uses general comparison to ensure that the whole series of @fVal values must meet the requirement of being greater than or equal to 10. We found that often edits are just 1 to 3 characters of difference, but this visualization is designed to concentrate on lengthier revisions. -->
            </g>
        </svg>
    </xsl:template>
    <xsl:template match="xml/fs">
        <xsl:variable name="currentApp" as="element()" select="current()"/>
        <xsl:variable name="yPos" select="(count($currentApp/preceding-sibling::fs[descendant::f/@fVal[not(. = 'null')] ! number() &gt;= 10]) + 1) * 30"/>
        <!-- ebb: The next variables control for column position in the SVG -->
        <xsl:variable name="cu_pos" select="position()"/>
        <xsl:variable name="vertPos" as="xs:integer" select="$cu_pos mod 11"/>
        <xsl:variable name="columnPos" as="xs:decimal" select="(floor($cu_pos div 11) + 1) * 500"/>
        <!-- 2024-07-23 CONTINUE: Apply these to create three columns for this SVG-->
        <g id="{@feats}">
        <xsl:for-each select="$wits">  
            <xsl:variable name="currentWit" as="xs:string" select="current()"/>
            <xsl:variable name="heatMapVal"  select="(($currentApp/f[@name=current()]/fs[@feats='witData']/f[not(@name='fMS_empty')]/@fVal[not(. = 'null')] ! number() => avg()) * (255 div $maxLevDistance)) ! ceiling(.)"/>
            <!-- This takes the average of the lev distance values given for comparisons with a given witness. -->
            <xsl:variable name="editionRegex" as="xs:string" select="'::.*?#'||current()"/>
            <xsl:comment>Edition Regex: <xsl:value-of select="$editionRegex"/></xsl:comment>
            <xsl:variable name="linkInfo" as="xs:string?" select="($currentApp/f[@name=current()][.//f[@name[contains(., '::')]]]//f/@name ! tokenize(., $editionRegex) ! tokenize(., '::')[starts-with(., 'C')])[last()]"/>
         <xsl:comment>LinkInfo VALUE: <xsl:value-of select="$linkInfo"/></xsl:comment> 
            
            <xsl:variable name="chapterLocation" select="($spine//tei:rdgGrp[@xml:id=$linkInfo and descendant::tei:ptr]//tei:ptr/@target)[not(contains(., 'sga'))][1] ! tokenize(., '2023-variorum-chapters/')[last()] ! substring-before(., '#') ! substring-before(., '.xml')"/>   
            
      
                
            
            
            <!-- 2024-07-23 ebb: The above code for retrieving chapterLocation info isn't matching properly in the spine files to pull  ptr/@target att values within the specific witness for some reason. So we're taking the first available ptr/@target for the moment. 
                Some XPath filters we want: 
                [substring-after(@wit, '#') = current()]/tei:ptr/@target ! tokenize(., '2023-variorum-chapters/')[last()] ! substring-before(., '#') ! substring-before(., '.xml') -->
            
            <xsl:comment><xsl:value-of select="$currentWit"/> SPINE CHAPTER LOCATION: <xsl:value-of select="$chapterLocation"/></xsl:comment>
            
            
            <xsl:variable name="linkConstructor" as="xs:string" select="'https://frankensteinvariorum.org/viewer/'||$chapterLocation ! tokenize(., '_') ! substring-after(., 'f')||'/'||$chapterLocation ! substring-after(., '_')||'/#'||$linkInfo ! substring-before(., '_rg')"/>
            <!-- SAMPLE LINK TO FV: https://frankensteinvariorum.org/viewer/1818/vol_3_chapter_i/#C24_app15 -->
              
            <g class="{current()}">
           <xsl:choose> 
               <xsl:when test="current() = 'fMS' and $currentApp/f[@name='fMS'][descendant::f/@fVal => distinct-values() = 'null']">
                   <!-- Output nothing for fMS here because it's missing at this point.   -->
               </xsl:when>
             
              <xsl:otherwise> 
                  <line x1="{position() * 150}" x2="{position() * 150}" y1="{$yPos}" y2="{$yPos + 30}" stroke-width="100" stroke="rgb({$heatMapVal}, {255 - 2*$heatMapVal}, {255 - 2*$heatMapVal})" xlink:href="{$linkConstructor}">
                      <title><xsl:value-of select="translate($currentApp/@feats, '_', ' ')"/></title>            
                  </line>
               <!--   <text x="{position() * 150}" y="{$yPos + 15}" text-anchor="middle"><xsl:value-of select="translate($currentApp/@feats, '_', ' ')"/></text> -->
              </xsl:otherwise>
           </xsl:choose>
            </g>
        </xsl:for-each>
        </g>
    </xsl:template>
    
    
    
</xsl:stylesheet>