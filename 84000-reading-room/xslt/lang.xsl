<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:m="http://read.84000.co/ns/1.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:xhtml="http://www.w3.org/1999/xhtml" version="2.0" exclude-result-prefixes="#all">
    
    <xsl:variable name="response-lang" select="/m:response/@lang"/>
    <xsl:variable name="replace-text" select="/m:response/m:replace-text/m:value"/>
    <xsl:variable name="text-items" select="doc(concat(/m:response/@app-config, '/', 'texts.', if($response-lang = ('en', 'zh')) then $response-lang else 'en', '.xml'))//m:item"/>
    
    <xsl:template name="local-text">
        <xsl:param name="local-key" as="xs:string" required="yes"/>
        <xsl:variable name="common-key" select="string-join(('about', 'common', $local-key), '.')"/>
        <xsl:variable name="global-key" select="string-join((tokenize(/m:response/@model-type, '/'), $local-key), '.')"/>
        <xsl:variable name="text-item" select="$text-items[@key = ($global-key, $common-key)][1]/node()"/>
        <xsl:choose>
            <xsl:when test="$text-item instance of text()">
                <xsl:call-template name="replace-text">
                    <xsl:with-param name="text" select="normalize-space($text-item)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="normalize-nodes-space">
                    <xsl:with-param name="nodes" select="$text-item"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="local-text-if-exists">
        <xsl:param name="local-key" as="xs:string" required="yes"/>
        <xsl:param name="node-name" as="xs:string?" required="no"/>
        <xsl:variable name="local-text">
            <xsl:call-template name="local-text">
                <xsl:with-param name="local-key" select="$local-key"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:if test="$local-text gt ''">
            <xsl:choose>
                <xsl:when test="$node-name gt ''">
                    <xsl:element name="{ $node-name }">
                        <xsl:value-of select="$local-text"/>
                    </xsl:element>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$local-text"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="normalize-nodes-space">
        <xsl:param name="nodes" required="yes"/>
        <xsl:for-each select="$nodes">
            <xsl:choose>
                <xsl:when test=". instance of text()">
                    <xsl:call-template name="replace-text">
                        <xsl:with-param name="text" select="translate(normalize-space(concat('', translate(., '&#xA;', ''), '')), '', '')"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="{ node-name(.) }">
                        <xsl:for-each select="@*">
                            <xsl:attribute name="{ name(.) }">
                                <xsl:call-template name="replace-text">
                                    <xsl:with-param name="text" select="."/>
                                </xsl:call-template>
                            </xsl:attribute>    
                        </xsl:for-each>
                        <xsl:call-template name="normalize-nodes-space">
                            <xsl:with-param name="nodes" select="./node()"/>
                        </xsl:call-template>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template name="replace-text">
        <xsl:param name="text" as="xs:string"/>
        <xsl:value-of select="functx:replace-multi($text, $replace-text/@key, $replace-text/text())"/>
    </xsl:template>
    
    <xsl:function name="functx:replace-multi" as="xs:string?">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="changeFrom" as="xs:string*"/>
        <xsl:param name="changeTo" as="xs:string*"/>
        
        <xsl:sequence select="if (count($changeFrom) &gt; 0) then functx:replace-multi(replace($arg,$changeFrom[1] ,functx:if-absent($changeTo[1], '')), $changeFrom[position() &gt; 1], $changeTo[position() &gt; 1]) else $arg"/>
        
    </xsl:function>
    
    <xsl:function name="functx:if-absent" as="item()*">
        <xsl:param name="arg" as="item()*"/>
        <xsl:param name="value" as="item()*"/>
        
        <xsl:sequence select="if (exists($arg)) then $arg else $value"/>
        
    </xsl:function>
    
</xsl:stylesheet>