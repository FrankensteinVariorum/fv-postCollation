<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse"
 
    version="3.0">
    <!-- 2023-08-13 ebb with thanks to djbpitt: I'm refactoring this stylesheet to try the XPath 3 function parse-xml() to:
    * raise a document node around the string content of `//ab/text()` and then parse that as an element tree. 
    This means dropping the complex and brittle series of regular expression matches in `<xsl:analyze-string>` processing.
    -->
    <!-- 2023-08-10 ebb with yxj and nlh: We should not change `<note>`, `<del>` or `<add>` elements in this stage. They will be wholly inside `<seg>` elements and should not interfere with the element raising raising process
    in this pipeline. -->
    <xsl:mode on-no-match="shallow-copy"/><!-- processes in no mode -->
   <!-- <xsl:mode on-no-match="shallow-copy" name="raise"/>--><!-- processes in the named mode -->
    
    <xsl:variable name="tester" as="document-node()" select="doc('P2-output/tester.xml')"/>
    
    
    <xsl:variable name="P2-Coll" as="document-node()+"
        select="collection('P2-output/?select=*.xml')"/>
    <xsl:variable name="testerDoc" as="document-node()" select="doc('P2-output/P2_fThomas_C10.xml')"/>
    <!--In Bridge Construction Phase 3, we are up-converting the text-converted tags in the edition files into self-closed elements.
        We add the th: namespace prefix to "trojan horse" attributes used for markers.-->
    <xsl:template match="/">
        <xsl:for-each select="$P2-Coll">
            <xsl:variable name="currentP2File" as="document-node()" select="current()"/>
            <xsl:variable name="bodyToDoc" as="document-node()">
                <xsl:document>
                    <xsl:apply-templates select="current()//body"/>
                </xsl:document>
            </xsl:variable> 
            <xsl:variable name="filename">
                <xsl:text>P3-</xsl:text>
                <xsl:value-of
                    select="tokenize(base-uri(), '/')[last()] ! tokenize(., 'P2_')[last()]"/>
            </xsl:variable>
        <xsl:variable name="chunk" as="xs:string" select="tokenize($filename, '_')[last()]"/>
            <xsl:result-document method="xml" indent="yes" href="P3-output/{$filename}">
                <TEI xml:id="{current()/TEI/@xml:id}">
                    <xsl:apply-templates select="descendant::teiHeader"/>
                    <text>
                        <body>
                    <xsl:apply-templates select="parse-xml($bodyToDoc)/*"/>
                        </body>
                    </text>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="*[@*[matches(name(), '[se]ID')]]">
        <!-- 2023-08-13 ebb: add the th: namespace prefix to the Trojan horse attributes. -->
        <xsl:element name="{local-name()}">
            <xsl:for-each select="@*[not(matches(name(), '[se]ID'))]">
                <xsl:copy-of select="current()"/>
            </xsl:for-each>
           <xsl:attribute name="th:{@*/name()[matches(., '[se]ID')]}">
               <xsl:value-of select="@*[matches(name(), '[se]ID')]"/>
           </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>        
    </xsl:template>
    <xsl:template match="*[not(contains(name(), 'title'))][not(@*[contains(name(), 'ID')])]">
        <xsl:element name="{local-name()}" xmlns="http://www.tei-c.org/ns/1.0" xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template> 
   <xsl:template match="titleStmt/title">
        <title>
            <xsl:text>Bridge Phase 3: </xsl:text>
            <xsl:value-of select="tokenize(., ':')[last()]"/>
        </title>
    </xsl:template>
</xsl:stylesheet>
