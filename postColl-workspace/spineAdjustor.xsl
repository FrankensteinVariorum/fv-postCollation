<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse" exclude-result-prefixes="xs"
    version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="spineColl" as="document-node()+"
        select="collection('subchunked_standoff_Spine/?select=*.xml')"/>
    <!--2018-10-23 ebb: In this stage, we "sew up" the lettered spine sub-chunk files into complete chunks to match their counterpart edition files. 2018-10-25: Also, we're adding hashtags if they're missing in the @wit on rdg. -->
    <xsl:template match="/">
        <xsl:for-each-group select="$spineColl"
            group-by="tokenize(base-uri(), '_')[last()] ! tokenize(., '[a-z]?\.xml')[1]">
            <xsl:variable name="filename" select="concat('spine_', current-grouping-key(), '.xml')"/>
            <xsl:variable name="chunk"
                select="tokenize($filename, '_')[last()] ! substring-before(., '.xml')"/>
            <xsl:result-document method="xml" indent="yes" href="preLev_standoff_Spine/{$filename}">
                <TEI>
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>Spine: Collation unit <xsl:value-of select="$chunk"/></title>
                            </titleStmt>
                            <publicationStmt>
                                <authority>Frankenstein Variorum Project</authority>
                                <date>2018</date>
                                <availability>
                                    <licence>Distributed under a Creative Commons
                                        Attribution-ShareAlike 3.0 Unported License</licence>
                                </availability>
                            </publicationStmt>
                            <xsl:copy-of select="(current-group()//TEI/teiHeader//sourceDesc)[1]"/>
                        </fileDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <ab type="alignmentChunk">
                                <xsl:for-each select="current-group()//TEI">
                                    <xsl:sort select="base-uri()"/>
                                    <xsl:apply-templates
                                        select="descendant::ab[@type = 'alignmentChunk']"/>
                                </xsl:for-each>
                            </ab>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each-group>
        
    </xsl:template>
    <xsl:template match="ab">
        <xsl:apply-templates select="app"/>
    </xsl:template>
    <xsl:template match="rdg">
        <xsl:choose>
            <xsl:when test="starts-with(@wit, '#')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <rdg wit="#{@wit}">
                    <xsl:apply-templates/>
                </rdg>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

</xsl:stylesheet>
