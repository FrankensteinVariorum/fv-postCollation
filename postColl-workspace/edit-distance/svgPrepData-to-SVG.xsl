<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns="http://www.w3.org/2000/svg"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:output method="xml" indent="yes"/>    
    <!-- 2024-07-21 This XSLT should generate 5 long side-by-side rectangles for each of the 5 versions. 
        The MS will have gaps where it's missing in comparison to the others. Colors will output in varying intensity,
        so we may want to use RGB values instead of the hex values. -->
       

    
    <!-- COLORS -->
    <xsl:variable name="color_MS" as="xs:string" select="concat('#', '8383DB')"/>
    <xsl:variable name="color_1818" as="xs:string" select="concat('#', 'FDB27A')"/>
    <xsl:variable name="color_Thom" as="xs:string" select="concat('#', 'E377BF')"/>
    <xsl:variable name="color_1823" as="xs:string" select="concat('#', '6FBCC0')"/>
    <xsl:variable name="color_1831" as="xs:string" select="concat('#', 'D95369')"/>
    <xsl:variable name="colorArray" as="xs:string+" select="concat($color_MS, ', ', $color_1818, ', ', $color_Thom, ', ', $color_1823, ', ', $color_1831)"/>
    
    <xsl:template match="/">
        <svg width="1500" height="3800" viewBox="0 0 1500 3800">
            <g class="outer" transform="translate(50, 3300)">
            <xsl:apply-templates select="descendant::fs"/>
            </g>
        </svg>
    </xsl:template>
    
    
    
</xsl:stylesheet>