<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/xslt/webpage.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            <xsl:call-template name="operations-page">
                <xsl:with-param name="active-tab" select="@model"/>
                <xsl:with-param name="tab-content">
                    
                    <!-- Dropdown list of config files -->
                    <form action="sys-config.html" method="post" class="filter-form" data-loading="Loading...">
                        <select name="config-set" class="form-control">
                            <xsl:for-each select="m:sys-config-files/m:option">
                                <option>
                                    <xsl:attribute name="value" select="@id"/>
                                    <xsl:if test="@selected eq 'true'">
                                        <xsl:attribute name="selected" select="'selected'"/>
                                    </xsl:if>
                                    <xsl:value-of select="text()"/>
                                </option>
                            </xsl:for-each>
                        </select>
                    </form>
                    
                    <!-- Help relevant to selected file  -->
                    <xsl:choose>
                        <xsl:when test="m:sys-config-files/m:option[@selected eq 'true'][not(@allow-updates eq 'true')]">
                            <div class="alert alert-info text-center top-margin small">
                                <p>
                                    <xsl:value-of select="'Currently this page only allows you to review the configuration. To make updates please email your changes to '"/>
                                    <a href="mailto:dominic.latham@84000.co" target="_blank">
                                        <xsl:value-of select="'dominic.latham@84000.co'"/>
                                    </a>
                                    <xsl:value-of select="'. Please include the relevant key in the email.'"/>
                                </p>
                            </div>
                        </xsl:when>
                    </xsl:choose>
                    
                    <!-- List of parameters -->
                    <xsl:variable name="max-setting-values" select="max(m:settings/m:setting/count(m:value))"/>
                    <div class="div-list no-border-top">
                        
                        <div class="item heading">
                            <div class="row">
                                <div class="col-sm-2">
                                    <xsl:value-of select="'Key'"/>
                                </div>
                                <div class="col-sm-10">
                                    <xsl:choose>
                                        <xsl:when test="$max-setting-values gt 1">
                                            <xsl:attribute name="colspan" select="$max-setting-values * 2"/>
                                            <xsl:value-of select="'Values'"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="'Value'"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </div>
                            </div>
                        </div>
                        
                        <xsl:for-each select="m:settings/m:setting">
                            <xsl:sort select="xs:integer(@sort-index)"/>
                            <xsl:variable name="setting" select="."/>
                            <div class="item">
                                <div class="row">
                                    <div class="col-sm-2 text-danger italic">
                                        <xsl:value-of select="$setting/@key"/>
                                    </div>
                                    <div class="col-sm-10">
                                        <div class="row">
                                            <xsl:for-each select="1 to $max-setting-values">
                                                <xsl:variable name="value-index" select="." as="xs:integer"/>
                                                <xsl:variable name="value" select="$setting/m:value[$value-index]"/>
                                                <xsl:choose>
                                                    <xsl:when test="$value">
                                                        <div class="col-sm-6">
                                                            <div class="row">
                                                                <xsl:if test="$value[@key]">
                                                                    <div class="col-sm-2 text-warning italic">
                                                                        <xsl:value-of select="$value/@key"/>
                                                                    </div>
                                                                </xsl:if>
                                                                <div class="col-sm-12 break">
                                                                    <xsl:if test="$value[@key]">
                                                                        <xsl:attribute name="class" select="'col-sm-10 break'"/>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="$value"/>
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </xsl:when>
                                                </xsl:choose>
                                            </xsl:for-each>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </xsl:for-each>
                        
                    </div>
                    
                </xsl:with-param>
            </xsl:call-template>
        </xsl:variable>
        
        <xsl:call-template name="reading-room-page">
            <xsl:with-param name="page-url" select="''"/>
            <xsl:with-param name="page-class" select="'utilities'"/>
            <xsl:with-param name="page-title" select="'System Config | 84000 Project Management'"/>
            <xsl:with-param name="page-description" select="'Configuration of the 84000 system'"/>
            <xsl:with-param name="content" select="$content"/>
        </xsl:call-template>
        
    </xsl:template>
    
</xsl:stylesheet>