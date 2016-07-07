<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>FullfilledStatus</fullName>
        <description>Change status to Fullfilled</description>
        <field>Status__c</field>
        <literalValue>Fulfilled</literalValue>
        <name>FullfilledStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>PartiallyFulfilledStatus</fullName>
        <description>Updates the Installment status to Partially Fullfilled.</description>
        <field>Status__c</field>
        <literalValue>Partially Fulfilled</literalValue>
        <name>PartiallyFulfilledStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>InstallmentFullfilled</fullName>
        <actions>
            <name>FullfilledStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Installment__c.Installment_Balance__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>Installment status changes to Fullfilled if criteria met</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>InstallmentPartialFullfillment</fullName>
        <actions>
            <name>PartiallyFulfilledStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>change the status to Partial Fullfilled if criteria met</description>
        <formula>AND( Installment_Balance__c  &gt; 0,  Installment_Balance__c  &lt;  Installment_Amount__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
