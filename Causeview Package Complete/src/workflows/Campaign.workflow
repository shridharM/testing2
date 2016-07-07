<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>CheckParentAppeal</fullName>
        <description>Checks parent appeal checkbox</description>
        <field>ParentAppeal__c</field>
        <literalValue>1</literalValue>
        <name>CheckParentAppeal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UncheckParentAppeal</fullName>
        <description>Unchecks Parent Appeal if Parent Campaign record type is not campaign</description>
        <field>ParentAppeal__c</field>
        <literalValue>0</literalValue>
        <name>UncheckParentAppeal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
</Workflow>
