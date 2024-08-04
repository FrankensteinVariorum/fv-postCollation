<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.w3.org/2000/svg"
    xmlns="http://www.w3.org/2000/svg"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fv="https://github.com/FrankensteinVariorum"
    xmlns:ebb="https://ebeshero.github.io"
    exclude-result-prefixes="xs fv ebb tei"
    version="3.0">
    
 <!-- 2024-08-03 ebb: This is an identity transformation script to add guide marks of letter and chapter boundaries in the 1818 and 1831 editions to the heatmap visualization of the Frankenstein Variorum.  -->   
    <xsl:output method="xml" indent="yes"/>  
    <xsl:mode on-no-match="shallow-copy"/>
    
    
    <xsl:variable name="heatMapSVG" as="document-node()" select="doc('editionHeatMap.svg')"/>
    <xsl:variable name="spine" as="document-node()+" select="collection('../standoff_Spine/?select=*.xml')"/>
    
 <!--1818 and 1831 edition chapter location strings, pulled from spine files. -->   
    <xsl:variable name="chapterLocs-1818" as="xs:string+" select="$spine//tei:rdgGrp[descendant::tei:ptr]/tei:rdg[@wit='#f1818']/tei:ptr/@target ! tokenize(., '2023-variorum-chapters/')[last()] ! substring-before(., '.xml#') ! substring-after(., '_') => distinct-values() => sort()"/>
    
    <xsl:variable name="chapterLocs-1831" as="xs:string+" select="$spine//tei:rdgGrp[descendant::tei:ptr]/tei:rdg[@wit='#f1831']/tei:ptr/@target ! tokenize(., '2023-variorum-chapters/')[last()] ! substring-before(., '.xml#') ! substring-after(., '_') => distinct-values() => sort()"/>
    
   <xsl:template match="/">
       <svg 
           width="100%"
           height="100%"
           viewBox="0 0 3000 7500">
       <xsl:comment>1831 Chapter locations:
       <xsl:value-of select="string-join($chapterLocs-1831, ', ')"/>
       </xsl:comment>
      
     <!-- Copy the original heatmap intact. We will be adding to it. 
           
           <xsl:apply-templates select="descendant::desc"/>
           <xsl:apply-templates select="descendant::g"/> -->
           
           <xsl:apply-templates select=".//desc"/>
          
    <g class="outer" transform="translate(750, 100)"> 
        <xsl:apply-templates select=".//g[@class='outer']/g"/>

       
        <g id="navGuides"> 
          
            
            <text x="300" y="-10" font-variant="small-caps" font-size="6rem"  style="text-anchor: middle" font-weight="bold" >1818</text>
            
            
            
            <text x="750" y="-10" font-variant="small-caps" font-size="6rem"  style="text-anchor: middle" font-weight="bold" >1831</text>
          <g id="guide-1818">
           <xsl:for-each select="$chapterLocs-1818">
               <xsl:variable name="currentPos" select="position()"/>
               <!--Find the very first usage of the current location marker in the heatmap. -->
               <xsl:variable name="nearestMatch" as="element()?" select="($heatMapSVG//g[@class='f1818'][contains(a/@xlink:href, current())])[1]"/>
               <xsl:variable name="currentYpos" select="$nearestMatch//line/@y1"/>
             
               <!-- Apparently there are at least two locations from 1818, and also 1831 not represented in the heatmap. Let's see how this turns out with listing just those represented.
             -->  
             <xsl:if test="$nearestMatch ! exists(.)">  
                 <xsl:comment> <xsl:value-of select="$nearestMatch//title"/></xsl:comment>
                 
                 <xsl:choose>
                     <xsl:when test="current() = ('vol_1_letter_ii', 'vol_2_chapter_vi', 'vol_3_chapter_i')">
                         <line x1="-575" x2="300" y1="{$nearestMatch//line/@y1}"  
                             y2="{$nearestMatch//line/@y1}" stroke-width="5" stroke="black"/>
                         <text font-size="6rem" font-variant="small-caps" x="-1000" y="{$nearestMatch//line/@y1 + 15}" style="text-anchor: middle">
                             <xsl:value-of select="current() ! translate(., '_', ' ')"/></text>
                     </xsl:when>
                     <xsl:otherwise>
                         <line x1="30" x2="300" y1="{$currentYpos}"  
                             y2="{$currentYpos}" stroke-width="5" stroke="black"/>
                         <text font-size="6rem" font-variant="small-caps" x="-310" y="{$currentYpos + 15}" style="text-anchor: middle">
                             <xsl:value-of select="current() ! translate(., '_', ' ')"/></text> 
                     </xsl:otherwise>
                 </xsl:choose>      
               </xsl:if>
           </xsl:for-each>
              <xsl:variable name="waltonInCont" as="element()" select="($heatMapSVG//g[@class='fMS'][contains(a/@xlink:href, 'walton_in_continuation')])[1]"/>
              <line x1="-575" x2="300" y1="{$waltonInCont//line/@y1}"  
                  y2="{$waltonInCont//line/@y1}" stroke-width="5" stroke="black"/>
              <text font-size="6rem" font-variant="small-caps" x="-1050" y="{$waltonInCont//line/@y1 + 15}" style="text-anchor: middle">
                  walton, in continuation
              </text> 
       </g>
       <g id="guide-1831">
           <xsl:variable name="nearestMatch" as="element()?" select="($heatMapSVG//g[@class='f1831'][contains(a/@xlink:href, current())])[1]"/>
           <xsl:for-each select="$chapterLocs-1831">
               <xsl:variable name="currentPos" select="position()"/>
               <!--Find the very first usage of the current location marker in the heatmap. -->
               <xsl:variable name="nearestMatch" as="element()?" select="($heatMapSVG//g[@class='f1831'][contains(a/@xlink:href, current())])[1]"/>
               <xsl:variable name="currentYpos" select="$nearestMatch//line/@y1"/>
               
               <!-- Apparently there are at least two locations from 1818, and also 1831 not represented in the heatmap. Let's see how this turns out with listing just those represented.
             -->  
               <xsl:if test="$nearestMatch ! exists(.)">  
                   <xsl:comment> <xsl:value-of select="$nearestMatch//title"/></xsl:comment>
                   
                   <xsl:choose>
                       <xsl:when test="current() = ('letter_ii', 'chapter_xiv')">
                         
                           <line x1="1550" x2="750" y1="{$nearestMatch//line/@y1}"  
                               y2="{$nearestMatch//line/@y1}" stroke-width="5" stroke="black"/>
                           <text font-size="6rem" font-variant="small-caps" x="1800" y="{$nearestMatch//line/@y1 + 15}" style="text-anchor: middle">
                               <xsl:value-of select="current() ! translate(., '_', ' ')"/></text>
                       </xsl:when>
                       <xsl:otherwise>
                           <line x1="1050" x2="750" y1="{$currentYpos}"  
                               y2="{$currentYpos}" stroke-width="5" stroke="black"/>
                           <text font-size="6rem" font-variant="small-caps" x="1300" y="{$currentYpos + 15}" style="text-anchor: middle">
                               <xsl:value-of select="current() ! translate(., '_', ' ')"/></text> 
                       </xsl:otherwise>
                   </xsl:choose>      
               </xsl:if>
           </xsl:for-each>
           <xsl:variable name="waltonInCont" as="element()" select="($heatMapSVG//g[@class='fMS'][contains(a/@xlink:href, 'walton_in_continuation')])[1]"/>
           <line x1="1100" x2="750" y1="{$waltonInCont//line/@y1}"  
               y2="{$waltonInCont//line/@y1}" stroke-width="5" stroke="black"/>
           <text font-size="6rem" font-variant="small-caps" x="1600" y="{$waltonInCont//line/@y1 + 15}" style="text-anchor: middle">
               walton, in continuation
           </text> 
       
       </g>
      </g>
        
    </g>
   </svg>
   </xsl:template>
    
    
</xsl:stylesheet>