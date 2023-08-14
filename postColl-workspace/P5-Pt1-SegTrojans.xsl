<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="P4-Coll" as="document-node()+"
        select="collection('P4-output/?select=*.xml')"/>
    <!--2018-07-29: Bridge Construction Phase 5: What we need to do:      
       *  where the end markers of seg elements are marked we reconstruct them in pieces. 
        * raise the <seg> marker elements marking hotspots
       *  deliver seg identifying locations to the Spinal Column file.
    In this first stage of Part 5, we are converting the seg elements into Trojan markers using the th:namespace, and explicitly designating those that are fragments (that will break hierarchy if raised) as parts by adding a part attribute. 
    In the next stage, we will need to add additional seg elements to handle fragmented hotspots that break across the edition element hierarchy.
    In the last stage of this process, we adapt CMSpMq's left-to-right sibling traversal for raising flattened elements.  
    -->
    <xsl:template match="/">
        <xsl:for-each select="$P4-Coll//TEI">
            <xsl:variable name="currentP4File" as="element()" select="current()"/>
            <xsl:variable name="filename">
                <xsl:text>P5-Pt1-</xsl:text>
                <xsl:value-of select="tokenize(base-uri(), '/')[last()] ! substring-after(., 'P4-')"
                />
            </xsl:variable>
            <xsl:variable name="chunk" as="xs:string"
                select="tokenize(base-uri(), '/')[last()] ! substring-before(., '.') ! substring-after(., '_')"/>

            <xsl:result-document method="xml" indent="yes" href="P5-Pt1-output/{$filename}">
                <TEI>
                    <xsl:apply-templates select="descendant::teiHeader"/>
                    <text>
                        <body>
                            <xsl:apply-templates select="descendant::div[@type = 'collation']"/>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>

    </xsl:template>
    <xsl:template match="teiHeader">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <xsl:apply-templates select="descendant::titleStmt/title"/>
                </titleStmt>
                <xsl:copy-of select="descendant::publicationStmt"/>
                <xsl:copy-of select="descendant::sourceDesc"/>
            </fileDesc>
        </teiHeader>
    </xsl:template>
    <xsl:template match="titleStmt/title">
        <title>
            <xsl:text>Bridge Phase 5:</xsl:text>
            <xsl:value-of select="tokenize(., ':')[last()]"/>
        </title>
    </xsl:template>

    <xsl:template match="seg">
        <xsl:choose>
            <!--segs with START IDs -->
            <xsl:when test="contains(@xml:id, '_start')">
                <xsl:variable name="startID" as="xs:string"
                    select="substring-before(@xml:id, '_start')"/>
                <xsl:choose>
                    <!--for simple segs with START IDS that have following-sibling ends -->
                    <xsl:when
                        test="following-sibling::seg[1][contains(@xml:id, '_end') and substring-before(@xml:id, '_end') eq $startID]">
                        <seg th:sID="{substring-before(@xml:id, '_start')}"/>
                    </xsl:when>
                    <!--for fragmented segs with START IDs. -->
                    <xsl:when
                        test="not(following-sibling::seg[contains(@xml:id, '_end') and substring-before(@xml:id, '_end') eq $startID])">
                        <seg th:sID="{substring-before(@xml:id, '_start')}__I" part="I"/>
                    </xsl:when>
                </xsl:choose>

            </xsl:when>
            <!--segs with END IDs -->
            <xsl:otherwise>
                <xsl:variable name="endID" as="xs:string" select="substring-before(@xml:id, '_end')"/>
                <xsl:choose>
                    <!--for simple segs where end IDS have a preceding-sibling start ID. -->
                    <xsl:when
                        test="preceding-sibling::seg[contains(@xml:id, '_start') and substring-before(@xml:id, '_start') eq $endID]">
                        <seg th:eID="{substring-before(@xml:id, '_end')}"/>
                    </xsl:when>
                    <!--for fragmented end IDs that don't have a preceding-sibling start ID. -->
                    <xsl:otherwise>
                        <seg th:eID="{substring-before(@xml:id, '_end')}__F" part="F"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
