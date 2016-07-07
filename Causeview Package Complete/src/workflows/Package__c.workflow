<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>PackageUniqueName</fullName>
        <field>Unique_Name__c</field>
        <formula>Name</formula>
        <name>PackageUniqueName</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>EnforceUniqueName</fullName>
        <actions>
            <name>PackageUniqueName</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Package__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Enforces a unique name for Packages.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
