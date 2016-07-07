<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SendEventRegistrationConfirmationEmail</fullName>
        <description>SendEventRegistrationConfirmationEmail</description>
        <protected>false</protected>
        <recipients>
            <field>Individual__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Free_Event_Registration_Confirmation_New</template>
    </alerts>
    <alerts>
        <fullName>SendGuestRegEmail</fullName>
        <description>SendGuestRegEmail</description>
        <protected>false</protected>
        <recipients>
            <field>Individual__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Guest_Registration_eMail_New</template>
    </alerts>
    <fieldUpdates>
        <fullName>CheckedInStatus</fullName>
        <field>Status__c</field>
        <literalValue>Attended</literalValue>
        <name>CheckedInStatus</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdateSysSendEmailConfirmation</fullName>
        <description>Updates _sysSendEmailConfirmation with Today () when workflow is invoked.</description>
        <field>sysSendEmailConfirmation__c</field>
        <formula>Today()</formula>
        <name>UpdateSysSendEmailConfirmation</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>UpdatesysGuestEmailSent</fullName>
        <description>Updates _sysGuestEmailSent field with Today ().</description>
        <field>sysGuestEmailSent__c</field>
        <formula>Today()</formula>
        <name>UpdatesysGuestEmailSent</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>CheckIn</fullName>
        <actions>
            <name>CheckedInStatus</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Event_Registration__c.Checked_In__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Changes status from Registered to Attended when the attendee checks in</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SendFreeEventRegistrationConfirmation</fullName>
        <actions>
            <name>SendEventRegistrationConfirmationEmail</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdateSysSendEmailConfirmation</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Event_Registration_Confirmation_Email_Sent</name>
            <type>Task</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>Event_Registration__c.sysSendEmailConfirmation__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Event_Registration__c.Transaction_ID__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Event_Registration__c.Status__c</field>
            <operation>equals</operation>
            <value>Registered</value>
        </criteriaItems>
        <description>Auto sends email confirmation for free event registrations.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SendGuestEmail</fullName>
        <actions>
            <name>SendGuestRegEmail</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>UpdatesysGuestEmailSent</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Automated_Guest_Registration_Email_Sent</name>
            <type>Task</type>
        </actions>
        <active>true</active>
        <description>Sends email to event registrant prompting for additional guest information.</description>
        <formula>AND((ISBLANK(Guest_of__c)), Number_of_Guests__c &gt; 0,Transaction_Amount__c &gt; 0, ISBLANK(sysGuestEmailSent__c))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <tasks>
        <fullName>Automated_Guest_Registration_Email_Sent</fullName>
        <assignedTo>cvdevmgr@causeview.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>The system has sent the automated guest registration email.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Automated Guest Registration Email Sent</subject>
    </tasks>
    <tasks>
        <fullName>Event_Registration_Confirmation_Email_Sent</fullName>
        <assignedTo>cvdevmgr@causeview.com</assignedTo>
        <assignedToType>user</assignedToType>
        <description>The automated event registration confirmation email has been sent.</description>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>Event Registration Confirmation Email Sent</subject>
    </tasks>
</Workflow>
