<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <!-- 
        Converts other xml to valid xhtml
    -->
    
    <xsl:output method="html" indent="no"/>
    
    <xsl:function name="common:lang-class" as="xs:string*">
        <!-- Standardise wayward lang ids -->
        <xsl:param name="lang"/>
        <xsl:choose>
            <xsl:when test="lower-case($lang) eq 'bo'">
                <xsl:value-of select="'text-bo'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'sa-ltn'">
                <xsl:value-of select="'text-sa'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'bo-ltn'">
                <xsl:value-of select="'text-wy'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = ('eng', 'en')">
                <xsl:value-of select="'text-en'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'zh'">
                <xsl:value-of select="'text-zh'"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'ja'">
                <xsl:value-of select="'text-ja'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="''"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="common:echo-for-doc-type" as="xs:string*">
        <xsl:param name="current-doc-type"/>
        <xsl:param name="echo-for-doc-type"/>
        <xsl:param name="string-to-echo" as="xs:string*"/>
        <xsl:if test="$string-to-echo and (lower-case($current-doc-type) eq lower-case($echo-for-doc-type))">
            <xsl:value-of select="$string-to-echo"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="common:index-of-node" as="xs:integer*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="nodeToFind" as="node()?"/>
        <xsl:sequence select="for $seq in (1 to count($nodes)) return $seq[$nodes[$seq] is $nodeToFind]"/>
    </xsl:function>
    
    <xsl:function name="common:integer" as="xs:integer">
        <xsl:param name="value"/>
        <xsl:sequence select="xs:integer(replace(concat('0',$value[1]), '\D', ''))"/>
    </xsl:function>
    
    <xsl:function name="common:is-a-number" as="xs:boolean">
        <xsl:param name="value"/>
        <xsl:sequence select="string(number(concat('', $value[1]))) != 'NaN'"/>
    </xsl:function>
    
    <xsl:function name="common:sort" as="item()*">
        <xsl:param name="sequence" as="item()*"/>
        <xsl:for-each select="$sequence">
            <xsl:sort select="."/>
            <xsl:copy-of select="."/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="common:standardized-sa" as="xs:string*">
        <xsl:param name="sa-string" as="xs:string"/>
        <xsl:variable name="in" select="'āḍḥīḷḹṃṇñṅṛṝṣśṭūṁ'"/>
        <xsl:variable name="out" select="'adhillmnnnrrsstum'"/>
        <xsl:value-of select="translate(lower-case($sa-string), $in, $out)"/>
    </xsl:function>
    
    <xsl:function name="common:normalize-bo">
        <xsl:param name="bo-string" as="xs:string"/>
        <!-- 
            - Normalize whitespace
            - Add a zero-length break after a beginning shad
            - Add a she to the end
        -->
        <xsl:value-of select="             replace(replace(replace($bo-string, '\s+', ' '), '(།)(\S)', '$1​$2'), '་\s+$', '་')"/>                  
    </xsl:function>
    
    <xsl:function name="common:alphanumeric" as="xs:string*">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="replace($string, '[^a-zA-Z0-9]', '')"/>
    </xsl:function>
    
    <xsl:function name="common:limit-str" as="xs:string">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:param name="max-length" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="string-length($string) gt $max-length ">
                <xsl:value-of select="concat(substring($string ,1, $max-length), '...')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="common:date-user-string">
        <xsl:param name="action-text" as="xs:string" required="yes"/>
        <xsl:param name="date-time" as="xs:dateTime?"/>
        <xsl:param name="user-name" as="xs:string?"/>
        <xsl:variable name="action-str">
            <xsl:if test="$action-text">
                <xsl:value-of select="concat($action-text, ' ')"/>
            </xsl:if>
        </xsl:variable>
        <xsl:variable name="date-str">
            <xsl:choose>
                <xsl:when test="$date-time instance of xs:dateTime and $date-time gt xs:dateTime('2000-01-01T00:00:00Z')">
                    <xsl:value-of select="concat('at ', format-dateTime($date-time, '[H01]:[m01] on [FNn,*-3], [D1o] [MNn,*-3] [Y01]'), ' ')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'at unknown time '"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="user-str">
            <xsl:choose>
                <xsl:when test="$user-name">
                    <xsl:value-of select="concat('by ', $user-name)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'by unknown user'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($action-str, $date-str, $user-str)"/>
    </xsl:function>
    
    <xsl:function name="common:pagination">
        <xsl:param name="first-record" as="xs:integer"/>
        <xsl:param name="max-records" as="xs:integer"/>
        <xsl:param name="count-records" as="xs:integer"/>
        <xsl:param name="base-url" as="xs:string"/>
        <xsl:param name="append-to-url" as="xs:string"/>
        
        <xsl:variable name="count-blocks" select="xs:integer(ceiling($count-records div $max-records))" as="xs:integer"/>
        <xsl:variable name="this-block" select="xs:integer(floor((($first-record -1) + $max-records) div $max-records))" as="xs:integer"/>
        
        <nav aria-label="Page navigation" class="pull-right">
            <ul class="pagination">
                <li class="disabled">
                    <span>
                        <xsl:value-of select="concat(format-number($count-records, '#,###'), if($count-records gt 1) then ' records' else ' record')"/>
                    </span>
                </li>
                <xsl:if test="$this-block gt  1">
                    <li>
                        <xsl:copy-of select="common:pagination-link(1, $max-records, $base-url, $append-to-url, 'fa-first', 'Page 1')"/>
                    </li>
                    <li>
                        <xsl:copy-of select="common:pagination-link((((($this-block - 1) - 1) * $max-records) + 1), $max-records, $base-url, $append-to-url, 'fa-previous', concat('Page ', format-number(($this-block - 1), '#,###')))"/>
                    </li>
                </xsl:if>
                <li class="active">
                    <span>
                        <xsl:value-of select="concat('page ', $this-block, ' of ', format-number($count-blocks, '#,###'))"/>
                    </span>
                </li>
                <xsl:if test="$this-block lt $count-blocks">
                    <li>
                        <xsl:copy-of select="common:pagination-link((((($this-block + 1) - 1) * $max-records) + 1), $max-records, $base-url, $append-to-url, 'fa-next', concat('Page ', format-number(($this-block + 1), '#,###')))"/>
                    </li>
                    <li>
                        <xsl:copy-of select="common:pagination-link(((($count-blocks - 1) * $max-records) + 1), $max-records, $base-url, $append-to-url, 'fa-last', concat('Page ', format-number($count-blocks, '#,###')))"/>
                    </li>
                </xsl:if>
                
            </ul>
        </nav>
    </xsl:function>
    
    <xsl:function name="common:pagination-link">
        <xsl:param name="first-record" as="xs:integer"/>
        <xsl:param name="max-records" as="xs:integer"/>
        <xsl:param name="base-url" as="xs:string"/>
        <xsl:param name="append-to-url" as="xs:string"/>
        <xsl:param name="link-text" as="xs:string"/>
        <xsl:param name="link-title" as="xs:string"/>
        <a>
            <xsl:attribute name="href" select="concat($base-url, if(contains($base-url, '?')) then '&amp;' else '?', 'first-record=',  $first-record, '&amp;max-records=', $max-records, $append-to-url)"/>
            <xsl:attribute name="title" select="$link-title"/>
            <xsl:choose>
                <xsl:when test="$link-text eq 'fa-next'">
                    <i class="fa fa-chevron-right"/>
                </xsl:when>
                <xsl:when test="$link-text eq 'fa-previous'">
                    <i class="fa fa-chevron-left"/>
                </xsl:when>
                <xsl:when test="$link-text eq 'fa-first'">
                    <i class="fa fa-step-backward"/>
                </xsl:when>
                <xsl:when test="$link-text eq 'fa-last'">
                    <i class="fa fa-step-forward"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$link-text"/>
                </xsl:otherwise>
            </xsl:choose>
            
        </a>
    </xsl:function>
    
    <xsl:function name="common:marker">
        
        <xsl:param name="start-letter" as="xs:string"/>
        <xsl:param name="previous-start-letter" as="xs:string"/>
        
        <xsl:if test="not($previous-start-letter eq $start-letter)">
            <a class="marker">
                <xsl:attribute name="name" select="$start-letter"/>
                <xsl:attribute name="id" select="concat('marker-', $start-letter)"/>
                <xsl:value-of select="$start-letter"/>
            </a>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="common:marker-nav">
        
        <xsl:param name="items-with-start-letters" as="item()*"/>
        
        <div data-spy="affix">
            <div class="btn-group-vertical btn-group-xs" role="group" aria-label="navigation">
                <xsl:for-each select="$items-with-start-letters">
                    
                    <xsl:sort select="@start-letter"/>
                    
                    <xsl:variable name="start-letter" select="@start-letter"/>
                    
                    <xsl:if test="not(preceding-sibling::*[@start-letter = $start-letter])">
                        
                        <a class="btn btn-default scroll-to-anchor">
                            <xsl:attribute name="href" select="concat('#marker-', $start-letter)"/>
                            <xsl:value-of select="$start-letter"/>
                        </a>
                        
                    </xsl:if>
                    
                </xsl:for-each>
            </div>
        </div>
    </xsl:function>
    
    <xsl:function name="common:position-to-color" as="xs:string">
        
        <xsl:param name="position" as="xs:integer"/>
        <xsl:param name="format" as="xs:string"/>
        
        <xsl:variable name="colour-map" select="document('../config/colour-map.xml')"/>
        <xsl:variable name="max-position" select="count($colour-map/m:colour-map/m:colour)"/>
        <xsl:variable name="position-bounded" select="if($position gt $max-position) then $max-position else $position"/>
        
        <xsl:choose>
            <xsl:when test="$format eq 'hex'">
                <xsl:value-of select="$colour-map/m:colour-map/m:colour[$position-bounded]/@hex"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$colour-map/m:colour-map/m:colour[$position-bounded]/@id"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="common:breadcrumb-items">
        <xsl:param name="parents" required="yes"/>
        <xsl:param name="lang" required="yes"/>
        <xsl:for-each select="$parents">
            <xsl:sort select="@nesting" order="descending"/>
            <li>
                <a class="printable">
                    <xsl:choose>
                        <xsl:when test="@type eq 'grouping'">
                            <xsl:attribute name="href" select="common:internal-link(concat('/section/', m:parent/@id, '.html'), (), concat('#grouping-', @id), /m:response/@lang)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="href" select="common:internal-link(concat('/section/', @id, '.html'), (), '', /m:response/@lang)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:apply-templates select="m:titles/m:title[@xml:lang='en']/text()"/>
                </a>
            </li>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Translation status -->
    <xsl:function name="common:translation-status">
        <xsl:param name="status-group"/>
        <xsl:choose>
            <xsl:when test="$status-group eq 'published'">
                <span class="label label-success published">
                    <xsl:value-of select="'Published'"/>
                </span>
            </xsl:when>
            <xsl:when test="$status-group eq 'translated'">
                <span class="label label-warning in-progress">
                    <xsl:value-of select="'In progress'"/>
                </span>
            </xsl:when>
            <xsl:when test="$status-group eq 'in-translation'">
                <span class="label label-warning in-progress">
                    <xsl:value-of select="'In progress'"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="label label-default">
                    <xsl:value-of select="'Not Started'"/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- Sponsorship status -->
    <xsl:function name="common:sponsorship-status">
        <xsl:param name="sponsorship-statuses"/>
        <xsl:for-each select="$sponsorship-statuses">
            <xsl:if test="not(@id eq 'no-sponsorship')">
                <span>
                    <xsl:choose>
                        <xsl:when test="@id = 'available'">
                            <xsl:attribute name="class" select="'nowrap label label-success'"/>
                        </xsl:when>
                        <xsl:when test="@id = 'full'">
                            <xsl:attribute name="class" select="'nowrap label label-info'"/>
                        </xsl:when>
                        <xsl:when test="@id = ('part', 'reserved', 'priority')">
                            <xsl:attribute name="class" select="'nowrap label label-warning'"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="class" select="'nowrap label label-default'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:value-of select="m:label"/>
                </span>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    <!-- 
    Deprecated in favour of concat('folio-', @ref-index)
    <xsl:function name="common:folio-id" as="xs:string">
        <xsl:param name="folio-str" as="xs:string"/>
        <xsl:value-of select="concat('ref-', lower-case(replace($folio-str, '\.', '-')))"/>
    </xsl:function>
     -->
    
    <!-- Localization helpers -->
    <xsl:function name="common:internal-link">
        <xsl:param name="url" required="yes"/>
        <xsl:param name="attributes" required="yes" as="xs:string*"/>
        <xsl:param name="fragment-id" required="yes" as="xs:string"/>
        <xsl:param name="lang" as="xs:string" required="yes"/>
        <xsl:variable name="lang-attribute" select="if($lang = ('zh')) then concat('lang=', $lang) else ()"/>
        <xsl:variable name="attributes-with-lang" select="($attributes, $lang-attribute)"/>
        <xsl:variable name="url-append" select="if(contains($url, '?')) then '&amp;' else '?'"/>
        <xsl:value-of select="concat($url, if(count($attributes-with-lang) gt 0) then concat($url-append, string-join($attributes-with-lang, '&amp;')) else '', $fragment-id)"/>
    </xsl:function>
    
    <xsl:function name="common:homepage-link">
        <xsl:param name="dir" as="xs:string?"/>
        <xsl:param name="lang" required="yes"/>
        <xsl:variable name="url-params">
            <xsl:choose>
                <xsl:when test="$lang eq 'zh'">
                    <xsl:choose>
                        <xsl:when test="$dir gt ''">
                            <xsl:value-of select="concat('/ch', '-', $dir)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="'/ch'"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$dir gt ''">
                            <xsl:value-of select="concat('/', $dir)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="''"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat('http://84000.co', $url-params)"/>
    </xsl:function>
    
    <xsl:function name="common:override-href">
        <xsl:param name="lang" required="yes"/>
        <xsl:param name="url-lang" required="yes"/>
        <xsl:param name="lang-url" required="yes"/>
        <xsl:if test="$lang eq $url-lang">
            <xsl:attribute name="href" select="$lang-url"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="common:localise-form">
        <xsl:param name="lang" required="yes"/>
        <xsl:if test="$lang eq 'zh'">
            <input type="hidden" name="lang">
                <xsl:attribute name="value" select="$lang"/>
            </input>
        </xsl:if>
    </xsl:function>
    
    
    <xsl:function name="common:normalize-data" as="xs:string?">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="replace($arg, '\s+', ' ')"/>
        
    </xsl:function>
    
    <xsl:function name="common:matches-regex" as="xs:string">
        
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:variable name="strings-combined" select="string-join($strings ! normalize-space(.) ! common:escape-for-regex(.), '|')"/>
        <xsl:value-of select="concat('(^|[^-\w])(', $strings-combined, ')(s|es|&#34;s|s&#34;)?([^-\w]|$)')"/>
        
    </xsl:function>
    
    <xsl:function name="common:matches-regex-exact" as="xs:string">
        
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:value-of select="concat('^\s*(', string-join($strings[normalize-space(.)] ! normalize-space(.) ! common:escape-for-regex(.), '|'), ')\s*$')"/>
        
    </xsl:function>
    
    <xsl:function name="common:escape-for-regex" as="xs:string?">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="replace($arg, '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')"/>
        
    </xsl:function>
    
    
    <xsl:function name="functx:replace-multi" as="xs:string?">
        
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="changeFrom" as="xs:string*"/>
        <xsl:param name="changeTo" as="xs:string*"/>
        
        <xsl:sequence select="if (count($changeFrom) &gt; 0) then functx:replace-multi(replace($arg, $changeFrom[1], functx:if-absent($changeTo[1],'')), $changeFrom[position() &gt; 1], $changeTo[position() &gt; 1]) else $arg "/>
        
    </xsl:function>
    
    <xsl:function name="functx:if-absent" as="item()*">
        <xsl:param name="arg" as="item()*"/>
        <xsl:param name="value" as="item()*"/>
        
        <xsl:sequence select="if (exists($arg)) then $arg else $value "/>
        
    </xsl:function>
    
    <xsl:function name="functx:capitalize-first" as="xs:string?">
        <xsl:param name="arg" as="xs:string?"/>
        
        <xsl:sequence select="concat(upper-case(substring($arg,1,1)),substring($arg,2))"/>
        
    </xsl:function>
    
    <xsl:function name="functx:is-a-number" as="xs:boolean">
        <xsl:param name="value" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="string(number($value)) != 'NaN'"/>
        
    </xsl:function>
    
    <xsl:function name="common:enforce-integer" as="xs:integer">
        <xsl:param name="value" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="if(functx:is-a-number($value)) then xs:integer($value) else 0"/>
        
    </xsl:function>
    
</xsl:stylesheet>