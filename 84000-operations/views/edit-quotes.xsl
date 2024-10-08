<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:output="http://www.w3.org/2010/xslt-xquery-serialization" xmlns:scheduler="http://exist-db.org/xquery/scheduler" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:ops="http://operations.84000.co" xmlns:common="http://read.84000.co/common" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/tei-to-xhtml.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:variable name="response" select="/m:response"/>
    <xsl:variable name="request-resource-id" select="$response/m:request/@resource-id" as="xs:string"/>
    <xsl:variable name="request-part" select="$response/m:request/@part" as="xs:string?"/>
    <xsl:variable name="request-root" select="$response/m:request/@root" as="xs:string?"/>
    
    <xsl:variable name="text" select="$response/m:text[1]"/>
    <xsl:variable name="main-title" select="$text/m:titles/m:title[@xml:lang eq 'en'][1]"/>
    <xsl:variable name="quotes" select="$response/m:quotes[1]"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <xsl:call-template name="operations-page">
                
                <xsl:with-param name="active-tab" select="@model"/>
                
                <xsl:with-param name="tab-content">
                    
                    <xsl:call-template name="alert-updated"/>
                    
                    <xsl:call-template name="alert-translation-locked"/>
                    
                    <!-- Page title -->
                    <h3 class="visible-print-block no-top-margin">
                        <xsl:value-of select="'Review Quotes'"/>
                    </h3>
                    
                    <!-- Title / status -->
                    <div class="center-vertical full-width sml-margin bottom">
                        
                        <div class="h3">
                            <a target="_blank">
                                <xsl:attribute name="href" select="m:translation-href(($text/m:toh/@key)[1], (), (), (), (), $reading-room-path)"/>
                                <xsl:value-of select="concat(string-join($text/m:toh/m:full, ' / '), ' / ', $main-title)"/>
                            </a>
                        </div>
                        
                        <div class="text-right">
                            <xsl:sequence select="ops:translation-status($text/@status-group)"/>
                        </div>
                        
                    </div>
                    
                    <!-- Links -->
                    <xsl:call-template name="text-links-list">
                        <xsl:with-param name="text" select="$text"/>
                        <xsl:with-param name="disable-links" select="('edit-quotes')"/>
                        <xsl:with-param name="text-status" select="$response/m:text-statuses/m:status[@status-id eq $text/@status]"/>
                    </xsl:call-template>
                    
                    <hr class="sml-margin"/>
                    
                    <!-- Navigation -->
                    <div class="center-vertical align-left">
                        
                        <!-- Select part -->
                        <div>
                            <form action="/edit-quotes.html" class="form-inline" data-loading="Reviewing quotes...">
                                
                                <input type="hidden" name="resource-id" value="{ $request-resource-id }"/>
                                
                                <select name="part" class="form-control">
                                    <xsl:for-each select="$text/m:part[@type eq 'translation']/m:part">
                                        <option>
                                            <xsl:if test="@id eq $request-part">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:attribute name="value" select="@id"/>
                                            <xsl:value-of select="(tei:head[@type eq parent::m:part/@type], '[Section with no header]')[1]"/>
                                        </option>
                                    </xsl:for-each>
                                </select>
                                
                                <select name="root" class="form-control">
                                    <xsl:for-each select="$text/m:source/m:isCommentaryOf">
                                        <option>
                                            <xsl:if test="@toh-key eq $request-root">
                                                <xsl:attribute name="selected" select="'selected'"/>
                                            </xsl:if>
                                            <xsl:attribute name="value" select="@toh-key"/>
                                            <xsl:value-of select="(tei:bibl/tei:ref, '[Root with no Toh]')[1]"/>
                                        </option>
                                    </xsl:for-each>
                                </select>
                                
                                <button class="btn btn-default" type="submit">
                                    <i class="fa fa-refresh"/>
                                </button>
                                
                            </form>
                        </div>
                        
                        <!-- Quotes count -->
                        <div>
                            <span class="badge badge-notification">
                                <xsl:value-of select="format-number(count($quotes/m:quote),'#,###')"/>
                            </span>
                            <span class="badge-text">
                                <xsl:value-of select="'quotes'"/>
                            </span>
                        </div>
                        
                    </div>
                    
                    <hr class="sml-margin"/>
                    
                    <!-- Quotes list -->
                    <div id="quotes-list" class="tests">
                        
                        <xsl:variable name="quotes-with-issues" select="$quotes/m:quote[not(@status eq 'complete')]"/>
                        <h4>
                            <xsl:value-of select="'Quotes with issues '"/>
                            <span class="badge badge-notification">
                                <xsl:if test="not($quotes-with-issues)">
                                    <xsl:attribute name="class" select="'badge badge-notification badge-muted'"/>
                                </xsl:if>
                                <xsl:value-of select="format-number(count($quotes-with-issues),'#,###')"/>
                            </span>
                        </h4>
                        <xsl:for-each select="$quotes-with-issues">
                            
                            <xsl:sort select="xs:integer(@index)"/>
                            
                            <xsl:call-template name="quote-item">
                                <xsl:with-param name="quote" select="."/>
                            </xsl:call-template>
                            
                        </xsl:for-each>
                        
                        <hr class="sml-margin"/>
                        
                        <xsl:variable name="quotes-without-issues" select="$quotes/m:quote[@status eq 'complete']"/>
                        <h4>
                            <xsl:value-of select="'Validated quotes '"/>
                            <span class="badge badge-notification badge-muted">
                                <xsl:value-of select="format-number(count($quotes-without-issues),'#,###')"/>
                            </span>
                        </h4>
                        <xsl:for-each select="$quotes-without-issues">
                            
                            <xsl:sort select="xs:integer(@index)"/>
                            
                            <xsl:call-template name="quote-item">
                                <xsl:with-param name="quote" select="."/>
                            </xsl:call-template>
                            
                        </xsl:for-each>
                        
                    </div>
                    
                </xsl:with-param>
            
                <xsl:with-param name="aside-content">
                    
                    <!-- Dual-view pop-up -->
                    <xsl:call-template name="dualview-popup"/>
                    
                </xsl:with-param>
                
            </xsl:call-template>
        
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title">
                <xsl:if test="$text[m:toh]">
                    <xsl:value-of select="$text/m:toh/m:full/data()"/>
                    <xsl:value-of select="' | '"/>
                </xsl:if>
                <xsl:value-of select="common:limit-str($main-title, 80)"/>
                <xsl:value-of select="' | '"/>
                <xsl:value-of select="'Quotes'"/>
                <xsl:value-of select="' | '"/>
                <xsl:value-of select="'84000 Project Management'"/>
            </xsl:with-param>
            <xsl:with-param name="page-description" select="'84000 Quotes'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="quote-item">
        
        <xsl:param name="quote" as="element(m:quote)"/>
        
        <div class="list-group accordion accordion-bordered" role="tablist" aria-multiselectable="false">
            
            <xsl:attribute name="id" select="concat('quote-accordion-', $quote/@id)"/>
            
            <!-- Configuration -->
            <xsl:call-template name="expand-item">
                
                <xsl:with-param name="id" select="concat('quote-configuration-', $quote/@id)"/>
                <xsl:with-param name="accordion-selector" select="concat('#quote-accordion-', $quote/@id)"/>
                <xsl:with-param name="active" select="false()"/>
                <xsl:with-param name="persist" select="true()"/>
                
                <xsl:with-param name="title">
                    <div class="top-vertical align-left">
                        
                        <!-- Success / fail icon -->
                        <div class="icon">
                            <xsl:choose>
                                <xsl:when test="$quote[@status eq 'complete']">
                                    <i class="fa fa-check-circle"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <i class="fa fa-times-circle"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                        
                        <!-- Quote text -->
                        <div class="tei-parser">
                            <xsl:choose>
                                
                                <xsl:when test="$quote/tei:q//text()[not(ancestor::tei:note)][not(ancestor::tei:orig)][normalize-space(.)]">
                                    <xsl:choose>
                                        
                                        <xsl:when test="$quote/m:highlight">
                                            <div class="quote-style-underline">
                                                <xsl:apply-templates select="$quote/tei:q/node()"/>
                                            </div>
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <xsl:apply-templates select="$quote/tei:q/node()"/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                </xsl:when>
                                
                                <xsl:otherwise>
                                    <xsl:value-of select="'[empty]'"/>
                                </xsl:otherwise>
                                
                            </xsl:choose>
                        </div>
                        
                        <div class="text-muted">
                            <xsl:value-of select="'/'"/>
                        </div>
                        
                        <!-- Quote id -->
                        <div>
                            <div>
                                <a class="small">
                                    <xsl:attribute name="href" select="m:translation-href($quote/@resource-id, (), (), $quote/@id, (), $reading-room-path)"/>
                                    <xsl:attribute name="target" select="concat($quote/@resource-id, '.html')"/>
                                    <xsl:value-of select="$quote/@id"/>
                                </a>
                            </div>
                        </div>
                        
                    </div>
                </xsl:with-param>
                
                <xsl:with-param name="content">
                    
                    <div class="top-margin">
                        
                        <!-- Tabs -->
                        <ul class="nav nav-tabs" role="tablist">
                            <li role="presentation">
                                <a role="tab" data-toggle="tab">
                                    <xsl:attribute name="href" select="concat('#quote-configuration-', $quote/@id, '-tei')"/>
                                    <xsl:attribute name="aria-controls" select="concat('quote-configuration-', $quote/@id, '-tei')"/>
                                    <xsl:value-of select="'TEI'"/>
                                </a>
                            </li>
                            <li role="presentation" class="active">
                                <a role="tab" data-toggle="tab">
                                    <xsl:attribute name="href" select="concat('#quote-configuration-', $quote/@id, '-regex')"/>
                                    <xsl:attribute name="aria-controls" select="concat('quote-configuration-', $quote/@id, '-regex')"/>
                                    <xsl:value-of select="'REGEX'"/>
                                </a>
                            </li>
                        </ul>
                        
                        <div class="tab-content">
                            
                            <!-- TEI tab -->
                            <div role="tabpanel" class="tab-pane">
                                
                                <xsl:attribute name="id" select="concat('quote-configuration-', $quote/@id, '-tei')"/>
                                
                                <xsl:variable name="quote-tei">
                                    <unescaped xmlns="http://read.84000.co/ns/1.0">
                                        <xsl:sequence select="$quote/tei:q"/>
                                    </unescaped>
                                </xsl:variable>
                                <code>
                                    <xsl:apply-templates select="$quote-tei/node()"/>
                                </code>
                                
                            </div>
                            
                            <!-- Regex tab -->
                            <div role="tabpanel" class="tab-pane active">
                                
                                <xsl:attribute name="id" select="concat('quote-configuration-', $quote/@id, '-regex')"/>
                                
                                <xsl:choose>
                                    <xsl:when test="$quote/m:highlight">
                                        
                                        <ul class="list-unstyled">
                                            <xsl:for-each select="$quote/m:highlight">
                                                
                                                <xsl:variable name="highlight" select="." as="element(m:highlight)"/>
                                                
                                                <li>
                                                    
                                                    <!--<xsl:value-of select="concat($highlight/@index, '.')"/>-->
                                                    
                                                    <span class="icon">
                                                        <xsl:choose>
                                                            <xsl:when test="$quote/m:source-html//xhtml:span[@data-quote-id eq $quote/@id][@data-quote-highlight eq $highlight/@index]">
                                                                <i class="fa fa-check-circle"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <i class="fa fa-times-circle"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </span>
                                                    
                                                    <xsl:value-of select="' '"/>
                                                    
                                                    <xsl:if test="$highlight/@regex-preceding">
                                                        <code class="break">
                                                            <xsl:value-of select="$highlight/@regex-preceding"/>
                                                        </code>
                                                        <xsl:value-of select="' ⟶ '"/>
                                                    </xsl:if>
                                                    
                                                    <code class="break">
                                                        <xsl:value-of select="concat($highlight/@target, '[', $highlight/@occurrence, ']')"/>
                                                    </code>
                                                    
                                                    <xsl:if test="$highlight/@regex-following">
                                                        <xsl:value-of select="' ⟶ '"/>
                                                        <code class="break">
                                                            <xsl:value-of select="$highlight/@regex-following"/>
                                                        </code>
                                                    </xsl:if>
                                                    
                                                </li>
                                                
                                            </xsl:for-each>
                                        </ul>
                                        
                                    </xsl:when>
                                    <xsl:otherwise>
                                        
                                        <span class="text-muted italic">
                                            <xsl:value-of select="'No highlight directives'"/>
                                        </span>
                                        
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                            </div>
                            
                        </div>
                        
                    </div>
                    
                </xsl:with-param>
                
            </xsl:call-template>
            
            <!-- Output -->
            <xsl:call-template name="expand-item">
                
                <xsl:with-param name="id" select="concat('quote-highlight-', $quote/@id)"/>
                <xsl:with-param name="accordion-selector" select="concat('#quote-accordion-', $quote/@id)"/>
                <xsl:with-param name="active" select="if($quote/m:highlight) then true() else false()"/>
                <xsl:with-param name="persist" select="true()"/>
                
                <xsl:with-param name="title">
                    
                    <div class="top-vertical text-muted">
                        
                        <div>
                            <xsl:value-of select="' ↳ '"/>
                        </div>
                        
                        <div>
                            <span class="label label-info">
                                <xsl:value-of select="$quote/m:source/m:toh/m:full"/>
                            </span>
                        </div>
                        
                        <div>
                            <span class="italic">
                                <xsl:value-of select="concat('This quote references ', $quote/m:source/m:text-title)"/>
                            </span>
                        </div>
                        
                        <div>
                            <xsl:value-of select="'/'"/>
                        </div>
                        
                        <div>
                            <a class="small">
                                <xsl:attribute name="href" select="m:translation-href($quote/m:source/@resource-id, (), (), $quote/m:source/@location-id, (), $reading-room-path)"/>
                                <xsl:attribute name="target" select="concat($quote/m:source/@resource-id, '.html')"/>
                                <xsl:value-of select="$quote/m:source/@location-id"/>
                            </a>
                        </div>
                        
                    </div>
                    
                </xsl:with-param>
                
                <xsl:with-param name="content">
                    
                    <div class="top-margin">
                        
                        <!-- Tabs -->
                        <ul class="nav nav-tabs" role="tablist">
                            <li role="presentation">
                                <a role="tab" data-toggle="tab">
                                    <xsl:attribute name="href" select="concat('#quote-highlight-', $quote/@id, '-tei')"/>
                                    <xsl:attribute name="aria-controls" select="concat('quote-highlight-', $quote/@id, '-tei')"/>
                                    <xsl:value-of select="'TEI'"/>
                                </a>
                            </li>
                            <li role="presentation" class="active">
                                <a role="tab" data-toggle="tab">
                                    <xsl:attribute name="href" select="concat('#quote-highlight-', $quote/@id, '-html')"/>
                                    <xsl:attribute name="aria-controls" select="concat('quote-highlight-', $quote/@id, '-html')"/>
                                    <xsl:value-of select="'HTML'"/>
                                </a>
                            </li>
                        </ul>
                        
                        <div class="tab-content">
                            
                            <!-- TEI tab -->
                            <div role="tabpanel" class="tab-pane">
                                
                                <xsl:attribute name="id" select="concat('quote-highlight-', $quote/@id, '-tei')"/>
                                
                                <xsl:variable name="source-tei">
                                    <unescaped xmlns="http://read.84000.co/ns/1.0">
                                        <xsl:sequence select="$quote/m:source-tei/*"/>
                                    </unescaped>
                                </xsl:variable>
                                
                                <code>
                                    <xsl:apply-templates select="$source-tei/node()"/>
                                </code>
                                
                            </div>
                            
                            <!-- HTML tab -->
                            <div role="tabpanel" class="tab-pane active">
                                
                                <xsl:attribute name="id" select="concat('quote-highlight-', $quote/@id, '-html')"/>
                                
                                <xsl:apply-templates select="$quote/m:source-html"/>
                                
                            </div>
                            
                        </div>
                        
                    </div>
                    
                </xsl:with-param>
                
            </xsl:call-template>
            
        </div>
        
    </xsl:template>
    
    <xsl:template match="m:source-html">
        <div class="tei-parser underline-quoted">
            <div class="clearfix">
                <xsl:apply-templates select="node()"/>
            </div>
        </div>
    </xsl:template>
    
    <!-- Copy xhtml nodes -->
    <xsl:template match="xhtml:*">
        
        <xsl:choose>
            <xsl:when test="self::xhtml:div[matches(@class, '(^|\s+)gtr(\s+|$)', 'i')]">
                <!-- Skip -->
            </xsl:when>
            <xsl:when test="self::xhtml:a[matches(@class, '(^|\s+)quote-link(\s+|$)', 'i')]">
                <!-- Skip -->
            </xsl:when>
            <xsl:when test="self::xhtml:div">
                <xsl:apply-templates select="node()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:copy-of select="@*"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>
    
    <!-- Copy fn nodes for debug -->
    <xsl:template match="fn:*">
        
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
        
    </xsl:template>
    
    <xsl:template match="text()">
        
        <xsl:value-of select="."/>
        
    </xsl:template>
    
    <xsl:template match="xhtml:span[contains(@class, 'quoted')][@data-quote-id eq ancestor::m:quote/@id]">
        <span>
            <xsl:copy-of select="@*[not(local-name(.) eq 'class')]"/>
            <xsl:attribute name="class" select="concat(@class, ' dualview-active')"/>
            <xsl:apply-templates select="node()"/>
        </span>
    </xsl:template>
    
    <xsl:template name="link-href">
        
        <xsl:param name="resource-id" as="xs:string" select="$request-resource-id"/>
        <xsl:param name="part" select="$request-part"/>
        <xsl:param name="add-parameters" as="xs:string*" select="()"/>
        
        <xsl:variable name="parameters" as="xs:string*">
            
            <!-- Maintain the state of the page -->
            <xsl:value-of select="concat('resource-id=', $resource-id)"/>
            <xsl:value-of select="concat('part=', $part)"/>
            
            <!-- Additional other parameters -->
            <xsl:sequence select="$add-parameters"/>
            
        </xsl:variable>
        
        <xsl:value-of select="concat('/edit-quotes.html?', string-join($parameters, '&amp;'))"/>
        
    </xsl:template>
    
</xsl:stylesheet>