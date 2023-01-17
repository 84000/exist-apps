<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:m="http://read.84000.co/ns/1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" exclude-result-prefixes="#all">
        
    <xsl:template name="epub-page">
        
        <xsl:param name="page-title"/>
        <xsl:param name="content"/>
        
        <html xmlns:epub="http://www.idpf.org/2007/ops">
            <head>
                <title>
                    <xsl:value-of select="concat($page-title[1], ' - ', /m:response/m:translation/m:titles/m:title[@xml:lang eq 'en'][1])"/>
                </title>
                <link href="css/manualStyles.css" rel="stylesheet" type="text/css"/>
                <link href="css/fontStyles.css" rel="stylesheet" type="text/css"/>
            </head>
            <body lang="en-GB" xml:lang="en-GB">
                <xsl:copy-of select="$content"/>
            </body>
        </html>
        
    </xsl:template>
    
</xsl:stylesheet>