<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:cx="http://interedition.eu/collatex/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all" version="3.0">
    <!--2018-06-21 ebb: Bridge Edition Constructor Part 1: This first phase up-converts to TEI and adds xml:ids to each <app> element in the output collation. 
        In the event that the collation process broke apart the self-closed elements into two tags, this stylesheet catches these and restores them to single tags.  -->
    <xsl:output method="xml" indent="yes"/>
    <xsl:variable name="collFiles" as="document-node()+"
        select="collection('collated-data/?select=*.xml')"/>

    <!--    <xsl:param name="collFiles" as="node()" required="yes"/>-->

    <xsl:variable name="witnesses" as="xs:string+" select="distinct-values($collFiles//@wit)"/>

    <xsl:template match="/">
        <xsl:for-each select="$collFiles//cx:apparatus">
            <xsl:variable name="chunk" as="xs:string"
                select="substring-after(substring-before(tokenize(base-uri(), '/')[last()], '.'), '_')"/>
            <xsl:result-document method="xml" indent="yes" href="P1-output/P1_{$chunk}.xml">
                <TEI xml:id="P1-{$chunk}">
                    <teiHeader>
                        <fileDesc>
                            <titleStmt>
                                <title>Bridge Phase 1: Collation unit <xsl:value-of select="$chunk"
                                    /></title>
                            </titleStmt>
                            <publicationStmt>
                                <authority>Frankenstein Variorum Project</authority>
                                <date>2023—</date>
                                <availability>
                                    <licence>Distributed under a Creative Commons
                                        Attribution-ShareAlike 3.0 Unported License</licence>
                                </availability>
                            </publicationStmt>
                            <sourceDesc>
                                <p>Produced from collation output prepared in batch file processing
                                    on <xsl:value-of select="./../comment()"/>.</p>
                                <p>Edited to correct alignments and prepared for the Frankenstein
                                    Variorum spine on <xsl:value-of select="current-dateTime()"
                                    />.</p>
                            </sourceDesc>
                        </fileDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <listApp>
                                <xsl:apply-templates select="descendant::app">
                                    <xsl:with-param name="chunk" select="$chunk" tunnel="yes"/>
                                </xsl:apply-templates>
                            </listApp>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="app">
        <xsl:param name="chunk" tunnel="yes"/>
        <app xml:id="{$chunk}_app{count(preceding::app) + 1}">
            <xsl:apply-templates>
                <xsl:with-param name="chunk" select="$chunk" tunnel="yes"/>
            </xsl:apply-templates>
        </app>
    </xsl:template>
    <xsl:template match="rdgGrp">
        <xsl:param name="chunk" tunnel="yes"/>
        <rdgGrp
            xml:id="{$chunk}_app{count(preceding::app) + 1}_rg{count(preceding-sibling::rdgGrp) + 1}"
            n="{@n}">
            <xsl:apply-templates/>
        </rdgGrp>
    </xsl:template>

    <xsl:template match="rdg">
        <rdg wit="{@wit}">
            <xsl:analyze-string select="." regex="&lt;([^/]+?)&gt;\s*&lt;/\1&gt;">
                <xsl:matching-substring>
                    <xsl:value-of select="tokenize(., '\s*&lt;/')[1] ! substring-before(., '&gt;')"/>
                    <xsl:text>/&gt;</xsl:text>
                    <!-- 2023-05-22 ebb and yxj: This finds text-bearing whole elements that contain only spaces or no text at all in the 
                    text node. 
                    It finds these and converts them into self-closing elements 
                    <mdel>   </mdel>
                    to
                    <mdel/>
                     -->
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <!-- Remove longTokens -->
                    <xsl:analyze-string select="." regex="&lt;.?longToken&gt;">
                        <xsl:matching-substring/>
                        <xsl:non-matching-substring>
                            <!-- normalize space and remove line break in **markers** -->
                            <xsl:analyze-string select="." regex="[\s\n\r]+">
                                <xsl:matching-substring>
                                    <xsl:text> </xsl:text>
                                </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:sequence select="."/>
                                </xsl:non-matching-substring>
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
                    </xsl:analyze-string>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </rdg>
    </xsl:template>
</xsl:stylesheet>
