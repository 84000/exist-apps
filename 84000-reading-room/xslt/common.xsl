<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:common="http://read.84000.co/common" xmlns:markdown="http://read.84000.co/markdown" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:function name="common:lang-class" as="xs:string">
        <!-- Standardise wayward lang ids -->
        <xsl:param name="lang" as="xs:string?"/>
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
    
    <xsl:function name="common:lang-label" as="xs:string">
        <xsl:param name="lang" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="lower-case($lang) eq 'bo'">
                <xsl:value-of select="'Tib.: '"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'sa-ltn'">
                <xsl:value-of select="'Skt.: '"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) eq 'bo-ltn'">
                <xsl:value-of select="'Tib.: '"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'zh'">
                <xsl:value-of select="'Chn.: '"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'ja'">
                <xsl:value-of select="'Jap.: '"/>
            </xsl:when>
            <xsl:when test="lower-case($lang) = 'pi-ltn'">
                <xsl:value-of select="'Pali: '"/>
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
        <xsl:value-of select="translate(lower-case(normalize-unicode(normalize-space($sa-string))), $in, $out)"/>
    </xsl:function>
    
    <xsl:function name="common:normalize-bo">
        <xsl:param name="bo-string" as="xs:string"/>
        <!-- 
            - Normalize whitespace
            - Add a zero-length break after a beginning shad
            - Add a she to the end
        -->
        <xsl:value-of select="replace(replace(replace($bo-string, '\s+', ' '), '(།)(\S)', '$1​$2'), '་\s+$', '་')"/>                  
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
        
        <nav aria-label="Page navigation" class="pagination-nav pull-right">
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
        
        <div data-spy="affix" data-offset-top="20">
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
    
    <xsl:function name="common:position-to-letter" as="xs:string">
        
        <xsl:param name="position" as="xs:integer"/>
        
        <xsl:variable name="alphabet" select="'abcdefghijklmnopqursuvwxyz'"/>
        <xsl:variable name="position-mod" select="$position mod string-length($alphabet)"/>
        
        <xsl:value-of select="substring($alphabet, $position-mod, 1)"/>
        
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
            <xsl:when test="$status-group eq 'in-application'">
                <span class="label label-danger in-progress">
                    <xsl:value-of select="'Application pending'"/>
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
        <!-- Shrink whitespace to one space -->
        <!-- Add zero-width joiner to em-dash - regex includes zwj i.e. &zwj;*— -->
        <xsl:sequence select="replace(replace($arg, '\s+', ' '), '‍*—', '‍—')"/>
        
    </xsl:function>
    
    <xsl:function name="common:matches-regex" as="xs:string">
        
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:variable name="strings-combined" select="string-join($strings ! normalize-space(.) ! common:escape-for-regex(.), '|')"/>
        <xsl:value-of select="concat('(^|[^-\w])(', $strings-combined, ')(s|es|''s|s'')?([^-\w]|$)')"/>
        
    </xsl:function>
    
    <xsl:function name="common:matches-regex-exact" as="xs:string">
        
        <xsl:param name="strings" as="xs:string*"/>
        <xsl:variable name="strings-combined" select="string-join($strings ! normalize-space(.) ! common:escape-for-regex(.), '|')"/>
        <xsl:value-of select="concat('^\s*(', $strings-combined, ')(s|es|''s|s'')?\s*$')"/>
        
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
    
    <xsl:function name="functx:change-element-ns-deep" as="node()*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:param name="newns" as="xs:string"/>
        <xsl:param name="prefix" as="xs:string"/>
        <xsl:for-each select="$nodes">
            <xsl:variable name="node" select="."/>
            <xsl:choose>
                <xsl:when test="$node instance of element()">
                    <xsl:element name="{concat($prefix, if ($prefix = '') then '' else ':', local-name($node))}" namespace="{$newns}">
                        <xsl:sequence select="($node/@*, functx:change-element-ns-deep($node/node(), $newns, $prefix))"/>
                    </xsl:element>
                </xsl:when>
                <xsl:when test="$node instance of document-node()">
                    <xsl:document>
                        <xsl:sequence select="functx:change-element-ns-deep($node/node(), $newns, $prefix)"/>
                    </xsl:document>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$node"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="functx:repeat-string" as="xs:string">
        <xsl:param name="stringToRepeat" as="xs:string?"/>
        <xsl:param name="count" as="xs:integer"/>
        
        <xsl:sequence select="string-join((for $i in 1 to $count return $stringToRepeat),'')"/>
        
    </xsl:function>
    
    <xsl:function name="common:enforce-integer" as="xs:integer">
        <xsl:param name="value" as="xs:anyAtomicType?"/>
        
        <xsl:sequence select="if(functx:is-a-number($value)) then xs:integer($value) else 0"/>
        
    </xsl:function>
    
    <xsl:function name="common:mark-string" as="node()*">
        <xsl:param name="string" as="xs:string?"/>
        <xsl:param name="regex" as="xs:string?"/>
        
        <xsl:analyze-string select="$string" regex="{ $regex }" flags="i">
            
            <xsl:matching-substring>
                <span class="mark">
                    <xsl:value-of select="."/>
                </span>
            </xsl:matching-substring>
            
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
            
        </xsl:analyze-string>     
        
    </xsl:function>
    
    <!-- MARKDOWN templates:
        
        Markdown                       XML                                              Notes / Conditions
        ~~~~~~~~~~~~~~~~~~~~~~~~       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        text                      <->  <p>text</p>                                      Where text is on a new line
        (tag)                     <->  <tag/>                                           Where tag is on a new line e.g. <lb/>
        (tag id:abc)              <->  <tag xml:id="abc"/>                              Where tag is on a new line e.g. <milestone/>
        [data](tag)               <->  <tag>data</tag>
        [data](tag lang:bo)       <->  <tag xml:lang="bo">data</tag>
        [data[[data]](tag)](tag)  <->  <tag xml:lang="bo">data[[data]](tag)</tag>       Match the outermost brackets, then recurse.
        [data](bo)                <->  <foreign xml:lang="bo">data</foreign>            Where lang is known-lang
        [data](http://abc)        <->  <ref target="http://abc">data</ref>              Valid for http: and https:
        
    -->
    <xsl:variable name="element-regex" select="'(^\s*|\[(.*?[^\]])\])\(([^\(\)]*?)\)'"/>
    
    <!-- 
        Known languages can be used in short codes 
        e.g. [data](bo) -> <foreign xml:lang="bo">data</foreign>
    -->
    <xsl:variable name="known-langs" select="('bo', 'en', 'zh', 'Sa-Ltn', 'Bo-Ltn', 'Pi-Ltn')"/>
    
    <!-- Return character for new lines in markdown -->
    <xsl:variable name="char-nl" select="'&#xA;'"/>
    
    <!-- Tei -> Markdown -->
    <xsl:template match="tei:div[@type eq 'markup']">
        
        <xsl:variable name="markup" select="."/>
        
        <markdown>
            
            <!-- Loop through nodes formatting everything to markdown strings -->
            <xsl:for-each select="$markup/node()">
                <xsl:choose>
                    
                    <!-- Text node -->
                    <xsl:when test=". instance of text() and normalize-space(.) gt ''">
                        
                        <xsl:call-template name="markdown:string">
                            <xsl:with-param name="node" select="."/>
                            <xsl:with-param name="new-line" select="true()"/>
                        </xsl:call-template>
                        
                        <xsl:value-of select="$char-nl"/>
                        
                    </xsl:when>
                    
                    <!-- Element -->
                    <xsl:when test=". instance of element()">
                        <xsl:choose>
                            
                            <!-- List -->
                            <xsl:when test="self::*:list[@type eq 'bullet']">
                                
                                <xsl:variable name="list-style" select="@rend"/>
                                
                                <xsl:for-each select="*:item/*:p">
                                    
                                    <!-- New line before list item -->
                                    <xsl:value-of select="$char-nl"/>
                                    
                                    <!-- Leading chars to markdown list -->
                                    <xsl:choose>
                                        
                                        <!-- Numbered list -->
                                        <xsl:when test="$list-style eq 'numbers'">
                                            <xsl:value-of select="concat(position(), '. ')"/>
                                        </xsl:when>
                                        
                                        <xsl:when test="$list-style eq 'letters'">
                                            <xsl:value-of select="concat(common:position-to-letter(position()), '. ')"/>
                                        </xsl:when>
                                        
                                        <!-- Bullet list -->
                                        <xsl:otherwise>
                                            <xsl:value-of select="'* '"/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                    
                                    <!-- Parse each content node -->
                                    <xsl:for-each select="node()">
                                        <xsl:call-template name="markdown:string">
                                            <xsl:with-param name="node" select="."/>
                                            <xsl:with-param name="markup" select="$markup"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                    
                                    <!-- New line after list item -->
                                    <xsl:value-of select="$char-nl"/>
                                    
                                </xsl:for-each>
                                
                            </xsl:when>
                            
                            <!-- Paragraph -->
                            <xsl:when test="self::*:p">
                                
                                <!-- New line before paragraph -->
                                <xsl:value-of select="$char-nl"/>
                                
                                <!-- Parse each content node -->
                                <xsl:for-each select="node()">
                                    <xsl:call-template name="markdown:string">
                                        <xsl:with-param name="node" select="."/>
                                        <xsl:with-param name="markup" select="$markup"/>
                                    </xsl:call-template>
                                </xsl:for-each>
                                
                                <!-- New line after paragraph -->
                                <xsl:value-of select="$char-nl"/>
                                
                            </xsl:when>
                            
                            <!-- Heading -->
                            <xsl:when test="self::*:head and @type = ('section', 'nonStructuralBreak') and not(@*[not(local-name(.) = ('type', 'tid'))]) and not(*)">
                                
                                <!-- Hash specifies a header -->
                                <xsl:value-of select="'# '"/>
                                
                                <!-- Output value -->
                                <xsl:value-of select="normalize-space(data())"/>
                                
                                <!-- New line after heading -->
                                <xsl:value-of select="$char-nl"/>
                                
                            </xsl:when>
                            
                            <!-- Parse the content -->
                            <xsl:otherwise>
                                
                                <xsl:call-template name="markdown:string">
                                    <xsl:with-param name="node" select="."/>
                                    <xsl:with-param name="new-line" select="true()"/>
                                </xsl:call-template>
                                
                                <!-- New line after element if it has content -->
                                <xsl:if test="data()">
                                    <xsl:value-of select="$char-nl"/>
                                </xsl:if>
                                
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:when>
                </xsl:choose>
            </xsl:for-each>
            
            <!-- Output notes at the end -->
            <xsl:for-each select="//tei:note[@place eq 'end']">
                
                <xsl:value-of select="$char-nl"/>
                
                <xsl:value-of select="concat(position(), ') ')"/>
                
                <xsl:for-each select="node()">
                    <xsl:call-template name="markdown:string">
                        <xsl:with-param name="node" select="."/>
                    </xsl:call-template>
                </xsl:for-each>
                
                <xsl:value-of select="$char-nl"/>
                
            </xsl:for-each>
            
        </markdown>
        
    </xsl:template>
    
    <!-- Markdown -> XML(TEI) -->
    <xsl:template match="m:markdown">
    
        <!-- The source node -->
        <xsl:variable name="source" select="."/>
        <!-- The target namespace for markup -->
        <xsl:variable name="namespace" select="($source/@target-namespace, 'http://www.tei-c.org/ns/1.0')[1]" as="xs:string"/>
        <!-- The content tokenized into lines -->
        <xsl:variable name="lines" select="tokenize($source/node(), '\n')" as="xs:string*"/>
        
        <!-- Parse lines to elements -->
        <xsl:variable name="elements">
            
            <!-- Need a root element so we can evaluate siblings -->
            <elements>
                
                <!-- Exclude empty lines and notes -->
                <xsl:for-each select="$lines[matches(., '\w+')][not(matches(., '^\s*\d\)\s+'))]">
                    
                    <xsl:variable name="line" select="."/>
                    <xsl:variable name="line-number" select="position()"/>
                    
                    <xsl:choose>
                        
                        <!-- This line defines an element -->
                        <xsl:when test="matches($line, concat('^\s*', $element-regex, '\s*$'), 'i')">
                            <xsl:call-template name="markdown:element">
                                <xsl:with-param name="md-string" select="replace($line, '\s+', ' ')"/>
                                <xsl:with-param name="namespace" select="$namespace"/>
                                <xsl:with-param name="lines" select="$lines"/>
                            </xsl:call-template>
                        </xsl:when>
                        
                        <!-- This line is a heading -->
                        <xsl:when test="matches($line, '^\s*#+\s+')">
                            
                            <!-- Add head element -->
                            <xsl:element name="head" namespace="{ $namespace }">
                                
                                <xsl:attribute name="type">
                                    
                                    <!-- 
                                    Remove option for multiple #
                                    Heading type determined by position in section
                                    
                                    <!-/- Evaluate the indent level -/->
                                    <xsl:variable name="leading-hashes" select="replace($line, '^\s*(#+)\s+(.*)', '$1')"/>
                                    
                                    <xsl:choose>
                                        <xsl:when test="string-length($leading-hashes) eq 1">
                                            <xsl:value-of select="'section'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'nonStructuralBreak'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    -->
                                    
                                    <xsl:choose>
                                        <xsl:when test="$line-number eq 1">
                                            <xsl:value-of select="'section'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'nonStructuralBreak'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:attribute>
                                
                                <!-- Remove hashes from content -->
                                <xsl:value-of select="replace(replace(., '^\s*#+\s+', ''), '\s+', ' ')"/>
                                
                            </xsl:element>
                            
                        </xsl:when>
                        
                        <!-- Convert other lines to <p/> -->
                        <xsl:otherwise>
                            
                            <!-- Add a paragraph element -->
                            <xsl:element name="p" namespace="{ $namespace }">
                                
                                <!-- Set type -->
                                <xsl:attribute name="line-group-type">
                                    <xsl:choose>
                                        
                                        <xsl:when test="matches($line, '^\s*\*\s+')">
                                            <xsl:value-of select="'list-item-bullet'"/>
                                        </xsl:when>
                                        
                                        <xsl:when test="matches($line, '^\s*\d\.\s+')">
                                            <xsl:value-of select="'list-item-number'"/>
                                        </xsl:when>
                                        
                                        <xsl:when test="matches($line, '^\s*[a-zA-Z]\.\s+')">
                                            <xsl:value-of select="'list-item-letter'"/>
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <xsl:value-of select="'p'"/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                </xsl:attribute>
                                
                                <!-- Get content -->
                                <xsl:variable name="content">
                                    <xsl:choose>
                                        
                                        <!-- Bullet list -->
                                        <xsl:when test="matches($line, '^\s*\*\s+')">
                                            <xsl:value-of select="replace(., '^\s*\*\s+', '')"/>
                                        </xsl:when>
                                        
                                        <!-- Number list -->
                                        <xsl:when test="matches($line, '^\s*\d\.\s+')">
                                            <xsl:value-of select="replace(., '^\s*\d\.\s+', '')"/>
                                        </xsl:when>
                                        
                                        <!-- Letter list -->
                                        <xsl:when test="matches($line, '^\s*[a-zA-Z]\.\s+')">
                                            <xsl:value-of select="replace(., '^\s*[a-zA-Z]\.\s+', '')"/>
                                        </xsl:when>
                                        
                                        <!-- Note -->
                                        <xsl:when test="matches($line, '^\s*\d\)\s+')">
                                            <xsl:value-of select="replace(., '^\s*\d\)\s+', '')"/>
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                </xsl:variable>
                                
                                <!-- Parse content -->
                                <xsl:analyze-string select="replace(replace($content, '^\s+', ''), '\s+', ' ')" regex="{ $element-regex }">
                                    
                                    <xsl:matching-substring>
                                        <xsl:call-template name="markdown:element">
                                            <xsl:with-param name="md-string" select="."/>
                                            <xsl:with-param name="namespace" select="$namespace"/>
                                            <xsl:with-param name="lines" select="$lines"/>
                                            <xsl:with-param name="leading-space" select="if(matches(., '^\s+')) then ' ' else ''"/>
                                            <xsl:with-param name="trailing-space" select="if(matches(., '\s+$')) then ' ' else ''"/>
                                        </xsl:call-template>
                                    </xsl:matching-substring>
                                    
                                    <xsl:non-matching-substring>
                                        <xsl:value-of select="."/>
                                    </xsl:non-matching-substring>
                                    
                                </xsl:analyze-string>
                                
                            </xsl:element>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                </xsl:for-each>
            
            </elements>
        
        </xsl:variable>
        
        <!-- Make groups of similar items for lists -->
        <xsl:variable name="elements">
            <xsl:for-each select="$elements/m:elements/*">
                
                <xsl:variable name="element" select="."/>
                
                <!-- Make a copy of the element -->
                <!-- Add a group for list items -->
                <xsl:element name="{ node-name($element) }" namespace="{ namespace-uri($element) }">
                    
                    <!-- Copy attributes -->
                    <xsl:sequence select="$element/@*"/>
                    
                    <!-- Add an attribute grouping list items -->
                    <xsl:attribute name="line-group-id">
                        <xsl:choose>
                            
                            <!-- List types where it's not the first in the list -->
                            <xsl:when test="$element/@line-group-type = ('list-item-bullet', 'list-item-number', 'list-item-letter') and preceding-sibling::*[1][@line-group-type eq $element/@line-group-type]">
                                <!-- 
                                    Find the first in this list
                                    - Closest sibling of this type that has a first sibling of not this type
                                    - Use the index of that as the group id
                                -->
                                <xsl:variable name="first-in-group" select="$element/preceding-sibling::*[@line-group-type eq $element/@line-group-type][preceding-sibling::*[1][not(@line-group-type eq $element/@line-group-type)]][1]"/>
                                <xsl:value-of select="common:index-of-node($elements/m:elements/*, $first-in-group)"/>
                            </xsl:when>
                            
                            <xsl:otherwise>
                                <xsl:value-of select="common:index-of-node($elements/m:elements/*, $element)"/>
                            </xsl:otherwise>
                            
                        </xsl:choose>
                    </xsl:attribute>
                    
                    <!-- Copy nodes -->
                    <xsl:sequence select="node()"/>
                    
                </xsl:element>
                
            </xsl:for-each>
        </xsl:variable>
        
        <!-- Output tei -->
        <xsl:element name="div" namespace="{ $namespace }">
            
            <xsl:attribute name="type" select="'markup'"/>
            
            <xsl:for-each-group select="$elements/*" group-by="@line-group-id">
                <xsl:choose>
                    
                    <!-- Add a list for list items -->
                    <xsl:when test="@line-group-type = ('list-item-bullet', 'list-item-number', 'list-item-letter')">
                        <xsl:element name="list" namespace="{ $namespace }">
                            
                            <xsl:attribute name="type" select="'bullet'"/>
                            
                            <xsl:choose>
                                <xsl:when test="@line-group-type eq 'list-item-bullet'">
                                    <xsl:attribute name="rend" select="'dots'"/>
                                </xsl:when>
                                <xsl:when test="@line-group-type eq 'list-item-number'">
                                    <xsl:attribute name="rend" select="'numbers'"/>
                                </xsl:when>
                                <xsl:when test="@line-group-type eq 'list-item-letter'">
                                    <xsl:attribute name="rend" select="'letters'"/>
                                </xsl:when>
                            </xsl:choose>
                            
                            <!-- Add each item in the list -->
                            <xsl:for-each select="current-group()">
                                <xsl:element name="item" namespace="{ $namespace }">
                                    <xsl:element name="{ node-name(.) }" namespace="{ namespace-uri(.) }">
                                        <xsl:sequence select="@*[not(name(.) = ('line-group-id', 'line-group-type'))]"/>
                                        <xsl:sequence select="node()"/>
                                    </xsl:element>
                                </xsl:element>
                            </xsl:for-each>
                            
                        </xsl:element>
                    </xsl:when>
                    
                    <!-- Add the element -->
                    <xsl:otherwise>
                        <xsl:for-each select="current-group()">
                            <xsl:element name="{ node-name(.) }" namespace="{ namespace-uri(.) }">
                                <xsl:sequence select="@*[not(name(.) = ('line-group-id', 'line-group-type'))]"/>
                                <xsl:sequence select="node()"/>
                            </xsl:element>
                        </xsl:for-each>
                    </xsl:otherwise>
                    
                </xsl:choose>  
            </xsl:for-each-group>
            
        </xsl:element>
           
    </xsl:template>
    
    <!-- XML(TEI) -> escaped string -->
    <xsl:template match="tei:div[@type eq 'unescaped']">
        
        <escaped>
            
            <xsl:variable name="serialization-parameters" as="element(output:serialization-parameters)">
                <output:serialization-parameters>
                    <output:method value="xml"/>
                    <output:version value="1.1"/>
                    <output:indent value="no"/>
                    <output:omit-xml-declaration value="yes"/>
                </output:serialization-parameters>
            </xsl:variable>
            
            <!-- Loop through nodes to avoid whitespace from passing node() sequence -->
            <xsl:for-each select="node()">
                <xsl:value-of select="replace(normalize-space(serialize(., $serialization-parameters)), '\s*xmlns=&#34;\S*&#34;', '')"/>
            </xsl:for-each>
            
        </escaped>
        
    </xsl:template>
    
    <!-- Escaped string -> XML(TEI) -->
    <xsl:template match="m:escaped">
        
        <xsl:variable name="source" select="."/>
        <xsl:variable name="namespace" select="($source/@target-namespace, 'http://www.tei-c.org/ns/1.0')[1]"/>
        
        <xsl:element name="div" namespace="{ $namespace }">
            
            <xsl:attribute name="type" select="'markup'"/>
            
            <xsl:sequence select="functx:change-element-ns-deep(parse-xml(concat('&lt;doc&gt;',text(),'&lt;/doc&gt;'))/doc/node(), $namespace, '')"/>
            
        </xsl:element>
        
    </xsl:template>
    
    <!-- Create an element from a markdown string -->
    <xsl:template name="markdown:element">
        
        <xsl:param name="md-string" as="xs:string"/>
        <xsl:param name="lines" as="xs:string*"/>
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:param name="leading-space" as="xs:string?"/>
        <xsl:param name="trailing-space" as="xs:string?"/>
        
        <xsl:variable name="content" select="replace($md-string, $element-regex, '$2')"/>
        <xsl:variable name="element" select="replace($md-string, $element-regex, '$3')"/>
        <xsl:variable name="element-tokenized" select="tokenize($element, '\s+')"/>
        <xsl:variable name="element-one" select="$element-tokenized[1]"/>
        <xsl:variable name="element-one-tokenized" select="tokenize($element-one,':')"/>
        <xsl:variable name="element-rest" select="subsequence($element-tokenized, 2)"/>
        
        <!-- Derive the element from the first token -->
        <xsl:variable name="element-name" as="xs:string?">
            <xsl:choose>
                <xsl:when test="lower-case($element-one) = $known-langs ! lower-case(.)">
                    <xsl:value-of select="'foreign'"/>
                </xsl:when>
                <xsl:when test="count($element-one-tokenized) eq 1">
                    <xsl:value-of select="$element-one-tokenized"/>
                </xsl:when>
                <xsl:when test="$element-one-tokenized[1] eq 'lang'">
                    <xsl:value-of select="'foreign'"/>
                </xsl:when>
                <xsl:when test="$element-one-tokenized[1] = ('http', 'https')">
                    <xsl:value-of select="'ref'"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <!-- If it's a note derive the content from a different line -->
        <xsl:variable name="content">
            
            <xsl:choose>
                
                <xsl:when test="$element-name eq 'note'">
                    <xsl:value-of select="$lines[matches(., concat('^\s*', $content, '\)\s+'))][1] ! replace(., '^\s*\d+\)\s+', '')"/>
                </xsl:when>
                
                <xsl:otherwise>
                    <xsl:value-of select="$content"/>
                </xsl:otherwise>
                
            </xsl:choose>
            
        </xsl:variable>
        
        <xsl:choose>
            
            <!-- An element has been determined -->
            <xsl:when test="$element-name">
                
                <xsl:value-of select="$leading-space"/>
                
                <!-- Add the element -->
                <xsl:element name="{ $element-name }" namespace="{ $namespace }">
                    
                    <!-- Add attributes based on first token -->
                    <xsl:choose>
                        <xsl:when test="lower-case($element-one) = $known-langs ! lower-case(.)">
                            <xsl:attribute name="xml:lang" select="$known-langs[lower-case(.) eq lower-case($element-one)]"/>
                        </xsl:when>
                        <xsl:when test="$element-one-tokenized[1] eq 'lang'">
                            <xsl:call-template name="markdown:attributes">
                                <xsl:with-param name="md-string" select="$element-one"/>
                            </xsl:call-template>
                        </xsl:when>
                        <xsl:when test="$element-one-tokenized[1] = ('http', 'https')">
                            <xsl:attribute name="target" select="$element-one"/>
                        </xsl:when>
                        <xsl:when test="$element-name eq 'milestone'">
                            <xsl:attribute name="unit" select="'chunk'"/>
                        </xsl:when>
                        <xsl:when test="$element-name eq 'note'">
                            <xsl:attribute name="place" select="'end'"/>
                        </xsl:when>
                    </xsl:choose>
                    
                    <!-- Parse other attributes -->
                    <xsl:call-template name="markdown:attributes">
                        <xsl:with-param name="md-string" select="$element-rest"/>
                    </xsl:call-template>
                    
                    <!-- Add the content -->
                    <xsl:if test="normalize-space($content) gt ''">
                        
                        <!-- Parse content -->
                        <!-- Remove a bracket from nested brackets - single brackets get parsed e.g. [[data]](tag) (will be ignored) -> [data](tag) (will be marked up) -->
                        <xsl:variable name="content-unnested" select="replace(replace($content, '(\]{2})([^\]])', ']$2'), '(\[{2})([^\[])', '[$2')"/>
                        <xsl:analyze-string select="$content-unnested" regex="{ $element-regex }">
                            
                            <xsl:matching-substring>
                                <xsl:call-template name="markdown:element">
                                    <xsl:with-param name="md-string" select="."/>
                                    <xsl:with-param name="namespace" select="$namespace"/>
                                    <xsl:with-param name="lines" select="$lines"/>
                                    <xsl:with-param name="leading-space" select="if(matches(., '^\s+')) then ' ' else ''"/>
                                    <xsl:with-param name="trailing-space" select="if(matches(., '\s+$')) then ' ' else ''"/>
                                </xsl:call-template>
                            </xsl:matching-substring>
                            
                            <xsl:non-matching-substring>
                                <xsl:value-of select="."/>
                            </xsl:non-matching-substring>
                            
                        </xsl:analyze-string>
                        
                    </xsl:if>
                    
                </xsl:element>
                
                <xsl:value-of select="$trailing-space"/>
                
            </xsl:when>
            
            <!-- No element determined -->
            <xsl:otherwise>
                <xsl:value-of select="$md-string"/>
            </xsl:otherwise>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Create attributes from markdown string -->
    <xsl:template name="markdown:attributes">
        
        <xsl:param name="md-string" as="xs:string*"/>
        
        <xsl:for-each select="$md-string">
            
            <xsl:variable name="attribute-tokenized" select="tokenize(., ':')"/>
            
            <xsl:if test="count($attribute-tokenized) eq 2">
                <xsl:choose>
                    <xsl:when test="$attribute-tokenized[1] eq 'lang'">
                        <xsl:attribute name="xml:lang" select="($known-langs[lower-case(.) eq lower-case($attribute-tokenized[2])], $attribute-tokenized[2])[1]"/>
                    </xsl:when>
                    <xsl:when test="$attribute-tokenized[1] eq 'id'">
                        <xsl:attribute name="xml:id" select="$attribute-tokenized[2]"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:attribute name="{ $attribute-tokenized[1] }" select="$attribute-tokenized[2]"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
            
        </xsl:for-each>
        
    </xsl:template>
    
    <!-- Create a markdown string from an element -->
    <xsl:template name="markdown:string">
        
        <xsl:param name="node" as="node()"/>
        <xsl:param name="markup" as="node()*"/>
        <xsl:param name="new-line" as="xs:boolean" select="false()"/>
        <xsl:param name="nesting" as="xs:integer" select="1"/>
        
        <xsl:if test="$new-line">
            <xsl:value-of select="$char-nl"/>
        </xsl:if>
        
        <xsl:choose>
            
            <!-- Text node -->
            <xsl:when test="$node instance of text()">
                <xsl:value-of select="replace($node/data(), '\s+', ' ')"/>
            </xsl:when>
            
            <!-- Element -->
            <xsl:when test="$node instance of element()">
                
                <!-- Add data in square brackets -->
                <xsl:if test="$node[data()] or not($new-line)">
                    
                    <xsl:value-of select="functx:repeat-string('[', $nesting)"/>
                    
                    <xsl:choose>
                        
                        <!-- If it's an end note then just output the number e.g. 1) -->
                        <xsl:when test="$node[self::tei:note[@place eq 'end']]">
                            <xsl:value-of select="common:index-of-node($markup//tei:note[@place eq 'end'], $node)"/>
                        </xsl:when>
                        
                        <!-- Otherwise parse the sub nodes -->
                        <xsl:otherwise>
                            <xsl:for-each select="$node/node()">
                                <xsl:call-template name="markdown:string">
                                    <xsl:with-param name="node" select="."/>
                                    <xsl:with-param name="nesting" select="$nesting + 1"/>
                                </xsl:call-template>
                            </xsl:for-each>
                        </xsl:otherwise>
                        
                    </xsl:choose>
                    
                    <xsl:value-of select="functx:repeat-string(']', $nesting)"/>
                    
                </xsl:if>
                
                <!-- Attributes string -->
                <xsl:variable name="attributes-strings" as="xs:string*">
                    
                    <xsl:variable name="exclude-attributes" as="xs:string*">
                        <xsl:value-of select="'tid'"/>
                        <xsl:choose>
                            <xsl:when test="local-name($node) eq 'milestone'">
                                <xsl:value-of select="'unit'"/>
                            </xsl:when>
                            <xsl:when test="local-name($node) eq 'note' and $node[@place eq 'end']">
                                <xsl:value-of select="'index'"/>
                                <xsl:value-of select="'place'"/>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:variable>
                    
                    <xsl:variable name="included-attributes" select="$node/@*[not(local-name(.) = $exclude-attributes)]"/>
                    
                    <xsl:choose>
                        <xsl:when test="count($included-attributes) eq 1 and local-name($node) eq 'foreign' and local-name($included-attributes[1]) eq 'lang' and $known-langs[lower-case(.) eq lower-case($included-attributes[1])]">
                            <xsl:value-of select="$known-langs[lower-case(.) eq lower-case($included-attributes[1])]"/>
                        </xsl:when>
                        <xsl:when test="count($included-attributes) eq 1 and local-name($node) eq 'ref' and local-name($included-attributes[1]) eq 'target' and matches($included-attributes[1]/string(), '^(http:|https:)')">
                            <xsl:value-of select="$included-attributes[1]/string()"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$included-attributes ! concat(local-name(.), ':', string())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:variable>
                
                <!-- Element name -->
                <xsl:variable name="element-name" as="xs:string*">
                    <xsl:choose>
                        <xsl:when test="count($attributes-strings) eq 1 and ($known-langs[. eq $attributes-strings[1]] or matches($attributes-strings[1], '^(http:|https:)'))">
                            <!-- Short code: no element name required -->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="local-name($node)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <!-- Add element name & attributes in round brackets -->
                <xsl:value-of select="concat('(', string-join(($element-name, $attributes-strings), ' '), ')')"/>
                
            </xsl:when>
            
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Markdown help guide -->
    <xsl:template name="markdown:guide">
        
        <h3>
            <xsl:value-of select="'Using Markdown'"/>
        </h3>
        
        <div class="small">
            
            <p class="text-muted">
                <xsl:value-of select="'Markdown is a standard for marking-up content using simplified syntax. '"/>
                <xsl:value-of select="'Here we have extended the markdown standard to allow us to update TEI.'"/>
                <br/>
                <span class="text-danger uppercase">
                    <xsl:value-of select="'Note: this is NOT standard markdown.'"/>
                </span>
            </p>
            
            <p>
                <xsl:value-of select="'To add a new paragraph simply start a new line'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'A paragraph has no line breaks in it.'"/>
                <br/>
                <br/>
                <xsl:value-of select="'A new paragraph comes after a line break.'"/>
                <br/>
            </pre>
            
            <p>
                <xsl:value-of select="'Specify a heading with a #'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'# Heading'"/>
            </pre>
            
            <p>
                <xsl:value-of select="'Easily define lists'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'* First bullet list item'"/>
                <br/>
                <xsl:value-of select="'* Next bullet list item'"/>
                <br/>
                <br/>
                <xsl:value-of select="'1. First numbered list item'"/>
                <br/>
                <xsl:value-of select="'2. Next numbered list item'"/>
                <br/>
                <br/>
                <xsl:value-of select="'a. First lettered list item'"/>
                <br/>
                <xsl:value-of select="'b. Next lettered list item'"/>
                <br/>
            </pre>
            
            <p>
                <xsl:value-of select="'There are also some short-code tags'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'(lb)'"/>
                <br/>
                <xsl:value-of select="'This paragraph will have an extra line of space above.'"/>
                <br/>
                <br/>
                <xsl:value-of select="'(milestone)'"/>
                <br/>
                <xsl:value-of select="'This paragraph has a milestone in the margin.'"/>
                <br/>
                <br/>
                <xsl:value-of select="'The term [Maitrāyanī](Sa-Ltn) is tagged as Sanskrit.'"/>
                <br/>
                <br/>
                <xsl:value-of select="'This [84000.co](https://84000.co) will be rendered as a link.'"/>
                <br/>
            </pre>
            
            <p>
                <xsl:value-of select="'All other TEI tags are supported by selecting the text in square brackets followed by the tag definition in round brackets.'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'You can specify a tag for any text inline [Karmaśataka](title). '"/>
                <br/>
                <br/>
                <xsl:value-of select="'Add the language attribute [Karmaśataka](title lang:Sa-Ltn).'"/>
                <br/>
                <br/>
                <xsl:value-of select="'And add further attributes [Karmaśataka](title lang:Sa-Ltn ref:entity-123).'"/>
                <br/>
            </pre>
            
            <p>
                <xsl:value-of select="'Add foot notes at the end of the text'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'Add a note tag in a paragraph [1](note).'"/>
                <br/>
                <br/>
                <xsl:value-of select="'1) Add the content of the note at the end of the text.'"/>
                <br/>
                <br/>
                <xsl:value-of select="'Note: numbers must correspond '"/>
                <br/>
                <xsl:value-of select="'e.g. [7](note) references 7) Text for note 7.'"/>
                <br/>
            </pre>
            
            <p class="text-danger">
                <xsl:value-of select="'Beware! You may encounter complex nesting of elements.'"/>
            </p>
            <pre class="wrap">
                <xsl:value-of select="'For instance link to [[[The Teaching of [[[Vimalakīrti]]](term ref:entity-123)]](http://read.84000.co/translation/toh176.html)](title lang:en) (Toh 176).'"/>
            </pre>
            <p class="text-danger">
                <xsl:value-of select="'If in doubt leave brackets alone. Editing of complex structures is best done by markup editors working directly with the TEI.'"/>
            </p>
            
        </div>
    </xsl:template>
    
    <!-- Mark matches -->
    <xsl:template match="exist:match">
        <span class="mark">
            <xsl:apply-templates select="text()"/>
        </span>
    </xsl:template>
    
    <!-- History -->
    <xsl:template match="m:status-updates">
        
        <xsl:if test="m:status-update[@date-time]">
            
            <div class="match-height-overflow" data-match-height="status-form">
                
                <h4 class="no-top-margin no-bottom-margin">
                    <xsl:value-of select="'History'"/>
                </h4>
                
                <hr class="sml-margin"/>
                
                <ul class="small list-unstyled">
                    <xsl:for-each select="m:status-update[@date-time]">
                        
                        <xsl:sort select="xs:dateTime(@date-time)" order="descending"/>
                        
                        <li>
                            
                            <div class="text-bold">
                                <xsl:choose>
                                    <xsl:when test="local-name(.) eq 'status-update'">
                                        <xsl:choose>
                                            <xsl:when test="@update eq 'text-version'">
                                                <xsl:value-of select="'Version update: ' || @value"/>
                                            </xsl:when>
                                            <xsl:when test="@update = ('translation-status', 'publication-status')">
                                                <xsl:value-of select="'Status update: ' || @value"/>
                                            </xsl:when>
                                        </xsl:choose>
                                        <xsl:if test="text() and not(text() eq @value)">
                                            <xsl:value-of select="concat(' / ', text())"/>
                                        </xsl:if>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="text()"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </div>
                            
                            <div class="text-muted italic">
                                <xsl:choose>
                                    <xsl:when test="local-name(.) eq 'status-update'">
                                        <xsl:value-of select="common:date-user-string('- Set ', @date-time, @user)"/>
                                    </xsl:when>
                                    <xsl:when test="local-name(.) eq 'task'">
                                        <xsl:value-of select="common:date-user-string('- Set ', @checked-off, @checked-off-by)"/>
                                    </xsl:when>
                                </xsl:choose>
                            </div>
                            
                        </li>
                        
                    </xsl:for-each>
                </ul>
            </div>
        </xsl:if>
        
    </xsl:template>
    
</xsl:stylesheet>