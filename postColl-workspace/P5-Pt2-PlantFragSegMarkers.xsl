<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="P5-Pt1-coll" as="document-node()+"
        select="collection('P5-Pt1-output/?select=*.xml')"/>
    <xsl:variable name="testerFile" as="document-node()"
        select="doc('P5-Pt1-output/P5-f1831_C07.xml')"/>
    <!--2018-10-10 ebb: Bridge Construction Phase 5b: Here we are dealing with "stranded" or fragmented segs that are in between up-raised elements in the edition files. This XSLT plants medial <seg/> start or end "marker" tags prior to upraising the seg elements.
  2018-10-15: We will need to add medial seg elements where there are multiple element nodes in between start-marker and end-marker pairs. We'll do this in the next stylesheet in the series to avoid ambiguous rule matches. 
    -->
    <xsl:template match="/">
        <xsl:for-each select="$P5-Pt1-coll//TEI">
            <xsl:variable name="currentP5File" as="element()" select="current()"/>
            <xsl:variable name="filename" as="xs:string" select="tokenize(base-uri(), '/')[last()]"/>
            <xsl:variable name="chunk" as="xs:string"
                select="tokenize(base-uri(), '/')[last()] ! substring-before(., '.') ! substring-after(., '_')"/>

            <xsl:result-document method="xml" indent="yes" href="P5-Pt2-output/{$filename}">
                <xsl:processing-instruction name="xml-model">href="../segMarkerTester.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <TEI xmlns="http://www.tei-c.org/ns/1.0"
                    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
                    xmlns:mith="http://mith.umd.edu/sc/ns1#"
                    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse">
                    <xsl:copy-of select="descendant::teiHeader" copy-namespaces="no"/>
                    <text>
                        <body>
                            <xsl:apply-templates select="descendant::div[@type = 'collation']"/>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <!--FRAGMENT PART I SEGs w/ (all start markers without following-sibling end markers) -->
    <xsl:template match="seg[@part = 'I' and @th:sID]">
        <xsl:copy-of select="."/>
        <xsl:variable name="matchID" as="xs:string" select="substring-before(@th:sID, '__')"/>
        <!--End marker for closing part will always be on the following:: axis. -->
        <xsl:copy-of
            select="following-sibling::node()[following::seg[@part = 'F' and substring-before(@th:eID, '__') = $matchID]]"/>
        <seg th:eID="{@th:sID}" part="{@part}"/>
    </xsl:template>
    <!--FRAGMENT PART F (terminal) segs: All end-markers without preceding-sibling start-markers -->
    <xsl:template match="seg[@part = 'F' and @th:eID]">
        <xsl:variable name="matchID" as="xs:string" select="substring-before(@th:eID, '__')"/>
        <!--Starting-part marker will always be on the preceding:: axis. -->
        <seg th:sID="{@th:eID}" part="{@part}"/>
        <xsl:copy-of
            select="preceding-sibling::node()[preceding::seg[@part = 'I' and substring-before(@th:sID, '__') = $matchID]]"/>
        <xsl:copy-of select="."/>
    </xsl:template>

    <!--Suppressing duplicates of copied nodes in the above templates -->
    <!--Suppresses nodes that come after initial start-markers -->
    <xsl:template
        match="node()[preceding-sibling::seg[@part = 'I' and @th:sID] and following::seg[1][@part = 'F'][substring-before(@th:eID, '__') = substring-before(current()/preceding-sibling::seg[1][@part = 'I']/@th:sID, '__')]]"/>
    <!--Suppresses nodes that come before terminal end-markers -->
    <xsl:template
        match="node()[following-sibling::seg[@part = 'F' and @th:eID] and preceding::seg[1][@part = 'I' and substring-before(@th:sID, '__') = substring-before(current()/following-sibling::seg[1][@part = 'F']/@th:eID, '__')]]"
    />
</xsl:stylesheet>
