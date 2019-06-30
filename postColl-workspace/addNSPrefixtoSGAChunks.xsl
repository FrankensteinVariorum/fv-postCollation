<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    <!--2019-06-30 ebb: This Stylesheet was made to patch in a new prefixed namespace line to the S-GA files in the repo.
        Run this with Saxon at command line update the original SGA files for the Variorum, using:
    java -jar saxon.jar -s:/sga-variorum-chunks -xsl:addNSPrefixtoSGAChunks.xsl -o:P5-output/ -->
    <xsl:template match="/*">
        <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@* | namespace-node()"/>
            <xsl:namespace name="tei" select="'http://www.tei-c.org/ns/1.0'"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>