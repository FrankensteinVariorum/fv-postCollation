<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:pitt="https://github.com/ebeshero/Pittsburgh_Frankenstein"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mith="http://mith.umd.edu/sc/ns1#"
    xmlns:th="http://www.blackmesatech.com/2017/nss/trojan-horse" exclude-result-prefixes="xs"
    version="3.0">
    
    <!-- 2023-08-10 ebb with yxj and nlh: We should not change `<note>`, `<del>` or `<add>` elements in this stage. They will be wholly inside `<seg>` elements and should not interfere with the element raising raising process
    in this pipeline. -->
    <xsl:mode on-no-match="shallow-copy"/><!-- processes in no mode -->
    <xsl:mode on-no-match="shallow-copy" name="raise"/><!-- processes in the named mode -->
    <xsl:variable name="P2-Coll" as="document-node()+"
        select="collection('P2-output/?select=*.xml')"/>
    <xsl:variable name="testerDoc" as="document-node()" select="doc('P2-output/P2_fThomas_C10.xml')"/>
    <!--In Bridge Construction Phase 3, we are up-converting the text-converted tags in the edition files into self-closed elements. We add the th: namespace prefix to "trojan horse" attributes used for markers.-->
    <xsl:template match="/">
        <xsl:for-each select="$P2-Coll//TEI">
            <xsl:variable name="currentP2File" as="element()" select="current()"/>
            <xsl:variable name="filename">
                <xsl:text>P3-</xsl:text>
                <xsl:value-of
                    select="tokenize(base-uri(), '/')[last()] ! tokenize(., 'P2_')[last()]"/>
            </xsl:variable>
            <xsl:variable name="chunk" as="xs:string" select="tokenize($filename, '_')[last()]"/>
            <xsl:result-document method="xml" indent="yes" href="P3-output/{$filename}">
                <TEI>
                    <xsl:apply-templates/>
                </TEI>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:template match="titleStmt/title">
        <title>
            <xsl:text>Bridge Phase 3: </xsl:text>
            <xsl:value-of select="tokenize(., ':')[last()]"/>
        </title>
    </xsl:template>
    <xsl:template match="ab">
        <!--2018-06-22: ebb: We can't use <ab> for top-level structures once we start regenerating <p> elements, since <ab> isn't allowed to contain <p>. -->
        <div type="collation" xml:id="{@xml:id}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="ab/text()">
        <xsl:analyze-string select="." regex="&lt;([^/&lt;&gt;\s]+?)(\s*[^/]*?)&gt;(.*?)&lt;/\s*\1\s*&gt;">
            <!--a whole unflattened element (left as a whole element with text or mixed content prior to collation.).-->
            <!-- 2023-08-10 ebb: FIND A WAY TO KEEP NOTE, ADD, AND DEL WHOLE UNFLATTENED ELEMENTS
            2023-08-13: 
            Looking at the remains of these elements in the P6-Pt3 output, I think all could perhaps safely be left whole at this stage now.
            -->
            <xsl:matching-substring>
               <!-- <xsl:variable name="startTagContents"
                    select="regex-group(1)regex-group(2)"/>-->
                <xsl:element name="{regex-group(1)}">
                   <!-- <xsl:attribute name="ana">
                        <xsl:text>start</xsl:text>
                    </xsl:attribute>-->
                    <xsl:for-each
                        select="tokenize(regex-group(2), ' ')[contains(., '=')]">
                        <xsl:attribute name="{substring-before(current(), '=')}">
                            <xsl:value-of
                                select="substring-after(current(), '=&#34;') ! substring-before(., '&#34;')"
                            />
                        </xsl:attribute>
                    </xsl:for-each>
                    <!--ANALYZE THE ELEMENT CONTENTS for ADD-INNER, DEL-INNER, ETC. -->
                    <xsl:analyze-string select="regex-group(3)" regex="&lt;([^/&lt;&gt;\s]+?)(\s*[^/]*?)&gt;(.+?)&lt;/\s*\1\s*&gt;">
                        <xsl:matching-substring>
                            <xsl:element name="{regex-group(1)}">
                                <xsl:for-each
                                    select="tokenize(regex-group(2), ' ')[contains(., '=')]">
                                    <xsl:attribute name="{substring-before(current(), '=')}">
                                        <xsl:value-of
                                            select="substring-after(current(), '=&#34;') ! substring-before(., '&#34;')"
                                        />
                                    </xsl:attribute>
                                </xsl:for-each>
                            
                            <xsl:value-of select="regex-group(3)"/>
                            </xsl:element>
                        </xsl:matching-substring>
                        <xsl:non-matching-substring><!--NOW, ANALYZE THE ELEMENT CONTENTS FOR FLATTENED sID and eID ELEMENTS -->
                            <xsl:analyze-string select="." regex="&lt;([^/\s/&lt;&gt;]+?)\s+([^/&gt;]*?[es]ID=[^/&lt;&gt;]+?)/&gt;">
                            <xsl:matching-substring>
                                <xsl:element name="{regex-group(1)}">
                                    <xsl:for-each
                                        select="tokenize(regex-group(2), ' ')[contains(., '=')]">
                                        <xsl:variable name="attName" as="xs:string">
                                            <xsl:choose>
                                                <xsl:when test="matches(current(), '[se]ID')">
                                                    <xsl:value-of
                                                        select="concat('th:', substring-before(current(), '='))"
                                                    />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of
                                                        select="substring-before(current(), '=')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:attribute name="{$attName}">
                                            <xsl:value-of
                                                select="substring-after(current(), '=&#34;') ! substring-before(., '&#34;')"
                                            />
                                        </xsl:attribute>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:matching-substring>
                                <xsl:non-matching-substring>
                                    <xsl:analyze-string select="." regex="&lt;[^/]*\n*[^/]+?/&gt;">
                                        <!--matches text strings representing self-closed elements (the milestone elements and such like). -->
                                        <xsl:matching-substring>
                                            <xsl:variable name="flattenedTagContents"
                                                select="substring-after(., '&lt;') ! substring-before(., '/&gt;')"/>
                                            
                                            <xsl:variable name="elementName"
                                                select="tokenize($flattenedTagContents, '\s+')[1]"/>
                                            <xsl:element name="{$elementName}">
                                                <xsl:variable name="attributeString"
                                                    select="string-join(tokenize($flattenedTagContents, '\s+')[position() gt 1], ' ')"/>
                                                
                                                <xsl:for-each select="tokenize($attributeString, '\s+')">
                                                    <xsl:variable name="attributeStringToken"
                                                        select="current()"/>
                                                    <xsl:variable name="attName"
                                                        select="substring-before(current(), '=&#34;')"/>
                                                    <xsl:variable name="attValue"
                                                        select="substring-after(current(), '=')"/>
                                                    <xsl:attribute name="{$attName}">
                                                        <xsl:value-of
                                                            select="substring-after($attValue, '&#34;') ! substring-before(., '&#34;')"
                                                        />
                                                    </xsl:attribute>
                                                </xsl:for-each>
                                            </xsl:element>
                                        </xsl:matching-substring>
                                        <xsl:non-matching-substring>
                                            <xsl:value-of select="."/>
                                        </xsl:non-matching-substring>
                                    </xsl:analyze-string>
                               </xsl:non-matching-substring>  
                            </xsl:analyze-string>
                        </xsl:non-matching-substring>
 
                    </xsl:analyze-string>
                    
                </xsl:element>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
               <!-- <xsl:analyze-string select="." regex="&lt;/[^/&amp;]+?&gt;">
                    <!-\-an end tag of an unflattened element-\->
                    <xsl:matching-substring>
                        <xsl:variable name="tagContents"
                            select="substring-after(., '&lt;/') ! substring-before(., '&gt;')"/>
                        <xsl:element name="{tokenize($tagContents, ' ')[1]}">
                            <xsl:attribute name="ana">
                                <xsl:text>end</xsl:text>
                            </xsl:attribute>
                        </xsl:element>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>-->
                <xsl:analyze-string select="." regex="&lt;([^/\s/&lt;&gt;]+?)\s+([^/&gt;]*?[es]ID=[^/&lt;&gt;]+?)/&gt;">
                            <!--matches strings representing flattened element tags marked with sID and eID attributes. -->
                            <xsl:matching-substring>
                                <!--<xsl:variable name="flattenedTagContents"
                                    select="substring-before(., '/') ! substring-after(., '&lt;')"/>-->
                               
                                <!--<xsl:message>Flattened Tag Contents: <xsl:value-of
                                        select="$flattenedTagContents"/></xsl:message>-->
                                <xsl:element name="{regex-group(1)}">
                                    <xsl:for-each
                                        select="tokenize(regex-group(2), ' ')[contains(., '=')]">
                                        <xsl:variable name="attName" as="xs:string">
                                            <xsl:choose>
                                                <xsl:when test="matches(current(), '[se]ID')">
                                                  <xsl:value-of
                                                  select="concat('th:', substring-before(current(), '='))"
                                                  />
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="substring-before(current(), '=')"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <xsl:attribute name="{$attName}">
                                            <xsl:value-of
                                                select="substring-after(current(), '=&#34;') ! substring-before(., '&#34;')"
                                            />
                                        </xsl:attribute>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:matching-substring>
                            <xsl:non-matching-substring>
                                <xsl:analyze-string select="." regex="&lt;[^/]*\n*[^/]+?/&gt;">
                                    <!--matches text strings representing self-closed elements (the milestone elements and such like). -->
                                    <xsl:matching-substring>
                                        <xsl:variable name="flattenedTagContents"
                                            select="substring-after(., '&lt;') ! substring-before(., '/&gt;')"/>

                                        <xsl:variable name="elementName"
                                            select="tokenize($flattenedTagContents, '\s+')[1]"/>
                                        <xsl:element name="{$elementName}">
                                            <xsl:variable name="attributeString"
                                                select="string-join(tokenize($flattenedTagContents, '\s+')[position() gt 1], ' ')"/>

                                            <xsl:for-each select="tokenize($attributeString, '\s+')">
                                                <xsl:variable name="attributeStringToken"
                                                  select="current()"/>
                                                <xsl:variable name="attName"
                                                  select="substring-before(current(), '=&#34;')"/>
                                                <xsl:variable name="attValue"
                                                  select="substring-after(current(), '=')"/>
                                                <xsl:attribute name="{$attName}">
                                                  <xsl:value-of
                                                  select="substring-after($attValue, '&#34;') ! substring-before(., '&#34;')"
                                                  />
                                                </xsl:attribute>
                                            </xsl:for-each>
                                        </xsl:element>
                                    </xsl:matching-substring>
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="."/>
                                    </xsl:non-matching-substring>
                                </xsl:analyze-string>
                            </xsl:non-matching-substring>
                        </xsl:analyze-string>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
         
 
    </xsl:template>
</xsl:stylesheet>
