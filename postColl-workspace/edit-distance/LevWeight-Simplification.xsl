<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <!--2018-10-24 updated 2019-03-16 ebb: We may or may not wish to run this XSLT. This identity transformation stylesheet removes comparisons to absent witnesses (indicated as NoRG) in the feature structures file holding weighted Levenshtein data for our collated Variorum.
    ISSUE: (Why we may NOT wish to run this): Running this stylesheet will affect our readout of collation variance. Consider the case of variant passages where one or more witnesses are not present and have no material to compare. This may be because, in the case of the ms notebooks, we simply do not have any material, or it may be because, in the case of the 1831 edition, a passage was heavily altered and cut, and there isn't any material present. High Levenshtein values are produced in each case. 
    As of 2019-03-16 (ebb), I'm deciding NOT to run this stylesheet so that the team can evaluate the Levenshtein results to represent comparisons with omitted/missing material. 
   Revisiting on 3 July 2019: I think we DO want to run this because we're getting spurious high results for passages of really low variance. 
    -->
    <xsl:template match="f">
        <xsl:choose>
            <xsl:when test="contains(@name, 'NoRG')"/>
            <xsl:otherwise>
                <xsl:copy-of select="current()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>