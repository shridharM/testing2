<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Opp_Record_Type_to_Converted</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Grant</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Opp Record Type to Converted</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Converted Opp</fullName>
        <actions>
            <name>Opp_Record_Type_to_Converted</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Opportunity.StageName</field>
            <operation>equals</operation>
            <value>Converted to Transaction</value>
        </criteriaItems>
        <description>Sets Opportunity record type to Converted to Transaction.  This workflow is deprecated post version 1.808.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
