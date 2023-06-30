<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="P5-Pt2-coll" as="document-node()+"
        select="collection('P5-Pt2-output/?select=*.xml')"/>
    <xsl:variable name="testerFile" as="document-node()"
        select="doc('P5-Pt2-output/P5-f1831_C07.xml')"/>
    <!--2018-10-16 ebb: This XSLT plants medial seg START markers to surround multiple element nodes in between fragmented seg start-pairs and end-pairs  
    -->
    <xsl:template match="/">
        <xsl:for-each select="$P5-Pt2-coll//TEI">
            <xsl:variable name="currentP5File" as="element()" select="current()"/>
            <xsl:variable name="filename" as="xs:string" select="tokenize(base-uri(), '/')[last()] ! replace(., 'Pt2', 'Pt3')"/>
            <xsl:variable name="chunk" as="xs:string"
                select="tokenize(base-uri(), '/')[last()] ! substring-before(., '.') ! substring-after(., '_')"/>
            <!--CHANGE THIS when ready to process full collection -->
            <xsl:result-document method="xml" indent="yes" href="P5-Pt3-output/{$filename}">
                <xsl:processing-instruction name="xml-model">href="../segMarkerTester.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <TEI xmlns="http://www.tei-c.org/ns/1.0"
                    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
                    xmlns:mith="http://mith.umd.edu/sc/ns1#"
                    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse">
                    <xsl:copy-of select="descendant::teiHeader" copy-namespaces="no"/>
                    <text>
                        <body>
                            <xsl:apply-templates select="descendant::div[@type = 'collation']"
                            > </xsl:apply-templates>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template
        match="*[not(self::seg)][not(descendant::*[1][@part = 'F' and @th:sID])][preceding::*[1][@part = 'I' and @th:eID]][not(preceding-sibling::*[1][@part = 'I' and @th:eID])][not(ancestor::*/preceding::*[1][@part = 'I' and substring-before(@th:eID, '__') = current()/preceding::*[1][@part = 'I' and substring-before(@th:eID, '__')]])][following-sibling::*[seg][1][seg[@part = 'F' and substring-before(@th:sID, '__') = substring-before(current()/preceding::*[1][@part = 'I']/@th:eID, '__')]]]">
        <xsl:variable name="matchID" as="xs:string"
            select="preceding::*[1]/@th:eID ! substring-before(., '__')"/>
        <seg part="M" th:sID="{$matchID}__M"/>
        <xsl:copy-of select="."/>
    </xsl:template>
</xsl:stylesheet>
