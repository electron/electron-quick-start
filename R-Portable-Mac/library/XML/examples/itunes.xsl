<?xml version="1.0"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        version="1.0">

 <xsl:output encoding="UTF-8"/>
        
    <xsl:template match="/">
        <songlist>
            <xsl:apply-templates select="plist/dict/dict/dict"/>
        </songlist>
    </xsl:template>
    
    <xsl:template match="dict">
        <song>
            <xsl:apply-templates select="key"/>
        </song>
    </xsl:template>
    
    <xsl:template match="key">
        <xsl:element name="{translate(text(), ' ', '_')}">
            <xsl:value-of select="following-sibling::node()[1]"/>
        </xsl:element>
<xsl:text>
</xsl:text>
    </xsl:template>
</xsl:stylesheet>
