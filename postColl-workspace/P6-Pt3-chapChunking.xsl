<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
    xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns:fv="https://frankensteinvariorum.github.io" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:var="https://frankensteinvariorum.github.io"
    exclude-result-prefixes="#all" version="3.0">
    <!-- 2023-08-13 ebb with djbpitt: exclude-result-prefixes="#all" removes all the namespaces that simply aren't used. 
        Within the stylesheet we should also use local-name() to output nodes that might come bundled with unwanted namespaces.
    -->
    <!-- 2023-06-01 ebb yxj nlh: This XSLT should output separate chapter files. 
    We have only tried it for the fMS so far, and it is outputting only one file, named with the correct text node, but otherwise systematically excluding its content. AND it is failing by only outputting a single file.
    
    ebb thinks we should proceed by testing the OTHER print editions, and see if that helps us figure out the problem in fMS.
   
    -->
    <xsl:output method="xml" undeclare-prefixes="true" version="1.1"/>
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="*">
        <!-- 2023-06-14 ebb: Adding this to lose the namespaces on the inner elements-->
        <xsl:element name="{local-name()}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:variable name="wholeFiles" as="document-node()+"
        select="collection('P6-Pt2-output/?select=*.xml')"/>

    <xsl:template match="/">
        <xsl:for-each select="$wholeFiles">
            <xsl:variable name="currFile" as="document-node()" select="current()"/>
            <xsl:for-each-group
                select="$currFile//anchor[@type = 'semantic']/following-sibling::node()"
                group-starting-with="anchor[@type = 'semantic']">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <xsl:result-document
                            href="P6-Pt3-output/{$currFile//anchor[@type='semantic'][1]/@xml:id ! replace(., '\W+', '_')}.xml"
                            method="xml" indent="yes">
                            <TEI xmlns:fv="https://frankensteinvariorum.github.io">
                                <teiHeader>
                                    <fileDesc>
                                        <titleStmt>
                                            <title><xsl:value-of
                                                  select="current()/@xml:id ! replace(., '_', ' ')"
                                                /></title>
                                            <principal>Elisa Beshero-Bondar</principal>
                                            <editor>Raffaele Viglianti</editor>
                                            <editor>Yuying Jin</editor>
                                            <respStmt><resp>Assisted in <date>2017-2019</date> by <name>Rikk Mulligan</name>, <name>Scott Weingart</name>, <name>Matthew Lincoln</name>, <name>Jon Klancher</name>, <name>Avery Wiscomb</name> and <name>John Quirk</name> from</resp> <orgName>Carnegie Mellon University.</orgName></respStmt>
                                            <respStmt><resp>Assisted in 2020 - 2023 by <name>Nathan Hammer</name>, <name>Rachel Gerzevske</name>, <name>Jacqueline Chan</name> and <name>Mia Borgia</name> from</resp> <orgName>Penn State Erie: The Behrend College.</orgName></respStmt> 
                                        </titleStmt>
                                        <publicationStmt>
                                            <authority>Frankenstein Variorum Project</authority>
                                            <date>2023—</date>
                                            <availability>
                                                <licence>Distributed under a Creative Commons
                                                  Attribution-ShareAlike 3.0 Unported
                                                  License</licence>
                                            </availability>
                                        </publicationStmt>
                                        <sourceDesc>
                                            <p>This file is developed from a process of collating five distinct editions for
                                                the <title level="m">Frankenstein Variorum</title> digital edition on
                                                  <xsl:value-of select="current-dateTime()"/>.</p>
                                            <p>The <title level="m">Frankenstein Variorum</title> digitally compares five versions of the novel <title level="m">Frankenstein</title> prepared between 1816 and 1831.
                                                <abbr>fMS</abbr> refers to the manuscript notebooks dated roughly 1816 to 1818 and stored in three boxes at the Bodleian library in Oxford.
                                                <abbr>f1818</abbr> refers to the first anonymous publication of Frankenstein in 1818. <abbr>fThomas</abbr> refers to a copy of the 1818 edition left by 
                                                Mary Shelley with her friend Mrs. Thomas in Italy before she left for England after the death of Percy Shelley. This copy contains 
                                                handwritten marginalia indicating edits she would make if there were ever a new edition, and apparently was not available for Mary Shelley to consult later.
                                                <abbr>f1823</abbr> refes to the published edition prepared by William Godwin, the first to feature Mary Wollstonecraft Godwin Shelley’s name as the author. 
                                                <abbr>f1831</abbr> refers to a heavily revised version prepared by Mary Shelley in 1831 for Bentley's Standard Series of novels. 
                                                This edition was bound together in one volume with <bibl><author>Friedrich von Schiller</author>’s <title level="m">The Ghost Seer</title>
                                                </bibl>.
                                            </p>
                                            <listBibl>
                                                <bibl xml:id="fMS"><author>Mary Wollstonecraft Shelley</author>, <title level="m">Frankenstein, or the Modern Prometheus</title>. <edition source="digital">Draft Bodleain MS, Abinger c.56 and c.57</edition> in <title>Shelley-Godwin Archive</title>, ed. <editor>Neil Fraistat</editor>, <editor>Elizabeth Denlinger</editor>, <editor>Raffaele Viglianti</editor>. <date from="2013">2013—present</date>, <ptr target="http://shelleygodwinarchive.org/contents/frankenstein/"/>.</bibl>
                                                <bibl xml:id="f1818"><title level="m">Frankenstein; or, the Modern Prometheus</title>. <edition source="print">In three volumes</edition>, <pubPlace>London</pubPlace>: 
                                                    <publisher>Printed for Lackington, Hughes, Harding, Mavor, &amp; Jones</publisher>, <date when="1818">1818</date>. <edition source="digital">The Pennsylvania Electronic Edition</edition>, ed. <editor>Stuart Curran</editor> and <editor>Jack Lynch</editor>, <date from="1995">1995—present</date>, <ptr target="http://knarf.english.upenn.edu/"/>.</bibl>
                                                <bibl xml:id="fThomas"><title level="m">The Thomas Copy</title>: Marginalia in the form of additions, deletions, and notes hand-written on a single copy of <bibl corresp="#f1818">the 1818 edition</bibl>.</bibl>
                                                <bibl xml:id="f1823"><author>Mary Wollstonecraft Shelley</author>, <title level="m">Frankenstein: or, the Modern Prometheus</title>. <edition>In two volumes</edition>, <pubPlace>London</pubPlace>: <publisher>Printed for G. and W. B. Whittaker</publisher>, <date when="1823">1823</date>.</bibl>
                                                <bibl xml:id="f1831"><author>Mary W. Shelley</author>. <title level="m">Frankenstein: or, the Modern Prometheus</title>. <series>Bentley Standard Novels, No. 9</series>, <pubPlace>London</pubPlace>: 
                                                    <publisher>Henry Colburn and Richard Bentley</publisher>, <date when="1818">1831</date>. <edition source="digital">The Pennsylvania Electronic Edition</edition>, ed. <editor>Stuart Curran</editor> and <editor>Jack Lynch</editor>, <date from="1995">1995—present</date>, <ptr target="http://knarf.english.upenn.edu/"/>.</bibl>
                                            </listBibl>
                                        </sourceDesc>
                                    </fileDesc>
                                </teiHeader>
                                <text>
                                    <body>
                                        <xsl:copy select="$currFile//anchor[@type = 'semantic'][1]"
                                            copy-namespaces="no">
                                            <xsl:copy-of select="@*"/>
                                        </xsl:copy>
                                        <xsl:apply-templates select="current-group()"/>
                                    </body>
                                </text>
                            </TEI>
                        </xsl:result-document>

                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:result-document href="P6-Pt3-output/{current()/@xml:id ! replace(., '\W+', '_')}.xml"
                            method="xml" indent="yes">
                            <xsl:processing-instruction name="xml-model">href="../FV_ODD/out/FV_ODD.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
                            <xsl:processing-instruction name="xml-model"> href="../FV_ODD/out/FV_ODD.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                            <TEI xmlns:fv="https://frankensteinvariorum.github.io">
                                <teiHeader>
                                    <fileDesc>
                                        <titleStmt>
                                            <title>Bridge Phase 6: <xsl:value-of
                                                  select="current()/@xml:id ! replace(., '_', ' ')"/></title>
                                        </titleStmt>
                                        <publicationStmt>
                                            <authority>Frankenstein Variorum Project</authority>
                                            <date>2023—</date>
                                            <availability>
                                                <licence>Distributed under a Creative Commons
                                                  Attribution-ShareAlike 3.0 Unported
                                                  License</licence>
                                            </availability>
                                        </publicationStmt>
                                        <sourceDesc>
                                            <p>Produced from a corpus of collation output files for
                                                the Frankenstein Variorum digital edition on
                                                  <xsl:value-of select="current-dateTime()"/>.</p>
                                        </sourceDesc>
                                    </fileDesc>
                                </teiHeader>
                                <text>
                                    <body>
                                        <xsl:apply-templates select="current-group()"/>
                                    </body>
                                </text>
                            </TEI>
                        </xsl:result-document>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="teiHeader"/>
    
    <xsl:template match="add|del|note">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*" />
           <xsl:if test="preceding::pb"> 
               <xsl:attribute name="n">
                <xsl:value-of select="preceding::pb[1]/@n"/> 
            </xsl:attribute>
           </xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
