<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../../xslt/common.xsl"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/xhtml:html">
        
        <translation>
            
            <xsl:for-each-group select="//xhtml:section[not(@id = ('titles','imprint','toc','end-notes','bibliography','glossary'))]/descendant::xhtml:*[@data-location-id][not(descendant::*/@data-location-id)]" group-by="@data-location-id">
                <xsl:call-template name="passage">
                    <xsl:with-param name="passage-id" select="@data-location-id"/>
                    <xsl:with-param name="parent-id" select="ancestor::xhtml:section/@id"/>
                    <xsl:with-param name="elements" select="current-group()"/>
                </xsl:call-template>
            </xsl:for-each-group>
            
        </translation>
        
    </xsl:template>
    
    <xsl:template name="passage">
        
        <xsl:param name="passage-id" as="xs:string"/>
        <xsl:param name="parent-id" as="xs:string"/>
        <xsl:param name="elements" as="element()*"/>
        
        <xsl:variable name="gutter" select="($elements/xhtml:div[matches(@class, '(^|\s)gtr(\s|$)')])[1]" as="element(xhtml:div)?"/>
        
        <passage>
            
            <xsl:attribute name="passage-id" select="$passage-id"/>
            <xsl:attribute name="parent-id" select="$parent-id"/>
            <xsl:attribute name="passage-label" select="$gutter/descendant::text()"/>
            
            <xsl:call-template name="content">
                <xsl:with-param name="contents" select="$elements/* except $gutter"/>
            </xsl:call-template>
            
            <!--<xsl:apply-templates select="$elements"/>-->
            
        </passage>
        
    </xsl:template>
    
    <xsl:template name="content">
        
        <xsl:param name="contents" as="element()*"/>
        
        <xsl:for-each select="$contents">
            
            <xsl:variable name="content" select="."/>
            
            <xsl:choose>
                
                <!-- paragraphs -->
                <xsl:when test="$content/self::xhtml:p">
                    
                    <line>
                        
                        <xsl:attribute name="content-type">
                            <xsl:choose>
                                <xsl:when test="matches($content/parent::xhtml:div/@class, '(^|\s)rw\-paragraph(\s|$)')">
                                    <xsl:value-of select="'paragraph'"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="'not-set'"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:attribute>
                        
                        <xsl:if test="$content/parent::xhtml:div/preceding-sibling::*[1][self::xhtml:br]">
                            <xsl:attribute name="space">
                                <xsl:value-of select="'vertical-space'"/>
                            </xsl:attribute>
                        </xsl:if>
                        
                        <value>
                            <xsl:value-of select="eft:content-string($content)"/>
                        </value>
                        
                    </line>
                    
                    <xsl:call-template name="annotations">
                        <xsl:with-param name="content-elements" select="$content/descendant::*"/>
                        <xsl:with-param name="passage-contents" select="$contents"/>
                    </xsl:call-template>
                
                </xsl:when>
                
                <!-- headers -->
                <xsl:when test="$content/self::xhtml:div and matches($content/@class, '(^|\s)heading\-section(\s+(chapter|section))?(\s|$)') and $content/xhtml:header/xhtml:h2">
                    
                    <line>
                        
                        <xsl:attribute name="content-type" select="'section-heading'"/>
                        
                        <xsl:attribute name="section-heading-type" select="replace($content/@class, '.*(^|\s)heading-section(\s+(chapter|section))?(\s|$).*', '$3')"/>
                        
                        <value>
                            <xsl:value-of select="eft:content-string($content)"/>
                        </value>
                        
                    </line>
                    
                    <xsl:call-template name="annotations">
                        <xsl:with-param name="content-elements" select="$content/xhtml:header/xhtml:h2/descendant::*"/>
                        <xsl:with-param name="passage-contents" select="$contents"/>
                    </xsl:call-template>
                    
                </xsl:when>
                
                <!-- Fallback -->
                <xsl:otherwise>
                    <xsl:apply-templates select="$content"/>
                </xsl:otherwise>
                
            </xsl:choose>
        
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:function name="eft:content-string">
        
        <xsl:param name="content" as="element()"/> 
        
        <xsl:variable name="content-strings">
            <xsl:for-each select="$content/descendant::text()">
                <xsl:choose>
                    <xsl:when test="matches(parent::xhtml:a/@class, '(^|\s)footnote\-link(\s|$)')">
                        
                        <xsl:value-of select="concat('[', normalize-space(.), ']')"/>
                        
                    </xsl:when>
                    <xsl:otherwise>
                        
                        <xsl:value-of select="."/>
                        
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
            
        </xsl:variable>
        
        <xsl:value-of select="string-join($content-strings) ! normalize-space()"/>
        
    </xsl:function>
    
    <xsl:template match="xhtml:*">
        <xsl:element name="{ node-name(.)}">
            <xsl:sequence select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="replace(., '\s+', ' ')"/>
    </xsl:template>
    
    <xsl:template name="annotations">
        
        <xsl:param name="content-elements" as="element()*"/>
        <xsl:param name="passage-contents" as="element()*"/>
        
        <xsl:for-each select="$content-elements">
            
            <xsl:variable name="element" select="."/>
            <xsl:variable name="element-name" select="name($element)"/>
            
            <xsl:variable name="annotation-type" as="xs:string">
                
                <xsl:choose>
                    
                    <!-- cite -->
                    <xsl:when test="$element-name eq 'cite'">
                        
                        <xsl:value-of select="'eft:titleRef'"/>

                    </xsl:when>
                    
                    <!-- [data-glossary-id] -->
                    <xsl:when test="$element-name = ('a','span') and $element/@data-glossary-id">
                        
                        <xsl:value-of select="'eft:glossaryTerm'"/>
                        
                    </xsl:when>
                    
                    <!-- a[class='footnote-link'] -->
                    <xsl:when test="$element-name = ('a') and matches($element/@class, '(^|\s)footnote\-link(\s|$)')">
                        
                        <xsl:value-of select="'eft:footnoteRef'"/>
                        
                    </xsl:when>
                    
                    <!-- span[class='small-caps'] -->
                    <xsl:when test="$element-name = ('span') and matches($element/@class, '(^|\s)small-caps(\s|$)')">
                        
                        <xsl:value-of select="'eft:smallcaps'"/>
                        
                    </xsl:when>
                    
                    <!-- span[class='mantra'] -->
                    <xsl:when test="$element-name = ('span') and matches($element/@class, '(^|\s)mantra(\s|$)')">
                        
                        <xsl:value-of select="'eft:mantra'"/>
                        
                    </xsl:when>
                    
                    <!-- span[class='ignore'] -->
                    <xsl:when test="$element-name = ('span') and matches($element/@class, '(^|\s)ignore(\s|$)')">
                        
                        <xsl:value-of select="'eft:notGlossaryMatch'"/>
                        
                    </xsl:when>
                    
                    <!-- em -->
                    <xsl:when test="$element-name = ('em')">
                        
                        <xsl:value-of select="'eft:emphasis'"/>
                        
                    </xsl:when>
                    
                    <!-- Fallback -->
                    <xsl:otherwise>
                        
                        <xsl:value-of select="concat('html:', $element-name)"/>
                        
                    </xsl:otherwise>
                    
                </xsl:choose>
                
            </xsl:variable>
            
            <xsl:variable name="target" as="element()">
                <target>
                    
                    <!-- Does this elements content occur previously in the string? -->
                    <xsl:attribute name="occurrence">
                        <xsl:call-template name="occurrence">
                            <xsl:with-param name="element-texts" select="$element/text()"/>
                            <xsl:with-param name="passage-contents" select="$passage-contents"/>
                        </xsl:call-template>
                    </xsl:attribute>
                    
                    <!-- language -->
                    <xsl:if test="@lang">
                        <xsl:attribute name="language" select="$element/@lang"/>
                    </xsl:if>
                    
                    <!-- target string -->
                    <value>
                        <xsl:value-of select="eft:content-string($element)"/>
                    </value>
                    
                </target>
            </xsl:variable>
            
            <xsl:choose>
                
                <xsl:when test="$annotation-type eq 'eft:glossaryTerm'">
                    
                    <xsl:call-template name="annotation">
                        <xsl:with-param name="annotation-type" select="$annotation-type"/>
                        <xsl:with-param name="target" select="$target"/>
                        <xsl:with-param name="body" as="element()*">
                            <xsl:element name="xmlId">
                                <xsl:value-of select="$element/@data-glossary-id"/>
                            </xsl:element>
                            <xsl:for-each select="$element/@*[not(local-name() = ('lang', 'href', 'class', 'data-glossary-id', 'data-match-mode', 'data-mark-id'))]">
                                <xsl:element name="{ local-name() }">
                                    <xsl:value-of select="string()"/>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </xsl:when>
                
                <xsl:when test="$annotation-type eq 'eft:footnoteRef'">
                    
                    <xsl:call-template name="annotation">
                        <xsl:with-param name="annotation-type" select="$annotation-type"/>
                        <xsl:with-param name="target" select="$target"/>
                        <xsl:with-param name="body" as="element()*">
                            <xsl:element name="xmlId">
                                <xsl:value-of select="$element/@id"/>
                            </xsl:element>
                            <xsl:for-each select="$element/@*[not(local-name() = ('lang', 'href', 'class', 'type'))]">
                                <xsl:element name="{ local-name() }">
                                    <xsl:value-of select="string()"/>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </xsl:when>
                
                <xsl:when test="$annotation-type = ('eft:titleRef','eft:smallcaps','eft:mantra','eft:emphasis','eft:notGlossaryMatch')">
                    
                    <xsl:call-template name="annotation">
                        <xsl:with-param name="annotation-type" select="$annotation-type"/>
                        <xsl:with-param name="target" select="$target"/>
                        <xsl:with-param name="body" as="element()*">
                            <xsl:if test="$element/@data-reconstructed">
                                <xsl:element name="reconstructed">
                                    <xsl:value-of select="$element/@data-reconstructed"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:for-each select="$element/@*[not(local-name() = ('lang','data-reconstructed', 'class'))]">
                                <xsl:element name="{ local-name() }">
                                    <xsl:value-of select="string()"/>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </xsl:when>
                
                <!-- Fallback -->
                <xsl:otherwise>
                    
                    <xsl:call-template name="annotation">
                        <xsl:with-param name="annotation-type" select="$annotation-type"/>
                        <xsl:with-param name="target" select="$target"/>
                        <xsl:with-param name="body" as="element()*">
                            <xsl:if test="$element/@data-reconstructed">
                                <xsl:element name="reconstructed">
                                    <xsl:value-of select="$element/@data-reconstructed"/>
                                </xsl:element>
                            </xsl:if>
                            <xsl:for-each select="$element/@*[not(local-name() = ('lang','data-reconstructed'))]">
                                <xsl:element name="{ local-name() }">
                                    <xsl:value-of select="string()"/>
                                </xsl:element>
                            </xsl:for-each>
                        </xsl:with-param>
                    </xsl:call-template>
                    
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <xsl:template name="annotation">
        
        <xsl:param name="annotation-type" as="xs:string"/>
        <xsl:param name="target" as="element()"/>
        <xsl:param name="body" as="element()*"/>
        
        <annotation>
            
            <xsl:attribute name="annotationType" select="$annotation-type"/>
            
            <xsl:sequence select="$target"/>
            
            <xsl:if test="$body">
                <body>
                    <xsl:sequence select="$body"/>
                </body>
            </xsl:if>
            
        </annotation>
        
    </xsl:template>
    
    <xsl:template name="occurrence" as="xs:integer">
        
        <xsl:param name="element-texts" as="text()*"/>
        <xsl:param name="passage-contents" as="element()*"/>
        
        <xsl:variable name="element-string" select="string-join($element-texts) ! normalize-space(.)" as="xs:string"/>
        
        <xsl:choose>
            <xsl:when test="$element-string">
                
                <xsl:variable name="contents-string-others" as="xs:string*">
                    <xsl:for-each select="$passage-contents/descendant::text()">
                        <xsl:choose>
                            <xsl:when test="count(. | $element-texts) eq count($element-texts)">
                                <xsl:value-of select="'__target__'"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="."/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:for-each>
                </xsl:variable>
                <xsl:variable name="contents-string-other" select="string-join($contents-string-others) ! normalize-space(.)"/>
                <xsl:variable name="contents-string-other-preceding" select="replace($contents-string-other, '^(.*)__target__(.*)', '$1')"/>
                <xsl:variable name="contents-string-preceding-match-count" select="count(analyze-string($contents-string-other-preceding, common:escape-for-regex($element-string), 'i')//fn:match)"/>
                
                <xsl:value-of select="$contents-string-preceding-match-count + 1"/>
                
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
</xsl:stylesheet>