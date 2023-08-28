<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fv="https://github.com/FrankensteinVariorum"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs tei"
    version="3.0">
    <!--2023-08-27 ebb: Updating this to clean out unnecessary namespaces in the spine output files at the end of the pipeline,
        and to add ODD-generated schema lines to the standOff spine files.
        
        2018-10-24 updated 2019-03-16 and 2019-07-03 ebb: This stylesheet maps the maximum Levenshtein distance value for each app onto the spine files. 
        Run this over FV_LevDists-weighted.xml (the XML generated by the Python script that calculates Levenshtein distances at each app location and stores them in feature structures.) 
        
        OLD Note: We may or may not wish to run the LevWeight-Simplification.xsl beforehand (which would remove comparisons with "0" at gap or cut locations where one or more witnesses are not present). 
        My former thinking was that we should *not* run this because omissions are an important source of variance.
        2019-07-03: My current thinking on this IS that we SHOULD run it because we are seeing spurious comparisons where there are only two reading groups and all witnesses are present. 
        So I'm now running it. 
    -->
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="spineColl" as="document-node()+"
        select="collection('preLev_standoff_Spine/?select=*.xml')"/>
    <xsl:variable name="FS_Levs" as="document-node()"
        select="doc('edit-distance/FV_LevDists-simplified.xml')"/> <!-- 2023-06-26 yxj: run simplifed one. -->

    <xsl:template match="/">
        <xsl:for-each select="$spineColl//tei:TEI">
            <xsl:variable name="filename" as="xs:string"
                select="tokenize(current()/base-uri(), '/')[last()]"/>
            <xsl:result-document method="xml" indent="yes" href="standoff_Spine/{$filename}">
                <xsl:processing-instruction name="xml-model">href="../FV_ODD/out/FV_ODD.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
                <xsl:processing-instruction name="xml-model"> href="../FV_ODD/out/FV_ODD.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>
                <TEI>
                    <xsl:apply-templates/>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="tei:app">
        <xsl:choose>
            <xsl:when test="tei:rdgGrp[contains(@xml:id, 'empty')] and count(tei:rdgGrp) = 2">
                <app xml:id="{@xml:id}" n="1">
                    <xsl:apply-templates/>
                </app>
            </xsl:when>
         <xsl:otherwise>
             <app xml:id="{@xml:id}" n="{$FS_Levs//fs[@feats=current()/@xml:id]/f/@fVal => max()}">
            <xsl:apply-templates/>
        </app></xsl:otherwise>
        
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
