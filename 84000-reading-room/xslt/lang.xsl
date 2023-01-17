<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:pkg="http://expath.org/ns/pkg" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:common="http://read.84000.co/common" xmlns:functx="http://www.functx.com" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="3.0" exclude-result-prefixes="#all">
    
    <!-- Store ref to document root for use in key() -->
    <xsl:variable name="root" select="/"/>
    
    <xsl:variable name="response-lang" select="/m:response/@lang"/>
    <xsl:variable name="response-model" select="/m:response/@model"/>
    <xsl:variable name="replace-text" select="/m:response/m:replace-text/m:value"/>
    <xsl:key name="text-items" match="/m:response/m:lang-items/m:item" use="@key"/>
    <!--<xsl:variable name="text-items" select="/m:response/m:lang-items/m:item"/>-->
    
    <xsl:template name="text">
        
        <xsl:param name="global-key" as="xs:string" required="yes"/>
        
        <xsl:variable name="text-item" select="key('text-items', $global-key, $root)[1]"/>
        
        <xsl:choose>
            
            <xsl:when test="$text-item">
                <xsl:call-template name="normalize-nodes-space">
                    <xsl:with-param name="nodes" select="$text-item/node()"/>
                </xsl:call-template>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="local-key" select="tokenize($global-key, '\.')"/>
                <xsl:variable name="common-key" select="string-join(('about', 'common', $local-key[last()]), '.')"/>
                <xsl:variable name="text-item" select="key('text-items', $common-key, $root)[1]"/>
                <xsl:if test="$text-item">
                    <xsl:call-template name="normalize-nodes-space">
                        <xsl:with-param name="nodes" select="$text-item/node()"/>
                    </xsl:call-template>
                </xsl:if>
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
    
    <xsl:template name="local-text">
        <xsl:param name="local-key" as="xs:string" required="yes"/>
        <xsl:call-template name="text">
            <xsl:with-param name="global-key" select="string-join((tokenize($response-model, '/'), $local-key), '.')"/>
        </xsl:call-template>
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
                    <xsl:element name="{ $node-name }" namespace="http://www.w3.org/1999/xhtml">
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
                    <xsl:element name="{ local-name(.) }" namespace="http://www.w3.org/1999/xhtml">
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