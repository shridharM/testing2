<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>UpdateEventId</fullName>
        <description>Update transaction Event Id from allocation</description>
        <field>Event_Id__c</field>
        <formula>New_Campaign__c</formula>
        <name>UpdateEventId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Gift__c</targetObject>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateLastAllocationUpdate</fullName>
        <description>Update toTransaction _sysLastAllocationUpdate field</description>
        <field>sysLastAllocationUpdate__c</field>
        <formula>Today()</formula>
        <name>UpdateLastAllocationUpdate</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <targetObject>Gift__c</targetObject>
    </fieldUpdates>
    <rules>
        <fullName>UpdateTransactionAllocationSysDate</fullName>
        <actions>
            <name>UpdateLastAllocationUpdate</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Gift_Detail__c.CreatedDate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>If Allocation has been update, then update Transaction _sysLastAllocationUpdate field to evaluate workflows.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
