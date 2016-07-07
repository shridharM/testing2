<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Email_to_contact_when_value_is_changed_of_status_field_on_recurring_gift</fullName>
        <description>Send Email to contact when value is changed of status field on recurring gift.</description>
        <protected>false</protected>
        <recipients>
            <field>Constituent__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Giving_Power/Recurring_Gift_Confirmation_Email</template>
    </alerts>
    <rules>
        <fullName>ConfirmationEmail</fullName>
        <actions>
            <name>Send_Email_to_contact_when_value_is_changed_of_status_field_on_recurring_gift</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>On change of status of Recurring Gift, an email will send to the contact that recurring gift status has been changed.</description>
        <formula>ISCHANGED( Status__c )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
