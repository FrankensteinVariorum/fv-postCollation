<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
xpath-default-namespace="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="xs"
    version="3.0">
<!--2019-03-16 ebb: This XSLT helps us generate and update documentation of the post-processing stages following collation, to generate files for the Frankenstein Variorum edition. It is designed to pull comments from XSLT files throughout the repo to output a text file intended to help review our inline documentation and build up this repository's general ReadMe file. -->
    <xsl:output method="text"/>
    <xsl:variable as="document-node()+" name="topLevel-xslFiles" select="collection('postColl-workspace/?select=*.xsl')"/>
    <xsl:variable as="document-node()+" name="deep-xslFiles" select="collection('postColl-workspace/edit-distance/?select=*.xsl')"/>
    <xsl:variable as="document-node()+" name="xslFiles" select="($topLevel-xslFiles, $deep-xslFiles)"/>
    <xsl:template match="/">
        <xsl:for-each select="$xslFiles">
            <xsl:sort select="base-uri(.)"/>
            <xsl:value-of select="base-uri(.) ! substring-after(., 'postColl-workspace/') ! concat('### ', ., '&#10;')"/>
            <xsl:apply-templates select="current()//descendant::comment()"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="comment()">
        <xsl:text>* </xsl:text><xsl:value-of select="."/><xsl:text>&#10;</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>