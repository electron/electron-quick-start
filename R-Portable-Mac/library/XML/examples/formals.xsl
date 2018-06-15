<?xml version="1.0"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
       version="1.0">

<!--
<xsl:template match="*">
 x
</xsl:template>
-->

<!--
 What we want here is a way of only extracting the arguments
-->

<xsl:template match="[not(usage)]">
 other
</xsl:template>

<xsl:template match="next">, </xsl:template>

<!-- /Rhelp/usage/arg -->
<xsl:template match="defaultValue"> = <xsl:value-of select="." /></xsl:template>

<!-- need to get the commas into this. So we use the <next> tag. 
 /Rhelp/usage/
-->
<xsl:template match="arg">
<xsl:value-of select="argName"/><xsl:apply-templates select="defaultValue"/><xsl:apply-templates select="next"/>
</xsl:template>

<xsl:template match="//usage">
<xsl:value-of select="sname" />(<xsl:apply-templates select="arg | next" />)
</xsl:template>


</xsl:stylesheet>
