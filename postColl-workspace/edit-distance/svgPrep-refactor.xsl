<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    version="3.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- 2024-07-20 ebb Redo the feature structures from svgPrep_LevDists-simplified so you see data for each witness.
        Throw out the data of EMPTY ms compared to the witnesses.
        Output from this XSLT should be saved as svgPrep-witLevData.xml
    -->
    <xsl:variable name="wits" as="xs:string+" select="'fMS', 'f1818', 'f1823', 'fThomas', 'f1831'"/>
    <xsl:template match="/">
        <xml>
            <xsl:apply-templates/>
        </xml>
    </xsl:template>
    <xsl:template match="fs">
        <xsl:variable name="fsNode" as="element()" select="current()"/>
        <fs feats="{@feats}">
           <xsl:for-each select="$wits">
               <f name="{current()}">
                   <fs feats="witData">
                  <xsl:apply-templates select="$fsNode/f[contains(@name, current())]"/>
                   </fs>
               </f>               
           </xsl:for-each>          
        </fs>
    </xsl:template>
    <xsl:template match="f">
        <xsl:choose>
            <xsl:when test="matches(@name, 'rg_empty::.*?#fMS')">
                <f name="witness_empty" fVal="null"/>
                <!-- 2024-08-03 ebb: This nullifies ONLY the MS witness where emptiness is due to
                gaps in the record. When 1831 or other witnesses are empty, those 
                are due to active revision and should be considered measurable differences.-->
            </xsl:when>
            <xsl:otherwise>
                <f name="{@name}" fVal="{@fVal}"/>
            </xsl:otherwise>
        </xsl:choose>
       
    </xsl:template>
   
    
</xsl:stylesheet>