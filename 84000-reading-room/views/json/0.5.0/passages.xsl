<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:json="http://www.json.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../../xslt/common.xsl"/>
    
    <xsl:param name="api-version" select="'0.5.0'"/>
    <xsl:param name="return-types" select="false()"/>
    
    <xsl:key name="locations" match="xhtml:*[@data-location-id]" use="@data-location-id"/>
    
    <xsl:variable name="passage-types" as="element()*">
        <passage-type parent-type="summary" type="summary" header-type="summaryHeader"/>
        <passage-type parent-type="acknowledgment" type="acknowledgment" header-type="acknowledgmentHeader"/>
        <passage-type parent-type="introduction" type="introduction" header-type="introductionHeader"/>
        <passage-type parent-type="prologue" type="prologue" header-type="prologueHeader"/>
        <passage-type parent-type="prelude" type="prelude" header-type="preludeHeader"/>
        <passage-type parent-type="translation" type="translation" header-type="translationHeader"/>
        <passage-type parent-type="colophon" type="colophon" header-type="colophonHeader"/>
        <passage-type parent-type="abbreviations" type="abbreviations" header-type="abbreviationsHeader"/>
        <passage-type parent-type="appendix" type="appendix" header-type="appendixHeader"/>
        <passage-type parent-type="end-notes" type="end-note" header-type="endnotesHeader"/>
    </xsl:variable>
    
    <xsl:variable name="annotation-types" as="element()*">
        <annotation-type type="leading-space"/>
        <annotation-type type="heading"/>
        <annotation-type type="glossary-instance"/>
        <annotation-type type="end-note"/>
        <annotation-type type="inline-title"/>
        <annotation-type type="foreign"/>
        <annotation-type type="distinct"/>
        <annotation-type type="emphasis"/>
        <annotation-type type="small-caps"/>
        <annotation-type type="link"/>
        <annotation-type type="internal-link"/>
        <annotation-type type="quoted"/>
        <annotation-type type="paragraph"/>
        <annotation-type type="line-group"/>
        <annotation-type type="line-break"/>
        <annotation-type type="mantra"/>
        <annotation-type type="reference"/>
        <annotation-type type="trailer"/>
        <annotation-type type="abbreviation"/>
        <annotation-type type="has-abbreviation"/>
    </xsl:variable>
    
    <xsl:variable name="annotation-content-types" as="element()*">
        <content-type type="glossary_xmlId"/>
        <content-type type="endnote_xmlId"/>
        <content-type type="quote_xmlId"/>
        <content-type type="abbreviation_xmlId"/>
        <content-type type="title"/>
        <content-type type="href"/>
        <content-type type="text"/>
        <content-type type="lang">
            <option value="en"/>
            <option value="sa-LATN"/>
            <option value="bo-LATN"/>
            <option value="pi-LATN"/>
            <option value="zh"/>
        </content-type>
        <content-type type="link-type">
            <option value="pending"/>
        </content-type>
        <content-type type="heading-level">
            <option value="h2"/>
            <option value="h3"/>
            <option value="h4"/>
        </content-type>
        <content-type type="link-text">
            <option value="endnoteIndex"/>
            <option value="passageLabel"/>
        </content-type>
        <content-type type="link-text-pending"/>
    </xsl:variable>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        
        <translation>
            
            <xsl:for-each-group select="descendant::xhtml:*[@data-location-id][not(descendant::*/@data-location-id)]" group-by="@data-location-id">
                
                <xsl:variable name="data-location-id" select="@data-location-id" as="xs:string"/>
                
                <xsl:call-template name="passage">
                    <xsl:with-param name="passage-id" select="$data-location-id"/>
                    <xsl:with-param name="parent-id" select="((ancestor::xhtml:*[@id][@data-location-id ! not(. eq $data-location-id)]/@id)[last()], ancestor::xhtml:section/@id)[1]"/>
                    <xsl:with-param name="parent-type" select="(ancestor::xhtml:section/@data-part-type[not(. = ('section', 'chapter'))], 'translation')[1]"/>
                    <xsl:with-param name="header-type" select="if(@data-head-type) then true() else false()"/>
                </xsl:call-template>
                
            </xsl:for-each-group>
            
        </translation>
        
        <xsl:if test="$return-types">
            <xsl:for-each select="$passage-types">
                <passageTypes type="{ @type }"/>
                <passageTypes type="{ @header-type }"/>
            </xsl:for-each>
            <xsl:for-each select="$annotation-types">
                <passageAnnotationTypes>
                    <xsl:sequence select="@*"/>
                </passageAnnotationTypes>
            </xsl:for-each>
            <xsl:for-each select="$annotation-content-types">
                <annotationContentTypes>
                    <xsl:sequence select="@*"/>
                    <xsl:sequence select="eft:option"/>
                </annotationContentTypes>
            </xsl:for-each>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="passage" as="element()*">
        
        <xsl:param name="passage-id" as="xs:string" required="yes"/>
        <xsl:param name="parent-id" as="xs:string" required="yes"/>
        <xsl:param name="parent-type" as="xs:string" required="yes"/>
        <xsl:param name="header-type" as="xs:boolean" required="yes"/>
        
        <xsl:variable name="passage-root" select="/xhtml:section/descendant::xhtml:*[@data-location-id eq $passage-id][not(ancestor::xhtml:div[@data-location-id eq $passage-id])]"/>
        <xsl:variable name="passage-nodes" select="$passage-root/node()[(ancestor-or-self::*[@data-location-id])[last()][@data-location-id eq $passage-id]]"/>
        <xsl:variable name="gutters" select="$passage-nodes/descendant-or-self::xhtml:div[matches(@class, '(^|\s)gtr(\s|$)')]" as="element(xhtml:div)*"/>
        <xsl:variable name="inbound-quote-links" select="$passage-nodes/descendant-or-self::xhtml:div[matches(@class, '(^|\s)quotes\-inbound(\s|$)')]" as="element(xhtml:div)*"/>
        <xsl:variable name="content-nodes" select="$passage-nodes | $passage-root/preceding-sibling::*[1][self::xhtml:br]"/>
        
        <passage>
            
            <xsl:attribute name="json:array" select="true()"/>
            <xsl:attribute name="xmlId" select="$passage-id"/>
            <xsl:attribute name="parentId" select="$parent-id"/>
            <xsl:attribute name="passageLabel" select="(($gutters)[1]/descendant::text() ! replace(., '­', ''), $passage-root/@data-section-index)[1]"/>
            
            <!-- Root part -->
            <xsl:attribute name="type">
                <xsl:choose>
                    <xsl:when test="$passage-types[@parent-type eq $parent-type] and $header-type">
                        <xsl:value-of select="$passage-types[@parent-type eq $parent-type]/@header-type"/>
                    </xsl:when>
                    <xsl:when test="$passage-types[@parent-type eq $parent-type]">
                        <xsl:value-of select="$passage-types[@parent-type eq $parent-type]/@type"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('unknown:', $parent-type)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            
            <passageSort>
                <xsl:attribute name="json:literal" select="true()"/>
                <xsl:value-of select="common:index-of-node(/xhtml:section//*, ($content-nodes/descendant-or-self::*[normalize-space(string-join(text()))])[1])"/>
            </passageSort>
            
            <content>
                
                <xsl:variable name="text-nodes-padded" as="text()*">
                    <xsl:call-template name="text-nodes-padded">
                        <xsl:with-param name="text-nodes" select="$content-nodes/descendant-or-self::text()"/>
                        <xsl:with-param name="partial" select="false()"/>
                    </xsl:call-template>
                </xsl:variable>
                
                <xsl:call-template name="text-filtered">
                    <xsl:with-param name="text-nodes" select="$text-nodes-padded"/>
                    <xsl:with-param name="exclude-elements" select="$gutters | $inbound-quote-links | $content-nodes/descendant::*[@data-location-id[not(. eq $passage-id)]]"/>
                </xsl:call-template>
                
            </content>
            
        </passage>
        
        <xsl:call-template name="standoff">
            <xsl:with-param name="passage-id" select="$passage-id"/>
            <xsl:with-param name="nodes" select="$content-nodes"/>
            <xsl:with-param name="exclude-elements" select="$gutters | $inbound-quote-links | $content-nodes/descendant::*[@data-location-id[not(. eq $passage-id)]]"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <!-- Recurse, compiling annotations -->
    <xsl:template name="standoff" as="element()*">
        
        <xsl:param name="passage-id" as="xs:string" required="yes"/>
        <xsl:param name="nodes" as="node()*" required="yes"/>
        <xsl:param name="node-index" as="xs:integer" select="1"/>
        <xsl:param name="text-nodes" as="text()*"/>
        <xsl:param name="exclude-elements" as="element()*"/>
        
        <xsl:variable name="text-nodes-padded" as="text()*">
            <xsl:call-template name="text-nodes-padded">
                <xsl:with-param name="text-nodes" select="$text-nodes"/>
                <xsl:with-param name="partial" select="true()"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="node" select="$nodes[$node-index]" as="node()?"/>
        
        <xsl:if test="count($exclude-elements | $node) gt count($exclude-elements)">
            
            <xsl:if test="$node instance of element()">
                
                <!-- Return annotation -->
                <xsl:if test="$node[text()] or $node[not(node())]">
                    
                    <xsl:variable name="text-nodes-joined" as="xs:string">
                        <xsl:call-template name="text-filtered">
                            <xsl:with-param name="text-nodes" select="$text-nodes-padded"/>
                            <xsl:with-param name="exclude-elements" select="$exclude-elements"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:variable name="child-text-nodes-joined" as="xs:string">
                        <xsl:call-template name="text-filtered">
                            <xsl:with-param name="text-nodes" select="$node/descendant::text()"/>
                            <xsl:with-param name="exclude-elements" select="$exclude-elements"/>
                        </xsl:call-template>
                    </xsl:variable>
                    
                    <xsl:call-template name="substring-annotation">
                        <xsl:with-param name="passage-id" select="$passage-id"/>
                        <xsl:with-param name="node" select="$node"/>
                        <xsl:with-param name="start" select="string-length($text-nodes-joined)"/>
                        <xsl:with-param name="end" select="string-length($text-nodes-joined) + string-length($child-text-nodes-joined)"/>
                        <xsl:with-param name="has-siblings" select="count(($nodes except $exclude-elements)[not(self::xhtml:br)]) gt 1"/>
                    </xsl:call-template>
                    
                </xsl:if>
                
                <!-- Recurse through child nodes -->
                <xsl:if test="$node/*">
                    <xsl:call-template name="standoff">
                        <xsl:with-param name="passage-id" select="$passage-id"/>
                        <xsl:with-param name="nodes" select="$node/node()"/>
                        <xsl:with-param name="text-nodes" select="$text-nodes"/>
                        <xsl:with-param name="exclude-elements" select="$exclude-elements"/>
                    </xsl:call-template>
                </xsl:if>
                
            </xsl:if>
            
        </xsl:if>
        
        <!-- Recurse to the next node -->
        <xsl:if test="$nodes[$node-index + 1]">
            <xsl:call-template name="standoff">
                <xsl:with-param name="passage-id" select="$passage-id"/>
                <xsl:with-param name="nodes" select="$nodes"/>
                <xsl:with-param name="node-index" select="$node-index + 1"/>
                <xsl:with-param name="text-nodes" select="($text-nodes-padded, $node/descendant-or-self::text())"/>
                <xsl:with-param name="exclude-elements" select="$exclude-elements"/>
            </xsl:call-template>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="substring-annotation" as="element(eft:annotation)*">
        
        <xsl:param name="passage-id" as="xs:string" required="yes"/>
        <xsl:param name="node" as="node()" required="yes"/>
        <xsl:param name="start" as="xs:integer" required="yes"/>
        <xsl:param name="end" as="xs:integer" required="yes"/>
        <xsl:param name="has-siblings" as="xs:boolean" required="yes"/>
        
        <xsl:variable name="tag-name" select="local-name($node)"/>
        
        <xsl:variable name="type" as="xs:string?">
            <xsl:choose>
                <xsl:when test="$tag-name = ('p') and not($has-siblings) and $node[not(@class)]">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name = ('span') and $node[@class eq 'ignore']">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name = ('span') and not($node/@*[not(local-name(.) = ('data-ref'))])">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name = ('br')">
                    <xsl:value-of select="'leading-space'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('h2','h3')">
                    <xsl:value-of select="'heading'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('div','header') and tokenize($node/@class, ' ')[. eq 'h4']">
                    <xsl:value-of select="'heading'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('p') and $node[not(@class)]">
                    <xsl:value-of select="'paragraph'"/>
                </xsl:when>
                <xsl:when test="$node[@data-endnote-id]">
                    <xsl:value-of select="'end-note'"/>
                </xsl:when>
                <xsl:when test="$node[@data-glossary-id]">
                    <xsl:value-of select="'glossary-instance'"/>
                </xsl:when>
                <xsl:when test="$node[@data-quote-id]">
                    <xsl:value-of select="'quoted'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'cite' and tokenize($node/@class, ' ')[. eq 'title']">
                    <xsl:value-of select="'inline-title'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('span', 'p') and tokenize($node/@class, ' ')[. eq 'mantra']">
                    <xsl:value-of select="'mantra'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'a' and $node[matches(@href, '^https?://(read\.)?84000\.co/(translation|source)/')]">
                    <xsl:value-of select="'internal-link'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'span' and $node[matches(@data-href, '^https?://(read\.)?84000\.co/(translation|source)/')]">
                    <xsl:value-of select="'internal-link'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'a' and $node[@href]">
                    <xsl:value-of select="'link'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'p' and tokenize($node/@class, ' ')[. eq 'trailer']">
                    <xsl:value-of select="'trailer'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'em' and tokenize($node/@class, ' ')[. eq 'foreign']">
                    <xsl:value-of select="'foreign'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'em' and tokenize($node/@class, ' ')[. eq 'distinct']">
                    <xsl:value-of select="'distinct'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'em' and tokenize($node/@class, ' ')[. eq 'emph']">
                    <xsl:value-of select="'emphasis'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'span' and tokenize($node/@class, ' ')[. eq 'ref']">
                    <xsl:value-of select="'reference'"/>
                </xsl:when>
                <xsl:when test="$node[@data-href]">
                    <xsl:value-of select="'link'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'div' and tokenize($node/@class, ' ')[. eq 'line']">
                    <xsl:value-of select="'line-break'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'div' and tokenize($node/@class, ' ')[. eq 'line-group']">
                    <xsl:value-of select="'line-group'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'span' and tokenize($node/@class, ' ')[. eq 'small-caps']">
                    <xsl:value-of select="'small-caps'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'th' and $node/parent::xhtml:tr[@data-abbreviation-id]">
                    <xsl:value-of select="'abbreviation'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'td' and $node/parent::xhtml:tr[@data-abbreviation-id]">
                    <xsl:value-of select="'has-abbreviation'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tag-name"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:variable>
        
        <xsl:if test="$type">
            
            <xsl:variable name="content" as="element()*">
                
                <!-- content based on @type -->
                <xsl:if test="tokenize($node/@class, ' ')[. eq 'folio-ref']">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'text'"/>
                        <xsl:with-param name="value" select="string-join($node/descendant::text()) ! replace(., '\s+', ' ') || ''"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'end-note'">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'link-text'"/>
                        <xsl:with-param name="value" select="'endnoteIndex'"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'heading' and $tag-name = ('h2','h3')">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'heading-level'"/>
                        <xsl:with-param name="value" select="$tag-name"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'heading' and tokenize($node/@class, ' ')[. eq 'h4']">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'heading-level'"/>
                        <xsl:with-param name="value" select="'h4'"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type = ('has-abbreviation', 'abbreviation') and $node/parent::xhtml:tr[@data-abbreviation-id]">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'abbreviation_xmlId'"/>
                        <xsl:with-param name="value" select="concat($node/parent::xhtml:tr/@data-abbreviation-id, '/abbreviation')"/>
                    </xsl:call-template>
                </xsl:if>
                
                <!-- content based on attributes -->
                <xsl:for-each select="$node/@*">
                    <xsl:variable name="attribute-name" select="local-name(.)"/>
                    <xsl:variable name="attribute-value" select="string()"/>
                    <xsl:choose>
                        <xsl:when test="$attribute-name = ('id','data-quote-highlight')">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$attribute-name eq 'type' and $attribute-value = ('noteref')">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$attribute-name  = ('target') and $type = ('link','internal-link')">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$attribute-name eq 'data-pointer-type' and $attribute-value eq 'id'">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'link-text'"/>
                                <xsl:with-param name="value" select="'passageLabel'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-name eq 'class'">
                            <xsl:for-each select="tokenize($attribute-value, '\s+')[. gt '']">
                                <xsl:variable name="class-name" select="."/>
                                <xsl:choose>
                                    <xsl:when test="$class-name eq $type">
                                        <!-- Already set as type => exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'inline-title' and $class-name eq 'title'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'internal-link' and $class-name = ('ref', 'folio-ref')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'end-note' and $class-name eq 'footnote-link'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'reference' and $class-name eq 'ref'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'emphasis' and $class-name eq 'emph'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'line-break' and $class-name eq 'line'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'heading' and $class-name = ('section-title', 'h4')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$node[@lang] and $class-name = ('text-en','text-sa','text-bo','text-zh','text-wy','text-pi','break')">
                                        <!-- Already set as lang => exclude -->
                                    </xsl:when>
                                    <xsl:when test="$class-name = ('quoted','matched')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'internal-link' and $class-name eq 'ref-pending'">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'link-type'"/>
                                            <xsl:with-param name="value" select="'pending'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'class'"/>
                                            <xsl:with-param name="value" select="$class-name"/>
                                        </xsl:call-template>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('data-glossary-id')">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'glossary_xmlId'"/>
                                <xsl:with-param name="value" select="$attribute-value"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('href') and matches($attribute-value, '^end\-notes\.xhtml#end\-note')">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('data-endnote-id')">
                            
                            <!--<xsl:variable name="end-note" select="key('locations', $attribute-value, $root)"/>-->
                            
                                <!--<xsl:variable name="end-note-passage">
                                <xsl:call-template name="passage">
                                    <xsl:with-param name="passage-id" select="$attribute-value"/>
                                    <xsl:with-param name="parent-id" select="$passage-id"/>
                                    <xsl:with-param name="parent-type" select="'end-note'"/>
                                    <!-\-<xsl:with-param name="elements" select="$end-note"/>-\->
                                </xsl:call-template>
                            </xsl:variable>
                            
                            <content>
                                <xsl:attribute name="json:array" select="true()"/>
                                <xsl:attribute name="type" select="'end-note'"/>
                                <xsl:attribute name="passage_xmlId" select="$attribute-value"/>
                                <xsl:attribute name="note" select="$end-note-passage/eft:passage/eft:content/text()"/>
                            </content>
                            
                            <!-\- Add annotations from end note -\->
                            <xsl:sequence select="$end-note-passage/eft:annotation"/>-->
                            
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'endnote_xmlId'"/>
                                <xsl:with-param name="value" select="$attribute-value"/>
                            </xsl:call-template>
                            
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('data-quote-id')">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'quote_xmlId'"/>
                                <xsl:with-param name="value" select="$attribute-value"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('data-href','href') and matches($attribute-value, '^https?://(read\.)?84000\.co')">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'href'"/>
                                <xsl:with-param name="value" select="substring-after($attribute-value, '84000.co')"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('data-inst') and $type eq 'internal-link' and tokenize($node/@class, ' ')[. eq 'ref-pending']">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'link-text-pending'"/>
                                <xsl:with-param name="value" select="$attribute-value"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-value gt ''">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="$attribute-name"/>
                                <xsl:with-param name="value" select="$attribute-value"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                </xsl:for-each>
                
            </xsl:variable>
            
            <xsl:choose>
                <xsl:when test="$type = ('line-break')">
                    <xsl:call-template name="annotation">
                        <xsl:with-param name="passage-id" select="$passage-id"/>
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="content" select="$content[self::eft:content]"/>
                        <xsl:with-param name="start" select="$start"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="annotation">
                        <xsl:with-param name="passage-id" select="$passage-id"/>
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="content" select="$content[self::eft:content]"/>
                        <xsl:with-param name="start" select="$start"/>
                        <xsl:with-param name="end" select="$end"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            
            <xsl:sequence select="$content[self::eft:annotation]"/>
            
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template name="annotation" as="element(eft:annotation)">
        
        <xsl:param name="passage-id" as="xs:string" required="yes"/>
        <xsl:param name="type" as="xs:string" required="yes"/>
        <xsl:param name="start" as="xs:integer?"/>
        <xsl:param name="end" as="xs:integer?"/>
        <xsl:param name="content" as="element()*"/>
        
        <annotation>
            
            <xsl:attribute name="passage_xmlId" select="$passage-id"/>
            <xsl:attribute name="type" select="($annotation-types[@type eq $type]/@type, concat('unknown:', $type))[1]"/>
            
            <start>
                <xsl:attribute name="json:literal" select="true()"/>
                <xsl:value-of select="($start, 0)[1]"/>
            </start>
            <end>
                <xsl:attribute name="json:literal" select="true()"/>
                <xsl:value-of select="($end, $start, 0)[1]"/>
            </end>
            
            <xsl:choose>
                <xsl:when test="$content">
                    <xsl:sequence select="$content"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'annotation-content-type-empty'"/>
                        <xsl:with-param name="value" select="''"/>
                    </xsl:call-template>
                </xsl:otherwise>
            </xsl:choose>
            
        </annotation>
    
    </xsl:template>
    
    <xsl:template name="annotation-content" as="element(eft:content)">
        
        <xsl:param name="type" as="xs:string" required="yes"/>
        <xsl:param name="value" as="xs:string" required="yes"/>
        <xsl:variable name="content-type" select="$annotation-content-types[@type eq $type]"/>
        
        <content>
            <xsl:attribute name="json:array" select="true()"/>
            <xsl:choose>
                <xsl:when test="not($type eq 'annotation-content-type-empty')">
                    <xsl:attribute name="{ ($content-type/@type, $type)[1] }" select="($content-type/eft:option[@value eq $value]/@value, $content-type[not(eft:option)] ! $value[. gt ''], concat('unknown:', $value))[1]"/>
                </xsl:when>
            </xsl:choose>
        </content>
        
    </xsl:template>
    
    <xsl:template name="text-nodes-padded" as="text()*">
        
        <xsl:param name="text-nodes" as="text()*"/>
        <xsl:param name="partial" as="xs:boolean"/>
        
        <xsl:for-each select="$text-nodes">
            
            <xsl:variable name="last" as="xs:boolean" select="position() ge count($text-nodes)"/>
            
            <xsl:sequence select="."/>
            
            <!-- Add trailing space -->
            <xsl:choose>
                <xsl:when test="(parent::xhtml:*[parent::xhtml:tr] | parent::xhtml:h2 | parent::xhtml:h3 | parent::xhtml:div[tokenize(@class, ' ')[. eq 'h4']]) and ($partial or not($last))">
                    <xsl:text> </xsl:text>
                </xsl:when>
            </xsl:choose>
            
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="text-filtered" as="xs:string">
        
        <xsl:param name="text-nodes" as="text()*"/>
        <xsl:param name="exclude-elements" as="element()*"/>
        
        <xsl:variable name="text-nodes-included" select="$text-nodes[not(count($exclude-elements | ancestor::*) lt sum((count($exclude-elements), count(ancestor::*))))]" as="text()*"/>
        <xsl:variable name="count-text-nodes-included" select="count($text-nodes-included)"/>
        
        <xsl:variable name="filtered-nodes" as="text()*">
            <xsl:for-each select="$text-nodes-included">
                
                <xsl:variable name="input-node" select="." as="text()"/>
                <xsl:variable name="output-node" select="." as="text()"/>
                <xsl:variable name="text-node-index" select="position()" as="xs:integer"/>
                <xsl:variable name="input-node-preceding" select="$text-nodes-included[$text-node-index - 1]" as="text()?"/>
                
                <xsl:choose>
                    
                    <!-- Exclude content -->
                    <xsl:when test="$input-node/parent::*[tokenize(@class, ' ')[. = ('footnote-link', 'folio-ref')]]">
                        <!-- Exclude -->
                    </xsl:when>
                    
                    <xsl:otherwise>
                        
                        <!-- Remove leading space -->
                        <xsl:variable name="output-node" as="text()?">
                            <xsl:choose>
                                <xsl:when test="$text-node-index eq 1">
                                    <xsl:value-of select="replace($output-node, '^\s+', '')"/>
                                </xsl:when>
                                <xsl:when test="$input-node/preceding-sibling::node()[1]/descendant-or-self::*[last()][tokenize(@class, ' ')[. = ('folio-ref')]]">
                                    <xsl:value-of select="replace($output-node, '^\s+', '')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:sequence select="$output-node"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <!-- Remove trailing space -->
                        <xsl:variable name="output-node" as="text()?">
                            <xsl:choose>
                                <xsl:when test="$text-node-index eq $count-text-nodes-included and ($input-node/parent::xhtml:h2 | $input-node/parent::xhtml:h3)">
                                    <xsl:value-of select="replace($output-node, '\s+$', '')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$output-node"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        
                        <xsl:value-of select="$output-node"/>
                        
                    </xsl:otherwise>
                    
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:value-of select="string-join(($filtered-nodes, '')) ! replace(., '\s+', ' ')"/>
        
    </xsl:template>
    
</xsl:stylesheet>