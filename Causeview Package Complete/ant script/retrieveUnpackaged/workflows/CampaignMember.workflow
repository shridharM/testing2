<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>SendRSVP</fullName>
        <description>SendRSVP</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>Causeview_Old_templates/RSVP</template>
    </alerts>
    <rules>
        <fullName>CMEmailSend</fullName>
        <active>false</active>
        <criteriaItems>
            <field>CampaignMember.Status</field>
            <operation>equals</operation>
            <value>Invited - Sent Email</value>
        </criteriaItems>
        <description>Campaign Member email invitation.  Emails campaign member an event RSVP email if criteria are met.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
