<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <!-- Run this with Saxon at command line update the original SGA files for the Variorum, using:
    java -jar saxon.jar -s:/sga-variorum-chunks -xsl:addNSPrefixtoSGAChunks.xsl -o:P5-output/ -->
    <xsl:template match="/*">
        <xsl:element name="{local-name()}" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy-of select="@* | namespace-node()"/>
            <xsl:namespace name="tei" select="'http://www.tei-c.org/ns/1.0'"/>
            <xsl:apply-templates select="node()[1]" mode="raising"/>
        </xsl:element>
    </xsl:template>
    
    
</xsl:stylesheet>