<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateSponsorshipAmount</fullName>
        <description>Updates Sponsorship Amount - quantity * benefit.sponsorship amount</description>
        <field>Total_Benefit_Value__c</field>
        <formula>Quantity__c *  Benefit__r.Benefit_Value__c</formula>
        <name>UpdateSponsorshipAmount</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>UpdateSponsorshipAmount</fullName>
        <actions>
            <name>UpdateSponsorshipAmount</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event_Level_Benefit__c.Quantity__c</field>
            <operation>greaterThan</operation>
            <value>0</value>
        </criteriaItems>
        <description>Updates Sponsorship Amount if applicable</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
