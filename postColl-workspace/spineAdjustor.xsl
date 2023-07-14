<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse" exclude-result-prefixes="xs"
    version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="spineColl" as="document-node()+"
        select="collection('early_standoff_Spine/?select=*.xml')"/>
    <!--2023-07-14 ebb: This XSLT is for patching and updating the spine structure. At this stage we are:
        * adding hashtags if they're missing in the @wit on rdg.
        * enhancing data for pointing to the Shelley-Godwin Archive, adding info to <witDetail> needed for links to 
        published webpages, and structuring the element contents of <witDetail> according to page. 
    
    -->
    <xsl:template match="/">
      <!-- 2023-07-14 No longer necessary since we no longer have subchunked files. 
          <xsl:for-each-group select="$spineColl"
            group-by="tokenize(base-uri(), '_')[last()] ! tokenize(., '[a-z]?\.xml')[1]">
            <xsl:variable name="filename" select="concat('spine_', current-grouping-key(), '.xml')"/>
            <xsl:variable name="chunk"
                select="tokenize($filename, '_')[last()] ! substring-before(., '.xml')"/>-->
        <xsl:for-each select="$spineColl">
            <xsl:variable name="filename" as="xs:string" select="current() ! tokenize(base-uri(), '/')[last()]"/>
            <xsl:variable name="chunk" as="xs:string" select="$filename ! substring-after(., '_') ! substring-before(., '.xml')"/>
            <xsl:result-document method="xml" indent="yes" href="preLev_standoff_Spine/{$filename}">
                <TEI>
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>Spine: Collation unit <xsl:value-of select="$chunk"/></title>
                            </titleStmt>
                            <publicationStmt>
                                <authority>Frankenstein Variorum Project</authority>
                                <date>2023—</date>
                                <availability>
                                    <licence>Distributed under a Creative Commons
                                        Attribution-ShareAlike 3.0 Unported License</licence>
                                </availability>
                            </publicationStmt>
                            <xsl:copy-of select="(current()//TEI/teiHeader//sourceDesc)[1]"/>
                        </fileDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <listApp>
                                <xsl:for-each select="current()//TEI">
                                    <xsl:apply-templates select=".//body/*"/>
                                </xsl:for-each>
                            </listApp>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
        <!--</xsl:for-each-group>-->
        
    </xsl:template>
    <xsl:template match="body/*">
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
