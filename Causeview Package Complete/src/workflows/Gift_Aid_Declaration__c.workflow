<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Effective_Date</fullName>
        <field>Effective_Date__c</field>
        <formula>if(text(Type__c)= &quot;This donation, and all future &amp; historic&quot;,date(year(Next_Fiscal_Date__c)-5,month(Next_Fiscal_Date__c),01), Start_Date__c)</formula>
        <name>Set Effective Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_End_Date_to_Null</fullName>
        <field>End_Date__c</field>
        <name>Set End Date to Null</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_End_Date</fullName>
        <field>End_Date__c</field>
        <formula>Start_Date__c</formula>
        <name>Update End Date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Declaration -One-time Effective Date</fullName>
        <actions>
            <name>Set_Effective_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_End_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.App_Settings__c.Gift_Aid_Enable__c = true,ISPICKVAL( Type__c ,&apos;This donation only&apos;))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Declaration Effective Date</fullName>
        <actions>
            <name>Set_Effective_Date</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_End_Date_to_Null</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND($Setup.App_Settings__c.Gift_Aid_Enable__c = true,!(ISPICKVAL( Type__c ,&apos;This donation only&apos;)))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
