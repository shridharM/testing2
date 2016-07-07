<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SendVolunteerAppAcknowledgement</fullName>
        <description>SendVolunteerAppAcknowledgement</description>
        <protected>false</protected>
        <recipients>
            <field>Volunteer__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Volunteer_Application_Acknowledgement_new</template>
    </alerts>
    <rules>
        <fullName>SendVolunteerAppAcknowledgement</fullName>
        <actions>
            <name>SendVolunteerAppAcknowledgement</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Automated_Email_Acknowledement_Sent</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Volunteer_Application__c.Status__c</field>
            <operation>equals</operation>
            <value>Submitted / In-Screening</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Application__c.Source__c</field>
            <operation>equals</operation>
            <value>Online Actionform</value>
        </criteriaItems>
        <criteriaItems>
            <field>Volunteer_Application__c.Type__c</field>
            <operation>equals</operation>
            <value>New Applicant</value>
        </criteriaItems>
        <description>Auto emails acknowledgement upon Application creation where Source = Online Actionform</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>Automated_Email_Acknowledement_Sent</fullName>
        <assignedTo>cvdevmgr@causeview.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>The system has sent the automated acknowledgement email.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Automated Email Acknowledement Sent</subject>
    </tasks>
</Workflow>
