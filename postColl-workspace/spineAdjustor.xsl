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
                            <!--ebb:  REPRESENT THE TEAM. ALSO STAGES OF THE PROJECT -->
                            <publicationStmt>
                                <authority>Frankenstein Variorum Project</authority>
                                <date>2023—</date>
                                <availability>
                                    <licence>Distributed under a Creative Commons
                                        Attribution-ShareAlike 3.0 Unported License</licence>
                                </availability>
                            </publicationStmt>
                            <sourceDesc>
                                <p>This project digitally compares five versions of the novel <title level="m">Frankenstein</title> prepared between 1816 and 1831.
                                <abbr>fMS</abbr> refers to the manuscript notebooks dated roughly 1816 to 1818 and stored in three boxes at the Bodleian library in Oxford.
                                    <abbr>f1818</abbr> refers to the first anonymous publication of Frankenstein in 1818. <abbr>fThomas</abbr> refers to a copy of the 1818 edition left by 
                                    Mary Shelley with her friend Mrs. Thomas in Italy before she left for England after the death of Percy Shelley. This copy contains 
                                    handwritten marginalia indicating edits she would make if there were ever a new edition, and apparently was not available for Mary Shelley to consult later.
                                    <abbr>f1823</abbr> refes to the published edition prepared by William Godwin, the first to feature Mary Wollstonecraft Godwin Shelley’s name as the author. 
                                    <abbr>f1831</abbr> refers to a heavily revised version prepared by Mary Shelley in 1831 for Bentley's Standard Series of novels. 
                                    This edition was bound together in one volume with <bibl>Friedrich von Schiller’s <title level="m">The Ghost Seer</title></bibl>.
                                </p>
                                <listBibl><!--ebb: PROVIDE DETAILED BIBL ENTRIES HERE FOR EACH EDITION. -->
                                    <bibl></bibl>
                                    <bibl></bibl>
                                    <bibl></bibl>
                                </listBibl>
                            </sourceDesc>
                        </fileDesc>
                        <encodingDesc>
                            <editorialDecl>
                                <p>This is a <q>spine</q> file representing a standoff critical apparatus for one of 33
                                    aligned collation units or <q>chunks</q> that start and end in parallel across five
                                    versions of the novel <title level="m">Frankenstein</title>. It is produced from a
                                    machine-assisted process working with the collation software collateX, but our output
                                    is not standard. CollateX calculates alignments and variations based on dividing
                                    documents into tokens based on words or characters, and it allows for its adapters to
                                    develop a normalization algorithm, to indicate that some strings, like <q>&amp;</q>
                                    should be read as <q>and</q> by the software. The normalization mechanism afforded by
                                    collateX permits us to compare markup of chapter and paragraph boundaries in simpler
                                    forms. For example, it allows for TEI surface-and-zone markup of paragraphs in
                                    <gi>milestone</gi> elements to be normalized as identical with <gi>p</gi> elements
                                    used in other editions. We have developed a very complex, lengthy series of
                                    normalizations
                                    <!--ebb: documented on our website or Jupyter notebook?: provide link here -->, and
                                    we want to expose them in our TEI representation of the comparison data in our
                                    project.</p>
                                <p>Our output of this spine file is not standard for collateX because we are
                                    purposefully sharing an array of normalized tokens in an <att>n</att> attribute on
                                    each <gi>rdgGrp</gi> element. This allows us to indicate the basis on which the
                                    witnesses align when they are frequently not identical character-by-character. We are
                                    grateful to David J. Birnbaum in his role as a member of the collateX team for
                                    assisting us by locally editing the collateX 1.7.1 Python library for our project to
                                    expose the normalized tokens in our TEI Variorum Spine files.</p>
                                <p>Additionally, we developed a post-collation processing pipeline with XSLT and Python
                                    to to calculate Levenshtein (or edit-distance) values for each pair-wise comparison
                                    possible at each moment of variation represented in a <gi>app</gi>, and we output the
                                    maximum of these values in the <att>n</att> attribute on each <gi>app</gi>
                                    element.</p>
                                <xsl:apply-templates select=".//sourceDesc"/>
                            </editorialDecl>
                            <appInfo>
                                <application ident="collateX" version="1.7.1">
                                    <label>collateX</label>
                                </application>
                            </appInfo>
                            <listPrefixDef>
                                <desc>When the manuscript notebook witness shows content, the <gi>witDetail</gi> element
                                    includes a <att>target</att> attribute that can be used to construct links to the
                                    Shelley-Godwin Archive website display of the particular page on which this appears.
                                    We also provide links directly to the XML documents together with XPath and
                                    string-range data that should point to the specirfic location in the Shelley-Godwin
                                    Archive TEI for this page. The prefixDef below indicates how to construct the links: </desc>
                                <prefixDef ident="s-ga" matchPattern="(c\d+/#/p\d+)"
                                    replacementPattern="https://shelleygodwinarchive.org/sc/oxford/ms_abinger/$1">
                                    <p>For example, s-ga:c57/#/p73 resolves to the URL <ref
                                        target="https://shelleygodwinarchive.org/sc/oxford/ms_abinger/c57/#/p73"
                                        >https://shelleygodwinarchive.org/sc/oxford/ms_abinger/c57/#/p73</ref> linking to 
                                        the webpage that represents page 73 in box 57 of the Oxford Abinger notebooks.</p>
                                </prefixDef>
                            </listPrefixDef>
                        </encodingDesc>
                    </teiHeader>
                    <text>
                        <body>
                            <listApp><!-- 2024-07-14 ebb: Ensure that we have replaced ab with listApp. 
                                NOTE: I just rewrote the P1 XSLT to do this. --> 
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
    
    <xsl:template match="witDetail">
        <!-- 2024-07-14 ebb: Here we add information for pointing links to the S-GA web page -->
        <!--NOTE: THERE WILL BE MULTIPLE OF THESE PAGES SOMETIMES... -->
        <xsl:variable name="box-page" select="ptr/@target ! tokenize(., 'c\d{2}/')[last()] ! 
            substring-after(., 'abinger_') ! substring-before(., '.xml')"/>
        <xsl:variable name="box" select="$box-page ! substring-before(., '-')"/>
        <xsl:variable name="page" select="$box-page ! substring-after(., '-') ! xs:integer(.)"/>
        <witDetail wit="{@wit}" target="s-ga:{$box}/#/p{$page}">
            <!-- s-ga:c57/#/p73 -->
        
        
    </xsl:template>

</xsl:stylesheet>
