<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <!--2018-10-24 updated 2019-03-16 ebb: This identity transformation stylesheet removes comparisons to NoRG (or null reading groups) in the feature structures file holding weighted Levenshtein data for our collated Variorum. -->
    <xsl:template match="f">
        <xsl:choose>
            <xsl:when test="contains(@name, 'NoRG')"/>
            <xsl:otherwise>
                <xsl:copy-of select="current()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>