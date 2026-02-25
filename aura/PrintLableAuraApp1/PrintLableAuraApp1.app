<aura:application extends="force:slds">
    <aura:attribute name="recordId" type="String" />
    <aura:handler name="init" value="{!this}" action="{!c.doInit}"/>
    
    <lightning:button label="Print" onclick="{!c.printPage}" />
    
    <div style="margin-left: 20px;margin-right: 20px;">
    	<c:printLable recordId="{!v.recordId}"> </c:printLable>
        <c:printLable recordId="{!v.recordId}"> </c:printLable>
    </div>
    
    <!-- <c:GenerateLabelAura> </c:GenerateLabelAura>  -->
</aura:application>