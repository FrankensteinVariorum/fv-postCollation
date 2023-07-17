<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:var="https://frankensteinvariorum.github.io" exclude-result-prefixes="xs" version="3.0">
  <!--2023-06-14 ebb: In order to convert the collated edition files into something we can cut into chapters and letters, we will:
    1. flatten their TEI Corpus structures into a single TEI file, and 
    2. Raise chapter / semantic unit anchor elements at the same hierarchy level so these can be addressed as siblings with xsl:for-each-group. 
    
    We're currently following the 2018 protocol so that this XSLT adds a tei: prefixed namespace in addition to the default namesapce to our output variorum edition files 
    to support use of xml pointers in the Variorum edition. However, we're also actively outputting the TEI namespace this time,
    together with the tei: prefixed namespace so both really *are* available this time, and this (properly!) raises validation 
    errors in the TEI until we associate a customized ODD-generated Relax NG schema. 
  
  -->

  <xsl:mode on-no-match="shallow-copy"/>

  <xsl:variable name="P6-Pt1" as="document-node()+"
    select="collection('P6-Pt1-output/?select=*.xml')"/>

  <xsl:function name="var:volumeFinder" as="xs:string?">
    <xsl:param name="witness"/>
    <xsl:param name="chapterMarker"/>
    <!-- 2023-06-13 ebb: This must change when we have the whole edition. For right now.we're just processing collation units in the middle, so we 
            have to extrapolate the information for vol 1 of 1818 (in 3 vols) and vol 1 of 1823 (in 2 vols). 1831 is complete in one volume.
            fMS has boxes C56 and C57 as a mostly complete witness that we are collating. 
            -->
    <xsl:choose>
      <xsl:when test="not($witness = 'f1831') and not($witness = 'fMS')">
        <!-- Print editions other than 1831 -->
        <xsl:choose>
          <xsl:when test="$chapterMarker/preceding::tei:milestone[@unit = 'volume'][1]">
            <xsl:value-of
              select="concat('_vol_', $chapterMarker/preceding::tei:milestone[@unit = 'volume'][1]/@n)"
            />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>_vol_1</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$witness = 'fMS'">
        <!-- Here we want the Box info, either c56 or c57, to help differentiate the chapters. 
        Get it from the first following lb/@n, substring-before its '-'.
      -->
        <xsl:value-of
          select="concat('_box_', $chapterMarker[1]/following::tei:lb[1]/@n ! substring-before(., '-'))"
        />
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <xsl:template match="/">
    <xsl:for-each select="$P6-Pt1">
      <xsl:variable name="currentEdition" as="document-node()" select="current()"/>
      <xsl:variable name="filename" as="xs:string"
        select="current() ! base-uri() ! tokenize(., '/')[last()]"/>
      <xsl:variable name="witness" as="xs:string" select="$filename ! substring-before(., '.xml')"/>
      <xsl:result-document method="xml" indent="yes" href="P6-Pt2-output/{$filename}">
        <TEI>
          <teiHeader>
            <fileDesc>
              <titleStmt>
                <title>Bridge Phase 6: Witness <xsl:value-of select="$witness"/></title>
              </titleStmt>
              <publicationStmt>
                <authority>Frankenstein Variorum Project</authority>
                <date>2023—</date>
                <availability>
                  <licence>Distributed under a Creative Commons Attribution-ShareAlike 3.0 Unported
                    License</licence>
                </availability>
              </publicationStmt>
              <sourceDesc>
                <p>Produced from a corpus of collation output files for the Frankenstein Variorum
                  digital edition on <xsl:value-of select="current-dateTime()"/>.</p>
              </sourceDesc>
            </fileDesc>
          </teiHeader>
          <text>
            <body>
              <xsl:apply-templates select="descendant::tei:div[@type = 'collation']/node()">
                <xsl:with-param name="witness" as="xs:string" select="$witness"/>
              </xsl:apply-templates>
            </body>
          </text>
        </TEI>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:seg[tei:milestone[@unit = 'chapter' and @type = 'start']]">
    <!--ebb: This template processes Print witness chapter start markers within seg elements. -->
    <xsl:param name="witness"/>
    <xsl:variable name="chapterMarker" as="element()"
      select="tei:milestone[@unit = 'chapter' and @type = 'start']"/>

    <xsl:variable name="vol_info" as="xs:string?">
      <xsl:value-of select="var:volumeFinder($witness, $chapterMarker)"/>
    </xsl:variable>

    <xsl:variable name="chap_id" as="xs:string" select="current()/following::tei:head[1]/following-sibling::text()[1] ! lower-case(.) ! replace(., '[.,:;]', '') ! tokenize(., ' ') => string-join('_')
        "/>
    <xsl:message>Chapter ID: <xsl:value-of select="$chap_id"/></xsl:message>

    <anchor type="semantic" subtype="{tei:milestone/@type}"
      xml:id="{$witness}{$vol_info}_{$chap_id}"/>
    <xsl:copy select="current()">
      <xsl:copy-of select="current()/@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:div/tei:milestone[@unit = 'chapter' and @type = 'start']">
    <!--ebb: This template processes top-level Print witness chapter start markers, nested as a child of the div[@type='collate'] element. -->
    <xsl:param name="witness"/>
    <xsl:variable name="chapterMarker" as="element()" select="current()"/>
    <xsl:variable name="vol_info" as="xs:string?">
      <xsl:value-of select="var:volumeFinder($witness, $chapterMarker)"/>
    </xsl:variable>
    <xsl:variable name="chap_id" as="xs:string" select="
        following::tei:head[1]/following-sibling::text()[1] ! lower-case(.) ! replace(., '[.,:;]', '') ! tokenize(., ' ') => string-join('_')
        "/>
    <anchor type="semantic" subtype="{@type}" xml:id="{$witness}{$vol_info}_{$chap_id}"/>
    <xsl:copy select="current()">
      <xsl:copy-of select="@*"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="tei:seg[tei:milestone[@spanTo and @unit = 'tei:head']]">
    <!--ebb: This template processes fMS chapter start markers in seg elements  -->
    <xsl:param name="witness"/>
    <xsl:variable name="chapterMarker" as="element()+" select="tei:milestone[@spanTo]"/>

    <xsl:variable name="vol_info" as="xs:string?">
      <xsl:value-of select="var:volumeFinder($witness, $chapterMarker)"/>
    </xsl:variable>
    <xsl:variable name="chap_id" as="xs:string"
      select="$chapterMarker/following::text()[matches(., '\w+')][1] ! lower-case(.) ! replace(., '^\s+', '') ! replace(., '[.,:;]', '') ! replace(., '\s+$', '') ! tokenize(., '\s+') => string-join('_')"/>
    <anchor type="semantic" subtype="start" xml:id="{$witness}{$vol_info}_{$chap_id}"/>
    <xsl:copy select="current()">
      <xsl:copy-of select="current()/@*"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="tei:div/tei:milestone[@spanTo and @unit = 'tei:head']">
    <!--ebb: This template processes top-level fMS chapter start markers nested directly in div[@type="collate"] elements.  -->
    <xsl:param name="witness"/>
    <xsl:variable name="chapterMarker" as="element()" select="current()"/>
    <xsl:variable name="vol_info" as="xs:string?">
      <xsl:value-of select="var:volumeFinder($witness, $chapterMarker)"/>
    </xsl:variable>
    <xsl:variable name="chap_id" as="xs:string"
      select="following::text()[matches(., '\w+')][1] ! lower-case(.) ! replace(., '^\s+', '') ! replace(., '[.,:;]', '') ! replace(., '\s+$', '') ! tokenize(., '\s+') => string-join('_')"/>
    <anchor type="semantic" subtype="start" xml:id="{$witness}{$vol_info}_{$chap_id}"/>
    <xsl:copy select="current()">
      <xsl:copy-of select="current()/@*"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="sga-add">
    <!-- ebb: Let's restore <sga-add> to just the TEI <add> element now that the collation is finished. -->
    <add>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates/>
    </add>
  </xsl:template>
</xsl:stylesheet>
