<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:function name="m:test-result" as="item()*">
        
        <xsl:param name="success" as="xs:boolean" required="yes"/>
        <xsl:param name="cell-id" as="xs:string" required="yes"/>
        <xsl:param name="text-id" as="xs:string*" required="yes"/>
        <xsl:param name="text-title" as="xs:string*" required="yes"/>
        <xsl:param name="test-title" as="xs:string" required="yes"/>
        <xsl:param name="test-domain" as="xs:string" required="yes"/>
        <xsl:param name="test-detail" as="node()" required="yes"/>
        
        <a role="button" class="pop-up">
            <xsl:attribute name="href" select="concat('#', $cell-id)"/>
            <xsl:choose>
                <xsl:when test="$success">
                    <i class="fa fa-check-circle"/>
                </xsl:when>
                <xsl:otherwise>
                    <i class="fa fa-times-circle"/>
                </xsl:otherwise>
            </xsl:choose>
        </a>
        
        <div class="hidden">
            <div>
                <xsl:attribute name="id" select="$cell-id"/>
                <h3 class="sml-margin bottom">
                    <xsl:choose>
                        <xsl:when test="$success">
                            <i class="fa fa-check-circle"/>
                            <xsl:value-of select="' Passed Test '"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <i class="fa fa-times-circle"/>
                            <xsl:value-of select="' Failed Test '"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </h3>
                <p class="italic sml-margin bottom text-danger">
                    <xsl:value-of select="$test-title"/>
                </p>
                <div>
                    <ul class="list-inline inline-dots">
                        <li>
                            <xsl:value-of select="$text-title"/>
                        </li>
                        <li>
                            <xsl:value-of select="$text-id"/>
                        </li>
                        <li>
                            <a>
                                <xsl:attribute name="href" select="concat($test-domain, '/translation/', $text-id, '.html?view-mode=tests')"/>
                                <xsl:attribute name="target" select="concat($text-id, '-html')"/>
                                <xsl:value-of select="'html'"/>
                            </a>
                        </li>
                        <li>
                            <a>
                                <xsl:attribute name="href" select="concat($test-domain, '/translation/', $text-id, '.xml?view-mode=tests')"/>
                                <xsl:attribute name="target" select="concat($text-id, '-xml')"/>
                                <xsl:value-of select="'xml'"/>
                            </a>
                        </li>
                        <li>
                            <a>
                                <xsl:attribute name="href" select="concat($test-domain, '/translation/', $text-id, '.tei')"/>
                                <xsl:attribute name="target" select="concat($text-id, '-tei')"/>
                                <xsl:value-of select="'tei'"/>
                            </a>
                        </li>
                    </ul>
                </div>
                <div>
                    <ul>
                        <xsl:for-each select="$test-detail/m:detail">
                            <li>
                                <xsl:if test="@type eq 'debug'">
                                    <xsl:attribute name="class" select="'debug'"/>
                                </xsl:if>
                                <xsl:copy-of select="node()"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </div>
            </div>
        </div>
        
    </xsl:function>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <form action="/test-translations.html" method="get" class="form-inline filter-form" data-loading="Loading...">
                <div class="form-group">
                    <xsl:variable name="request-translation-id" as="xs:string">
                        <xsl:choose>
                            <xsl:when test="/m:response/m:request/m:parameter[@name eq 'translation-id']">
                                <xsl:value-of select="/m:response/m:request/m:parameter[@name eq 'translation-id']"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="''"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <select name="translation-id" id="translation-id" class="form-control">
                        <option value="all">
                            <xsl:if test="$request-translation-id eq 'all'">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'All translations'"/>
                        </option>
                        <option value="published">
                            <xsl:if test="$request-translation-id eq 'published'">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'Published translations'"/>
                        </option>
                        <option value="in-markup">
                            <xsl:if test="$request-translation-id eq 'in-markup'">
                                <xsl:attribute name="selected" select="'selected'"/>
                            </xsl:if>
                            <xsl:value-of select="'Translations in markup'"/>
                        </option>
                        <xsl:for-each select="m:translations/m:file">
                            <xsl:sort select="@id"/>
                            <option>
                                <xsl:attribute name="value" select="@id"/>
                                <xsl:if test="@id eq $request-translation-id">
                                    <xsl:attribute name="selected" select="'selected'"/>
                                </xsl:if>
                                <xsl:value-of select="common:limit-str(concat(@file-name, ' / ', data(.)), 140)"/>
                            </option>
                        </xsl:for-each>
                        <xsl:if test="not(m:translations/m:file[@id eq $request-translation-id])">
                            <option>
                                <xsl:attribute name="value" select="$request-translation-id"/>
                                <xsl:attribute name="selected" select="'selected'"/>
                                <xsl:value-of select="'[Text not found] ' || $request-translation-id"/>
                            </option>
                        </xsl:if>
                    </select>
                </div>
                <div class="form-group">
                    <button class="btn btn-default" type="submit">
                        <i class="fa fa-refresh"/>
                    </button>
                </div>
            </form>
            
            <table class="table table-responsive table-icons">
                <thead>
                    <tr>
                        <th>Text</th>
                        <th>Status</th>
                        <th>Load time</th>
                        <xsl:for-each select="//m:results/m:translation[1]/m:tests/m:test">
                            <th class="icon">
                                <xsl:value-of select="position()"/>
                            </th>
                        </xsl:for-each>
                        <th class="icon">filter</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="m:results/m:translation">
                        <xsl:sort select="count(m:tests/m:test[@pass eq '1'])" order="ascending"/>
                        <xsl:sort select="number(@duration)" order="descending"/>
                        <xsl:variable name="table-row" select="position()"/>
                        <xsl:variable name="toh-key" select="m:toh/@key"/>
                        <xsl:variable name="text-id" select="@id"/>
                        <xsl:variable name="text-title" select="m:title/text()"/>
                        <xsl:variable name="test-domain" select="@test-domain"/>
                        <tr>
                            <td>
                                <a>
                                    <xsl:attribute name="href" select="concat($test-domain, '/translation/', $toh-key, '.html?view-mode=tests')"/>
                                    <xsl:attribute name="title" select="$text-title"/>
                                    <xsl:attribute name="target" select="$toh-key"/>
                                    <xsl:value-of select="m:toh/m:full"/>
                                </a>
                            </td>
                            <td>
                                <xsl:copy-of select="common:translation-status(@status-group)"/>
                            </td>
                            <td>
                                <span>
                                    
                                    <xsl:choose>
                                        
                                        <xsl:when test="number(@duration) gt 5">
                                            <xsl:attribute name="class" select="'label label-danger'"/>
                                        </xsl:when>
                                        
                                        <xsl:when test="number(@duration) gt 1">
                                            <xsl:attribute name="class" select="'label label-warning'"/>
                                        </xsl:when>
                                        
                                        <xsl:otherwise>
                                            <xsl:attribute name="class" select="'label label-default'"/>
                                        </xsl:otherwise>
                                        
                                    </xsl:choose>
                                    
                                    <xsl:value-of select="concat(@duration, ' secs')"/>
                                    
                                </span>
                            </td>
                            <xsl:for-each select="m:tests/m:test">
                                <xsl:variable name="test-id" select="position()"/>
                                <xsl:variable name="cell-id" select="concat('col-', $test-id,'row-', $table-row)"/>
                                <xsl:variable name="test-title" select="concat($test-id, '. ', m:title/text())"/>
                                <xsl:variable name="test-result" select="xs:boolean(@pass)"/>
                                <xsl:variable name="test-details" select="m:details"/>
                                <td class="icon">
                                    <xsl:sequence select="m:test-result($test-result, $cell-id, $toh-key, $text-title, $test-title, $test-domain, $test-details)"/>
                                </td>
                            </xsl:for-each>
                            <td class="icon">
                                <a>
                                    <xsl:attribute name="href" select="concat('?translation-id=', $text-id)"/>
                                    <xsl:attribute name="title" select="'Run tests on this file only'"/>
                                    <xsl:attribute name="data-loading" select="'Applying filter...'"/>
                                    <i class="fa fa-filter"/>
                                </a>
                            </td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities tests'"/>
            <xsl:with-param name="page-title" select="'Translation Tests | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Automated tests for 84000 translations'"/>
            <xsl:with-param name="content">
                <xsl:call-template name="utilities-page">
                    <xsl:with-param name="content" select="$content"/>
                </xsl:call-template>
            </xsl:with-param>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>