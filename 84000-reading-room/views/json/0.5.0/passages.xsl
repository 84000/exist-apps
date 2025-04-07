<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:eft="http://read.84000.co/ns/1.0" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:json="http://www.json.org" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="3.1" exclude-result-prefixes="#all">
    
    <xsl:import href="../../../xslt/common.xsl"/>
    
    <xsl:param name="api-version" select="'0.5.0'"/>
    <xsl:param name="return-types" select="false()"/>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
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
        <annotation-type type="inline-title"/>
        <annotation-type type="glossary-instance"/>
        <annotation-type type="end-note-link"/>
        <annotation-type type="link"/>
        <annotation-type type="internal-link"/>
        <annotation-type type="reference"/>
        <annotation-type type="paragraph"/>
        <annotation-type type="span"/>
        <annotation-type type="line-group"/>
        <annotation-type type="line"/>
        <annotation-type type="list"/>
        <annotation-type type="list-item"/>
        <annotation-type type="mantra"/>
        <annotation-type type="blockquote"/>
        <annotation-type type="quote"/>
        <annotation-type type="quoted"/>
        <annotation-type type="trailer"/>
        <annotation-type type="table-body-row"/>
        <annotation-type type="table-body-data"/>
        <annotation-type type="table-body-header"/>
        <annotation-type type="abbreviation"/>
        <annotation-type type="has-abbreviation"/>
        <annotation-type type="code"/>
    </xsl:variable>
    
    <xsl:variable name="annotation-content-types" as="element()*">
        <content-type type="glossary_xmlId"/>
        <content-type type="endnote_xmlId"/>
        <content-type type="quote_xmlId"/>
        <content-type type="abbreviation_xmlId"/>
        <content-type type="href"/>
        <content-type type="quote"/>
        <annotation-type type="nesting"/>
        <content-type type="lang">
            <option value="en"/>
            <option value="bo"/>
            <option value="Bo-Ltn"/>
            <option value="Sa-Ltn"/>
            <option value="Pi-Ltn"/>
            <option value="zh"/>
            <option value="ja"/>
        </content-type>
        <content-type type="text-style">
            <option value="italic"/>
            <option value="text-bold"/>
            <option value="underline"/>
            <option value="line-through"/>
            <option value="small-caps"/>
            <option value="subscript"/>
            <option value="foreign"/>
            <option value="distinct"/>
            <option value="emphasis"/>
        </content-type>
        <content-type type="link-type">
            <option value="pending"/>
            <option value="not-found"/>
        </content-type>
        <content-type type="heading-type">
            <option value="section-title"/>
            <option value="section-label"/>
            <option value="table-label"/>
            <option value="supplementary"/>
        </content-type>
        <content-type type="heading-level">
            <option value="h2"/>
            <option value="h3"/>
            <option value="h4"/>
            <option value="h5"/>
        </content-type>
        <content-type type="link-text"/>
        <content-type type="link-text-lookup">
            <option value="endnoteIndex"/>
            <option value="passageLabel"/>
            <option value="targetTextShortcode"/>
            <option value="quotingTextShortcode"/>
        </content-type>
        <content-type type="link-text-pending"/>
        <content-type type="list-spacing">
            <option value="horizontal"/>
            <option value="vertical"/>
        </content-type>
        <content-type type="list-item-style">
            <option value="dots"/>
            <option value="numbers"/>
            <option value="letters"/>
        </content-type>
        <content-type type="reconstructed">
            <option value="reconstructedPhonetic"/>
            <option value="reconstructedSemantic"/>
        </content-type>
    </xsl:variable>
    
    <xsl:template match="/eft:html-sections">
        
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
        
        <!-- Root passage is the furthest up the tree with this @data-location-id -->
        <xsl:variable name="passage-root" select="/eft:html-sections/xhtml:section/descendant::xhtml:*[@data-location-id eq $passage-id][not(ancestor::xhtml:div[@data-location-id eq $passage-id])]"/>
        <!-- Passage nodes are children of the root that don't have a contradicting @data-location-id -->
        <xsl:variable name="passage-nodes" select="$passage-root/node()[(ancestor-or-self::*[@data-location-id])[last()][@data-location-id eq $passage-id]]"/>
        <!-- Milestone gutter -->
        <xsl:variable name="gutters" select="$passage-nodes/descendant-or-self::xhtml:div[matches(@class, '(^|\s)gtr(\s|$)')]" as="element(xhtml:div)*"/>
        <!-- Inbound quote gutter -->
        <xsl:variable name="inbound-quote-links" select="$passage-nodes/descendant-or-self::xhtml:div[matches(@class, '(^|\s)quotes\-inbound(\s|$)')]" as="element(xhtml:div)*"/>
        <!-- Content nodes are passage nodes plus leading whitespace nodes -->
        <xsl:variable name="content-nodes" select="$passage-nodes | $passage-root/preceding-sibling::*[1][self::xhtml:br]"/>
        <!-- Nodes to ignore when parsing -->
        <xsl:variable name="exclude-elements" select="$gutters | $inbound-quote-links | $content-nodes/descendant::*[@data-location-id[not(. eq $passage-id)]] | $content-nodes/descendant-or-self::*[tokenize(@class, ' ')[. eq 'visible-ebook']]"/>
        
        <!-- Mark-up elements found the content expressed as annotations -->
        <xsl:variable name="standoff" as="element()*">
            <xsl:call-template name="standoff">
                <xsl:with-param name="passage-id" select="$passage-id"/>
                <xsl:with-param name="nodes" select="$content-nodes"/>
                <xsl:with-param name="node-index" select="1"/>
                <xsl:with-param name="node-nesting" select="0"/>
                <xsl:with-param name="exclude-elements" select="$exclude-elements"/>
                <xsl:with-param name="output-string" select="''"/>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:variable name="content" select="string-join($standoff[self::eft:output-string]/text()) ! replace(., '\s+', ' ')" as="xs:string"/>
        
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
            
            <!-- Sort value (integer) to keep passages in the correct order -->
            <passageSort>
                <xsl:attribute name="json:literal" select="true()"/>
                <xsl:value-of select="common:index-of-node(/eft:html-sections/xhtml:section//*, ($content-nodes/descendant-or-self::*[normalize-space(string-join(text()))])[1])"/>
            </passageSort>
            
            <!-- The passage string -->
            <content>
                <xsl:value-of select="$content"/>
            </content>
            
        </passage>
        
        <xsl:sequence select="$standoff[self::eft:annotation]"/>
        
        <xsl:for-each select="$inbound-quote-links/descendant-or-self::xhtml:div[matches(@class, '(^|\s)quotes\-inbound(\s|$)')]/descendant::xhtml:a[@data-quote-id]">
            <xsl:call-template name="substring-annotation">
                <xsl:with-param name="passage-id" select="$passage-id"/>
                <xsl:with-param name="node" select="."/>
                <xsl:with-param name="start" select="1"/>
                <xsl:with-param name="end" select="string-length($content) + 1"/>
                <xsl:with-param name="has-siblings" select="false()"/>
            </xsl:call-template>
        </xsl:for-each>
        
    </xsl:template>
    
    <!-- Recurse through nodes, compiling annotations -->
    <xsl:template name="standoff" as="element()*">
        
        <xsl:param name="passage-id" as="xs:string" required="yes"/>
        <xsl:param name="nodes" as="node()*" required="yes"/>
        <xsl:param name="node-index" as="xs:integer" required="yes"/>
        <xsl:param name="node-nesting" as="xs:integer" required="yes"/>
        <xsl:param name="exclude-elements" as="element()*" required="yes"/>
        <xsl:param name="output-string" as="xs:string" required="yes"/>
        
        <xsl:variable name="node" select="$nodes[$node-index]" as="node()?"/>
        <xsl:variable name="exclude-elements-count" select="count($exclude-elements)" as="xs:integer"/>
        
        <xsl:variable name="standoff" as="element()*">
            
            <xsl:if test="count($exclude-elements | $node) gt $exclude-elements-count">
                
                <xsl:choose>
                    <xsl:when test="$node instance of element()">
                        
                        <!-- Recurse through child nodes -->
                        <xsl:variable name="children-standoff" as="element()*">
                            <xsl:if test="$node[node()] and not($node[tokenize(@class, ' ')[. = ('footnote-link', 'folio-ref', 'quote-link')]])">
                                <xsl:call-template name="standoff">
                                    <xsl:with-param name="passage-id" select="$passage-id"/>
                                    <xsl:with-param name="nodes" select="$node/node()"/>
                                    <xsl:with-param name="node-index" select="1"/>
                                    <xsl:with-param name="node-nesting" select="$node-nesting + 1"/>
                                    <xsl:with-param name="exclude-elements" select="$exclude-elements"/>
                                    <xsl:with-param name="output-string" select="$output-string"/>
                                </xsl:call-template>
                            </xsl:if>
                        </xsl:variable>
                        
                        <xsl:call-template name="substring-annotation">
                            <xsl:with-param name="passage-id" select="$passage-id"/>
                            <xsl:with-param name="node" select="$node"/>
                            <xsl:with-param name="start" select="string-length($output-string) + 1"/>
                            <xsl:with-param name="end" select="string-length(string-join(($output-string, $children-standoff[self::eft:output-string]/text()))) + 1"/>
                            <xsl:with-param name="has-siblings" select="count(($nodes except $exclude-elements)[not(self::xhtml:br)]) gt 1"/>
                        </xsl:call-template>
                        
                        <xsl:sequence select="$children-standoff"/>
                        
                    </xsl:when>
                </xsl:choose>
                
            </xsl:if>
            
        </xsl:variable>
        
        <xsl:sequence select="$standoff"/>
        
        <xsl:variable name="preceding-string" select="string-join(($output-string, $standoff[self::eft:output-string]/text(), ''))" as="xs:string"/>
        <xsl:variable name="following-string" select="string-join($nodes[$node-index + 1]/descendant-or-self::text()[count($exclude-elements except ancestor::*) eq $exclude-elements-count][not(ancestor::*[tokenize(@class, ' ')[. = ('footnote-link', 'folio-ref')]])])" as="xs:string?"/>
        
        <xsl:variable name="output-string-element" as="element()?">
            <xsl:choose>
                <xsl:when test="$node instance of text()">
                    <output-string>
                        <xsl:attribute name="passage-id" select="$passage-id"/>
                        <xsl:variable name="string" as="xs:string" select="$node"/>
                        <xsl:variable name="string" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="not($preceding-string gt '')">
                                    <xsl:value-of select="replace($string, '^\s+', '')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$string"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="string" as="xs:string">
                            <xsl:choose>
                                <xsl:when test="not($following-string ! normalize-space(.)) or $following-string ! normalize-space(.) ! matches(., '^\s+$')">
                                    <xsl:value-of select="replace($string, '\s+$', '')"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="$string"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="string-join($string) ! replace(., '\s+', ' ')"/>
                    </output-string>
                </xsl:when>
                <xsl:when test="$node instance of element()">
                    
                    <!--<xsl:variable name="last-char-is-word-char" as="xs:boolean" select="$preceding-string and not(matches($preceding-string, '一$')) and matches($preceding-string, '[\p{L}\p{N}\)\]:;\.,]$')"/>-->
                    <xsl:variable name="last-char-is-space" as="xs:boolean" select="$preceding-string and matches($preceding-string, '\s$')"/>
                    <xsl:variable name="next-char-is-word" as="xs:boolean" select="$following-string and not(matches($following-string, '^一')) and matches($following-string, '^[\p{L}\p{N}\[\(“&#34;]', 'i')"/>
                    
                    <xsl:if test="($preceding-string and not($last-char-is-space)) and $next-char-is-word">
                        <output-string>
                            <xsl:attribute name="passage-id" select="$passage-id"/>
                            <xsl:text> </xsl:text>
                        </output-string>
                    </xsl:if>
                    
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="$output-string-element"/>
        
        <!-- Recurse to the next node -->
        <xsl:if test="$nodes[$node-index + 1]">
            <xsl:call-template name="standoff">
                <xsl:with-param name="passage-id" select="$passage-id"/>
                <xsl:with-param name="nodes" select="$nodes"/>
                <xsl:with-param name="node-index" select="$node-index + 1"/>
                <xsl:with-param name="node-nesting" select="$node-nesting"/>
                <xsl:with-param name="output-string" select="string-join(($preceding-string, $output-string-element[self::eft:output-string]/text(),''))"/>
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
                <xsl:when test="$tag-name = ('div') and $node[matches(@class, '^rw\srw\-(paragraph|section\-head|line|line\-group|list\-bullet|list\-item|list\-head|list\-section|table|label|mantra|blockquote)$')]">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name eq 'div' and $node[matches(@class, '^rw\-heading\sheading\-section(\schapter)?(\snested)?(\snested\-\d+)?(\ssupplementary)?$')]">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name eq 'header' and $node[xhtml:h2 | xhtml:h3 | xhtml:h4 | xhtml:h5 | xhtml:div[tokenize(@class, ' ')[. = ('h3', 'h4')]]]">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name = ('table','tbody')">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name eq 'span' and $node[tokenize(@class, ' ')[. eq 'quote-outbound']] and $node/preceding-sibling::xhtml:span[tokenize(@class, ' ')[. eq 'quote']]">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name = 'span' and $node[tokenize(@class, ' ')[. eq 'quote-outbound']] and $node/ancestor::xhtml:blockquote">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name eq 'a' and $node/parent::xhtml:span[tokenize(@class, ' ')[. eq 'quote-outbound']][@id]">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name = ('div') and $node[matches(@class, '^list\slist\-(bullet|section)(\slist\-sublist)?(\snesting\-\d+)?(\s(dots|numbers|letters))?$')]">
                    <xsl:value-of select="'list'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('div') and $node[tokenize(@class, ' ')[. eq 'list-item']][descendant::text()[normalize-space()]]">
                    <xsl:value-of select="'list-item'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('br')">
                    <xsl:value-of select="'leading-space'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('h2','h3','h4','h5')">
                    <xsl:value-of select="'heading'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('div','header') and tokenize($node/@class, ' ')[. = ('h3', 'h4')]">
                    <xsl:value-of select="'heading'"/>
                </xsl:when>
                <xsl:when test="$tag-name = ('p') and $node[not(@class)]">
                    <xsl:value-of select="'paragraph'"/>
                </xsl:when>
                <xsl:when test="$node[@data-endnote-id]">
                    <xsl:value-of select="'end-note-link'"/>
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
                <xsl:when test="$tag-name eq 'a' and $node[@data-pointer-target]">
                    <xsl:value-of select="'internal-link'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'p' and tokenize($node/@class, ' ')[. eq 'trailer']">
                    <xsl:value-of select="'trailer'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'em'">
                    <xsl:value-of select="'span'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'sub'">
                    <xsl:value-of select="'span'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'span' and tokenize($node/@class, ' ')[. eq 'ref']">
                    <xsl:value-of select="'reference'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'span' and tokenize($node/@class, ' ')[. eq 'quote']">
                    <xsl:value-of select="'quote'"/>
                </xsl:when>
                <xsl:when test="$node[@data-href]">
                    <xsl:value-of select="'link'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'div' and tokenize($node/@class, ' ')[. eq 'line']">
                    <xsl:value-of select="'line'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'div' and tokenize($node/@class, ' ')[. eq 'line-group']">
                    <xsl:value-of select="'line-group'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'tr' and $node[@data-abbreviation-id]">
                    <!-- exclude -->
                </xsl:when>
                <xsl:when test="$tag-name eq 'th' and $node/parent::xhtml:tr[@data-abbreviation-id]">
                    <xsl:value-of select="'abbreviation'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'td' and $node/parent::xhtml:tr[@data-abbreviation-id]">
                    <xsl:value-of select="'has-abbreviation'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'tr' and $node/parent::xhtml:tbody">
                    <xsl:value-of select="'table-body-row'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'th' and $node/parent::xhtml:tr/parent::xhtml:tbody">
                    <xsl:value-of select="'table-body-header'"/>
                </xsl:when>
                <xsl:when test="$tag-name eq 'td' and $node/parent::xhtml:tr/parent::xhtml:tbody">
                    <xsl:value-of select="'table-body-data'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$tag-name"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:variable>
        
        <xsl:if test="$type">
            
            <xsl:variable name="content" as="element()*">
                
                <!-- content based on @type -->
                <xsl:if test="$type = ('link', 'internal-link') and $node[descendant::text()] and (not($start lt $end) or tokenize($node/@class, ' ')[. eq 'folio-ref'])">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'link-text'"/>
                        <xsl:with-param name="value" select="string-join($node/descendant::text()) ! replace(., '\s+', ' ') || ''"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'end-note-link'">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'link-text-lookup'"/>
                        <xsl:with-param name="value" select="'endnoteIndex'"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'heading' and $tag-name = ('h2','h3','h4','h5')">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'heading-level'"/>
                        <xsl:with-param name="value" select="$tag-name"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'heading' and tokenize($node/@class, ' ')[. = ('h3','h4')]">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'heading-level'"/>
                        <xsl:with-param name="value" select="if(tokenize($node/@class, ' ')[. eq 'h3']) then 'h3' else 'h4'"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'heading' and $node/parent::xhtml:div[tokenize(@class, ' ')[. eq 'supplementary']]">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'heading-type'"/>
                        <xsl:with-param name="value" select="'supplementary'"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type = ('has-abbreviation', 'abbreviation') and $node/parent::xhtml:tr[@data-abbreviation-id]">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'abbreviation_xmlId'"/>
                        <xsl:with-param name="value" select="concat($node/parent::xhtml:tr/@data-abbreviation-id, '/abbreviation')"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'span' and $tag-name eq 'sub'">
                    <xsl:call-template name="annotation-content">
                        <xsl:with-param name="type" select="'text-style'"/>
                        <xsl:with-param name="value" select="'subscript'"/>
                    </xsl:call-template>
                </xsl:if>
                
                <xsl:if test="$type eq 'quote' and $node/following-sibling::xhtml:span[tokenize(@class, ' ')[. eq 'quote-outbound']][@id]">
                    <xsl:for-each select="$node/following-sibling::xhtml:span[tokenize(@class, ' ')[. eq 'quote-outbound']][@id]">
                        <xsl:call-template name="annotation-content">
                            <xsl:with-param name="type" select="'quote_xmlId'"/>
                            <xsl:with-param name="value" select="@id"/>
                        </xsl:call-template>
                        <xsl:if test="common:index-of-node($node/following-sibling::xhtml:span[tokenize(@class, ' ')[. eq 'quote-outbound']][@id], .) eq 1">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'link-text-lookup'"/>
                                <xsl:with-param name="value" select="'targetTextShortcode'"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
                
                <xsl:if test="$type eq 'blockquote' and $node/descendant::xhtml:span[tokenize(@class, ' ')[. eq 'quote-outbound']][@id]">
                    <xsl:for-each select="$node/descendant::xhtml:span[tokenize(@class, ' ')[. eq 'quote-outbound']][@id]">
                        <xsl:call-template name="annotation-content">
                            <xsl:with-param name="type" select="'quote_xmlId'"/>
                            <xsl:with-param name="value" select="@id"/>
                        </xsl:call-template>
                        <xsl:if test="common:index-of-node($node/descendant::xhtml:span[tokenize(@class, ' ')[. eq 'quote-outbound']][@id], .) eq 1">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'link-text-lookup'"/>
                                <xsl:with-param name="value" select="'targetTextShortcode'"/>
                            </xsl:call-template>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:if>
                
                <!-- content based on attributes -->
                <xsl:for-each select="$node/@*">
                    <xsl:variable name="attribute-name" select="local-name(.)"/>
                    <xsl:variable name="attribute-value" select="string()"/>
                    <xsl:choose>
                        <xsl:when test="$attribute-name = ('id','data-quote-highlight','data-location-id')">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$attribute-name eq 'type' and $attribute-value = ('noteref')">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$attribute-name  eq 'target' and $type = ('link','internal-link','quoted')">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$attribute-name eq 'href' and matches($attribute-value, '^end\-notes\.xhtml#end\-note')">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$attribute-name eq 'title' and $start lt $end">
                            <!-- exclude -->
                        </xsl:when>
                        <xsl:when test="$type eq 'quoted' and $attribute-name = ('href', 'data-dualview-href', 'data-dualview-title', 'data-loading', 'title')">
                            <!-- exclude -->
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
                                    <xsl:when test="$type eq 'end-note-link' and $class-name eq 'footnote-link'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'reference' and $class-name eq 'ref'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'quoted' and $class-name = ('bridged', 'quote-link')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'list-item' and $class-name = ('list-item-first', 'list-item-last')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'blockquote' and $class-name = ('quote')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'heading' and $class-name = ('h3','h4')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$node[@lang] and $class-name = ('text-en','text-sa','text-bo','text-zh','text-wy','text-pi','text-ja','break')">
                                        <!-- Already set as lang => exclude -->
                                    </xsl:when>
                                    <xsl:when test="$class-name = ('matched','hidden-print','hidden-ebook','table-responsive')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$node[@data-reconstructed] and $class-name = ('reconstructed')">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type[not(. eq 'mantra')] and $class-name eq 'mantra'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'list' and $class-name eq 'list-sublist'">
                                        <!-- exclude -->
                                    </xsl:when>
                                    <xsl:when test="$type eq 'heading' and $class-name = ('section-title', 'section-label', 'table-label')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'heading-type'"/>
                                            <xsl:with-param name="value" select="$class-name"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$type eq 'internal-link' and $class-name eq 'ref-pending'">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'link-type'"/>
                                            <xsl:with-param name="value" select="'pending'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$class-name = ('foreign','distinct','italic','small-caps')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'text-style'"/>
                                            <xsl:with-param name="value" select="$class-name"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$class-name = ('text-bold','emphtext-bold')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'text-style'"/>
                                            <xsl:with-param name="value" select="'text-bold'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$class-name = ('underline','emphunderline')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'text-style'"/>
                                            <xsl:with-param name="value" select="'underline'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$class-name = ('line-through','emphline-through')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'text-style'"/>
                                            <xsl:with-param name="value" select="'line-through'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$class-name = ('emph','emphtext-bold','emphunderline','emphline-through')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'text-style'"/>
                                            <xsl:with-param name="value" select="'emphasis'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$type eq 'list' and $class-name = ('list-bullet','list-section')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'list-spacing'"/>
                                            <xsl:with-param name="value" select="if($class-name eq 'list-bullet') then 'horizontal' else 'vertical'"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="$type eq 'list' and $class-name = ('dots','numbers','letters')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'list-item-style'"/>
                                            <xsl:with-param name="value" select="$class-name"/>
                                        </xsl:call-template>
                                    </xsl:when>
                                    <xsl:when test="matches($class-name, '^nesting\-\d+$')">
                                        <xsl:call-template name="annotation-content">
                                            <xsl:with-param name="type" select="'nesting'"/>
                                            <xsl:with-param name="value" select="replace($class-name, '^nesting\-(\d+)$', '$1')"/>
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
                        <xsl:when test="$attribute-name eq 'lang'">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'lang'"/>
                                <xsl:with-param name="value">
                                    <xsl:choose>
                                        <xsl:when test="$attribute-value eq 'bo-LATN'">
                                            <xsl:value-of select="'Bo-Ltn'"/>
                                        </xsl:when>
                                        <xsl:when test="$attribute-value eq 'sa-LATN'">
                                            <xsl:value-of select="'Sa-Ltn'"/>
                                        </xsl:when>
                                        <xsl:when test="$attribute-value eq 'pi-LATN'">
                                            <xsl:value-of select="'Pi-Ltn'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="$attribute-value"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:with-param>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('data-glossary-id')">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'glossary_xmlId'"/>
                                <xsl:with-param name="value" select="$attribute-value"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('data-endnote-id')">
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
                            <xsl:if test="$type eq 'quoted'">
                                <xsl:call-template name="annotation-content">
                                    <xsl:with-param name="type" select="'link-text-lookup'"/>
                                    <xsl:with-param name="value" select="'quotingTextShortcode'"/>
                                </xsl:call-template>
                            </xsl:if>
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
                        <xsl:when test="$attribute-name = ('data-reconstructed')">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'reconstructed'"/>
                                <xsl:with-param name="value" select="$attribute-value"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-name = ('data-pointer-target') and $type eq 'internal-link' and not($node[@href])">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'href'"/>
                                <xsl:with-param name="value" select="$attribute-value"/>
                            </xsl:call-template>
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'link-type'"/>
                                <xsl:with-param name="value" select="'not-found'"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$attribute-name eq 'data-pointer-type' and $attribute-value eq 'id'">
                            <xsl:call-template name="annotation-content">
                                <xsl:with-param name="type" select="'link-text-lookup'"/>
                                <xsl:with-param name="value" select="'passageLabel'"/>
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
                
                <!-- Exclude annotation -->
                <xsl:when test="$type eq 'div' and not($content)">
                    <!-- exclude -->
                </xsl:when>
                
                <!-- Apply annotation -->
                <xsl:otherwise>
                    
                    <xsl:call-template name="annotation">
                        <xsl:with-param name="passage-id" select="$passage-id"/>
                        <xsl:with-param name="type" select="$type"/>
                        <xsl:with-param name="content" select="$content[self::eft:content]"/>
                        <xsl:with-param name="start" select="$start"/>
                        <xsl:with-param name="end" select="$end"/>
                    </xsl:call-template>
                    
                    <!-- Cases where multiple annotations should be applied -->
                    <xsl:choose>
                        <xsl:when test="$type[not(. eq 'mantra')] and $node/@class ! tokenize(., ' ')[. eq 'mantra']">
                            <xsl:call-template name="annotation">
                                <xsl:with-param name="passage-id" select="$passage-id"/>
                                <xsl:with-param name="type" select="'mantra'"/>
                                <xsl:with-param name="content" select="$content[self::eft:content] except $content[@class eq 'unknown:mantra']"/>
                                <xsl:with-param name="start" select="$start"/>
                                <xsl:with-param name="end" select="$end"/>
                            </xsl:call-template>
                        </xsl:when>
                    </xsl:choose>
                    
                </xsl:otherwise>
                
            </xsl:choose>
            
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
        <xsl:variable name="content-value" select="($content-type/eft:option[@value eq $value]/@value, $content-type[not(eft:option)] ! $value[. gt ''], concat('unknown:', $value))[1]"/>
        
        <content>
            <xsl:attribute name="json:array" select="true()"/>
            <xsl:choose>
                <xsl:when test="not($type eq 'annotation-content-type-empty')">
                    <xsl:element name="{ ($content-type/@type, $type)[1] }">
                        <xsl:choose>
                            <xsl:when test="matches($content-value, '^\d+$')">
                                <xsl:attribute name="json:literal" select="true()"/>
                                <xsl:value-of select="xs:integer($content-value)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$content-value"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:when>
            </xsl:choose>
        </content>
        
    </xsl:template>
    
</xsl:stylesheet>