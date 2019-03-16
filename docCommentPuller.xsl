<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xpath-default-namespace="http://www.w3.org/1999/XSL/Transform"
    version="3.0">
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