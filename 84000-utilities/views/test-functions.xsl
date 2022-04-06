<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" version="3.0" exclude-result-prefixes="#all">
    
    <xsl:import href="../../84000-reading-room/views/html/website-page.xsl"/>
    <xsl:import href="common.xsl"/>
    
    <xsl:template match="/m:response">
        
        <xsl:variable name="content">
            
            <h2>
                <xsl:value-of select="testsuites/testsuite/@package"/>
            </h2>
            
            <table class="table table-responsive table-icons width-auto">
                <thead>
                    <tr>
                        <th class="icon">Result</th>
                        <th>Class</th>
                    </tr>
                </thead>
                <tbody>
                    <xsl:for-each select="testsuites/testsuite/testcase">
                        <xsl:sort select="if(error | failure) then 0 else 1"/>
                        <tr>
                            <td class="icon">
                                <xsl:choose>
                                    <xsl:when test="error | failure | output">
                                        <xsl:attribute name="rowspan" select="count(error | failure | output) + 1"/>
                                        <i class="fa fa-times-circle"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <i class="fa fa-check-circle"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </td>
                            <td>
                                <xsl:value-of select="@class"/>
                            </td>
                        </tr>
                        <xsl:for-each select="error | failure">
                            <tr class="sub text-danger italic">
                                <td>
                                    <xsl:value-of select="@message"/>
                                </td>
                            </tr>
                        </xsl:for-each>
                        <xsl:for-each select="output">
                            <tr class="sub text-muted italic">
                                <td>
                                    <xsl:value-of select="concat('output: ', data())"/>
                                </td>
                            </tr>
                        </xsl:for-each>
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