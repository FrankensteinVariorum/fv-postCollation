<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:fv="https://github.com/FrankensteinVariorum"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
     exclude-result-prefixes="xs"
    version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:variable name="spineColl" as="document-node()+"
        select="collection('early_standoff_Spine/?select=*.xml')"/>
    <!--2023-07-14 ebb: This XSLT is for patching and updating the spine structure. At this stage we are:
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
                                <title>Spine: Collation unit C07</title>
                                <principal>Elisa Beshero-Bondar</principal>
                                <editor>Raffaele Viglianti</editor>
                                <editor>Yuying Jin</editor>
                                <respStmt><resp>Assisted in <date>2017-2019</date> by <name>Rikk Mulligan</name>, <name>Scott Weingart</name>, <name>Matthew Lincoln</name>, <name>Jon Klancher</name>, <name>Avery Wiscomb</name>, and <name>John Quirk</name> from</resp> <orgName>Carnegie Mellon University.</orgName></respStmt>
                                <respStmt><resp>Assisted in 2020 - 2023 by <name>Nathan Hammer</name>, <name>Rachel Gerzevske</name>, <name>Jacqueline Chan</name> and <name>Mia Borgia</name> from</resp> <orgName>Penn State Erie: The Behrend College.</orgName></respStmt>
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
                                <p>This <title level="m">Frankenstein Variorum</title> digitally compares five versions of the novel <title level="m">Frankenstein</title> prepared between 1816 and 1831.
                                <abbr>fMS</abbr> refers to the manuscript notebooks dated roughly 1816 to 1818 and stored in three boxes at the Bodleian library in Oxford, of which our collation represents the material in boxes c56 and c57, representing most of the novel with some gaps.
                                    <abbr>f1818</abbr> refers to the first anonymous publication of Frankenstein in 1818. <abbr>fThomas</abbr> refers to a copy of the 1818 edition left by 
                                    Mary Shelley with her friend Mrs. Thomas in Italy before she left for England after the death of Percy Shelley. This copy contains 
                                    handwritten marginalia indicating edits she would make if there were ever a new edition, and apparently was not available for Mary Shelley to consult later.
                                    <abbr>f1823</abbr> refes to the published edition prepared by William Godwin, the first to feature Mary Wollstonecraft Godwin Shelley’s name as the author. 
                                    <abbr>f1831</abbr> refers to a heavily revised version prepared by Mary Shelley in 1831 for Bentley’s Standard series of novels. 
                                    This edition was bound together in one volume with <bibl><author>Friedrich von Schiller</author>’s <title level="m">The Ghost Seer</title></bibl>.
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
                                    forms. For example, it allows for TEI <q>surface-and-zone</q> markup of paragraphs in
                                    <gi>milestone</gi> elements to be normalized as identical with <gi>p</gi> elements
                                    used in other editions. We have developed a very complex, lengthy series of
                                    normalizations in <ref target="https://github.com/FrankensteinVariorum/collationWorkspace/blob/main/python-collation/collate.py">our Python script</ref> to prepare our digital edition files for collation.
                                    <!--ebb: documented on our website or Jupyter notebook?: provide link here -->
                                   The <q>spine</q> files reveal the normalized strings in order to share the comparison data we rely on for our
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
                                <xsl:apply-templates select=".//sourceDesc/*"/>
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
                                <prefixDef ident="sga" matchPattern="(c\d+/#/p\d+)"
                                    replacementPattern="https://shelleygodwinarchive.org/sc/oxford/ms_abinger/$1">
                                    <p>For example, sga:c57/#/p73 resolves to the URL <ref
                                        target="https://shelleygodwinarchive.org/sc/oxford/ms_abinger/c57/#/p73"
                                        >https://shelleygodwinarchive.org/sc/oxford/ms_abinger/c57/#/p73</ref> linking to 
                                        the webpage that represents page 73 in box 57 of the Oxford Abinger notebooks.</p>
                                </prefixDef>
                            </listPrefixDef>
                        </encodingDesc>
                    </teiHeader>
                  <xsl:apply-templates select="descendant::text"/>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
        <!--</xsl:for-each-group>-->
        
    </xsl:template>
    <xsl:template match="teiHeader"/>
   
   <xsl:template match="ab">
       <listApp>
           <xsl:apply-templates/>
       </listApp>
   </xsl:template>
    
    <xsl:template match="witDetail">
        <xsl:variable name="currentNode" as="element()" select="current()"/>
        <!-- 2024-07-14 ebb: Here we add information for pointing links to the S-GA web page -->
        <xsl:variable name="box-pages" as="xs:string*" select="(for $i in ptr/@target ! tokenize(., 'c\d{2}/')[last()] return $i ! 
            substring-after(., 'abinger_') ! substring-before(., '.xml')) => distinct-values()"/>
      
        <xsl:variable name="reformatted" as="xs:string*">
            <!--ebb: We are constructing this format:
                sga:c57/#/p73 
            -->
            <xsl:for-each select="$box-pages">
                <xsl:variable name="box" as="xs:string" select="current() ! substring-before(., '-')"/>
                <xsl:variable name="page" as="xs:string" select="current() ! substring-after(., '-') ! xs:integer(.) ! string()"/>
                <xsl:value-of select="('sga:' || $box || '/#/p' || $page)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:element name="witDetail">
            <xsl:copy select="@*"/>
            <xsl:attribute name="target">
                <xsl:value-of select="$reformatted => string-join(' ')"/>
            </xsl:attribute>
            <xsl:for-each select="$box-pages">
                <ref type="page" target="{$currentNode/ptr[contains(@target, current())] ! substring-before(@target, '#') => distinct-values()}">  
                    <xsl:variable name="pageStringRanges" as="element()+" select="$currentNode/ptr[@target ! contains(., current())]"/>
                    <xsl:for-each select="$pageStringRanges">
                        <xsl:copy-of select="current()"/>
                        <xsl:copy-of select="current()/following-sibling::fv:line_text[1]"/>
                        <xsl:copy-of select="current()/following-sibling::fv:resolved_text[1]"/>
                    </xsl:for-each>  
                </ref>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="witDetail/ptr"/>
    <xsl:template match="witDetail/fv:*"/>
    
  
</xsl:stylesheet>
