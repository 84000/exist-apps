<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:exist="http://exist.sourceforge.net/NS/exist" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="../../84000-reading-room/xslt/functions.xsl"/>
    
    <xsl:template match="/m:response">
        <xsl:variable name="content">
            
            <div class="container">
                <div class="panel panel-default">
                    
                    <div class="panel-heading bold hidden-print center-vertical">
                        
                        <span class="title">
                            <xsl:value-of select="'Test Searches'"/>
                        </span>
                        
                    </div>
                    
                    <div class="panel-body min-height-md">
                        <ul class="nav nav-tabs active-tab-refresh" role="tablist">
                            <xsl:for-each select="m:langs/m:lang">
                                <li role="presentation">
                                    <xsl:if test="lower-case(@xml:lang) eq lower-case(/m:response/m:request/@lang)">
                                        <xsl:attribute name="class" select="'active'"/>
                                    </xsl:if>
                                    <a>
                                        <xsl:attribute name="href" select="concat('?lang=', lower-case(@xml:lang))"/>
                                        <xsl:value-of select="m:label"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                        
                        <div class="row">
                            <div class="col-sm-4">
                                
                                <!-- Form to add a new query -->
                                <form action="test-searches.html" method="post">
                                    <input type="hidden" name="action" value="add-test"/>
                                    <input type="hidden" name="lang">
                                        <xsl:attribute name="value" select="m:request/@lang"/>
                                    </input>
                                    <div class="input-group">
                                        <input type="text" name="test-string" class="form-control" placeholder="Add a query e.g. Sūtra"/>
                                        <span class="input-group-btn">
                                            <button class="btn btn-primary" type="submit">
                                                <xsl:value-of select="'Add'"/>
                                            </button>
                                        </span>
                                    </div>
                                </form>
                                
                                <!-- List of queries -->
                                
                                <table class="table table-responsive table-icons">
                                    <thead>
                                        <tr>
                                            <th colspan="2">
                                                <xsl:value-of select="'Query'"/>
                                            </th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="m:tests/m:test">
                                            <xsl:sort select="m:sort"/>
                                            <tr data-toggle="collapse" class="collapsed">
                                                <xsl:attribute name="data-target" select="concat('#test-results-', @xml:id)"/>
                                                <td>
                                                    <xsl:attribute name="class" select="common:lang-class(m:request/@lang)"/>
                                                    <xsl:value-of select="m:query"/>
                                                </td>
                                                <td class="icon">
                                                    <xsl:choose>
                                                        <xsl:when test="m:result[@invalid]">
                                                            <i class="fa fa-times-circle"/>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <i class="fa fa-check-circle"/>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                                
                            </div>
                            <div class="col-sm-8">
                                
                                <!-- Form to add new text to be searched (data) -->
                                <form action="test-searches.html" method="post" class="form-horizontal">
                                    <input type="hidden" name="action" value="add-data"/>
                                    <input type="hidden" name="lang">
                                        <xsl:attribute name="value" select="m:request/@lang"/>
                                    </input>
                                    <div class="form-group">
                                        <div class="col-sm-10">
                                            <div class="input-group">
                                                <input type="text" name="data-string" class="form-control" placeholder="String to be indexed e.g. Atyayajñānasūtra"/>
                                                <span class="input-group-btn">
                                                    <button class="btn btn-primary" type="submit">
                                                        <xsl:value-of select="'Add'"/>
                                                    </button>
                                                </span>
                                            </div>
                                        </div>
                                        <!-- 
                                        <div class="col-sm-2">
                                            <a role="button" data-toggle="collapse">
                                                <xsl:attribute name="href" select="'#test-results-all'"/>
                                                <xsl:attribute name="aria-controls" select="'test-results-all'"/>
                                                <xsl:choose>
                                                    <xsl:when test="m:request/@test-id eq 'all'">
                                                        <xsl:attribute name="class" select="'btn btn-default'"/>
                                                        <xsl:attribute name="aria-expanded" select="'true'"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:attribute name="class" select="'btn btn-default collapsed'"/>
                                                        <xsl:attribute name="aria-expanded" select="'false'"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:value-of select="'Add a match'"/>
                                            </a>
                                        </div> -->
                                        <div class="col-sm-2">
                                            <a role="button">
                                                <xsl:attribute name="href" select="concat('?action=reindex&amp;lang=', m:request/@lang)"/>
                                                <xsl:attribute name="class" select="'btn btn-default'"/>
                                                <xsl:value-of select="'Re-index'"/>
                                            </a>
                                        </div>
                                    </div>
                                </form>
                                
                                <!-- List of results -->
                                <div id="results-panel" class="replace">
                                    
                                    <xsl:for-each select="m:tests/m:test">
                                        <xsl:call-template name="result-set">
                                            <xsl:with-param name="test-id" select="@xml:id"/>
                                            <xsl:with-param name="lang" select="/m:response/m:request/@lang"/>
                                            <xsl:with-param name="query-string" select="m:query"/>
                                            <xsl:with-param name="results" select="m:result"/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                    
                                </div>
                                
                            </div>
                        </div>
                        
                    </div>
                </div>
            </div>
            
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities tests'"/>
            <xsl:with-param name="page-title" select="'Search Tests | 84000 Utilities'"/>
            <xsl:with-param name="page-description" select="'Automated tests for 84000 searches'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
    <xsl:template name="result-set">
        <xsl:param name="test-id" required="yes" as="xs:string"/>
        <xsl:param name="lang" required="yes" as="xs:string"/>
        <xsl:param name="query-string" required="yes" as="xs:string"/>
        <xsl:param name="results" required="yes"/>
        
        <div class="sml-margin top collapse fade" aria-expanded="false">
            
            <xsl:attribute name="id" select="concat('test-results-', $test-id)"/>
            <xsl:choose>
                <xsl:when test="/m:response/m:request/@test-id eq $test-id">
                    <xsl:attribute name="class" select="'sml-margin top collapse fade in'"/>
                    <xsl:attribute name="aria-expanded" select="'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="class" select="'sml-margin top collapse fade'"/>
                    <xsl:attribute name="aria-expanded" select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
            
            <table class="table">
                <thead>
                    <tr>
                        <th>
                            <xsl:value-of select="'#'"/>
                        </th>
                        <th>
                            <xsl:value-of select="$query-string"/>
                        </th>
                        <th colspan="2">
                            <xsl:value-of select="'Result'"/>
                        </th>
                        <th>
                            <xsl:value-of select="'Score'"/>
                        </th>
                        <th class="text-right">
                            <xsl:value-of select="concat('(', $lang, ' / ', $test-id,')')"/>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:choose>
                        <xsl:when test="$results">
                            <xsl:for-each select="$results">
                                <xsl:sort select="number(@score)" order="descending"/>
                                <tr>
                                    <td>
                                        <xsl:value-of select="concat(position(), '.')"/>
                                    </td>
                                    <td>
                                        <xsl:apply-templates select="m:data"/>
                                    </td>
                                    <td class="icon">
                                        <xsl:choose>
                                            <xsl:when test="@invalid = ('should', 'should-not')">
                                                <i class="fa fa-times-circle"/>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <i class="fa fa-check-circle"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    <td>
                                        <xsl:choose>
                                            <xsl:when test="@invalid = 'should'">
                                                <xsl:value-of select="'Not matched '"/>
                                                <span class="small text-muted">
                                                    <xsl:value-of select="' (but should)'"/>
                                                </span>
                                            </xsl:when>
                                            <xsl:when test="@invalid = 'should-not'">
                                                <xsl:value-of select="'Matched '"/>
                                                <span class="small text-muted">
                                                    <xsl:value-of select="' (but should not)'"/>
                                                </span>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="'Matched! '"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                    <td class="small text-muted">
                                        <xsl:value-of select="@score"/>
                                    </td>
                                    <td class="text-right">
                                        <xsl:choose>
                                            <xsl:when test="@invalid = 'should'">
                                                <a class="small text-muted underline">
                                                    <xsl:attribute name="href" select="concat('?test-id=', $test-id, '&amp;data-id=', m:data/@xml:id, '&amp;action=should-not-match', '&amp;lang=', $lang)"/>
                                                    <xsl:value-of select="'mark as correct'"/>
                                                </a>
                                            </xsl:when>
                                            <xsl:when test="@invalid = 'should-not'">
                                                <a class="small text-muted underline">
                                                    <xsl:attribute name="href" select="concat('?test-id=', $test-id, '&amp;data-id=', m:data/@xml:id, '&amp;action=should-match', '&amp;lang=', $lang)"/>
                                                    <xsl:value-of select="'mark as correct'"/>
                                                </a>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <a class="small text-muted underline">
                                                    <xsl:attribute name="href" select="concat('?test-id=', $test-id, '&amp;data-id=', m:data/@xml:id, '&amp;action=should-not-match', '&amp;lang=', $lang)"/>
                                                    <xsl:value-of select="'mark as wrong'"/>
                                                </a>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <tr>
                                <td colspan="6" class="text-muted text-center">
                                    <xsl:value-of select="'~ No matches ~'"/>
                                </td>
                            </tr>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </tbody>
                <tfoot>
                    <tr>
                        <td colspan="6">
                            <form action="test-searches.html" method="post">
                                <input type="hidden" name="lang">
                                    <xsl:attribute name="value" select="$lang"/>
                                </input>
                                <input type="hidden" name="test-id">
                                    <xsl:attribute name="value" select="$test-id"/>
                                </input>
                                <input type="hidden" name="action" value="should-match"/>
                                <div class="input-group" style="width:100%;">
                                    <span class="input-group-addon">
                                        <xsl:value-of select="'Should match '"/>
                                    </span>
                                    <select name="data-id" class="form-control">
                                        <xsl:for-each select="/m:response/m:datas/m:data[not(@xml:id = $results/m:data/@xml:id)]">
                                            <xsl:sort select="."/>
                                            <option>
                                                <xsl:attribute name="value" select="@xml:id"/>
                                                <xsl:value-of select="."/>
                                            </option>
                                        </xsl:for-each>
                                    </select>
                                    <span class="input-group-btn">
                                        <button class="btn btn-primary" type="submit">
                                            <xsl:value-of select="'Add'"/>
                                        </button>
                                    </span>
                                </div>
                            </form>
                        </td>
                    </tr>
                </tfoot>
            </table>
            
        </div>
        
    </xsl:template>
    
    <xsl:template match="exist:match">
        <xsl:if test="preceding-sibling::*[1][self::exist:match]">
            <span class="text-muted">
                <xsl:value-of select="'·'"/>
            </span>
        </xsl:if>
        <mark class="no-shadow">
            <xsl:apply-templates select="node()"/>
        </mark>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:value-of select="replace(., '­', '-')"/>
    </xsl:template>
    
</xsl:stylesheet>