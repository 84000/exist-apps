<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">

    <!--
        Excel 2012 generic files generator

        This file generates the 'generic' files, that are needed in order to generate
        valid excel file.

        It is included and should not be used directly.

        @author Pavel Ptacek
        @copyright Pavel Ptacek (c) 2012-2013
    -->

    <!-- generate theme file -->
    <xsl:template xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main" name="generate_themes">
        <xsl:param name="content"/>

        <xsl:for-each select="$content/a:theme">
            <m:entry href="xl/theme/theme{position()}.xml">
                <xsl:copy-of select="."/>
            </m:entry>
        </xsl:for-each>
        
    </xsl:template>

    <!-- generate styles file -->
    <xsl:template name="generate_styles">
        <xsl:param name="content"/>

        <m:entry href="xl/styles.xml">
            <xsl:copy-of select="$content"/>
        </m:entry>
        
    </xsl:template>

    <!-- generate binary file -->
    <xsl:template name="generate_binary">
        <xsl:param name="name"/>
        <m:entry href="{$name}" media-type="text/plain" omit-xml-declaration="yes">
            <xsl:fallback/>
        </m:entry>
    </xsl:template>

</xsl:stylesheet>